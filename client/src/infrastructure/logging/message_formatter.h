#pragma once

#include <fmt/format.h>

#include <string>
#include <string_view>
#include <utility>

namespace infrastructure::logging {

std::string normalizeLogMessage(std::string_view message);
std::string composeLogPayload(std::string_view functionName, std::string_view message);

template <typename... Args>
std::string formatLogMessage(fmt::format_string<Args...> messageFormat, Args&&... args)
{
    return fmt::format(messageFormat, std::forward<Args>(args)...);
}

}
