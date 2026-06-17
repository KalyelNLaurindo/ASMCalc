# 📚 **ASMCalc Quick Start Guide**

This guide provides simple, sequential instructions to install, bootstrap, and run the **ASMCalc** application on your local machine.

---

## 📋 Prerequisites

Before setting up the project, make sure you have the following environments installed:

1.  **NASM (Netwide Assembler):** Version 2.15 or newer (must be added to system environment `PATH`).
2.  **MinGW GCC Compiler:** With 32-bit execution compilation support (must support `-m32` flag).
3.  **GNU Make:** Recommended for automating build tasks.

---

## 🚀 Step-by-Step Setup

### Step 1: Navigate to the Project Directory
Ensure your terminal is located inside the `ASMCalc` project folder:
```bash
cd "e:\Software Projects\Software Engineering Portfolio\15-sistemas-legados\ASMCalc"
```

### Step 2: Build the Executable
Run the Makefile compiler helper command to assemble and link the source code:
```bash
make build
```
*(If you do not have GNU Make, run the following compilation sequence manually:)*
```bash
nasm -f win32 src/math.asm -o src/math.obj
nasm -f win32 src/io.asm -o src/io.obj
nasm -f win32 src/main.asm -o src/main.obj
gcc -m32 src/main.obj src/math.obj src/io.obj -o ASMCalc.exe
```

### Step 3: Run the Calculator
Start the interactive command-line interface:
```bash
ASMCalc.exe
```

---

## ✅ Core Commands Reference

Here are the most frequently used commands to interact with the project:

| Action / Goal | Command Syntax | Description | Example |
| :--- | :--- | :--- | :--- |
| **Assemble & Link App** | `make build` | Assembles `.asm` files and links the `.exe` binary | `make build` |
| **Run Unit Tests** | `make test` | Assembles the math library and links C unit assertions | `make test` |
| **Clean Build Artifacts**| `make clean` | Removes all compiled `.obj` and `.exe` files | `make clean` |

---

## ❓ Troubleshooting & Known Issues

| Error / Issue | Root Cause | Solution |
| :--- | :--- | :--- |
| `nasm: command not found` | The assembler executable is not in the system environment `PATH` | Download NASM from its official page and append its install directory to your Windows System `PATH`. |
| `gcc: error: unrecognized command line option '-m32'` | Your GCC toolchain is 64-bit only and lacks multilib support | Install a MinGW-w64 build that includes multilib support, or configure a native 32-bit MinGW toolchain. |
| `fatal error: LNK1112: module machine type 'x64' conflicts...` | Linking a 64-bit object with 32-bit object | Clean intermediate objects using `make clean` and ensure GCC is called with the `-m32` parameter. |

---

**Signature:** Kalyel N. Laurindo / Software Engineer
