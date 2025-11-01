@ECHO OFF

nasm -f win64 -DTARGET_WIN64 bottles_poly.asm -o bottles.obj
gcc -nostdlib -Wl,-e,_start -o bottles.exe bottles.obj -lkernel32
