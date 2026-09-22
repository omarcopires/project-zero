#include <gtest/gtest.h>

#include <version>

TEST(Bootstrap, UsesCpp20OrNewer)
{
    EXPECT_GE(__cplusplus, 202002L);
}
