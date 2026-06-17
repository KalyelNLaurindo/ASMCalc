# **📋 Implementation & AI-Driven Execution Plan: ASMCalc — x86 Assembly TDD Implementation Flow**

**Role:** Project Owner / Tech Lead / AI Prompt Engineer

**Objective:** Map out the phased execution roadmap for standard software implementation, prioritizing a Test-First (TDD) cycle and optimizing the workspace environment for AI-assisted code generation via structured specifications (`claude.md` / `.cursorrules`).

## **🏛️ Project Metadata**

- **Target Technical Stack:** x86 Assembly (Protected Mode, Intel Syntax, NASM), MinGW GCC (32-bit Linker), GNU Make.
- **Date of Creation:** June 16, 2026
- **Lead Architect / Tech Lead:** Kalyel N. Laurindo / Software Engineer
- **Execution Version:** v1.0
- **Git Branching Strategy:** Feature Branching (GitFlow)

---

## **🚀 1. Phased Production Roadmap (The Order of Execution)**

### **Roadmap Phase Entry**

- **Field 1.0 - Active Phases Config:** Phase 1 (Infrastructure & Config) / Phase 2 (Domain Context) / Phase 3 (Core Use Cases - TDD Unit Testing) / Phase 4 (Adapters & CLI Menu Integration) / Phase 6 (Packaging & Release/Makefile)

#### **Phase 1: Backing Infrastructure & Configuration Setup**

- **Core Focus:** Toolchain verification (NASM and GCC compilers), directory validation, creation of project structure, `.gitignore` setting.
- **Field 1.1 - Initialization Tasks:**
  1. Verify NASM is installed: `nasm -v`
  2. Verify MinGW GCC (32-bit target support) is installed: `gcc -v`
  3. Create `.gitignore` to ignore `.obj` object files, debug databases, and `.exe` compiled binaries.
  4. Create `Makefile` containing build, clean, and test rules.
  5. Perform the setup commit.
- **Field 1.2 - Target File/Directory Paths:** `ASMCalc/.gitignore`, `ASMCalc/Makefile`, `ASMCalc/src/`
- **Field 1.3 - Exact Terminal Verification Command:** `nasm -v; gcc -v`
- **Field 1.4 - Phase Output Deliverables:** An initialized working directory with compilation toolchains confirmed.

#### **Phase 2: Bounded Domain Context (Pure Mathematical Calculations)**

- **Core Focus:** Creating pure assembly subroutines for addition, subtraction, multiplication, and division with zero-check guards using standard CPU register arithmetic.
- **Field 2.1 - Core Domain Modeling Tasks:**
  1. Write `src/math.asm` containing arithmetic subroutines `math_add`, `math_sub`, `math_imul`, `math_idiv`.
  2. Ensure standard **cdecl** calling conventions (e.g. function arguments retrieved from stack relative to `EBP`).
- **Field 2.2 - Target File/Directory Paths:** `ASMCalc/src/math.asm`
- **Field 2.3 - Exact Terminal Verification Command:** `nasm -f win32 src/math.asm -o src/math.obj`
- **Field 2.4 - Phase Output Deliverables:** Object file `src/math.obj` containing verified arithmetic symbols.

#### **Phase 3: Test-First Core Logic (TDD Unit Testing)**

- **Core Focus:** Testing mathematical subroutines via a C test runner to assert correctness of register preservation and calculation values.
- **Field 3.1 - Application Logic Tasks:**
  1. Write a C test runner `tests/unit_tests.c` that declares external functions `math_add`, `math_sub`, `math_imul`, `math_idiv`.
  2. Assert correct return values for positive, negative, and zero inputs, and division by zero detection.
- **Field 3.2 - Target File/Directory Paths:** `ASMCalc/tests/unit_tests.c`
- **Field 3.3 - Exact Terminal Verification Command:** `gcc -m32 tests/unit_tests.c src/math.obj -o tests/unit_tests.exe; tests/unit_tests.exe`
- **Field 3.4 - Phase Output Deliverables:** Unit testing executable verifying all core calculator arithmetic routines.

#### **Phase 4: Interface Adapters & CLI Menu Integration**

- **Core Focus:** Implementing string-to-number parse routines, prompt print handlers, and the main interactive console loop.
- **Field 4.1 - Integration & Adapter Tasks:**
  1. Write `src/io.asm` containing ASCII-to-integer (`atoi_conv`) and integer-to-ASCII (`itoa_conv`) converters, plus helper wrappers for printing messages (`print_str`).
  2. Write `src/main.asm` defining the main entry point `_main` (or `main` depending on compiler symbol prefixing), prompting the user with the menu, reading inputs, routing to math functions, and rendering results.
- **Field 4.2 - Target File/Directory Paths:** `ASMCalc/src/io.asm`, `ASMCalc/src/main.asm`
- **Field 4.3 - Exact Terminal Verification Command:** `make build; ASMCalc.exe`
- **Field 4.4 - Phase Output Deliverables:** Fully functional executable `ASMCalc.exe` responding to user arithmetic inputs on the console.

#### **Phase 5: Diagnostics, Observability & Hardening**

- **Field 5.1 - Observability & Hardening Tasks:** N/A (Standard CLI boundary checks mapped to user interface errors).

#### **Phase 6: Packaging, CI/CD & Release Preparation**

- **Core Focus:** Final project packaging, LICENSE inclusion, and project document cleanup.
- **Field 6.1 - Packaging & Release Tasks:**
  1. Add MIT `LICENSE` file.
  2. Complete `README.md` at root detailing compilation commands.
  3. Validate full build cycle from clean state.
- **Field 6.2 - Target File/Directory Paths:** `ASMCalc/LICENSE`, `ASMCalc/README.md`
- **Field 6.3 - Exact Terminal Verification Command:** `make clean && make build`
- **Field 6.4 - Phase Output Deliverables:** Ready-to-distribute binary and source code archive of ASMCalc.

---

## **🧪 2. The Test-First (TDD) Lifecycle Gate**

Every code routine produced must comply with the strict Red-Green-Refactor sequence. Under no circumstances shall the AI output production assembly logic before delivering or linking its corresponding unit test harness in `tests/unit_tests.c`.

---

## **🤖 3. AI Context Engineering (claude.md)**

```markdown
# ASMCalc

## 1. Role and Persona

You are a Staff Software Engineer and x86 Assembly Architect. You write clean, production-ready, highly commented Intel-syntax Assembly code using NASM.

## 2. Core Constraints

- **Testing Approach:** Test-First (maintain tests/unit_tests.c verifying math.obj symbols before final implementation).
- **Architectural Isolation:** Standard modular assembly files linked together.
- **Mocking Constraint:** N/A.
- **Self-Healing Limit:** If the NASM assembler or GCC linker fails more than 3 consecutive times, stop and request human assistance.
- **Strict Pathing Rule:** Place code only in src/ and tests/ folders.
- **Data Durability Rule:** N/A.
- **Data Deletion Strategy:** N/A.

## 3. Technology Stack Specifics

- Backend Framework: NASM 32-bit Assembly (win32 format), MinGW GCC 32-bit.
- Database Paradigm & Connection: CPU Registers and Stack memory frames.
- Communication Protocols: Local CLI Console streams (stdin/stdout via printf/scanf).
```

---

## **📋 4. Specification-to-Execution Matrix**

| Feature Identifier | Target System Boundary | Production Code File Path | Pre-Condition Test Suite File | Associated Prompt Spec File | Status |
| :----------------- | :--------------------- | :------------------------ | :---------------------------- | :-------------------------- | :----- |
| **FT01-MATH**      | Core Arithmetic        | `src/math.asm`            | `tests/unit_tests.c`          | `context/Software Design - ASMCalc.md` | Pending |
| **FT02-IO**        | ASCII/Int Converters   | `src/io.asm`              | `tests/unit_tests.c`          | `context/Software Design - ASMCalc.md` | Pending |
| **FT03-CLI**       | Menu & Input Loop      | `src/main.asm`            | `tests/e2e_tests.bat`         | `context/Software Design - ASMCalc.md` | Pending |

---

## **🛡️ 5. Definition of Done (DoD) for AI Iterations**

- [ ] **Structural Validation:** The assembly code compiles cleanly using NASM with no warnings.
- [ ] **Test Execution:** C test harness compiles and passes all assertions.
- [ ] **Context Sync:** Any register mapping adjustments are logged in the file headers.

---

**Signature:** Kalyel N. Laurindo / Software Engineer
