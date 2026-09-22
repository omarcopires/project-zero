#include "infrastructure/logging/message_formatter.h"

#include <cstddef>

namespace infrastructure::logging {

std::string normalizeLogMessage(const std::string_view message)
{
    std::string normalized(message);

    for (std::size_t index = 0; index < normalized.size(); ++index) {
        const auto character = static_cast<unsigned char>(normalized[index]);
        const bool isLowercaseAsciiLetter = character >= 'a' && character <= 'z';
        const bool isUppercaseAsciiLetter = character >= 'A' && character <= 'Z';

        if (isLowercaseAsciiLetter) {
            normalized[index] = static_cast<char>(character - 'a' + 'A');
            break;
        }

        if (isUppercaseAsciiLetter) {
            break;
        }
    }

    return normalized;
}

std::string composeLogPayload(const std::string_view functionName, const std::string_view message)
{
    return fmt::format("[{}] - {}", functionName, normalizeLogMessage(message));
}

}
