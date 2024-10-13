# This example comes from https://eliemichel.github.io/LearnWebGPU
cmake_minimum_required(VERSION 3.11.0...3.25.0)
project(sdl2webgpu-examples VERSION 1.0.0 LANGUAGES C)

include(FetchContent)
include(utils.cmake)

# Dependencies
FetchContent_Declare(
  sdl2
  GIT_REPOSITORY https://github.com/libsdl-org/SDL.git
  GIT_TAG        release-2.28.5
)
FetchContent_Declare(
  webgpu
  GIT_REPOSITORY https://github.com/eliemichel/WebGPU-distribution.git
  GIT_TAG        7ed61fb96d972a4c61ccc79af1139eba2a0ce4c4  # fetch
)
FetchContent_MakeAvailable(sdl2 webgpu)

# The sdl2webgpu target
# NB: We specify a second argument only because this is an out-of-tree
# directory, no need to do this in your case.
add_subdirectory(.. sdl2webgpu)

# Example
add_executable(hello-sdl2webgpu hello-sdl2webgpu.c)
target_link_libraries(hello-sdl2webgpu PRIVATE SDL2::SDL2 webgpu sdl2webgpu)
set_target_properties(hello-sdl2webgpu PROPERTIES CXX_STANDARD 17)
target_treat_all_warnings_as_errors(hello-sdl2webgpu)

# Copy wgpu-native or Dawn dll/so/dylib next to the executable
target_copy_webgpu_binaries(hello-sdl2webgpu)

# Copy SDL2.dll/so/dylib next to the executable
add_custom_command(
  TARGET hello-sdl2webgpu
  POST_BUILD
  COMMAND
    ${CMAKE_COMMAND}
    -E copy_if_different
    $<TARGET_FILE:SDL2::SDL2>
    $<TARGET_FILE_DIR:hello-sdl2webgpu>
)
