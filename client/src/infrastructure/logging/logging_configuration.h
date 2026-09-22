#pragma once

#include <filesystem>
#include <string>

namespace infrastructure::logging {

struct LoggingConfiguration {
    std::string loggerName;
    std::filesystem::path filePath;
    bool developerMode = false;
};

}
