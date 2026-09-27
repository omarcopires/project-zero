#include "presentation/rendering/light_map_item.h"

#include <QPainter>

namespace client::presentation::rendering {

	LightMapItem::LightMapItem(QQuickItem *parent) : QQuickPaintedItem(parent) {
		setOpaquePainting(false);
	}

	qreal LightMapItem::lightScale() const noexcept {
		return m_lightScale;
	}

	void LightMapItem::setLightScale(const qreal scale) {
		if (m_lightScale == scale) {
			return;
		}
		m_lightScale = scale;
		emit lightScaleChanged();
	}

	void LightMapItem::paint(QPainter *) {
		// Lighting remains transparent until authoritative light data is available.
	}

}
