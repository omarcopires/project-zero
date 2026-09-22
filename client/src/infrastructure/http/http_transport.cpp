#include "infrastructure/http/http_transport.h"

#include <QHostAddress>
#include <QNetworkRequest>
#include <QVariant>

#include <limits>
#include <utility>

namespace infrastructure::http {

	HttpTransport::HttpTransport(QObject* parent) : QObject(parent), m_manager(new QNetworkAccessManager(this)), m_deadlineTimer(new QTimer(this)) {
		qRegisterMetaType<HttpError>();
		qRegisterMetaType<HttpFailure>();
		qRegisterMetaType<HttpResponse>();
		m_deadlineTimer->setSingleShot(true);
	}

	bool HttpTransport::isActive() const {
		return m_reply != nullptr && !m_terminalEventEmitted;
	}

	void HttpTransport::postJson(const HttpRequestOptions &options, const QByteArray &body) {
		if (isActive()) {
			emit failureOccurred({ .error = HttpError::OperationInProgress, .description = QStringLiteral("An HTTP operation is already active") });
			return;
		}

		if (!optionsAreValid(options)) {
			emit failureOccurred({ .error = HttpError::InvalidConfiguration, .description = QStringLiteral("HTTP request options are invalid") });
			return;
		}

		disposeReply();
		++m_operationId;
		m_terminalEventEmitted = false;
		m_responseBuffer.clear();
		m_maximumResponseBytes = options.maximumResponseBytes;

		QNetworkRequest request(options.endpoint);
		request.setHeader(QNetworkRequest::ContentTypeHeader, QStringLiteral("application/json"));
		request.setAttribute(QNetworkRequest::RedirectPolicyAttribute, QNetworkRequest::ManualRedirectPolicy);
		m_reply = m_manager->post(request, body);
		const auto operationId = m_operationId;
		connect(m_reply, &QNetworkReply::readyRead, this, [this, operationId] { handleReadyRead(operationId); });
		connect(m_reply, &QNetworkReply::finished, this, [this, operationId] { handleFinished(operationId); });
		connect(m_deadlineTimer, &QTimer::timeout, m_reply, [this, operationId] { handleTimeout(operationId); });
		m_deadlineTimer->start(static_cast<int>(options.deadline.count()));
	}

	void HttpTransport::cancel() {
		if (!isActive()) {
			return;
		}

		fail(HttpError::Cancelled, QStringLiteral("HTTP operation was cancelled"));
	}

	bool HttpTransport::optionsAreValid(const HttpRequestOptions &options) const {
		QHostAddress address;
		const auto usesHttps = options.endpoint.scheme() == QStringLiteral("https");
		const auto usesLoopbackHttp = options.endpoint.scheme() == QStringLiteral("http")
			&& (options.endpoint.host().compare(QStringLiteral("localhost"), Qt::CaseInsensitive) == 0
		        || (address.setAddress(options.endpoint.host()) && address.isLoopback()));
		return options.endpoint.isValid()
			&& !options.endpoint.isEmpty()
			&& (usesHttps || usesLoopbackHttp)
			&& !options.endpoint.host().isEmpty()
			&& options.deadline.count() > 0
			&& options.deadline.count() <= std::numeric_limits<int>::max()
			&& options.maximumResponseBytes > 0;
	}

	void HttpTransport::handleReadyRead(const quint64 operationId) {
		if (operationId != m_operationId || !isActive()) {
			return;
		}

		const auto incoming = m_reply->readAll();
		const auto currentSize = static_cast<quint64>(m_responseBuffer.size());
		const auto incomingSize = static_cast<quint64>(incoming.size());
		const auto maximumSize = static_cast<quint64>(m_maximumResponseBytes);
		if (currentSize > maximumSize || incomingSize > maximumSize - currentSize) {
			fail(HttpError::ResponseTooLarge, QStringLiteral("HTTP response exceeded the configured limit"));
			return;
		}

		m_responseBuffer.append(incoming);
	}

	void HttpTransport::handleFinished(const quint64 operationId) {
		if (operationId != m_operationId || !isActive()) {
			return;
		}

		handleReadyRead(operationId);
		if (!isActive()) {
			return;
		}

		m_deadlineTimer->stop();
		const auto redirectTarget = m_reply->attribute(QNetworkRequest::RedirectionTargetAttribute);
		if (redirectTarget.isValid() && !redirectTarget.toUrl().isEmpty()) {
			fail(HttpError::RedirectRejected, QStringLiteral("HTTP redirect was rejected"));
			return;
		}

		if (m_reply->error() != QNetworkReply::NoError) {
			fail(HttpError::NetworkFailure, QStringLiteral("HTTP network operation failed"));
			return;
		}

		const auto statusCode = m_reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
		auto responseBody = std::exchange(m_responseBuffer, QByteArray {});
		m_terminalEventEmitted = true;
		disposeReply();
		emit completed({ .statusCode = statusCode, .body = std::move(responseBody) });
	}

	void HttpTransport::handleTimeout(const quint64 operationId) {
		if (operationId == m_operationId && isActive()) {
			fail(HttpError::Timeout, QStringLiteral("HTTP operation deadline elapsed"));
		}
	}

	void HttpTransport::fail(const HttpError error, QString description) {
		if (m_terminalEventEmitted) {
			return;
		}

		m_terminalEventEmitted = true;
		m_deadlineTimer->stop();
		m_responseBuffer.clear();
		if (m_reply != nullptr) {
			disconnect(m_reply, nullptr, this, nullptr);
			m_reply->abort();
		}
		disposeReply();
		emit failureOccurred({ .error = error, .description = std::move(description) });
	}

	void HttpTransport::disposeReply() {
		if (m_reply == nullptr) {
			return;
		}

		disconnect(m_reply, nullptr, this, nullptr);
		m_reply->deleteLater();
		m_reply = nullptr;
	}

}
