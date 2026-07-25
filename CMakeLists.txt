cmake_minimum_required(VERSION 3.25)

file(READ "${CMAKE_CURRENT_SOURCE_DIR}/VERSION" POLYCPP_VERSION)
string(STRIP "${POLYCPP_VERSION}" POLYCPP_VERSION)

project(
  polycpp
  VERSION ${POLYCPP_VERSION}
  LANGUAGES CXX
  DESCRIPTION "Reusable C++ subproject orchestration template")

if(NOT CMAKE_CONFIGURATION_TYPES AND NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Build type" FORCE)
  message(STATUS "polycpp: defaulting CMAKE_BUILD_TYPE to ${CMAKE_BUILD_TYPE}")
endif()

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

option(POLYCPP_WARNINGS_AS_ERRORS "Treat compiler warnings as errors" OFF)
option(POLYCPP_BUILD_TESTS "Enable unit and integration tests" ON)
option(POLYCPP_ENABLE_ASAN "Enable AddressSanitizer instrumentation" OFF)
option(POLYCPP_ENABLE_UBSAN "Enable UndefinedBehaviorSanitizer instrumentation" OFF)
option(POLYCPP_ENABLE_TSAN "Enable ThreadSanitizer instrumentation" OFF)
option(POLYCPP_BUILD_HELLO_LIB "Enable building the hello-lib subproject" ON)
option(POLYCPP_BUILD_HELLO_APP "Enable building the hello-app subproject" ON)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(Sccache)
include(Warnings)
include(Sanitizers)
include(ClangTidy)

find_package(spdlog REQUIRED)

if(POLYCPP_BUILD_TESTS)
  enable_testing()
  find_package(GTest REQUIRED)
  include(GoogleTest)
endif()

if(POLYCPP_BUILD_HELLO_LIB AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/projects/hello-lib/CMakeLists.txt")
  add_subdirectory(projects/hello-lib)
endif()

if(POLYCPP_BUILD_HELLO_APP AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/projects/hello-app/CMakeLists.txt")
  add_subdirectory(projects/hello-app)
endif()

include(Packaging)