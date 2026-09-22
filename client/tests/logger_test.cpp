#include "infrastructure/logging/logger.h"

#include <gtest/gtest.h>

#include <filesystem>
#include <fstream>
#include <iterator>
#include <regex>
#include <string>

namespace infrastructure::logging {
namespace {

std::filesystem::path logFilePath(const std::string_view fileName)
{
    return std::filesystem::path(testing::TempDir()) / fileName;
}

std::string readFile(const std::filesystem::path& path)
{
    std::ifstream stream(path, std::ios::binary);
    return {std::istreambuf_iterator<char>(stream), std::istreambuf_iterator<char>()};
}

TEST(Logger, WritesExpectedPatternWithoutAnsiSequences)
{
    const auto path = logFilePath("pattern.log");

    {
        Logger logger({.loggerName = "transport", .filePath = path});
        logger.info("connect", "connected to endpoint {}", 7172);
        logger.flush();
    }

    const auto output = readFile(path);
    const std::regex expectedPattern(
        R"(\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3}\] \[transport\] \[info\] \[connect\] - Connected to endpoint 7172\r?\n)");
    EXPECT_TRUE(std::regex_match(output, expectedPattern));
    EXPECT_EQ(output.find('\x1b'), std::string::npos);
}

TEST(Logger, FiltersDebugMessagesOutsideDeveloperMode)
{
    const auto path = logFilePath("filtered.log");

    {
        Logger logger({.loggerName = "diagnostics", .filePath = path});
        logger.debug("filteredCase", "hidden diagnostic marker");
        logger.info("filteredCase", "visible diagnostic marker");
        logger.flush();
    }

    const auto output = readFile(path);
    EXPECT_EQ(output.find("Hidden diagnostic marker"), std::string::npos);
    EXPECT_NE(output.find("Visible diagnostic marker"), std::string::npos);
}

TEST(Logger, EnablesDebugMessagesInDeveloperMode)
{
    const auto path = logFilePath("developer.log");

    {
        Logger logger({.loggerName = "diagnostics", .filePath = path, .developerMode = true});
        logger.debug("developerCase", "developer diagnostic marker");
        logger.flush();
    }

    EXPECT_NE(readFile(path).find("[debug] [developerCase] - Developer diagnostic marker"), std::string::npos);
}

TEST(Logger, TruncatesPreviousSession)
{
    const auto path = logFilePath("truncated.log");
    {
        std::ofstream previousSession(path, std::ios::binary | std::ios::trunc);
        previousSession << "previous-session-sensitive-marker";
    }

    {
        Logger logger({.loggerName = "diagnostics", .filePath = path});
        logger.info("startup", "new session");
        logger.flush();
    }

    const auto output = readFile(path);
    EXPECT_EQ(output.find("previous-session-sensitive-marker"), std::string::npos);
    EXPECT_NE(output.find("New session"), std::string::npos);
}

}
}
