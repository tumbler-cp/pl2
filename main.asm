%include "dict.inc"
%include "lib.inc"
%include "words.inc"

section .bss
buff: resb 256 ; Буффер 

section .data
error_404: db "<ERROR>: Key not found !", 0
error_reading: db "<ERROR>: Too many characters for key!", 0

section .text

global _start
_start:
    mov rdi, buff
    mov rsi, 256
    call read_word
    test rax, rax
    jz .err_read

    mov rdi, buff
    mov rsi, header
    call find_word
    test rax, rax
    jz .err_find

    mov rdi, rax
    add rdi, 8
    call string_length
    lea rdi, [rdi + rax + 1]
    call print_string
    call print_newline
    call exit
    
.err_find:
    mov rdi, error_404
    jmp .err
.err_read:
    mov rdi, error_reading
.err:
    call print_err
    call exit

