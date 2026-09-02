import json
import os
import tempfile
import unittest
import warnings
from pathlib import Path
from types import SimpleNamespace

import numpy as np
from benedict import benedict as bd

from src import cache
from src.cpu import CPU
from src.syscalls import DEFAULT_DELAY_MAX_CYCLES, DELAY_CYCLE_LIMIT
from src.word import Word
from src.power import (CPAAttack, DEFAULT_LEAKAGE_WEIGHTS, HW, SBOX, aes_internal,
                       cycle_power, power_draw, POWER_TRACE, POWER_VALUES, set_config)


def _synthetic_traces(model, key, seed):
    """Build one synthetic power trace per plaintext byte.

    The middle sample carries the signal HW(model(input, key)); the two
    surrounding samples carry input-dependent noise so that no trace column
    is constant (which would divide by a zero standard deviation).
    """
    rng = np.random.default_rng(seed)
    traces = []
    for input_byte in range(256):
        signal = float(HW[model(input_byte, key)])
        noise = rng.standard_normal(2)
        traces.append((input_byte, np.array([noise[0], signal, noise[1]])))
    return traces


class _PowerTraceStateMixin:
    """PowerTrace is a singleton; every test has to reset it explicitly."""

    def setUp(self):
        self._reset()

    def tearDown(self):
        self._reset()

    @staticmethod
    def _reset():
        POWER_TRACE.capture = False
        POWER_TRACE.sample = []
        POWER_TRACE.trace = []
        POWER_TRACE.stall_power = 0.0
        POWER_TRACE.leakage_weights = dict(DEFAULT_LEAKAGE_WEIGHTS)
        POWER_TRACE.noise_sigma = 0.0
        POWER_TRACE.name = "power-trace"
        POWER_TRACE.metadata = {}
        POWER_TRACE.set_seed(None)


class CPALeakageModelTest(unittest.TestCase):

    def test_cpa_uses_supplied_leakage_model(self):
        key = 0x6d
        add_round_key = lambda input_byte, key_guess: input_byte ^ key_guess
        traces = _synthetic_traces(add_round_key, key, seed=1)

        scores = CPAAttack(traces, add_round_key).attack()

        self.assertEqual(int(np.argmax(scores)), key)

    def test_cpa_default_leakage_model_recovers_key(self):
        key = 0x2b
        traces = _synthetic_traces(aes_internal, key, seed=0)

        scores = CPAAttack(traces).attack()

        self.assertEqual(int(np.argmax(scores)), key)


class CacheRefillPowerTest(_PowerTraceStateMixin, unittest.TestCase):
    """CacheLine.write is the cache_refill power source; its weight gates it."""

    def test_cache_write_contributes_power_when_enabled(self):
        POWER_TRACE.capture = True

        cache.CacheLRU(4, 2, 4).write(0, 0b1011)

        self.assertEqual(POWER_TRACE.sample, [3])

    def test_cache_write_contributes_nothing_when_the_weight_is_zero(self):
        POWER_TRACE.leakage_weights["cache_refill"] = 0.0
        POWER_TRACE.capture = True

        cache.CacheLRU(4, 2, 4).write(0, 0b1011)

        self.assertEqual(POWER_TRACE.sample, [])

    def test_cycle_still_yields_a_sample_when_the_weight_is_zero(self):
        # Trace length must not depend on the weight: a cycle in which the only
        # activity was a zero-weighted cache refill still produces one 0.0 sample.
        POWER_TRACE.leakage_weights["cache_refill"] = 0.0
        POWER_TRACE.capture = True

        cache.CacheLRU(4, 2, 4).write(0, 0b1011)
        POWER_TRACE.flush_sample()

        self.assertEqual(POWER_TRACE.trace, [0.0])


class CPAZeroVarianceTest(unittest.TestCase):
    """A constant sample point must not poison the score of every key guess.

    Correlating a constant column divides by a zero standard deviation. The
    resulting NaN used to be reduced with the builtin max(), which keeps the
    first element unless a later one compares greater -- and every comparison
    against NaN is False. A NaN in the first sample point therefore became the
    score of all 256 guesses, and argmax silently returned 0.
    """

    @staticmethod
    def _with_constant_leading_sample(traces):
        # Models the cycle that starts the capture: deterministic, so identical
        # in every trace.
        return [(input_byte, np.concatenate([[1.0], trace]))
                for input_byte, trace in traces]

    def test_constant_leading_sample_does_not_hide_the_key(self):
        key = 0x1A
        traces = self._with_constant_leading_sample(
            _synthetic_traces(aes_internal, key, seed=3))

        with warnings.catch_warnings():
            warnings.simplefilter("ignore", RuntimeWarning)
            scores = CPAAttack(traces).attack()

        self.assertFalse(np.isnan(scores).any())
        self.assertEqual(int(np.argmax(scores)), key)

    def test_constant_sample_point_is_reported(self):
        traces = self._with_constant_leading_sample(
            _synthetic_traces(aes_internal, 0x1A, seed=4))

        with self.assertWarnsRegex(RuntimeWarning, "constant across all traces"):
            CPAAttack(traces).attack()

    def test_constant_leakage_model_scores_zero_instead_of_nan(self):
        # A model that ignores the plaintext has no varying hypothesis, so the
        # denominator vanishes for every sample point.
        traces = _synthetic_traces(aes_internal, 0x1A, seed=5)

        scores = CPAAttack(traces, lambda input_byte, key_guess: 0).attack()

        self.assertFalse(np.isnan(scores).any())
        self.assertEqual(set(scores), {0.0})


class CyclePowerSampleTest(_PowerTraceStateMixin, unittest.TestCase):
    """One tick commits exactly one sample, whether or not the cycle faulted."""

    @staticmethod
    @cycle_power
    def _tick(fault_info):
        # Stands in for CPU.tick: accumulates this cycle's activity and reports
        # whether the cycle faulted. cycle_power only looks at the return value.
        POWER_TRACE.append(3.0)
        return SimpleNamespace(fault_info=fault_info)

    def test_non_faulting_cycle_commits_its_sample(self):
        POWER_TRACE.capture = True

        self._tick(None)

        self.assertEqual(POWER_TRACE.trace, [3.0])

    def test_faulting_cycle_commits_its_sample(self):
        POWER_TRACE.capture = True

        self._tick("fault")

        self.assertEqual(POWER_TRACE.trace, [3.0])

    def test_faulting_cycle_does_not_leak_into_the_next_sample(self):
        # The regression: a dropped faulting cycle left its activity in the
        # accumulator, so the following cycle reported the sum of both.
        POWER_TRACE.capture = True

        self._tick("fault")
        self._tick(None)

        self.assertEqual(POWER_TRACE.trace, [3.0, 3.0])


class SplicedSampleTest(_PowerTraceStateMixin, unittest.TestCase):
    """insert_sample() splices a sample without touching the cycle in flight."""

    def test_inserted_sample_is_appended_to_the_trace(self):
        POWER_TRACE.capture = True

        POWER_TRACE.insert_sample(-7.0)

        self.assertEqual(POWER_TRACE.trace, [-7.0])

    def test_inserted_sample_does_not_absorb_the_pending_cycle(self):
        # sys_trace_delay runs inside CPU.tick, i.e. while the ecall cycle's
        # own activity is still in the accumulator. Splicing must not flush it.
        POWER_TRACE.capture = True

        POWER_TRACE.append(5.0)
        POWER_TRACE.insert_sample(-7.0)
        POWER_TRACE.flush_sample()

        self.assertEqual(POWER_TRACE.trace, [-7.0, 5.0])

    def test_nothing_is_inserted_while_not_capturing(self):
        POWER_TRACE.capture = False

        POWER_TRACE.insert_sample(-7.0)

        self.assertEqual(POWER_TRACE.trace, [])


class _StubSlot:
    """Stands in for _Slot: power_draw only reads .active and .instr_ty.name."""

    def __init__(self, name, active):
        self.instr_ty = SimpleNamespace(name=name)
        self.active = active

    @power_draw
    def tick_execute(self):
        return None


class InstructionPowerSourceTest(_PowerTraceStateMixin, unittest.TestCase):
    """power_draw emits opcode power while working and stall power while blocked."""

    def test_working_slot_draws_its_opcode_power(self):
        POWER_TRACE.capture = True

        _StubSlot("mul", active=True).tick_execute()

        self.assertEqual(POWER_TRACE.sample, [POWER_VALUES["mul"]])

    def test_blocked_slot_draws_stall_power_instead(self):
        POWER_TRACE.capture = True
        POWER_TRACE.stall_power = 0.25

        _StubSlot("mul", active=False).tick_execute()

        self.assertEqual(POWER_TRACE.sample, [0.25])

    def test_stall_power_is_tagged_as_its_own_source(self):
        # The tag is what lets a later per-source weight reach the stall term.
        POWER_TRACE.capture = True
        recorded = []
        POWER_TRACE.append = lambda value, source="instruction": recorded.append(source)
        try:
            _StubSlot("mul", active=True).tick_execute()
            _StubSlot("mul", active=False).tick_execute()
        finally:
            del POWER_TRACE.append

        self.assertEqual(recorded, ["instruction", "stall"])


class LeakageSourceTagTest(_PowerTraceStateMixin, unittest.TestCase):
    """Every leakage site names its source, so a weight can reach it.

    The store and the load write-back used to fall through to the default
    "instruction" tag, which made them indistinguishable from the opcode
    constant. The probe stores a value with two set bits into zeroed memory and
    reads it back into a zeroed register, so both Hamming terms are 2.
    """

    PROBE = """
        addi a0, zero, 5
        sw   a0, zero, 0
        lw   a1, zero, 0
    """

    def _recorded(self):
        "Every (value, source) pair appended while the probe runs."
        recorded = []
        cpu = CPU(bd.from_yaml("config.yml"))
        cpu.load_program(self.PROBE)

        POWER_TRACE.capture = True
        POWER_TRACE.append = lambda value, source="instruction": recorded.append(
            (value, source))
        try:
            for _ in range(40):
                if not cpu.tick().executing_program:
                    break
        finally:
            del POWER_TRACE.append          # drop the instance attribute again
        return recorded

    def _values_from(self, source):
        return [value for value, tag in self._recorded() if tag == source]

    def test_byte_store_is_tagged_as_memory_store(self):
        self.assertIn(2, self._values_from("memory_store"))

    def test_load_write_back_is_tagged_as_register_load(self):
        self.assertIn(2, self._values_from("register_load"))


class LeakageWeightTest(_PowerTraceStateMixin, unittest.TestCase):
    """append() scales each contribution by the weight of its source.

    The weights exist because the sources are on incommensurable scales: a
    cache-line refill can inject four 0-32 Hamming distances into the same
    sample as a 0-8 algorithmic leak, so the leak being attacked is buried by
    activity that has nothing to do with the key.
    """

    def test_full_weight_passes_the_value_through(self):
        POWER_TRACE.capture = True

        POWER_TRACE.append(7.0, source="cache_refill")

        self.assertEqual(POWER_TRACE.sample, [7.0])

    def test_zero_weight_drops_the_contribution(self):
        POWER_TRACE.leakage_weights["cache_refill"] = 0.0
        POWER_TRACE.capture = True

        POWER_TRACE.append(7.0, source="cache_refill")

        self.assertEqual(POWER_TRACE.sample, [])

    def test_fractional_weight_scales_the_contribution(self):
        POWER_TRACE.leakage_weights["cache_refill"] = 0.25
        POWER_TRACE.capture = True

        POWER_TRACE.append(8.0, source="cache_refill")

        self.assertEqual(POWER_TRACE.sample, [2.0])

    def test_each_source_is_weighted_independently(self):
        POWER_TRACE.leakage_weights["cache_refill"] = 0.0
        POWER_TRACE.capture = True

        POWER_TRACE.append(2.0)                          # default source
        POWER_TRACE.append(3.0, source="memory_store")
        POWER_TRACE.append(4.0, source="register_load")
        POWER_TRACE.append(7.0, source="cache_refill")

        self.assertEqual(POWER_TRACE.sample, [2.0, 3.0, 4.0])

    def test_unknown_source_leaks_at_full_weight(self):
        # A new or untagged emulator site must not crash a simulation, so
        # append() is lenient. Config typos are caught in set_config instead.
        POWER_TRACE.capture = True

        POWER_TRACE.append(5.0, source="something_new")

        self.assertEqual(POWER_TRACE.sample, [5.0])

    def test_nothing_is_recorded_while_not_capturing(self):
        POWER_TRACE.capture = False

        POWER_TRACE.append(2.0)
        POWER_TRACE.append(7.0, source="cache_refill")

        self.assertEqual(POWER_TRACE.sample, [])

    def test_cycle_still_yields_a_sample_when_a_source_is_zeroed(self):
        # Trace length must not depend on the weights: a cycle whose only
        # activity was a zero-weighted source still produces one 0.0 sample.
        POWER_TRACE.leakage_weights["cache_refill"] = 0.0
        POWER_TRACE.capture = True

        POWER_TRACE.append(7.0, source="cache_refill")
        POWER_TRACE.flush_sample()

        self.assertEqual(POWER_TRACE.trace, [0.0])

    def test_set_config_reads_the_weights(self):
        conf = bd.from_yaml("config.yml")
        conf["PowerTraces.weights.cache_refill"] = 0.25

        set_config(conf)

        self.assertEqual(POWER_TRACE.leakage_weights["cache_refill"], 0.25)
        self.assertEqual(POWER_TRACE.leakage_weights["memory_store"], 1.0)

    def test_set_config_restores_defaults_when_weights_are_absent(self):
        # The singleton retains whatever the previous run left behind.
        POWER_TRACE.leakage_weights["cache_refill"] = 0.0
        conf = bd.from_yaml("config.yml")
        conf["PowerTraces"].pop("weights", None)

        set_config(conf)

        self.assertEqual(POWER_TRACE.leakage_weights, DEFAULT_LEAKAGE_WEIGHTS)


class NoiseAndSeedTest(_PowerTraceStateMixin, unittest.TestCase):
    """Additive Gaussian noise with a configurable sigma and a reproducible seed.

    sigma is what makes SNR a course knob: for a Hamming-weight leak the
    correlation falls as rho_max / sqrt(1 + 1/SNR) and the number of traces
    needed grows as 1/rho^2, so a lab sheet varies sigma and counts traces.
    """

    def test_zero_sigma_leaves_the_samples_exact(self):
        POWER_TRACE.noise_sigma = 0.0
        samples = np.arange(10, dtype=float)

        np.testing.assert_array_equal(POWER_TRACE._apply_noise(samples), samples)

    def test_sigma_sets_the_noise_standard_deviation(self):
        POWER_TRACE.noise_sigma = 2.0
        POWER_TRACE.set_seed(7)
        samples = np.zeros(20000)

        noisy = POWER_TRACE._apply_noise(samples)

        self.assertAlmostEqual(float(np.std(noisy)), 2.0, delta=0.1)

    def test_same_seed_reproduces_the_same_noise(self):
        POWER_TRACE.noise_sigma = 1.0
        samples = np.zeros(64)

        POWER_TRACE.set_seed(1234)
        first = POWER_TRACE._apply_noise(samples)
        POWER_TRACE.set_seed(1234)
        second = POWER_TRACE._apply_noise(samples)

        np.testing.assert_array_equal(first, second)

    def test_different_seed_gives_different_noise(self):
        POWER_TRACE.noise_sigma = 1.0
        samples = np.zeros(64)

        POWER_TRACE.set_seed(1234)
        first = POWER_TRACE._apply_noise(samples)
        POWER_TRACE.set_seed(5678)
        second = POWER_TRACE._apply_noise(samples)

        self.assertFalse(np.array_equal(first, second))

    def test_consecutive_captures_get_different_noise(self):
        # The AES demo calls stop_capture 255 times in one run. Reseeding per
        # capture would give every trace an identical noise vector, i.e. a
        # constant per-sample offset rather than noise.
        POWER_TRACE.noise_sigma = 1.0
        POWER_TRACE.set_seed(99)
        samples = np.zeros(64)

        first = POWER_TRACE._apply_noise(samples)
        second = POWER_TRACE._apply_noise(samples)

        self.assertFalse(np.array_equal(first, second))

    def test_delay_stream_is_independent_of_the_noise_stream(self):
        # Two substreams from one seed: enabling the delay countermeasure must
        # not shift the noise draws, so runs that differ only in the
        # countermeasure stay otherwise comparable.
        POWER_TRACE.noise_sigma = 1.0
        samples = np.zeros(64)

        POWER_TRACE.set_seed(2024)
        undisturbed = POWER_TRACE._apply_noise(samples)
        POWER_TRACE.set_seed(2024)
        POWER_TRACE.delay_random.random(17)          # as sys_trace_delay would
        disturbed = POWER_TRACE._apply_noise(samples)

        np.testing.assert_array_equal(undisturbed, disturbed)

    def test_noise_reaches_the_exported_trace_file(self):
        POWER_TRACE.noise_sigma = 1.0
        POWER_TRACE.set_seed(3)
        POWER_TRACE.capture = True
        POWER_TRACE.trace = [0.0] * 32
        POWER_TRACE.name = "noise-probe"

        cwd = os.getcwd()
        with tempfile.TemporaryDirectory() as tmp:
            os.chdir(tmp)
            try:
                POWER_TRACE.stop_capture()
                written = json.loads(
                    Path(tmp, "traces", "noise-probe.json").read_text())["trace"]
            finally:
                os.chdir(cwd)

        self.assertEqual(len(written), 32)
        self.assertNotEqual(written, [0.0] * 32)

    def test_set_config_reads_sigma_and_seed(self):
        conf = bd.from_yaml("config.yml")
        conf["PowerTraces.noise.sigma"] = 2.5
        conf["PowerTraces.seed"] = 42

        set_config(conf)

        self.assertEqual(POWER_TRACE.noise_sigma, 2.5)
        self.assertEqual(POWER_TRACE.seed, 42)

    def test_set_config_restores_the_noise_defaults_when_absent(self):
        POWER_TRACE.noise_sigma = 3.0
        conf = bd.from_yaml("config.yml")
        conf["PowerTraces"].pop("noise", None)
        conf["PowerTraces"].pop("seed", None)

        set_config(conf)

        self.assertEqual(POWER_TRACE.noise_sigma, 0.0)
        self.assertIsNone(POWER_TRACE.seed)


class _StubDelaySyscall:
    """Stands in for SystemCall: sys_trace_delay reads get_arg(0) and set_return."""

    def __init__(self, max_cycles=0):
        self._max_cycles = Word(max_cycles)
        self.returned = None

    def get_arg(self, index):
        assert index == 0
        return self._max_cycles

    def set_return(self, value):
        self.returned = value


def _splice_delay(seed, max_cycles=0):
    """Run sys_trace_delay on a fresh trace and return the spliced samples."""
    from src.syscalls import sys_trace_delay

    POWER_TRACE.set_seed(seed)
    POWER_TRACE.capture = True
    POWER_TRACE.trace = []
    sys_trace_delay(_StubDelaySyscall(max_cycles))
    return list(POWER_TRACE.trace)


class TraceDelaySeedTest(_PowerTraceStateMixin, unittest.TestCase):
    """The random-delay countermeasure draws from the seeded generator.

    It used to use the module-level `random`, which made lab results
    irreproducible between students even when the noise was seeded.
    """

    def test_same_seed_splices_the_same_delay(self):
        self.assertEqual(_splice_delay(11), _splice_delay(11))

    def test_different_seeds_splice_different_delays(self):
        lengths = {len(_splice_delay(seed)) for seed in range(20)}

        self.assertGreater(len(lengths), 1)


class TraceDelayPowerTest(_PowerTraceStateMixin, unittest.TestCase):
    """A delay cycle draws the power of a nop, not a random amplitude.

    It used to splice U(-30, +30) per delay cycle, i.e. amplitude noise four
    times the size of the whole signal range -- and negative power at that --
    so a broken attack could not be attributed to the misalignment the
    countermeasure is supposed to teach.
    """

    def test_every_delay_sample_is_the_nop_power(self):
        seen = 0
        for seed in range(40):
            spliced = _splice_delay(seed)
            seen += len(spliced)
            for value in spliced:
                self.assertEqual(value, POWER_VALUES["nop"])

        self.assertGreater(seen, 0)

    def test_instruction_weight_scales_the_delay_samples(self):
        POWER_TRACE.leakage_weights["instruction"] = 0.5

        for value in _splice_delay(7, max_cycles=20):
            self.assertEqual(value, 0.5 * POWER_VALUES["nop"])

    def test_zero_weight_keeps_the_delay_but_drops_its_power(self):
        # A weight of 0.0 suppresses a source's amplitude, never the timing:
        # the delay is a misalignment countermeasure, so its samples have to
        # stay in the trace even when they carry nothing.
        full = _splice_delay(7, max_cycles=20)
        POWER_TRACE.leakage_weights["instruction"] = 0.0

        suppressed = _splice_delay(7, max_cycles=20)

        self.assertEqual(len(suppressed), len(full))
        self.assertEqual(set(suppressed) or {0.0}, {0.0})


class TraceDelayMaxCyclesTest(_PowerTraceStateMixin, unittest.TestCase):
    """a0 bounds the delay; it is optional and defaults to 20 cycles."""

    @staticmethod
    def _lengths(max_cycles, seeds=200):
        return [len(_splice_delay(seed, max_cycles)) for seed in range(seeds)]

    def test_argument_bounds_the_number_of_delay_cycles(self):
        lengths = self._lengths(5)

        self.assertLessEqual(max(lengths), 5)
        self.assertEqual(max(lengths), 5)       # the whole range is reachable
        self.assertEqual(min(lengths), 0)

    def test_zero_argument_falls_back_to_the_default(self):
        lengths = self._lengths(0)

        self.assertEqual(max(lengths), DEFAULT_DELAY_MAX_CYCLES)
        self.assertEqual(DEFAULT_DELAY_MAX_CYCLES, 20)

    def test_negative_argument_falls_back_to_the_default(self):
        self.assertEqual(_splice_delay(3, -1), _splice_delay(3, 0))

    def test_oversized_argument_is_clamped(self):
        # A caller that leaves garbage in a0 -- hand-written asm predating the
        # argument -- must not splice a million samples into the trace.
        self.assertLessEqual(len(_splice_delay(3, 10 ** 6)), DELAY_CYCLE_LIMIT)
        self.assertLessEqual(len(_splice_delay(3, 0xFFFFFFF0)), DELAY_CYCLE_LIMIT)

    def test_effective_maximum_is_returned(self):
        from src.syscalls import sys_trace_delay

        POWER_TRACE.capture = True
        for requested, effective in ((5, 5), (0, DEFAULT_DELAY_MAX_CYCLES),
                                     (-1, DEFAULT_DELAY_MAX_CYCLES),
                                     (10 ** 6, DELAY_CYCLE_LIMIT)):
            call = _StubDelaySyscall(requested)
            sys_trace_delay(call)

            self.assertEqual(call.returned, Word(effective))


class PowerConfigValidationTest(_PowerTraceStateMixin, unittest.TestCase):
    """A misconfigured power model fails loudly.

    Weights and sigma are quieter to get wrong than the booleans they replace:
    a typo in a source name would otherwise silently leave that source at full
    weight, and a stale config would silently lose its setting.
    """

    def test_unknown_section_key_is_rejected(self):
        conf = bd.from_yaml("config.yml")
        conf["PowerTraces.wieghts"] = {}

        with self.assertRaisesRegex(ValueError, "unknown PowerTraces key: wieghts"):
            set_config(conf)

    def test_removed_random_noise_names_its_replacement(self):
        conf = bd.from_yaml("config.yml")
        conf["PowerTraces.random_noise"] = True

        with self.assertRaisesRegex(ValueError, "random_noise was removed.*noise.sigma"):
            set_config(conf)

    def test_removed_cache_refill_leakage_names_its_replacement(self):
        conf = bd.from_yaml("config.yml")
        conf["PowerTraces.cache_refill_leakage"] = False

        with self.assertRaisesRegex(ValueError,
                                    "cache_refill_leakage was removed.*weights.cache_refill"):
            set_config(conf)

    def test_unknown_leakage_source_is_rejected(self):
        conf = bd.from_yaml("config.yml")
        conf["PowerTraces.weights.cache_refil"] = 0.0

        with self.assertRaisesRegex(ValueError, "unknown leakage source.*cache_refil"):
            set_config(conf)

    def test_unknown_noise_key_is_rejected(self):
        conf = bd.from_yaml("config.yml")
        conf["PowerTraces.noise.stddev"] = 1.0

        with self.assertRaisesRegex(ValueError, "unknown PowerTraces.noise key: stddev"):
            set_config(conf)

    def test_negative_weight_is_rejected(self):
        conf = bd.from_yaml("config.yml")
        conf["PowerTraces.weights.cache_refill"] = -1.0

        with self.assertRaisesRegex(
                ValueError, r"weights\.cache_refill must not be negative: -1\.0"):
            set_config(conf)

    def test_negative_sigma_is_rejected(self):
        conf = bd.from_yaml("config.yml")
        conf["PowerTraces.noise.sigma"] = -0.5

        with self.assertRaisesRegex(
                ValueError, r"noise\.sigma must not be negative: -0\.5"):
            set_config(conf)

    def test_negative_stall_power_is_rejected(self):
        conf = bd.from_yaml("config.yml")
        conf["PowerTraces"]["stall_power"] = -5.0

        with self.assertRaisesRegex(
                ValueError, r"stall_power must not be negative: -5\.0"):
            set_config(conf)

    def test_falsy_non_mapping_weights_is_rejected(self):
        # weights: 0.0 used to be silently accepted, leaving every weight at
        # its default of 1.0 instead of raising -- exactly the "silence all
        # leakage" mistake this validation exists to catch.
        conf = bd.from_yaml("config.yml")
        conf["PowerTraces"]["weights"] = 0.0

        with self.assertRaisesRegex(
                ValueError, r"PowerTraces\.weights must be a mapping.*0\.0"):
            set_config(conf)

    def test_truthy_non_mapping_noise_is_rejected(self):
        # noise: 0.5 used to raise a TypeError from deep inside dict iteration
        # that named neither PowerTraces nor noise.
        conf = bd.from_yaml("config.yml")
        conf["PowerTraces"]["noise"] = 0.5

        with self.assertRaisesRegex(
                ValueError, r"PowerTraces\.noise must be a mapping.*0\.5"):
            set_config(conf)

    def test_non_integer_seed_is_rejected(self):
        conf = bd.from_yaml("config.yml")
        conf["PowerTraces"]["seed"] = "abc"

        with self.assertRaisesRegex(ValueError, r"PowerTraces\.seed.*abc"):
            set_config(conf)

    def test_the_shipped_config_is_accepted(self):
        # Guards against config.yml and the validator drifting apart.
        set_config(bd.from_yaml("config.yml"))

        self.assertEqual(POWER_TRACE.leakage_weights, DEFAULT_LEAKAGE_WEIGHTS)
        self.assertEqual(POWER_TRACE.noise_sigma, 0.0)
        self.assertIsNone(POWER_TRACE.seed)


class StallPowerConfigTest(_PowerTraceStateMixin, unittest.TestCase):

    def test_set_config_reads_stall_power(self):
        conf = bd.from_yaml("config.yml")
        conf["PowerTraces"]["stall_power"] = 0.5

        set_config(conf)

        self.assertEqual(POWER_TRACE.stall_power, 0.5)

    def test_set_config_defaults_to_zero_when_key_absent(self):
        # The singleton retains whatever the previous run left behind, so
        # set_config must actively restore the default rather than skip the key.
        POWER_TRACE.stall_power = 0.5
        conf = bd.from_yaml("config.yml")
        conf["PowerTraces"].pop("stall_power", None)

        set_config(conf)

        self.assertEqual(POWER_TRACE.stall_power, 0.0)


class InstructionPowerTimingTest(_PowerTraceStateMixin, unittest.TestCase):
    """End to end: opcode power lands on the cycles an instruction is busy.

    The probe leaves every kind of blocking in the trace: `xor`, `mul` and `sw`
    wait on operands, and `lw` waits on a store->load hazard.
    """

    PROBE = """
        addi a0, zero, 5
        addi a1, zero, 3
        xor  a2, a0, a1
        mul  a3, a0, a1
        sw   a3, zero, 0
        lw   a4, zero, 0
    """

    def _run(self, stall_power):
        conf = bd.from_yaml("config.yml")
        conf["PowerTraces"]["weights"]["cache_refill"] = 0.0
        conf["PowerTraces"]["stall_power"] = stall_power

        cpu = CPU(conf)
        cpu.load_program(self.PROBE)

        POWER_TRACE.capture = True
        for _ in range(30):
            if not cpu.tick().executing_program:
                break

        return POWER_TRACE.trace

    def test_opcode_power_lands_on_the_active_cycles(self):
        trace = self._run(stall_power=0.0)

        np.testing.assert_allclose(trace, [
            0.0,   # nothing has been issued yet
            4.0,   # both addi complete; xor/mul/sw blocked on operands
            5.3,   # xor 0.8 completes + mul 4.5 counting down
            4.5,   # mul busy
            4.5,   # mul busy
            10.5,  # mul 4.5 completes + store HD 4.0 + sw 2.0 (memory busy)
            2.0, 2.0, 2.0, 2.0,          # sw memory write cycles
            0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,   # lw blocked on the hazard
            6.0,   # load HD 4.0 + lw 2.0 (memory read)
            2.0,   # lw completes
        ] + [0.0] * 8)

    def test_stall_power_only_shifts_the_blocked_cycles(self):
        idle = self._run(stall_power=0.0)
        self._reset()
        stalled = self._run(stall_power=0.25)

        # Every difference is a multiple of the stall constant, and the cycles
        # where lw waits on the hazard pick up exactly one blocked slot.
        difference = np.asarray(stalled) - np.asarray(idle)
        np.testing.assert_allclose(difference % 0.25, 0.0, atol=1e-9)
        np.testing.assert_allclose(difference[10:17], 0.25)

    def test_trace_length_is_independent_of_stall_power(self):
        idle = len(self._run(stall_power=0.0))
        self._reset()
        stalled = len(self._run(stall_power=0.25))

        self.assertEqual(idle, stalled)


class TraceLengthMatchesCycleCountTest(_PowerTraceStateMixin, unittest.TestCase):
    """End to end: len(trace) == number of ticks, on programs that do fault.

    Capture is driven from the test rather than by the trace syscalls so that
    the whole run is recorded and no stop_capture() truncates the trace.
    """

    def _run(self, program):
        POWER_TRACE.capture = True

        cpu = CPU(bd.from_yaml("config.yml"))
        cpu.load_program_from_file(program)

        ticks = 0
        faults = 0
        while True:
            status = cpu.tick()
            ticks += 1
            if status.fault_info is not None:
                faults += 1
            if not status.executing_program:
                break

        return ticks, faults, len(POWER_TRACE.trace)

    def test_mispredicted_branches_do_not_shorten_the_trace(self):
        ticks, faults, samples = self._run("demo/spectre.tea")

        self.assertGreater(faults, 0, "program faults nothing; test proves nothing")
        self.assertEqual(samples, ticks)

    def test_faulting_memory_accesses_do_not_shorten_the_trace(self):
        ticks, faults, samples = self._run("demo/meltdown.tea")

        self.assertGreater(faults, 0, "program faults nothing; test proves nothing")
        self.assertEqual(samples, ticks)


if __name__ == "__main__":
    unittest.main()
