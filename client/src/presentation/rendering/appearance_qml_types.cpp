#include "presentation/rendering/appearance_qml_types.h"

#include "presentation/rendering/render_driver_item.h"

#include <QUrl>
#include <qqml.h>

namespace client::presentation::rendering {

	void registerAppearanceQmlTypes() {
		qmlRegisterType(
			QUrl(QStringLiteral("qrc:/qt/qml/clientui/AppearanceInstanceRenderer.qml")),
			"qmlcomponents",
			1,
			0,
			"AppearanceInstanceRenderer"
		);
		qmlRegisterType(
			QUrl(QStringLiteral("qrc:/qt/qml/clientui/ObjectAppearanceInstance.qml")),
			"qmlcomponents",
			1,
			0,
			"ObjectAppearanceInstance"
		);
		qmlRegisterType(
			QUrl(QStringLiteral("qrc:/qt/qml/clientui/OutfitAppearanceInstance.qml")),
			"qmlcomponents",
			1,
			0,
			"OutfitAppearanceInstance"
		);
		qmlRegisterType<RenderDriverItem>(
			"qmlcomponents",
			1,
			0,
			"RenderDriver"
		);
		qmlRegisterType(
			QUrl(QStringLiteral("qrc:/qt/qml/clientui/SingleObjectAppearanceInstanceRenderer.qml")),
			"qmlcomponents",
			1,
			0,
			"SingleObjectAppearanceInstanceRenderer"
		);
	}

}
