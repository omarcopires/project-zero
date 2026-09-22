#include "protocol/framing/modern_frame.h"

#include <gtest/gtest.h>

#include <algorithm>
#include <array>
#include <cstddef>
#include <cstdint>
#include <vector>

namespace protocol::framing {
namespace {

std::vector<std::byte> frameWithBlockCount(const std::uint16_t blockCount)
{
    const auto bodySize = static_cast<std::size_t>(blockCount) * modernFrameBlockSize + modernFrameExtraBytes;
    std::vector<std::byte> frame(modernFrameHeaderSize + bodySize, std::byte { 0x2A });
    frame[0] = static_cast<std::byte>(blockCount & 0xFF);
    frame[1] = static_cast<std::byte>((blockCount >> 8) & 0xFF);
    return frame;
}

TEST(ModernFrame, RequestsHeaderFromEmptyInput)
{
    const auto result = decodeModernFrame({});

    EXPECT_EQ(result.status, FrameDecodeStatus::NeedMoreData);
    EXPECT_EQ(result.bytesRequired, modernFrameHeaderSize);
}

TEST(ModernFrame, RequestsRemainderFromPartialFrame)
{
    auto frame = frameWithBlockCount(1);
    frame.resize(5);

    const auto result = decodeModernFrame(frame);

    EXPECT_EQ(result.status, FrameDecodeStatus::NeedMoreData);
    EXPECT_EQ(result.bytesRequired, 14);
}

TEST(ModernFrame, DecodesSingleFrame)
{
    const auto frame = frameWithBlockCount(1);
    const auto result = decodeModernFrame(frame);

    ASSERT_EQ(result.status, FrameDecodeStatus::FrameReady);
    EXPECT_EQ(result.body.size(), 12);
    EXPECT_EQ(result.bytesConsumed, 14);
}

TEST(ModernFrame, LeavesConcatenatedFrameForNextDecode)
{
    const auto first = frameWithBlockCount(0);
    const auto second = frameWithBlockCount(2);
    std::vector<std::byte> stream(first);
    stream.insert(stream.end(), second.begin(), second.end());

    const auto firstResult = decodeModernFrame(stream);
    ASSERT_EQ(firstResult.status, FrameDecodeStatus::FrameReady);
    EXPECT_EQ(firstResult.bytesConsumed, first.size());

    const auto secondResult = decodeModernFrame(std::span(stream).subspan(firstResult.bytesConsumed));
    ASSERT_EQ(secondResult.status, FrameDecodeStatus::FrameReady);
    EXPECT_EQ(secondResult.bytesConsumed, second.size());
}

TEST(ModernFrame, ReportsTruncationAtEndOfStream)
{
    auto frame = frameWithBlockCount(1);
    frame.pop_back();

    const auto result = decodeModernFrame(frame, FrameInputState::EndOfStream);

    EXPECT_EQ(result.status, FrameDecodeStatus::Failure);
    EXPECT_EQ(result.error, FrameError::Truncated);
}

TEST(ModernFrame, ReportsCleanEndOfStream)
{
    const auto result = decodeModernFrame({}, FrameInputState::EndOfStream);

    EXPECT_EQ(result.status, FrameDecodeStatus::StreamEnded);
    EXPECT_FALSE(result.error.has_value());
}

TEST(ModernFrame, AcceptsLargestServerMessage)
{
    const auto frame = frameWithBlockCount(8187);
    const auto result = decodeModernFrame(frame);

    ASSERT_EQ(result.status, FrameDecodeStatus::FrameReady);
    EXPECT_EQ(result.body.size(), 65500);
}

TEST(ModernFrame, RejectsBodyBeyondServerOutputLimit)
{
    const std::array input{std::byte { 0xFC }, std::byte { 0x1F }};
    const auto result = decodeModernFrame(input);

    EXPECT_EQ(result.status, FrameDecodeStatus::Failure);
    EXPECT_EQ(result.error, FrameError::BodyTooLarge);
}

TEST(ModernFrame, RejectsOutboundBodyBeyondServerInputLimit)
{
    const std::vector<std::byte> body(4100);
    const auto result = encodeModernFrame(body);

    EXPECT_EQ(result.error, FrameError::BodyTooLarge);
    EXPECT_TRUE(result.bytes.empty());
}

TEST(ModernFrame, EncodesLittleEndianBlockCount)
{
    const std::vector<std::byte> body(20, std::byte { 0x5A });
    const auto result = encodeModernFrame(body);

    ASSERT_FALSE(result.error.has_value());
    ASSERT_EQ(result.bytes.size(), 22);
    EXPECT_EQ(result.bytes[0], std::byte { 0x02 });
    EXPECT_EQ(result.bytes[1], std::byte { 0x00 });
    EXPECT_TRUE(std::equal(body.begin(), body.end(), result.bytes.begin() + 2));
}

TEST(ModernFrame, RejectsUnalignedBodyForEncoding)
{
    const std::vector<std::byte> body(13);
    const auto result = encodeModernFrame(body);

    EXPECT_EQ(result.error, FrameError::InvalidBodySize);
    EXPECT_TRUE(result.bytes.empty());
}

}
}
