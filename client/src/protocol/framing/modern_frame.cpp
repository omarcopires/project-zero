#include "protocol/framing/modern_frame.h"

#include <cstdint>
#include <limits>

namespace protocol::framing {
namespace {

std::uint16_t readLittleEndianHeader(const std::span<const std::byte> input)
{
    const auto lowByte = std::to_integer<std::uint16_t>(input[0]);
    const auto highByte = std::to_integer<std::uint16_t>(input[1]);
    return static_cast<std::uint16_t>(lowByte | (highByte << 8));
}

FrameDecodeResult incompleteResult(const std::span<const std::byte> input, const std::size_t bytesRequired, const FrameInputState inputState)
{
    if (inputState == FrameInputState::EndOfStream) {
        if (input.empty()) {
            return {.status = FrameDecodeStatus::StreamEnded};
        }

        return {
            .status = FrameDecodeStatus::Failure,
            .error = FrameError::Truncated,
            .bytesRequired = bytesRequired,
        };
    }

    return {
        .status = FrameDecodeStatus::NeedMoreData,
        .bytesRequired = bytesRequired,
    };
}

}

FrameDecodeResult decodeModernFrame(const std::span<const std::byte> input, const FrameInputState inputState)
{
    if (input.size() < modernFrameHeaderSize) {
        return incompleteResult(input, modernFrameHeaderSize, inputState);
    }

    const auto blockCount = readLittleEndianHeader(input);
    const auto bodySize = static_cast<std::size_t>(blockCount) * modernFrameBlockSize + modernFrameExtraBytes;
    if (bodySize > maximumInboundFrameBodySize) {
        return {
            .status = FrameDecodeStatus::Failure,
            .error = FrameError::BodyTooLarge,
        };
    }

    const auto frameSize = modernFrameHeaderSize + bodySize;
    if (input.size() < frameSize) {
        return incompleteResult(input, frameSize, inputState);
    }

    return {
        .status = FrameDecodeStatus::FrameReady,
        .body = input.subspan(modernFrameHeaderSize, bodySize),
        .bytesConsumed = frameSize,
        .bytesRequired = frameSize,
    };
}

FrameEncodeResult encodeModernFrame(const std::span<const std::byte> body)
{
    if (body.size() > maximumOutboundFrameBodySize) {
        return {.error = FrameError::BodyTooLarge};
    }

    if (body.size() < modernFrameExtraBytes || (body.size() - modernFrameExtraBytes) % modernFrameBlockSize != 0) {
        return {.error = FrameError::InvalidBodySize};
    }

    const auto blockCount = (body.size() - modernFrameExtraBytes) / modernFrameBlockSize;
    if (blockCount > std::numeric_limits<std::uint16_t>::max()) {
        return {.error = FrameError::BodyTooLarge};
    }

    FrameEncodeResult result;
    result.bytes.reserve(modernFrameHeaderSize + body.size());
    result.bytes.push_back(static_cast<std::byte>(blockCount & 0xFF));
    result.bytes.push_back(static_cast<std::byte>((blockCount >> 8) & 0xFF));
    result.bytes.insert(result.bytes.end(), body.begin(), body.end());
    return result;
}

}
