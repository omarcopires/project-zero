#pragma once

namespace client::presentation::qml {

	// These values are local QML comparison tokens. They are not persisted or
	// sent over the network; only their names and behavior are frontend contracts.
	enum class SplitResizePreference {
		PreferBoth = 0,
		PreferMapWindow = 1,
		PreferChat = 2,
	};

}
