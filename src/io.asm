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
    fmt_str   db "%s", 0
    fmt_float db "%.2f", 0

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

; ------------------------------------------------------------------------------
; atof_conv(const char *str, double *out_val) -> returns 0 on success, -1 on error
; ------------------------------------------------------------------------------
_atof_conv:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi

    mov esi, [ebp + 8]    ; esi = str
    mov edi, [ebp + 12]   ; edi = out_val (pointer)

    ; Skip leading spaces
.skip_leading:
    movzx ebx, byte [esi]
    cmp ebx, ' '
    je .next_leading
    cmp ebx, 9            ; '\t'
    je .next_leading
    jmp .check_sign

.next_leading:
    inc esi
    jmp .skip_leading

.check_sign:
    cmp ebx, '-'
    je .has_sign
    cmp ebx, '+'
    je .has_sign
    jmp .check_digits_start

.has_sign:
    inc esi
    movzx ebx, byte [esi]

.check_digits_start:
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
    ; Call atof(str)
    push dword [ebp + 8]
    call _atof
    add esp, 4            ; Double result is now in ST(0)

    ; Store ST(0) (double) into *out_val
    mov eax, [ebp + 12]   ; out_val pointer
    fstp qword [eax]      ; Store qword and pop FPU stack
    
    xor eax, eax          ; Return 0 (success)

.done:
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

; ------------------------------------------------------------------------------
; ftoa_conv(double val, char *buffer) -> formats double to string via sprintf
; ------------------------------------------------------------------------------
_ftoa_conv:
    push ebp
    mov ebp, esp
    push ebx

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
