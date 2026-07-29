import sys

from benedict import benedict
from .cpu import CPU


def main():
    """
    Execute a programm via the command-line without any GUI.

    return -- 0 if the programm executed successfully
              1 if the programm does not exist or execution
                was not successfull.
    """
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
