"""Power trace capture, and the side-channel analyses that consume the traces."""

from __future__ import annotations

import json
import os
import warnings
from dataclasses import dataclass, asdict
from functools import wraps
from pathlib import Path
from typing import Callable, Iterable, Optional, Sequence, TypeVar, Union

import numpy as np
import numpy.typing as npt

_T = TypeVar("_T")

# Power drawn per cycle by an instruction of the given kind. The scale is arbitrary
# but ordered by the average current an instruction draws on real hardware, so
# instructions that measure alike are valued alike.
POWER_VALUES: dict[str, float] = {
    "add": 2.0,
    "addi": 2.0,
    "sub": 2.0,
    "subi": 2.0,
    "sll": 1.5,
    "slli": 1.5,
    "srl": 1.5,
    "srli": 1.5,
    "sra": 1.5,
    "srai": 1.5,
    "xor": 0.8,
    "xori": 0.8,
    "or": 0.8,
    "ori": 0.8,
    "and": 0.8,
    "andi": 0.8,
    "slt": 1.5,
    "slti": 1.5,
    "sltu": 1.5,
    "sltiu": 1.5,
    "lui": 2.0,
    "auipc": 2.0,
    "mul": 4.5,
    "mulh": 4.5,
    "mulhu": 4.5,
    "mulhsu": 4.5,
    "div": 5.0,
    "divu": 5.0,
    "rem": 4.5,
    "remu": 4.5,
    "lw": 2.0,
    "lh": 2.0,
    "lhu": 2.0,
    "lb": 2.0,
    "lbu": 2.0,
    "sw": 2.0,
    "sh": 2.0,
    "sb": 2.0,
    "cbo.flush": 10.0,
    "x.flushall": 10.0,
    "beq": 3.0,
    "bne": 3.0,
    "blt": 3.0,
    "ble": 3.0,
    "bgt": 3.0,
    "bge": 3.0,
    "bltu": 3.0,
    "bleu": 3.0,
    "bgtu": 3.0,
    "bgeu": 3.0,
    "jal": 3.0,
    "jalr": 3.0,
    "rdcycle": 10.0,
    # Serializing instructions all flush the pipeline, so they cost the same.
    "fence.i": 10.0,
    "ecall": 10.0,
    "ebreak": 10.0,
    "nop": 2.0,
    "li": 2.0,      # addi
    "mv": 2.0,      # addi
    "not": 0.8,     # xori
    "neg": 2.0,     # sub
    "seqz": 1.5,    # sltiu
    "snez": 1.5,    # sltu
    "sltz": 1.5,    # slt
    "sgtz": 1.5,    # slt
    "blts": 3.0,    # blt
    "bles": 3.0,    # ble
    "bgts": 3.0,    # bgt
    "bges": 3.0,    # bge
    "beqz": 3.0,    # beq
    "bnez": 3.0,    # bne
    "bltz": 3.0,    # blt
    "blez": 3.0,    # ble
    "bgtz": 3.0,    # bgt
    "bgez": 3.0,    # bge
    "bltuz": 3.0,   # bltu
    "bleuz": 3.0,   # bleu
    "bgtuz": 3.0,   # bgtu
    "bgeuz": 3.0,   # bgeu
    "j": 3.0,       # jal
    "jr": 3.0,      # jalr
    "ret": 3.0,     # jalr
    "call": 3.0,    # jal
    "tail": 3.0,    # jal
    "flush": 10.0,          # cbo.flush
    "flushall": 10.0,       # x.flushall
    "rdtsc": 10.0,          # rdcycle
    "fence": 10.0,          # fence.i
    "th.dcache.ciall": 10.0,  # x.flushall
}

# Scaling of each leakage term, keyed by the `source` argument of PowerTrace.append.
# The sources are on incommensurable scales -- an opcode constant is 0.8-10.0, a load
# write-back 0-32, a byte store 0-8, and a cache-line refill contributes 0-8 once per
# byte of the line -- so the mix, and with it the SNR, has to be configurable. A weight
# of 0.0 disables a source entirely.
DEFAULT_LEAKAGE_WEIGHTS: dict[str, float] = {
    "instruction": 1.0,
    "stall": 1.0,
    "register_load": 1.0,
    "memory_store": 1.0,
    "cache_refill": 1.0,
}

_POWER_CONFIG_KEYS = frozenset({"stall_power", "weights", "noise", "seed"})
_NOISE_CONFIG_KEYS = frozenset({"sigma"})


def power_draw(func: Callable[..., _T]) -> Callable[..., _T]:
    """Record the power a slot draws in the cycle the wrapped method executes."""
    @wraps(func)
    def wrapper(self, *args, **kwargs) -> _T:
        result = func(self, *args, **kwargs)
        if self.active:
            POWER_TRACE.append(POWER_VALUES[self.instr_ty.name], source="instruction")
        else:
            POWER_TRACE.append(POWER_TRACE.stall_power, source="stall")
        return result

    return wrapper


def cycle_power(func: Callable[..., _T]) -> Callable[..., _T]:
    """Commit the accumulated contributions of the wrapped cycle as one sample."""
    @wraps(func)
    def wrapper(self, *args, **kwargs) -> _T:
        result = func(self, *args, **kwargs)
        POWER_TRACE.flush_sample()
        return result

    return wrapper


@dataclass
class TraceData:
    """
    A power trace captured by this emulator.

    name     -- Name of the power trace as set by the trace_set_name syscall
    trace    -- The power measured per single cycle of the CPU
    metadata -- String keys and values set by the trace_set_metadata syscall. Can be
                used to record the input values of an algorithm or other metadata
                relevant to the postprocessing of the power traces.
    """

    name: str
    trace: list[float]
    metadata: dict[str, str]


def _trace_to_json(data: TraceData, path: os.PathLike) -> None:
    """Serialize a TraceData object to a JSON file."""
    with open(path, "w") as f:
        json.dump(asdict(data), f)


def _trace_from_json(path: os.PathLike) -> TraceData:
    """Deserialize a TraceData object from a JSON file."""
    with open(path) as f:
        return TraceData(**json.load(f))


class PowerTrace:
    """
    Represents a power trace of the cpu. This is an append only data structure.
    Should be considered as an internal API for the emulator and is not intended
    for actual use
    """

    _instance: Optional["PowerTrace"] = None

    trace: list[float]
    sample: list[float]
    capture: bool
    name: str
    metadata: dict[str, str]
    noise_sigma: float
    stall_power: float
    leakage_weights: dict[str, float]
    seed: Optional[int]
    random: np.random.Generator
    delay_random: np.random.Generator

    def __new__(cls) -> "PowerTrace":
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls.trace = []
            cls.sample = []
            cls.capture = False
            cls.name = "power-trace"
            cls.metadata = {}
            cls.noise_sigma = 0.0
            cls._instance.set_seed(None)
            cls.stall_power = 0.0
            cls.leakage_weights = dict(DEFAULT_LEAKAGE_WEIGHTS)
        return cls._instance

    def set_seed(self, seed: Optional[int]) -> None:
        """
        Seed the measurement noise and the random-delay countermeasure.

        The two substreams are independent, so enabling the delay countermeasure does
        not shift the noise draws. A seed of None draws from OS entropy, which makes
        the run irreproducible.

        Called once per set_config rather than once per capture, so that a program
        capturing many traces gets fresh noise for each of them.
        """
        self.seed = seed
        noise_seq, delay_seq = np.random.SeedSequence(seed).spawn(2)
        self.random = np.random.default_rng(noise_seq)
        self.delay_random = np.random.default_rng(delay_seq)

    def _apply_noise(self, samples: npt.NDArray) -> npt.NDArray:
        """
        Add Gaussian measurement noise of the configured sigma.

        sigma is in the same (arbitrary) units as the trace itself, so it is read
        against the amplitude of the leakage terms: the algorithmic leak of the AES
        demo has a standard deviation of about 1.4.
        """
        if self.noise_sigma <= 0.0:
            return samples
        return samples + self.random.normal(0.0, self.noise_sigma, len(samples))

    def append(self, trace_value: float, source: str = "instruction") -> None:
        """
        Record one power contribution for the current cycle.

        """
        if not self.capture:
            return
        weight = self.leakage_weights.get(source, 1.0)
        if weight == 0.0:
            return
        self.sample.append(trace_value * weight)

    def insert_sample(self, trace_value: float, source: str = "instruction") -> None:
        """
        Append a finished sample that does not correspond to a CPU cycle.

        For countermeasures that splice extra samples into the trace while a cycle is
        still in flight: system calls run inside CPU.tick(), so append() followed by
        flush_sample() would commit the activity of the cycle carrying the ecall as
        part of the spliced sample. See sys_trace_delay.

        source scales the value as it does in append(), but a weight of 0.0 still
        appends the now zero sample, because a spliced sample is a position in the
        trace and dropping it would turn an amplitude knob into a timing one.
        """
        if not self.capture:
            return
        self.trace.append(trace_value * self.leakage_weights.get(source, 1.0))

    def flush_sample(self) -> None:
        """Commit the contributions of the current cycle as a single sample."""
        if not self.capture:
            return

        self.trace.append(float(sum(self.sample)))
        self.sample = []

    def set_trace_name(self, name: str) -> None:
        self.name = name

    def set_metadata(self, key: str, value: str) -> None:
        """
        Add or overwrite a key/value pair in the metadata that will be attached to the
        TraceData written by the next stop_capture() call.
        """
        self.metadata[key] = value

    def start_capture(self) -> int:
        if not self.capture:
            self.capture = True
            self.sample = []
            return 1
        return 0

    def stop_capture(self) -> int:
        """
        Stops the capture of a power trace. It will write the resulting trace into
        a ./traces directory as a JSON-serialized TraceData object.
        If the set trace name already exists we will extend the power trace already
        contained in that file.
        return: 0 if no capture was running 1 if capture was stopped successfully
        """
        if not self.capture:
            return 0

        export = self._apply_noise(np.asarray(self.trace, dtype=float))

        if not os.path.exists("traces/"):
            os.mkdir("./traces")

        trace_path = f"./traces/{self.name}.json"
        samples = export.tolist()

        if os.path.exists(trace_path):
            trace_data = _trace_from_json(trace_path)
            trace_data.trace.extend(samples)
            trace_data.metadata.update(self.metadata)
        else:
            trace_data = TraceData(
                name=self.name, trace=samples, metadata=dict(self.metadata)
            )

        _trace_to_json(trace_data, trace_path)

        self.trace = []
        self.metadata = {}
        self.capture = False
        return 1


def set_config(conf: dict) -> None:
    """
    Apply the PowerTraces section of the config to the PowerTrace singleton.

    Every field is reset, including the ones falling back to a default: the singleton
    survives CPU construction, so skipping an absent key would leave the previous
    run's value in place.
    """
    pt = PowerTrace()
    section = conf["PowerTraces"]

    for key in section:
        if key not in _POWER_CONFIG_KEYS:
            raise ValueError(f"unknown PowerTraces key: {key} "
                             f"(known keys are {sorted(_POWER_CONFIG_KEYS)})")

    weights_section = section.get("weights")
    if weights_section is None:
        weights_section = {}
    elif not isinstance(weights_section, dict):
        raise ValueError(
            f"PowerTraces.weights must be a mapping of source -> weight, "
            f"got {weights_section!r}")

    weights = dict(DEFAULT_LEAKAGE_WEIGHTS)
    for source, value in weights_section.items():
        if source not in DEFAULT_LEAKAGE_WEIGHTS:
            raise ValueError(f"unknown leakage source in PowerTraces.weights: "
                             f"{source} (known sources are "
                             f"{sorted(DEFAULT_LEAKAGE_WEIGHTS)})")
        weight = float(value)
        if weight < 0.0:
            raise ValueError(f"PowerTraces.weights.{source} must not be "
                             f"negative: {weight}")
        weights[source] = weight

    noise_section = section.get("noise")
    if noise_section is None:
        noise_section = {}
    elif not isinstance(noise_section, dict):
        raise ValueError(
            f"PowerTraces.noise must be a mapping, got {noise_section!r}")

    for key in noise_section:
        if key not in _NOISE_CONFIG_KEYS:
            raise ValueError(f"unknown PowerTraces.noise key: {key} "
                             f"(known keys are {sorted(_NOISE_CONFIG_KEYS)})")
    sigma = float(noise_section.get("sigma", 0.0))
    if sigma < 0.0:
        raise ValueError(f"PowerTraces.noise.sigma must not be negative: {sigma}")

    stall_power = float(section.get("stall_power", 0.0))
    if stall_power < 0.0:
        raise ValueError(
            f"PowerTraces.stall_power must not be negative: {stall_power}")

    seed = section.get("seed", None)
    if seed is not None and (isinstance(seed, bool) or not isinstance(seed, int)):
        raise ValueError(
            f"PowerTraces.seed must be an int or null, got {seed!r}")

    pt.leakage_weights = weights
    pt.noise_sigma = sigma
    pt.stall_power = stall_power
    pt.set_seed(seed)


POWER_TRACE = PowerTrace()

SBOX: list[int] = [
    0x63,0x7c,0x77,0x7b,0xf2,0x6b,0x6f,0xc5,0x30,0x01,0x67,0x2b,0xfe,0xd7,0xab,0x76,
    0xca,0x82,0xc9,0x7d,0xfa,0x59,0x47,0xf0,0xad,0xd4,0xa2,0xaf,0x9c,0xa4,0x72,0xc0,
    0xb7,0xfd,0x93,0x26,0x36,0x3f,0xf7,0xcc,0x34,0xa5,0xe5,0xf1,0x71,0xd8,0x31,0x15,
    0x04,0xc7,0x23,0xc3,0x18,0x96,0x05,0x9a,0x07,0x12,0x80,0xe2,0xeb,0x27,0xb2,0x75,
    0x09,0x83,0x2c,0x1a,0x1b,0x6e,0x5a,0xa0,0x52,0x3b,0xd6,0xb3,0x29,0xe3,0x2f,0x84,
    0x53,0xd1,0x00,0xed,0x20,0xfc,0xb1,0x5b,0x6a,0xcb,0xbe,0x39,0x4a,0x4c,0x58,0xcf,
    0xd0,0xef,0xaa,0xfb,0x43,0x4d,0x33,0x85,0x45,0xf9,0x02,0x7f,0x50,0x3c,0x9f,0xa8,
    0x51,0xa3,0x40,0x8f,0x92,0x9d,0x38,0xf5,0xbc,0xb6,0xda,0x21,0x10,0xff,0xf3,0xd2,
    0xcd,0x0c,0x13,0xec,0x5f,0x97,0x44,0x17,0xc4,0xa7,0x7e,0x3d,0x64,0x5d,0x19,0x73,
    0x60,0x81,0x4f,0xdc,0x22,0x2a,0x90,0x88,0x46,0xee,0xb8,0x14,0xde,0x5e,0x0b,0xdb,
    0xe0,0x32,0x3a,0x0a,0x49,0x06,0x24,0x5c,0xc2,0xd3,0xac,0x62,0x91,0x95,0xe4,0x79,
    0xe7,0xc8,0x37,0x6d,0x8d,0xd5,0x4e,0xa9,0x6c,0x56,0xf4,0xea,0x65,0x7a,0xae,0x08,
    0xba,0x78,0x25,0x2e,0x1c,0xa6,0xb4,0xc6,0xe8,0xdd,0x74,0x1f,0x4b,0xbd,0x8b,0x8a,
    0x70,0x3e,0xb5,0x66,0x48,0x03,0xf6,0x0e,0x61,0x35,0x57,0xb9,0x86,0xc1,0x1d,0x9e,
    0xe1,0xf8,0x98,0x11,0x69,0xd9,0x8e,0x94,0x9b,0x1e,0x87,0xe9,0xce,0x55,0x28,0xdf,
    0x8c,0xa1,0x89,0x0d,0xbf,0xe6,0x42,0x68,0x41,0x99,0x2d,0x0f,0xb0,0x54,0xbb,0x16
]

HW: list[int] = [bin(n).count("1") for n in range(0, 256)]

def mean(X: npt.ArrayLike) -> npt.NDArray:
    return np.sum(X, axis=0)/len(X)


def std_dev(X: npt.ArrayLike, X_bar: npt.ArrayLike) -> npt.NDArray:
    return np.sqrt(np.sum((X-X_bar)**2, axis=0))


def cov(X: npt.ArrayLike, X_bar: npt.ArrayLike,
        Y: npt.ArrayLike, Y_bar: npt.ArrayLike) -> npt.NDArray:
    return np.sum((X-X_bar)*(Y-Y_bar), axis=0)


def aes_internal(input_byte: int, key_byte: int) -> int:
    """
    Helper function for AES leakage model.
    Represents the internal state leakage based on S-box output.
    """
    return input_byte ^ key_byte ^ SBOX[input_byte ^ key_byte]


class CPAAttack:

    def __init__(self, trace_data: Sequence[tuple[int, npt.ArrayLike]],
                 leakage_model: Optional[Callable[[int, int], int]] = None):
        """
        Constructs a CPAAttack instance.
        trace_data: A sequence which per trace contains a tuple with (input byte, trace)
        leakage_model: A callable that takes (input_byte, key_guess) and returns an
                       intermediate value in the range 0-255. Its Hamming weight is
                       correlated against the power traces. Defaults to aes_internal.
        """
        self.trace_data = trace_data
        self.leakage_model = leakage_model if leakage_model is not None else aes_internal

    def attack(self) -> list[float]:
        """
        Calculates the correlation for each keyguess for the first keybyte.

        A sample point that is constant across all traces has a zero standard deviation
        and no correlation coefficient. It carries no information about the key, so it
        is scored 0 rather than divided into a NaN, which would lose every comparison
        and thereby become the reported score of every key guess.
        return: A list where the index is the guess for the keybyte and the value at
                index i is the correlation this keyguess has. Higher values are better.
        """
        textin_array = []
        trace_array = []
        for t in range(len(self.trace_data)):
            textin_array.append(self.trace_data[t][0])
            trace_array.append(np.array(self.trace_data[t][1]))

        maxcpa: list[float] = [0] * 256
        t_bar = mean(trace_array)
        o_t = std_dev(trace_array, t_bar)

        usable = o_t > 0
        if not usable.all():
            warnings.warn(
                f"{int((~usable).sum())} of {usable.size} sample points are "
                "constant across all traces and cannot be correlated; "
                "they are scored 0.",
                RuntimeWarning,
                stacklevel=2,
            )

        for kguess in range(0, 256):
            hws = np.array([[HW[self.leakage_model(textin, kguess)]
                             for textin in textin_array]]).transpose()
            hws_bar = mean(hws)
            o_hws = std_dev(hws, hws_bar)
            if np.all(o_hws == 0):
                # The leakage model maps every plaintext to the same Hamming weight
                # under this guess, so there is no hypothesis to correlate.
                maxcpa[kguess] = 0.0
                continue
            correlation = cov(trace_array, t_bar, hws, hws_bar)
            cpaoutput = np.zeros_like(correlation, dtype=float)
            np.divide(correlation, o_t * o_hws, out=cpaoutput, where=usable)
            maxcpa[kguess] = np.max(np.abs(cpaoutput))
            print(f"{kguess:02x} keyguess", np.max(np.abs(cpaoutput)))

        return maxcpa


class DPAAttack:

    def __init__(self, trace_data: Sequence[tuple[int, npt.ArrayLike]],
                 leakage_model: Callable[[int, int], int]):
        """
        Construct a DPAAttack instance.
        trace_data: A sequence which per trace contains a tuple with (input byte, trace)
        leakage_model: A callable that takes (input_byte, key_guess) and returns a
                       leakage value
        """
        self.trace_data = trace_data
        self.leakage_model = leakage_model

    def attack(self) -> list[float]:
        """
        Calculate the most likely keyguess based on the provided leakage model by
        building a one and zero list with the leakage model.
        For now, only attacks the first byte of the key.
        return: A list where the index is the guess for the keybyte and the value at
                index i is the DPA score for that keyguess. Higher values are better.
        """
        textin_array = []
        trace_array = []
        for t in self.trace_data:
            textin_array.append(t[0])
            trace_array.append(t[1])
        textin_array = np.array(textin_array)
        trace_array = np.array(trace_array)
        dpa_scores: list[float] = [0] * 256
        for key_guess in range(256):
            zero_list = []
            one_list = []
            for i in range(len(textin_array)):
                input_byte = textin_array[i]
                leakage_value = self.leakage_model(input_byte, key_guess)
                if leakage_value & 0x1 == 1:
                    one_list.append(trace_array[i])
                else:
                    zero_list.append(trace_array[i])
            if len(zero_list) > 0 and len(one_list) > 0:
                one_avg = np.asarray(one_list).mean(axis=0)
                zero_avg = np.asarray(zero_list).mean(axis=0)
                dpa_scores[key_guess] = np.max(np.abs(one_avg - zero_avg))
            else:
                dpa_scores[key_guess] = 0
        return dpa_scores


class TraceLoader:

    def __init__(self, path: Union[str, os.PathLike]):
        self.path = Path(path)

    def load_traces(self) -> npt.NDArray:
        """Load every trace in the directory, zero-padded to a common length."""
        trace_files = self.path.glob("*.json")
        max_trace_length = 0
        traces = []
        for trace_file in trace_files:
            trace_data = np.asarray(_trace_from_json(trace_file).trace)
            max_trace_length = max(max_trace_length, len(trace_data))
            traces.append(trace_data)

        final_traces = []
        for trace in traces:
            extension = np.zeros(max_trace_length - len(trace))
            final_traces.append(np.concatenate([trace, extension]))
        return np.asarray(final_traces)

    def load_trace_data(self) -> list[TraceData]:
        """Load every trace in the directory as a TraceData object."""
        return [_trace_from_json(trace_file)
                for trace_file in self.path.glob("*.json")]


class TraceViewer:
    """
    Renders power traces with matplotlib.

    Bundles the recurring plotting patterns used to inspect power traces:
    overlaying many traces, comparing per-group mean traces, and showing a
    single trace. Every method builds a figure, calls plt.show() and returns
    the (figure, axes) pair so callers can customise the plot further.

    matplotlib is imported lazily in the constructor so that importing this
    module (and with it the emulator core, via syscalls.py) does not require
    matplotlib to be installed.
    """

    def __init__(self, figsize: tuple[int, int] = (20, 10), grid_alpha: float = 0.3):
        import matplotlib.pyplot as plt
        import matplotlib.cm as cm
        from matplotlib.lines import Line2D

        self._plt = plt
        self._cm = cm
        self._Line2D = Line2D
        self.figsize = figsize
        self.grid_alpha = grid_alpha

    def _new_axes(self, title: str, xlabel: str, ylabel: str) -> tuple:
        "Create a figure/axes pair with the shared title, labels and grid."
        fig, ax = self._plt.subplots(figsize=self.figsize)
        ax.set_title(title)
        ax.set_xlabel(xlabel)
        ax.set_ylabel(ylabel)
        ax.grid(True, alpha=self.grid_alpha)
        return fig, ax

    def plot_overlay(self, traces: Iterable[npt.ArrayLike], title: str = "Power Traces", *,
                     subtract_mean: bool = False, baseline: bool = False,
                     xlabel: str = "Trace Clock Cycle", ylabel: str = "Power Value",
                     legend_label: str = "traces") -> tuple:
        """
        Overlay many power traces on a single axis with a viridis colour gradient.

        traces        -- Iterable of 1D power traces. They are truncated to their
                         common minimum length before plotting.
        subtract_mean -- If True, plot each trace minus the mean of all traces.
        baseline      -- If True, draw a dashed horizontal line at y=0.
        return        -- The (figure, axes) pair.
        """
        traces = [np.asarray(t, dtype=float) for t in traces]
        min_len = min(len(t) for t in traces)
        traces = [t[:min_len] for t in traces]

        if subtract_mean:
            mean_trace = np.mean(traces, axis=0)
            traces = [t - mean_trace for t in traces]

        fig, ax = self._new_axes(title, xlabel, ylabel)
        colors = self._cm.viridis(np.linspace(0, 1, len(traces)))
        for color, trace in zip(colors, traces):
            ax.plot(trace, color=color, alpha=0.3, linewidth=0.6)

        if baseline:
            ax.axhline(0, color="black", linewidth=1.2, linestyle="--",
                       label="mean (zero)")

        trace_proxy = self._Line2D([0], [0], color=self._cm.viridis(0.5),
                                   alpha=0.6, linewidth=1,
                                   label=f"{legend_label} (n={len(traces)})")
        handles, labels = ax.get_legend_handles_labels()
        ax.legend(handles=[trace_proxy] + handles,
                  labels=[trace_proxy.get_label()] + labels)

        fig.tight_layout()
        self._plt.show()
        return fig, ax

    def plot_group_means(self, groups: dict, title: str = "Mean Traces by Group", *,
                         label_prefix: str = "group",
                         xlabel: str = "Trace Clock Cycle",
                         ylabel: str = "Power Value") -> tuple:
        """
        Plot the mean trace of each group, one thick line per group.

        groups       -- Mapping of group key -> sequence of traces. Empty groups are
                        skipped; each group's members are truncated to their common
                        minimum length before averaging.
        label_prefix -- Prefix for each line's legend label, formatted as
                        "{label_prefix}={key} (n={count})".
        return       -- The (figure, axes) pair.
        """
        populated = {key: members for key, members in groups.items()
                     if len(members) > 0}

        fig, ax = self._new_axes(title, xlabel, ylabel)
        colors = self._cm.tab10(np.linspace(0, 0.9, max(len(populated), 1)))
        for color, key in zip(colors, sorted(populated)):
            members = populated[key]
            min_len = min(len(t) for t in members)
            mean_trace = np.mean([np.asarray(t)[:min_len] for t in members],
                                 axis=0)
            ax.plot(mean_trace, color=color, linewidth=2.0,
                    label=f"{label_prefix}={key} (n={len(members)})")
        ax.legend(loc="best")

        fig.tight_layout()
        self._plt.show()
        return fig, ax

    def plot_trace(self, trace: npt.ArrayLike, title: str = "Power Trace", *,
                   xlabel: str = "Trace Clock Cycle",
                   ylabel: str = "Power Value") -> tuple:
        """
        Plot a single power trace.

        return -- The (figure, axes) pair.
        """
        fig, ax = self._new_axes(title, xlabel, ylabel)
        ax.plot(np.asarray(trace), alpha=0.3, linewidth=0.6)

        fig.tight_layout()
        self._plt.show()
        return fig, ax
