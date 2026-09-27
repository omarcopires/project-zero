#include "presentation/rendering/world_map_item.h"

#include "protocol/game/map_thing_kind.h"

#include <QPainter>

#include <cstdint>
#include <utility>

namespace client::presentation::rendering {
	namespace {

		constexpr qreal fieldSize = 32.0;

	}

	WorldMapItem::WorldMapItem(QQuickItem *parent) : QQuickPaintedItem(parent) {
		setOpaquePainting(false);
		setAntialiasing(false);
	}

	void WorldMapItem::setMapDescription(protocol::game::MapDescription description) {
		m_mapDescription = std::move(description);
		update();
	}

	void WorldMapItem::setAppearanceImageLookup(AppearanceImageLookup lookup) {
		m_appearanceImageLookup = std::move(lookup);
		update();
	}

	void WorldMapItem::paint(QPainter *painter) {
		if (painter == nullptr || !m_mapDescription || !m_appearanceImageLookup
		    || width() <= 0 || height() <= 0) {
			return;
		}

		painter->save();
		painter->setClipRect(boundingRect());
		for (const auto &tile : m_mapDescription->tiles) {
			if (tile.position.floor != m_mapDescription->center.floor) {
				continue;
			}

			const qreal fieldX = width() / 2.0
				+ (static_cast<std::int32_t>(tile.position.x) - m_mapDescription->center.x) * fieldSize
				- fieldSize / 2.0;
			const qreal fieldY = height() / 2.0
				+ (static_cast<std::int32_t>(tile.position.y) - m_mapDescription->center.y) * fieldSize
				- fieldSize / 2.0;
			for (const auto &thing : tile.things) {
				auto kind = assets::AppearanceKind::Object;
				std::uint32_t appearanceId = thing.id;
				if (thing.kind != protocol::game::MapThingKind::Object) {
					appearanceId = thing.appearanceId;
					if (!thing.appearanceIsObject) {
						kind = assets::AppearanceKind::Outfit;
					}
				}

				const QImage image = m_appearanceImageLookup(
					kind, appearanceId
				);
				if (image.isNull()) {
					continue;
				}

				const QPointF imagePosition(
					fieldX + (fieldSize - image.width()) / 2.0,
					fieldY + fieldSize - image.height()
				);
				painter->drawImage(imagePosition, image);
			}
		}
		painter->restore();
	}

}
