import sys

from benedict import benedict

from src.cpu import CPU


def main():
    # Just execute a cpu programm and terminate. dont do anything with the interactive emulator
    path = "config.yml"
    config = benedict.from_yaml(path)

    cpu = CPU(config)

    if len(sys.argv < 2):
        print("Usage: python headless_main.py <path to program>")
        exit(1)

    program = sys.argv[1]
    cpu.load_program_from_file(program)

    while (info := cpu.tick()).executing_program:
        if cpu._console.has_output:
            print(cpu._console.extract_output(True))


if __name__ == "__main__":
    main()
