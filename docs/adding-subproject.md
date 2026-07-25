# Adding a Subproject

Use this guide to add a new subproject under projects/<name>/ while keeping the
root orchestrator, tests, and packaging metadata consistent.

## 1. Create the directory skeleton

```bash
mkdir -p projects/<name>/{include/<name>,src,tests}
```

## 2. Add projects/<name>/CMakeLists.txt

Choose one of the two common templates below.

Minimal STATIC library template (similar to hello-lib):

```cmake
add_library(<name> STATIC src/<source>.cpp)

target_include_directories(
  <name>
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>)

target_compile_features(<name> PUBLIC cxx_std_20)

polycpp_add_strict_warnings(<name>)
polycpp_apply_sanitizers(<name>)
polycpp_enable_clang_tidy(<name>)

include(GNUInstallDirs)

install(
  TARGETS <name>
  EXPORT <name>-targets
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT <name>_runtime
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT <name>_runtime
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR} COMPONENT <name>_runtime)

install(
  DIRECTORY include/<name>/
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/<name>
  COMPONENT <name>_dev
  FILES_MATCHING PATTERN "*.hpp")

install(
  EXPORT <name>-targets
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/<name>
  NAMESPACE polycpp::
  COMPONENT <name>_dev)

if(POLYCPP_BUILD_TESTS)
  add_subdirectory(tests)
endif()
```

Minimal executable template (similar to hello-app):

```cmake
add_executable(<name> src/main.cpp)

target_compile_features(<name> PRIVATE cxx_std_20)

polycpp_add_strict_warnings(<name>)
polycpp_apply_sanitizers(<name>)
polycpp_enable_clang_tidy(<name>)

include(GNUInstallDirs)

install(
  TARGETS <name>
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  COMPONENT <name>_runtime)

if(POLYCPP_BUILD_TESTS)
  add_subdirectory(tests)
endif()
```

## 3. Register the subproject in the root CMakeLists.txt

Add one cache option and one guarded add_subdirectory call:

```cmake
option(POLYCPP_BUILD_<NAME> "Build <name>" ON)
if(POLYCPP_BUILD_<NAME> AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/projects/<name>/CMakeLists.txt")
  add_subdirectory(projects/<name>)
endif()
```

## 4. Wire tests with gtest_discover_tests

Follow the same pattern as
[projects/hello-lib/tests/CMakeLists.txt](../projects/hello-lib/tests/CMakeLists.txt):
create a test target, link GTest and your subproject target, apply warnings and
sanitizers, then call gtest_discover_tests.

## 5. Add install rules with per-component tags

Tag install destinations with COMPONENT <name>_runtime and, for libraries with
public headers or export files, COMPONENT <name>_dev.

## 6. Extend cmake/Packaging.cmake metadata

Add component names and metadata for every new component, including display
name, description, and dependencies, then add generator-specific package names.
Use existing hello_lib_runtime and hello_app_runtime blocks as the reference.

Typical variables include:
- CPACK_COMPONENT_<NAME>_RUNTIME_*
- CPACK_COMPONENT_<NAME>_DEV_*
- CPACK_DEBIAN_<NAME>_RUNTIME_PACKAGE_NAME
- CPACK_DEBIAN_<NAME>_DEV_PACKAGE_NAME
- CPACK_RPM_<NAME>_RUNTIME_PACKAGE_NAME
- CPACK_RPM_<NAME>_DEV_PACKAGE_NAME

## 7. Add or wire third-party dependencies

If the new subproject needs additional libraries, update root CMAKE_MODULE_PATH
and find_package(...) usage as needed, and add the dependency with a pinned
version to conanfile.txt.

## 8. Run local verification

```bash
mkdir -p build && cd build
conan install .. --build=missing -pr:b=default -s build_type=Release
cd ..
cmake --preset conan-release -DPOLYCPP_WARNINGS_AS_ERRORS=ON
cmake --build build/Release
ctest --test-dir build/Release --output-on-failure
```

## 9. Optional runtime Dockerfile for the subproject

This template intentionally ships only Dockerfile.dev at the repo root. If your
new subproject needs a runtime image, place a subproject-specific Dockerfile
under projects/<name>/ and keep its build flow scoped to that subproject.
