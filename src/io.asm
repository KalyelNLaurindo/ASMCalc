; ==============================================================================
;                      ASMCalc - Input/Output Engine (x86 32-bit FPU)
; ==============================================================================
; Author: Kalyel N. Laurindo / Software Engineer
; Date: 2026-06-17
; Description: Character and double-precision string conversion routines linked 
;              with standard C Runtime Library (msvcrt.dll) for FPU interface.
; ==============================================================================

bits 32

section .data
    fmt_str         db "%s", 0
    fmt_float       db "%.2f", 0
    fmt_complex_pos db "%.2f + %.2fi", 0
    fmt_complex_neg db "%.2f - %.2fi", 0
    fmt_frac        db "%d/%d", 0
    fmt_int         db "%d", 0

section .text

; Libc external functions
extern _printf
extern _getchar
extern _fflush
extern _atof
extern _sprintf
extern _atoi

; Exported symbols
global _atoi_conv
global _atof_conv
global _ftoa_conv
global _print_str
global _read_str
global _parse_complex
global _format_complex
global _parse_fraction
global _format_fraction

; ------------------------------------------------------------------------------
; atof_conv(const char *str, double *out_val) -> returns 0 on success, -1 on error
; ------------------------------------------------------------------------------
_atof_conv:
    push ebp
    mov ebp, esp
    sub esp, 8            ; [ebp - 4] = cumulative sign, [ebp - 8] = start of digits
    push ebx
    push esi
    push edi

    mov dword [ebp - 4], 1 ; Default sign is positive (1)
    mov esi, [ebp + 8]    ; esi = str
    mov edi, [ebp + 12]   ; edi = out_val (pointer)

.parse_signs_and_spaces:
    movzx ebx, byte [esi]
    cmp ebx, ' '
    je .is_space
    cmp ebx, 9            ; '\t'
    je .is_space
    cmp ebx, '-'
    je .is_minus
    cmp ebx, '+'
    je .is_plus
    jmp .check_digits_start

.is_space:
    inc esi
    jmp .parse_signs_and_spaces

.is_minus:
    neg dword [ebp - 4]   ; Toggle sign
    inc esi
    jmp .parse_signs_and_spaces

.is_plus:
    inc esi               ; Plus does not change cumulative sign
    jmp .parse_signs_and_spaces

.check_digits_start:
    mov [ebp - 8], esi    ; Save start of digits pointer
    xor ecx, ecx          ; Digit counter = 0
    xor edx, edx          ; Dot counter = 0

.parse_loop:
    cmp ebx, '.'
    je .handle_dot

    cmp ebx, '0'
    jl .check_trailing
    cmp ebx, '9'
    jg .check_trailing

    inc ecx               ; Increment digit counter
    inc esi
    movzx ebx, byte [esi]
    jmp .parse_loop

.handle_dot:
    inc edx               ; Increment dot counter
    cmp edx, 1
    jg .invalid           ; More than one dot is invalid
    inc esi
    movzx ebx, byte [esi]
    jmp .parse_loop

.check_trailing:
    ; Must have parsed at least one digit
    test ecx, ecx
    jz .invalid

.skip_trailing:
    test ebx, ebx         ; End of string?
    jz .valid

    cmp ebx, ' '
    je .next_trailing
    cmp ebx, 9            ; '\t'
    je .next_trailing
    cmp ebx, 10           ; '\n'
    je .next_trailing
    cmp ebx, 13           ; '\r'
    je .next_whitespace
    jmp .invalid          ; Any other char at the end is invalid

.next_whitespace:
    ; Treat carriage return like standard whitespace and ignore it
    inc esi
    movzx ebx, byte [esi]
    jmp .skip_trailing

.next_trailing:
    inc esi
    movzx ebx, byte [esi]
    jmp .skip_trailing

.invalid:
    mov eax, -1
    jmp .done

.valid:
    ; Call atof(start_of_digits)
    push dword [ebp - 8]
    call _atof
    add esp, 4            ; Double result is now in ST(0)

    ; Apply cumulative sign
    cmp dword [ebp - 4], -1
    jne .store_result
    fchs                  ; Negate ST(0)

.store_result:
    ; Store ST(0) (double) into *out_val
    mov eax, [ebp + 12]   ; out_val pointer
    fstp qword [eax]      ; Store qword and pop FPU stack
    
    xor eax, eax          ; Return 0 (success)

.done:
    pop edi
    pop esi
    pop ebx
    mov esp, ebp          ; Clean up local variables
    pop ebp
    ret

; ------------------------------------------------------------------------------
; ftoa_conv(double val, char *buffer) -> formats double to string via sprintf
; ------------------------------------------------------------------------------
_ftoa_conv:
    push ebp
    mov ebp, esp
    push ebx

    ; Compare val with 0.0 to handle negative zero
    fld qword [ebp + 8]
    fldz
    fucomip st1
    fstp st0
    jne .not_zero
    ; If it is zero, clear sign bit (overwrite both halves with 0)
    mov dword [ebp + 8], 0
    mov dword [ebp + 12], 0

.not_zero:
    push dword [ebp + 12] ; val (high 32-bit)
    push dword [ebp + 8]  ; val (low 32-bit)
    push fmt_float        ; "%f"
    push dword [ebp + 16] ; buffer
    call _sprintf
    add esp, 16

    pop ebx
    pop ebp
    ret

; ------------------------------------------------------------------------------
; print_str(const char *str) -> prints string to standard output using printf
; ------------------------------------------------------------------------------
_print_str:
    push ebp
    mov ebp, esp

    push ebx              ; Preserve non-volatile

    mov eax, [ebp + 8]    ; str pointer
    push eax
    push fmt_str          ; "%s" format
    call _printf
    add esp, 8            ; Clean caller stack

    ; Call fflush(NULL) to flush stdout immediately
    push 0
    call _fflush
    add esp, 4

    pop ebx
    pop ebp
    ret

; ------------------------------------------------------------------------------
; read_str(char *buffer, int max_len) -> reads line from console using getchar
; ------------------------------------------------------------------------------
_read_str:
    push ebp
    mov ebp, esp

    push ebx
    push edi

    mov edi, [ebp + 8]    ; buffer
    mov ebx, [ebp + 12]   ; max_len
    dec ebx               ; Leave room for null terminator
    xor ecx, ecx          ; Char counter = 0

.loop:
    cmp ecx, ebx
    jge .done

    push ecx              ; Preserve counter
    call _getchar
    pop ecx               ; Restore counter

    cmp eax, -1           ; Check EOF
    je .done_eof
    cmp eax, 10           ; Check LF ('\n')
    je .done
    cmp eax, 13           ; Check CR ('\r')
    je .loop              ; Ignore CR

    mov [edi + ecx], al   ; Store character
    inc ecx
    jmp .loop

.done_eof:
    test ecx, ecx
    jnz .done
    mov eax, -1           ; Return -1 on immediate EOF
    jmp .exit

.done:
    mov byte [edi + ecx], 0 ; Null-terminate
    mov eax, ecx          ; Return number of characters read

.exit:
    pop edi
    pop ebx
    pop ebp
    ret

; ------------------------------------------------------------------------------
; atoi_conv(const char *str, int *out_val) -> parses integer via libc atoi
; ------------------------------------------------------------------------------
_atoi_conv:
    push ebp
    mov ebp, esp

    push dword [ebp + 8]   ; str
    call _atoi
    add esp, 4             ; EAX has the parsed integer

    mov ecx, [ebp + 12]    ; out_val pointer
    mov [ecx], eax         ; Store result

    xor eax, eax           ; Return 0 for success
    pop ebp
    ret

; ; ------------------------------------------------------------------------------
; parse_complex(const char *str, double *out_real, double *out_imag) -> 0 on success, -1 on error
; ------------------------------------------------------------------------------
_parse_complex:
    push ebp
    mov ebp, esp
    sub esp, 128          ; [ebp - 128] = real_buf (64 bytes), [ebp - 64] = imag_buf (64 bytes)
    push ebx
    push esi
    push edi

    mov esi, [ebp + 8]    ; str
    mov edi, [ebp + 12]   ; out_real (pointer)
    mov ecx, [ebp + 16]   ; out_imag (pointer)

    ; 1. Find if 'i' or 'I' exists in the string
    mov edx, esi
.find_i:
    movzx eax, byte [edx]
    test eax, eax
    jz .no_imag_part      ; Reached end of string, no 'i'
    cmp eax, 'i'
    je .has_imag_part
    cmp eax, 'I'
    je .has_imag_part
    inc edx
    jmp .find_i

.no_imag_part:
    ; Purely real
    ; out_imag = 0.0
    fldz
    mov eax, [ebp + 16]
    fstp qword [eax]
    ; Parse real part
    push dword [ebp + 12] ; out_real
    push esi              ; str
    call _atof_conv
    add esp, 8
    jmp .done

.has_imag_part:
    ; We have 'i'. edx points to 'i'.
    ; 2. Let's find the last separating '+' or '-' before 'i'.
    mov ebx, edx
.find_separator:
    cmp ebx, esi
    je .pure_imaginary    ; Back to start of string, no separator found
    dec ebx
    cmp ebx, esi          ; Is it the first character?
    je .pure_imaginary    ; If it is the first character, it cannot be a separator
    movzx eax, byte [ebx]
    cmp eax, '+'
    je .found_separator
    cmp eax, '-'
    je .found_separator
    jmp .find_separator

.pure_imaginary:
    ; Purely imaginary: out_real = 0.0
    fldz
    mov eax, [ebp + 12]
    fstp qword [eax]
    ; Copy from esi to imag_buf, excluding 'i'
    lea edi, [ebp - 64]   ; imag_buf
    mov ecx, esi          ; source
.copy_pure_imag:
    cmp ecx, edx          ; until we reach 'i'
    je .terminate_pure_imag
    mov al, [ecx]
    mov [edi], al
    inc ecx
    inc edi
    jmp .copy_pure_imag
.terminate_pure_imag:
    mov byte [edi], 0
    jmp .parse_imag_only

.found_separator:
    ; Separator found at ebx.
    ; Copy real part from esi to ebx (exclusive) into real_buf
    lea edi, [ebp - 128]  ; real_buf
    mov ecx, esi
.copy_real_part:
    cmp ecx, ebx
    je .terminate_real_part
    mov al, [ecx]
    mov [edi], al
    inc ecx
    inc edi
    jmp .copy_real_part
.terminate_real_part:
    mov byte [edi], 0

    ; Parse real part from real_buf
    push edx              ; preserve pointer to 'i'
    push dword [ebp + 12] ; out_real
    lea eax, [ebp - 128]  ; real_buf
    push eax
    call _atof_conv
    add esp, 8
    pop edx               ; restore pointer to 'i'
    test eax, eax
    jnz .error            ; if real parse failed, error

    ; Copy imaginary part starting at ebx to edx (exclusive) into imag_buf
    lea edi, [ebp - 64]   ; imag_buf
    mov ecx, ebx
.copy_imag_part:
    cmp ecx, edx
    je .terminate_imag_part
    mov al, [ecx]
    mov [edi], al
    inc ecx
    inc edi
    jmp .copy_imag_part
.terminate_imag_part:
    mov byte [edi], 0

.parse_imag_only:
    ; Parse imaginary part float from imag_buf
    lea edi, [ebp - 64]
.skip_spaces_pure:
    movzx eax, byte [edi]
    cmp eax, ' '
    je .next_space_pure
    cmp eax, 9
    je .next_space_pure
    jmp .check_pure_sign
.next_space_pure:
    inc edi
    jmp .skip_spaces_pure

.check_pure_sign:
    movzx eax, byte [edi]
    test eax, eax
    jz .imag_one
    cmp eax, '+'
    jne .check_pure_minus
    movzx eax, byte [edi + 1]
    test eax, eax
    jz .imag_one
.check_pure_minus:
    cmp eax, '-'
    jne .parse_imag_float
    movzx eax, byte [edi + 1]
    test eax, eax
    jz .imag_minus_one

.parse_imag_float:
    push dword [ebp + 16] ; out_imag
    push edi              ; pointer to start of imag float
    call _atof_conv
    add esp, 8
    jmp .done

.imag_one:
    fld1
    mov eax, [ebp + 16]
    fstp qword [eax]
    xor eax, eax          ; success
    jmp .done

.imag_minus_one:
    fld1
    fchs
    mov eax, [ebp + 16]
    fstp qword [eax]
    xor eax, eax          ; success
    jmp .done

.error:
    mov eax, -1

.done:
    pop edi
    pop esi
    pop ebx
    mov esp, ebp
    pop ebp
    ret

; ------------------------------------------------------------------------------
; format_complex(double real, double imag, char *buffer)
; ------------------------------------------------------------------------------
_format_complex:
    push ebp
    mov ebp, esp
    push ebx

    mov ebx, [ebp + 24]   ; buffer
    
    ; Check if imag is negative
    fld qword [ebp + 16]  ; ST(0) = imag
    fldz
    fucomip st1
    fstp st0              ; Pop imag
    ja .imag_negative

    ; Imag is positive or zero
    ; sprintf(buffer, "%.2f + %.2fi", real, imag)
    push dword [ebp + 20] ; imag high
    push dword [ebp + 16] ; imag low
    push dword [ebp + 12] ; real high
    push dword [ebp + 8]  ; real low
    push fmt_complex_pos  ; "%.2f + %.2fi"
    push ebx              ; buffer
    call _sprintf
    add esp, 24
    jmp .done_fmt

.imag_negative:
    ; Imag is negative. Negate imag on stack to print positive
    fld qword [ebp + 16]
    fchs
    sub esp, 8
    fstp qword [esp]      ; Store absolute imag on stack
    
    push dword [ebp + 12] ; real high
    push dword [ebp + 8]  ; real low
    push fmt_complex_neg  ; "%.2f - %.2fi"
    push ebx              ; buffer
    call _sprintf
    add esp, 24

.done_fmt:
    pop ebx
    pop ebp
    ret

; ------------------------------------------------------------------------------
; parse_fraction(const char *str, int *out_num, int *out_den) -> 0 on success, -1 on error
; ------------------------------------------------------------------------------
_parse_fraction:
    push ebp
    mov ebp, esp
    sub esp, 128          ; [ebp - 128] = num_buf, [ebp - 64] = den_buf
    push ebx
    push esi
    push edi

    mov esi, [ebp + 8]    ; str
    mov edi, [ebp + 12]   ; out_num
    mov ecx, [ebp + 16]   ; out_den

    ; Find if '/' exists
    mov edx, esi
.find_slash:
    movzx eax, byte [edx]
    test eax, eax
    jz .no_slash
    cmp eax, '/'
    je .has_slash
    inc edx
    jmp .find_slash

.no_slash:
    ; Pure integer
    mov dword [ecx], 1    ; den = 1
    push edi              ; out_num
    push esi              ; str
    call _atoi_conv
    add esp, 8
    jmp .done_frac

.has_slash:
    ; Copy numerator from esi to edx (exclusive) into num_buf
    lea ebx, [ebp - 128]  ; num_buf
    mov ecx, esi
.copy_num:
    cmp ecx, edx
    je .terminate_num
    mov al, [ecx]
    mov [ebx], al
    inc ecx
    inc ebx
    jmp .copy_num
.terminate_num:
    mov byte [ebx], 0

    ; Parse numerator
    push edx              ; preserve pointer to '/'
    push edi              ; out_num
    lea ebx, [ebp - 128]  ; num_buf
    push ebx
    call _atoi_conv
    add esp, 8
    pop edx               ; restore pointer to '/'
    test eax, eax
    jnz .error_frac

    ; Copy denominator starting at edx + 1 to end of string into den_buf
    inc edx               ; past '/'
    lea ebx, [ebp - 64]   ; den_buf
    mov ecx, edx
.copy_den:
    mov al, [ecx]
    mov [ebx], al
    test al, al
    jz .terminate_den
    inc ecx
    inc ebx
    jmp .copy_den
.terminate_den:

    ; Parse denominator
    push dword [ebp + 16] ; out_den (pointer)
    lea ebx, [ebp - 64]   ; den_buf
    push ebx
    call _atoi_conv
    add esp, 8
    test eax, eax
    jnz .error_frac

    ; Check if denominator is 0
    mov ecx, [ebp + 16]   ; out_den pointer
    mov eax, [ecx]
    test eax, eax
    jz .error_frac
    xor eax, eax          ; success
    jmp .done_frac

.error_frac:
    mov eax, -1

.done_frac:
    pop edi
    pop esi
    pop ebx
    mov esp, ebp
    pop ebp
    ret

; ------------------------------------------------------------------------------
; format_fraction(int num, int den, char *buffer)
; ------------------------------------------------------------------------------
_format_fraction:
    push ebp
    mov ebp, esp
    push ebx

    mov eax, [ebp + 8]    ; num
    mov ecx, [ebp + 12]   ; den
    mov ebx, [ebp + 16]   ; buffer

    cmp ecx, 1
    je .pure_int

    push ecx
    push eax
    push fmt_frac
    push ebx
    call _sprintf
    add esp, 16
    jmp .done_fmt_frac

.pure_int:
    push eax
    push fmt_int
    push ebx
    call _sprintf
    add esp, 12

.done_fmt_frac:
    pop ebx
    pop ebp
    ret
