#include "session/authentication/login_codec.h"

#include "core/client_identity.h"

#include <gtest/gtest.h>

#include <QJsonDocument>
#include <QJsonObject>

namespace session::authentication {
	namespace {

		const QByteArray validResponse = R"({
  "session":{"sessionkey":"synthetic-session","status":"active"},
  "playdata":{
    "worlds":[{"id":0,"name":"Local","externaladdressunprotected":"127.0.0.1","externalportunprotected":7172}],
    "characters":[{"name":"Synthetic Character","worldid":0}]
  }
})";

		TEST(LoginCodec, EncodesMinimalSupportedLoginRequest) {
			const auto encoded = encodeLoginRequest({ .email = "test@example.invalid", .password = "secret" });

			ASSERT_TRUE(encoded.has_value());
			const auto object = QJsonDocument::fromJson(*encoded).object();
			EXPECT_EQ(object.value(QStringLiteral("type")).toString(), QStringLiteral("login"));
			EXPECT_EQ(object.value(QStringLiteral("email")).toString(), QStringLiteral("test@example.invalid"));
			EXPECT_EQ(object.value(QStringLiteral("password")).toString(), QStringLiteral("secret"));
			EXPECT_EQ(object.value(QStringLiteral("twoFactorAction")).toString(), QStringLiteral("skip"));
			EXPECT_EQ(object.value(QStringLiteral("version")).toInt(), client::identity::version);
		}

		TEST(LoginCodec, RejectsEmptyCredentials) {
			EXPECT_FALSE(encodeLoginRequest({}).has_value());
			EXPECT_FALSE(encodeLoginRequest({ .email = "test@example.invalid" }).has_value());
		}

		TEST(LoginCodec, DecodesSessionWorldAndCharacter) {
			const auto response = decodeLoginResponse(validResponse);

			EXPECT_EQ(response.status, LoginResponseStatus::Success);
			EXPECT_EQ(response.sessionKey, "synthetic-session");
			ASSERT_EQ(response.worlds.size(), 1);
			EXPECT_EQ(response.worlds.front().port, 7172);
			ASSERT_EQ(response.characters.size(), 1);
			EXPECT_EQ(response.characters.front().name, "Synthetic Character");
		}

		TEST(LoginCodec, ClassifiesAuthenticationError) {
			const auto response = decodeLoginResponse(R"({"errorMessage":"remote text is not presented directly"})");
			EXPECT_EQ(response.status, LoginResponseStatus::AuthenticationRejected);
		}

		TEST(LoginCodec, RejectsRequiredTwoFactorChallenge) {
			const auto response = decodeLoginResponse(R"({"errorCode":6,"errorMessage":"code required"})");
			EXPECT_EQ(response.status, LoginResponseStatus::UnsupportedChallenge);
		}

		TEST(LoginCodec, RejectsEnrollmentChallenge) {
			const auto response = decodeLoginResponse(R"({"errorCode":7,"twoFactorSetup":{"secret":"must-not-be-used"}})");
			EXPECT_EQ(response.status, LoginResponseStatus::UnsupportedChallenge);
			EXPECT_TRUE(response.sessionKey.empty());
		}

		TEST(LoginCodec, RejectsMalformedJson) {
			EXPECT_EQ(decodeLoginResponse(QByteArrayLiteral("not-json")).status, LoginResponseStatus::InvalidResponse);
		}

		TEST(LoginCodec, RejectsIncompleteSuccess) {
			EXPECT_EQ(decodeLoginResponse(R"({"session":{"sessionkey":"x","status":"active"},"playdata":{}})").status, LoginResponseStatus::InvalidResponse);
		}

	}
}
