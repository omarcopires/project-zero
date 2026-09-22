#pragma once

namespace protocol::framing {

enum class FrameError {
    Truncated,
    BodyTooLarge,
    InvalidBodySize,
};

}
