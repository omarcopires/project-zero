#include "presentation/rendering/appearance_image_provider.h"

#include "assets/appearance_catalog_loader.h"

#include <QImage>
#include <QMutexLocker>
#include <QStringView>

#include <limits>
#include <utility>

namespace client::presentation::rendering {

	AppearanceImageProvider::AppearanceImageProvider(const QString &assetsDirectory)
		: QQuickImageProvider(QQuickImageProvider::Image) {
		if (assetsDirectory.isEmpty()) {
			return;
		}

		auto catalogResult = assets::loadAppearanceCatalog(assetsDirectory);
		if (catalogResult.catalog.has_value()) {
			m_appearanceCatalog = std::move(catalogResult.catalog);
		}
		m_spriteSheetLoader.loadCatalog(assetsDirectory);
	}

	QImage AppearanceImageProvider::requestImage(
		const QString &id,
		QSize *size,
		const QSize &requestedSize
	) {
		if (size != nullptr) {
			*size = {};
		}
		if (!m_appearanceCatalog.has_value() || id.size() > 64) {
			return {};
		}
		const QMutexLocker spriteLoaderLock(&m_spriteLoaderMutex);

		const QStringView request(id);
		const qsizetype separator = request.indexOf(u'/');
		if (separator <= 0 || separator == request.size() - 1
		    || request.mid(separator + 1).contains(u'/')) {
			return {};
		}

		const auto kind = parseKind(request.left(separator));
		if (!kind) {
			return {};
		}

		bool idIsValid = false;
		const qulonglong parsedId = request.mid(separator + 1).toString().toULongLong(&idIsValid, 10);
		if (!idIsValid || parsedId > std::numeric_limits<std::uint32_t>::max()) {
			return {};
		}

		const auto *appearance = m_appearanceCatalog->find(*kind, static_cast<std::uint32_t>(parsedId));
		if (appearance == nullptr || appearance->frameGroups.empty()) {
			return {};
		}

		const auto &frameGroup = appearance->frameGroups.front();
		if (frameGroup.spriteInfo == std::nullopt) {
			return {};
		}
		const auto &spriteInfo = *frameGroup.spriteInfo;
		if (!spriteInfo.layers || *spriteInfo.layers != 1
		    || !spriteInfo.patternWidth || *spriteInfo.patternWidth != 1
		    || !spriteInfo.patternHeight || *spriteInfo.patternHeight != 1
		    || !spriteInfo.patternDepth || *spriteInfo.patternDepth != 1
		    || spriteInfo.spriteIds.size() != 1 || spriteInfo.animation.has_value()) {
			return {};
		}

		auto result = m_spriteSheetLoader.loadSpriteImage(spriteInfo.spriteIds.front());
		if (result.status != assets::SpriteImageStatus::Ready || result.image.isNull()) {
			return {};
		}
		if (size != nullptr) {
			*size = result.image.size();
		}
		if (requestedSize.isValid() && !requestedSize.isEmpty()
		    && requestedSize != result.image.size()) {
			return result.image.scaled(requestedSize, Qt::KeepAspectRatio, Qt::FastTransformation);
		}
		return result.image;
	}

	std::optional<assets::AppearanceKind> AppearanceImageProvider::parseKind(const QStringView kind) const noexcept {
		if (kind == u"object") {
			return assets::AppearanceKind::Object;
		}
		if (kind == u"outfit") {
			return assets::AppearanceKind::Outfit;
		}
		if (kind == u"effect") {
			return assets::AppearanceKind::Effect;
		}
		if (kind == u"missile") {
			return assets::AppearanceKind::Missile;
		}
		return std::nullopt;
	}

}
