# TSK-05: Main Console Router Menu Loop (main.asm)

* **Owner / Assignee:** Kalyel N. Laurindo / Software Engineer  
* **Estimated Effort:** 4 Hours  
* **Story / Epic Reference:** RF02  
* **Development Methodology:** Integration Testing

## 📖 Description & Objectives

Build the central routing flow inside `src/main.asm` defining `_main`. Render calculations options, route commands to arithmetic modules, and manage clean program exits.

## ✅ Definition of Ready (DoR)
* [x] `src/math.asm` and `src/io.asm` ready and compiled to object binaries.

## 🏁 Definition of Done (DoD) & Acceptance Criteria
* [x] **[Functional]:** Launching `ASMCalc.exe` presents active menu routing allowing selection of addition, subtraction, multiplication, and division.
* [x] **[UX/CLI]:** Menu runs recursively until user selects exit option.
* [x] **[Resilience]:** Program does not crash under invalid operation selections.
