add_test(
  NAME hello_app_integration_tests
  COMMAND $<TARGET_FILE:hello-app> integration)

set_tests_properties(
  hello_app_integration_tests
  PROPERTIES PASS_REGULAR_EXPRESSION "Hello, integration!")