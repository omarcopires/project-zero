#include "presentation/translations/json_catalog_translator.h"

#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QString>
#include <QJsonValue>

#include <utility>

namespace client::presentation::translations {

	bool JsonCatalogTranslator::loadCatalog(const QString& resourcePath) {
		QFile catalogFile(resourcePath);
		if (!catalogFile.open(QIODevice::ReadOnly)) {
			return false;
		}

		QJsonParseError parseError {};
		const QJsonDocument catalog = QJsonDocument::fromJson(catalogFile.readAll(), &parseError);
		if (parseError.error != QJsonParseError::NoError || !catalog.isObject()) {
			return false;
		}

		const QJsonObject catalogObject = catalog.object();
		const QJsonValue messageListValue = catalogObject.value(QStringLiteral("messages"));
		if (
			catalogObject.value(QStringLiteral("format")).toString() != QStringLiteral("qt-qm-catalog-extraction-v1")
			|| !messageListValue.isArray()
		) {
			return false;
		}

		const QJsonArray messageList = messageListValue.toArray();
		if (messageList.isEmpty() || catalogObject.value(QStringLiteral("messageCount")).toInt(-1) != messageList.size()) {
			return false;
		}

		QHash<QString, QStringList> translations;
		for (const QJsonValue& messageValue : messageList) {
			if (!messageValue.isObject()) {
				return false;
			}

			const QJsonObject message = messageValue.toObject();
			const QJsonValue contextValue = message.value(QStringLiteral("context"));
			const QJsonValue sourceValue = message.value(QStringLiteral("source"));
			const QJsonValue commentValue = message.value(QStringLiteral("comment"));
			const QJsonValue formsValue = message.value(QStringLiteral("translations"));
			if (
				!contextValue.isString()
				|| !sourceValue.isString()
				|| sourceValue.toString().isEmpty()
				|| !commentValue.isString()
				|| !formsValue.isArray()
				|| formsValue.toArray().isEmpty()
			) {
				return false;
			}

			QStringList forms;
			for (const QJsonValue& form : formsValue.toArray()) {
				if (!form.isString()) {
					return false;
				}
				forms.append(form.toString());
			}

			const QString lookupKey = makeLookupKey(
				contextValue.toString(),
				sourceValue.toString(),
				commentValue.toString()
			);
			if (translations.contains(lookupKey)) {
				return false;
			}
			translations.insert(lookupKey, forms);
		}
		if (translations.isEmpty()) {
			return false;
		}

		m_translations = std::move(translations);
		return true;
	}

	QString JsonCatalogTranslator::makeLookupKey(
		const QString& context,
		const QString& source,
		const QString& comment
	) {
		return QString::number(context.size()) + QLatin1Char(':') + context
			+ QString::number(source.size()) + QLatin1Char(':') + source
			+ QString::number(comment.size()) + QLatin1Char(':') + comment;
	}

	bool JsonCatalogTranslator::isEmpty() const {
		return m_translations.isEmpty();
	}

	QString JsonCatalogTranslator::translate(
		const char* context,
		const char* sourceText,
		const char* disambiguation,
		const int n
	) const {
		if (sourceText == nullptr) {
			return {};
		}

		QString lookupContext = context == nullptr ? QString() : QString::fromUtf8(context);
		if (lookupContext == QStringLiteral("qtTrId")) {
			lookupContext.clear();
		}
		const QString source = QString::fromUtf8(sourceText);
		const QString comment = disambiguation == nullptr ? QString() : QString::fromUtf8(disambiguation);
		const QStringList forms = m_translations.value(makeLookupKey(lookupContext, source, comment));
		if (forms.isEmpty()) {
			return {};
		}
		if (n == -1 || forms.size() == 1) {
			return forms.front();
		}
		return n == 1 ? forms.front() : forms.back();
	}

}
