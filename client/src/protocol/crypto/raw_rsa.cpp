#include "protocol/crypto/raw_rsa.h"

#include "protocol/constants/world_handshake_constants.h"

#include <openssl/bn.h>

#include <memory>
#include <string>
#include <utility>

namespace protocol::crypto {
	namespace {

		struct BigNumberDeleter {
			void operator()(BIGNUM *value) const noexcept {
				BN_free(value);
			}
		};

		struct ContextDeleter {
			void operator()(BN_CTX *value) const noexcept {
				BN_CTX_free(value);
			}
		};

		using BigNumber = std::unique_ptr<BIGNUM, BigNumberDeleter>;
		using Context = std::unique_ptr<BN_CTX, ContextDeleter>;

		BigNumber parseDecimal(const std::string_view value) {
			BIGNUM *number = nullptr;
			const std::string decimal(value);
			const auto parsedCharacters = BN_dec2bn(&number, decimal.c_str());
			if (decimal.empty() || parsedCharacters != static_cast<int>(decimal.size())) {
				BN_free(number);
				return {};
			}
			return BigNumber(number);
		}

	}

	RawRsaResult encryptRawRsa(
		const std::span<const std::byte> plaintext,
		const std::string_view modulusDecimal,
		const std::uint32_t exponent) {
		if (plaintext.size() != constants::rsaBlockSize) {
			return { .status = RawRsaStatus::InvalidBlockSize };
		}

		auto modulus = parseDecimal(modulusDecimal);
		BigNumber publicExponent(BN_new());
		if (!modulus || !publicExponent
		    || BN_is_negative(modulus.get())
		    || !BN_is_odd(modulus.get())
		    || BN_num_bytes(modulus.get()) != static_cast<int>(constants::rsaBlockSize)
		    || exponent < 3 || (exponent % 2) == 0
		    || BN_set_word(publicExponent.get(), exponent) != 1) {
			return { .status = RawRsaStatus::InvalidPublicKey };
		}

		BigNumber message(BN_bin2bn(
			reinterpret_cast<const unsigned char*>(plaintext.data()),
			static_cast<int>(plaintext.size()),
			nullptr));
		if (!message) {
			return { .status = RawRsaStatus::EncryptionFailed };
		}
		if (BN_cmp(message.get(), modulus.get()) >= 0) {
			return { .status = RawRsaStatus::MessageOutOfRange };
		}

		BigNumber encrypted(BN_new());
		Context context(BN_CTX_new());
		if (!encrypted || !context
		    || BN_mod_exp(encrypted.get(), message.get(), publicExponent.get(), modulus.get(), context.get()) != 1) {
			return { .status = RawRsaStatus::EncryptionFailed };
		}

		std::vector<std::byte> ciphertext(constants::rsaBlockSize);
		if (BN_bn2binpad(
				encrypted.get(),
				reinterpret_cast<unsigned char*>(ciphertext.data()),
				static_cast<int>(ciphertext.size())) != static_cast<int>(ciphertext.size())) {
			return { .status = RawRsaStatus::EncryptionFailed };
		}
		return { .status = RawRsaStatus::Ready, .ciphertext = std::move(ciphertext) };
	}

}
