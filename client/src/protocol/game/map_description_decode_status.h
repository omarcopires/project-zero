#pragma once

namespace protocol::game {

	enum class MapDescriptionDecodeStatus {
		Ready,
		InvalidHeader,
		Truncated,
		UnknownAppearance,
		UnsupportedAppearanceFeature,
		InvalidThing,
		UnsupportedContainerType,
		TooManyThingsOnTile,
		InvalidRunLength,
	};

}
