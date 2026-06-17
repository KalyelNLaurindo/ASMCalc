# TSK-06: Expanded Math Operations & ANSI Color Terminal Interface (Scope Expansion)

* **Owner / Assignee:** Kalyel N. Laurindo / Software Engineer  
* **Estimated Effort:** 6 Hours  
* **Story / Epic Reference:** RF01, RF02, RF04  
* **Development Methodology:** TDD & Integration Testing

## 📖 Description & Objectives

Expand the core mathematical engine with modulo division (`math_mod`) and integer power (`math_pow`). Additionally, build a beautiful CLI menu utilizing ANSI escape codes for coloring, showing register/ANS status, and offering options to reuse the last calculation result as the first operand.

## ✅ Definition of Ready (DoR)
* [x] Infrastructure and baseline arithmetic tests in place.
* [x] ANSI code compatibility verified for modern terminal environments.

## 🏁 Definition of Done (DoD) & Acceptance Criteria
* [x] **[Testing]:** Modulo and power subroutines pass standard unit tests in `tests/unit_tests.c`.
* [x] **[UX/Functional]:** Interactive terminal prints color-coded menus, displays error highlights, and correctly retains the "ANS" register (last calculated value).
* [x] **[Resilience]:** Exponentiation handles zero and negative bounds gracefully, and modulo operation is protected against division-by-zero crashes.

---
**Signature:** Kalyel N. Laurindo / Software Engineer
