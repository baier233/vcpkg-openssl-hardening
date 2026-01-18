# vcpkg-openssl-hardening

Security hardening patches for OpenSSL builds via vcpkg. Strips sensitive build information from compiled binaries to prevent reverse engineering and fingerprinting.

## Features

- **Strip Build Paths**: Removes vcpkg installation paths from binaries
- **Strip Version Info**: Clears compiler flags, build dates, and platform info
- **Strip Directory Paths**: Removes OPENSSLDIR, ENGINESDIR, MODULESDIR from binaries
- **LLVM Hikari Support**: Optional code obfuscation with Hikari LLVM passes
- **Static CRT Linkage**: Single self-contained executable without runtime dependencies

## What Gets Stripped

| Before | After |
|--------|-------|
| `C:\path\to\vcpkg\packages\openssl_x64-windows-static-llvm-hikari` | (empty) |
| `compiler: clang-cl.exe /nologo /DWIN32 ...` | (empty) |
| `built on: Jan 17 2026 UTC` | (empty) |
| `platform: VC-WIN64A` | (empty) |
| `OPENSSLDIR: "C:\path\to\vcpkg\..."` | (empty) |
| `ENGINESDIR: "C:\path\to\vcpkg\...\engines-3"` | (empty) |
| `MODULESDIR: "C:\path\to\vcpkg\...\bin"` | (empty) |

## Requirements

- Windows 10/11 x64
- Visual Studio 2022 (Community, Professional, or Enterprise)
- vcpkg (https://github.com/microsoft/vcpkg)
- LLVM with Hikari obfuscation passes

## Installation

### Quick Install

```batch
git clone https://github.com/yourusername/vcpkg-openssl-hardening.git
cd vcpkg-openssl-hardening

REM 1. Copy config template and edit with your paths
copy scripts\config.template.cmd scripts\config.cmd
notepad scripts\config.cmd

REM 2. Run installation
scripts\install.cmd
```

### Configuration

Copy `scripts\config.template.cmd` to `scripts\config.cmd` and edit the paths:

```batch
REM Required - Set these to your installation paths
set "VCPKG_ROOT=C:\path\to\vcpkg"
set "LLVM_HIKARI_ROOT=C:\path\to\llvm-hikari"

REM Optional - Auto-detected if not set
REM set "VS_PATH=C:\Program Files\Microsoft Visual Studio\2022\Community"
REM set "MSVC_VERSION=14.xx.xxxxx"
REM set "WINSDK_VERSION=10.0.xxxxx.0"
```

**Environment Variables:**

| Variable | Required | Description |
|----------|----------|-------------|
| `VCPKG_ROOT` | Yes | Path to vcpkg installation |
| `LLVM_HIKARI_ROOT` | Yes | Path to LLVM Hikari installation |
| `VS_PATH` | No | Path to Visual Studio (auto-detected) |
| `MSVC_VERSION` | No | MSVC tools version (auto-detected) |
| `WINSDK_PATH` | No | Path to Windows SDK (auto-detected) |
| `WINSDK_VERSION` | No | Windows SDK version (auto-detected) |
| `HIKARI_CONFIG_FILE` | No | Path to Hikari config (defaults to toolchains/obf_cfg.json) |

### Manual Install

1. Copy triplet:
   ```
   triplets\x64-windows-static-llvm-hikari.cmake -> %VCPKG_ROOT%\triplets\community\
   ```

2. Copy toolchain:
   ```
   toolchains\llvm-hikari-windows.cmake -> %VCPKG_ROOT%\scripts\toolchains\
   toolchains\obf_cfg.json -> %VCPKG_ROOT%\scripts\toolchains\
   ```

3. Copy patch:
   ```
   patches\disable-openssl-version-info.patch -> %VCPKG_ROOT%\ports\openssl\
   ```

4. Add patch to `%VCPKG_ROOT%\ports\openssl\portfile.cmake`:
   ```cmake
   vcpkg_from_github(
       ...
       PATCHES
           disable-openssl-version-info.patch  # Add this line
           cmake-config.patch
           ...
   )
   ```

## Usage

### Build OpenSSL

```batch
REM From Developer Command Prompt
scripts\build.cmd

REM Or manually
vcpkg install openssl:x64-windows-static-llvm-hikari --no-binarycaching
```

### Verify Build

```batch
scripts\test.cmd
```

Expected output:
```
=== OpenSSL Version Info Test ===

OpenSSL_version(OPENSSL_VERSION): ''
OpenSSL_version(OPENSSL_CFLAGS): ''
OpenSSL_version(OPENSSL_BUILT_ON): ''
OpenSSL_version(OPENSSL_PLATFORM): ''
OpenSSL_version(OPENSSL_DIR): ''
OpenSSL_version(OPENSSL_ENGINES_DIR): ''
OpenSSL_version(OPENSSL_MODULES_DIR): ''

=== Expected: All values should be empty or null ===
```

### Use in Your Project

#### Visual Studio Project

1. Add include directory:
   ```
   %VCPKG_ROOT%\installed\x64-windows-static-llvm-hikari\include
   ```

2. Add library directory:
   ```
   %VCPKG_ROOT%\installed\x64-windows-static-llvm-hikari\lib
   ```

3. Link libraries:
   ```
   libssl.lib
   libcrypto.lib
   crypt32.lib
   ws2_32.lib
   advapi32.lib
   user32.lib
   ```

#### CMake Project

```cmake
set(VCPKG_TARGET_TRIPLET "x64-windows-static-llvm-hikari")
find_package(OpenSSL REQUIRED)
target_link_libraries(your_target PRIVATE OpenSSL::SSL OpenSSL::Crypto)
```

## Project Structure

```
vcpkg-openssl-hardening/
├── patches/
│   └── disable-openssl-version-info.patch   # Main hardening patch
├── triplets/
│   └── x64-windows-static-llvm-hikari.cmake # Custom vcpkg triplet
├── toolchains/
│   ├── llvm-hikari-windows.cmake            # LLVM Hikari CMake toolchain
│   └── obf_cfg.json                         # Hikari obfuscation config
├── scripts/
│   ├── config.template.cmd                  # Configuration template (copy to config.cmd)
│   ├── config.cmd                           # User configuration (git-ignored)
│   ├── load_config.cmd                      # Configuration loader
│   ├── install.cmd                          # Installation script
│   ├── build.cmd                            # Build script
│   └── test.cmd                             # Verification script
├── test/
│   └── test_openssl_version.c               # Test program
└── README.md
```

## Patch Details

The `disable-openssl-version-info.patch` modifies these files:

1. **`Configurations/windows-makefile.tmpl`**
   - Changes `-D"OPENSSLDIR=\"$openssldir\""` to `-D"OPENSSLDIR=\"\""`
   - Same for ENGINESDIR and MODULESDIR

2. **`crypto/cversion.c`**
   - Makes `OpenSSL_version()` return empty strings for all queries

3. **`crypto/defaults.c`**
   - Makes `ossl_get_openssldir()`, `ossl_get_enginesdir()`, `ossl_get_modulesdir()` return empty strings

4. **`util/mkbuildinf.pl`**
   - Clears platform, compiler flags, and build date from generated buildinf.h

## Hikari Obfuscation

The included toolchain supports LLVM Hikari obfuscation passes. Configure in `toolchains/obf_cfg.json`:

```json
{
  "randomSeed": "your-unique-seed-here",
  "indbr": { "enable": true, "level": 1 },
  "icall": { "enable": true, "level": 1 },
  "indgv": { "enable": true, "level": 1 },
  "cie": { "enable": true, "level": 1 },
  "cfe": { "enable": true, "level": 1 },
  "fla": { "enable": true },
  "cse": { "enable": true },
  "rtti": { "enable": true }
}
```

## Customization

### Change Paths

Edit `scripts/config.cmd` to set your paths:
```batch
set "VCPKG_ROOT=C:\path\to\vcpkg"
set "LLVM_HIKARI_ROOT=C:\path\to\llvm-hikari"
set "VS_PATH=C:\Program Files\Microsoft Visual Studio\2022\Enterprise"
```

Or set environment variables before running scripts:
```batch
set VCPKG_ROOT=C:\path\to\vcpkg
set LLVM_HIKARI_ROOT=C:\path\to\llvm-hikari
scripts\build.cmd
```

### Disable Obfuscation

Create a triplet without Hikari by removing the toolchain chainload:
```cmake
set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE static)
set(VCPKG_LIBRARY_LINKAGE static)
# No VCPKG_CHAINLOAD_TOOLCHAIN_FILE = use standard MSVC
```

## License

MIT License - See LICENSE file for details.