# TSK-03: C Test Harness for Math Routines

* **Owner / Assignee:** Kalyel N. Laurindo / Software Engineer  
* **Estimated Effort:** 3 Hours  
* **Story / Epic Reference:** RF01, RF03  
* **Development Methodology:** TDD (Red-Green-Refactor)

## 📖 Description & Objectives

Create a standalone C testing runner in `tests/unit_tests.c` that links with compiled assembly objects (`math.obj`) and asserts correctness of operations across multiple boundary values.

## ✅ Definition of Ready (DoR)
* [ ] Toolchain supports linking C object files with 32-bit Assembly objects.

## 🏁 Definition of Done (DoD) & Acceptance Criteria
* [ ] **[Testing]:** Running `make test` builds the test harness executable and runs assertions.
* [ ] **[Functional]:** Standard assertions verify sum, sub, mult, and div results.
* [ ] **[Technical]:** Custom boundary checks test edge cases (large values, division by zero, negative operands).
