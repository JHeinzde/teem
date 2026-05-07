
# Requires Clang 17+ (for XTHeadCmo)
CLANG ?= clang
SYSROOT ?= /usr/riscv64-elf/
RISCV_CLANG ?= $(CLANG) --sysroot=$(SYSROOT)  --target=riscv32 -march=rv32im_zicbom_xtheadcmo
CFLAGS ?=  -mllvm -riscv-no-aliases -fno-builtin -Wall

.PHONY: all clean

all: $(patsubst %.c,%.s,$(wildcard *.c))

%.s: %.c cpuemu.h
	$(RISCV_CLANG) $(CFLAGS) -S -o $@ $<

clean:
	rm -f *.s
