#include <gtest/gtest.h>

#include "assets/lzma_decode_status.h"
#include "assets/lzma_stream_decoder.h"

#include <lzma.h>

#include <array>
#include <cstddef>
#include <cstdint>
#include <optional>
#include <span>
#include <vector>

namespace {

	constexpr std::uint64_t decoderMemoryLimit = 8 * 1024 * 1024;

	std::optional<std::vector<std::byte>> encodeLzmaAlone(const std::span<const std::byte> input) {
		lzma_options_lzma options {};
		if (lzma_lzma_preset(&options, 1)) {
			return std::nullopt;
		}

		lzma_stream encoder = LZMA_STREAM_INIT;
		if (lzma_alone_encoder(&encoder, &options) != LZMA_OK) {
			lzma_end(&encoder);
			return std::nullopt;
		}

		std::array<std::uint8_t, 8192> encodedBytes {};
		encoder.next_in = reinterpret_cast<const std::uint8_t*>(input.data());
		encoder.avail_in = input.size();
		encoder.next_out = encodedBytes.data();
		encoder.avail_out = encodedBytes.size();
		const lzma_ret encodeResult = lzma_code(&encoder, LZMA_FINISH);
		const std::size_t encodedSize = encodedBytes.size() - encoder.avail_out;
		lzma_end(&encoder);
		if (encodeResult != LZMA_STREAM_END) {
			return std::nullopt;
		}

		const auto bytes = std::as_bytes(std::span(encodedBytes.data(), encodedSize));
		return std::vector<std::byte>(bytes.begin(), bytes.end());
	}

	std::vector<std::byte> makeInput() {
		std::vector<std::byte> input(512);
		for (std::size_t index = 0; index < input.size(); ++index) {
			input[index] = static_cast<std::byte>((index * 37U) & 0xFFU);
		}
		return input;
	}

}

TEST(LzmaStreamDecoder, DecodesLzmaAlonePayload) {
	const auto input = makeInput();
	const auto encoded = encodeLzmaAlone(input);
	ASSERT_TRUE(encoded.has_value());

	const auto decoded = assets::decodeLzmaAlone(*encoded, input.size(), decoderMemoryLimit);
	ASSERT_EQ(decoded.status, assets::LzmaDecodeStatus::Decoded);
	EXPECT_EQ(decoded.output, input);
}

TEST(LzmaStreamDecoder, RejectsOutputBeyondConfiguredLimit) {
	const auto input = makeInput();
	const auto encoded = encodeLzmaAlone(input);
	ASSERT_TRUE(encoded.has_value());

	const auto decoded = assets::decodeLzmaAlone(*encoded, input.size() - 1, decoderMemoryLimit);
	EXPECT_EQ(decoded.status, assets::LzmaDecodeStatus::OutputLimitExceeded);
	EXPECT_TRUE(decoded.output.empty());
}

TEST(LzmaStreamDecoder, RejectsMemoryRequirementBeyondConfiguredLimit) {
	const auto input = makeInput();
	const auto encoded = encodeLzmaAlone(input);
	ASSERT_TRUE(encoded.has_value());

	const auto decoded = assets::decodeLzmaAlone(*encoded, input.size(), 1);
	EXPECT_EQ(decoded.status, assets::LzmaDecodeStatus::MemoryLimitExceeded);
	EXPECT_TRUE(decoded.output.empty());
}

TEST(LzmaStreamDecoder, RejectsTruncatedPayload) {
	const auto input = makeInput();
	auto encoded = encodeLzmaAlone(input);
	ASSERT_TRUE(encoded.has_value());
	ASSERT_GT(encoded->size(), 4U);

	encoded->resize(encoded->size() - 4);
	const auto decoded = assets::decodeLzmaAlone(*encoded, input.size(), decoderMemoryLimit);
	EXPECT_EQ(decoded.status, assets::LzmaDecodeStatus::TruncatedInput);
	EXPECT_TRUE(decoded.output.empty());
}

TEST(LzmaStreamDecoder, RejectsTrailingBytesAfterLzmaAlonePayload) {
	const auto input = makeInput();
	auto encoded = encodeLzmaAlone(input);
	ASSERT_TRUE(encoded.has_value());
	encoded->push_back(std::byte { 0x7F });

	const auto decoded = assets::decodeLzmaAlone(*encoded, input.size(), decoderMemoryLimit);
	EXPECT_EQ(decoded.status, assets::LzmaDecodeStatus::TrailingData);
	EXPECT_TRUE(decoded.output.empty());
}

TEST(LzmaStreamDecoder, ReportsEmptyInput) {
	const auto decoded = assets::decodeLzmaAlone({}, 0, decoderMemoryLimit);
	EXPECT_EQ(decoded.status, assets::LzmaDecodeStatus::EmptyInput);
	EXPECT_TRUE(decoded.output.empty());
}
