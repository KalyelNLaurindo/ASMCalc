# TSK-04: Low-Level CLI Input/Output Handlers (io.asm)

* **Owner / Assignee:** Kalyel N. Laurindo / Software Engineer  
* **Estimated Effort:** 4 Hours  
* **Story / Epic Reference:** RF02, RF04  
* **Development Methodology:** TDD (Red-Green-Refactor)

## 📖 Description & Objectives

Implement string-to-integer (`atoi_conv`) and integer-to-string (`itoa_conv`) subroutines in `src/io.asm`, as well as standard stream printing and buffer-safe reading wrappers linking against standard libc elements.

## ✅ Definition of Ready (DoR)
* [x] Math procedures finalized or mocked.
* [x] GCC linking configurations verified for standard library integration.

## 🏁 Definition of Done (DoD) & Acceptance Criteria
* [x] **[Testing]:** Conversion routines pass standard assertion checks in `tests/unit_tests.c`.
* [x] **[Functional]:** String number formats are parsed to native binary values and correctly formatted back.
* [x] **[Technical]:** Character inputs that are not decimal digits are intercepted, returning error status codes without parsing corrupt data.
