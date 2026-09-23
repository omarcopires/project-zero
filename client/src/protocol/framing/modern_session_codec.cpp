#include "protocol/framing/modern_session_codec.h"

#include "protocol/binary/little_endian.h"
#include "protocol/compression/raw_deflate.h"
#include "protocol/framing/modern_frame.h"

#include <cstddef>
#include <utility>
#include <vector>

namespace protocol::framing {
	namespace {

		constexpr std::uint32_t maximumSequence = 0x7FFFFFFFU;
		constexpr std::uint32_t compressionFlag = 0x80000000U;
		constexpr std::size_t paddingHeaderSize = 1;
		constexpr std::size_t maximumDecompressedPayloadSize = 65500;

		bool validSequence(const std::uint32_t sequence) {
			return sequence > 0 && sequence <= maximumSequence;
		}

	}

	ModernSessionResult encodeModernSessionPacket(
		const std::span<const std::byte> payload,
		const crypto::XteaKey &key,
		const std::uint32_t sequence) {
		if (payload.empty()) {
			return { .status = ModernSessionStatus::EmptyPayload };
		}
		if (!validSequence(sequence)) {
			return { .status = ModernSessionStatus::InvalidSequence };
		}

		const auto paddingSize = (modernFrameBlockSize - ((payload.size() + paddingHeaderSize) % modernFrameBlockSize))
			% modernFrameBlockSize;
		std::vector<std::byte> plaintext;
		plaintext.reserve(paddingHeaderSize + payload.size() + paddingSize);
		plaintext.push_back(static_cast<std::byte>(paddingSize));
		plaintext.insert(plaintext.end(), payload.begin(), payload.end());
		plaintext.resize(plaintext.size() + paddingSize, std::byte { 0x00 });

		auto encrypted = crypto::encryptXtea(plaintext, key);
		if (encrypted.status != crypto::XteaStatus::Ready) {
			return { .status = ModernSessionStatus::EncryptionFailed };
		}

		std::vector<std::byte> body;
		body.reserve(sizeof(sequence) + encrypted.bytes.size());
		binary::appendU32(body, sequence);
		body.insert(body.end(), encrypted.bytes.begin(), encrypted.bytes.end());
		auto frame = encodeModernFrame(body);
		if (frame.error) {
			return { .status = ModernSessionStatus::FrameEncodingFailed };
		}
		return { .status = ModernSessionStatus::Ready, .sequence = sequence, .bytes = std::move(frame.bytes) };
	}

	ModernSessionResult decodeModernSessionBody(
		const std::span<const std::byte> body,
		const crypto::XteaKey &key,
		const std::uint32_t expectedSequence) {
		if (!validSequence(expectedSequence)) {
			return { .status = ModernSessionStatus::InvalidSequence };
		}
		if (body.size() < modernFrameExtraBytes + modernFrameBlockSize
		    || (body.size() - modernFrameExtraBytes) % modernFrameBlockSize != 0) {
			return { .status = ModernSessionStatus::InvalidBodySize };
		}

		const auto sequenceWord = binary::readU32(body).value();
		const auto compressed = (sequenceWord & compressionFlag) != 0;
		const auto sequence = sequenceWord & maximumSequence;
		if (sequence != expectedSequence) {
			return { .status = ModernSessionStatus::UnexpectedSequence, .sequence = sequence };
		}

		auto decrypted = crypto::decryptXtea(body.subspan(modernFrameExtraBytes), key);
		if (decrypted.status != crypto::XteaStatus::Ready) {
			return { .status = ModernSessionStatus::EncryptionFailed, .sequence = sequence };
		}
		const auto paddingSize = std::to_integer<std::size_t>(decrypted.bytes.front());
		if (paddingSize >= modernFrameBlockSize || decrypted.bytes.size() <= paddingHeaderSize + paddingSize) {
			return { .status = ModernSessionStatus::InvalidPadding, .sequence = sequence };
		}

		const auto payloadEnd = decrypted.bytes.end() - static_cast<std::ptrdiff_t>(paddingSize);
		std::vector<std::byte> payload(decrypted.bytes.begin() + paddingHeaderSize, payloadEnd);
		if (compressed) {
			auto decompressed = compression::decompressRawDeflate(payload, maximumDecompressedPayloadSize);
			if (decompressed.status != compression::RawDeflateStatus::Ready) {
				return { .status = ModernSessionStatus::DecompressionFailed, .sequence = sequence };
			}
			payload = std::move(decompressed.bytes);
		}
		return {
			.status = ModernSessionStatus::Ready,
			.sequence = sequence,
			.bytes = std::move(payload),
		};
	}

}
