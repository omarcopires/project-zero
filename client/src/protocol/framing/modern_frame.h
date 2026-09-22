#pragma once

#include "protocol/framing/frame_decode_result.h"
#include "protocol/framing/frame_encode_result.h"
#include "protocol/framing/frame_input_state.h"

#include <cstddef>
#include <span>

namespace protocol::framing {

inline constexpr std::size_t modernFrameHeaderSize = 2;
inline constexpr std::size_t modernFrameBlockSize = 8;
inline constexpr std::size_t modernFrameExtraBytes = 4;
inline constexpr std::size_t maximumInboundFrameBodySize = 65500;
inline constexpr std::size_t maximumOutboundFrameBodySize = 4096;

FrameDecodeResult decodeModernFrame(std::span<const std::byte> input, FrameInputState inputState = FrameInputState::Open);
FrameEncodeResult encodeModernFrame(std::span<const std::byte> body);

}
