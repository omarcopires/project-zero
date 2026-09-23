#pragma once

#include "session/selection/character_selection_status.h"
#include "session/selection/world_connection_target.h"

#include <optional>

namespace session::selection {

	struct CharacterSelectionResult {
		CharacterSelectionStatus status = CharacterSelectionStatus::SessionUnavailable;
		std::optional<WorldConnectionTarget> target;
	};

}
