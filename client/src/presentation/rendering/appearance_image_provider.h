#pragma once

#include "assets/appearance_catalog.h"
#include "assets/sprite_sheet_loader.h"

#include <QMutex>
#include <QQuickImageProvider>
#include <QString>
#include <QStringView>

#include <optional>

namespace client::presentation::rendering {

	class AppearanceImageProvider final : public QQuickImageProvider {
	public:
		explicit AppearanceImageProvider(const QString &assetsDirectory);

		QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize) override;

	private:
		std::optional<assets::AppearanceKind> parseKind(QStringView kind) const noexcept;

		std::optional<assets::AppearanceCatalog> m_appearanceCatalog;
		QMutex m_spriteLoaderMutex;
		assets::SpriteSheetLoader m_spriteSheetLoader;
	};

}
