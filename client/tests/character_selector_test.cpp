#include "session/selection/character_selector.h"

#include <gtest/gtest.h>

namespace session::selection {
	namespace {

		authentication::LoginResponse validSession() {
			authentication::LoginResponse response;
			response.status = authentication::LoginResponseStatus::Success;
			response.sessionKey = "synthetic-session";
			response.worlds.push_back({ .id = 7, .name = "Local World", .host = "127.0.0.1", .port = 7172 });
			response.characters.push_back({ .name = "First Character", .worldId = 7 });
			return response;
		}

		TEST(CharacterSelector, RequiresAuthenticatedSession) {
			CharacterSelector selector;
			const auto result = selector.select("First Character");

			EXPECT_EQ(result.status, CharacterSelectionStatus::SessionUnavailable);
			EXPECT_FALSE(result.target.has_value());
		}

		TEST(CharacterSelector, ResolvesSelectedCharacterAndWorld) {
			CharacterSelector selector;
			ASSERT_TRUE(selector.updateSession(validSession()));

			const auto result = selector.select("First Character");

			ASSERT_EQ(result.status, CharacterSelectionStatus::Success);
			ASSERT_TRUE(result.target.has_value());
			EXPECT_EQ(result.target->sessionKey, "synthetic-session");
			EXPECT_EQ(result.target->characterName, "First Character");
			EXPECT_EQ(result.target->worldName, "Local World");
			EXPECT_EQ(result.target->host, "127.0.0.1");
			EXPECT_EQ(result.target->port, 7172);
		}

		TEST(CharacterSelector, RejectsUnknownCharacter) {
			CharacterSelector selector;
			ASSERT_TRUE(selector.updateSession(validSession()));

			EXPECT_EQ(selector.select("Unknown").status, CharacterSelectionStatus::CharacterNotFound);
		}

		TEST(CharacterSelector, RejectsAmbiguousCharacter) {
			auto response = validSession();
			response.characters.push_back(response.characters.front());
			CharacterSelector selector;
			ASSERT_TRUE(selector.updateSession(response));

			EXPECT_EQ(selector.select("First Character").status, CharacterSelectionStatus::AmbiguousCharacter);
		}

		TEST(CharacterSelector, RejectsMissingWorld) {
			auto response = validSession();
			response.worlds.clear();
			CharacterSelector selector;
			ASSERT_TRUE(selector.updateSession(response));

			EXPECT_EQ(selector.select("First Character").status, CharacterSelectionStatus::WorldNotFound);
		}

		TEST(CharacterSelector, RejectsAmbiguousWorld) {
			auto response = validSession();
			response.worlds.push_back(response.worlds.front());
			CharacterSelector selector;
			ASSERT_TRUE(selector.updateSession(response));

			EXPECT_EQ(selector.select("First Character").status, CharacterSelectionStatus::AmbiguousWorld);
		}

		TEST(CharacterSelector, RejectsInvalidEndpoint) {
			auto response = validSession();
			response.worlds.front().port = 0;
			CharacterSelector selector;
			ASSERT_TRUE(selector.updateSession(response));

			EXPECT_EQ(selector.select("First Character").status, CharacterSelectionStatus::InvalidEndpoint);
		}

		TEST(CharacterSelector, NewSessionInvalidatesSelection) {
			CharacterSelector selector;
			auto response = validSession();
			ASSERT_TRUE(selector.updateSession(response));
			ASSERT_EQ(selector.select("First Character").status, CharacterSelectionStatus::Success);
			ASSERT_NE(selector.selectedTarget(), nullptr);

			response.sessionKey = "replacement-session";
			ASSERT_TRUE(selector.updateSession(response));
			EXPECT_EQ(selector.selectedTarget(), nullptr);
		}

		TEST(CharacterSelector, FailedSessionClearsPreviousSelection) {
			CharacterSelector selector;
			ASSERT_TRUE(selector.updateSession(validSession()));
			ASSERT_EQ(selector.select("First Character").status, CharacterSelectionStatus::Success);

			authentication::LoginResponse rejected { .status = authentication::LoginResponseStatus::AuthenticationRejected };
			EXPECT_FALSE(selector.updateSession(rejected));
			EXPECT_EQ(selector.selectedTarget(), nullptr);
			EXPECT_EQ(selector.select("First Character").status, CharacterSelectionStatus::SessionUnavailable);
		}

	}
}
