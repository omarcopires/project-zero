#pragma once

namespace protocol::framing {

enum class FrameDecodeStatus {
    NeedMoreData,
    FrameReady,
    StreamEnded,
    Failure,
};

}
