# TSK-09: CLI Menu & ANS Adaptation for Floats (main.asm)

* **Owner / Assignee:** Kalyel N. Laurindo / Software Engineer  
* **Estimated Effort:** 4 Hours  
* **Story / Epic Reference:** RF02  
* **Development Methodology:** Integration Testing

## 📖 Description & Objectives

Update the main loop router in `src/main.asm` to handle 32-bit floats. This includes:
1. Parsing inputs using `atof_conv` instead of `atoi_conv`.
2. Formatting and displaying the ANS register as a float using `ftoa_conv`.
3. Invoking FPU math procedures for calculation and displaying results in decimal format.

## ✅ Definition of Ready (DoR)
* [ ] `src/math.asm` and `src/io.asm` updated with float subroutines.

## 🏁 Definition of Done (DoD) & Acceptance Criteria
* [ ] **[Functional]:** Calculator supports operations on decimal numbers (e.g., `5.5 + 4.5 = 10.000000`).
* [ ] **[UX/CLI]:** ANS register dynamically formats floats. Non-numeric inputs show clean highlights without crashing.
* [ ] **[Resilience]:** Program remains stable under division by zero and invalid decimal structures.

---
**Signature:** Kalyel N. Laurindo / Software Engineer
