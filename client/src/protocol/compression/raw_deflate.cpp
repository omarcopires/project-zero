#include "protocol/compression/raw_deflate.h"

#include <zlib.h>

#include <algorithm>
#include <limits>

namespace protocol::compression {
	namespace {

		constexpr std::size_t outputChunkSize = 4096;

		struct InflateGuard {
			z_stream* stream;

			~InflateGuard() {
				inflateEnd(stream);
			}
		};

	}

	RawDeflateResult decompressRawDeflate(
		const std::span<const std::byte> compressed,
		const std::size_t maximumOutputBytes) {
		if (compressed.empty()) {
			return { .status = RawDeflateStatus::EmptyInput };
		}
		if (maximumOutputBytes == 0) {
			return { .status = RawDeflateStatus::InvalidOutputLimit };
		}
		if (compressed.size() > std::numeric_limits<uInt>::max()) {
			return { .status = RawDeflateStatus::InvalidStream };
		}

		z_stream stream {};
		stream.next_in = reinterpret_cast<Bytef*>(const_cast<std::byte*>(compressed.data()));
		stream.avail_in = static_cast<uInt>(compressed.size());
		if (inflateInit2(&stream, -MAX_WBITS) != Z_OK) {
			return { .status = RawDeflateStatus::InvalidStream };
		}
		const InflateGuard guard { .stream = &stream };

		RawDeflateResult result { .status = RawDeflateStatus::InvalidStream };
		while (true) {
			if (result.bytes.size() == maximumOutputBytes) {
				std::byte probe {};
				stream.next_out = reinterpret_cast<Bytef*>(&probe);
				stream.avail_out = 1;
				const auto status = inflate(&stream, Z_NO_FLUSH);
				if (stream.avail_out == 0) {
					return { .status = RawDeflateStatus::OutputLimitExceeded };
				}
				if (status == Z_STREAM_END) {
					if (stream.avail_in != 0) {
						return { .status = RawDeflateStatus::TrailingData };
					}
					result.status = RawDeflateStatus::Ready;
					return result;
				}
				if (status != Z_OK || stream.avail_in == 0) {
					return { .status = RawDeflateStatus::InvalidStream };
				}
				continue;
			}
			const auto available = std::min(outputChunkSize, maximumOutputBytes - result.bytes.size());
			const auto offset = result.bytes.size();
			result.bytes.resize(offset + available);
			stream.next_out = reinterpret_cast<Bytef*>(result.bytes.data() + offset);
			stream.avail_out = static_cast<uInt>(available);

			const auto status = inflate(&stream, Z_NO_FLUSH);
			const auto produced = available - stream.avail_out;
			result.bytes.resize(offset + produced);
			if (status == Z_STREAM_END) {
				if (stream.avail_in != 0) {
					return { .status = RawDeflateStatus::TrailingData };
				}
				result.status = RawDeflateStatus::Ready;
				return result;
			}
			if (status != Z_OK || (produced == 0 && stream.avail_in == 0)) {
				return { .status = RawDeflateStatus::InvalidStream };
			}
		}
	}

}
