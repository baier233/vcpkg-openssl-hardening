# LLVM + Hikari Obfuscation Toolchain for Windows (MSVC ABI compatible)
# This toolchain uses clang-cl.exe as a drop-in replacement for cl.exe
# with Hikari LLVM obfuscation passes enabled.
#
# Required environment variables:
#   LLVM_HIKARI_ROOT    - Path to LLVM Hikari installation (e.g., C:/llvm-msvc_X86_64)
#
# Optional environment variables (auto-detected if not set):
#   VS_PATH             - Path to Visual Studio (e.g., C:/Program Files/Microsoft Visual Studio/2022/Community)
#   MSVC_VERSION        - MSVC tools version (e.g., 14.44.35207)
#   WINSDK_PATH         - Path to Windows SDK (e.g., C:/Program Files (x86)/Windows Kits/10)
#   WINSDK_VERSION      - Windows SDK version (e.g., 10.0.26100.0)
#   HIKARI_CONFIG_FILE  - Path to Hikari obfuscation config file

if(NOT _VCPKG_LLVM_HIKARI_WINDOWS_TOOLCHAIN)
    set(_VCPKG_LLVM_HIKARI_WINDOWS_TOOLCHAIN 1)

    # ============================================================
    # LLVM Hikari Toolchain Paths (Required)
    # ============================================================
    if(DEFINED ENV{LLVM_HIKARI_ROOT})
        file(TO_CMAKE_PATH "$ENV{LLVM_HIKARI_ROOT}" LLVM_HIKARI_ROOT)
        string(STRIP "${LLVM_HIKARI_ROOT}" LLVM_HIKARI_ROOT)
    else()
        message(FATAL_ERROR "LLVM_HIKARI_ROOT environment variable is not set. "
            "Please set it to your LLVM Hikari installation path.")
    endif()

    # Hikari configuration file path
    if(DEFINED ENV{HIKARI_CONFIG_FILE})
        set(HIKARI_CONFIG_FILE "$ENV{HIKARI_CONFIG_FILE}")
    else()
        set(HIKARI_CONFIG_FILE "${CMAKE_CURRENT_LIST_DIR}/obf_cfg.json")
    endif()

    # ============================================================
    # Find Visual Studio (auto-detect or use environment variable)
    # ============================================================
    if(DEFINED ENV{VS_PATH})
        file(TO_CMAKE_PATH "$ENV{VS_PATH}" VS_PATH)
    else()
        # Auto-detect Visual Studio 2022
        set(_VS_CANDIDATES
            "C:/Program Files/Microsoft Visual Studio/2022/Community"
            "C:/Program Files/Microsoft Visual Studio/2022/Professional"
            "C:/Program Files/Microsoft Visual Studio/2022/Enterprise"
        )
        set(VS_PATH "")
        foreach(_VS_CANDIDATE ${_VS_CANDIDATES})
            if(EXISTS "${_VS_CANDIDATE}")
                set(VS_PATH "${_VS_CANDIDATE}")
                break()
            endif()
        endforeach()
        if(NOT VS_PATH)
            message(FATAL_ERROR "Visual Studio 2022 not found. "
                "Please set VS_PATH environment variable to your Visual Studio installation path.")
        endif()
    endif()

    # Auto-detect MSVC version or use environment variable
    if(DEFINED ENV{MSVC_VERSION})
        set(MSVC_VERSION "$ENV{MSVC_VERSION}")
    else()
        # Auto-detect: find the latest MSVC version
        file(GLOB _MSVC_VERSIONS "${VS_PATH}/VC/Tools/MSVC/*")
        if(_MSVC_VERSIONS)
            list(SORT _MSVC_VERSIONS ORDER DESCENDING)
            list(GET _MSVC_VERSIONS 0 _MSVC_LATEST)
            get_filename_component(MSVC_VERSION "${_MSVC_LATEST}" NAME)
        else()
            message(FATAL_ERROR "MSVC tools not found in ${VS_PATH}/VC/Tools/MSVC/. "
                "Please set MSVC_VERSION environment variable.")
        endif()
    endif()
    set(MSVC_PATH "${VS_PATH}/VC/Tools/MSVC/${MSVC_VERSION}")

    # ============================================================
    # Find Windows SDK (auto-detect or use environment variable)
    # ============================================================
    if(DEFINED ENV{WINSDK_PATH})
        file(TO_CMAKE_PATH "$ENV{WINSDK_PATH}" WINSDK_PATH)
    else()
        # Default Windows SDK path
        set(WINSDK_PATH "C:/Program Files (x86)/Windows Kits/10")
        if(NOT EXISTS "${WINSDK_PATH}")
            message(FATAL_ERROR "Windows SDK not found at ${WINSDK_PATH}. "
                "Please set WINSDK_PATH environment variable.")
        endif()
    endif()

    if(DEFINED ENV{WINSDK_VERSION})
        set(WINSDK_VERSION "$ENV{WINSDK_VERSION}")
    else()
        # Auto-detect: find the latest Windows SDK version
        file(GLOB _WINSDK_VERSIONS "${WINSDK_PATH}/Include/10.*")
        if(_WINSDK_VERSIONS)
            list(SORT _WINSDK_VERSIONS ORDER DESCENDING)
            list(GET _WINSDK_VERSIONS 0 _WINSDK_LATEST)
            get_filename_component(WINSDK_VERSION "${_WINSDK_LATEST}" NAME)
        else()
            message(FATAL_ERROR "Windows SDK versions not found in ${WINSDK_PATH}/Include/. "
                "Please set WINSDK_VERSION environment variable.")
        endif()
    endif()

    # Print detected configuration
    message(STATUS "LLVM Hikari Toolchain Configuration:")
    message(STATUS "  LLVM_HIKARI_ROOT: ${LLVM_HIKARI_ROOT}")
    message(STATUS "  VS_PATH: ${VS_PATH}")
    message(STATUS "  MSVC_VERSION: ${MSVC_VERSION}")
    message(STATUS "  WINSDK_PATH: ${WINSDK_PATH}")
    message(STATUS "  WINSDK_VERSION: ${WINSDK_VERSION}")

    # ============================================================
    # Compiler and Linker Paths
    # ============================================================
    set(LLVM_BIN_DIR "${LLVM_HIKARI_ROOT}/bin")

    set(CMAKE_C_COMPILER "${LLVM_BIN_DIR}/clang-cl.exe" CACHE FILEPATH "C compiler" FORCE)
    set(CMAKE_CXX_COMPILER "${LLVM_BIN_DIR}/clang-cl.exe" CACHE FILEPATH "C++ compiler" FORCE)
    set(CMAKE_LINKER "${LLVM_BIN_DIR}/lld-link.exe" CACHE FILEPATH "Linker" FORCE)
    set(CMAKE_AR "${LLVM_BIN_DIR}/llvm-lib.exe" CACHE FILEPATH "Archiver" FORCE)
    set(CMAKE_RC_COMPILER "rc.exe" CACHE FILEPATH "Resource compiler" FORCE)

    # ============================================================
    # Set INCLUDE and LIB environment variables for clang-cl/lld-link
    # ============================================================
    set(MSVC_INCLUDE "${MSVC_PATH}/include")
    set(UCRT_INCLUDE "${WINSDK_PATH}/Include/${WINSDK_VERSION}/ucrt")
    set(SHARED_INCLUDE "${WINSDK_PATH}/Include/${WINSDK_VERSION}/shared")
    set(UM_INCLUDE "${WINSDK_PATH}/Include/${WINSDK_VERSION}/um")
    set(WINRT_INCLUDE "${WINSDK_PATH}/Include/${WINSDK_VERSION}/winrt")

    set(MSVC_LIB "${MSVC_PATH}/lib/x64")
    set(UCRT_LIB "${WINSDK_PATH}/Lib/${WINSDK_VERSION}/ucrt/x64")
    set(UM_LIB "${WINSDK_PATH}/Lib/${WINSDK_VERSION}/um/x64")

    # Set environment variables
    set(ENV{INCLUDE} "${MSVC_INCLUDE};${UCRT_INCLUDE};${SHARED_INCLUDE};${UM_INCLUDE};${WINRT_INCLUDE}")
    set(ENV{LIB} "${MSVC_LIB};${UCRT_LIB};${UM_LIB}")
    set(ENV{PATH} "${LLVM_BIN_DIR};${MSVC_PATH}/bin/Hostx64/x64;${WINSDK_PATH}/bin/${WINSDK_VERSION}/x64;$ENV{PATH}")

    # ============================================================
    # CMake Policies
    # ============================================================
    if(POLICY CMP0056)
        cmake_policy(SET CMP0056 NEW)
    endif()
    if(POLICY CMP0066)
        cmake_policy(SET CMP0066 NEW)
    endif()
    if(POLICY CMP0067)
        cmake_policy(SET CMP0067 NEW)
    endif()
    if(POLICY CMP0137)
        cmake_policy(SET CMP0137 NEW)
    endif()

    # ============================================================
    # Platform Configuration
    # ============================================================
    list(APPEND CMAKE_TRY_COMPILE_PLATFORM_VARIABLES
        VCPKG_CRT_LINKAGE VCPKG_TARGET_ARCHITECTURE
        VCPKG_C_FLAGS VCPKG_CXX_FLAGS
        VCPKG_C_FLAGS_DEBUG VCPKG_CXX_FLAGS_DEBUG
        VCPKG_C_FLAGS_RELEASE VCPKG_CXX_FLAGS_RELEASE
        VCPKG_LINKER_FLAGS VCPKG_LINKER_FLAGS_RELEASE VCPKG_LINKER_FLAGS_DEBUG
    )

    set(CMAKE_SYSTEM_NAME Windows CACHE STRING "")

    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set(CMAKE_SYSTEM_PROCESSOR x86 CACHE STRING "")
        set(CLANG_TARGET_TRIPLE "i686-pc-windows-msvc")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(CMAKE_SYSTEM_PROCESSOR AMD64 CACHE STRING "")
        set(CLANG_TARGET_TRIPLE "x86_64-pc-windows-msvc")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(CMAKE_SYSTEM_PROCESSOR ARM64 CACHE STRING "")
        set(CLANG_TARGET_TRIPLE "aarch64-pc-windows-msvc")
    endif()

    if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
        set(CMAKE_CROSSCOMPILING OFF CACHE STRING "")
    endif()

    # ============================================================
    # CRT Linkage Configuration
    # ============================================================
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>$<$<STREQUAL:${VCPKG_CRT_LINKAGE},dynamic>:DLL>" CACHE STRING "")

    if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
        set(VCPKG_CRT_LINK_FLAG_PREFIX "/MD")
    elseif(VCPKG_CRT_LINKAGE STREQUAL "static")
        set(VCPKG_CRT_LINK_FLAG_PREFIX "/MT")
    else()
        message(FATAL_ERROR "Invalid VCPKG_CRT_LINKAGE: ${VCPKG_CRT_LINKAGE}")
    endif()

    # ============================================================
    # Hikari LLVM Obfuscation Flags
    # ============================================================
    string(REPLACE "\\" "/" HIKARI_CONFIG_FILE_UNIX "${HIKARI_CONFIG_FILE}")

    # Check if Hikari supports config file or use individual flags
    if(EXISTS "${HIKARI_CONFIG_FILE}")
        set(HIKARI_FLAGS "-mllvm -hikari-cfg=${HIKARI_CONFIG_FILE_UNIX}")
    else()
        # Fallback to individual flags if config file doesn't exist
        set(HIKARI_FLAGS "")
        message(WARNING "Hikari config file not found: ${HIKARI_CONFIG_FILE}")
    endif()

    # ============================================================
    # Compiler Flags
    # ============================================================
    set(CLANG_CL_FLAGS "--target=${CLANG_TARGET_TRIPLE} -fms-compatibility -fms-extensions -fms-compatibility-version=19.44")

    # Include paths as compiler flags
    set(INCLUDE_FLAGS "/I\"${MSVC_INCLUDE}\" /I\"${UCRT_INCLUDE}\" /I\"${SHARED_INCLUDE}\" /I\"${UM_INCLUDE}\"")

    set(CMAKE_C_FLAGS "/nologo /DWIN32 /D_WINDOWS /utf-8 ${CLANG_CL_FLAGS} ${INCLUDE_FLAGS} ${HIKARI_FLAGS} ${VCPKG_C_FLAGS}" CACHE STRING "" FORCE)
    set(CMAKE_CXX_FLAGS "/nologo /DWIN32 /D_WINDOWS /utf-8 /GR /EHsc ${CLANG_CL_FLAGS} ${INCLUDE_FLAGS} ${HIKARI_FLAGS} ${VCPKG_CXX_FLAGS}" CACHE STRING "" FORCE)
    set(CMAKE_RC_FLAGS "-c65001 /DWIN32" CACHE STRING "")

    set(CMAKE_C_FLAGS_DEBUG "${VCPKG_CRT_LINK_FLAG_PREFIX}d /Z7 /Ob0 /Od ${VCPKG_C_FLAGS_DEBUG}" CACHE STRING "" FORCE)
    set(CMAKE_CXX_FLAGS_DEBUG "${VCPKG_CRT_LINK_FLAG_PREFIX}d /Z7 /Ob0 /Od ${VCPKG_CXX_FLAGS_DEBUG}" CACHE STRING "" FORCE)
    set(CMAKE_C_FLAGS_RELEASE "${VCPKG_CRT_LINK_FLAG_PREFIX} /O2 /DNDEBUG ${VCPKG_C_FLAGS_RELEASE}" CACHE STRING "" FORCE)
    set(CMAKE_CXX_FLAGS_RELEASE "${VCPKG_CRT_LINK_FLAG_PREFIX} /O2 /DNDEBUG ${VCPKG_CXX_FLAGS_RELEASE}" CACHE STRING "" FORCE)

    # ============================================================
    # Linker Flags
    # ============================================================
    set(LIB_PATH_FLAGS "/LIBPATH:\"${MSVC_LIB}\" /LIBPATH:\"${UCRT_LIB}\" /LIBPATH:\"${UM_LIB}\"")

    set(CMAKE_EXE_LINKER_FLAGS "/nologo ${LIB_PATH_FLAGS} ${VCPKG_LINKER_FLAGS}" CACHE STRING "" FORCE)
    set(CMAKE_SHARED_LINKER_FLAGS "/nologo ${LIB_PATH_FLAGS} ${VCPKG_LINKER_FLAGS}" CACHE STRING "" FORCE)
    set(CMAKE_MODULE_LINKER_FLAGS "/nologo ${LIB_PATH_FLAGS} ${VCPKG_LINKER_FLAGS}" CACHE STRING "" FORCE)
    set(CMAKE_STATIC_LINKER_FLAGS "/nologo" CACHE STRING "" FORCE)

    set(CMAKE_EXE_LINKER_FLAGS_RELEASE "/DEBUG /INCREMENTAL:NO /OPT:REF /OPT:ICF ${VCPKG_LINKER_FLAGS_RELEASE}" CACHE STRING "" FORCE)
    set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "/DEBUG /INCREMENTAL:NO /OPT:REF /OPT:ICF ${VCPKG_LINKER_FLAGS_RELEASE}" CACHE STRING "" FORCE)
    set(CMAKE_EXE_LINKER_FLAGS_DEBUG "${VCPKG_LINKER_FLAGS_DEBUG}" CACHE STRING "" FORCE)
    set(CMAKE_SHARED_LINKER_FLAGS_DEBUG "${VCPKG_LINKER_FLAGS_DEBUG}" CACHE STRING "" FORCE)

    # Cleanup
    unset(VCPKG_CRT_LINK_FLAG_PREFIX)
endif()
