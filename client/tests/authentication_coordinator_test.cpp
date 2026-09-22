#include "session/authentication/authentication_coordinator.h"

#include <gtest/gtest.h>

namespace session::authentication {
	namespace {

		LoginResponse successfulResponse() {
			LoginResponse response;
			response.status = LoginResponseStatus::Success;
			response.sessionKey = "synthetic-session";
			response.worlds.push_back({ .id = 0, .name = "Local", .host = "127.0.0.1", .port = 7172 });
			response.characters.push_back({ .name = "Synthetic Character", .worldId = 0 });
			return response;
		}

		TEST(AuthenticationCoordinator, StartsWithMonotonicAttempt) {
			AuthenticationCoordinator coordinator;

			const auto first = coordinator.begin();
			ASSERT_TRUE(first.has_value());
			EXPECT_EQ(coordinator.state(), AuthenticationState::Authenticating);
			EXPECT_EQ(coordinator.activeAttempt(), first);

			EXPECT_TRUE(coordinator.cancel(*first));
			const auto second = coordinator.begin();
			ASSERT_TRUE(second.has_value());
			EXPECT_GT(second->id, first->id);
		}

		TEST(AuthenticationCoordinator, RejectsConcurrentAttempt) {
			AuthenticationCoordinator coordinator;
			ASSERT_TRUE(coordinator.begin().has_value());

			EXPECT_FALSE(coordinator.begin().has_value());
			EXPECT_EQ(coordinator.state(), AuthenticationState::Authenticating);
		}

		TEST(AuthenticationCoordinator, StoresOnlySuccessfulSession) {
			AuthenticationCoordinator coordinator;
			const auto attempt = coordinator.begin();
			ASSERT_TRUE(attempt.has_value());

			EXPECT_TRUE(coordinator.complete(*attempt, successfulResponse()));
			EXPECT_EQ(coordinator.state(), AuthenticationState::Authenticated);
			ASSERT_NE(coordinator.authenticatedSession(), nullptr);
			EXPECT_EQ(coordinator.authenticatedSession()->sessionKey, "synthetic-session");
			EXPECT_FALSE(coordinator.activeAttempt().has_value());
		}

		TEST(AuthenticationCoordinator, ClassifiesRejectedCredentials) {
			AuthenticationCoordinator coordinator;
			const auto attempt = coordinator.begin();
			ASSERT_TRUE(attempt.has_value());

			EXPECT_TRUE(coordinator.complete(*attempt, { .status = LoginResponseStatus::AuthenticationRejected }));
			EXPECT_EQ(coordinator.state(), AuthenticationState::Rejected);
			EXPECT_EQ(coordinator.authenticatedSession(), nullptr);
		}

		TEST(AuthenticationCoordinator, StopsAtUnsupportedChallenge) {
			AuthenticationCoordinator coordinator;
			const auto attempt = coordinator.begin();
			ASSERT_TRUE(attempt.has_value());

			EXPECT_TRUE(coordinator.complete(*attempt, { .status = LoginResponseStatus::UnsupportedChallenge }));
			EXPECT_EQ(coordinator.state(), AuthenticationState::UnsupportedChallenge);
			EXPECT_EQ(coordinator.authenticatedSession(), nullptr);
		}

		TEST(AuthenticationCoordinator, ClassifiesIncompatibleResponse) {
			AuthenticationCoordinator coordinator;
			const auto attempt = coordinator.begin();
			ASSERT_TRUE(attempt.has_value());

			EXPECT_TRUE(coordinator.complete(*attempt, {}));
			EXPECT_EQ(coordinator.state(), AuthenticationState::Failed);
			EXPECT_EQ(coordinator.failureReason(), AuthenticationFailureReason::IncompatibleResponse);
		}

		TEST(AuthenticationCoordinator, IgnoresResponseAfterCancellation) {
			AuthenticationCoordinator coordinator;
			const auto attempt = coordinator.begin();
			ASSERT_TRUE(attempt.has_value());
			ASSERT_TRUE(coordinator.cancel(*attempt));

			EXPECT_FALSE(coordinator.complete(*attempt, successfulResponse()));
			EXPECT_EQ(coordinator.state(), AuthenticationState::Cancelled);
			EXPECT_EQ(coordinator.authenticatedSession(), nullptr);
		}

		TEST(AuthenticationCoordinator, IgnoresResponseFromOlderAttempt) {
			AuthenticationCoordinator coordinator;
			const auto first = coordinator.begin();
			ASSERT_TRUE(first.has_value());
			ASSERT_TRUE(coordinator.cancel(*first));
			const auto second = coordinator.begin();
			ASSERT_TRUE(second.has_value());

			EXPECT_FALSE(coordinator.complete(*first, successfulResponse()));
			EXPECT_EQ(coordinator.activeAttempt(), second);
			EXPECT_EQ(coordinator.state(), AuthenticationState::Authenticating);
		}

		TEST(AuthenticationCoordinator, DistinguishesTimeoutFromTransportFailure) {
			AuthenticationCoordinator coordinator;
			const auto timeoutAttempt = coordinator.begin();
			ASSERT_TRUE(timeoutAttempt.has_value());
			EXPECT_TRUE(coordinator.fail(*timeoutAttempt, AuthenticationFailureReason::Timeout));
			EXPECT_EQ(coordinator.failureReason(), AuthenticationFailureReason::Timeout);

			const auto transportAttempt = coordinator.begin();
			ASSERT_TRUE(transportAttempt.has_value());
			EXPECT_TRUE(coordinator.fail(*transportAttempt, AuthenticationFailureReason::Transport));
			EXPECT_EQ(coordinator.failureReason(), AuthenticationFailureReason::Transport);
		}

	}
}
