#pragma once

#include <QHash>
#include <QString>
#include <QStringList>
#include <QTranslator>

namespace client::presentation::translations {

	class JsonCatalogTranslator final : public QTranslator {
	public:
		using QTranslator::QTranslator;

		bool loadCatalog(const QString& resourcePath);
		bool isEmpty() const override;
		QString translate(
			const char* context,
			const char* sourceText,
			const char* disambiguation = nullptr,
			int n = -1
		) const override;

	private:
		static QString makeLookupKey(const QString& context, const QString& source, const QString& comment);

		QHash<QString, QStringList> m_translations;
	};

}
