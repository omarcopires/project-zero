#pragma once

#include <QQuickItem>
#include <QString>

namespace client::presentation::rendering {

	class RenderDriverItem : public QQuickItem {
		Q_OBJECT
		Q_PROPERTY(QString graphicsApi READ graphicsApi NOTIFY graphicsApiChanged)

	public:
		explicit RenderDriverItem(QQuickItem *parent = nullptr);

		QString graphicsApi() const;

	signals:
		void graphicsApiChanged();
	};

}
