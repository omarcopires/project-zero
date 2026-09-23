#pragma once

#include "application/world/world_session_error.h"

#include <QString>

namespace application::world {

	struct WorldSessionFailure {
		WorldSessionError error = WorldSessionError::Transport;
		QString description;
	};

}
