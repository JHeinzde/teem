
# Requires Clang 17+ (for XTHeadCmo)
CLANG ?= clang
SYSROOT ?= /usr/riscv64-elf/
RISCV_CLANG ?= $(CLANG) --sysroot=$(SYSROOT) --target=riscv32-unknown-elf -march=rv32im_zicbom_xtheadcmo
CFLAGS ?=  -mllvm -riscv-no-aliases -fno-builtin -fno-plt -Wall

.PHONY: all clean

all: $(patsubst %.c,%.s,$(wildcard *.c))

%.s: %.c cpuemu.h
	$(RISCV_CLANG) $(CFLAGS) -S -o $@ $<
	sed -i 's/@plt//g' $@

clean:
	rm -f *.s
