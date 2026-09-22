#include "infrastructure/logging/logger.h"

#include <spdlog/logger.h>
#include <spdlog/sinks/basic_file_sink.h>
#include <spdlog/sinks/stdout_color_sinks.h>

#include <stdexcept>
#include <utility>
#include <vector>

namespace infrastructure::logging {
namespace {

constexpr std::string_view logPattern = "[%Y-%m-%d %H:%M:%S.%e] [%n] [%^%l%$] %v";

spdlog::level::level_enum toSpdlogLevel(const LogLevel level)
{
    switch (level) {
        case LogLevel::Trace:
            return spdlog::level::trace;
        case LogLevel::Debug:
            return spdlog::level::debug;
        case LogLevel::Info:
            return spdlog::level::info;
        case LogLevel::Warning:
            return spdlog::level::warn;
        case LogLevel::Error:
            return spdlog::level::err;
        case LogLevel::Critical:
            return spdlog::level::critical;
    }

    throw std::invalid_argument("Unsupported log level");
}

}

class Logger::Impl final {
public:
    explicit Impl(const LoggingConfiguration& configuration)
    {
        if (configuration.loggerName.empty()) {
            throw std::invalid_argument("Logger name cannot be empty");
        }

        if (configuration.filePath.empty()) {
            throw std::invalid_argument("Log file path cannot be empty");
        }

        std::vector<spdlog::sink_ptr> sinks;
        sinks.emplace_back(std::make_shared<spdlog::sinks::stdout_color_sink_mt>());
        sinks.emplace_back(std::make_shared<spdlog::sinks::basic_file_sink_mt>(configuration.filePath.string(), true));

        logger = std::make_shared<spdlog::logger>(configuration.loggerName, sinks.begin(), sinks.end());
        logger->set_pattern(std::string(logPattern));
        logger->set_level(configuration.developerMode ? spdlog::level::debug : spdlog::level::info);
        logger->flush_on(spdlog::level::trace);
    }

    std::shared_ptr<spdlog::logger> logger;
};

Logger::Logger(const LoggingConfiguration& configuration)
    : m_impl(std::make_unique<Impl>(configuration))
{
}

Logger::~Logger()
{
    try {
        flush();
    } catch (...) {
    }
}

void Logger::flush()
{
    m_impl->logger->flush();
}

void Logger::log(const LogLevel level, const std::string_view functionName, std::string message)
{
    if (functionName.empty()) {
        throw std::invalid_argument("Log function name cannot be empty");
    }

    m_impl->logger->log(toSpdlogLevel(level), "{}", composeLogPayload(functionName, message));
}

}
