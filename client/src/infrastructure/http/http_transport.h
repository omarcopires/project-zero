#pragma once

#include "infrastructure/http/http_failure.h"
#include "infrastructure/http/http_request_options.h"
#include "infrastructure/http/http_response.h"

#include <QByteArray>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QObject>
#include <QTimer>

namespace infrastructure::http {

	class HttpTransport final : public QObject {
		Q_OBJECT

	public:
		explicit HttpTransport(QObject* parent = nullptr);

		bool isActive() const;
		void postJson(const HttpRequestOptions &options, const QByteArray &body);
		void cancel();

	signals:
		void completed(infrastructure::http::HttpResponse response);
		void failureOccurred(infrastructure::http::HttpFailure failure);

	private:
		bool optionsAreValid(const HttpRequestOptions &options) const;
		void handleReadyRead(quint64 operationId);
		void handleFinished(quint64 operationId);
		void handleTimeout(quint64 operationId);
		void fail(HttpError error, QString description);
		void disposeReply();

		QNetworkAccessManager* m_manager;
		QNetworkReply* m_reply = nullptr;
		QTimer* m_deadlineTimer;
		QByteArray m_responseBuffer;
		std::size_t m_maximumResponseBytes = 0;
		quint64 m_operationId = 0;
		bool m_terminalEventEmitted = true;
	};

}
