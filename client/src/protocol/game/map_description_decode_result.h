#pragma once

#include "protocol/game/map_description.h"
#include "protocol/game/map_description_decode_status.h"

namespace protocol::game {

	struct MapDescriptionDecodeResult {
		MapDescriptionDecodeStatus status;
		MapDescription description;
	};

}
