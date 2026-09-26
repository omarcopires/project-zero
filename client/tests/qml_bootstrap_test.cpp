#include <QGuiApplication>
#include <QFile>
#include <QImageReader>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QQmlComponent>
#include <QQmlEngine>
#include <QString>
#include <QUrl>
#include <QtTest>

#include "presentation/qml/qml_enum_values.h"
#include "presentation/qml/map_antialiasing_mode.h"
#include "presentation/qml/split_resize_preference.h"
#include "presentation/translations/json_catalog_translator.h"

class QmlBootstrapTest final : public QObject {
	Q_OBJECT

private slots:
	void initTestCase();
	void loadsEnglishBootstrapTranslations();
	void loadsOriginalClientWindow();
	void exposesSplitResizePreferencesToQml();

private:
	client::presentation::translations::JsonCatalogTranslator m_translations;
};

void QmlBootstrapTest::initTestCase() {
	client::presentation::qml::registerQmlEnumValues();
	QVERIFY(m_translations.loadCatalog(QStringLiteral(":/translations/en.json")));
	QCoreApplication::installTranslator(&m_translations);
}

void QmlBootstrapTest::loadsEnglishBootstrapTranslations() {
	QCOMPARE(
		QCoreApplication::translate("qtTrId", "startscreen_please_wait_caption"),
		QStringLiteral("Please Wait")
	);
	QCOMPARE(
		QCoreApplication::translate("qtTrId", "startscreen_please_wait_description"),
		QStringLiteral("Loading game files")
	);
	QCOMPARE(
		QCoreApplication::translate("qtTrId", "aboutdialog_caption"),
		QStringLiteral("Info")
	);
}

void QmlBootstrapTest::loadsOriginalClientWindow() {
	QVERIFY(QFile::exists(QStringLiteral(":/qt/qml/qmlcomponents/qml/clientwindow.qml")));
	QVERIFY(QFile::exists(QStringLiteral(":/images/title.jpg")));
	QVERIFY(QFile::exists(QStringLiteral(":/images/skin/classic/dialog-frame-borderimage.png")));

	QImageReader titleImage(QStringLiteral(":/images/title.jpg"));
	QVERIFY2(titleImage.canRead(), qPrintable(titleImage.errorString()));
	QVERIFY2(!titleImage.read().isNull(), qPrintable(titleImage.errorString()));

	QImageReader dialogFrame(QStringLiteral(":/images/skin/classic/dialog-frame-borderimage.png"));
	QVERIFY2(dialogFrame.canRead(), qPrintable(dialogFrame.errorString()));
	QVERIFY2(!dialogFrame.read().isNull(), qPrintable(dialogFrame.errorString()));

	QQmlApplicationEngine engine;
	engine.addImportPath(QStringLiteral("qrc:/qt/qml"));
	engine.load(QUrl(QStringLiteral("qrc:/qt/qml/qmlcomponents/qml/clientwindow.qml")));

	const auto rootObjects = engine.rootObjects();
	QCOMPARE(rootObjects.size(), 1);
	const auto *window = qobject_cast<QQuickWindow*>(rootObjects.front());
	QVERIFY(window != nullptr);
	QVERIFY(window->minimumWidth() > 0);
	QVERIFY(window->minimumHeight() > 0);
	QVERIFY(window->findChild<QObject*>(QStringLiteral("placeholder")) != nullptr);

	bool foundTranslatedCaption = false;
	bool foundTranslatedDescription = false;
	for (QObject* object : window->findChildren<QObject*>()) {
		foundTranslatedCaption = foundTranslatedCaption
			|| object->property("caption").toString() == QStringLiteral("Please Wait");
		foundTranslatedDescription = foundTranslatedDescription
			|| object->property("text").toString() == QStringLiteral("Loading game files");
	}
	QVERIFY(foundTranslatedCaption);
	QVERIFY(foundTranslatedDescription);
}

void QmlBootstrapTest::exposesSplitResizePreferencesToQml() {
	QQmlEngine engine;
	QQmlComponent component(&engine);
	component.setData(
		"import QtQml\n"
		"import qmlenumvalues 1.0\n"
		"QtObject {\n"
		"    property int preferBoth: TibiaEnums.PreferBoth\n"
		"    property int preferMapWindow: TibiaEnums.PreferMapWindow\n"
		"    property int preferChat: TibiaEnums.PreferChat\n"
		"    property int antialiasingModeNone: TibiaEnums.AntialiasingModeNone\n"
		"    property int antialiasingModeAntialiasing: TibiaEnums.AntialiasingModeAntialiasing\n"
		"    property int antialiasingModeRetro: TibiaEnums.AntialiasingModeRetro\n"
		"}",
		QUrl()
	);
	QVERIFY2(component.isReady(), qPrintable(component.errorString()));
	QObject* object = component.create();
	QVERIFY2(object != nullptr, qPrintable(component.errorString()));
	QCOMPARE(
		object->property("preferBoth").toInt(),
		static_cast<int>(client::presentation::qml::SplitResizePreference::PreferBoth)
	);
	QCOMPARE(
		object->property("preferMapWindow").toInt(),
		static_cast<int>(client::presentation::qml::SplitResizePreference::PreferMapWindow)
	);
	QCOMPARE(
		object->property("preferChat").toInt(),
		static_cast<int>(client::presentation::qml::SplitResizePreference::PreferChat)
	);
	QCOMPARE(
		object->property("antialiasingModeNone").toInt(),
		static_cast<int>(client::presentation::qml::MapAntialiasingMode::None)
	);
	QCOMPARE(
		object->property("antialiasingModeAntialiasing").toInt(),
		static_cast<int>(client::presentation::qml::MapAntialiasingMode::Antialiasing)
	);
	QCOMPARE(
		object->property("antialiasingModeRetro").toInt(),
		static_cast<int>(client::presentation::qml::MapAntialiasingMode::Retro)
	);
	delete object;
}

int main(int argc, char* argv[]) {
	QGuiApplication application(argc, argv);
	QmlBootstrapTest test;
	return QTest::qExec(&test, argc, argv);
}

#include "qml_bootstrap_test.moc"
