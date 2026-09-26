#pragma once

#include <lzma.h>

#include <array>
#include <cstddef>
#include <cstdint>
#include <optional>
#include <span>
#include <vector>

namespace test_support {

	inline std::optional<std::vector<std::byte>> encodeRawLzma(const std::span<const std::byte> input) {
		lzma_options_lzma options {};
		if (lzma_lzma_preset(&options, 1)) {
			return std::nullopt;
		}
		options.dict_size = 1024 * 1024;

		lzma_filter filters[] {
			{ .id = LZMA_FILTER_LZMA1, .options = &options },
			{ .id = LZMA_VLI_UNKNOWN, .options = nullptr },
		};
		lzma_stream encoder = LZMA_STREAM_INIT;
		if (lzma_raw_encoder(&encoder, filters) != LZMA_OK) {
			lzma_end(&encoder);
			return std::nullopt;
		}

		std::vector<std::uint8_t> encodedBytes(input.size() * 2 + 1024);
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

	inline std::vector<std::byte> encodeVarint(std::uint64_t value) {
		std::vector<std::byte> encoded;
		while (value >= 0x80) {
			encoded.push_back(static_cast<std::byte>((value & 0x7F) | 0x80));
			value >>= 7;
		}
		encoded.push_back(static_cast<std::byte>(value));
		return encoded;
	}

	inline std::optional<std::vector<std::byte>> makeCipSpriteSheet(
		const std::span<const std::byte> bitmapBytes
	) {
		const auto rawPayload = encodeRawLzma(bitmapBytes);
		if (!rawPayload) {
			return std::nullopt;
		}

		constexpr std::size_t zeroPrefixSize = 24;
		constexpr std::array<std::byte, 5> marker {
			std::byte { 0x70 }, std::byte { 0x0A }, std::byte { 0xFA }, std::byte { 0x80 }, std::byte { 0x24 },
		};
		std::size_t varintSize = 1;
		std::vector<std::byte> encodedLength;
		do {
			const std::uint64_t tailSize = 10 + varintSize + rawPayload->size();
			encodedLength = encodeVarint(tailSize);
			if (encodedLength.size() == varintSize) {
				break;
			}
			varintSize = encodedLength.size();
		} while (true);

		std::vector<std::byte> wrapped(zeroPrefixSize, std::byte { 0 });
		wrapped.insert(wrapped.end(), marker.begin(), marker.end());
		wrapped.insert(wrapped.end(), encodedLength.begin(), encodedLength.end());
		wrapped.push_back(std::byte { 0x5D });
		wrapped.insert(wrapped.end(), {
			std::byte { 0x00 }, std::byte { 0x00 }, std::byte { 0x10 }, std::byte { 0x00 },
		});
		wrapped.insert(wrapped.end(), 8, std::byte { 0 });
		wrapped.insert(wrapped.end(), rawPayload->begin(), rawPayload->end());
		return wrapped;
	}

}
