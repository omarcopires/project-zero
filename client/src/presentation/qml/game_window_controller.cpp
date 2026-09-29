#include "presentation/qml/game_window_controller.h"

#include "assets/appearance_catalog_loader.h"
#include "application/world/world_session_request.h"
#include "infrastructure/http/http_request_options.h"
#include "presentation/rendering/world_map_item.h"
#include "session/authentication/login_request.h"
#include "session/selection/character_selection_status.h"

#include <QCoreApplication>
#include <QFileInfo>
#include <QImage>
#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <QQuickImageProvider>
#include <QQuickItem>
#include <QRandomGenerator>
#include <QSettings>
#include <QUrl>
#include <QVariantMap>

#include <algorithm>
#include <limits>
#include <utility>

namespace client::presentation::qml {
	namespace {

		QString configFilePath() {
			const QString configuredPath = QString::fromLocal8Bit(qgetenv("CLIENT_CONFIG_FILE"));
			if (!configuredPath.isEmpty()) {
				return QFileInfo(configuredPath).absoluteFilePath();
			}
			return QCoreApplication::applicationDirPath() + QStringLiteral("/client.ini");
		}

		QString worldErrorText(const application::world::WorldSessionError error) {
			switch (error) {
				case application::world::WorldSessionError::InvalidRequest:
					return QStringLiteral("The world login settings are incomplete.");
				case application::world::WorldSessionError::Transport:
					return QStringLiteral("The game world could not be reached.");
				case application::world::WorldSessionError::InvalidFrame:
				case application::world::WorldSessionError::InvalidChallenge:
				case application::world::WorldSessionError::InvalidSessionPacket:
					return QStringLiteral("The game world returned an invalid response.");
				case application::world::WorldSessionError::InvalidMapDescription:
					return QStringLiteral("The game world sent map data this client cannot display yet.");
				case application::world::WorldSessionError::LoginEncodingFailed:
					return QStringLiteral("The game world login could not be encoded.");
				case application::world::WorldSessionError::LoginSendFailed:
					return QStringLiteral("The game world login could not be sent.");
				case application::world::WorldSessionError::ServerRejected:
					return QStringLiteral("The game world rejected this character login.");
				case application::world::WorldSessionError::UpdateRequired:
					return QStringLiteral("The game client must be updated before entering this world.");
			}
			return QStringLiteral("The game world session ended unexpectedly.");
		}

	}

	GameWindowController::GameWindowController(
		QQmlApplicationEngine* engine,
		QQuickImageProvider* appearanceProvider,
		infrastructure::logging::Logger &logger,
		QObject* parent
	) : QObject(parent),
		m_engine(engine),
		m_appearanceProvider(appearanceProvider),
		m_logger(logger),
		m_authenticationService(this) {
		m_configPath = configFilePath();
		QSettings settings(m_configPath, QSettings::IniFormat);
		m_loginServiceUrl = settings.value(
										QStringLiteral("network/login_service_url"),
										QStringLiteral("http://127.0.0.1:8080/api/v1/webservice")
		)
								.toString();
		m_worldHostOverride = settings.value(QStringLiteral("network/world_host")).toString().trimmed();
		const auto worldPortValue = settings.value(QStringLiteral("network/world_port"));
		bool worldPortIsNumeric = false;
		const uint configuredWorldPort = worldPortValue.toUInt(&worldPortIsNumeric);
		const bool hasWorldPort = worldPortValue.isValid() && !worldPortValue.toString().isEmpty();
		m_invalidWorldEndpoint = m_worldHostOverride.isEmpty() != !hasWorldPort
			|| (hasWorldPort && (!worldPortIsNumeric || configuredWorldPort == 0 || configuredWorldPort > std::numeric_limits<quint16>::max()));
		if (hasWorldPort && worldPortIsNumeric
		    && configuredWorldPort <= std::numeric_limits<quint16>::max()) {
			m_worldPortOverride = static_cast<quint16>(configuredWorldPort);
		}
		m_assetHashIdentifier = settings.value(QStringLiteral("network/asset_hash_identifier")).toString();
		m_rememberEmail = settings.value(QStringLiteral("account/remember_email"), false).toBool();
		if (m_rememberEmail) {
			m_initialLoginEmail = settings.value(QStringLiteral("account/email")).toString();
		}
		m_assetsDirectory = QString::fromLocal8Bit(qgetenv("CLIENT_ASSETS_DIRECTORY"));
		if (m_assetsDirectory.isEmpty()) {
			m_assetsDirectory = settings.value(QStringLiteral("assets/directory")).toString();
		}
		if (m_assetsDirectory.isEmpty()) {
			m_assetsDirectory = QCoreApplication::applicationDirPath() + QStringLiteral("/things/assets");
		} else {
			const QFileInfo assetsInfo(m_assetsDirectory);
			if (!assetsInfo.isAbsolute()) {
				m_assetsDirectory = QCoreApplication::applicationDirPath() + QStringLiteral("/") + m_assetsDirectory;
			}
		}
		m_hintAreaTitle = QStringLiteral("Client status");
		m_hintAreaRichText = QStringLiteral("Enter your account details to continue.");
		connect(
			&m_authenticationService,
			&application::authentication::AuthenticationService::stateChanged,
			this,
			&GameWindowController::handleAuthenticationStateChanged
		);
		m_initialMapTimer.setSingleShot(true);
		m_initialMapTimer.setInterval(10000);
		connect(&m_initialMapTimer, &QTimer::timeout, this, [this] {
			if (!m_initialMapAvailable && m_worldSession != nullptr
			    && m_worldSession->state() == application::world::WorldSessionState::Active) {
				m_worldSession->close();
				m_gameWindowState.clear();
				emit propertiesChanged();
				showStatus(QStringLiteral("Initial map unavailable"), QStringLiteral("The world session became active but did not provide a renderable initial map."));
				showCharacterSelection();
			}
		});
	}

	QString GameWindowController::gameWindowState() const {
		return m_gameWindowState;
	}
	bool GameWindowController::isAuthenticated() const {
		return m_isAuthenticated;
	}
	bool GameWindowController::showCreateAccountOption() const {
		return false;
	}
	bool GameWindowController::createAccountEnabled() const {
		return false;
	}
	bool GameWindowController::rememberEmail() const {
		return m_rememberEmail;
	}
	QString GameWindowController::initialLoginEmail() const {
		return m_initialLoginEmail;
	}
	bool GameWindowController::showEmailAsPlainText() const {
		return m_showEmailAsPlainText;
	}
	bool GameWindowController::isCapsLockActive() const {
		return false;
	}
	QString GameWindowController::hintAreaTitle() const {
		return m_hintAreaTitle;
	}
	QString GameWindowController::hintAreaRichText() const {
		return m_hintAreaRichText;
	}
	int GameWindowController::upperPaneHeight() const {
		return m_upperPaneHeight;
	}
	int GameWindowController::lowerPaneHeight() const {
		return m_lowerPaneHeight;
	}
	int GameWindowController::resizingMode() const {
		return m_resizingMode;
	}
	QObject* GameWindowController::statusBarController() const {
		return nullptr;
	}
	bool GameWindowController::statusBarVisible() const {
		return false;
	}
	bool GameWindowController::anthemMuted() const {
		return true;
	}
	bool GameWindowController::musicMuted() const {
		return true;
	}
	bool GameWindowController::newEventToday() const {
		return false;
	}
	int GameWindowController::onlinePlayerCount() const {
		return 0;
	}
	int GameWindowController::twitchStreamCount() const {
		return 0;
	}
	int GameWindowController::twitchViewerCount() const {
		return 0;
	}
	int GameWindowController::youTubeStreamCount() const {
		return 0;
	}
	int GameWindowController::youTubeViewerCount() const {
		return 0;
	}
	QString GameWindowController::dragonLogoSource() const {
		return {};
	}
	QString GameWindowController::boostedBossName() const {
		return {};
	}
	QString GameWindowController::boostedCreatureName() const {
		return {};
	}
	int GameWindowController::boostedBossRace() const {
		return 0;
	}
	int GameWindowController::boostedCreatureRace() const {
		return 0;
	}
	QVariant GameWindowController::eventsScheduleCurrent() const {
		return {};
	}
	QVariant GameWindowController::eventsScheduleUpcoming() const {
		return {};
	}
	QString GameWindowController::eventsScheduleCurrentTooltip() const {
		return {};
	}
	QString GameWindowController::eventsScheduleCurrentSeasonalTooltip() const {
		return {};
	}
	QString GameWindowController::eventsScheduleUpcomingTooltip() const {
		return {};
	}
	QString GameWindowController::eventsScheduleUpcomingSeasonalTooltip() const {
		return {};
	}
	QVariantList GameWindowController::characterList() const {
		return m_characterList;
	}
	QString GameWindowController::accountPremiumStatus() const {
		return {};
	}
	bool GameWindowController::showOutfits() const {
		return m_showOutfits;
	}
	bool GameWindowController::recoverySetupComplete() const {
		return true;
	}
	bool GameWindowController::isPremium() const {
		return false;
	}
	bool GameWindowController::showGetPremiumButton() const {
		return false;
	}
	QVariantList GameWindowController::premiumFeaturesModel() const {
		return {};
	}
	bool GameWindowController::showHiddenCharacters() const {
		return m_showHiddenCharacters;
	}
	int GameWindowController::lastSelectedIndex() const {
		return 0;
	}
	int GameWindowController::sortColumn() const {
		return 1;
	}
	int GameWindowController::sortOrder() const {
		return 0;
	}
	bool GameWindowController::clientSettingSmoothFiltering() const {
		return false;
	}
	QObject* GameWindowController::mapWindowController() {
		return this;
	}
	bool GameWindowController::mapWindowScaleOnlyByEvenMultiples() const {
		return false;
	}
	bool GameWindowController::useLightMap() const {
		return false;
	}
	int GameWindowController::antialiasingMode() const {
		return 0;
	}
	bool GameWindowController::showNumericalEffects() const {
		return false;
	}

	void GameWindowController::setGameWindowRoot(QQuickItem* root) {
		m_gameWindowRoot = root;
		if (root == nullptr) {
			return;
		}
		if (auto* mapPane = root->findChild<QObject*>(QStringLiteral("mapWindowPane")); mapPane != nullptr) {
			mapPane->setProperty("mapWindowController", QVariant::fromValue(static_cast<QObject*>(this)));
		}
	}

	void GameWindowController::setShowEmailAsPlainText(const bool visible) {
		if (m_showEmailAsPlainText == visible) {
			return;
		}
		m_showEmailAsPlainText = visible;
		emit propertiesChanged();
	}

	void GameWindowController::setRememberEmail(const bool remember) {
		if (m_rememberEmail == remember) {
			return;
		}
		m_rememberEmail = remember;
		QSettings settings(m_configPath, QSettings::IniFormat);
		settings.setValue(QStringLiteral("account/remember_email"), remember);
		if (!remember) {
			settings.remove(QStringLiteral("account/email"));
			m_initialLoginEmail.clear();
		}
		emit propertiesChanged();
	}

	void GameWindowController::setUpperPaneHeight(const int height) {
		if (m_upperPaneHeight != height) {
			m_upperPaneHeight = height;
			emit propertiesChanged();
		}
	}

	void GameWindowController::setLowerPaneHeight(const int height) {
		if (m_lowerPaneHeight != height) {
			m_lowerPaneHeight = height;
			emit propertiesChanged();
		}
	}

	void GameWindowController::setResizingMode(const int mode) {
		if (m_resizingMode != mode) {
			m_resizingMode = mode;
			emit propertiesChanged();
		}
	}

	void GameWindowController::loginPressed(const QString &email, const QString &password) {
		if (m_authenticationService.state() == session::authentication::AuthenticationState::Authenticating) {
			showStatus(QStringLiteral("Login in progress"), QStringLiteral("Wait for the current login request to finish."));
			return;
		}
		if (email.trimmed().isEmpty() || password.isEmpty()) {
			showStatus(QStringLiteral("Login not started"), QStringLiteral("Enter both your email address and password."));
			return;
		}
		if (m_rememberEmail) {
			m_initialLoginEmail = email.trimmed();
			QSettings settings(m_configPath, QSettings::IniFormat);
			settings.setValue(QStringLiteral("account/email"), m_initialLoginEmail);
			settings.setValue(QStringLiteral("account/remember_email"), true);
		} else {
			QSettings settings(m_configPath, QSettings::IniFormat);
			settings.remove(QStringLiteral("account/email"));
		}
		infrastructure::http::HttpRequestOptions options;
		options.endpoint = QUrl(m_loginServiceUrl);
		session::authentication::LoginRequest request {
			.email = email.trimmed().toStdString(),
			.password = password.toStdString(),
		};
		showStatus(QStringLiteral("Connecting"), QStringLiteral("Contacting the configured login service."));
		if (!m_authenticationService.authenticate(options, request)) {
			showStatus(QStringLiteral("Login not started"), QStringLiteral("The login request could not be started. Check the local client configuration."));
		}
	}

	void GameWindowController::handleAuthenticationStateChanged(const session::authentication::AuthenticationState state) {
		using session::authentication::AuthenticationState;
		switch (state) {
			case AuthenticationState::Authenticated: {
				const auto* session = m_authenticationService.authenticatedSession();
				if (session == nullptr || !m_characterSelector.updateSession(*session)) {
					showStatus(QStringLiteral("Login failed"), QStringLiteral("The login service response did not contain a usable character list."));
					return;
				}
				m_isAuthenticated = true;
				m_characterList.clear();
				for (const auto &character : session->characters) {
					const auto world = std::ranges::find_if(session->worlds, [&](const auto &candidate) {
						return candidate.id == character.worldId;
					});
					QVariantMap outfit {
						{ QStringLiteral("id"), 0 },
						{ QStringLiteral("headColor"), QStringLiteral("black") },
						{ QStringLiteral("torsoColor"), QStringLiteral("black") },
						{ QStringLiteral("legsColor"), QStringLiteral("black") },
						{ QStringLiteral("detailColor"), QStringLiteral("black") },
						{ QStringLiteral("firstAddOn"), false },
						{ QStringLiteral("secondAddOn"), false },
					};
					m_characterList.push_back(QVariantMap {
						{ QStringLiteral("characterName"), QString::fromStdString(character.name) },
						{ QStringLiteral("world"), world == session->worlds.end() ? QString() : QString::fromStdString(world->name) },
						{ QStringLiteral("worldRules"), QString() },
						{ QStringLiteral("outfit"), outfit },
						{ QStringLiteral("isPinned"), false },
						{ QStringLiteral("isMainCharacter"), false },
						{ QStringLiteral("dailyRewardState"), 2 },
						{ QStringLiteral("level"), 0 },
						{ QStringLiteral("vocation"), QString() },
						{ QStringLiteral("isHidden"), false },
					});
				}
				emit propertiesChanged();
				showStatus(QStringLiteral("Choose a character"), QStringLiteral("Select a character to connect to its game world."));
				showCharacterSelection();
				return;
			}
			case AuthenticationState::Rejected:
				showStatus(QStringLiteral("Login failed"), QStringLiteral("The login service rejected the credentials."));
				return;
			case AuthenticationState::UnsupportedChallenge:
				showStatus(QStringLiteral("Additional verification required"), QStringLiteral("This login requires a verification step that the current client does not support."));
				return;
			case AuthenticationState::Failed:
				showStatus(QStringLiteral("Login failed"), QStringLiteral("The login service could not be reached or returned an unsupported response."));
				return;
			case AuthenticationState::Cancelled:
				showStatus(QStringLiteral("Login cancelled"), QStringLiteral("The login request was cancelled."));
				return;
			case AuthenticationState::Idle:
			case AuthenticationState::Authenticating:
				return;
		}
	}

	void GameWindowController::showCharacterSelection() {
		if (m_engine == nullptr || m_characterSelectionDialog != nullptr) {
			return;
		}
		QQmlComponent component(
			m_engine,
			QUrl(QStringLiteral("qrc:/qt/qml/qmlcomponents/qml/CharacterSelection.qml"))
		);
		if (!component.isReady()) {
			for (const auto &error : component.errors()) {
				m_logger.error("qml", "CharacterSelection component: {}", error.toString().toStdString());
			}
			m_logger.error("qml", "CharacterSelection component is not ready (status {}).", static_cast<int>(component.status()));
			m_isAuthenticated = false;
			m_characterSelector.clearSession();
			m_characterList.clear();
			emit propertiesChanged();
			showStatus(QStringLiteral("Character selection unavailable"), QStringLiteral("The original character selection screen could not be loaded."));
			return;
		}
		const QVariantMap initialProperties {
			{ QStringLiteral("controller"), QVariant::fromValue(static_cast<QObject*>(this)) },
		};
		QObject* dialog = component.createWithInitialProperties(initialProperties, m_engine->rootContext());
		auto* dialogItem = qobject_cast<QQuickItem*>(dialog);
		if (dialogItem == nullptr || m_gameWindowRoot == nullptr) {
			for (const auto &error : component.errors()) {
				m_logger.error("qml", "CharacterSelection creation: {}", error.toString().toStdString());
			}
			if (dialog == nullptr) {
				m_logger.error("qml", "CharacterSelection creation returned null.");
			}
			if (m_gameWindowRoot == nullptr) {
				m_logger.error("qml", "CharacterSelection has no game window parent.");
			}
			m_isAuthenticated = false;
			m_characterSelector.clearSession();
			m_characterList.clear();
			emit propertiesChanged();
			showStatus(QStringLiteral("Character selection unavailable"), QStringLiteral("The original character selection screen could not be created."));
			delete dialog;
			return;
		}
		dialog->setParent(this);
		dialogItem->setParentItem(m_gameWindowRoot);
		dialogItem->setZ(10000);
		dialogItem->setProperty("personalMouseShield", true);
		dialogItem->setProperty("centerAtElement", QVariant::fromValue(static_cast<QObject*>(m_gameWindowRoot.data())));
		m_characterSelectionDialog = dialog;
		connect(dialog, &QObject::destroyed, this, [this] { m_characterSelectionDialog = nullptr; });
		const bool centered = QMetaObject::invokeMethod(
			dialog,
			"centerDialog",
			Q_ARG(QVariant, QVariant(true))
		);
		if (!centered) {
			dialogItem->setX(std::max(0.0, (m_gameWindowRoot->width() - dialogItem->width()) / 2.0));
			dialogItem->setY(std::max(0.0, (m_gameWindowRoot->height() - dialogItem->height()) / 2.0));
		}
		dialogItem->setVisible(true);
	}

	void GameWindowController::closeCharacterSelection() {
		if (m_characterSelectionDialog == nullptr) {
			return;
		}
		QObject* dialog = m_characterSelectionDialog;
		m_characterSelectionDialog = nullptr;
		if (auto* dialogItem = qobject_cast<QQuickItem*>(dialog); dialogItem != nullptr) {
			dialogItem->setVisible(false);
		}
		dialog->deleteLater();
	}

	void GameWindowController::onCharacterSelectionConfirmed(const QVariantList &rows) {
		if (rows.size() != 1 || !rows.front().canConvert<int>()) {
			showStatus(QStringLiteral("Choose one character"), QStringLiteral("Select exactly one character to continue."));
			return;
		}
		const int row = rows.front().toInt();
		if (row < 0 || row >= m_characterList.size()) {
			showStatus(QStringLiteral("Character unavailable"), QStringLiteral("The selected character is no longer available."));
			return;
		}
		const QString characterName = m_characterList.at(row).toMap().value(QStringLiteral("characterName")).toString();
		const auto selection = m_characterSelector.select(characterName.toStdString());
		if (selection.status != session::selection::CharacterSelectionStatus::Success || !selection.target.has_value()) {
			showStatus(QStringLiteral("Character unavailable"), QStringLiteral("The selected character does not have a valid world endpoint."));
			return;
		}
		beginWorldSession(*selection.target);
	}

	void GameWindowController::beginWorldSession(const session::selection::WorldConnectionTarget &target) {
		if (m_invalidWorldEndpoint) {
			showStatus(QStringLiteral("World login is not configured"), QStringLiteral("Set both network/world_host and network/world_port in client.ini, or leave both unset to use the address returned by the login service."));
			return;
		}
		auto loadedCatalog = assets::loadAppearanceCatalog(m_assetsDirectory);
		if (!loadedCatalog.catalog.has_value()) {
			showStatus(QStringLiteral("World map assets unavailable"), QStringLiteral("Set CLIENT_ASSETS_DIRECTORY or assets/directory in client.ini to the compatible assets directory."));
			return;
		}
		if (m_worldSession == nullptr) {
			auto catalog = std::make_shared<const assets::AppearanceCatalog>(std::move(*loadedCatalog.catalog));
			m_worldSession = std::make_unique<application::world::WorldSessionService>(std::move(catalog), this);
			connect(m_worldSession.get(), &application::world::WorldSessionService::stateChanged, this, &GameWindowController::handleWorldStateChanged);
			connect(m_worldSession.get(), &application::world::WorldSessionService::initialMapDescriptionReceived, this, [this](const protocol::game::MapDescription &description) {
				if (m_gameWindowRoot == nullptr) {
					return;
				}
				auto* mapItem = m_gameWindowRoot->findChild<presentation::rendering::WorldMapItem*>(QStringLiteral("worldmap"));
				if (mapItem == nullptr) {
					showStatus(QStringLiteral("World map unavailable"), QStringLiteral("The original map item could not be found."));
					return;
				}
				mapItem->setAppearanceImageLookup([provider = m_appearanceProvider](const assets::AppearanceKind kind, const std::uint32_t id) {
					if (provider == nullptr) {
						return QImage {};
					}
					const auto kindName = kind == assets::AppearanceKind::Object
						? QStringLiteral("object")
						: QStringLiteral("outfit");
					return provider->requestImage(
						QStringLiteral("%1/%2").arg(kindName).arg(static_cast<qulonglong>(id)), nullptr, {}
					);
				});
				mapItem->setMapDescription(description);
				m_initialMapAvailable = true;
				m_initialMapTimer.stop();
				if (m_worldSession != nullptr
				    && m_worldSession->state() == application::world::WorldSessionState::Active) {
					m_gameWindowState = QStringLiteral("INGAME");
					emit propertiesChanged();
					showStatus(QStringLiteral("Connected"), QStringLiteral("The character entered the game world."));
				}
			});
			connect(m_worldSession.get(), &application::world::WorldSessionService::failureOccurred, this, [this](const application::world::WorldSessionFailure &failure) {
				if (failure.error == application::world::WorldSessionError::InvalidFrame
				    || failure.error == application::world::WorldSessionError::InvalidChallenge
				    || failure.error == application::world::WorldSessionError::InvalidSessionPacket
				    || failure.error == application::world::WorldSessionError::InvalidMapDescription) {
					m_logger.error("world-session", "{}", failure.description.toStdString());
				}
				m_initialMapTimer.stop();
				m_gameWindowState.clear();
				emit propertiesChanged();
				showStatus(QStringLiteral("World connection failed"), worldErrorText(failure.error));
				showCharacterSelection();
			});
			connect(m_worldSession.get(), &application::world::WorldSessionService::loginWaitReceived, this, [this](const QString &message, std::uint8_t retrySeconds) {
				m_initialMapTimer.stop();
				m_gameWindowState.clear();
				QMetaObject::invokeMethod(m_worldSession.get(), [this, message, retrySeconds] {
					if (m_worldSession != nullptr) {
						m_worldSession->close();
					}
					showStatus(QStringLiteral("World is busy"), QStringLiteral("%1 Select the character again after %2 seconds to retry.")
						.arg(message.toHtmlEscaped()).arg(static_cast<int>(retrySeconds)));
					showCharacterSelection(); }, Qt::QueuedConnection);
			});
			connect(m_worldSession.get(), &application::world::WorldSessionService::sessionEnded, this, [this](std::uint8_t) {
				m_initialMapTimer.stop();
				m_gameWindowState.clear();
				emit propertiesChanged();
				showStatus(QStringLiteral("World session ended"), QStringLiteral("The character was disconnected from the game world."));
				showCharacterSelection();
			});
		}

		application::world::WorldSessionRequest request;
		request.connection.host = m_worldHostOverride.isEmpty()
			? QString::fromStdString(target.host)
			: m_worldHostOverride;
		request.connection.port = m_worldPortOverride == 0 ? target.port : m_worldPortOverride;
		request.sessionKey = target.sessionKey;
		request.characterName = target.characterName;
		request.assetHashIdentifier = m_assetHashIdentifier.toStdString();
		auto* random = QRandomGenerator::system();
		for (auto &word : request.xteaKey) {
			word = random->generate();
		}
		m_initialMapAvailable = false;
		if (!m_worldSession->start(request)) {
			showStatus(QStringLiteral("World connection failed"), QStringLiteral("The world session request could not be started."));
			return;
		}
		closeCharacterSelection();
		showStatus(QStringLiteral("Connecting to world"), QStringLiteral("The selected character is connecting to its game world."));
	}

	void GameWindowController::handleWorldStateChanged(const application::world::WorldSessionState state) {
		if (state == application::world::WorldSessionState::Active) {
			if (m_initialMapAvailable) {
				m_gameWindowState = QStringLiteral("INGAME");
				emit propertiesChanged();
				showStatus(QStringLiteral("Connected"), QStringLiteral("The character entered the game world."));
			} else {
				showStatus(QStringLiteral("Loading initial map"), QStringLiteral("Waiting for the initial map description before showing the game screen."));
				m_initialMapTimer.start();
			}
		} else if (state == application::world::WorldSessionState::Waiting) {
			closeCharacterSelection();
			showStatus(QStringLiteral("Waiting for world"), QStringLiteral("The game world placed this character in a queue."));
		}
	}

	void GameWindowController::onCancelClicked() {
		closeCharacterSelection();
		if (m_worldSession != nullptr) {
			m_initialMapTimer.stop();
			m_worldSession->close();
			m_worldSession.reset();
		}
		m_characterSelector.clearSession();
		m_characterList.clear();
		m_isAuthenticated = false;
		m_gameWindowState.clear();
		emit propertiesChanged();
		showStatus(QStringLiteral("Login cancelled"), QStringLiteral("Character selection was cancelled."));
	}

	void GameWindowController::showStatus(const QString &title, const QString &message) {
		m_hintAreaTitle = title;
		m_hintAreaRichText = message.toHtmlEscaped();
		emit propertiesChanged();
	}

	void GameWindowController::goToLogin() {
		showStatus(QStringLiteral("Login"), QStringLiteral("Enter your account details to continue."));
	}
	void GameWindowController::goToCreateNewAccount() {
		showStatus(QStringLiteral("Unavailable"), QStringLiteral("Account creation is not part of this client increment."));
	}
	void GameWindowController::handleCreateNewAccount() {
		goToCreateNewAccount();
	}
	void GameWindowController::forgotEMailAddressOrPasswordPressed() {
		showStatus(QStringLiteral("Unavailable"), QStringLiteral("Account recovery is not part of this client increment."));
	}
	void GameWindowController::manageAccountPressed() {
		showStatus(QStringLiteral("Unavailable"), QStringLiteral("Account management is not part of this client increment."));
	}
	void GameWindowController::manageClientsPressed() {
		showStatus(QStringLiteral("Unavailable"), QStringLiteral("Client management is not part of this client increment."));
	}
	void GameWindowController::optionsPressed() {
		showStatus(QStringLiteral("Unavailable"), QStringLiteral("Options are not connected in this client increment."));
	}
	void GameWindowController::quitPressed() {
		QCoreApplication::quit();
	}
	void GameWindowController::tibiaLogoPressed() {
		showStatus(QStringLiteral("Unavailable"), QStringLiteral("This link is not configured."));
	}
	void GameWindowController::cipSoftLogoPressed() {
		showStatus(QStringLiteral("Unavailable"), QStringLiteral("This link is not configured."));
	}
	void GameWindowController::twitchLogoPressed() {
		showStatus(QStringLiteral("Unavailable"), QStringLiteral("Streaming links are not configured."));
	}
	void GameWindowController::youTubeLogoPressed() {
		showStatus(QStringLiteral("Unavailable"), QStringLiteral("Streaming links are not configured."));
	}
	void GameWindowController::muteAnthemPressed() {
		showStatus(QStringLiteral("Unavailable"), QStringLiteral("Audio playback is not available."));
	}
	void GameWindowController::requestOpenCalendar() {
		showStatus(QStringLiteral("Unavailable"), QStringLiteral("The event calendar is not connected."));
	}
	void GameWindowController::linkClicked(const QString &) {
		showStatus(QStringLiteral("Unavailable"), QStringLiteral("External links are disabled in this client increment."));
	}
	void GameWindowController::linkHoverChanged(const bool) { }
	void GameWindowController::closeOpenMultiActionButtons() { }
	void GameWindowController::leftAndRightStatusActionBarWidthChanged(const int) { }
	void GameWindowController::createCharacterPressed() {
		showStatus(QStringLiteral("Unavailable"), QStringLiteral("Character creation is not part of this client increment."));
	}
	void GameWindowController::onPinnedChanged(const QString &, const bool) {
		showStatus(QStringLiteral("Pinning unavailable"), QStringLiteral("Character pin preferences are not persisted by this client."));
	}
	void GameWindowController::onGetPremiumClicked() {
		showStatus(QStringLiteral("Unavailable"), QStringLiteral("Store access is not connected."));
	}
	void GameWindowController::onMorePremiumFeaturesClicked() {
		showStatus(QStringLiteral("Unavailable"), QStringLiteral("Store access is not connected."));
	}
	void GameWindowController::setShowHiddenCharacters(const bool visible) {
		if (m_showHiddenCharacters == visible) {
			return;
		}
		m_showHiddenCharacters = visible;
		emit showHiddenCharactersChanged();
	}
	void GameWindowController::setShowOutfits(const bool visible) {
		if (m_showOutfits == visible) {
			return;
		}
		m_showOutfits = visible;
		emit showOutfitsChanged();
		if (visible) {
			showStatus(QStringLiteral("Outfit preview unavailable"), QStringLiteral("The login response does not include outfit data."));
		}
	}
	void GameWindowController::setSortOrder(const int column, const int order) {
		if (column != 1 || m_characterList.size() < 2) {
			return;
		}
		std::stable_sort(m_characterList.begin(), m_characterList.end(), [order](const QVariant &left, const QVariant &right) {
			const auto leftName = left.toMap().value(QStringLiteral("characterName")).toString();
			const auto rightName = right.toMap().value(QStringLiteral("characterName")).toString();
			return order == 1 ? leftName > rightName : leftName < rightName;
		});
		emit propertiesChanged();
	}
	void GameWindowController::onMapWindowEntered() { }
	void GameWindowController::onMapWindowExited() { }
	int GameWindowController::getCharacterIndexForSearchString(const QString &text) const {
		for (qsizetype index = 0; index < m_characterList.size(); ++index) {
			if (m_characterList.at(index).toMap().value(QStringLiteral("characterName")).toString().startsWith(text, Qt::CaseInsensitive)) {
				return static_cast<int>(index);
			}
		}
		return -1;
	}

}
