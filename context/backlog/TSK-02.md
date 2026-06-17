# TSK-02: Core Arithmetic Procedures (math.asm)

* **Owner / Assignee:** Kalyel N. Laurindo / Software Engineer  
* **Estimated Effort:** 4 Hours  
* **Story / Epic Reference:** RF01, RF03  
* **Development Methodology:** TDD (Red-Green-Refactor)

## 📖 Description & Objectives

Implement core 32-bit x86 signed integer arithmetic routines (`math_add`, `math_sub`, `math_imul`, `math_idiv`) in `src/math.asm` adhering to the **cdecl** standard.

## ✅ Definition of Ready (DoR)
* [ ] TDD Setup: `tests/unit_tests.c` declared and linked to compile pipeline.
* [ ] `src/math.asm` template ready.

## 🏁 Definition of Done (DoD) & Acceptance Criteria
* [ ] **[Testing/Quality - TDD]:** Unit tests in `tests/unit_tests.c` pass successfully for all operations (RED-GREEN cycle completed).
* [ ] **[Functional]:** Addition, subtraction, multiplication, and division return correct math results in register `EAX`.
* [ ] **[Technical]:** Divisor zero values trigger defensive branch checks returning error flag (`EAX = -1` or custom error protocol) instead of causing division exceptions.
