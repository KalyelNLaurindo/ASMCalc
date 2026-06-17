; ==============================================================================
;                      ASMCalc - Input/Output Engine (x86 32-bit)
; ==============================================================================
; Author: Kalyel N. Laurindo / Software Engineer
; Date: 2026-06-17
; Description: Character and string conversion routines linked with standard 
;              C Runtime Library (msvcrt.dll) for console interface.
; ==============================================================================

bits 32

section .data
    ; Format specifier for printing strings
    fmt_str db "%s", 0

section .text

; Libc external functions
extern _printf
extern _getchar
extern _fflush

; Exported symbols
global _atoi_conv
global _itoa_conv
global _print_str
global _read_str

; ------------------------------------------------------------------------------
; atoi_conv(const char *str, int *out_val) -> returns 0 on success, -1 on error
; ------------------------------------------------------------------------------
_atoi_conv:
    push ebp
    mov ebp, esp

    ; Preserve registers
    push ebx
    push esi
    push edi

    mov esi, [ebp + 8]    ; esi = str
    mov edi, [ebp + 12]   ; edi = out_val (pointer)

    ; Initialize
    xor eax, eax          ; Current parsed value = 0
    xor ecx, ecx          ; Sign indicator (0 = positive, 1 = negative)
    xor edx, edx          ; Digit count

    ; Skip leading spaces
.skip_spaces:
    movzx ebx, byte [esi]
    cmp ebx, ' '
    je .next_space
    cmp ebx, 9            ; '\t'
    je .next_space
    jmp .check_sign

.next_space:
    inc esi
    jmp .skip_spaces

.check_sign:
    cmp ebx, '-'
    je .is_negative
    cmp ebx, '+'
    je .is_positive
    jmp .parse_digits

.is_negative:
    mov ecx, 1
    inc esi
    jmp .load_next

.is_positive:
    inc esi

.load_next:
    movzx ebx, byte [esi]

.parse_digits:
    ; Check if string is empty/finished
    test ebx, ebx
    jz .check_empty

    ; Validate it's a decimal digit
    cmp ebx, '0'
    jl .check_trailing_whitespace
    cmp ebx, '9'
    jg .check_trailing_whitespace

    ; Convert char to numeric value
    sub ebx, '0'
    inc edx               ; Increment digit count

    ; Guard against overflow: value = value * 10 + digit
    ; Check if multiplying by 10 overflows
    imul eax, 10
    jo .overflow_err      ; Jump if signed overflow occurs

    ; Add new digit
    add eax, ebx
    jo .overflow_err      ; Jump if signed overflow occurs

    inc esi
    movzx ebx, byte [esi]
    jmp .parse_digits

.check_trailing_whitespace:
    test edx, edx         ; Did we parse any digits?
    jz .invalid_char      ; No digits parsed is an error

.whitespace_loop:
    movzx ebx, byte [esi]
    test ebx, ebx
    jz .apply_sign        ; Success: reached end of string

    cmp ebx, ' '
    je .next_whitespace
    cmp ebx, 9            ; '\t'
    je .next_whitespace
    cmp ebx, 10           ; '\n'
    je .next_whitespace
    cmp ebx, 13           ; '\r'
    je .next_whitespace
    jmp .invalid_char     ; Any other char is invalid

.next_whitespace:
    inc esi
    jmp .whitespace_loop

.check_empty:
    test edx, edx         ; Did we parse any digits?
    jz .invalid_char      ; No digits parsed is an error
    jmp .apply_sign

.invalid_char:
    mov eax, -1
    jmp .done

.overflow_err:
    mov eax, -1
    jmp .done

.apply_sign:
    test ecx, ecx
    jz .store_val
    neg eax               ; Apply negative sign

.store_val:
    mov [edi], eax        ; Save to out_val pointer
    xor eax, eax          ; Return 0 (success)

.done:
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

section .text

; ------------------------------------------------------------------------------
; itoa_conv(int val, char *buffer) -> converts integer to null-terminated string
; ------------------------------------------------------------------------------
_itoa_conv:
    push ebp
    mov ebp, esp

    push ebx
    push esi
    push edi

    mov eax, [ebp + 8]    ; val
    mov edi, [ebp + 12]   ; buffer pointer
    mov esi, edi          ; Save start of buffer

    ; Check if value is zero
    cmp eax, 0
    jne .check_negative
    mov byte [edi], '0'
    mov byte [edi + 1], 0
    jmp .done

.check_negative:
    cmp eax, 0
    jge .start_conversion
    mov byte [edi], '-'   ; Add negative prefix
    inc edi
    neg eax               ; Make positive

.start_conversion:
    xor ecx, ecx          ; Count of digits pushed onto stack
    mov ebx, 10           ; Divisor

.div_loop:
    test eax, eax
    jz .pop_digits
    xor edx, edx          ; Clear EDX for unsigned div
    div ebx               ; EAX = quotient, EDX = remainder
    add edx, '0'          ; Convert remainder to ASCII char
    push edx              ; Push digit char onto stack
    inc ecx
    jmp .div_loop

.pop_digits:
    test ecx, ecx
    jz .null_terminate
    pop edx
    mov [edi], dl
    inc edi
    dec ecx
    jmp .pop_digits

.null_terminate:
    mov byte [edi], 0     ; Null-terminate string

.done:
    pop edi
    pop esi
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
