#pragma once

#include <QObject>
#include <QPointer>
#include <QPointF>
#include <QQuickItem>
#include <QQuickWindow>
#include <QTimer>

namespace client::presentation::qml {

	class TooltipWatcher final : public QObject {
		Q_OBJECT

	public:
		explicit TooltipWatcher(QQuickItem *item);

		Q_INVOKABLE bool contained(QQuickItem *item) const;
		Q_INVOKABLE QPointF hoverPosition(QQuickItem *item) const;
		Q_INVOKABLE void unregister();

	signals:
		void hoverRefresh();
		void unregistered();
		void mouseButtonPressed();

	protected:
		bool eventFilter(QObject *watched, QEvent *event) override;

	private:
		QPointer<QQuickItem> m_item;
		QPointer<QQuickWindow> m_window;
		QTimer m_refreshTimer;
		bool m_registered = true;
	};

	class TooltipHelper final : public QObject {
		Q_OBJECT

	public:
		using QObject::QObject;

		Q_INVOKABLE QQuickItem *findWindowContentItemForQuickItem(QQuickItem *item) const;
		Q_INVOKABLE TooltipWatcher *registerTooltip(QQuickItem *item);
		Q_INVOKABLE bool inWindow() const;
	};

}
