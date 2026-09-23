#include "protocol/binary/adler32.h"
#include "protocol/binary/little_endian.h"

#include <gtest/gtest.h>

#include <array>
#include <cstddef>
#include <vector>

namespace protocol::binary {
	namespace {

		TEST(ProtocolBinary, ReadsLittleEndianValues) {
			const std::array bytes { std::byte { 0x34 }, std::byte { 0x12 }, std::byte { 0x78 }, std::byte { 0x56 }, std::byte { 0x34 }, std::byte { 0x12 } };

			EXPECT_EQ(readU16(bytes).value(), 0x1234);
			EXPECT_EQ(readU32(bytes, 2).value(), 0x12345678U);
		}

		TEST(ProtocolBinary, RejectsOutOfBoundsReads) {
			const std::array bytes { std::byte { 0x01 }, std::byte { 0x02 }, std::byte { 0x03 } };

			EXPECT_FALSE(readU32(bytes).has_value());
			EXPECT_FALSE(readU16(bytes, bytes.size()).has_value());
		}

		TEST(ProtocolBinary, AppendsLittleEndianValues) {
			std::vector<std::byte> bytes;
			appendU16(bytes, 0x1234);
			appendU32(bytes, 0x12345678U);

			const std::vector expected {
				std::byte { 0x34 }, std::byte { 0x12 }, std::byte { 0x78 }, std::byte { 0x56 }, std::byte { 0x34 }, std::byte { 0x12 }
			};
			EXPECT_EQ(bytes, expected);
		}

		TEST(ProtocolBinary, CalculatesKnownAdler32) {
			const std::array payload {
				std::byte { 0x01 }, std::byte { 0x1F }, std::byte { 0x04 }, std::byte { 0x03 },
				std::byte { 0x02 }, std::byte { 0x01 }, std::byte { 0x5A }, std::byte { 0x71 }
			};

			EXPECT_EQ(adler32(payload), 0x024000F6U);
		}

	}
}
