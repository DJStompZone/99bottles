; 99 Bottles dual-target (NASM Linux/Win64)
; ©2025 DJ Stomp, MIT license
; "No Rights Reserved"

BITS 64

%ifidn __OUTPUT_FORMAT__,win64
    %define TARGET_WIN64
%endif

%ifdef TARGET_WIN64
extern  GetStdHandle
extern  WriteFile
extern  ExitProcess
STD_OUTPUT_HANDLE       equ -11
%endif

section .data
    bottles:        db " bottles of beer", 10
    bottles_len:    equ $ - bottles
    on_wall:        db " on the wall", 10
    on_wall_len:    equ $ - on_wall
    take_down:      db "Take one down, pass it around", 10
    take_down_len:  equ $ - take_down
    nl:             db 10
    nl_len:         equ $ - nl

section .bss
    numbuf:         resb 32
%ifdef TARGET_WIN64
    bytes_written:  resd 1
    hStdOut:        resq 1
%endif

section .text
global _start

; --------------------------------------------------------
; Macro: WRITE ptr,len  -> stdout
; Clobbers: rcx, rdx, r8, r9, rax (win32)  rax, rdi, rsi, rdx (gcc)
; --------------------------------------------------------
%macro WRITE 2
%ifdef TARGET_WIN64
    mov     rcx, [rel hStdOut]
    mov     rdx, %1
    mov     r8,  %2
    lea     r9,  [rel bytes_written]
    sub     rsp, 32
    call    WriteFile
    add     rsp, 32
%else
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, %1
    mov     rdx, %2
    syscall
%endif
%endmacro

; -----------------------------------------------------
; prints unsigned integer in RAX to stdout
; Clobbers: rax, rbx, rcx, rdx, rsi, r8, r9
; -----------------------------------------------------
print_u64:
    push    rbx
    mov     rbx, 10
    lea     rsi, [rel numbuf + 32]

    cmp     rax, 0
    jne     .conv
    mov     byte [rel numbuf + 31], '0'
    lea     rsi, [rel numbuf + 31]
    mov     rdx, 1
    jmp     .out

.conv:
.repeat:
    xor     rdx, rdx
    div     rbx
    dec     rsi
    mov     byte [rsi], dl
    add     byte [rsi], '0'
    test    rax, rax
    jne     .repeat

    lea     rdx, [rel numbuf + 32]
    sub     rdx, rsi

.out:
    WRITE   rsi, rdx
    pop     rbx
    ret

; -----------------
; Win64 init stdout
; -----------------
%ifdef TARGET_WIN64
init_io:
    mov     ecx, STD_OUTPUT_HANDLE
    sub     rsp, 32
    call    GetStdHandle
    add     rsp, 32
    mov     [rel hStdOut], rax
    ret
%endif

_start:
%ifdef TARGET_WIN64
    call    init_io
%endif
    mov     r15, 99

.loop:
    mov     rax, r15
    call    print_u64
    lea     rsi, [rel bottles]
    mov     rdx, bottles_len
    WRITE   rsi, rdx
    lea     rsi, [rel on_wall]
    mov     rdx, on_wall_len
    WRITE   rsi, rdx

    mov     rax, r15
    call    print_u64
    lea     rsi, [rel bottles]
    mov     rdx, bottles_len
    WRITE   rsi, rdx

    lea     rsi, [rel take_down]
    mov     rdx, take_down_len
    WRITE   rsi, rdx

    dec     r15
    mov     rax, r15
    call    print_u64
    lea     rsi, [rel bottles]
    mov     rdx, bottles_len
    WRITE   rsi, rdx
    lea     rsi, [rel on_wall]
    mov     rdx, on_wall_len
    WRITE   rsi, rdx
    lea     rsi, [rel nl]
    mov     rdx, nl_len
    WRITE   rsi, rdx

    test    r15, r15
    jg      .loop

%ifdef TARGET_WIN64
    xor     ecx, ecx
    sub     rsp, 32
    call    ExitProcess
%else
    mov     rax, 60
    xor     rdi, rdi
    syscall
%endif
