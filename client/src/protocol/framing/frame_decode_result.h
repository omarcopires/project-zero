#pragma once

#include "protocol/framing/frame_decode_status.h"
#include "protocol/framing/frame_error.h"

#include <cstddef>
#include <optional>
#include <span>

namespace protocol::framing {

struct FrameDecodeResult {
    FrameDecodeStatus status = FrameDecodeStatus::NeedMoreData;
    std::optional<FrameError> error;
    std::span<const std::byte> body;
    std::size_t bytesConsumed = 0;
    std::size_t bytesRequired = 0;
};

}
