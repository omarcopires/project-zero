#include "protocol/compression/raw_deflate.h"

#include <gtest/gtest.h>

#include <array>
#include <cstddef>
#include <string>
#include <vector>

namespace protocol::compression {
	namespace {

		constexpr std::array<std::byte, 31> compressedFixture {
			std::byte { 0x4B }, std::byte { 0xCE }, std::byte { 0xCF }, std::byte { 0x2D },
			std::byte { 0x28 }, std::byte { 0x4A }, std::byte { 0x2D }, std::byte { 0x2E },
			std::byte { 0x4E }, std::byte { 0x4D }, std::byte { 0xD1 }, std::byte { 0x2D },
			std::byte { 0x4E }, std::byte { 0x2D }, std::byte { 0x2E }, std::byte { 0xCE },
			std::byte { 0xCC }, std::byte { 0xCF }, std::byte { 0xD3 }, std::byte { 0x2D },
			std::byte { 0x48 }, std::byte { 0xAC }, std::byte { 0xCC }, std::byte { 0xC9 },
			std::byte { 0x4F }, std::byte { 0x4C }, std::byte { 0x49 }, std::byte { 0x1E },
			std::byte { 0x92 }, std::byte { 0x32 }, std::byte { 0x00 },
		};

		std::vector<std::byte> expectedPayload() {
			const std::string unit = "compressed-session-payload";
			std::string text;
			for (int repetition = 0; repetition < 8; ++repetition) {
				text += unit;
			}
			return std::vector<std::byte>(
				reinterpret_cast<const std::byte*>(text.data()),
				reinterpret_cast<const std::byte*>(text.data() + text.size()));
		}

		TEST(RawDeflate, DecompressesKnownRawStream) {
			const auto result = decompressRawDeflate(compressedFixture, 1024);
			EXPECT_EQ(result.status, RawDeflateStatus::Ready);
			EXPECT_EQ(result.bytes, expectedPayload());
		}

		TEST(RawDeflate, RejectsOutputBeyondLimit) {
			EXPECT_EQ(decompressRawDeflate(compressedFixture, 208).status, RawDeflateStatus::Ready);
			EXPECT_EQ(decompressRawDeflate(compressedFixture, 207).status, RawDeflateStatus::OutputLimitExceeded);
		}

		TEST(RawDeflate, RejectsTruncatedStream) {
			auto truncated = std::vector<std::byte>(compressedFixture.begin(), compressedFixture.end() - 1);
			EXPECT_EQ(decompressRawDeflate(truncated, 1024).status, RawDeflateStatus::InvalidStream);
		}

		TEST(RawDeflate, RejectsTrailingData) {
			auto trailing = std::vector<std::byte>(compressedFixture.begin(), compressedFixture.end());
			trailing.push_back(std::byte { 0x00 });
			EXPECT_EQ(decompressRawDeflate(trailing, 1024).status, RawDeflateStatus::TrailingData);
		}

		TEST(RawDeflate, RejectsEmptyInputAndZeroLimit) {
			EXPECT_EQ(decompressRawDeflate({}, 1024).status, RawDeflateStatus::EmptyInput);
			EXPECT_EQ(decompressRawDeflate(compressedFixture, 0).status, RawDeflateStatus::InvalidOutputLimit);
		}

	}
}
