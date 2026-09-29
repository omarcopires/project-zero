#pragma once

#include "application/authentication/authentication_service.h"
#include "application/world/world_session_service.h"
#include "infrastructure/logging/logger.h"
#include "session/selection/character_selector.h"

#include <QObject>
#include <QPointer>
#include <QQuickItem>
#include <QTimer>
#include <QString>
#include <QVariant>

#include <memory>

class QQmlApplicationEngine;
class QQuickItem;
class QQuickImageProvider;

namespace client::presentation::qml {

	class GameWindowController final : public QObject {
		Q_OBJECT
		Q_PROPERTY(QString gameWindowState READ gameWindowState NOTIFY propertiesChanged)
		Q_PROPERTY(bool isAuthenticated READ isAuthenticated NOTIFY propertiesChanged)
		Q_PROPERTY(bool showCreateAccountOption READ showCreateAccountOption CONSTANT)
		Q_PROPERTY(bool createAccountEnabled READ createAccountEnabled CONSTANT)
		Q_PROPERTY(bool rememberEmail READ rememberEmail WRITE setRememberEmail NOTIFY propertiesChanged)
		Q_PROPERTY(QString initialLoginEmail READ initialLoginEmail NOTIFY propertiesChanged)
		Q_PROPERTY(bool showEmailAsPlainText READ showEmailAsPlainText WRITE setShowEmailAsPlainText NOTIFY propertiesChanged)
		Q_PROPERTY(bool isCapsLockActive READ isCapsLockActive CONSTANT)
		Q_PROPERTY(QString hintAreaTitle READ hintAreaTitle NOTIFY propertiesChanged)
		Q_PROPERTY(QString hintAreaRichText READ hintAreaRichText NOTIFY propertiesChanged)
		Q_PROPERTY(int upperPaneHeight READ upperPaneHeight WRITE setUpperPaneHeight NOTIFY propertiesChanged)
		Q_PROPERTY(int lowerPaneHeight READ lowerPaneHeight WRITE setLowerPaneHeight NOTIFY propertiesChanged)
		Q_PROPERTY(int resizingMode READ resizingMode WRITE setResizingMode NOTIFY propertiesChanged)
		Q_PROPERTY(QObject* statusBarController READ statusBarController CONSTANT)
		Q_PROPERTY(bool statusBarVisible READ statusBarVisible CONSTANT)
		Q_PROPERTY(bool anthemMuted READ anthemMuted CONSTANT)
		Q_PROPERTY(bool musicMuted READ musicMuted CONSTANT)
		Q_PROPERTY(bool newEventToday READ newEventToday CONSTANT)
		Q_PROPERTY(int onlinePlayerCount READ onlinePlayerCount CONSTANT)
		Q_PROPERTY(int twitchStreamCount READ twitchStreamCount CONSTANT)
		Q_PROPERTY(int twitchViewerCount READ twitchViewerCount CONSTANT)
		Q_PROPERTY(int youTubeStreamCount READ youTubeStreamCount CONSTANT)
		Q_PROPERTY(int youTubeViewerCount READ youTubeViewerCount CONSTANT)
		Q_PROPERTY(QString dragonLogoSource READ dragonLogoSource CONSTANT)
		Q_PROPERTY(QString boostedBossName READ boostedBossName CONSTANT)
		Q_PROPERTY(QString boostedCreatureName READ boostedCreatureName CONSTANT)
		Q_PROPERTY(int boostedBossRace READ boostedBossRace CONSTANT)
		Q_PROPERTY(int boostedCreatureRace READ boostedCreatureRace CONSTANT)
		Q_PROPERTY(QVariant eventsScheduleCurrent READ eventsScheduleCurrent CONSTANT)
		Q_PROPERTY(QVariant eventsScheduleUpcoming READ eventsScheduleUpcoming CONSTANT)
		Q_PROPERTY(QString eventsScheduleCurrentTooltip READ eventsScheduleCurrentTooltip CONSTANT)
		Q_PROPERTY(QString eventsScheduleCurrentSeasonalTooltip READ eventsScheduleCurrentSeasonalTooltip CONSTANT)
		Q_PROPERTY(QString eventsScheduleUpcomingTooltip READ eventsScheduleUpcomingTooltip CONSTANT)
		Q_PROPERTY(QString eventsScheduleUpcomingSeasonalTooltip READ eventsScheduleUpcomingSeasonalTooltip CONSTANT)
		Q_PROPERTY(QVariantList characterList READ characterList NOTIFY propertiesChanged)
		Q_PROPERTY(QString accountPremiumStatus READ accountPremiumStatus CONSTANT)
		Q_PROPERTY(bool showOutfits READ showOutfits NOTIFY showOutfitsChanged)
		Q_PROPERTY(bool recoverySetupComplete READ recoverySetupComplete CONSTANT)
		Q_PROPERTY(bool isPremium READ isPremium CONSTANT)
		Q_PROPERTY(bool showGetPremiumButton READ showGetPremiumButton CONSTANT)
		Q_PROPERTY(QVariantList premiumFeaturesModel READ premiumFeaturesModel CONSTANT)
		Q_PROPERTY(bool showHiddenCharacters READ showHiddenCharacters NOTIFY showHiddenCharactersChanged)
		Q_PROPERTY(int lastSelectedIndex READ lastSelectedIndex CONSTANT)
		Q_PROPERTY(int sortColumn READ sortColumn CONSTANT)
		Q_PROPERTY(int sortOrder READ sortOrder CONSTANT)
		Q_PROPERTY(bool clientSettingSmoothFiltering READ clientSettingSmoothFiltering CONSTANT)
		Q_PROPERTY(QObject* mapWindowController READ mapWindowController CONSTANT)
		Q_PROPERTY(bool mapWindowScaleOnlyByEvenMultiples READ mapWindowScaleOnlyByEvenMultiples CONSTANT)
		Q_PROPERTY(bool useLightMap READ useLightMap CONSTANT)
		Q_PROPERTY(int antialiasingMode READ antialiasingMode CONSTANT)
		Q_PROPERTY(bool showNumericalEffects READ showNumericalEffects CONSTANT)

	public:
		GameWindowController(
			QQmlApplicationEngine* engine,
			QQuickImageProvider* appearanceProvider,
			infrastructure::logging::Logger &logger,
			QObject* parent = nullptr
		);

		QString gameWindowState() const;
		bool isAuthenticated() const;
		bool showCreateAccountOption() const;
		bool createAccountEnabled() const;
		bool rememberEmail() const;
		QString initialLoginEmail() const;
		bool showEmailAsPlainText() const;
		bool isCapsLockActive() const;
		QString hintAreaTitle() const;
		QString hintAreaRichText() const;
		int upperPaneHeight() const;
		int lowerPaneHeight() const;
		int resizingMode() const;
		QObject* statusBarController() const;
		bool statusBarVisible() const;
		bool anthemMuted() const;
		bool musicMuted() const;
		bool newEventToday() const;
		int onlinePlayerCount() const;
		int twitchStreamCount() const;
		int twitchViewerCount() const;
		int youTubeStreamCount() const;
		int youTubeViewerCount() const;
		QString dragonLogoSource() const;
		QString boostedBossName() const;
		QString boostedCreatureName() const;
		int boostedBossRace() const;
		int boostedCreatureRace() const;
		QVariant eventsScheduleCurrent() const;
		QVariant eventsScheduleUpcoming() const;
		QString eventsScheduleCurrentTooltip() const;
		QString eventsScheduleCurrentSeasonalTooltip() const;
		QString eventsScheduleUpcomingTooltip() const;
		QString eventsScheduleUpcomingSeasonalTooltip() const;
		QVariantList characterList() const;
		QString accountPremiumStatus() const;
		bool showOutfits() const;
		bool recoverySetupComplete() const;
		bool isPremium() const;
		bool showGetPremiumButton() const;
		QVariantList premiumFeaturesModel() const;
		bool showHiddenCharacters() const;
		int lastSelectedIndex() const;
		int sortColumn() const;
		int sortOrder() const;
		bool clientSettingSmoothFiltering() const;
		QObject* mapWindowController();
		bool mapWindowScaleOnlyByEvenMultiples() const;
		bool useLightMap() const;
		int antialiasingMode() const;
		bool showNumericalEffects() const;

		void setGameWindowRoot(QQuickItem* root);
		void setShowEmailAsPlainText(bool visible);
		void setRememberEmail(bool remember);
		void setUpperPaneHeight(int height);
		void setLowerPaneHeight(int height);
		void setResizingMode(int mode);

		Q_INVOKABLE void loginPressed(const QString &email, const QString &password);
		Q_INVOKABLE void goToLogin();
		Q_INVOKABLE void goToCreateNewAccount();
		Q_INVOKABLE void handleCreateNewAccount();
		Q_INVOKABLE void forgotEMailAddressOrPasswordPressed();
		Q_INVOKABLE void manageAccountPressed();
		Q_INVOKABLE void manageClientsPressed();
		Q_INVOKABLE void optionsPressed();
		Q_INVOKABLE void quitPressed();
		Q_INVOKABLE void tibiaLogoPressed();
		Q_INVOKABLE void cipSoftLogoPressed();
		Q_INVOKABLE void twitchLogoPressed();
		Q_INVOKABLE void youTubeLogoPressed();
		Q_INVOKABLE void muteAnthemPressed();
		Q_INVOKABLE void requestOpenCalendar();
		Q_INVOKABLE void linkClicked(const QString &link);
		Q_INVOKABLE void linkHoverChanged(bool hovered);
		Q_INVOKABLE void closeOpenMultiActionButtons();
		Q_INVOKABLE void leftAndRightStatusActionBarWidthChanged(int width);
		Q_INVOKABLE void createCharacterPressed();
		Q_INVOKABLE int getCharacterIndexForSearchString(const QString &text) const;
		Q_INVOKABLE void onCharacterSelectionConfirmed(const QVariantList &rows);
		Q_INVOKABLE void onCancelClicked();
		Q_INVOKABLE void onPinnedChanged(const QString &characterName, bool pinned);
		Q_INVOKABLE void onGetPremiumClicked();
		Q_INVOKABLE void onMorePremiumFeaturesClicked();
		Q_INVOKABLE void setShowHiddenCharacters(bool visible);
		Q_INVOKABLE void setShowOutfits(bool visible);
		Q_INVOKABLE void setSortOrder(int column, int order);
		Q_INVOKABLE void onMapWindowEntered();
		Q_INVOKABLE void onMapWindowExited();

	signals:
		void propertiesChanged();
		void showOutfitsChanged();
		void showHiddenCharactersChanged();

	private:
		void handleAuthenticationStateChanged(session::authentication::AuthenticationState state);
		void handleWorldStateChanged(application::world::WorldSessionState state);
		void showCharacterSelection();
		void closeCharacterSelection();
		void beginWorldSession(const session::selection::WorldConnectionTarget &target);
		void showStatus(const QString &title, const QString &message);

		QQmlApplicationEngine* m_engine;
		QQuickImageProvider* m_appearanceProvider;
		infrastructure::logging::Logger &m_logger;
		application::authentication::AuthenticationService m_authenticationService;
		std::unique_ptr<application::world::WorldSessionService> m_worldSession;
		session::selection::CharacterSelector m_characterSelector;
		QPointer<QQuickItem> m_gameWindowRoot;
		QPointer<QObject> m_characterSelectionDialog;
		QTimer m_initialMapTimer;
		QString m_loginServiceUrl;
		QString m_configPath;
		QString m_worldHostOverride;
		QString m_assetHashIdentifier;
		QString m_assetsDirectory;
		QString m_gameWindowState;
		QString m_hintAreaTitle;
		QString m_hintAreaRichText;
		QString m_initialLoginEmail;
		QVariantList m_characterList;
		int m_upperPaneHeight = 0;
		int m_lowerPaneHeight = 0;
		int m_resizingMode = 0;
		quint16 m_worldPortOverride = 0;
		bool m_isAuthenticated = false;
		bool m_rememberEmail = false;
		bool m_showEmailAsPlainText = false;
		bool m_showOutfits = false;
		bool m_showHiddenCharacters = false;
		bool m_invalidWorldEndpoint = false;
		bool m_initialMapAvailable = false;
	};

}
