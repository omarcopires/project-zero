#include "protocol/crypto/xtea.h"

#include "protocol/binary/little_endian.h"

#include <cstddef>
#include <cstdint>
#include <utility>

namespace protocol::crypto {
	namespace {

		constexpr std::size_t blockSize = 8;
		constexpr std::uint32_t delta = 0x9E3779B9U;
		constexpr std::uint32_t decryptInitialSum = 0xC6EF3720U;
		constexpr std::size_t roundCount = 32;

		void writeU32(std::vector<std::byte> &bytes, const std::size_t offset, const std::uint32_t value) {
			bytes[offset] = static_cast<std::byte>(value & 0xFFU);
			bytes[offset + 1] = static_cast<std::byte>((value >> 8U) & 0xFFU);
			bytes[offset + 2] = static_cast<std::byte>((value >> 16U) & 0xFFU);
			bytes[offset + 3] = static_cast<std::byte>((value >> 24U) & 0xFFU);
		}

		XteaResult transform(const std::span<const std::byte> input, const XteaKey &key, const bool encrypt) {
			if (input.size() % blockSize != 0) {
				return { .status = XteaStatus::InvalidBlockSize };
			}

			std::vector<std::byte> output(input.begin(), input.end());
			for (std::size_t offset = 0; offset < output.size(); offset += blockSize) {
				auto left = binary::readU32(output, offset).value();
				auto right = binary::readU32(output, offset + sizeof(std::uint32_t)).value();
				std::uint32_t sum = encrypt ? 0U : decryptInitialSum;

				for (std::size_t round = 0; round < roundCount; ++round) {
					if (encrypt) {
						left += (((right << 4U) ^ (right >> 5U)) + right) ^ (sum + key[sum & 3U]);
						sum += delta;
						right += (((left << 4U) ^ (left >> 5U)) + left) ^ (sum + key[(sum >> 11U) & 3U]);
					} else {
						right -= (((left << 4U) ^ (left >> 5U)) + left) ^ (sum + key[(sum >> 11U) & 3U]);
						sum -= delta;
						left -= (((right << 4U) ^ (right >> 5U)) + right) ^ (sum + key[sum & 3U]);
					}
				}

				writeU32(output, offset, left);
				writeU32(output, offset + sizeof(std::uint32_t), right);
			}
			return { .status = XteaStatus::Ready, .bytes = std::move(output) };
		}

	}

	XteaResult encryptXtea(const std::span<const std::byte> plaintext, const XteaKey &key) {
		return transform(plaintext, key, true);
	}

	XteaResult decryptXtea(const std::span<const std::byte> ciphertext, const XteaKey &key) {
		return transform(ciphertext, key, false);
	}

}
