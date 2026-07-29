import unittest
import warnings
from types import SimpleNamespace

import numpy as np
from benedict import benedict as bd

from src import cache
from src.cpu import CPU
from src.power import (CPAAttack, HW, SBOX, aes_internal, cycle_power,
                       power_draw, POWER_TRACE, POWER_VALUES, set_config)


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


class PowerTraceSourceGateTest(unittest.TestCase):
    """The cache_refill_leakage switch gates only the cache-refill power source."""

    def setUp(self):
        self._reset()

    def tearDown(self):
        self._reset()

    @staticmethod
    def _reset():
        # PowerTrace is a singleton; constructing it again does not reset state.
        POWER_TRACE.capture = False
        POWER_TRACE.sample = []
        POWER_TRACE.trace = []
        POWER_TRACE.cache_refill_leakage = True
        POWER_TRACE.stall_power = 0.0

    def test_cache_refill_power_recorded_when_enabled(self):
        POWER_TRACE.cache_refill_leakage = True
        POWER_TRACE.capture = True

        POWER_TRACE.append(7.0, source="cache_refill")

        self.assertEqual(POWER_TRACE.sample, [7.0])

    def test_cache_refill_power_dropped_when_disabled(self):
        POWER_TRACE.cache_refill_leakage = False
        POWER_TRACE.capture = True

        POWER_TRACE.append(7.0, source="cache_refill")

        self.assertEqual(POWER_TRACE.sample, [])

    def test_other_sources_unaffected_when_disabled(self):
        POWER_TRACE.cache_refill_leakage = False
        POWER_TRACE.capture = True

        POWER_TRACE.append(2.0)                        # default source
        POWER_TRACE.append(3.0, source="memory_store")
        POWER_TRACE.append(4.0, source="register_load")

        self.assertEqual(POWER_TRACE.sample, [2.0, 3.0, 4.0])

    def test_nothing_is_recorded_while_not_capturing(self):
        POWER_TRACE.capture = False

        POWER_TRACE.append(2.0)
        POWER_TRACE.append(7.0, source="cache_refill")

        self.assertEqual(POWER_TRACE.sample, [])

    def test_set_config_reads_the_switch(self):
        conf = bd.from_yaml("config.yml")
        conf["PowerTraces"]["cache_refill_leakage"] = False

        set_config(conf)

        self.assertFalse(POWER_TRACE.cache_refill_leakage)

    def test_set_config_defaults_to_true_when_key_absent(self):
        # The singleton retains whatever the previous run left behind, so
        # set_config must actively restore the default rather than skip the key.
        POWER_TRACE.cache_refill_leakage = False
        conf = bd.from_yaml("config.yml")
        conf["PowerTraces"].pop("cache_refill_leakage", None)

        set_config(conf)

        self.assertTrue(POWER_TRACE.cache_refill_leakage)


class CacheRefillPowerTest(unittest.TestCase):
    """CacheLine.write is the cache_refill power source."""

    def setUp(self):
        self._reset()

    def tearDown(self):
        self._reset()

    @staticmethod
    def _reset():
        POWER_TRACE.capture = False
        POWER_TRACE.sample = []
        POWER_TRACE.trace = []
        POWER_TRACE.cache_refill_leakage = True
        POWER_TRACE.stall_power = 0.0

    def test_cache_write_contributes_power_when_enabled(self):
        POWER_TRACE.cache_refill_leakage = True
        POWER_TRACE.capture = True

        cache.CacheLRU(4, 2, 4).write(0, 0b1011)

        self.assertEqual(POWER_TRACE.sample, [3])

    def test_cache_write_contributes_nothing_when_disabled(self):
        POWER_TRACE.cache_refill_leakage = False
        POWER_TRACE.capture = True

        cache.CacheLRU(4, 2, 4).write(0, 0b1011)

        self.assertEqual(POWER_TRACE.sample, [])

    def test_cycle_still_yields_a_sample_when_refill_power_is_dropped(self):
        # Trace length must not depend on the switch: a cycle in which the only
        # activity was a suppressed cache refill still produces one 0.0 sample.
        POWER_TRACE.cache_refill_leakage = False
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
        POWER_TRACE.cache_refill_leakage = True
        POWER_TRACE.stall_power = 0.0


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
        conf["PowerTraces"]["cache_refill_leakage"] = False
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
