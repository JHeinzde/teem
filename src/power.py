import os
import numpy as np
from functools import wraps

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
            pt = power_trace()
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
        power_trace().flush_sample()
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
        Stops a the capture of a power trace. If trace_name does not exist a file with the name {trace_name}.txt will be created,
        if trace_name already exists it will append the current trace to the existing trace file.
        trace_name: The name for the file of the power trace
        return: 0 if no capture was running 1 if capture was stopped successfully
        """
        if not self.capture:
            return 0

        export = np.asarray(self.trace)

        if not os.path.exists("traces/"):
            os.mkdir("./traces")

        trace_path = f"./traces/{self.name}"

        if os.path.exists(trace_path):
            with open(trace_path, "wb") as f:
                # In case the file already exists we want to only append to the existing power trace inside of that file
                # The reason for this is the API we offer in the user-space of the emulator of the cpu
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

def power_trace():
    return PowerTrace()


POWER_TRACE = power_trace()


