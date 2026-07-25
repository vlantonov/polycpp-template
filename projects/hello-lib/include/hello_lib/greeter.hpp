#pragma once

#include <string>
#include <string_view>

namespace polycpp::hello_lib {

[[nodiscard]] std::string greet(std::string_view name);

}  // namespace polycpp::hello_lib