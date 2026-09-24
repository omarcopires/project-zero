#pragma once

namespace assets {

	enum class AppearanceCatalogLoadStatus {
		Ready,
		InvalidAssetsDirectory,
		ManifestUnavailable,
		InvalidManifest,
		AppearanceAssetMissing,
		InvalidAssetPath,
		AppearanceAssetUnavailable,
		InvalidAppearanceData,
	};

}
