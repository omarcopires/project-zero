#pragma once

#include "protocol/framing/frame_error.h"

#include <cstddef>
#include <optional>

namespace diagnostics {

	struct FixtureInspectionResult {
		std::size_t frameCount = 0;
		std::size_t byteCount = 0;
		std::optional<protocol::framing::FrameError> error;
	};

}
