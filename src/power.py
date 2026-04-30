import os
from functools import wraps
from typing import List, Tuple, Callable

import numpy as np
import numpy.typing as npt

POWER_VALUES = {
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
    "lui": 1.0,
    "auipc": 1.0,
    "mul": 4.5,
    "mulh": 4.5,
    "mulhu": 4.5,
    "mulhsu": 4.5,
    "div": 5.0,
    "divu": 5.0,
    "rem": 4.5,
    "remu": 4.5,
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
    "fence.i": 10.0,
    "ecall": 1.0,
    "ebreak": 1.0,
    "blts": 3.0,
    "bles": 3.0,
    "bgts": 3.0,
    "bges": 3.0,
    "li": 1.0,
    "mv": 1.0,
    "not": 0.8,
    "neg": 0.8,
    "seqz": 1.0,
    "snez": 1.0,
    "sltz": 1.0,
    "sgtz": 1.0,
    "lw": 2.0,
    "lh": 2.0,
    "lhu": 1.0,
    "lb": 1.0,
    "lbu": 1.0,
    "beqz": 1.0,
    "bnez": 1.0,
    "bltz": 1.0,
    "blez": 1.0,
    "bgtz": 1.0,
    "bgez": 1.0,
    "bltuz": 1.0,
    "bleuz": 1.0,
    "bgtuz": 1.0,
    "bgeuz": 1.0,
    "j": 1.0,
    "jr": 1.0,
    "ret": 1.0,
    "call": 1.0,
    "tail": 1.0,
    "flush": 1.0,
    "flushall": 1.0,
    "rdtsc": 1.0,
    "fence": 1.0,
    "th.dcache.ciall": 1.0,
}


def power_draw(func):
    @wraps(func)
    def wrapper(self, *args, **kwargs):
        result = func(self, *args, **kwargs)
        # If a slot is in the executing stage we add its power value to the power trace.
        if self.stage == "executing":
            pt = POWER_TRACE
            pt.append(POWER_VALUES[self.instr_ty.name])
        return result

    return wrapper


def cycle_power(func):
    @wraps(func)
    def wrapper(self, *args, **kwargs):
        result = func(self)
        if result.fault_info is not None:
            # Currently we only care about cycles that did not produce a fault
            return result
        POWER_TRACE.flush_sample()
        return result

    return wrapper


class PowerTrace(object):
    """
    Represents a power trace of the cpu. This is an append only data structure
    """

    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(PowerTrace, cls).__new__(cls)
            cls.trace = []
            cls.sample = []
            cls.capture = False
            cls.name = "power-trace"
            cls.random = np.random.default_rng()
            cls.random_noise = True
        return cls._instance

    def append(self, trace_value: float):
        if self.capture:
            self.sample.append(trace_value)

    def flush_sample(self):
        if not self.capture:
            return
        cycle_value = 0.0
        for s in self.sample:
            cycle_value += s

        self.sample = []

        self.trace.append(cycle_value)

    def set_trace_name(self, name: str):
        self.name = name

    def start_capture(self):
        if not self.capture:
            self.capture = True
            self.sample = []
            return 1
        return 0

    def stop_capture(self):
        """
        Stops a the capture of a power trace. It will write all resulting traces into a ./traces directory.
        If the set trace name already exists we will extend the power trace already contained in that file.
        trace_name: The name for the file of the power trace
        return: 0 if no capture was running 1 if capture was stopped successfully
        """
        if not self.capture:
            return 0

        export = np.asarray(self.trace)

        if self.random_noise:
            noise = self.random.standard_normal(len(export))
            export += noise

        if not os.path.exists("traces/"):
            os.mkdir("./traces")

        trace_path = f"./traces/{self.name}"

        if os.path.exists(trace_path):
            with open(trace_path) as f:
                # TODO: see if there is a more simple way to extend the array in a file
                arr = np.load(f)
                arr.extend(export)
                f.seek(0)
                np.save(arr)
        else:
            with open(trace_path, "wb") as f:
                np.save(f, export)

        self.trace = []
        self.capture = False
        return 1


def set_config(conf):
    PowerTrace().random_noise = conf["PowerTraces"]["random_noise"]


POWER_TRACE = PowerTrace()

# disable E231
SBOX = [
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

HW = [bin(n).count("1") for n in range(0, 256)]


def mean(X):
    return np.sum(X, axis=0)/len(X)


def std_dev(X, X_bar):
    return np.sqrt(np.sum((X-X_bar)**2, axis=0))


def cov(X, X_bar, Y, Y_bar):
    return np.sum((X-X_bar)*(Y-Y_bar), axis=0)


def aes_internal(input_byte, key_byte):
    """
    Helper function for AES leakage model.
    Represents the internal state leakage based on S-box output.
    """
    return input_byte ^ key_byte ^ SBOX[input_byte ^ key_byte]


class CPAAttack:

    def __init__(self, trace_data):
        """
        Constructs a CPAAttack instance. 
        trace_data: A an array which per trace contains a tuple with (input byte array, trace) 
        """
        self.trace_data = trace_data

    def attack(self) -> npt.ArrayLike:
        """
        Calculates the correlation for each keyguess for the first keybot TODO: Extend to return the correlation for each key byte in the whole key
        return: A numpy array where the index is the guess for the keybyte and the value at index i is the correlation this keyguess has. Higher values are 
        better.
        """
        textin_array = []
        trace_array = []
        for t in range(len(self.trace_data)):
            textin_array.append(self.trace_data[t][0])
            trace_array.append(self.trace_data[t][1])

        maxcpa = [0] * 256
        t_bar = mean(trace_array)
        o_t = std_dev(trace_array, t_bar)

        for kguess in range(0, 256):
            hws = np.array([[HW[textin ^ kguess ^ aes_internal(textin, kguess)] for textin in textin_array]]).transpose()
            hws_bar = mean(hws)
            o_hws = std_dev(hws, hws_bar)
            correlation = cov(trace_array, t_bar, hws, hws_bar)
            cpaoutput = correlation/(o_t*o_hws)
            maxcpa[kguess] = max(abs(cpaoutput))

        return maxcpa


class DPAAttack:

    def __init__(self, trace_data: List[Tuple], leakage_model: Callable):
        """
        Construct a DPAAttack instance 
        trace_data: An array which per trace contains a tuple with (input byte array, trace)
        leakage_model: A callable function that takes (input_byte, key_guess) and returns a leakage value
        """
        self.trace_data = trace_data
        self.leakage_model = leakage_model

    def attack(self) -> npt.ArrayLike:
        """
        Calculate the most likley keyguess based on the provided leakage model by building a one and zero list with the leakage model. Returns
        all possible keybytes in the order of best match according to DPA.
        For now, only attacks the first byte of the key.
        return: A numpy array where the index is the guess for the keybyte and the value at index i 
                is the DPA score for that keyguess. Higher values are better.
        """
        textin_array = []
        trace_array = []
        for t in self.trace_data:
            textin_array.append(t[0])
            trace_array.append(t[1])
        textin_array = np.array(textin_array)
        trace_array = np.array(trace_array)
        dpa_scores = [0] * 256
        for key_guess in range(256):
            zero_list = []
            one_list = []
            for i in range(len(textin_array)):
                input_byte = textin_array[i]  # Get first byte of input
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
