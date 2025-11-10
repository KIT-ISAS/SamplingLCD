cmake_minimum_required(VERSION 3.10)
project(LCDApproximationJuliaWrapper)

add_library(LCDApproximationJuliaWrapper MODULE julia_dirac_to_dirac.cpp julia_gm_to_dirac.cpp julia_approximation_options.cpp)

# Choose shared or static linking
target_link_libraries(LCDApproximationJuliaWrapper PRIVATE approxLCD_shared)

add_custom_command(TARGET LCDApproximationJuliaWrapper POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E remove_directory "${CMAKE_CURRENT_SOURCE_DIR}/LCDApproximationJulia/lib/"
    COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_CURRENT_SOURCE_DIR}/LCDApproximationJulia/lib/"
    COMMAND ${CMAKE_COMMAND} -E copy
        "$<TARGET_FILE:LCDApproximationJuliaWrapper>"
        "$<TARGET_FILE:approxLCD_shared>"
        "${CMAKE_CURRENT_SOURCE_DIR}/LCDApproximationJulia/lib/"
    COMMENT "Copying LCDApproximationJuliaWrapper, approxLCD to julia package"
)