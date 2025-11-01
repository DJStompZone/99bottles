#!/usr/bin/env bash

nasm -felf64 -DTARGET_LINUX bottles_poly.asm -o bottles.o
ld -o bottles bottles.o
