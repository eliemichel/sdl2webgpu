# This example comes from https://eliemichel.github.io/LearnWebGPU
cmake_minimum_required(VERSION 3.11.0...3.25.0)
project(sdl2webgpu-examples VERSION 1.0.0 LANGUAGES C)

include(FetchContent)
include(utils.cmake)

# Dependencies
if (EMSCRIPTEN)

  add_library(SDL2_SDL2 INTERFACE)
  target_compile_options(SDL2_SDL2 INTERFACE --use-port=sdl2)
  target_link_options(SDL2_SDL2 INTERFACE --use-port=sdl2)
  add_library(SDL2::SDL2 ALIAS SDL2_SDL2)
  function(target_copy_sdl2_binaries)
  endfunction()

  add_library(webgpu INTERFACE)
  target_link_options(webgpu INTERFACE -sUSE_WEBGPU=1)
  function(target_copy_webgpu_binaries)
  endfunction()

else()

  FetchContent_Declare(
    sdl2
    URL https://github.com/libsdl-org/SDL/archive/refs/tags/release-2.32.2.zip
    URL_HASH MD5=c38041ed63bdc9be67982adb746b8635
  )
  FetchContent_Declare(
    webgpu
    URL https://github.com/eliemichel/WebGPU-distribution/archive/refs/tags/main-v0.3.0-alpha.zip
    URL_HASH MD5=ea1195dc6c7661c36aa13ea5b734b86e
  )
  FetchContent_MakeAvailable(sdl2 webgpu)

  function(target_copy_sdl2_binaries Target)
    add_custom_command(
      TARGET ${Target}
      POST_BUILD
      COMMAND
        ${CMAKE_COMMAND}
        -E copy_if_different
        $<TARGET_FILE:SDL2::SDL2>
        $<TARGET_FILE_DIR:${Target}>
    )
  endfunction()

endif()

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
target_copy_sdl2_binaries(hello-sdl2webgpu)
