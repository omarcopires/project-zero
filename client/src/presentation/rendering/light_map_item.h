#pragma once

#include <QPainter>
#include <QQuickPaintedItem>

namespace client::presentation::rendering {

	class LightMapItem : public QQuickPaintedItem {
		Q_OBJECT
		Q_PROPERTY(qreal scale READ lightScale WRITE setLightScale)

	public:
		explicit LightMapItem(QQuickItem *parent = nullptr);

		qreal lightScale() const noexcept;
		void setLightScale(qreal scale);
		void paint(QPainter *painter) override;

	signals:
		void lightScaleChanged();

	private:
		qreal m_lightScale = 0.0;
	};

}
