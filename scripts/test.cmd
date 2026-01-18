@echo off
REM Test script to verify OpenSSL hardening
REM Compiles test program and checks for sensitive strings

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

set "INSTALL_DIR=%VCPKG_ROOT%\installed\x64-windows-static-llvm-hikari"
set "PROJECT_DIR=%~dp0.."
set "TEST_DIR=%PROJECT_DIR%\test"

echo ============================================
echo OpenSSL Hardening Test
echo ============================================
echo.

REM Check if OpenSSL is installed
if not exist "%INSTALL_DIR%\lib\libcrypto.lib" (
    echo ERROR: OpenSSL not found at %INSTALL_DIR%
    echo Please run scripts\build.cmd first.
    exit /b 1
)

REM Compile test program
echo [1/4] Compiling test program...
cd /d "%TEST_DIR%"
cl /nologo /MT /I"%INSTALL_DIR%\include" test_openssl_version.c ^
    /link /LIBPATH:"%INSTALL_DIR%\lib" libssl.lib libcrypto.lib ^
    crypt32.lib ws2_32.lib advapi32.lib user32.lib ^
    /OUT:test_openssl.exe >nul 2>&1
if errorlevel 1 (
    echo ERROR: Compilation failed!
    exit /b 1
)
echo       Done.

REM Check for sensitive strings
echo [2/4] Checking for vcpkg paths in executable...
strings test_openssl.exe 2>nul | findstr /i "vcpkg packages openssl_x64" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo       WARNING: vcpkg paths found in executable!
    echo.
    echo       Found strings:
    strings test_openssl.exe 2>nul | findstr /i "vcpkg packages openssl_x64"
    echo.
    set "VCPKG_CHECK=FAIL"
) else (
    echo       PASS: No vcpkg paths found.
    set "VCPKG_CHECK=PASS"
)

echo [3/4] Checking for build paths in executable...
REM Check for common development path patterns
strings test_openssl.exe 2>nul | findstr /i "buildtrees" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo       WARNING: Build paths found in executable!
    set "PATH_CHECK=FAIL"
) else (
    echo       PASS: No build paths found.
    set "PATH_CHECK=PASS"
)

REM Run the test program
echo [4/4] Running version info test...
echo.
test_openssl.exe
echo.

REM Cleanup
del /q test_openssl.exe test_openssl.obj 2>nul

echo ============================================
echo Test Summary
echo ============================================
echo vcpkg paths check: %VCPKG_CHECK%
echo build paths check: %PATH_CHECK%
echo.

if "%VCPKG_CHECK%"=="PASS" if "%PATH_CHECK%"=="PASS" (
    echo All tests PASSED!
    exit /b 0
) else (
    echo Some tests FAILED. Please review the output above.
    exit /b 1
)

endlocal
