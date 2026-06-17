; ==============================================================================
;                      ASMCalc - Main CLI Application (x86 32-bit)
; ==============================================================================
; Author: Kalyel N. Laurindo / Software Engineer
; Date: 2026-06-17
; Description: Router and interactive user interface loop. Uses ANSI color escapes.
; ==============================================================================

bits 32

section .data
    ; ANSI Escape Color Constants
    CLR_RESET   db 27, "[0m", 0
    CLR_TITLE   db 27, "[1;36m", 0  ; Bold Cyan
    CLR_MENU    db 27, "[1;33m", 0  ; Bold Yellow
    CLR_SUCCESS db 27, "[1;32m", 0  ; Bold Green
    CLR_ERROR   db 27, "[1;31m", 0  ; Bold Red
    CLR_HINT    db 27, "[0;35m", 0  ; Purple/Magenta Hint

    ; Banner Strings
    msg_banner_top db "===============================================", 10, 0
    msg_banner_mid db "                 ASMCalc CLI Calculator        ", 10, 0
    msg_banner_bot db "===============================================", 10, 0

    ; Menu Strings
    msg_ans_label db "  Active ANS Register: ", 0
    msg_ans_empty db "N/A", 10, 0
    msg_menu_line db "-----------------------------------------------", 10, 0
    msg_menu_opt1 db "  1. Add (+)", 10, 0
    msg_menu_opt2 db "  2. Subtract (-)", 10, 0
    msg_menu_opt3 db "  3. Multiply (*)", 10, 0
    msg_menu_opt4 db "  4. Divide (/)", 10, 0
    msg_menu_opt5 db "  5. Modulo (%)", 10, 0
    msg_menu_opt6 db "  6. Power (^)", 10, 0
    msg_menu_opt7 db "  7. Clear ANS Register", 10, 0
    msg_menu_opt8 db "  8. Exit Program", 10, 0
    msg_menu_prompt db "  Choose Option (1-8): ", 0

    ; Prompt Strings
    msg_prompt_a db "  Enter Operand A: ", 0
    msg_prompt_b db "  Enter Operand B: ", 0
    msg_hint_ans db " (type 'ans' to reuse last result)", 0
    msg_newline db 10, 0

    ; Result and Error Strings
    msg_result_prefix db "  Result: ", 0
    msg_err_invalid   db "  [ERROR] Invalid option! Please enter 1-8.", 10, 0
    msg_err_num       db "  [ERROR] Invalid numeric format or overflow!", 10, 0
    msg_err_div_zero  db "  [ERROR] Division by zero is undefined!", 10, 0
    msg_err_ans_empty db "  [ERROR] ANS register is empty!", 10, 0
    msg_exit_greeting db "  Goodbye! Thanks for using ASMCalc.", 10, 0

    ; ANS Register State
    has_ans dd 0
    ans_val dd 0

section .bss
    ; Input Buffers
    buf_option resb 16
    buf_operand resb 64
    buf_output resb 32
    val_a resd 1
    val_b resd 1
    val_opt resd 1

section .text

; External Math Engine Subroutines
extern _math_add
extern _math_sub
extern _math_imul
extern _math_idiv
extern _math_mod
extern _math_pow

; External Input/Output Subroutines
extern _print_str
extern _read_str
extern _atoi_conv
extern _itoa_conv

global _main

; ------------------------------------------------------------------------------
; Main application loop entry point
; ------------------------------------------------------------------------------
_main:
    ; Establish stack frame
    push ebp
    mov ebp, esp

.menu_loop:
    ; Print Banner
    push CLR_TITLE
    call _print_str
    add esp, 4
    push msg_banner_top
    call _print_str
    push msg_banner_mid
    call _print_str
    push msg_banner_top
    call _print_str
    push CLR_RESET
    call _print_str
    add esp, 16

    ; Print ANS Register status
    push msg_ans_label
    call _print_str
    add esp, 4

    mov eax, [has_ans]
    test eax, eax
    jz .print_ans_na

    ; Convert ans_val to string and print it in success green
    push CLR_SUCCESS
    call _print_str
    add esp, 4

    push buf_output
    push dword [ans_val]
    call _itoa_conv
    add esp, 8

    push buf_output
    call _print_str
    push msg_newline
    call _print_str
    add esp, 8
    jmp .print_menu_body

.print_ans_na:
    push msg_ans_empty
    call _print_str
    add esp, 4

.print_menu_body:
    ; Print Menu Operations
    push CLR_MENU
    call _print_str
    add esp, 4

    push msg_menu_line
    call _print_str
    push msg_menu_opt1
    call _print_str
    push msg_menu_opt2
    call _print_str
    push msg_menu_opt3
    call _print_str
    push msg_menu_opt4
    call _print_str
    push msg_menu_opt5
    call _print_str
    push msg_menu_opt6
    call _print_str
    push msg_menu_opt7
    call _print_str
    push msg_menu_opt8
    call _print_str
    push msg_menu_line
    call _print_str
    add esp, 40

    push CLR_RESET
    call _print_str
    add esp, 4

    ; Prompt Option Input
    push msg_menu_prompt
    call _print_str
    add esp, 4

    push 16
    push buf_option
    call _read_str
    add esp, 8
    cmp eax, -1
    je .exit_prog

    ; Convert option to int
    push val_opt
    push buf_option
    call _atoi_conv
    add esp, 8
    test eax, eax
    jnz .invalid_option

    ; Validate range 1-8
    mov eax, [val_opt]
    cmp eax, 1
    jl .invalid_option
    cmp eax, 8
    jg .invalid_option

    ; Check for Exit (8)
    cmp eax, 8
    je .exit_prog

    ; Check for Clear ANS (7)
    cmp eax, 7
    je .clear_ans

    ; It's a calculation (1 to 6). Proceed to Operand A.
    jmp .prompt_operand_a

.invalid_option:
    push CLR_ERROR
    call _print_str
    push msg_err_invalid
    call _print_str
    push CLR_RESET
    call _print_str
    add esp, 12
    jmp .menu_loop

.clear_ans:
    mov dword [has_ans], 0
    mov dword [ans_val], 0
    push CLR_SUCCESS
    call _print_str
    push msg_menu_line
    call _print_str
    push CLR_RESET
    call _print_str
    add esp, 12
    jmp .menu_loop

.exit_prog:
    push CLR_TITLE
    call _print_str
    push msg_exit_greeting
    call _print_str
    push CLR_RESET
    call _print_str
    add esp, 12
    
    ; Return 0
    xor eax, eax
    pop ebp
    ret

; ------------------------------------------------------------------------------
; Read Operand A
; ------------------------------------------------------------------------------
.prompt_operand_a:
    push msg_prompt_a
    call _print_str
    add esp, 4

    ; Show ANS hint if available
    mov eax, [has_ans]
    test eax, eax
    jz .read_a_input
    push CLR_HINT
    call _print_str
    push msg_hint_ans
    call _print_str
    push CLR_RESET
    call _print_str
    add esp, 12

.read_a_input:
    push 64
    push buf_operand
    call _read_str
    add esp, 8
    cmp eax, -1
    je .exit_prog

    ; Check if input is "ans" (case insensitive)
    push buf_operand
    call _check_ans_keyword
    add esp, 4
    test eax, eax
    jz .parse_a_normally

    ; Use ANS
    mov eax, [has_ans]
    test eax, eax
    jz .ans_empty_err
    mov eax, [ans_val]
    mov [val_a], eax
    jmp .prompt_operand_b

.parse_a_normally:
    push val_a
    push buf_operand
    call _atoi_conv
    add esp, 8
    test eax, eax
    jnz .operand_error

; ------------------------------------------------------------------------------
; Read Operand B
; ------------------------------------------------------------------------------
.prompt_operand_b:
    push msg_prompt_b
    call _print_str
    add esp, 4

    ; Show ANS hint if available
    mov eax, [has_ans]
    test eax, eax
    jz .read_b_input
    push CLR_HINT
    call _print_str
    push msg_hint_ans
    call _print_str
    push CLR_RESET
    call _print_str
    add esp, 12

.read_b_input:
    push 64
    push buf_operand
    call _read_str
    add esp, 8
    cmp eax, -1
    je .exit_prog

    ; Check if input is "ans" (case insensitive)
    push buf_operand
    call _check_ans_keyword
    add esp, 4
    test eax, eax
    jz .parse_b_normally

    ; Use ANS
    mov eax, [has_ans]
    test eax, eax
    jz .ans_empty_err
    mov eax, [ans_val]
    mov [val_b], eax
    jmp .execute_calculation

.parse_b_normally:
    push val_b
    push buf_operand
    call _atoi_conv
    add esp, 8
    test eax, eax
    jnz .operand_error

; ------------------------------------------------------------------------------
; Execute Operation
; ------------------------------------------------------------------------------
.execute_calculation:
    mov eax, [val_opt]
    
    cmp eax, 1
    je .do_add
    cmp eax, 2
    je .do_sub
    cmp eax, 3
    je .do_imul
    cmp eax, 4
    je .do_idiv
    cmp eax, 5
    je .do_mod
    cmp eax, 6
    je .do_pow
    jmp .menu_loop ; Should not happen

.do_add:
    push dword [val_b]
    push dword [val_a]
    call _math_add
    add esp, 8
    jmp .display_result

.do_sub:
    push dword [val_b]
    push dword [val_a]
    call _math_sub
    add esp, 8
    jmp .display_result

.do_imul:
    push dword [val_b]
    push dword [val_a]
    call _math_imul
    add esp, 8
    jmp .display_result

.do_idiv:
    ; Division safety checks
    mov ecx, [val_b]
    cmp ecx, 0
    je .div_zero_err

    push dword [val_b]
    push dword [val_a]
    call _math_idiv
    add esp, 8
    jmp .display_result

.do_mod:
    ; Modulo division safety checks
    mov ecx, [val_b]
    cmp ecx, 0
    je .div_zero_err

    push dword [val_b]
    push dword [val_a]
    call _math_mod
    add esp, 8
    jmp .display_result

.do_pow:
    push dword [val_b]
    push dword [val_a]
    call _math_pow
    add esp, 8
    jmp .display_result

; ------------------------------------------------------------------------------
; Post-calculation and error handlers
; ------------------------------------------------------------------------------
.display_result:
    ; Save result to ANS
    mov [ans_val], eax
    mov dword [has_ans], 1

    ; Convert ans_val to output buffer
    push buf_output
    push eax
    call _itoa_conv
    add esp, 8

    ; Print formatted output
    push CLR_SUCCESS
    call _print_str
    push msg_result_prefix
    call _print_str
    push buf_output
    call _print_str
    push msg_newline
    call _print_str
    push CLR_RESET
    call _print_str
    add esp, 20
    
    jmp .menu_loop

.ans_empty_err:
    push CLR_ERROR
    call _print_str
    push msg_err_ans_empty
    call _print_str
    push CLR_RESET
    call _print_str
    add esp, 12
    jmp .menu_loop

.operand_error:
    push CLR_ERROR
    call _print_str
    push msg_err_num
    call _print_str
    push CLR_RESET
    call _print_str
    add esp, 12
    jmp .menu_loop

.div_zero_err:
    push CLR_ERROR
    call _print_str
    push msg_err_div_zero
    call _print_str
    push CLR_RESET
    call _print_str
    add esp, 12
    jmp .menu_loop

; ------------------------------------------------------------------------------
; Helper: check_ans_keyword(const char *buf) -> returns 1 if "ans"/"ANS", else 0
; ------------------------------------------------------------------------------
_check_ans_keyword:
    push ebp
    mov ebp, esp
    push esi

    mov esi, [ebp + 8]   ; Buffer

    ; Character 0: 'a' or 'A'
    mov al, [esi]
    cmp al, 'a'
    je .char1
    cmp al, 'A'
    je .char1
    jmp .false

.char1:
    ; Character 1: 'n' or 'N'
    mov al, [esi+1]
    cmp al, 'n'
    je .char2
    cmp al, 'N'
    je .char2
    jmp .false

.char2:
    ; Character 2: 's' or 'S'
    mov al, [esi+2]
    cmp al, 's'
    je .char3
    cmp al, 'S'
    je .char3
    jmp .false

.char3:
    ; Character 3: null terminator
    mov al, [esi+3]
    cmp al, 0
    jne .false

    mov eax, 1           ; Match
    jmp .done

.false:
    xor eax, eax         ; No match

.done:
    pop esi
    pop ebp
    ret
