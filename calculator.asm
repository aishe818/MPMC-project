.model small
.stack 100h
.data
    ; Menu messages
    menu_msg     db 10,13,'Choose your operation$'
    menu_1       db 10,13,'1. Addition$'
    menu_2       db 10,13,'2. Subtraction$'
    menu_3       db 10,13,'3. Multiplication$'
    menu_4       db 10,13,'4. Division$'
    menu_5       db 10,13,'5. Exit$'
    choice_msg   db 10,13,'Enter your choice (1-5): $'

    ; Input prompts
    num1_msg     db 10,13,'Enter first number (0-99): $'
    num2_msg     db 10,13,'Enter second number (0-99): $'
    result_msg   db 10,13,'Result: $'
    continue_msg db 10,13,'Press any key to continue...$'

    ; Variables
    num1        dw ?    
    num2        dw ?

    ; Error message
    div_zero_msg db 10,13,'Error: Division by zero!$'

.code
main proc
    mov ax, @data
    mov ds, ax

menu_loop:
    ; Clear screen
    mov ax, 0003h
    int 10h

    ; Display menu
    mov ah, 9
    lea dx, menu_msg
    int 21h
    lea dx, menu_1
    int 21h
    lea dx, menu_2
    int 21h
    lea dx, menu_3
    int 21h
    lea dx, menu_4
    int 21h
    lea dx, menu_5
    int 21h
    lea dx, choice_msg
    int 21h

    ; Get user choice
    mov ah, 1
    int 21h

    cmp al, '1'
    je do_addition
    cmp al, '2'
    je do_subtraction
    cmp al, '3'
    je do_multiplication
    cmp al, '4'
    je do_division
    cmp al, '5'
    je exit_program

    jmp menu_loop

do_addition:
    call get_numbers
    mov ax, num1
    add ax, num2
    call show_result
    jmp menu_loop

do_subtraction:
    call get_numbers
    mov ax, num1
    sub ax, num2
    call show_result
    jmp menu_loop

do_multiplication:
    call get_numbers
    mov ax, num1
    xor dx, dx          ; ?? Clear DX to avoid garbage in high bits
    mul num2            ; AX = num1 * num2
    call show_result
    jmp menu_loop

do_division:
    call get_numbers
    cmp num2, 0
    jne perform_div
    mov ah, 9
    lea dx, div_zero_msg
    int 21h
    call wait_key
    jmp menu_loop

perform_div:
    mov ax, num1
    xor dx, dx
    div num2            ; AX = result, DX = remainder
    call show_result

    cmp dx, 0
    je no_remainder

    ; Display decimal point and one decimal digit
    mov ah, 2
    mov dl, '.'
    int 21h

    mov ax, dx
    mov cx, 10
    mul cx
    div num2
    add al, '0'
    mov dl, al
    mov ah, 2
    int 21h

no_remainder:
    call wait_key
    jmp menu_loop

exit_program:
    mov ah, 4ch
    int 21h
main endp

; --------------------------
; Get two numbers from user
; --------------------------
get_numbers proc
    mov ah, 9
    lea dx, num1_msg
    int 21h
    call read_number
    mov num1, ax

    mov ah, 9
    lea dx, num2_msg
    int 21h
    call read_number
    mov num2, ax

    ret
get_numbers endp

; --------------------------
; Read 1- or 2-digit number
; --------------------------
read_number proc
    xor bx, bx

    ; First digit
    mov ah, 1
    int 21h
    sub al, '0'
    mov bl, al

    ; Check for second digit
    mov ah, 1
    int 21h
    cmp al, 13
    je single_digit

    sub al, '0'
    mov cl, al

    mov al, 10
    mul bl
    add al, cl
    mov bl, al

single_digit:
    mov ax, bx
    ret
read_number endp

; --------------------------
; Show result in AX
; --------------------------
show_result proc
    mov bx, ax

    mov ah, 9
    lea dx, result_msg
    int 21h

    cmp bx, 0
    jne not_zero

    mov ah, 2
    mov dl, '0'
    int 21h
    jmp result_done

not_zero:
    mov ax, bx
    mov cx, 0
    mov bx, 10

digits_to_stack:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz digits_to_stack

print_digits:
    pop dx
    add dl, '0'
    mov ah, 2
    int 21h
    loop print_digits

result_done:
    call wait_key
    ret
show_result endp

wait_key proc
    mov ah, 9
    lea dx, continue_msg
    int 21h

    mov ah, 1
    int 21h
    ret
wait_key endp

end main
