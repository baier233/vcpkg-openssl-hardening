@echo off
REM ============================================
REM OpenSSL Hardening Configuration Template
REM ============================================
REM Copy this file to config.cmd and fill in your paths.
REM
REM Required environment variables:
REM   - VCPKG_ROOT: Path to vcpkg installation
REM   - LLVM_HIKARI_ROOT: Path to LLVM Hikari installation
REM
REM Optional environment variables (auto-detected if not set):
REM   - VS_PATH: Path to Visual Studio installation
REM   - MSVC_VERSION: MSVC tools version (e.g., 14.44.35207)
REM   - WINSDK_VERSION: Windows SDK version (e.g., 10.0.26100.0)
REM   - WINSDK_PATH: Path to Windows SDK
REM   - HIKARI_CONFIG_FILE: Path to Hikari obfuscation config
REM ============================================

REM ============================================
REM Required Configuration (MUST be set)
REM ============================================

REM Path to vcpkg installation
if not defined VCPKG_ROOT set "VCPKG_ROOT=C:\path\to\vcpkg"

REM Path to LLVM Hikari installation
if not defined LLVM_HIKARI_ROOT set "LLVM_HIKARI_ROOT=C:\path\to\llvm-hikari"

REM ============================================
REM Optional Configuration (auto-detected if not set)
REM ============================================

REM Visual Studio path (auto-detected: Community, Professional, Enterprise)
REM if not defined VS_PATH set "VS_PATH=C:\Program Files\Microsoft Visual Studio\2022\Community"

REM MSVC tools version (auto-detected from VS installation)
REM if not defined MSVC_VERSION set "MSVC_VERSION=14.xx.xxxxx"

REM Windows SDK version (auto-detected)
REM if not defined WINSDK_VERSION set "WINSDK_VERSION=10.0.xxxxx.0"

REM Windows SDK path
REM if not defined WINSDK_PATH set "WINSDK_PATH=C:\Program Files (x86)\Windows Kits\10"

REM Hikari obfuscation config file path
REM if not defined HIKARI_CONFIG_FILE set "HIKARI_CONFIG_FILE=%~dp0..\toolchains\obf_cfg.json"
