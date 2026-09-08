import sys

from benedict import benedict
from .cpu import CPU


def main() -> None:
    """Execute a program from the command line, without any GUI."""
    path = "config.yml"
    config = benedict.from_yaml(path)

    cpu = CPU(config)

    if len(sys.argv) < 2:
        print("Usage: python headless_main.py <path to program>")
        exit(1)

    program = sys.argv[1]
    cpu.load_program_from_file(program)

    while (_ := cpu.tick()).executing_program:
        if cpu._console.has_output:
            print(cpu._console.extract_output(True))
