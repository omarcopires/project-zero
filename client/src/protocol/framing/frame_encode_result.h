#pragma once

#include "protocol/framing/frame_error.h"

#include <cstddef>
#include <optional>
#include <vector>

namespace protocol::framing {

struct FrameEncodeResult {
    std::optional<FrameError> error;
    std::vector<std::byte> bytes;
};

}
