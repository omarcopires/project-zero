#include "assets/lzma_stream_decoder.h"

#include <lzma.h>

#include <algorithm>
#include <array>
#include <span>
#include <utility>
#include <vector>

namespace assets {
	namespace {

		constexpr std::size_t outputBufferSize = 16 * 1024;

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

}
