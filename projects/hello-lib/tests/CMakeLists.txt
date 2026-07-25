add_executable(hello_lib_tests greeter_test.cpp)

target_link_libraries(
  hello_lib_tests
  PRIVATE
    hello_lib
    GTest::gtest
    GTest::gtest_main)

polycpp_add_strict_warnings(hello_lib_tests)
polycpp_apply_sanitizers(hello_lib_tests)

gtest_discover_tests(hello_lib_tests)