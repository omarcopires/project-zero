#include <QGuiApplication>
#include <QIcon>
#include <QFileInfo>
#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQmlError>
#include <QQuickItem>
#include <QQuickWindow>
#include <QSettings>
#include <QString>
#include <QVariant>
#include <QUrl>

#include <cstdlib>
#include <filesystem>

#include "infrastructure/logging/logger.h"
#include "presentation/qml/game_window_controller.h"
#include "presentation/qml/qml_enum_values.h"
#include "presentation/qml/sound_helper.h"
#include "presentation/qml/tooltip_helper.h"
#include "presentation/rendering/appearance_image_provider.h"
#include "presentation/rendering/appearance_qml_types.h"
#include "presentation/rendering/optimized_border_image_provider.h"
#include "presentation/rendering/world_map_qml_types.h"
#include "presentation/translations/json_catalog_translator.h"

namespace {

	QString clientConfigPath() {
		const QString configuredPath = QString::fromLocal8Bit(qgetenv("CLIENT_CONFIG_FILE"));
		return configuredPath.isEmpty()
			? QCoreApplication::applicationDirPath() + QStringLiteral("/client.ini")
			: QFileInfo(configuredPath).absoluteFilePath();
	}

	QString assetsDirectory() {
		const QString configuredDirectory = QString::fromLocal8Bit(qgetenv("CLIENT_ASSETS_DIRECTORY"));
		if (!configuredDirectory.isEmpty()) {
			const QFileInfo configuredInfo(configuredDirectory);
			return configuredInfo.isAbsolute()
				? configuredInfo.absoluteFilePath()
				: QFileInfo(QCoreApplication::applicationDirPath() + QStringLiteral("/") + configuredDirectory).absoluteFilePath();
		}
		QSettings settings(clientConfigPath(), QSettings::IniFormat);
		const QString settingsDirectory = settings.value(QStringLiteral("assets/directory")).toString();
		if (settingsDirectory.isEmpty()) {
			return QCoreApplication::applicationDirPath() + QStringLiteral("/things/assets");
		}
		const QFileInfo directoryInfo(settingsDirectory);
		return directoryInfo.isAbsolute()
			? directoryInfo.absoluteFilePath()
			: QFileInfo(QCoreApplication::applicationDirPath() + QStringLiteral("/") + settingsDirectory).absoluteFilePath();
	}

}

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
	client::presentation::qml::registerSoundHelper();
	client::presentation::rendering::registerAppearanceQmlTypes();
	client::presentation::rendering::registerWorldMapQmlTypes();
	client::presentation::translations::JsonCatalogTranslator translations;
	if (!translations.loadCatalog(QStringLiteral(":/translations/en.json"))) {
		logger.error("main", "Failed to load the English translation catalog");
		return EXIT_FAILURE;
	}
	application.installTranslator(&translations);

	QQmlApplicationEngine engine;
	auto *tooltipHelper = new client::presentation::qml::TooltipHelper(&engine);
	engine.rootContext()->setContextProperty(QStringLiteral("TooltipHelper"), tooltipHelper);
	engine.rootContext()->setContextProperty(QStringLiteral("UICachingEnabled"), false);
	engine.rootContext()->setContextProperty(
		QStringLiteral("tibiaMouseCursorController"),
		static_cast<QObject *>(nullptr)
	);
	const QString assetsPath = assetsDirectory();
	auto *appearanceProvider = new client::presentation::rendering::AppearanceImageProvider(assetsPath);
	engine.addImageProvider(
		QStringLiteral("appearance"),
		appearanceProvider
	);
	engine.addImageProvider(
		QStringLiteral("optimized1pixelborderimage"),
		new client::presentation::rendering::OptimizedBorderImageProvider
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

	auto *clientWindow = qobject_cast<QQuickWindow*>(engine.rootObjects().front());
	if (clientWindow == nullptr) {
		logger.error("main", "The client window root is not a Qt Quick window");
		return EXIT_FAILURE;
	}
	QQuickItem *placeholder = nullptr;
	for (QQuickItem *child : clientWindow->contentItem()->childItems()) {
		if (child->objectName() == QStringLiteral("placeholder")) {
			placeholder = child;
			break;
		}
	}
	if (placeholder == nullptr) {
		logger.error("main", "The client window does not expose its game window placeholder");
		return EXIT_FAILURE;
	}

	QQmlComponent gameWindowComponent(
		&engine,
		QUrl(QStringLiteral("qrc:/qt/qml/qmlcomponents/qml/gamewindow.qml"))
	);
	if (!gameWindowComponent.isReady()) {
		for (const auto &error : gameWindowComponent.errors()) {
			logger.error("qml", "{}", error.toString().toStdString());
		}
		logger.error("main", "The original game window cannot be composed until its QML dependencies are available");
	} else {
		QObject *gameWindowObject = gameWindowComponent.create();
		auto *gameWindow = qobject_cast<QQuickItem*>(gameWindowObject);
		const auto creationErrors = gameWindowComponent.errors();
		if (gameWindow == nullptr || !creationErrors.isEmpty()) {
			for (const auto &error : gameWindowComponent.errors()) {
				logger.error("qml", "{}", error.toString().toStdString());
			}
			logger.error("main", "The original game window failed to create without QML errors");
			delete gameWindowObject;
		} else {
			gameWindow->setParent(placeholder);
			gameWindow->setParentItem(placeholder);
			auto *controller = new client::presentation::qml::GameWindowController(
				&engine, appearanceProvider, logger, &engine);
			gameWindow->setProperty(
				"controller",
				QVariant::fromValue(static_cast<QObject *>(controller))
			);
			controller->setGameWindowRoot(gameWindow);
			logger.info("main", "The original game window was added to the client window");
		}
	}

	return application.exec();
}
