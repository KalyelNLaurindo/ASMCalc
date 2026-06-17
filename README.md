# 📋 **ASMCalc — Pure x86 Assembly CLI Calculator**

### **High-Performance Low-Level Interactive Calculation Engine**

[![Stack Version](https://img.shields.io/badge/Assembly-x86_32-blue?style=for-the-badge&logo=assembly)](https://nasm.us)
[![Architecture](https://img.shields.io/badge/Architecture-Modular_ASM-8A2BE2?style=for-the-badge)](#)
[![Dependencies](https://img.shields.io/badge/Dependencies-msvcrt.dll-success?style=for-the-badge)](#)
[![Testing Paradigm](https://img.shields.io/badge/Testing-TDD_C_Harness-green?style=for-the-badge)](#)

---

## **🏛️ Repository Metadata & Context**

| Property               | Description                                                                              |
| :--------------------- | :--------------------------------------------------------------------------------------- |
| **Role**               | Portfolio Legacy System / Architectural Reference                                        |
| **Target Segment**     | Students / Junior Engineers onboarding in Legacy Systems                                 |
| **Architecture Style** | Modular Assembly Subroutines obeying standard **cdecl** calling conventions              |
| **Execution Engine**   | Standalone 32-bit Win32 Console Binary executing native assembly arithmetic opcodes      |
| **Date of Creation**   | June 16, 2026                                                                            |
| **Current Version**    | v1.0.0                                                                                   |

---

## **🚀 1. The Product Vision & Core Problem**

### **1.1. The Macro Pain Space**
Modern developer onboarding processes assume a high level of abstraction, shielding engineers from physical register states and stack operations. When developers are introduced to legacy corporate modules containing embedded assembly math calculations, they lack clean, isolated, and well-documented reference implementations. They often resort to disassembling complex C scripts, which generates highly convoluted outputs, leading to high bug rates and onboarding friction.

### **1.2. The Core Solution Paradigm Shift**
ASMCalc provides a clean, hand-written, line-by-line documented x86 Assembly CLI calculator. It isolates basic addition, subtraction, multiplication, and division into decoupled subroutines, demonstrating stack framework parameters and calling convention standards without high-level compiler overhead.

---

## **🎮 2. CLI / Interface Usage Reference**

The client interface is a simple interactive console loop.

| Command / Action              | Syntax                | Description                                                        | Example              |
| :---------------------------- | :-------------------- | :----------------------------------------------------------------- | :------------------- |
| **Run Calculator**            | `ASMCalc.exe`         | Launches the CLI calculator menu and console handler               | `ASMCalc.exe`        |
| **Arithmetic Selection**      | Input `1` to `4`      | Directs execution to Sum, Subtraction, Multiplication, or Division | Menu prompt entry    |
| **Operand Input**             | Positive/Negative Dec | Reads decimal numbers to perform operations                        | Input: `15`, `-3`     |

> [!NOTE]
> **Data & Validation Rules:**
> - User input strings are read using size-restricted buffers to prevent buffer overflow attacks.
> - Division operations execute zero-value divisor checks prior to the hardware calculation, avoiding processor exceptions (division-by-zero crashes).

---

## **🛠️ 3. Technical Stack Overview**

| Architectural Layer        | Component / Technology                        | Technical Rationale                                                                       |
| :------------------------- | :-------------------------------------------- | :---------------------------------------------------------------------------------------- |
| **User Interface**         | Win32 Console Streams                         | Direct standard input/output interface with zero UI rendering overhead.                    |
| **Calculation Logic**      | Intel x86 32-bit Assembly (NASM)              | Complete control over CPU registers and mathematical instruction sets.                   |
| **System Abstraction**     | Microsoft Visual C Runtime (`msvcrt.dll`)     | Leverage standard C lib operations (`printf`, `scanf`) for console I/O helper operations.  |
| **Build System**           | GNU Make (Makefile) & MinGW GCC (32-bit)      | Streamlined assembly compilation and linking workflow on Windows environment.             |

---

## **🏗️ 4. Core Architectural Premises**

*   **Premise 4.1 - Design & Modularity Strategy:** Monolith structured into separated files for I/O functions (`io.asm`) and math calculations (`math.asm`) bound together via calling convention interfaces.
*   **Premise 4.2 - Testing Strategy & Coverage Rule:** Test-Driven Development (TDD) via C unit tests (`tests/unit_tests.c`) calling assembly object routines directly.
*   **Premise 4.3 - Data Deletion & Auditing Policy:** N/A (Temporary registers are reset on menu loop iterations).
*   **Premise 4.4 - API Idempotency & Concurrency Strategy:** N/A (Single-threaded CLI application).

---

## **📂 5. Codebase Structure & Directory Standards**

```
ASMCalc/
├── context/                   # Architecture & Discovery specs
│   ├── backlog/
│   │   └── 4 - Task Management - ASMCalc.md
│   ├── 0 - Problem Discovery - ASMCalc.md
│   ├── 1 - Solution Architecture - ASMCalc.md
│   ├── 2 - Software Design - ASMCalc.md
│   ├── 3 - Implementation Flow - ASMCalc.md
│   ├── CLAUDE - ASMCalc.md
│   └── Quick Start - ASMCalc.md
│
├── src/                       # Assembly source codes
│   ├── main.asm               # Entry point & Menu loop
│   ├── math.asm               # Arithmetic routines
│   └── io.asm                 # Standard stream & ASCII parsing routines
│
├── tests/                     # Test harness suite
│   └── unit_tests.c           # C Unit Testing harness
│
├── Makefile                   # GNU Make compiler/linker instructions
├── README.md                  # Developer manual
└── .gitignore                 # Excludes .obj and .exe artifacts
```

---

## **💻 6. Local Engineering Development Setup**

### **6.1. Core System Prerequisites**
- **NASM Assembler** (added to System PATH)
- **MinGW GCC Compiler** with 32-bit compilation support (`gcc -m32`)
- **GNU Make**

### **6.2. Initial Bootstrap Sequence**

1. Compile the calculator locally using Makefile:
   ```bash
   make build
   ```

2. Run the executable:
   ```bash
   ASMCalc.exe
   ```

### **6.3. Automated Verification Commands**

- **Execute primary system test engine (C Unit Tests)**:
  ```bash
  make test
  ```

- **Clean temporary build object files**:
  ```bash
  make clean
  ```

---

🏁 **End of Document:** This repository README serves as the definitive engineering portal for the ASMCalc ecosystem.

Made with ❤️ by **Kalyel N. Laurindo / Software Engineer**
