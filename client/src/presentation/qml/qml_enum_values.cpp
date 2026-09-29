#include "presentation/qml/qml_enum_values.h"

#include <qqml.h>

#include "presentation/qml/map_antialiasing_mode.h"
#include "presentation/qml/split_resize_preference.h"

namespace client::presentation::qml {

	int TibiaEnumsAdapter::preferBoth() const {
		return static_cast<int>(SplitResizePreference::PreferBoth);
	}

	int TibiaEnumsAdapter::preferMapWindow() const {
		return static_cast<int>(SplitResizePreference::PreferMapWindow);
	}

	int TibiaEnumsAdapter::preferChat() const {
		return static_cast<int>(SplitResizePreference::PreferChat);
	}

	int TibiaEnumsAdapter::antialiasingModeNone() const {
		return static_cast<int>(MapAntialiasingMode::None);
	}

	int TibiaEnumsAdapter::antialiasingModeAntialiasing() const {
		return static_cast<int>(MapAntialiasingMode::Antialiasing);
	}

	int TibiaEnumsAdapter::antialiasingModeRetro() const {
		return static_cast<int>(MapAntialiasingMode::Retro);
	}

	int TibiaEnumsAdapter::dailyRewardStateCollected() const {
		return 0;
	}

	int TibiaEnumsAdapter::dailyRewardStateNotCollected() const {
		return 1;
	}

	int TibiaEnumsAdapter::dailyRewardStateNotAvailable() const {
		return 2;
	}

	void registerQmlEnumValues() {
		qmlRegisterUncreatableType<SelectionModeAdapter>(
			"QtQuick.LegacyControls",
			1,
			0,
			"SelectionMode",
			QStringLiteral("SelectionMode only provides selection mode constants")
		);
		qmlRegisterSingletonType<TibiaEnumsAdapter>(
			"qmlenumvalues",
			1,
			0,
			"TibiaEnums",
			[](QQmlEngine*, QJSEngine*) -> QObject* {
				return new TibiaEnumsAdapter;
			}
		);
		qmlRegisterSingletonType<TibiaEnumsAdapter>(
			"qmlcomponents",
			1,
			0,
			"TibiaEnums",
			[](QQmlEngine*, QJSEngine*) -> QObject* {
				return new TibiaEnumsAdapter;
			}
		);
	}

}
