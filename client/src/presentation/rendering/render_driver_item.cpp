#include "presentation/rendering/render_driver_item.h"

#include <QQuickWindow>
#include <QSGRendererInterface>

namespace client::presentation::rendering {

	RenderDriverItem::RenderDriverItem(QQuickItem *parent) : QQuickItem(parent) {
		setFlag(ItemHasContents, false);
		connect(this, &QQuickItem::windowChanged, this, &RenderDriverItem::graphicsApiChanged);
	}

	QString RenderDriverItem::graphicsApi() const {
		const auto *quickWindow = window();
		if (quickWindow == nullptr || quickWindow->rendererInterface() == nullptr) {
			return QStringLiteral("unavailable");
		}

		const auto api = quickWindow->rendererInterface()->graphicsApi();
		switch (api) {
			case QSGRendererInterface::Software:
				return QStringLiteral("software");
			case QSGRendererInterface::OpenVG:
				return QStringLiteral("openvg");
			case QSGRendererInterface::OpenGL:
				return QStringLiteral("opengl");
			case QSGRendererInterface::Direct3D11:
				return QStringLiteral("direct3d11");
			case QSGRendererInterface::Vulkan:
				return QStringLiteral("vulkan");
			case QSGRendererInterface::Metal:
				return QStringLiteral("metal");
			case QSGRendererInterface::Null:
				return QStringLiteral("null");
			case QSGRendererInterface::Unknown:
				return QStringLiteral("unknown");
		}
		return QStringLiteral("unknown");
	}

}
