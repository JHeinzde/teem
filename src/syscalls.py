"""System call (ECALL) handling."""

from __future__ import annotations

from typing import TYPE_CHECKING, Callable, Literal, Optional, Union, cast

from .execution import FaultInfo
from .instructions import RegID
from .word import Byte, Word
from .power import POWER_TRACE, POWER_VALUES

if TYPE_CHECKING:
    # Avoid circular import.
    from .cpu import CPU


SyscallCallback = Callable[['SystemCall'], None]


MAX_READWRITE = 4096


# Bounds of the random-delay countermeasure, in spliced samples
DEFAULT_DELAY_MAX_CYCLES = 20
DELAY_CYCLE_LIMIT = 4096


REGISTERED_SYSCALLS: dict[int, SyscallCallback] = {}


class SystemCall:
    """
    The context of a single system call invocation.
    """

    cpu: CPU
    fault_info: FaultInfo
    callback: Optional[SyscallCallback]

    def __init__(self, cpu: CPU, fault_info: FaultInfo):
        self.cpu = cpu
        self.fault_info = fault_info
        self.callback = None

    def get_register(self, regno: RegID) -> Word:
        "Retrieve the value of the given register."
        result = self.cpu._exec_engine._registers[regno]
        assert isinstance(result, Word)
        return result

    def set_register(self, regno: RegID, value: Word) -> None:
        "Set the indicated register to the given value."
        registers = self.cpu._exec_engine._registers
        assert isinstance(registers[regno], Word)
        registers[regno] = Word.from_int(value)

    def get_number(self) -> Word:
        "Return the number of the current system call."
        # The syscam call number is passed in a7.
        return self.get_register(cast(RegID, 17))

    def get_arg(self, index: Literal[0, 1, 2, 3, 4, 5]) -> Word:
        "Retrieve the given system call argument."
        # a0 through a5 are, conveniently, registers 10 through 15.
        return self.get_register(cast(RegID, 10 + index))

    def set_return(self, value: Word) -> None:
        "Set the system call's return value."
        self.set_register(cast(RegID, 10), value)

    def set_pc(self, addr: int) -> None:
        "Set the address at which execution will resume."
        frontend = self.cpu._frontend
        assert frontend is not None
        assert len(frontend.instr_queue) == 0
        frontend.set_pc(addr)

    def run(self) -> None:
        "Effect the system call's effects on the given CPU instance."
        if self.callback is None:
            self.set_return(Word(-38))  # ENOSYS
        else:
            self.callback(self)


def syscall(number: Union[int, Word]) -> Callable[[SyscallCallback], SyscallCallback]:
    "Decorator for entering a system call into the global registry."
    def register(callback: SyscallCallback) -> SyscallCallback:
        REGISTERED_SYSCALLS[Word.from_int(number).value] = callback
        return callback

    return register


@syscall(-1)
def sys_exit(self: SystemCall):
    "Stop the program's execution."
    self.cpu._exit_status = self.get_arg(0).value
    assert self.cpu._frontend is not None
    self.set_pc(self.cpu._frontend.pc_bounds[1])


@syscall(-2)
def sys_write(self: SystemCall):
    "Print some text to the console."
    bufaddr, bufsize = self.get_arg(0), self.get_arg(1).value

    text_bytes: list[int] = []
    for i in range(min(bufsize, MAX_READWRITE)):
        mem_result = self.cpu._mem.read_byte(bufaddr + Word(i))
        if mem_result.fault:
            self.set_return(Word(-14))  # EFAULT
            return

        text_bytes.append(mem_result.value.value)

    self.cpu._console.add_output(bytes(text_bytes))
    self.set_return(Word(len(text_bytes)))


@syscall(-3)
def sys_read(self: SystemCall):
    bufaddr, bufsize = self.get_arg(0), self.get_arg(1).value

    if not self.cpu._console.has_input:
        # If the input buffer is empty, "block" (by retrying) until it is not.
        self.cpu._console.need_input = True
        self.set_pc(self.fault_info.instr.addr)
        return

    received_bytes = self.cpu._console.read_input(min(bufsize, MAX_READWRITE))
    for i, b in enumerate(received_bytes):
        mem_result = self.cpu._mem.write_byte(bufaddr + Word(i), Byte(b))
        if mem_result.fault:
            # An EFAULT read is not guaranteed not lose data. Too bad.
            self.set_return(Word(-14))  # EFAULT
            return

    self.set_return(Word(len(received_bytes)))


@syscall(-4)
def sys_trace_start(self: SystemCall):
    "Start capturing a power trace."
    self.set_return(POWER_TRACE.start_capture())


@syscall(-5)
def sys_trace_stop(self: SystemCall):
    "Stop the running capture and write its trace to ./traces."
    self.set_return(POWER_TRACE.stop_capture())


@syscall(-6)
def sys_trace_set_name(self: SystemCall):
    "Name the trace the next capture writes."
    bufaddr, buffsize = self.get_arg(0), self.get_arg(1).value

    text_bytes: list[int] = []
    for i in range(min(buffsize - 1, MAX_READWRITE)):
        mem_result = self.cpu._mem.read_byte(bufaddr + Word(i))
        if mem_result.fault:
            self.set_return(Word(-1))
            return

        text_bytes.append(mem_result.value.value)

    POWER_TRACE.set_trace_name(bytes(text_bytes).decode("latin-1"))
    self.set_return(Word(len(text_bytes)))


@syscall(-8)
def sys_trace_set_metadata(self: SystemCall):
    "Attach a key/value pair to the trace of the next capture."
    key_addr, key_size = self.get_arg(0), self.get_arg(1).value
    value_addr, value_size = self.get_arg(2), self.get_arg(3).value

    key_bytes: list[int] = []
    for i in range(min(key_size - 1, MAX_READWRITE)):
        mem_result = self.cpu._mem.read_byte(key_addr + Word(i))
        if mem_result.fault:
            self.set_return(Word(-1))
            return
        key_bytes.append(mem_result.value.value)

    value_bytes: list[int] = []
    for i in range(min(value_size - 1, MAX_READWRITE)):
        mem_result = self.cpu._mem.read_byte(value_addr + Word(i))
        if mem_result.fault:
            self.set_return(Word(-1))
            return
        value_bytes.append(mem_result.value.value)

    POWER_TRACE.set_metadata(
        bytes(key_bytes).decode("latin-1"),
        bytes(value_bytes).decode("latin-1"),
    )
    self.set_return(Word(0))


@syscall(-7)
def sys_trace_delay(self: SystemCall):
    """
    Random-delay countermeasure: splice U{0..max_cycles} idle samples.

    a0 -- the largest number of delay cycles that may be drawn. It is optional: a
          value of 0 or less selects DEFAULT_DELAY_MAX_CYCLES, and anything above
          DELAY_CYCLE_LIMIT is clamped, so garbage left in a0 costs a bounded number
          of samples rather than the run.

    Every delay cycle draws the constant power of a nop, because the countermeasure
    works by misalignment alone. Amplitude noise is a separate knob,
    PowerTraces.noise.sigma.

    return: The maximum actually used, i.e. after defaulting and clamping.
    """
    max_cycles = self.get_arg(0).signed_value
    if max_cycles <= 0:
        max_cycles = DEFAULT_DELAY_MAX_CYCLES
    max_cycles = min(max_cycles, DELAY_CYCLE_LIMIT)

    for _ in range(POWER_TRACE.delay_random.integers(0, max_cycles + 1)):
        POWER_TRACE.insert_sample(POWER_VALUES["nop"], source="instruction")

    self.set_return(Word(max_cycles))


def dispatch_syscall(cpu: CPU, fault_info: FaultInfo) -> None:
    """
    Select which system call is being called and invoke its handler.
    """
    syscall = SystemCall(cpu, fault_info)
    number = syscall.get_number()
    try:
        syscall.callback = REGISTERED_SYSCALLS[number.value]
    except KeyError:
        pass
    syscall.run()
