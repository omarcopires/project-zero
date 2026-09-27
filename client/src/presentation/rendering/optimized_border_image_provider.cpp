#include "presentation/rendering/optimized_border_image_provider.h"

#include <QImage>
#include <QPainter>
#include <QRect>

namespace client::presentation::rendering {

	OptimizedBorderImageProvider::OptimizedBorderImageProvider()
		: QQuickImageProvider(QQuickImageProvider::Image) {}

	QImage OptimizedBorderImageProvider::requestImage(
		const QString &id,
		QSize *size,
		const QSize &requestedSize
	) {
		if (size != nullptr) {
			*size = {};
		}
		if (!id.startsWith(QStringLiteral("/images/")) || id.contains(QStringLiteral(".."))) {
			return {};
		}

		const QImage source(QStringLiteral(":") + id);
		if (source.isNull()) {
			return {};
		}
		const QSize targetSize = requestedSize.isValid() && !requestedSize.isEmpty()
			? requestedSize
			: source.size();
		if (targetSize.width() > 4096 || targetSize.height() > 4096) {
			return {};
		}
		if (size != nullptr) {
			*size = targetSize;
		}
		if (targetSize == source.size()) {
			return source;
		}
		if (source.width() < 3 || source.height() < 3 || targetSize.width() < 3 || targetSize.height() < 3) {
			return source.scaled(targetSize, Qt::IgnoreAspectRatio, Qt::FastTransformation);
		}

		QImage result(targetSize, QImage::Format_ARGB32_Premultiplied);
		result.fill(Qt::transparent);
		QPainter painter(&result);
		painter.setRenderHint(QPainter::SmoothPixmapTransform, false);

		const int sourceRight = source.width() - 1;
		const int sourceBottom = source.height() - 1;
		const int targetRight = targetSize.width() - 1;
		const int targetBottom = targetSize.height() - 1;
		const QRect sourceRects[3][3] = {
			{ QRect(0, 0, 1, 1), QRect(1, 0, sourceRight - 1, 1), QRect(sourceRight, 0, 1, 1) },
			{ QRect(0, 1, 1, sourceBottom - 1), QRect(1, 1, sourceRight - 1, sourceBottom - 1), QRect(sourceRight, 1, 1, sourceBottom - 1) },
			{ QRect(0, sourceBottom, 1, 1), QRect(1, sourceBottom, sourceRight - 1, 1), QRect(sourceRight, sourceBottom, 1, 1) },
		};
		const QRect targetRects[3][3] = {
			{ QRect(0, 0, 1, 1), QRect(1, 0, targetRight - 1, 1), QRect(targetRight, 0, 1, 1) },
			{ QRect(0, 1, 1, targetBottom - 1), QRect(1, 1, targetRight - 1, targetBottom - 1), QRect(targetRight, 1, 1, targetBottom - 1) },
			{ QRect(0, targetBottom, 1, 1), QRect(1, targetBottom, targetRight - 1, 1), QRect(targetRight, targetBottom, 1, 1) },
		};
		for (int row = 0; row < 3; ++row) {
			for (int column = 0; column < 3; ++column) {
				painter.drawImage(targetRects[row][column], source, sourceRects[row][column]);
			}
		}
		return result;
	}

}
