# TSK-01: Toolchain Verification & Makefile Bootstrap

* **Owner / Assignee:** Kalyel N. Laurindo / Software Engineer  
* **Estimated Effort:** 2 Hours  
* **Story / Epic Reference:** N/A  
* **Development Methodology:** Build Validation

## 📖 Description & Objectives

Verify local development environment tools (`nasm` and `gcc`) and configure a working Makefile to coordinate assembly compilation, linking, and testing runs.

## ✅ Definition of Ready (DoR)
* [x] GCC and NASM installed on client OS
* [x] Project directory structure established

## 🏁 Definition of Done (DoD) & Acceptance Criteria
* [x] Running `make build` compiles dummy assembly correctly.
* [x] Running `make clean` clears temporary objects.
