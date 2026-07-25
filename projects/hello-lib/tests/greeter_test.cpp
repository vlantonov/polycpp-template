#include <gtest/gtest.h>

#include <hello_lib/greeter.hpp>

TEST(GreeterTest, Greet_ReturnsHelloWithName) {
  EXPECT_EQ(polycpp::hello_lib::greet("world"), "Hello, world!");
}

TEST(GreeterTest, Greet_HandlesEmptyName) { EXPECT_EQ(polycpp::hello_lib::greet(""), "Hello, !"); }