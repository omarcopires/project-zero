#pragma once

#include "assets/appearance_kind.h"
#include "protocol/game/map_description.h"

#include <QImage>
#include <QPainter>
#include <QQuickPaintedItem>

#include <functional>
#include <optional>

namespace client::presentation::rendering {

	class WorldMapItem : public QQuickPaintedItem {
		Q_OBJECT

	public:
		using AppearanceImageLookup = std::function<QImage(assets::AppearanceKind kind, std::uint32_t id)>;

		explicit WorldMapItem(QQuickItem *parent = nullptr);

		void setMapDescription(protocol::game::MapDescription description);
		void setAppearanceImageLookup(AppearanceImageLookup lookup);
		void paint(QPainter *painter) override;

	private:
		std::optional<protocol::game::MapDescription> m_mapDescription;
		AppearanceImageLookup m_appearanceImageLookup;
	};

}
