include_guard(GLOBAL)

if(WIN32)
    include(${CMAKE_SOURCE_DIR}/cmake/InstallVcpkg.cmake)  # Ensure vcpkg is installed

    if (MSVC)
        set(VCPKG_TARGET_TRIPLETS "x64-windows")
    elseif (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        set(VCPKG_TARGET_TRIPLETS "x64-mingw-static")
    else()
        message(FATAL_ERROR "Unsupported Windows compiler: ${CMAKE_CXX_COMPILER_ID}")
    endif()

    # Check if packages are installed
    execute_process(
        COMMAND C:/vcpkg/vcpkg list
        OUTPUT_VARIABLE INSTALLED_PACKAGES
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    foreach(TRIPLET ${VCPKG_TARGET_TRIPLETS})
        foreach(PKG IN ITEMS gtest benchmark)
            if(NOT INSTALLED_PACKAGES MATCHES "${PKG}:${TRIPLET}")
                message(STATUS "Installing ${PKG}:${TRIPLET} via vcpkg...")
                execute_process(COMMAND C:/vcpkg/vcpkg install ${PKG}:${TRIPLET})
            else()
                message(STATUS "${PKG}:${TRIPLET} is already installed.")
            endif()
        endforeach()
    endforeach()

else() # UNIX or non-Windows platforms
    include(FetchContent)
    # Set benchmark options BEFORE FetchContent_MakeAvailable
    set(BENCHMARK_ENABLE_TESTING OFF CACHE BOOL "" FORCE)
    set(BENCHMARK_ENABLE_GTEST_TESTS OFF CACHE BOOL "" FORCE)

    FetchContent_Declare(
        googletest
        URL https://github.com/google/googletest/archive/refs/tags/v1.14.0.zip
    )

    FetchContent_Declare(
        benchmark
        URL https://github.com/google/benchmark/archive/refs/tags/v1.8.3.zip
    )

    FetchContent_MakeAvailable(googletest benchmark)
endif()