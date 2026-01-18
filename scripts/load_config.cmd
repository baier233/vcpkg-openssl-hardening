@echo off
REM ============================================
REM Load Configuration Helper
REM ============================================
REM This script loads user configuration and auto-detects paths.
REM Called by other scripts via: call "%~dp0load_config.cmd"
REM ============================================

REM Load user config if exists
if exist "%~dp0config.cmd" (
    call "%~dp0config.cmd"
)

REM ============================================
REM Auto-detect Visual Studio
REM ============================================
if not defined VS_PATH (
    if exist "C:\Program Files\Microsoft Visual Studio\2022\Community" (
        set "VS_PATH=C:\Program Files\Microsoft Visual Studio\2022\Community"
    ) else if exist "C:\Program Files\Microsoft Visual Studio\2022\Professional" (
        set "VS_PATH=C:\Program Files\Microsoft Visual Studio\2022\Professional"
    ) else if exist "C:\Program Files\Microsoft Visual Studio\2022\Enterprise" (
        set "VS_PATH=C:\Program Files\Microsoft Visual Studio\2022\Enterprise"
    )
)

REM Auto-detect MSVC version
if not defined MSVC_VERSION (
    if defined VS_PATH (
        for /d %%i in ("%VS_PATH%\VC\Tools\MSVC\*") do set "MSVC_VERSION=%%~nxi"
    )
)

REM ============================================
REM Auto-detect Windows SDK
REM ============================================
if not defined WINSDK_PATH (
    if exist "C:\Program Files (x86)\Windows Kits\10" (
        set "WINSDK_PATH=C:\Program Files (x86)\Windows Kits\10"
    )
)

if not defined WINSDK_VERSION (
    if defined WINSDK_PATH (
        for /d %%i in ("%WINSDK_PATH%\Include\10.*") do set "WINSDK_VERSION=%%~nxi"
    )
)

REM ============================================
REM Set derived paths
REM ============================================
if defined VS_PATH (
    set "VCVARS64_PATH=%VS_PATH%\VC\Auxiliary\Build\vcvars64.bat"
)

if not defined HIKARI_CONFIG_FILE (
    set "HIKARI_CONFIG_FILE=%~dp0..\toolchains\obf_cfg.json"
)

REM ============================================
REM Validate required configuration
REM ============================================
:validate
exit /b 0
