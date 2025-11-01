# 99 Bottles Poly NASM

Cross-platform x86-64 assembly implementation of "99 Bottles of Beer"
Build it for Linux or Windows from a single assembly source via a small macro

## Overview
Demonstrates how to write a single NASM source that conditionally compiles for both ELF64 (Linux) and PE/COFF (Win64).

## Compilation

### Linux
```bash
nasm -felf64 -DTARGET_LINUX 99bottles_poly.asm -o 99bottles.o
ld -o 99bottles 99bottles.o
./99bottles
```

### Windows (MinGW64)
```bash
nasm -f win64 -DTARGET_WIN64 99bottles_poly.asm -o 99bottles.obj
gcc -nostdlib -Wl,-e,_start -o 99bottles.exe 99bottles.obj -lkernel32
./99bottles.exe
```

These have been saved in `build.sh` and `build.bat` respectively

## Under the Hood

| Platform | Output call | Exit call | ABI notes |
|-----------|--------------|-----------|------------|
| Linux | `sys_write(1, buf, len)` | `sys_exit(0)` | Syscalls via `syscall`, volatile regs handled per System V |
| Windows | `WriteFile(GetStdHandle(-11), buf, len, )` | `ExitProcess(0)` | Shadow space observed, caller-saved regs avoided |

## Requirements
* NASM  2.15  
* Linux: `ld`
* Windows: MinGW-w64 (`gcc` and `ld`)  

## License

MIT License  

2025 DJ Stomp
"No Rights Reserved"
