#pragma once

#include "session/authentication/login_response.h"
#include "session/selection/character_selection_result.h"

#include <optional>
#include <string_view>

namespace session::selection {

	class CharacterSelector final {
	public:
		bool updateSession(const authentication::LoginResponse &response);
		void clearSession();
		CharacterSelectionResult select(std::string_view characterName);

		const WorldConnectionTarget* selectedTarget() const;

	private:
		std::optional<authentication::LoginResponse> m_session;
		std::optional<WorldConnectionTarget> m_selectedTarget;
	};

}
