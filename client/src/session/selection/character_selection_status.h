#pragma once

namespace session::selection {

	enum class CharacterSelectionStatus {
		Success,
		SessionUnavailable,
		CharacterNotFound,
		AmbiguousCharacter,
		WorldNotFound,
		AmbiguousWorld,
		InvalidEndpoint,
	};

}
