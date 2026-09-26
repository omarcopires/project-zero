#pragma once

#include "assets/sprite_image_status.h"

#include <QImage>

namespace assets {

	struct SpriteSheetImageResult {
		SpriteImageStatus status = SpriteImageStatus::CatalogUnavailable;
		QImage image;
	};

}
