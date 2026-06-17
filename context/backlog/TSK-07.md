# TSK-07: FPU Core Arithmetic Engine (math.asm)

* **Owner / Assignee:** Kalyel N. Laurindo / Software Engineer  
* **Estimated Effort:** 4 Hours  
* **Story / Epic Reference:** RF01, RF03  
* **Development Methodology:** TDD (Red-Green-Refactor)

## 📖 Description & Objectives

Implement floating-point math subroutines (`math_add_f`, `math_sub_f`, `math_mul_f`, `math_div_f`) in `src/math.asm` utilizing the x87 FPU coprocessor stack. The functions must accept 32-bit float parameters via stack, execute using FPU instructions, and return results in `ST(0)`.

## ✅ Definition of Ready (DoR)
* [x] Baseline integer math procedures decoupled or clearly demarcated.
* [x] FPU stack instructions verified for 32-bit Protected Mode execution.

## 🏁 Definition of Done (DoD) & Acceptance Criteria
* [x] **[Testing]:** Float math subroutines pass rigorous C unit assertions in `tests/unit_tests.c`.
* [x] **[Safety]:** Division by zero checks for float values are handled safely, returning `NaN` or a sentinel value.
* [x] **[Calling Convention]:** Complies with the 32-bit C calling convention (parameters on stack, result in ST(0)).

---
**Signature:** Kalyel N. Laurindo / Software Engineer
