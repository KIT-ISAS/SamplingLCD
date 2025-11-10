include_guard(GLOBAL)

if(WIN32 AND NOT EXISTS "C:/vcpkg/vcpkg.exe")
    message(STATUS "vcpkg not found. Installing...")

    execute_process(COMMAND git clone https://github.com/microsoft/vcpkg.git C:/vcpkg
                    RESULT_VARIABLE GIT_CLONE_FAILED)
    if(GIT_CLONE_FAILED)
        message(FATAL_ERROR "Failed to clone vcpkg.")
    endif()

    execute_process(COMMAND C:/vcpkg/bootstrap-vcpkg.bat
                    RESULT_VARIABLE VCPKG_BOOTSTRAP_FAILED)
    if(VCPKG_BOOTSTRAP_FAILED)
        message(FATAL_ERROR "Failed to bootstrap vcpkg.")
    endif()

    message(STATUS "vcpkg installed successfully.")
else()
    message(STATUS "vcpkg found.")
endif()

# Set vcpkg toolchain
set(CMAKE_TOOLCHAIN_FILE "C:/vcpkg/scripts/buildsystems/vcpkg.cmake" CACHE STRING "")
