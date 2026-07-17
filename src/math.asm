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
global _math_complex_add
global _math_complex_sub
global _math_complex_mul
global _math_complex_div
global _math_gcd
global _math_fraction_simplify
global _math_fraction_add
global _math_fraction_sub
global _math_fraction_mul
global _math_fraction_div

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

    ; Check if base is negative or zero
    fldz
    fucomip st1             ; Compare 0.0 with base (pops 0.0)
    ja .base_negative       ; If 0.0 > base, jump to .base_negative
    je .base_zero           ; If 0.0 == base, jump to .base_zero

    ; Base is positive, compute normally
    fyl2x                   ; ST(0) = exp * log2(base)
    jmp .exponentiate

.base_negative:
    ; Check if exponent is an integer
    fld st1                 ; ST(0) = exp, ST(1) = base, ST(2) = exp
    frndint                 ; ST(0) = round(exp), ST(1) = base, ST(2) = exp
    fld st2                 ; ST(0) = exp, ST(1) = round(exp), ST(2) = base, ST(3) = exp
    fucomip st1             ; Compare exp with round(exp) (pops exp)
    fstp st0                ; Pop round(exp)
    ; Now stack has ST(0) = base, ST(1) = exp
    jne .complex_nan        ; If not equal, exponent is fractional -> complex -> NaN

    ; Determine if integer exponent is odd or even
    fld st1                 ; ST(0) = exp, ST(1) = base, ST(2) = exp
    frndint
    sub esp, 4
    fistp dword [esp]       ; pops rounded exp, stack is now ST(0) = base, ST(1) = exp
    pop eax                 ; EAX = rounded exponent
    test eax, 1
    setnz cl                ; CL = 1 if odd, 0 if even
    movzx ecx, cl
    push ecx                ; Save pariness flag

    ; Compute positive base power: |base|^exp
    fabs                    ; ST(0) = |base|, ST(1) = exp
    fyl2x                   ; ST(0) = exp * log2(|base|)

.exponentiate:
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

    ; If we computed negative base, check if we need to negate result
    fld qword [ebp + 8]     ; Load base -> ST(0), ST(1) = result
    fldz                    ; ST(0) = 0.0, ST(1) = base, ST(2) = result
    fucomip st1             ; Compare 0.0 with base (pops 0.0)
    fstp st0                ; Pop base, leaving result in ST(0)
    jbe .done               ; If base >= 0, we are done

    ; Base was negative, pop the pariness flag and check if odd
    pop ecx
    cmp ecx, 1
    jne .done
    fchs                    ; Negate result
    jmp .done

.complex_nan:
    fstp st0                ; Pop base
    fstp st0                ; Pop exp
    fldz
    fldz
    fdivp st1, st0          ; Return NaN (0.0/0.0)
    jmp .done

.base_zero:
    ; Base is zero. Clean FPU and return 0.0
    fstp st0                ; Pop base
    fstp st0                ; Pop exp
    fldz                    ; Return 0.0

.done:
    pop ebp
    ret

; ------------------------------------------------------------------------------
; math_complex_add(complex *res, const complex *a, const complex *b)
; ------------------------------------------------------------------------------
_math_complex_add:
    push ebp
    mov ebp, esp
    
    mov eax, [ebp + 8]    ; eax = res pointer
    mov ecx, [ebp + 12]   ; ecx = a pointer
    mov edx, [ebp + 16]   ; edx = b pointer
    
    ; real part: res->real = a->real + b->real
    fld qword [ecx]
    fadd qword [edx]
    fstp qword [eax]
    
    ; imag part: res->imag = a->imag + b->imag
    fld qword [ecx + 8]
    fadd qword [edx + 8]
    fstp qword [eax + 8]
    
    pop ebp
    ret

; ------------------------------------------------------------------------------
; math_complex_sub(complex *res, const complex *a, const complex *b)
; ------------------------------------------------------------------------------
_math_complex_sub:
    push ebp
    mov ebp, esp
    
    mov eax, [ebp + 8]
    mov ecx, [ebp + 12]
    mov edx, [ebp + 16]
    
    fld qword [ecx]
    fsub qword [edx]
    fstp qword [eax]
    
    fld qword [ecx + 8]
    fsub qword [edx + 8]
    fstp qword [eax + 8]
    
    pop ebp
    ret

; ------------------------------------------------------------------------------
; math_complex_mul(complex *res, const complex *a, const complex *b)
; ------------------------------------------------------------------------------
_math_complex_mul:
    push ebp
    mov ebp, esp
    push ebx
    
    mov eax, [ebp + 8]    ; res
    mov ecx, [ebp + 12]   ; a
    mov edx, [ebp + 16]   ; b
    
    ; Compute real part: a.real * b.real - a.imag * b.imag
    fld qword [ecx]       ; ST(0) = a.real
    fmul qword [edx]      ; ST(0) = a.real * b.real
    fld qword [ecx + 8]   ; ST(0) = a.imag, ST(1) = a.real * b.real
    fmul qword [edx + 8]  ; ST(0) = a.imag * b.imag, ST(1) = ...
    fsubp st1, st0        ; ST(0) = a.real * b.real - a.imag * b.imag
    
    ; Compute imag part: a.real * b.imag + a.imag * b.real
    fld qword [ecx]       ; ST(0) = a.real, ST(1) = temp_real
    fmul qword [edx + 8]  ; ST(0) = a.real * b.imag, ST(1) = temp_real
    fld qword [ecx + 8]   ; ST(0) = a.imag, ST(1) = a.real * b.imag, ST(2) = temp_real
    fmul qword [edx]      ; ST(0) = a.imag * b.real
    faddp st1, st0        ; ST(0) = a.real * b.imag + a.imag * b.real, ST(1) = temp_real
    
    ; Store imag part
    fstp qword [eax + 8]
    ; Store real part
    fstp qword [eax]
    
    pop ebx
    pop ebp
    ret

; ------------------------------------------------------------------------------
; math_complex_div(complex *res, const complex *a, const complex *b)
; ------------------------------------------------------------------------------
_math_complex_div:
    push ebp
    mov ebp, esp
    push ebx
    
    mov eax, [ebp + 8]    ; res
    mov ecx, [ebp + 12]   ; a
    mov edx, [ebp + 16]   ; b
    
    ; Compute denominator: b.real^2 + b.imag^2
    fld qword [edx]       ; ST(0) = b.real
    fmul st0, st0         ; ST(0) = b.real^2
    fld qword [edx + 8]   ; ST(0) = b.imag
    fmul st0, st0         ; ST(0) = b.imag^2
    faddp st1, st0        ; ST(0) = denom = b.real^2 + b.imag^2
    
    ; Check if denom is 0.0
    fldz
    fucomip st1
    je .div_by_zero
    
    ; Compute real numerator: a.real * b.real + a.imag * b.imag
    fld qword [ecx]       ; ST(0) = a.real, ST(1) = denom
    fmul qword [edx]      ; ST(0) = a.real * b.real
    fld qword [ecx + 8]   ; ST(0) = a.imag, ST(1) = ...
    fmul qword [edx + 8]  ; ST(0) = a.imag * b.imag
    faddp st1, st0        ; ST(0) = a.real * b.real + a.imag * b.imag, ST(1) = denom
    
    fdiv st0, st1         ; ST(0) = real_result, ST(1) = denom
    
    ; Compute imag numerator: a.imag * b.real - a.real * b.imag
    fld qword [ecx + 8]   ; ST(0) = a.imag, ST(1) = real_result, ST(2) = denom
    fmul qword [edx]      ; ST(0) = a.imag * b.real
    fld qword [ecx]       ; ST(0) = a.real, ST(1) = ...
    fmul qword [edx + 8]  ; ST(0) = a.real * b.imag
    fsubp st1, st0        ; ST(0) = a.imag * b.real - a.real * b.imag, ST(1) = real_result, ST(2) = denom
    
    fdiv st0, st2         ; ST(0) = imag_result, ST(1) = real_result, ST(2) = denom
    
    ; Store results
    fstp qword [eax + 8]  ; Store imag_result
    fstp qword [eax]      ; Store real_result
    fstp st0              ; Pop denom
    jmp .done_div
    
.div_by_zero:
    fstp st0              ; Pop denom
    fldz
    fldz
    fdivp st1, st0        ; NaN
    fld st0
    fstp qword [eax]
    fstp qword [eax + 8]
    
.done_div:
    pop ebx
    pop ebp
    ret

; ------------------------------------------------------------------------------
; math_gcd(int a, int b) -> returns GCD in EAX
; ------------------------------------------------------------------------------
_math_gcd:
    push ebp
    mov ebp, esp
    push ebx
    
    mov eax, [ebp + 8]    ; eax = a
    mov ecx, [ebp + 12]   ; ecx = b
    
    test eax, eax
    jns .a_pos
    neg eax
.a_pos:
    test ecx, ecx
    jns .b_pos
    neg ecx
.b_pos:

.loop_gcd:
    test ecx, ecx
    jz .done_gcd
    cdq
    idiv ecx              ; edx = eax % ecx, eax = eax / ecx
    mov eax, ecx
    mov ecx, edx
    jmp .loop_gcd
    
.done_gcd:
    pop ebx
    pop ebp
    ret

; ------------------------------------------------------------------------------
; math_fraction_simplify(fraction *f)
; ------------------------------------------------------------------------------
_math_fraction_simplify:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    
    mov esi, [ebp + 8]    ; f pointer
    mov eax, [esi]        ; num
    mov ecx, [esi + 4]    ; den
    
    test ecx, ecx
    jns .den_positive
    neg eax
    neg ecx
    mov [esi], eax
    mov [esi + 4], ecx
    
.den_positive:
    test eax, eax
    jnz .calc_gcd
    mov dword [esi + 4], 1
    jmp .done_simplify
    
.calc_gcd:
    push ecx              ; b
    push eax              ; a
    call _math_gcd
    add esp, 8            ; eax = gcd
    
    test eax, eax
    jz .done_simplify
    
    mov ebx, eax          ; ebx = gcd
    mov eax, [esi]        ; num
    cdq
    idiv ebx              ; eax = num / gcd
    mov [esi], eax
    
    mov eax, [esi + 4]    ; den
    cdq
    idiv ebx              ; eax = den / gcd
    mov [esi + 4], eax
    
.done_simplify:
    pop esi
    pop ebx
    pop ebp
    ret

; ------------------------------------------------------------------------------
; math_fraction_add(fraction *res, const fraction *a, const fraction *b)
; ------------------------------------------------------------------------------
_math_fraction_add:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov edi, [ebp + 8]    ; res
    mov esi, [ebp + 12]   ; a
    mov ebx, [ebp + 16]   ; b
    
    mov eax, [esi]        ; a->num
    imul dword [ebx + 4]  ; eax = a->num * b->den
    mov ecx, eax
    
    mov eax, [ebx]        ; b->num
    imul dword [esi + 4]  ; eax = b->num * a->den
    add eax, ecx
    mov [edi], eax
    
    mov eax, [esi + 4]    ; a->den
    imul dword [ebx + 4]
    mov [edi + 4], eax
    
    push edi
    call _math_fraction_simplify
    add esp, 4
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

; ------------------------------------------------------------------------------
; math_fraction_sub(fraction *res, const fraction *a, const fraction *b)
; ------------------------------------------------------------------------------
_math_fraction_sub:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov edi, [ebp + 8]    ; res
    mov esi, [ebp + 12]   ; a
    mov ebx, [ebp + 16]   ; b
    
    mov eax, [esi]        ; a->num
    imul dword [ebx + 4]  ; eax = a->num * b->den
    mov ecx, eax
    
    mov eax, [ebx]        ; b->num
    imul dword [esi + 4]  ; eax = b->num * a->den
    sub ecx, eax
    mov [edi], ecx
    
    mov eax, [esi + 4]    ; a->den
    imul dword [ebx + 4]
    mov [edi + 4], eax
    
    push edi
    call _math_fraction_simplify
    add esp, 4
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

; ------------------------------------------------------------------------------
; math_fraction_mul(fraction *res, const fraction *a, const fraction *b)
; ------------------------------------------------------------------------------
_math_fraction_mul:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov edi, [ebp + 8]    ; res
    mov esi, [ebp + 12]   ; a
    mov ebx, [ebp + 16]   ; b
    
    mov eax, [esi]
    imul dword [ebx]
    mov [edi], eax
    
    mov eax, [esi + 4]
    imul dword [ebx + 4]
    mov [edi + 4], eax
    
    push edi
    call _math_fraction_simplify
    add esp, 4
    
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

; ------------------------------------------------------------------------------
; math_fraction_div(fraction *res, const fraction *a, const fraction *b)
; ------------------------------------------------------------------------------
_math_fraction_div:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
    
    mov edi, [ebp + 8]    ; res
    mov esi, [ebp + 12]   ; a
    mov ebx, [ebp + 16]   ; b
    
    mov eax, [ebx]
    test eax, eax
    jz .div_by_zero_frac
    
    mov eax, [esi]
    imul dword [ebx + 4]
    mov [edi], eax
    
    mov eax, [esi + 4]
    imul dword [ebx]
    mov [edi + 4], eax
    
    push edi
    call _math_fraction_simplify
    add esp, 4
    jmp .done_div_frac
    
.div_by_zero_frac:
    mov dword [edi], 0
    mov dword [edi + 4], 0
    
.done_div_frac:
    pop edi
    pop esi
    pop ebx
    pop ebp
    ret

