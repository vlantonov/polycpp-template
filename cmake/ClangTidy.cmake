include_guard(GLOBAL)

option(POLYCPP_ENABLE_CLANG_TIDY "Enable clang-tidy for supported targets" OFF)

function(polycpp_enable_clang_tidy target)
  if(NOT POLYCPP_ENABLE_CLANG_TIDY)
    return()
  endif()

  find_program(CLANG_TIDY_EXECUTABLE clang-tidy REQUIRED)
  set_target_properties(${target} PROPERTIES CXX_CLANG_TIDY "${CLANG_TIDY_EXECUTABLE};--use-color")
endfunction()