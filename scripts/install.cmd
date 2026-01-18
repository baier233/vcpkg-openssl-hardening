@echo off
REM OpenSSL Hardening Installation Script
REM This script installs the custom triplet, toolchain, and patches to vcpkg

setlocal enabledelayedexpansion

REM Load configuration
call "%~dp0load_config.cmd"

REM Check if VCPKG_ROOT is set
if "%VCPKG_ROOT%"=="" (
    echo ERROR: VCPKG_ROOT not set.
    echo Please set VCPKG_ROOT in scripts\config.cmd or as environment variable.
    exit /b 1
)

if not exist "%VCPKG_ROOT%\vcpkg.exe" (
    echo ERROR: vcpkg.exe not found at: %VCPKG_ROOT%
    echo Please verify VCPKG_ROOT in scripts\config.cmd
    exit /b 1
)

echo ============================================
echo OpenSSL Hardening Installation
echo ============================================
echo VCPKG_ROOT: %VCPKG_ROOT%
echo.

REM Create directories if they don't exist
if not exist "%VCPKG_ROOT%\triplets\community" mkdir "%VCPKG_ROOT%\triplets\community"
if not exist "%VCPKG_ROOT%\scripts\toolchains" mkdir "%VCPKG_ROOT%\scripts\toolchains"

REM Copy triplet
echo [1/5] Installing custom triplet...
copy /Y "%~dp0..\triplets\x64-windows-static-llvm-hikari.cmake" "%VCPKG_ROOT%\triplets\community\" >nul
if errorlevel 1 (
    echo ERROR: Failed to copy triplet file
    exit /b 1
)
echo       Done.

REM Copy toolchain
echo [2/5] Installing LLVM Hikari toolchain...
copy /Y "%~dp0..\toolchains\llvm-hikari-windows.cmake" "%VCPKG_ROOT%\scripts\toolchains\" >nul
if errorlevel 1 (
    echo ERROR: Failed to copy toolchain file
    exit /b 1
)
echo       Done.

REM Copy obfuscation config
echo [3/5] Installing Hikari obfuscation config...
copy /Y "%~dp0..\toolchains\obf_cfg.json" "%VCPKG_ROOT%\scripts\toolchains\" >nul
if errorlevel 1 (
    echo ERROR: Failed to copy obfuscation config
    exit /b 1
)
echo       Done.

REM Copy OpenSSL patch
echo [4/5] Installing OpenSSL hardening patch...
copy /Y "%~dp0..\patches\disable-openssl-version-info.patch" "%VCPKG_ROOT%\ports\openssl\" >nul
if errorlevel 1 (
    echo ERROR: Failed to copy OpenSSL patch
    exit /b 1
)
echo       Done.

REM Update OpenSSL portfile.cmake to include the patch
echo [5/5] Updating OpenSSL portfile.cmake...
findstr /C:"disable-openssl-version-info.patch" "%VCPKG_ROOT%\ports\openssl\portfile.cmake" >nul 2>&1
if errorlevel 1 (
    REM Patch not yet added, need to add it
    powershell -Command "(Get-Content '%VCPKG_ROOT%\ports\openssl\portfile.cmake') -replace '(vcpkg_from_github.*?PATCHES)', \"`$1`n        disable-openssl-version-info.patch\" | Set-Content '%VCPKG_ROOT%\ports\openssl\portfile.cmake'"
    echo       Patch reference added to portfile.cmake
) else (
    echo       Patch reference already exists in portfile.cmake
)
echo       Done.

echo.
echo ============================================
echo Installation Complete!
echo ============================================
echo.
echo Next steps:
echo   1. Build OpenSSL with: vcpkg install openssl:x64-windows-static-llvm-hikari
echo   2. Run test with: scripts\test.cmd
echo.

endlocal
