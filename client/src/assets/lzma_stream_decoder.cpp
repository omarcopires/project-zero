#include "assets/lzma_stream_decoder.h"

#include <lzma.h>

#include <algorithm>
#include <array>
#include <limits>
#include <optional>
#include <span>
#include <utility>
#include <vector>

namespace assets {
	namespace {

		constexpr std::size_t outputBufferSize = 16 * 1024;
		constexpr std::size_t cipPrefixSize = 24;
		constexpr std::size_t cipMarkerSize = 5;
		constexpr std::size_t cipLengthBase = 32;
		constexpr std::size_t cipSizeFieldSize = 8;
		constexpr std::size_t maximumCipPrefixSize = 64;

		class LzmaStream final {
		public:
			LzmaStream() : m_stream(LZMA_STREAM_INIT) {}
			~LzmaStream() {
				lzma_end(&m_stream);
			}

			LzmaStream(const LzmaStream&) = delete;
			LzmaStream& operator=(const LzmaStream&) = delete;

			lzma_stream* get() noexcept {
				return &m_stream;
			}

		private:
			lzma_stream m_stream;
		};

		LzmaDecodeResult failure(const LzmaDecodeStatus status) {
			return { .status = status };
		}

		bool skip(const std::span<const std::byte> bytes, std::size_t &offset, const std::size_t count) {
			if (offset > bytes.size() || count > bytes.size() - offset) {
				return false;
			}
			offset += count;
			return true;
		}

		std::optional<std::uint64_t> readVarint(const std::span<const std::byte> bytes, std::size_t &offset) {
			std::uint64_t value = 0;
			for (unsigned int index = 0; index < 10; ++index) {
				if (offset >= bytes.size()) {
					return std::nullopt;
				}
				const auto current = std::to_integer<std::uint8_t>(bytes[offset++]);
				const auto payload = static_cast<std::uint8_t>(current & 0x7FU);
				const unsigned int shift = index * 7;
				if (shift == 63 && payload > 1) {
					return std::nullopt;
				}
				value |= static_cast<std::uint64_t>(payload) << shift;
				if ((current & 0x80U) == 0) {
					return value;
				}
			}
			return std::nullopt;
		}

		std::optional<std::uint32_t> readLittleEndianU32(
			const std::span<const std::byte> bytes,
			std::size_t &offset
		) {
			if (offset > bytes.size() || sizeof(std::uint32_t) > bytes.size() - offset) {
				return std::nullopt;
			}
			std::uint32_t value = 0;
			for (unsigned int index = 0; index < sizeof(std::uint32_t); ++index) {
				value |= static_cast<std::uint32_t>(std::to_integer<std::uint8_t>(bytes[offset++])) << (index * 8);
			}
			return value;
		}

		LzmaDecodeResult decodeRawLzma(
			const std::span<const std::byte> compressedBytes,
			const std::size_t maximumOutputBytes,
			const std::uint64_t maximumMemoryBytes,
			lzma_options_lzma &options
		) {
			lzma_filter filters[] {
				{ .id = LZMA_FILTER_LZMA1, .options = &options },
				{ .id = LZMA_VLI_UNKNOWN, .options = nullptr },
			};
			const std::uint64_t memoryUsage = lzma_raw_decoder_memusage(filters);
			if (memoryUsage == std::numeric_limits<std::uint64_t>::max() || memoryUsage > maximumMemoryBytes) {
				return failure(LzmaDecodeStatus::MemoryLimitExceeded);
			}

			LzmaStream decoder;
			lzma_stream* stream = decoder.get();
			const auto initialization = lzma_raw_decoder(stream, filters);
			if (initialization == LZMA_MEM_ERROR) {
				return failure(LzmaDecodeStatus::ResourceFailure);
			}
			if (initialization != LZMA_OK) {
				return failure(LzmaDecodeStatus::InvalidStream);
			}

			stream->next_in = reinterpret_cast<const std::uint8_t*>(compressedBytes.data());
			stream->avail_in = compressedBytes.size();

			std::vector<std::byte> output;
			std::array<std::uint8_t, outputBufferSize> outputBuffer {};
			while (true) {
				const std::size_t remainingOutputBytes = maximumOutputBytes - output.size();
				const bool probingOutputLimit = remainingOutputBytes == 0;
				const std::size_t outputCapacity = probingOutputLimit
					? 1
					: std::min(outputBuffer.size(), remainingOutputBytes);
				const std::size_t remainingInputBeforeDecode = stream->avail_in;

				stream->next_out = outputBuffer.data();
				stream->avail_out = outputCapacity;
				const lzma_action action = stream->avail_in == 0 ? LZMA_FINISH : LZMA_RUN;
				const lzma_ret decodeResult = lzma_code(stream, action);
				const std::size_t producedBytes = outputCapacity - stream->avail_out;

				if (probingOutputLimit && producedBytes != 0) {
					return failure(LzmaDecodeStatus::OutputLimitExceeded);
				}
				if (producedBytes != 0) {
					const auto decodedBytes = std::as_bytes(std::span(outputBuffer.data(), producedBytes));
					output.insert(output.end(), decodedBytes.begin(), decodedBytes.end());
				}

				if (decodeResult == LZMA_STREAM_END) {
					if (stream->avail_in != 0) {
						return failure(LzmaDecodeStatus::TrailingData);
					}
					return { .status = LzmaDecodeStatus::Decoded, .output = std::move(output) };
				}
				if (decodeResult == LZMA_MEM_ERROR) {
					return failure(LzmaDecodeStatus::ResourceFailure);
				}
				if (decodeResult == LZMA_BUF_ERROR
				    || (decodeResult == LZMA_OK && producedBytes == 0 && stream->avail_in == remainingInputBeforeDecode)) {
					return failure(LzmaDecodeStatus::TruncatedInput);
				}
				if (decodeResult != LZMA_OK) {
					return failure(LzmaDecodeStatus::InvalidStream);
				}
			}
		}

	}

	LzmaDecodeResult decodeLzmaAlone(
		const std::span<const std::byte> compressedBytes,
		const std::size_t maximumOutputBytes,
		const std::uint64_t maximumMemoryBytes
	) {
		if (compressedBytes.empty()) {
			return failure(LzmaDecodeStatus::EmptyInput);
		}
		if (maximumMemoryBytes == 0) {
			return failure(LzmaDecodeStatus::InvalidConfiguration);
		}

		LzmaStream decoder;
		lzma_stream* stream = decoder.get();
		const auto initialization = lzma_alone_decoder(stream, maximumMemoryBytes);
		if (initialization == LZMA_MEMLIMIT_ERROR) {
			return failure(LzmaDecodeStatus::MemoryLimitExceeded);
		}
		if (initialization == LZMA_MEM_ERROR) {
			return failure(LzmaDecodeStatus::ResourceFailure);
		}
		if (initialization != LZMA_OK) {
			return failure(LzmaDecodeStatus::InvalidStream);
		}

		stream->next_in = reinterpret_cast<const std::uint8_t*>(compressedBytes.data());
		stream->avail_in = compressedBytes.size();

		std::vector<std::byte> output;
		std::array<std::uint8_t, outputBufferSize> outputBuffer {};
		while (true) {
			const std::size_t remainingOutputBytes = maximumOutputBytes - output.size();
			const bool probingOutputLimit = remainingOutputBytes == 0;
			const std::size_t outputCapacity = probingOutputLimit
				? 1
				: std::min(outputBuffer.size(), remainingOutputBytes);
			const std::size_t remainingInputBeforeDecode = stream->avail_in;

			stream->next_out = outputBuffer.data();
			stream->avail_out = outputCapacity;
			const lzma_ret decodeResult = lzma_code(stream, LZMA_FINISH);
			const std::size_t producedBytes = outputCapacity - stream->avail_out;

			if (probingOutputLimit && producedBytes != 0) {
				return failure(LzmaDecodeStatus::OutputLimitExceeded);
			}
			if (producedBytes != 0) {
				const auto decodedBytes = std::as_bytes(std::span(outputBuffer.data(), producedBytes));
				output.insert(output.end(), decodedBytes.begin(), decodedBytes.end());
			}

			if (decodeResult == LZMA_STREAM_END) {
				if (stream->avail_in != 0) {
					return failure(LzmaDecodeStatus::TrailingData);
				}
				return { .status = LzmaDecodeStatus::Decoded, .output = std::move(output) };
			}
			if (decodeResult == LZMA_MEMLIMIT_ERROR) {
				return failure(LzmaDecodeStatus::MemoryLimitExceeded);
			}
			if (decodeResult == LZMA_MEM_ERROR) {
				return failure(LzmaDecodeStatus::ResourceFailure);
			}
			if (decodeResult == LZMA_BUF_ERROR) {
				return failure(LzmaDecodeStatus::TruncatedInput);
			}
			if (decodeResult != LZMA_OK) {
				return failure(LzmaDecodeStatus::InvalidStream);
			}
			if (producedBytes == 0 && stream->avail_in == remainingInputBeforeDecode) {
				return failure(LzmaDecodeStatus::TruncatedInput);
			}
		}
	}

	LzmaDecodeResult decodeCipSpriteSheet(
		const std::span<const std::byte> compressedBytes,
		const std::size_t maximumOutputBytes,
		const std::uint64_t maximumMemoryBytes
	) {
		if (compressedBytes.empty()) {
			return failure(LzmaDecodeStatus::EmptyInput);
		}
		if (maximumOutputBytes == 0 || maximumMemoryBytes == 0) {
			return failure(LzmaDecodeStatus::InvalidConfiguration);
		}

		std::size_t offset = 0;
		while (offset < compressedBytes.size() && compressedBytes[offset] == std::byte { 0 }) {
			++offset;
		}
		if (offset == 0 || offset > maximumCipPrefixSize || offset != cipPrefixSize
		    || !skip(compressedBytes, offset, cipMarkerSize)) {
			return failure(LzmaDecodeStatus::InvalidContainerHeader);
		}

		const auto declaredTailSize = readVarint(compressedBytes, offset);
		if (!declaredTailSize || compressedBytes.size() < cipLengthBase
		    || *declaredTailSize != compressedBytes.size() - cipLengthBase) {
			return failure(LzmaDecodeStatus::InvalidContainerHeader);
		}

		if (offset >= compressedBytes.size()) {
			return failure(LzmaDecodeStatus::InvalidContainerHeader);
		}
		const auto properties = std::to_integer<std::uint8_t>(compressedBytes[offset++]);
		lzma_options_lzma options {};
		options.lc = properties % 9;
		const unsigned int remainder = properties / 9;
		options.lp = remainder % 5;
		options.pb = remainder / 5;
		if (options.lc > 4 || options.lp > 4 || options.pb > 4 || options.lc + options.lp > 4) {
			return failure(LzmaDecodeStatus::InvalidContainerHeader);
		}

		const auto dictionarySize = readLittleEndianU32(compressedBytes, offset);
		if (!dictionarySize || *dictionarySize == 0 || !skip(compressedBytes, offset, cipSizeFieldSize)) {
			return failure(LzmaDecodeStatus::InvalidContainerHeader);
		}
		options.dict_size = *dictionarySize;
		if (offset >= compressedBytes.size()) {
			return failure(LzmaDecodeStatus::InvalidContainerHeader);
		}

		const auto rawPayload = compressedBytes.subspan(offset);
		if (rawPayload.empty()) {
			return failure(LzmaDecodeStatus::InvalidContainerHeader);
		}
		return decodeRawLzma(rawPayload, maximumOutputBytes, maximumMemoryBytes, options);
	}

}
