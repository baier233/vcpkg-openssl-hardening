# x64-windows-static-llvm-hikari.cmake
# Custom triplet for building with LLVM clang-cl + Hikari obfuscation
# Maintains MSVC ABI compatibility for static linking

set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE static)
set(VCPKG_LIBRARY_LINKAGE static)

# Use custom LLVM Hikari toolchain
set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${CMAKE_CURRENT_LIST_DIR}/../toolchains/llvm-hikari-windows.cmake")

# Pass environment variables to build process
set(VCPKG_ENV_PASSTHROUGH
    LLVM_HIKARI_ROOT
    HIKARI_CONFIG_FILE
    VS_PATH
    MSVC_VERSION
    WINSDK_PATH
    WINSDK_VERSION
    INCLUDE
    LIB
    PATH
)

# Skip dumpbin checks as LLVM-built binaries may differ slightly
set(VCPKG_POLICY_SKIP_DUMPBIN_CHECKS enabled)
