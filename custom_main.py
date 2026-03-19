from src.cpu import CPU
from src.parser import Parser


def main():
    # Just execute a cpu programm and terminate. dont do anything with the interactive emulator 
    with open("main.s", "rs") as f:
        src = f.readall()

    program = Parser().parse(src)
    cpu = CPU()


if __name__ == "__main__":
    main() 
