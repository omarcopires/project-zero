#include "session/authentication/login_codec.h"

#include "core/client_identity.h"

#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>

#include <cstdint>
#include <initializer_list>
#include <limits>
#include <utility>

namespace session::authentication {
	namespace {

		QString firstString(const QJsonObject &object, std::initializer_list<const char*> keys) {
			for (const auto* key : keys) {
				const auto value = object.value(QLatin1StringView(key));
				if (value.isString() && !value.toString().isEmpty()) {
					return value.toString();
				}
			}
			return {};
		}

		int firstPort(const QJsonObject &object) {
			for (const auto* key : { "externalportunprotected", "externalportprotected", "externalport" }) {
				const auto value = object.value(QLatin1StringView(key)).toInt();
				if (value > 0 && value <= std::numeric_limits<std::uint16_t>::max()) {
					return value;
				}
			}
			return 0;
		}

	}

	std::optional<QByteArray> encodeLoginRequest(const LoginRequest &request) {
		if (request.email.empty() || request.email.size() > 255 || request.password.empty()
		    || request.password.size() > 1024) {
			return std::nullopt;
		}

		QJsonObject object;
		object.insert(QStringLiteral("type"), QStringLiteral("login"));
		object.insert(QStringLiteral("email"), QString::fromStdString(request.email));
		object.insert(QStringLiteral("password"), QString::fromStdString(request.password));
		object.insert(QStringLiteral("twoFactorAction"), QStringLiteral("skip"));
		object.insert(QStringLiteral("stayloggedin"), true);
		object.insert(QStringLiteral("version"), client::identity::version);
		return QJsonDocument(object).toJson(QJsonDocument::Compact);
	}

	LoginResponse decodeLoginResponse(const QByteArray &responseBody) {
		QJsonParseError parseError;
		const auto document = QJsonDocument::fromJson(responseBody, &parseError);
		if (parseError.error != QJsonParseError::NoError || !document.isObject()) {
			return {};
		}

		const auto root = document.object();
		const auto errorCode = root.value(QStringLiteral("errorCode")).toInt();
		if (errorCode == 6 || errorCode == 7 || root.value(QStringLiteral("twoFactorSetup")).isObject()) {
			return { .status = LoginResponseStatus::UnsupportedChallenge };
		}
		if (!firstString(root, { "error", "errorMessage" }).isEmpty()) {
			return { .status = LoginResponseStatus::AuthenticationRejected };
		}

		const auto session = root.value(QStringLiteral("session")).toObject();
		const auto playdata = root.value(QStringLiteral("playdata")).toObject();
		const auto sessionKey = session.value(QStringLiteral("sessionkey")).toString();
		if (session.isEmpty() || playdata.isEmpty() || sessionKey.isEmpty()
		    || session.value(QStringLiteral("status")).toString() != QStringLiteral("active")) {
			return {};
		}

		LoginResponse response { .status = LoginResponseStatus::Success, .sessionKey = sessionKey.toStdString() };
		const auto worlds = playdata.value(QStringLiteral("worlds")).toArray();
		for (const auto &value : worlds) {
			const auto object = value.toObject();
			LoginWorld world {
				.id = object.value(QStringLiteral("id")).toInt(-1),
				.name = object.value(QStringLiteral("name")).toString().toStdString(),
				.host = firstString(object, { "externaladdressunprotected", "externaladdressprotected", "externaladdress" }).toStdString(),
				.port = static_cast<std::uint16_t>(firstPort(object)),
			};
			if (world.id < 0 || world.name.empty() || world.host.empty() || world.port == 0) {
				return {};
			}
			response.worlds.push_back(std::move(world));
		}

		const auto characters = playdata.value(QStringLiteral("characters")).toArray();
		for (const auto &value : characters) {
			const auto object = value.toObject();
			LoginCharacter character {
				.name = object.value(QStringLiteral("name")).toString().toStdString(),
				.worldId = object.value(QStringLiteral("worldid")).toInt(-1),
			};
			if (character.name.empty() || character.worldId < 0) {
				return {};
			}
			response.characters.push_back(std::move(character));
		}

		if (response.worlds.empty() || response.characters.empty()) {
			return {};
		}
		return response;
	}

}
