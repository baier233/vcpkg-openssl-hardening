@echo off
REM Build OpenSSL with hardening patches
REM Requires Visual Studio Developer Command Prompt or vcvars64.bat

setlocal enabledelayedexpansion

REM Load configuration
call "%~dp0load_config.cmd"

REM Initialize VS environment if not already done
where cl >nul 2>&1
if errorlevel 1 (
    if defined VCVARS64_PATH (
        if exist "!VCVARS64_PATH!" (
            call "!VCVARS64_PATH!" >nul 2>&1
        ) else (
            echo ERROR: Visual Studio not found at: !VCVARS64_PATH!
            echo Please set VS_PATH in scripts\config.cmd or run from Developer Command Prompt.
            exit /b 1
        )
    ) else (
        echo ERROR: Visual Studio not found. Please set VS_PATH in scripts\config.cmd
        echo or run from Developer Command Prompt.
        exit /b 1
    )
)

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
echo Building OpenSSL with Hardening Patches
echo ============================================
echo.
echo Configuration:
echo   VCPKG_ROOT: %VCPKG_ROOT%
echo   VS_PATH: %VS_PATH%
echo   LLVM_HIKARI_ROOT: %LLVM_HIKARI_ROOT%
echo.

REM Clear any cached builds
echo [1/3] Cleaning previous builds...
if exist "%VCPKG_ROOT%\buildtrees\openssl" rmdir /s /q "%VCPKG_ROOT%\buildtrees\openssl"
if exist "%VCPKG_ROOT%\packages\openssl_x64-windows-static-llvm-hikari" rmdir /s /q "%VCPKG_ROOT%\packages\openssl_x64-windows-static-llvm-hikari"
echo       Done.

REM Remove existing installation
echo [2/3] Removing existing OpenSSL installation...
"%VCPKG_ROOT%\vcpkg.exe" remove openssl:x64-windows-static-llvm-hikari --recurse 2>nul
echo       Done.

REM Build OpenSSL
echo [3/3] Building OpenSSL with hardening patches...
"%VCPKG_ROOT%\vcpkg.exe" install openssl:x64-windows-static-llvm-hikari --no-binarycaching
if errorlevel 1 (
    echo.
    echo ERROR: OpenSSL build failed!
    exit /b 1
)

echo.
echo ============================================
echo Build Complete!
echo ============================================
echo.
echo OpenSSL installed to: %VCPKG_ROOT%\installed\x64-windows-static-llvm-hikari
echo.
echo Run scripts\test.cmd to verify the build.
echo.

endlocal
