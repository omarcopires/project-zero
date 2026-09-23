#include "session/selection/character_selector.h"

#include "session/authentication/login_response_status.h"

#include <algorithm>

namespace session::selection {

	bool CharacterSelector::updateSession(const authentication::LoginResponse &response) {
		clearSession();
		if (response.status != authentication::LoginResponseStatus::Success || response.sessionKey.empty()) {
			return false;
		}

		m_session = response;
		return true;
	}

	void CharacterSelector::clearSession() {
		m_selectedTarget.reset();
		m_session.reset();
	}

	CharacterSelectionResult CharacterSelector::select(const std::string_view characterName) {
		m_selectedTarget.reset();
		if (!m_session.has_value()) {
			return { .status = CharacterSelectionStatus::SessionUnavailable };
		}

		const auto characterMatches = std::ranges::count_if(m_session->characters, [&](const auto &character) {
			return std::string_view(character.name) == characterName;
		});
		if (characterMatches == 0) {
			return { .status = CharacterSelectionStatus::CharacterNotFound };
		}
		if (characterMatches != 1) {
			return { .status = CharacterSelectionStatus::AmbiguousCharacter };
		}

		const auto character = std::ranges::find_if(m_session->characters, [&](const auto &candidate) {
			return std::string_view(candidate.name) == characterName;
		});
		const auto worldMatches = std::ranges::count_if(m_session->worlds, [&](const auto &world) {
			return world.id == character->worldId;
		});
		if (worldMatches == 0) {
			return { .status = CharacterSelectionStatus::WorldNotFound };
		}
		if (worldMatches != 1) {
			return { .status = CharacterSelectionStatus::AmbiguousWorld };
		}

		const auto world = std::ranges::find_if(m_session->worlds, [&](const auto &candidate) {
			return candidate.id == character->worldId;
		});
		if (world->host.empty() || world->port == 0) {
			return { .status = CharacterSelectionStatus::InvalidEndpoint };
		}

		m_selectedTarget = WorldConnectionTarget {
			.sessionKey = m_session->sessionKey,
			.characterName = character->name,
			.worldName = world->name,
			.host = world->host,
			.port = world->port,
		};
		return { .status = CharacterSelectionStatus::Success, .target = m_selectedTarget };
	}

	const WorldConnectionTarget* CharacterSelector::selectedTarget() const {
		return m_selectedTarget ? &*m_selectedTarget : nullptr;
	}

}
