# ==============================================================================
#                      ASMCalc - x86 Assembly CLI Calculator
# ==============================================================================
# Author: Kalyel N. Laurindo / Software Engineer
# Date: 2026-06-17
# ==============================================================================

# Toolchain definitions
NASM = C:\Program Files\NASM\nasm.exe
CC   = C:\tools\msys64\mingw32\bin\gcc.exe

# Compiler and Assembler Flags
# GCC: Compile natively for 32-bit (i686), strict warning levels, optimization
CFLAGS  = -Wall -Wextra -Werror -O2
# NASM: Win32 object format, enable all warnings
ASMFLAGS = -f win32 -w+all

# Build directories
SRC_DIR   = src
TEST_DIR  = tests
BUILD_DIR = build

# Targets
all: check-env build

# Build target (empty for now until io.asm and main.asm are implemented)
build: check-env $(SRC_DIR)/math.obj $(SRC_DIR)/io.obj $(SRC_DIR)/main.obj
	"$(CC)" $(CFLAGS) $(SRC_DIR)/main.obj $(SRC_DIR)/math.obj $(SRC_DIR)/io.obj -o ASMCalc.exe
	@echo Build completed. ASMCalc.exe generated.

# Compilation rule for Assembly files
$(SRC_DIR)/math.obj: $(SRC_DIR)/math.asm
	@if not exist $(SRC_DIR) mkdir $(SRC_DIR)
	"$(NASM)" $(ASMFLAGS) $(SRC_DIR)/math.asm -o $(SRC_DIR)/math.obj

$(SRC_DIR)/io.obj: $(SRC_DIR)/io.asm
	@if not exist $(SRC_DIR) mkdir $(SRC_DIR)
	"$(NASM)" $(ASMFLAGS) $(SRC_DIR)/io.asm -o $(SRC_DIR)/io.obj

$(SRC_DIR)/main.obj: $(SRC_DIR)/main.asm
	@if not exist $(SRC_DIR) mkdir $(SRC_DIR)
	"$(NASM)" $(ASMFLAGS) $(SRC_DIR)/main.asm -o $(SRC_DIR)/main.obj

# Test Target
test: check-env $(SRC_DIR)/math.obj $(SRC_DIR)/io.obj $(TEST_DIR)/unit_tests.c
	@if not exist $(TEST_DIR) mkdir $(TEST_DIR)
	"$(CC)" $(CFLAGS) $(TEST_DIR)/unit_tests.c $(SRC_DIR)/math.obj $(SRC_DIR)/io.obj -o $(TEST_DIR)/unit_tests.exe
	@echo Running unit tests...
	@$(TEST_DIR)/unit_tests.exe

# Environment Verification target
check-env:
	@echo ===================================================
	@echo   Verifying Build Environment...
	@echo ===================================================
	@if not exist "$(NASM)" ( \
		echo ERROR: NASM not found at $(NASM) && exit 1 \
	) else ( \
		"$(NASM)" -v \
	)
	@if not exist "$(CC)" ( \
		echo ERROR: 32-bit GCC not found at $(CC) && exit 1 \
	) else ( \
		"$(CC)" -v \
	)
	@echo Toolchain verified successfully.
	@echo.

# Cleanup target
clean:
	@echo Cleaning build artifacts...
	@if exist $(SRC_DIR)\math.obj del /q $(SRC_DIR)\math.obj
	@if exist $(SRC_DIR)\io.obj del /q $(SRC_DIR)\io.obj
	@if exist $(SRC_DIR)\main.obj del /q $(SRC_DIR)\main.obj
	@if exist ASMCalc.exe del /q ASMCalc.exe
	@if exist $(TEST_DIR)\unit_tests.exe del /q $(TEST_DIR)\unit_tests.exe
	@if exist $(TEST_DIR)\unit_tests.obj del /q $(TEST_DIR)\unit_tests.obj
	@echo Done.

.PHONY: all build test clean check-env
