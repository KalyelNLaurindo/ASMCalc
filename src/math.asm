; ==============================================================================
;                      ASMCalc - Mathematics Engine (x86 32-bit)
; ==============================================================================
; Author: Kalyel N. Laurindo / Software Engineer
; Date: 2026-06-17
; Description: Signed 32-bit integer arithmetic routines implementing cdecl calling 
;              convention. High-risk routines contain safety guards against division exceptions.
; ==============================================================================

bits 32

section .text

; Export functions for C linker mapping (prefixed with underscore on Windows x86)
global _math_add
global _math_sub
global _math_imul
global _math_idiv
global _math_mod
global _math_pow

; ------------------------------------------------------------------------------
; math_add(int a, int b) -> returns (a + b) in EAX
; ------------------------------------------------------------------------------
_math_add:
    ; Establish stack frame
    push ebp
    mov ebp, esp

    ; Load operands
    mov eax, [ebp + 8]   ; Parameter a (offset +8 from stack base)
    add eax, [ebp + 12]  ; Parameter b (offset +12 from stack base)

    ; Restore stack frame and exit
    pop ebp
    ret

; ------------------------------------------------------------------------------
; math_sub(int a, int b) -> returns (a - b) in EAX
; ------------------------------------------------------------------------------
_math_sub:
    ; Establish stack frame
    push ebp
    mov ebp, esp

    ; Load operands
    mov eax, [ebp + 8]   ; Parameter a
    sub eax, [ebp + 12]  ; Parameter b (subtract b from a)

    ; Restore stack frame and exit
    pop ebp
    ret

; ------------------------------------------------------------------------------
; math_imul(int a, int b) -> returns (a * b) in EAX
; ------------------------------------------------------------------------------
_math_imul:
    ; Establish stack frame
    push ebp
    mov ebp, esp

    ; Load operands
    mov eax, [ebp + 8]   ; Parameter a
    imul eax, [ebp + 12] ; Signed multiply EAX by b. Result fits in EAX.

    ; Restore stack frame and exit
    pop ebp
    ret

; ------------------------------------------------------------------------------
; math_idiv(int a, int b) -> returns (a / b) in EAX (or -1 on division by zero)
; ------------------------------------------------------------------------------
_math_idiv:
    ; Establish stack frame
    push ebp
    mov ebp, esp

    ; Preserve EBX register since it is non-volatile in cdecl
    push ebx

    ; Load operands
    mov eax, [ebp + 8]   ; Parameter a (dividend)
    mov ebx, [ebp + 12]  ; Parameter b (divisor)

    ; Safety guard: Check for division by zero
    cmp ebx, 0
    je .err_div_zero

    ; Prepare EDX:EAX for division
    cdq                  ; Sign-extends EAX into EDX (handles negative dividends)
    idiv ebx             ; Divide EDX:EAX by EBX. EAX = quotient, EDX = remainder.
    jmp .done

.err_div_zero:
    ; Divisor was zero, return error sentinel (-1)
    mov eax, -1

.done:
    ; Restore non-volatile EBX
    pop ebx

    ; Restore stack frame and exit
    pop ebp
    ret

; ------------------------------------------------------------------------------
; math_mod(int a, int b) -> returns (a % b) in EAX (or -1 on division by zero)
; ------------------------------------------------------------------------------
_math_mod:
    ; Establish stack frame
    push ebp
    mov ebp, esp

    ; Preserve EBX register
    push ebx

    ; Load operands
    mov eax, [ebp + 8]   ; Parameter a (dividend)
    mov ebx, [ebp + 12]  ; Parameter b (divisor)

    ; Safety guard: Check for division by zero
    cmp ebx, 0
    je .err_div_zero

    ; Prepare EDX:EAX for division
    cdq                  ; Sign-extends EAX into EDX
    idiv ebx             ; Divide EDX:EAX by EBX. EAX = quotient, EDX = remainder.
    mov eax, edx         ; Move remainder (EDX) to return register (EAX)
    jmp .done

.err_div_zero:
    ; Divisor was zero, return error sentinel (-1)
    mov eax, -1

.done:
    ; Restore non-volatile EBX
    pop ebx

    ; Restore stack frame and exit
    pop ebp
    ret

; ------------------------------------------------------------------------------
; math_pow(int base, int exp) -> returns (base ^ exp) in EAX
; ------------------------------------------------------------------------------
_math_pow:
    ; Establish stack frame
    push ebp
    mov ebp, esp

    ; Preserve EBX and ECX
    push ebx
    push ecx

    ; Load operands
    mov eax, [ebp + 8]   ; base
    mov ecx, [ebp + 12]  ; exp

    ; Check if exp < 0
    cmp ecx, 0
    jl .neg_exp

    ; Check if exp == 0
    je .zero_exp

    ; If exp > 0, set up power loop
    mov ebx, eax         ; ebx = base
    mov eax, 1           ; result = 1

.loop:
    test ecx, ecx
    jz .done
    imul eax, ebx        ; result *= base
    dec ecx
    jmp .loop

.zero_exp:
    mov eax, 1           ; base^0 = 1
    jmp .done

.neg_exp:
    mov eax, 0           ; Integer division limits negative power to 0

.done:
    ; Restore registers
    pop ecx
    pop ebx
    pop ebp
    ret
