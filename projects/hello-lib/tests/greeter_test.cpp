#include <hello_lib/greeter.hpp>

#include <gtest/gtest.h>

TEST(GreeterTest, Greet_ReturnsHelloWithName) {
  EXPECT_EQ(polycpp::hello_lib::greet("world"), "Hello, world!");
}

TEST(GreeterTest, Greet_HandlesEmptyName) {
  EXPECT_EQ(polycpp::hello_lib::greet(""), "Hello, !");
}