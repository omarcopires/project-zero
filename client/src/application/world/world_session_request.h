#pragma once

#include "infrastructure/transport/connection_options.h"
#include "protocol/crypto/xtea.h"

#include <string>

namespace application::world {

	struct WorldSessionRequest {
		infrastructure::transport::ConnectionOptions connection;
		std::string sessionKey;
		std::string characterName;
		std::string assetHashIdentifier;
		protocol::crypto::XteaKey xteaKey {};
	};

}
