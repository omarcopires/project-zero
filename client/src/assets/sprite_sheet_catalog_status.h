#pragma once

namespace assets {

	enum class SpriteSheetCatalogStatus {
	Ready,
	InvalidAssetsDirectory,
	ManifestUnavailable,
	InvalidManifest,
	EmptyCatalog,
	OverlappingSpriteRanges,
};

}
