#include "infrastructure/logging/logger.h"

#include <QCoreApplication>

#include <cstdlib>
#include <filesystem>

int main(int argc, char* argv[])
{
    const QCoreApplication application(argc, argv);

    try {
        infrastructure::logging::Logger logger({
            .loggerName = "diagnostics",
            .filePath = std::filesystem::path("debug.log"),
            .developerMode = application.arguments().contains("--developer"),
        });
        logger.info("main", "Diagnostics initialized");
        return EXIT_SUCCESS;
    } catch (...) {
        return EXIT_FAILURE;
    }
}
