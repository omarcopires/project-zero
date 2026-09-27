#pragma once

#include <QQuickImageProvider>

namespace client::presentation::rendering {

	class OptimizedBorderImageProvider final : public QQuickImageProvider {
	public:
		OptimizedBorderImageProvider();

		QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize) override;
	};

}
