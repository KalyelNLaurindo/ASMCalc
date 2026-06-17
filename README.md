# 📋 **ASMCalc — Pure x86 Assembly CLI Calculator**

### **High-Performance Low-Level Interactive Calculation Engine**

[![Stack Version](https://img.shields.io/badge/Assembly-x86__32-blue?style=for-the-badge&logo=assembly)](https://nasm.us)
[![Architecture](https://img.shields.io/badge/Architecture-Modular__ASM-8A2BE2?style=for-the-badge)](#)
[![Dependencies](https://img.shields.io/badge/Dependencies-msvcrt.dll-green?style=for-the-badge)](#)
[![Testing Paradigm](https://img.shields.io/badge/Testing-TDD__C__Harness-brightgreen?style=for-the-badge)](#)

---

## **🏛️ Repository Metadata & Context**

| Property               | Description                                                                              |
| :--------------------- | :--------------------------------------------------------------------------------------- |
| **Role**               | Portfolio Legacy System / Architectural Reference                                        |
| **Target Audience**    | Software Engineers / Recruiters / Systems Engineering Specialists                       |
| **Architecture Style** | Modular Assembly Subroutines obeying standard **cdecl** calling conventions              |
| **Execution Engine**   | Standalone 32-bit Win32 Console Binary executing native assembly arithmetic opcodes      |
| **Build System**       | GNU Make & MinGW GCC (Dynamic linking to `msvcrt.dll` for stable I/O)                    |
| **Date of Creation**   | June 16, 2026                                                                            |
| **Current Version**    | v1.1.0 (Sprint 1 Completed)                                                              |

---

## **🚀 1. The Product Vision & Engineering Focus**

### **1.1. The Macro Pain Space**
Modern software development operates under layers of heavy compiler abstractions, hiding register management, stack frames, and CPU flags from engineers. When developers encounter low-level legacy modules, they often struggle to comprehend calling conventions, manual register preservation, and CPU exception avoidance. 

### **1.2. The Solution: ASMCalc**
**ASMCalc** is a highly documented, modular, and optimized CLI calculator written entirely in 32-bit x86 Intel Assembly (Protected Mode). It serves as a premium reference for:
- Establishing proper stack frames (`EBP`, `ESP` isolation).
- Enforcing standard C Calling Conventions (`cdecl`) for seamless integration with C/C++ libraries.
- Standardizing register preservation rules (saving non-volatile `EBX`, `ESI`, and `EDI`).
- Preventing hardware exceptions (software checks for division-by-zero on `IDIV` and modulo operations).
- Enhancing console UX with native ANSI color escape sequences and an in-memory results register (`ANS`).

---

## **🎮 2. CLI Features & Interface Usage**

The interface is an interactive console loop styled with ANSI colors (Bold Cyan for headers, Green for results, Red for errors, Yellow for menus).

```text
===============================================
                 ASMCalc CLI Calculator
===============================================
  Active ANS Register: 8
-----------------------------------------------
  1. Add (+)
  2. Subtract (-)
  3. Multiply (*)
  4. Divide (/)
  5. Modulo (%)
  6. Power (^)
  7. Clear ANS Register
  8. Exit Program
-----------------------------------------------
  Choose Option (1-8):
```

### **Core CLI Interactions**
- **ANS Register**: Reuses the result of the last successful calculation as the first operand by entering `ans` (case-insensitive) in the input prompts.
- **Arithmetic Expansion**: Includes modulo (`math_mod`) and power (`math_pow`) operations, complete with hardware boundary protections.
- **Input Hardening**: Digits are read using size-restricted buffer controls. Character inputs that are not decimal digits are intercepted, returning error status codes without parsing corrupt data.

---

## **🛠️ 3. Technical Stack & Architecture**

| Architectural Layer        | Component / Technology                        | Technical Rationale                                                                       |
| :------------------------- | :-------------------------------------------- | :---------------------------------------------------------------------------------------- |
| **User Interface**         | Win32 Console / ANSI Escapes                  | Color-coded CLI with zero rendering overhead, compatible with modern terminal emulators.  |
| **Calculation Logic**      | Intel x86 32-bit Assembly (NASM)              | Hand-written Intel-syntax assembly code focusing on CPU register control and instruction-level speed.|
| **System Abstraction**     | Microsoft Visual C Runtime (`msvcrt.dll`)     | Dynamic linking to libc helper functions (`printf`, `getchar`, `fflush`) to avoid platform-specific system calls. |
| **Test Engine**            | TDD C Harness (`tests/unit_tests.c`)          | Verifies assembly symbols, tests signed boundaries, and asserts register preservation.    |

---

## **🏗️ 4. Core Architectural Premises & Guidelines**

*   **Premise 4.1 - Design & Modularity Strategy:** Monolith structured into separated files for I/O functions (`io.asm`) and math calculations (`math.asm`) bound together via calling convention interfaces.
*   **Premise 4.2 - Stack Frame Integrity:** Every subroutine that modifies stack pointer or uses local buffers must establish a proper stack frame:
    ```assembly
    push ebp
    mov ebp, esp
    ; ... body ...
    mov esp, ebp
    pop ebp
    ret
    ```
*   **Premise 4.3 - Testing Strategy & Coverage Rule:** Test-Driven Development (TDD) via C unit tests (`tests/unit_tests.c`) calling assembly object routines directly.
*   **Premise 4.4 - Deferred Stack Cleanup:** Functions invoked repeatedly in the menu render block utilize deferred stack cleanups (e.g. cleaning multiple pushes in a single `add esp, N` instruction) to optimize execution size.

---

## **📂 5. Codebase Structure**

```
ASMCalc/
├── context/                   # Architecture & Discovery specs
│   ├── backlog/               # Prioritized agile tasks (TSK-01 to TSK-09)
│   │   ├── README.md          # Agile Backlog & Kanban board status
│   │   ├── TSK-01.md          # Toolchain Verification
│   │   ├── TSK-02.md          # Core Arithmetic Procedures
│   │   ├── TSK-03.md          # C Test Harness Setup
│   │   ├── TSK-04.md          # Low-Level CLI Input/Output Handlers
│   │   ├── TSK-05.md          # Main Console Router Menu Loop
│   │   ├── TSK-06.md          # Expanded Math Operations & ANSI Color Interface
│   │   ├── TSK-07.md          # FPU Core Arithmetic Engine
│   │   ├── TSK-08.md          # Float Parsing and Formatting Routines
│   │   └── TSK-09.md          # CLI Menu & ANS Adaptation for Floats
│   ├── Problem Discovery - ASMCalc.md
│   ├── Solution Architecture - ASMCalc.md
│   ├── Software Design - ASMCalc.md
│   ├── Implementation Flow - ASMCalc.md
│   └── Quick Start - ASMCalc.md
│
├── src/                       # Assembly source codes
│   ├── main.asm               # Entry point & Menu loop
│   ├── math.asm               # Arithmetic routines (Sum, Sub, Mul, Div, Mod, Pow)
│   └── io.asm                 # Standard stream & ASCII parsing routines (atoi, itoa, print, read)
│
├── tests/                     # Test harness suite
│   └── unit_tests.c           # C Unit Testing harness
│
├── Makefile                   # GNU Make compiler/linker instructions
├── README.md                  # Developer manual
├── claude.md                  # Claude/AI reference file
├── setup_env.bat              # Environment Bootstrap script
└── .gitignore                 # Excludes .obj and .exe artifacts
```

---

## **💻 6. Local Engineering Development Setup**

### **6.1. Core System Prerequisites**
- **NASM Assembler** (added to System PATH)
- **MinGW GCC Compiler** with 32-bit compilation support (`gcc -m32`)
- **GNU Make** (e.g., `mingw32-make` or `make`)

*Note: MSYS2's MinGW 32-bit toolchain (`mingw-w64-i686-gcc`) is recommended on Windows.*

### **6.2. Environment Verification & Compilation**

1. Configure environment path for GCC and NASM:
   ```powershell
   $env:PATH = "C:\tools\msys64\mingw32\bin;C:\Program Files\NASM;" + $env:PATH
   ```

2. Verify compiler toolchains are accessible:
   ```powershell
   mingw32-make check-env
   ```

3. Build the interactive CLI application:
   ```powershell
   mingw32-make build
   ```

4. Run the executable:
   ```powershell
   .\ASMCalc.exe
   ```

### **6.3. Running Automated Tests**

Run C-based unit assertions targeting compiled assembly object files. This includes validating signed arithmetic edge cases, integer overflow, conversion formatting, and strict register preservation checks:
```powershell
mingw32-make test
```

Clean build artifacts:
```powershell
mingw32-make clean
```

---

🏁 **End of Document:** This repository README serves as the definitive engineering portal for the ASMCalc ecosystem.

Made with ❤️ by [Kalyel N. Laurindo](https://github.com/KalyelNLaurindo) (Lead Software Engineer & Contributor)
