#pragma once

#include "assets/appearance_catalog.h"
#include "assets/appearance_catalog_load_status.h"

#include <optional>

namespace assets {

	struct AppearanceCatalogLoadResult {
		AppearanceCatalogLoadStatus status;
		std::optional<AppearanceCatalog> catalog;
	};

}
