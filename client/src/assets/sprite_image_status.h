#pragma once

namespace assets {

	enum class SpriteImageStatus {
	Ready,
	CatalogUnavailable,
	SpriteNotFound,
	SpriteOutOfRange,
	SpriteSheetUnavailable,
	InvalidCompressedData,
	InvalidBitmap,
};

}
