include_guard(GLOBAL)

if(WIN32)
    include(${CMAKE_SOURCE_DIR}/cmake/InstallVcpkg.cmake)  # Ensure vcpkg is installed

    if (MSVC)
        set(VCPKG_TARGET_TRIPLETS "x64-windows")
    elseif (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        set(VCPKG_TARGET_TRIPLETS "x64-mingw-static" "x64-mingw-dynamic")
    else()
        message(FATAL_ERROR "Unsupported Windows compiler: ${CMAKE_CXX_COMPILER_ID}")
    endif()

    # Check if GSL is already installed via vcpkg
    execute_process(
        COMMAND C:/vcpkg/vcpkg list
        OUTPUT_VARIABLE INSTALLED_PACKAGES
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    
    foreach(TRIPLET ${VCPKG_TARGET_TRIPLETS})
        if(NOT INSTALLED_PACKAGES MATCHES "gsl:${TRIPLET}")
            message(STATUS "Installing GSL:${TRIPLET} via vcpkg...")
            execute_process(COMMAND C:/vcpkg/vcpkg install gsl:${TRIPLET})
        else()
            message(STATUS "GSL:${TRIPLET} is already installed in vcpkg.")
        endif()
    endforeach()
    
elseif(UNIX)
    # Check if GSL is installed
    execute_process(
        COMMAND pkg-config --modversion gsl
        OUTPUT_VARIABLE GSL_VERSION
        OUTPUT_STRIP_TRAILING_WHITESPACE
        RESULT_VARIABLE GSL_CHECK
    )

    if(GSL_CHECK EQUAL 0)
        message(STATUS "GSL is already installed (Version: ${GSL_VERSION}).")
    else()
        message(STATUS "Installing GSL via package manager...")

        find_program(APT apt)
        find_program(DNF dnf)
        find_program(YUM yum)

        if(APT)
            execute_process(COMMAND sudo apt update)
            execute_process(COMMAND sudo apt install -y libgsl-dev)
        elseif(DNF)
            execute_process(COMMAND sudo dnf install -y gsl-devel)
        elseif(YUM)
            execute_process(COMMAND sudo yum install -y gsl-devel)
        else()
            message(FATAL_ERROR "No suitable package manager found. Please install GSL manually.")
        endif()
    endif()
endif()
