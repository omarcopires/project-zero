#include "protocol/crypto/xtea.h"

#include <gtest/gtest.h>

#include <array>
#include <cstddef>
#include <vector>

namespace protocol::crypto {
	namespace {

		constexpr XteaKey testKey { 0x01020304U, 0x11121314U, 0x21222324U, 0x31323334U };
		constexpr std::array<std::byte, 8> plaintext {
			std::byte { 0x00 }, std::byte { 0x01 }, std::byte { 0x02 }, std::byte { 0x03 },
			std::byte { 0x04 }, std::byte { 0x05 }, std::byte { 0x06 }, std::byte { 0x07 },
		};
		constexpr std::array<std::byte, 8> ciphertext {
			std::byte { 0x8D }, std::byte { 0x0E }, std::byte { 0xF4 }, std::byte { 0x8D },
			std::byte { 0x07 }, std::byte { 0x50 }, std::byte { 0xB4 }, std::byte { 0x8F },
		};

		TEST(Xtea, EncryptsKnownLittleEndianVector) {
			const auto result = encryptXtea(plaintext, testKey);
			EXPECT_EQ(result.status, XteaStatus::Ready);
			EXPECT_EQ(result.bytes, std::vector<std::byte>(ciphertext.begin(), ciphertext.end()));
		}

		TEST(Xtea, DecryptsKnownLittleEndianVector) {
			const auto result = decryptXtea(ciphertext, testKey);
			EXPECT_EQ(result.status, XteaStatus::Ready);
			EXPECT_EQ(result.bytes, std::vector<std::byte>(plaintext.begin(), plaintext.end()));
		}

		TEST(Xtea, TransformsEveryBlockAndRoundTrips) {
			std::vector<std::byte> input(24);
			for (std::size_t index = 0; index < input.size(); ++index) {
				input[index] = static_cast<std::byte>(index);
			}

			const auto encrypted = encryptXtea(input, testKey);
			ASSERT_EQ(encrypted.status, XteaStatus::Ready);
			EXPECT_NE(encrypted.bytes, input);
			const auto decrypted = decryptXtea(encrypted.bytes, testKey);
			EXPECT_EQ(decrypted.status, XteaStatus::Ready);
			EXPECT_EQ(decrypted.bytes, input);
		}

		TEST(Xtea, RejectsUnalignedInput) {
			const std::array<std::byte, 7> input {};
			EXPECT_EQ(encryptXtea(input, testKey).status, XteaStatus::InvalidBlockSize);
			EXPECT_EQ(decryptXtea(input, testKey).status, XteaStatus::InvalidBlockSize);
		}

	}
}
