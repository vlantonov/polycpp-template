#include <hello_lib/greeter.hpp>

#include <spdlog/spdlog.h>

#include <string>

namespace polycpp::hello_lib {

std::string greet(std::string_view name) {
  spdlog::debug("greet called for {}", name);
  return "Hello, " + std::string{name} + "!";
}

}  // namespace polycpp::hello_lib