# RISC-V Clang 17+ Toolchain Installation Guide

## Docker (quickest option)

A `Dockerfile` is included in this repository. It builds a self-contained image based on `debian:bookworm-slim` with clang 17 and the RISC-V ELF cross-compiler already wired up — no host toolchain installation required.

### Build the image

```sh
docker build -t riscv-clang .
```

The image is roughly 500–600 MB on disk (clang 17 accounts for most of that).

### Compile

```sh
# Run make inside the container with the current directory mounted at /work
docker run --rm -v "$(pwd)":/work riscv-clang

# Clean generated assembly files
docker run --rm -v "$(pwd)":/work riscv-clang clean

# Pass any make variable overrides as usual
docker run --rm -v "$(pwd)":/work riscv-clang CFLAGS="-O2 -Wall"
```

The `SYSROOT` and `CLANG` variables are pre-configured inside the image; no overrides are needed for the standard build.

### Notes

- The `/work` directory is the build context inside the container. The `.s` output files are written back to the host directory via the volume mount.
- The image uses `debian:bookworm-slim` as its base and strips bootstrap tools (`wget`, `gnupg`) after the LLVM repository is set up.
- The `clang-17` binary is symlinked to `/usr/local/bin/clang` so the Makefile's default `CLANG=clang` resolves correctly.

---

## What the Makefile Requires

The `Makefile` in this project uses the following toolchain setup:

```makefile
CLANG ?= clang
SYSROOT ?= /usr/riscv64-elf/
RISCV_CLANG ?= $(CLANG) --sysroot=$(SYSROOT) --target=riscv32 -march=rv32im_zicbom_xtheadcmo
CFLAGS ?= -mllvm -riscv-no-aliases -fno-builtin -Wall
```

You need:

1. **Clang 17 or newer** — required for the `XTHeadCmo` vendor extension (T-Head cache management operations)
2. **A RISC-V bare-metal ELF sysroot** — provides the C headers and runtime libraries for the `riscv32` target; defaults to `/usr/riscv64-elf/`

The Makefile only compiles C sources to assembly (`-S` flag), so no linker or C standard library runtime is strictly needed — but a sysroot with at least compiler headers must be present for clang to initialise its search paths.

All `SYSROOT`, `CLANG`, and `CFLAGS` variables can be overridden on the command line:

```sh
make CLANG=clang-17 SYSROOT=/path/to/your/sysroot
```

---

## Arch Linux (and Arch-based: Manjaro, EndeavourOS, …)

Arch ships the RISC-V bare-metal toolchain in the official `extra` repository. The sysroot ends up at `/usr/riscv64-elf/`, which is exactly what the Makefile defaults to.

```sh
# Install Clang (the system package is already 17+)
sudo pacman -S clang

# Install the RISC-V ELF cross-compiler and newlib (the C library / headers)
sudo pacman -S riscv64-elf-gcc riscv64-elf-newlib
```

> **Note on the clang version:** Arch follows a rolling release model, so the `clang` package is typically several major versions ahead of 17. If you specifically need clang 17 for reproducibility, install `clang17` from the AUR:
> ```sh
> # Using an AUR helper (e.g. paru or yay)
> paru -S clang17
> ```
> Then invoke the Makefile with `make CLANG=clang-17`.

### Verify

```sh
clang --version          # must show 17.x or later
ls /usr/riscv64-elf/include/   # should list newlib headers (e.g. stdio.h)
```

### Build

```sh
# Default — uses clang from PATH and /usr/riscv64-elf/ sysroot
make

# Explicit clang version
make CLANG=clang-17
```

---

## Debian-based (Debian 12 Bookworm / Ubuntu 24.04 LTS and later)

### 1. Install Clang 17

**Ubuntu 24.04 (Noble) and later** include `clang-17` in the official repositories:

```sh
sudo apt update
sudo apt install clang-17
```

**Ubuntu 22.04 (Jammy) and Debian 12 (Bookworm)** — clang 17 is not in the default repos; use the official LLVM apt script:

```sh
wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
sudo ./llvm.sh 17
sudo apt install clang-17
```

### 2. Install the RISC-V ELF sysroot

```sh
sudo apt install gcc-riscv64-unknown-elf picolibc-riscv64-unknown-elf
```

- `gcc-riscv64-unknown-elf` — the RISC-V bare-metal cross-compiler (also provides essential runtime objects)
- `picolibc-riscv64-unknown-elf` — the embedded C library; its headers are placed inside the GCC sysroot

### 3. Find the sysroot path

The sysroot location on Debian/Ubuntu differs from the Makefile default. Find it with:

```sh
dpkg -L gcc-riscv64-unknown-elf | grep 'riscv64-unknown-elf/include' | head -1
```

The path is typically `/usr/riscv64-unknown-elf` or a sub-path under `/usr/lib/gcc-cross/`. A reliable way to extract the sysroot root is:

```sh
riscv64-unknown-elf-gcc -print-sysroot
```

### 4. Build

```sh
make CLANG=clang-17 SYSROOT=$(riscv64-unknown-elf-gcc -print-sysroot)
```

Or set `SYSROOT` explicitly once you know the path:

```sh
make CLANG=clang-17 SYSROOT=/usr/riscv64-unknown-elf
```

---

## Fedora-based (Fedora 42+ / RHEL derivatives via EPEL)

### 1. Install Clang 17

Fedora ships a dedicated `clang17` package (the default `clang` package tracks the latest LLVM release):

```sh
sudo dnf install clang17
```

The binary is installed as `clang-17`. Verify:

```sh
clang-17 --version
```

### 2. Install the RISC-V ELF toolchain

Fedora's official repositories only include a Linux-targeting RISC-V cross-compiler (`gcc-riscv64-linux-gnu`), which is unsuitable for bare-metal. Use the official prebuilt toolchain from [riscv-collab/riscv-gnu-toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain/releases):

```sh
# Download the latest Ubuntu 22.04 prebuilt ELF toolchain (works on Fedora)
# Adjust the release tag/filename to the latest available
wget https://github.com/riscv-collab/riscv-gnu-toolchain/releases/latest/download/riscv64-elf-ubuntu-22.04-gcc-nightly-<DATE>-nightly.tar.xz

sudo mkdir -p /opt/riscv
sudo tar -xf riscv64-elf-ubuntu-22.04-gcc-nightly-*.tar.xz -C /opt/riscv --strip-components=1

# Add to PATH
echo 'export PATH=/opt/riscv/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

> Alternatively, you can build from source following the [riscv-gnu-toolchain README](https://github.com/riscv-collab/riscv-gnu-toolchain#readme). Install prerequisites first:
> ```sh
> sudo dnf install autoconf automake python3 libmpc-devel mpfr-devel \
>     gmp-devel gawk bison flex texinfo patchutils gcc gcc-c++ zlib-devel expat-devel
> ```

### 3. Find the sysroot path

```sh
riscv64-unknown-elf-gcc -print-sysroot
# Typically: /opt/riscv/riscv64-unknown-elf
```

### 4. Build

```sh
make CLANG=clang-17 SYSROOT=$(riscv64-unknown-elf-gcc -print-sysroot)
```

---

## NixOS

NixOS manages toolchain paths through the Nix store, so the traditional `/usr/riscv64-elf/` sysroot does not exist. The recommended approach is a `shell.nix` (or `devShell` in a flake) that provides both clang 17 and the RISC-V cross-compiler, and sets `SYSROOT` automatically.

### Option A: `shell.nix` (imperative / `nix-shell`)

```nix
# shell.nix
let
  pkgs = import <nixpkgs> {};
  riscvPkgs = pkgs.pkgsCross.riscv64-embedded.buildPackages;
in
pkgs.mkShell {
  name = "riscv-clang-dev";

  nativeBuildInputs = [
    pkgs.llvmPackages_17.clang   # clang 17
    riscvPkgs.gcc                # riscv64-none-elf-gcc (provides the sysroot)
    riscvPkgs.binutils
    pkgs.gnumake
  ];

  shellHook = ''
    # Resolve the riscv sysroot from the cross GCC
    export RISCV_GCC="${riscvPkgs.gcc}"
    export SYSROOT="$(${riscvPkgs.gcc}/bin/riscv64-none-elf-gcc -print-sysroot)"
    echo "RISC-V sysroot: $SYSROOT"
    echo "Clang:          $(clang --version | head -1)"
  '';
}
```

Enter the shell and build:

```sh
nix-shell
# Inside the shell:
make SYSROOT="$SYSROOT"
```

### Option B: `flake.nix` (`nix develop`)

```nix
# flake.nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs   = import nixpkgs { inherit system; };
      riscvPkgs = pkgs.pkgsCross.riscv64-embedded.buildPackages;
    in {
      devShells.${system}.default = pkgs.mkShell {
        name = "riscv-clang-dev";

        nativeBuildInputs = [
          pkgs.llvmPackages_17.clang
          riscvPkgs.gcc
          riscvPkgs.binutils
          pkgs.gnumake
        ];

        shellHook = ''
          export SYSROOT="$(${riscvPkgs.gcc}/bin/riscv64-none-elf-gcc -print-sysroot)"
          echo "RISC-V sysroot: $SYSROOT"
        '';
      };
    };
}
```

Enter the dev shell and build:

```sh
nix develop
# Inside the shell:
make SYSROOT="$SYSROOT"
```

> **Note on the cross-GCC binary name in NixOS:** The Nixpkgs `riscv64-embedded` cross package names its GCC binary `riscv64-none-elf-gcc` (not `riscv64-unknown-elf-gcc`). The sysroot itself is still compatible with clang's `--sysroot` flag.

---

## Sysroot Path Quick Reference

| Distribution | Default sysroot path | Makefile override needed? |
|---|---|---|
| Arch Linux | `/usr/riscv64-elf/` | No (matches Makefile default) |
| Debian / Ubuntu | `/usr/riscv64-unknown-elf` (verify with `riscv64-unknown-elf-gcc -print-sysroot`) | Yes |
| Fedora (prebuilt) | `/opt/riscv/riscv64-unknown-elf` | Yes |
| NixOS | Nix store path (varies per generation) | Yes — use `shellHook` to export `SYSROOT` |

---

## Verifying the Full Setup

Run the following to confirm clang and the sysroot are wired up correctly (adjust binary name and SYSROOT as needed for your distro):

```sh
clang-17 --target=riscv32 \
         -march=rv32im_zicbom_xtheadcmo \
         --sysroot=/usr/riscv64-elf/ \
         -mllvm -riscv-no-aliases \
         -fno-builtin \
         -S -o /dev/null -x c /dev/null 2>&1
```

A successful run produces no output (or only a harmless note). Any `error:` line indicates a problem with the sysroot path or an unsupported `-march` string (clang too old).

---

## Troubleshooting

**`error: unknown target triple 'riscv32'` / march not recognised**
Your clang is older than 17. Install clang 17+ as described above.

**`error: no such file or directory: 'sysroot/include'`**
The `SYSROOT` path is wrong. Use `riscv64-unknown-elf-gcc -print-sysroot` (or the distro-equivalent) to find the correct path and pass it via `make SYSROOT=…`.

**`xtheadcmo` or `zicbom` extension rejected**
These extensions require LLVM 17+. Confirm your version with `clang --version` and ensure the binary found in `PATH` is the one you installed.

**`clang-17: command not found` after using `llvm.sh`**
The script installs versioned binaries. Use `clang-17` explicitly:
```sh
make CLANG=clang-17
```
Or create a symlink:
```sh
sudo ln -s /usr/bin/clang-17 /usr/local/bin/clang
```
