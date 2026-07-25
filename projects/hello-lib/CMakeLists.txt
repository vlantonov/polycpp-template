add_library(hello_lib STATIC src/greeter.cpp)

target_include_directories(
  hello_lib
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>)

target_link_libraries(hello_lib PRIVATE spdlog::spdlog)
target_compile_features(hello_lib PUBLIC cxx_std_20)

polycpp_add_strict_warnings(hello_lib)
polycpp_apply_sanitizers(hello_lib)
polycpp_enable_clang_tidy(hello_lib)

include(GNUInstallDirs)

install(
  TARGETS hello_lib
  EXPORT hello_lib-targets
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT hello_lib_runtime
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT hello_lib_runtime
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR} COMPONENT hello_lib_runtime)

install(
  DIRECTORY include/hello_lib/
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/hello_lib
  COMPONENT hello_lib_dev
  FILES_MATCHING PATTERN "*.hpp")

install(
  EXPORT hello_lib-targets
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/hello_lib
  NAMESPACE polycpp::
  COMPONENT hello_lib_dev)

if(POLYCPP_BUILD_TESTS)
  add_subdirectory(tests)
endif()