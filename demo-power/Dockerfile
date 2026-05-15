# ─────────────────────────────────────────────────────────────────────────────
# RISC-V / Clang 17 cross-compilation image
#
# Compiles *.c → *.s for the riscv32 target used by this project:
#   --target=riscv32 -march=rv32im_zicbom_xtheadcmo
#
# Build:
#   docker build -t riscv-clang .
#
# Use (mount your source directory at /work):
#   docker run --rm -v "$(pwd)":/work riscv-clang          # runs `make`
#   docker run --rm -v "$(pwd)":/work riscv-clang clean    # runs `make clean`
# ─────────────────────────────────────────────────────────────────────────────
FROM debian:bookworm-slim

# Keep apt non-interactive
ARG DEBIAN_FRONTEND=noninteractive

# ── Stage 1: add the official LLVM 17 apt repository ─────────────────────────
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        ca-certificates \
        gnupg \
        wget \
 && wget -qO /usr/share/keyrings/llvm.asc \
        https://apt.llvm.org/llvm-snapshot.gpg.key \
 && echo "deb [signed-by=/usr/share/keyrings/llvm.asc] \
https://apt.llvm.org/bookworm/ llvm-toolchain-bookworm-17 main" \
    > /etc/apt/sources.list.d/llvm-17.list \
# ── Stage 2: install clang-17, RISC-V ELF cross-compiler, make ───────────────
 && apt-get update \
 && apt-get install -y --no-install-recommends \
        clang-17 \
        gcc-riscv64-unknown-elf \
        make \
# ── Stage 3: remove bootstrap tools, wipe apt cache ──────────────────────────
 && apt-get purge -y --auto-remove wget gnupg \
 && rm -rf /var/lib/apt/lists/* \
# ── Stage 4: wire up the sysroot the Makefile expects at /usr/riscv64-elf/ ───
#    riscv64-unknown-elf-gcc reports its configured sysroot; if it differs
#    from the Makefile default we create a symlink so no SYSROOT override
#    is needed.  If the sysroot is empty / root we create an empty directory
#    (sufficient because cpuemu.h carries no external includes and the build
#    only emits assembly, never links).
 && SYSROOT="$(riscv64-unknown-elf-gcc -print-sysroot)" \
 && if [ -z "$SYSROOT" ] || [ "$SYSROOT" = "/" ] || [ "$SYSROOT" = "/usr" ]; then \
        mkdir -p /usr/riscv64-elf; \
    elif [ "$SYSROOT" != "/usr/riscv64-elf" ]; then \
        ln -sfn "$SYSROOT" /usr/riscv64-elf; \
    fi \
# ── Stage 5: provide an unversioned `clang` alias expected by the Makefile ───
 && ln -sf /usr/bin/clang-17 /usr/local/bin/clang

WORKDIR /work

# Default target: run make.  Override by passing a make target as extra args:
#   docker run --rm -v "$(pwd)":/work riscv-clang clean
CMD ["make"]
