section .text
 
global exit
global string_length
global print_string
global print_err
global print_newline
global print_char
global print_int
global print_uint
global string_equals
global read_char
global read_word
global parse_uint
global parse_int
global string_copy



; Принимает код возврата и завершает текущий процесс
exit: 
    mov rax, 60
    syscall 

; Принимает указатель на нуль-терминированную строку, возвращает её длину
string_length:
    push rdi
    xor rax, rax
.cnt_loop:
    cmp byte[rdi + rax], 0
    jz  .end
    inc rax
    jmp .cnt_loop
.end:
    pop rdi
    ret

; Принимает указатель на нуль-терминированную строку, выводит её в stdout
print_string:
    push rdi
    call string_length
    pop rsi

    sub rsp, 2
    mov rdx, rax
    mov rdi, 1
    mov rax, 1
    syscall

    add rsp, 2
    ret

print_err:
    push rdi
    call string_length
    pop rsi
    sub rsp, 2
    mov rdx, rax
    mov rdi, 2
    mov rax, 1
    syscall
    add rsp, 2
    ret

; Переводит строку (вывод символ с кодом 0xA)
print_newline:
    mov rdi, 0xA
; Принимает код символа и выводит его в stdout
print_char:
    push rdi
    mov rsi, rsp
    mov rdi, 1
    mov rdx, 1
    mov rax, 1
    syscall
    pop rdi
    ret

; Выводит знаковое 8-байтовое число в десятичном формате 
print_int:
    push rdi
    test rdi, rdi
    jns .print_u
    mov rdi, '-'
    call print_char
    pop rdi
    neg rdi
    push rdi
.print_u:
    pop rdi
; Выводит беззнаковое 8-байтовое число в десятичном формате 
; Совет: выделите место в стеке и храните там результаты деления
; Не забудьте перевести цифры в их ASCII коды.
print_uint:
    push rdi
    xor r8, r8
    mov rax, rdi
    mov rcx, 10
.div_loop:
    xor rdx, rdx
    div rcx
    add rdx, '0'
    push rdx
    inc r8
    cmp rax, 0
    jnz .div_loop
.print:
    pop rdi
    push r8
    call print_char
    pop r8
    dec r8
    cmp r8, 0
    jnz .print
    pop rdi
    ret

; Принимает два указателя на нуль-терминированные строки, возвращает 1 если они равны, 0 иначе
string_equals:
    xor rax, rax
    xor rcx, rcx
.main_loop:
    mov al, byte[rdi + rcx]
    cmp al, byte[rsi + rcx]
    jne .neq
    cmp al, 0
    je .eq
    inc rcx
    jmp .main_loop
.eq:
    mov rax, 1
    ret
.neq:
    xor rax, rax
    ret

; Читает один символ из stdin и возвращает его. Возвращает 0 если достигнут конец потока
read_char:
    sub rsp, 8         
    mov rdi, 0
    mov rsi, rsp       
    mov rdx, 1
    mov rax, 0         
    syscall

    add rsp, 8         
    cmp rax, 0
    jle .end

    movzx rax, byte [rsi] 
    ret

.end:
    mov rax, 0
    ret


; Принимает: адрес начала буфера, размер буфера
; Читает в буфер слово из stdin, пропуская пробельные символы в начале, .
; Пробельные символы это пробел 0x20, табуляция 0x9 и перевод строки 0xA.
; Останавливается и возвращает 0 если слово слишком большое для буфера
; При успехе возвращает адрес буфера в rax, длину слова в rdx.
; При неудаче возвращает 0 в rax
; Эта функция должна дописывать к слову нуль-терминатор

read_word:
    push rdi
    push rsi
    xor rdx, rdx
.spaces:
    call read_char
    cmp al, 0x9
    je .spaces
    cmp al, 0xA
    je .spaces
    cmp al, 0x20
    je .spaces
    pop rsi
    pop rdi

    mov rdx, 0
.word:
    cmp al, 0x9
    je .fin

    cmp al, 0xA
    je .fin

    cmp al, 0x20
    je .fin

    test rax, rax
    jz .fin

    cmp rdx, rsi
    jg .fin_err
    mov [rdi+rdx], al
    inc rdx
    push rdi
    push rsi
    push rdx
    call read_char
    pop rdx
    pop rsi
    pop rdi
    jmp .word
.fin_err:
    xor rax, rax
    xor rdx, rdx
    ret
.fin:
    mov byte[rdi + rdx], 0
    mov rax, rdi
    ret
 

; Принимает указатель на строку, пытается
; прочитать из её начала беззнаковое число.
; Возвращает в rax: число, rdx : его длину в символах
; rdx = 0 если число прочитать не удалось
parse_uint:
    push rbx
    xor rax, rax
    xor rdx, rdx
.main_loop:
	mov bl, byte[rdi+rdx]
	test bl, bl
	jz .fin

	cmp bl, '0'
	jl .fin_err

	cmp bl, '9'
	jg .fin_err

	sub bl, '0'
	imul rax, 10

	add rax, rbx
	inc rdx
	jmp .main_loop
.fin_err:
	cmp rax, 0
	jnz .fin
	xor rdx, rdx
.fin:
	pop rbx
	ret


; Принимает указатель на строку, пытается
; прочитать из её начала знаковое число.
; Если есть знак, пробелы между ним и числом не разрешены.
; Возвращает в rax: число, rdx : его длину в символах (включая знак, если он был) 
; rdx = 0 если число прочитать не удалось
parse_int: 
    cmp byte[rdi], '-'
    jne parse_uint
    inc rdi
    call parse_uint
    test rdx, rdx
    jz .fin
    inc rdx
    neg rax
.fin:
    ret

; Принимает указатель на строку, указатель на буфер и длину буфера
; Копирует строку в буфер
; Возвращает длину строки если она умещается в буфер, иначе 0
string_copy:
    push rdi
    push rsi
    push rdx

    call string_length

    xor rcx, rcx

    pop rdx
    pop rsi
    pop rdi

    inc rax
    cmp rax, rdx
    jg .fin_err

.main_loop:
    cmp rax, rcx
    je .fin
    mov dl, byte [rdi + rcx]
    mov [rsi + rcx], dl
    inc rcx
    jmp .main_loop	
.fin:
    ret    
.fin_err: 
    xor rax, rax
    ret
