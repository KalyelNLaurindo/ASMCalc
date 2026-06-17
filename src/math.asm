; ==============================================================================
;                      ASMCalc - Mathematics Engine (x86 32-bit FPU)
; ==============================================================================
; Author: Kalyel N. Laurindo / Software Engineer
; Date: 2026-06-17
; Description: 64-bit Double Precision (REAL8) math subroutines utilizing 
;              the x87 FPU coprocessor stack and transcendental instructions.
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
; math_add(double a, double b) -> returns (a + b) in ST(0)
; ------------------------------------------------------------------------------
_math_add:
    push ebp
    mov ebp, esp

    fld qword [ebp + 8]     ; Load double a (offset +8 from stack base)
    fadd qword [ebp + 16]   ; Add double b (offset +16 from stack base)

    pop ebp
    ret

; ------------------------------------------------------------------------------
; math_sub(double a, double b) -> returns (a - b) in ST(0)
; ------------------------------------------------------------------------------
_math_sub:
    push ebp
    mov ebp, esp

    fld qword [ebp + 8]     ; Load double a
    fsub qword [ebp + 16]   ; Subtract double b

    pop ebp
    ret

; ------------------------------------------------------------------------------
; math_imul(double a, double b) -> returns (a * b) in ST(0)
; ------------------------------------------------------------------------------
_math_imul:
    push ebp
    mov ebp, esp

    fld qword [ebp + 8]     ; Load double a
    fmul qword [ebp + 16]   ; Multiply by double b

    pop ebp
    ret

; ------------------------------------------------------------------------------
; math_idiv(double a, double b) -> returns (a / b) in ST(0) (or NaN on div-by-zero)
; ------------------------------------------------------------------------------
_math_idiv:
    push ebp
    mov ebp, esp

    fld qword [ebp + 16]    ; Load double b (divisor)
    fldz                    ; Load 0.0
    fucomip st1             ; Compare 0.0 with b and pop 0.0
    fstp st0                ; Pop b
    je .div_zero

    fld qword [ebp + 8]     ; Load double a
    fdiv qword [ebp + 16]   ; Divide by double b
    jmp .done

.div_zero:
    fldz
    fldz
    fdivp st1, st0          ; 0.0 / 0.0 = NaN

.done:
    pop ebp
    ret

; ------------------------------------------------------------------------------
; math_mod(double a, double b) -> returns (a % b) in ST(0) via fprem
; ------------------------------------------------------------------------------
_math_mod:
    push ebp
    mov ebp, esp

    fld qword [ebp + 16]    ; Load double b
    fldz                    ; Load 0.0
    fucomip st1             ; Compare 0.0 with b and pop 0.0
    fstp st0                ; Pop b
    je .div_zero

    ; Load operands in correct order for partial remainder
    fld qword [ebp + 16]    ; ST(1) = b
    fld qword [ebp + 8]     ; ST(0) = a
    
.rem_loop:
    fprem                   ; ST(0) = ST(0) % ST(1)
    fstsw ax                ; Store status word in AX
    sahf                    ; Store AH into flags
    jp .rem_loop            ; If C2 is set, reduction is incomplete, loop again

    fstp st1                ; Pop ST(1) (b), leaving remainder in ST(0)
    jmp .done

.div_zero:
    fldz
    fldz
    fdivp st1, st0          ; Return NaN

.done:
    pop ebp
    ret

; ------------------------------------------------------------------------------
; math_pow(double base, double exp) -> returns (base ^ exp) in ST(0) via fyl2x + f2xm1
; ------------------------------------------------------------------------------
_math_pow:
    push ebp
    mov ebp, esp

    fld qword [ebp + 16]    ; Load exp (y) -> ST(1)
    fld qword [ebp + 8]     ; Load base (x) -> ST(0)

    ; Check if base is 0.0
    fldz
    fucomip st1             ; Compare 0.0 with base
    je .base_zero

    fyl2x                   ; ST(0) = y * log2(x), pops base

    ; Split ST(0) (z) into integer part (I) and fractional part (F)
    fld st0                 ; ST(0) = z, ST(1) = z
    frndint                 ; ST(0) = I (rounded to nearest integer)
    fsub st1, st0           ; ST(1) = z - I = F. ST(0) = I, ST(1) = F
    fxch st1                ; ST(0) = F, ST(1) = I
    f2xm1                   ; ST(0) = 2^F - 1
    fld1                    ; ST(0) = 1, ST(1) = 2^F - 1
    faddp st1, st0          ; ST(0) = 2^F, ST(1) = I
    fscale                  ; ST(0) = 2^F * 2^I = 2^z, ST(1) = I
    fstp st1                ; Pop I, leaving result in ST(0)
    jmp .done

.base_zero:
    ; Base is zero. Clean FPU and return 0.0
    fstp st0                ; Pop base
    fstp st0                ; Pop exp
    fldz                    ; Return 0.0

.done:
    pop ebp
    ret
