# TSK-10: Extended Negative Number Support & Boundary Validation

* **Owner / Assignee:** Kalyel N. Laurindo / Software Engineer  
* **Estimated Effort:** 6 Hours  
* **Story / Epic Reference:** RF01, RF02  
* **Development Methodology:** TDD (Red-Green-Refactor)

## 📖 Description & Objectives

Implement deep verification, boundary checks, and robust formatting for operations involving negative integers and floats. This task covers:
1. Handling negative roots or powers that result in complex/undefined numbers (e.g., negative base with fractional exponent in `math_pow` returning NaN/error).
2. Proper signs formatting and handling negative zero (`-0.0`).
3. Parsing of inputs with multiple consecutive unary operators (e.g. `5 + -3` or `-5 * -2`).

## ✅ Definition of Ready (DoR)
* [ ] FPU stack exception status flags analyzed.
* [ ] Input parser constraints for negative signs and operators mapped.

## 🏁 Definition of Done (DoD) & Acceptance Criteria
* [ ] **[Testing]:** Multi-sign negative numbers operations pass the unit tests.
* [ ] **[Robustness]:** Operations producing imaginary outputs (e.g. `(-4)^0.5`) cleanly return NaN and do not trigger hardware faults.
* [ ] **[Formatting]:** Negative outputs are correctly printed with prefix minus signs and exact two decimal digits without sign pollution.

---
**Signature:** Kalyel N. Laurindo / Software Engineer
