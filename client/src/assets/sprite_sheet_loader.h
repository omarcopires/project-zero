#pragma once

#include "assets/sprite_sheet_catalog_status.h"
#include "assets/sprite_sheet_image_result.h"
#include "assets/sprite_sheet_type.h"

#include <QCache>
#include <QString>

#include <cstddef>
#include <cstdint>
#include <vector>

namespace assets {

	class SpriteSheetLoader final {
	public:
		SpriteSheetLoader();

		SpriteSheetCatalogStatus loadCatalog(const QString &assetsDirectory);
		SpriteSheetImageResult loadSpriteImage(std::uint32_t spriteId);
		std::size_t sheetCount() const noexcept;

	private:
		struct SheetEntry {
			QString fileName;
			std::uint32_t firstSpriteId = 0;
			std::uint32_t lastSpriteId = 0;
			SpriteSheetType type = SpriteSheetType::Standard;
		};

		const SheetEntry *findSheet(std::uint32_t spriteId) const noexcept;
		QImage loadSheet(const SheetEntry &entry, SpriteImageStatus &status);

		QString m_assetsDirectory;
		SpriteSheetCatalogStatus m_catalogStatus = SpriteSheetCatalogStatus::InvalidAssetsDirectory;
		std::vector<SheetEntry> m_sheets;
		QCache<QString, QImage> m_sheetCache;
	};

}
