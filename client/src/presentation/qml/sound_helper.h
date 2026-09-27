#pragma once

#include <QObject>

namespace client::presentation::qml {

	class SoundHelper final : public QObject {
		Q_OBJECT

	public:
		enum Sound {
			SCREENSHOT = 0,
			BUTTON_PRESS = 1,
			BUTTON_RELEASE = 2,
			STORE_ANIMATION_RATTLING = 3,
			STORE_ANIMATION_BUY = 4,
			CHAT_MESSAGE_ARRIVED = 5,
			PRIVATE_MESSAGE_IN_LOCAL_CHAT = 6,
			SEND_CHAT_MESSAGE = 7,
			OPEN_DIALOG_OR_WIDGET = 8,
			VIP_LIST_LOGOUT = 9,
			VIP_LIST_LOGIN = 10,
			QUEST_TRACKER_ADD = 11,
			QUEST_TRACKER_REMOVE = 12,
		};
		Q_ENUM(Sound)

		using QObject::QObject;

		Q_INVOKABLE bool playSound(int soundId) const;
	};

	void registerSoundHelper();

}
