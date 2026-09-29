#pragma once

#include <QObject>

namespace client::presentation::qml {

	class SelectionModeAdapter final : public QObject {
		Q_OBJECT

	public:
		enum SelectionMode {
			NoSelection = 0,
			SingleSelection = 1,
			MultiSelection = 2,
			ExtendedSelection = 3,
			ContiguousSelection = 4
		};
		Q_ENUM(SelectionMode)
	};

	class TibiaEnumsAdapter final : public QObject {
		Q_OBJECT
		Q_PROPERTY(int PreferBoth READ preferBoth CONSTANT)
		Q_PROPERTY(int PreferMapWindow READ preferMapWindow CONSTANT)
		Q_PROPERTY(int PreferChat READ preferChat CONSTANT)
		Q_PROPERTY(int AntialiasingModeNone READ antialiasingModeNone CONSTANT)
		Q_PROPERTY(int AntialiasingModeAntialiasing READ antialiasingModeAntialiasing CONSTANT)
		Q_PROPERTY(int AntialiasingModeRetro READ antialiasingModeRetro CONSTANT)
		Q_PROPERTY(int DailyRewardStateCollected READ dailyRewardStateCollected CONSTANT)
		Q_PROPERTY(int DailyRewardStateNotCollected READ dailyRewardStateNotCollected CONSTANT)
		Q_PROPERTY(int DailyRewardStateNotAvailable READ dailyRewardStateNotAvailable CONSTANT)

	public:
		using QObject::QObject;

		[[nodiscard]] int preferBoth() const;
		[[nodiscard]] int preferMapWindow() const;
		[[nodiscard]] int preferChat() const;
		[[nodiscard]] int antialiasingModeNone() const;
		[[nodiscard]] int antialiasingModeAntialiasing() const;
		[[nodiscard]] int antialiasingModeRetro() const;
		[[nodiscard]] int dailyRewardStateCollected() const;
		[[nodiscard]] int dailyRewardStateNotCollected() const;
		[[nodiscard]] int dailyRewardStateNotAvailable() const;
	};

	void registerQmlEnumValues();

}
