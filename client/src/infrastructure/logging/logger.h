#pragma once

#include "infrastructure/logging/log_level.h"
#include "infrastructure/logging/logging_configuration.h"
#include "infrastructure/logging/message_formatter.h"

#include <memory>
#include <string>
#include <string_view>
#include <utility>

namespace infrastructure::logging {

class Logger final {
public:
    explicit Logger(const LoggingConfiguration& configuration);
    ~Logger();

    Logger(const Logger&) = delete;
    Logger& operator=(const Logger&) = delete;
    Logger(Logger&&) = delete;
    Logger& operator=(Logger&&) = delete;

    template <typename... Args>
    void trace(std::string_view functionName, fmt::format_string<Args...> messageFormat, Args&&... args)
    {
        log(LogLevel::Trace, functionName, formatLogMessage(messageFormat, std::forward<Args>(args)...));
    }

    template <typename... Args>
    void debug(std::string_view functionName, fmt::format_string<Args...> messageFormat, Args&&... args)
    {
        log(LogLevel::Debug, functionName, formatLogMessage(messageFormat, std::forward<Args>(args)...));
    }

    template <typename... Args>
    void info(std::string_view functionName, fmt::format_string<Args...> messageFormat, Args&&... args)
    {
        log(LogLevel::Info, functionName, formatLogMessage(messageFormat, std::forward<Args>(args)...));
    }

    template <typename... Args>
    void warning(std::string_view functionName, fmt::format_string<Args...> messageFormat, Args&&... args)
    {
        log(LogLevel::Warning, functionName, formatLogMessage(messageFormat, std::forward<Args>(args)...));
    }

    template <typename... Args>
    void error(std::string_view functionName, fmt::format_string<Args...> messageFormat, Args&&... args)
    {
        log(LogLevel::Error, functionName, formatLogMessage(messageFormat, std::forward<Args>(args)...));
    }

    template <typename... Args>
    void critical(std::string_view functionName, fmt::format_string<Args...> messageFormat, Args&&... args)
    {
        log(LogLevel::Critical, functionName, formatLogMessage(messageFormat, std::forward<Args>(args)...));
    }

    void flush();

private:
    class Impl;

    void log(LogLevel level, std::string_view functionName, std::string message);

    std::unique_ptr<Impl> m_impl;
};

}
