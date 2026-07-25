add_executable(hello-app src/main.cpp)

target_link_libraries(hello-app PRIVATE hello_lib spdlog::spdlog)
target_compile_features(hello-app PRIVATE cxx_std_20)

polycpp_add_strict_warnings(hello-app)
polycpp_apply_sanitizers(hello-app)
polycpp_enable_clang_tidy(hello-app)

include(GNUInstallDirs)

install(
  TARGETS hello-app
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  COMPONENT hello_app_runtime)

if(POLYCPP_BUILD_TESTS)
  add_subdirectory(tests)
endif()