# TSK-08: Float Parsing and Formatting Routines (io.asm)

* **Owner / Assignee:** Kalyel N. Laurindo / Software Engineer  
* **Estimated Effort:** 4 Hours  
* **Story / Epic Reference:** RF02, RF04  
* **Development Methodology:** TDD (Red-Green-Refactor)

## 📖 Description & Objectives

Implement floating-point string conversion subroutines in `src/io.asm`:
1. `atof_conv(const char *str, float *out_val)`: Parse a decimal string (including fractions, e.g., "12.34") to a 32-bit float.
2. `ftoa_conv(float val, char *buffer)`: Format a 32-bit float to its ASCII representation (e.g., "12.340000").
Both should wrap stable libc calls (`atof`, `sprintf`) to guarantee robustness.

## ✅ Definition of Ready (DoR)
* [ ] Libc linker imports defined for `atof` and `sprintf`.
* [ ] FPU stack loading mechanics verified for float values.

## 🏁 Definition of Done (DoD) & Acceptance Criteria
* [ ] **[Testing]:** Conversion routines pass standard assertion checks in `tests/unit_tests.c`.
* [ ] **[Robustness]:** Inputs with non-numeric formats or multiple decimals are rejected with error status codes.
* [ ] **[Formatting]:** Floating-point values are correctly outputted to buffers with sign preservation.

---
**Signature:** Kalyel N. Laurindo / Software Engineer
