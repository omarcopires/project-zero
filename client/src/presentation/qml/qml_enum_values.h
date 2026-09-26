#pragma once

#include <QObject>

namespace client::presentation::qml {

	class TibiaEnumsAdapter final : public QObject {
		Q_OBJECT
		Q_PROPERTY(int PreferBoth READ preferBoth CONSTANT)
		Q_PROPERTY(int PreferMapWindow READ preferMapWindow CONSTANT)
		Q_PROPERTY(int PreferChat READ preferChat CONSTANT)
		Q_PROPERTY(int AntialiasingModeNone READ antialiasingModeNone CONSTANT)
		Q_PROPERTY(int AntialiasingModeAntialiasing READ antialiasingModeAntialiasing CONSTANT)
		Q_PROPERTY(int AntialiasingModeRetro READ antialiasingModeRetro CONSTANT)

	public:
		using QObject::QObject;

		[[nodiscard]] int preferBoth() const;
		[[nodiscard]] int preferMapWindow() const;
		[[nodiscard]] int preferChat() const;
		[[nodiscard]] int antialiasingModeNone() const;
		[[nodiscard]] int antialiasingModeAntialiasing() const;
		[[nodiscard]] int antialiasingModeRetro() const;
	};

	void registerQmlEnumValues();

}
