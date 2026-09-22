#include "diagnostics/fixture_inspector.h"

#include "protocol/framing/frame_error.h"

#include <gtest/gtest.h>

#include <cstddef>
#include <cstdint>
#include <vector>

namespace diagnostics {
	namespace {

		std::vector<std::byte> frameWithBlockCount(const std::uint16_t blockCount) {
			constexpr std::size_t blockSize = 8;
			constexpr std::size_t extraBytes = 4;
			constexpr std::size_t headerSize = 2;
			const auto bodySize = static_cast<std::size_t>(blockCount) * blockSize + extraBytes;
			std::vector<std::byte> frame(headerSize + bodySize, std::byte { 0x2A });
			frame[0] = static_cast<std::byte>(blockCount & 0xFF);
			frame[1] = static_cast<std::byte>((blockCount >> 8) & 0xFF);
			return frame;
		}

		TEST(FixtureInspector, AcceptsSingleFrame) {
			const auto fixture = frameWithBlockCount(1);
			const auto result = inspectFixture(fixture);

			EXPECT_EQ(result.frameCount, 1);
			EXPECT_EQ(result.byteCount, fixture.size());
			EXPECT_FALSE(result.error.has_value());
		}

		TEST(FixtureInspector, AcceptsConcatenatedFrames) {
			auto fixture = frameWithBlockCount(0);
			const auto secondFrame = frameWithBlockCount(2);
			fixture.insert(fixture.end(), secondFrame.begin(), secondFrame.end());

			const auto result = inspectFixture(fixture);

			EXPECT_EQ(result.frameCount, 2);
			EXPECT_FALSE(result.error.has_value());
		}

		TEST(FixtureInspector, ReassemblesFragmentedFrame) {
			const auto fixture = frameWithBlockCount(2);
			const auto result = inspectFragmentedFixture(fixture, 1);

			EXPECT_EQ(result.frameCount, 1);
			EXPECT_FALSE(result.error.has_value());
		}

		TEST(FixtureInspector, RejectsTruncatedFrame) {
			auto fixture = frameWithBlockCount(1);
			fixture.pop_back();

			const auto result = inspectFixture(fixture);

			EXPECT_EQ(result.frameCount, 0);
			ASSERT_TRUE(result.error.has_value());
			EXPECT_EQ(*result.error, protocol::framing::FrameError::Truncated);
		}

		TEST(FixtureInspector, RejectsOversizedFrameHeader) {
			const std::vector fixture { std::byte { 0xFF }, std::byte { 0xFF } };
			const auto result = inspectFixture(fixture);

			ASSERT_TRUE(result.error.has_value());
			EXPECT_EQ(*result.error, protocol::framing::FrameError::BodyTooLarge);
		}

		TEST(FixtureInspector, AcceptsExactInboundLimit) {
			const auto fixture = frameWithBlockCount(8187);
			const auto result = inspectFragmentedFixture(fixture, 4096);

			EXPECT_EQ(result.frameCount, 1);
			EXPECT_FALSE(result.error.has_value());
		}

		TEST(FixtureInspector, RejectsZeroFragmentSize) {
			const auto fixture = frameWithBlockCount(0);
			const auto result = inspectFragmentedFixture(fixture, 0);

			ASSERT_TRUE(result.error.has_value());
			EXPECT_EQ(*result.error, protocol::framing::FrameError::InvalidBodySize);
		}

	}
}
