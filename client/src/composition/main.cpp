#include <QGuiApplication>
#include <QIcon>
#include <QQmlError>
#include <QQmlApplicationEngine>
#include <QString>
#include <QUrl>

#include <cstdlib>
#include <filesystem>

#include "infrastructure/logging/logger.h"
#include "presentation/qml/qml_enum_values.h"
#include "presentation/rendering/appearance_image_provider.h"
#include "presentation/translations/json_catalog_translator.h"

int main(int argc, char* argv[]) {
	QGuiApplication application(argc, argv);
	application.setApplicationName(QStringLiteral("Client"));
	application.setWindowIcon(QIcon(QStringLiteral(":/icons/client.ico")));
	QCoreApplication::addLibraryPath(QCoreApplication::applicationDirPath() + QStringLiteral("/plugins"));
	const auto debugLogPath = std::filesystem::path(QGuiApplication::applicationDirPath().toStdWString()) / "debug.log";
	infrastructure::logging::Logger logger({
		.loggerName = "client",
		.filePath = debugLogPath,
	});
	logger.info("main", "Starting visual client");

	client::presentation::qml::registerQmlEnumValues();
	client::presentation::translations::JsonCatalogTranslator translations;
	if (!translations.loadCatalog(QStringLiteral(":/translations/en.json"))) {
		logger.error("main", "Failed to load the English translation catalog");
		return EXIT_FAILURE;
	}
	application.installTranslator(&translations);

	QQmlApplicationEngine engine;
	const QString assetsDirectory = QString::fromLocal8Bit(qgetenv("CLIENT_ASSETS_DIRECTORY"));
	engine.addImageProvider(
		QStringLiteral("appearance"),
		new client::presentation::rendering::AppearanceImageProvider(assetsDirectory)
	);
	QObject::connect(
		&engine,
		&QQmlApplicationEngine::warnings,
		&application,
		[&logger](const QList<QQmlError>& warnings) {
			for (const auto& warning : warnings) {
				logger.error("qml", "{}", warning.toString().toStdString());
			}
		}
	);
	engine.addImportPath(QStringLiteral("qrc:/qt/qml"));
	engine.load(QUrl(QStringLiteral("qrc:/qt/qml/qmlcomponents/qml/clientwindow.qml")));
	if (engine.rootObjects().isEmpty()) {
		logger.error("main", "Failed to load the client window");
		return EXIT_FAILURE;
	}

	return application.exec();
}
