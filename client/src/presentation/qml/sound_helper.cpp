#include "presentation/qml/sound_helper.h"

#include <qqml.h>

namespace client::presentation::qml {

	bool SoundHelper::playSound(const int soundId) const {
		Q_UNUSED(soundId);
		return false;
	}

	void registerSoundHelper() {
		qmlRegisterSingletonType<SoundHelper>(
			"qmlcomponents",
			1,
			0,
			"SoundHelper",
			[](QQmlEngine*, QJSEngine*) -> QObject* {
				return new SoundHelper;
			}
		);
	}

}
