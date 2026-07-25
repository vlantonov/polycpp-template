include_guard(GLOBAL)

option(POLYCPP_USE_SCCACHE "Use sccache as the compiler launcher" ON)

if(POLYCPP_USE_SCCACHE)
  find_program(SCCACHE_EXECUTABLE sccache)
  if(SCCACHE_EXECUTABLE)
    set(CMAKE_C_COMPILER_LAUNCHER "${SCCACHE_EXECUTABLE}" CACHE STRING "C compiler launcher" FORCE)
    set(CMAKE_CXX_COMPILER_LAUNCHER "${SCCACHE_EXECUTABLE}" CACHE STRING "CXX compiler launcher" FORCE)
    message(STATUS "polycpp: sccache enabled at ${SCCACHE_EXECUTABLE}")
  else()
    message(WARNING "polycpp: sccache requested but executable was not found")
  endif()
endif()

add_compile_options($<$<COMPILE_LANG_AND_ID:CXX,MSVC>:/Z7>)