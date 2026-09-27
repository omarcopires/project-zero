#include "presentation/rendering/appearance_qml_types.h"

#include <QUrl>
#include <qqml.h>

namespace client::presentation::rendering {

	void registerAppearanceQmlTypes() {
		qmlRegisterType(
			QUrl(QStringLiteral("qrc:/qt/qml/clientui/SingleObjectAppearanceInstanceRenderer.qml")),
			"qmlcomponents",
			1,
			0,
			"SingleObjectAppearanceInstanceRenderer"
		);
	}

}
