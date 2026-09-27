#include "presentation/qml/tooltip_helper.h"

#include <QCursor>
#include <QEvent>
#include <QGuiApplication>
#include <QQuickWindow>

namespace client::presentation::qml {

	TooltipWatcher::TooltipWatcher(QQuickItem *item)
		: QObject(item),
		  m_item(item),
		  m_window(item == nullptr ? nullptr : item->window()) {
		if (m_window != nullptr) {
			m_window->installEventFilter(this);
		}
		m_refreshTimer.setInterval(50);
		connect(&m_refreshTimer, &QTimer::timeout, this, &TooltipWatcher::hoverRefresh);
		m_refreshTimer.start();
	}

	bool TooltipWatcher::contained(QQuickItem *item) const {
		if (!m_registered || item == nullptr || item->window() == nullptr
		    || !item->isVisible() || !item->isEnabled()) {
			return false;
		}
		const QPointF globalPosition(QCursor::pos());
		const QPointF localPosition = item->mapFromGlobal(globalPosition);
		return item->contains(localPosition);
	}

	QPointF TooltipWatcher::hoverPosition(QQuickItem *item) const {
		if (item == nullptr || item->window() == nullptr) {
			return {};
		}
		return item->mapFromGlobal(QPointF(QCursor::pos()));
	}

	void TooltipWatcher::unregister() {
		if (!m_registered) {
			return;
		}
		m_registered = false;
		m_refreshTimer.stop();
		if (m_window != nullptr) {
			m_window->removeEventFilter(this);
		}
		emit unregistered();
		deleteLater();
	}

	bool TooltipWatcher::eventFilter(QObject *watched, QEvent *event) {
		if (watched == m_window && m_registered) {
			if (event->type() == QEvent::MouseButtonPress) {
				emit mouseButtonPressed();
			} else if (event->type() == QEvent::MouseMove || event->type() == QEvent::HoverMove
			           || event->type() == QEvent::Leave || event->type() == QEvent::WindowDeactivate) {
				emit hoverRefresh();
			}
		}
		return QObject::eventFilter(watched, event);
	}

	QQuickItem *TooltipHelper::findWindowContentItemForQuickItem(QQuickItem *item) const {
		return item == nullptr || item->window() == nullptr ? nullptr : item->window()->contentItem();
	}

	TooltipWatcher *TooltipHelper::registerTooltip(QQuickItem *item) {
		return item == nullptr ? nullptr : new TooltipWatcher(item);
	}

	bool TooltipHelper::inWindow() const {
		return QGuiApplication::applicationState() == Qt::ApplicationActive;
	}

}
