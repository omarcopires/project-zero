#include "infrastructure/logging/message_formatter.h"

#include <gtest/gtest.h>

namespace infrastructure::logging {
namespace {

TEST(MessageFormatter, CapitalizesFirstAsciiLetter)
{
    EXPECT_EQ(normalizeLogMessage("123 connected"), "123 Connected");
    EXPECT_EQ(normalizeLogMessage("Already normalized"), "Already normalized");
    EXPECT_EQ(normalizeLogMessage("1234"), "1234");
}

TEST(MessageFormatter, ComposesStableFunctionPrefix)
{
    EXPECT_EQ(composeLogPayload("connect", "connected to endpoint"), "[connect] - Connected to endpoint");
}

TEST(MessageFormatter, UsesTypedFormattingAndEscapedBraces)
{
    EXPECT_EQ(
        formatLogMessage("Count {} for {} with {{literal}} braces", 42, "session"),
        "Count 42 for session with {literal} braces");
}

}
}
