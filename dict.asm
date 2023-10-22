%include "lib.inc"
global find_word

section .text

find_word:
    push rdi
    push rsi
    add rsi, 8
    call string_equals
    pop rsi
    pop rdi
    test rax, rax
    jnz .found
    mov rsi, [rsi]
    test rsi, rsi
    jnz find_word

    xor rax, rax
    jmp .end
.found:
    mov rax, rsi
.end:
    ret


