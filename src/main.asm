; ==============================================================================
;                      ASMCalc - Main CLI Application (x86 32-bit FPU)
; ==============================================================================
; Author: Kalyel N. Laurindo / Software Engineer
; Date: 2026-06-17
; Description: Router and interactive user interface loop supporting doubles,
;              complex numbers, and rational fractions.
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
    msg_ans_empty db "N/A", 0
    msg_mode_real db " (Mode: Real)", 10, 0
    msg_mode_comp db " (Mode: Complex)", 10, 0
    msg_mode_frac db " (Mode: Fraction)", 10, 0
    msg_menu_line db "-----------------------------------------------", 10, 0
    msg_menu_opt1 db "  1. Add (+)", 10, 0
    msg_menu_opt2 db "  2. Subtract (-)", 10, 0
    msg_menu_opt3 db "  3. Multiply (*)", 10, 0
    msg_menu_opt4 db "  4. Divide (/)", 10, 0
    msg_menu_opt5 db "  5. Modulo (%)", 10, 0
    msg_menu_opt6 db "  6. Power (^)", 10, 0
    msg_menu_opt7 db "  7. Clear ANS Register", 10, 0
    msg_menu_opt8 db "  8. Toggle Mode (Real/Complex/Fraction)", 10, 0
    msg_menu_opt9 db "  9. Exit Program", 10, 0
    msg_menu_prompt db "  Choose Option (1-9): ", 0

    ; Prompt Strings
    msg_prompt_a db "  Enter Operand A: ", 0
    msg_prompt_b db "  Enter Operand B: ", 0
    msg_hint_ans db " (type 'ans' to reuse last result)", 0
    msg_newline db 10, 0

    ; Result and Error Strings
    msg_result_prefix db "  Result: ", 0
    msg_err_invalid   db "  [ERROR] Invalid option! Please enter 1-9.", 10, 0
    msg_err_num       db "  [ERROR] Invalid numeric format or overflow!", 10, 0
    msg_err_div_zero  db "  [ERROR] Division by zero is undefined!", 10, 0
    msg_err_ans_empty db "  [ERROR] ANS register is empty!", 10, 0
    msg_err_unsupp    db "  [ERROR] Modulo and Power are only supported in Real mode!", 10, 0
    msg_exit_greeting db "  Goodbye! Thanks for using ASMCalc.", 10, 0

    ; ANS Register State
    has_ans dd 0
    ans_val dq 0.0
    ans_val_imag dq 0.0
    ans_val_num dd 0
    ans_val_den dd 1

    ; Calculation Mode (0 = Real, 1 = Complex, 2 = Fraction)
    calc_mode dd 0

section .bss
    ; Input Buffers
    buf_option resb 16
    buf_operand resb 64
    buf_output resb 64
    val_a resq 1
    val_a_imag resq 1
    val_a_num resd 1
    val_a_den resd 1
    
    val_b resq 1
    val_b_imag resq 1
    val_b_num resd 1
    val_b_den resd 1
    
    val_opt resd 1

section .text

; External standard math subroutines
extern _math_add
extern _math_sub
extern _math_imul
extern _math_idiv
extern _math_mod
extern _math_pow
extern _math_complex_add
extern _math_complex_sub
extern _math_complex_mul
extern _math_complex_div
extern _math_fraction_add
extern _math_fraction_sub
extern _math_fraction_mul
extern _math_fraction_div

; External Input/Output Subroutines
extern _print_str
extern _read_str
extern _atof_conv
extern _ftoa_conv
extern _atoi_conv
extern _parse_complex
extern _format_complex
extern _parse_fraction
extern _format_fraction

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

    ; Print ANS Register status prefix
    push msg_ans_label
    call _print_str
    add esp, 4

    mov eax, [has_ans]
    test eax, eax
    jz .print_ans_na

    ; Convert active ans to string based on mode
    mov eax, [calc_mode]
    cmp eax, 1
    je .print_ans_complex
    cmp eax, 2
    je .print_ans_fraction

    ; Real Mode printing
    push buf_output
    push dword [ans_val + 4]
    push dword [ans_val]
    call _ftoa_conv
    add esp, 12
    jmp .print_ans_value

.print_ans_complex:
    push buf_output
    push dword [ans_val_imag + 4]
    push dword [ans_val_imag]
    push dword [ans_val + 4]
    push dword [ans_val]
    call _format_complex
    add esp, 20
    jmp .print_ans_value

.print_ans_fraction:
    push buf_output
    push dword [ans_val_den]
    push dword [ans_val_num]
    call _format_fraction
    add esp, 12

.print_ans_value:
    push CLR_SUCCESS
    call _print_str
    push buf_output
    call _print_str
    push CLR_RESET
    call _print_str
    add esp, 12
    jmp .print_mode_suffix

.print_ans_na:
    push msg_ans_empty
    call _print_str
    add esp, 4

.print_mode_suffix:
    ; Print Mode Suffix
    mov eax, [calc_mode]
    cmp eax, 1
    je .print_mode_comp_suff
    cmp eax, 2
    je .print_mode_frac_suff

    push msg_mode_real
    call _print_str
    add esp, 4
    jmp .print_menu_body

.print_mode_comp_suff:
    push msg_mode_comp
    call _print_str
    add esp, 4
    jmp .print_menu_body

.print_mode_frac_suff:
    push msg_mode_frac
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
    push msg_menu_opt9
    call _print_str
    push msg_menu_line
    call _print_str
    add esp, 44

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

    ; Validate range 1-9
    mov eax, [val_opt]
    cmp eax, 1
    jl .invalid_option
    cmp eax, 9
    jg .invalid_option

    ; Check for Exit (9)
    cmp eax, 9
    je .exit_prog

    ; Check for Toggle Mode (8)
    cmp eax, 8
    je .toggle_mode

    ; Check for Clear ANS (7)
    cmp eax, 7
    je .clear_ans

    ; It's a math operation (1 to 6). Check if Modulo/Power are chosen in complex/fraction modes
    mov edx, [calc_mode]
    test edx, edx
    jz .prompt_operand_a ; Real mode supports everything

    cmp eax, 5
    jge .unsupported_operation_error

    ; Proceed to Operand A
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

.unsupported_operation_error:
    push CLR_ERROR
    call _print_str
    push msg_err_unsupp
    call _print_str
    push CLR_RESET
    call _print_str
    add esp, 12
    jmp .menu_loop

.clear_ans:
    mov dword [has_ans], 0
    fldz
    fstp qword [ans_val]
    fldz
    fstp qword [ans_val_imag]
    mov dword [ans_val_num], 0
    mov dword [ans_val_den], 1
    push CLR_SUCCESS
    call _print_str
    push msg_menu_line
    call _print_str
    push CLR_RESET
    call _print_str
    add esp, 12
    jmp .menu_loop

.toggle_mode:
    mov eax, [calc_mode]
    inc eax
    cmp eax, 3
    jl .save_mode
    xor eax, eax
.save_mode:
    mov [calc_mode], eax
    mov dword [has_ans], 0 ; Clear ANS to prevent cross-mode pollution
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

    mov edx, [calc_mode]
    cmp edx, 1
    je .ans_a_complex
    cmp edx, 2
    je .ans_a_fraction

    ; Real ANS
    fld qword [ans_val]
    fstp qword [val_a]
    jmp .prompt_operand_b

.ans_a_complex:
    fld qword [ans_val]
    fstp qword [val_a]
    fld qword [ans_val_imag]
    fstp qword [val_a_imag]
    jmp .prompt_operand_b

.ans_a_fraction:
    mov eax, [ans_val_num]
    mov [val_a_num], eax
    mov eax, [ans_val_den]
    mov [val_a_den], eax
    jmp .prompt_operand_b

.parse_a_normally:
    mov edx, [calc_mode]
    cmp edx, 1
    je .parse_a_complex
    cmp edx, 2
    je .parse_a_fraction

    ; Parse Real A
    push val_a
    push buf_operand
    call _atof_conv
    add esp, 8
    test eax, eax
    jnz .operand_error
    jmp .prompt_operand_b

.parse_a_complex:
    push val_a_imag
    push val_a
    push buf_operand
    call _parse_complex
    add esp, 12
    test eax, eax
    jnz .operand_error
    jmp .prompt_operand_b

.parse_a_fraction:
    push val_a_den
    push val_a_num
    push buf_operand
    call _parse_fraction
    add esp, 12
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

    mov edx, [calc_mode]
    cmp edx, 1
    je .ans_b_complex
    cmp edx, 2
    je .ans_b_fraction

    ; Real ANS
    fld qword [ans_val]
    fstp qword [val_b]
    jmp .execute_calculation

.ans_b_complex:
    fld qword [ans_val]
    fstp qword [val_b]
    fld qword [ans_val_imag]
    fstp qword [val_b_imag]
    jmp .execute_calculation

.ans_b_fraction:
    mov eax, [ans_val_num]
    mov [val_b_num], eax
    mov eax, [ans_val_den]
    mov [val_b_den], eax
    jmp .execute_calculation

.parse_b_normally:
    mov edx, [calc_mode]
    cmp edx, 1
    je .parse_b_complex
    cmp edx, 2
    je .parse_b_fraction

    ; Parse Real B
    push val_b
    push buf_operand
    call _atof_conv
    add esp, 8
    test eax, eax
    jnz .operand_error
    jmp .execute_calculation

.parse_b_complex:
    push val_b_imag
    push val_b
    push buf_operand
    call _parse_complex
    add esp, 12
    test eax, eax
    jnz .operand_error
    jmp .execute_calculation

.parse_b_fraction:
    push val_b_den
    push val_b_num
    push buf_operand
    call _parse_fraction
    add esp, 12
    test eax, eax
    jnz .operand_error

; ------------------------------------------------------------------------------
; Execute Operation
; ------------------------------------------------------------------------------
.execute_calculation:
    mov edx, [calc_mode]
    cmp edx, 1
    je .execute_complex
    cmp edx, 2
    je .execute_fraction

    ; Real Mode Execution
    mov eax, [val_opt]
    cmp eax, 1
    je .real_add
    cmp eax, 2
    je .real_sub
    cmp eax, 3
    je .real_mul
    cmp eax, 4
    je .real_div
    cmp eax, 5
    je .real_mod
    cmp eax, 6
    je .real_pow
    jmp .menu_loop

.real_add:
    push dword [val_b + 4]
    push dword [val_b]
    push dword [val_a + 4]
    push dword [val_a]
    call _math_add
    add esp, 16
    jmp .store_real_result

.real_sub:
    push dword [val_b + 4]
    push dword [val_b]
    push dword [val_a + 4]
    push dword [val_a]
    call _math_sub
    add esp, 16
    jmp .store_real_result

.real_mul:
    push dword [val_b + 4]
    push dword [val_b]
    push dword [val_a + 4]
    push dword [val_a]
    call _math_imul
    add esp, 16
    jmp .store_real_result

.real_div:
    push dword [val_b + 4]
    push dword [val_b]
    push dword [val_a + 4]
    push dword [val_a]
    call _math_idiv
    add esp, 16
    jmp .store_real_result

.real_mod:
    push dword [val_b + 4]
    push dword [val_b]
    push dword [val_a + 4]
    push dword [val_a]
    call _math_mod
    add esp, 16
    jmp .store_real_result

.real_pow:
    push dword [val_b + 4]
    push dword [val_b]
    push dword [val_a + 4]
    push dword [val_a]
    call _math_pow
    add esp, 16

.store_real_result:
    fstp qword [ans_val]
    
    ; Check if NaN
    fld qword [ans_val]
    fld st0
    fucomip st1
    fstp st0
    jp .nan_error
    
    mov dword [has_ans], 1
    
    push buf_output
    push dword [ans_val + 4]
    push dword [ans_val]
    call _ftoa_conv
    add esp, 12
    jmp .print_result

.execute_complex:
    mov eax, [val_opt]
    cmp eax, 1
    je .complex_add
    cmp eax, 2
    je .complex_sub
    cmp eax, 3
    je .complex_mul
    cmp eax, 4
    je .complex_div
    jmp .menu_loop

.complex_add:
    push val_b
    push val_a
    push ans_val
    call _math_complex_add
    add esp, 12
    jmp .store_complex_result

.complex_sub:
    push val_b
    push val_a
    push ans_val
    call _math_complex_sub
    add esp, 12
    jmp .store_complex_result

.complex_mul:
    push val_b
    push val_a
    push ans_val
    call _math_complex_mul
    add esp, 12
    jmp .store_complex_result

.complex_div:
    push val_b
    push val_a
    push ans_val
    call _math_complex_div
    add esp, 12

.store_complex_result:
    ; Check if real or imag part is NaN
    fld qword [ans_val]
    fld st0
    fucomip st1
    fstp st0
    jp .nan_error

    fld qword [ans_val_imag]
    fld st0
    fucomip st1
    fstp st0
    jp .nan_error

    mov dword [has_ans], 1

    push buf_output
    push dword [ans_val_imag + 4]
    push dword [ans_val_imag]
    push dword [ans_val + 4]
    push dword [ans_val]
    call _format_complex
    add esp, 20
    jmp .print_result

.execute_fraction:
    mov eax, [val_opt]
    cmp eax, 1
    je .fraction_add
    cmp eax, 2
    je .fraction_sub
    cmp eax, 3
    je .fraction_mul
    cmp eax, 4
    je .fraction_div
    jmp .menu_loop

.fraction_add:
    push val_b_num
    push val_a_num
    push ans_val_num
    call _math_fraction_add
    add esp, 12
    jmp .store_fraction_result

.fraction_sub:
    push val_b_num
    push val_a_num
    push ans_val_num
    call _math_fraction_sub
    add esp, 12
    jmp .store_fraction_result

.fraction_mul:
    push val_b_num
    push val_a_num
    push ans_val_num
    call _math_fraction_mul
    add esp, 12
    jmp .store_fraction_result

.fraction_div:
    push val_b_num
    push val_a_num
    push ans_val_num
    call _math_fraction_div
    add esp, 12

.store_fraction_result:
    ; Check if denominator is 0 (division by zero error)
    mov eax, [ans_val_den]
    test eax, eax
    jz .nan_error

    mov dword [has_ans], 1

    push buf_output
    push dword [ans_val_den]
    push dword [ans_val_num]
    call _format_fraction
    add esp, 12

.print_result:
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

.nan_error:
    mov dword [has_ans], 0
    push CLR_ERROR
    call _print_str
    push msg_err_div_zero
    call _print_str
    push CLR_RESET
    call _print_str
    add esp, 12
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
