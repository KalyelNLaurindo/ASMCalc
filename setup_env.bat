@echo off
echo ===================================================
echo   ASMCalc - Environment Bootstrap Script
echo ===================================================
echo Installing NASM and MinGW (GCC) via Chocolatey...
echo NOTE: This script requires administrator privileges.
echo.

choco install nasm mingw -y

if %errorlevel% neq 0 (
    echo.
    echo ERROR: Installation failed. Please run this script in an Elevated Command Prompt (Administrator).
    exit /b %errorlevel%
)

echo.
echo Environment tools installed successfully!
echo Please restart your terminal/IDE to refresh environment variables.
exit /b 0
