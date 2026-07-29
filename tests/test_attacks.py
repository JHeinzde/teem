from shutil import rmtree
from unittest import TestCase

import numpy as np
from benedict import benedict as bd

from src.cpu import CPU
from src.power import CPAAttack, DPAAttack, TraceLoader, aes_internal


class AttacksTest(TestCase):
    """Test Meltdown and Spectre demo attacks."""

    def test_meltdown(self):
        """Test a simple Meltdown attack."""
        # Create CPU and load program
        cpu = CPU(bd.from_yaml("config.yml"))
        cpu.load_program_from_file("demo/meltdown.tea")

        # Execute program to the end
        while True:
            info = cpu.tick()
            if not info.executing_program:
                break

        # Check that the secret value was leaked successfully
        secret = 0x42
        leaked = cpu._exec_engine._registers[1].value // 0x10
        self.assertEqual(leaked, secret)

    def test_spectre(self):
        """Test a simple Spectre attack."""
        # Create CPU and load program
        cpu = CPU(bd.from_yaml("config.yml"))
        cpu.load_program_from_file("demo/spectre.tea")

        # Execute program to the end
        while True:
            info = cpu.tick()
            if not info.executing_program:
                break

        # Check that the secret value was leaked successfully
        secret = 0x41
        leaked = cpu._exec_engine._registers[1].value // 0x10
        self.assertEqual(leaked, secret)

    def test_dpa(self):
        """Test a simpel one byte dpa attack"""

        # stop_capture() appends to an existing traces/<name>.json, so a
        # leftover directory from an earlier run would double every trace.
        rmtree("traces", ignore_errors=True)

        # The cache-line refill leak adds up to four 0-32 Hamming distances to
        # the same cycle as the 0-8 algorithmic leak, which buries the single
        # bit that DPA partitions on. Correlation-based CPA survives that;
        # single-bit DPA does not. See
        # docs/superpowers/specs/2026-07-27-cache-refill-leakage-config-design.md
        conf = bd.from_yaml("config.yml")
        conf["PowerTraces"]["cache_refill_leakage"] = False

        cpu = CPU(conf)
        cpu.load_program_from_file("demo-power/aes-no-delay-first-byte-varies.s")

        while True:
            if not (info := cpu.tick()).executing_program:
                break
        key_byte = 0x1A

        # load the resulting traces and convert them into a structure that can be used by the DPAAttack class
        traces = TraceLoader("traces").load_trace_data()
        converted_traces = []
        for trace in traces:
            converted_traces.append(
                (bytes(trace.metadata["input"], "latin-1")[0], trace.trace)
            )
        dpa = DPAAttack(converted_traces, aes_internal)
        result = dpa.attack()
        recovered_key_byte = np.argmax(result)

        self.assertEqual(key_byte, recovered_key_byte)
        rmtree(
            "traces"
        )  # Cleanup traces directory, which would be dangling after this test.

    def test_cpa(self):
        """Test a simple one byte cpa attack"""

        rmtree("traces", ignore_errors=True)

        conf = bd.from_yaml("config.yml")
        conf["PowerTraces"]["cache_refill_leakage"] = False

        cpu = CPU(conf)
        cpu.load_program_from_file("demo-power/aes-no-delay-first-byte-varies.s")

        while True:
            if not (info := cpu.tick()).executing_program:
                break
        key_byte = 0x1A

        # load the resulting traces and convert them into a structure that can be used by the DPAAttack class
        traces = TraceLoader("traces").load_trace_data()
        converted_traces = []
        for trace in traces:
            converted_traces.append(
                (bytes(trace.metadata["input"], "latin-1")[0], trace.trace)
            )
        cpa = CPAAttack(converted_traces, aes_internal)
        result = cpa.attack()
        recovered_key_byte = np.argmax(result)

        self.assertEqual(key_byte, recovered_key_byte)
        rmtree(
            "traces"
        )  # Cleanup traces directory, which would be dangling after this test.
