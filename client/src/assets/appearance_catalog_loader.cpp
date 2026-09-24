#include "assets/appearance_catalog_loader.h"

#include <QByteArray>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>
#include <QStringView>

#include <cstddef>
#include <span>
#include <utility>

namespace assets {
	namespace {

		constexpr qint64 maximumAppearanceAssetBytes = 32 * 1024 * 1024;
		constexpr qint64 maximumManifestBytes = 4 * 1024 * 1024;
		constexpr auto manifestFileName = QStringView(u"catalog-content.json");
		constexpr auto appearanceEntryType = QStringView(u"appearances");

	}

	AppearanceCatalogLoadResult loadAppearanceCatalog(const QString &assetsDirectory) {
		const QFileInfo rootInfo(assetsDirectory);
		const QString canonicalRoot = rootInfo.canonicalFilePath();
		if (canonicalRoot.isEmpty() || !rootInfo.isDir()) {
			return { .status = AppearanceCatalogLoadStatus::InvalidAssetsDirectory };
		}

		const QDir rootDirectory(canonicalRoot);
		const QFileInfo manifestInfo(rootDirectory.filePath(manifestFileName.toString()));
		if (manifestInfo.canonicalFilePath().isEmpty() || manifestInfo.canonicalPath() != canonicalRoot
		    || manifestInfo.size() <= 0 || manifestInfo.size() > maximumManifestBytes) {
			return { .status = AppearanceCatalogLoadStatus::ManifestUnavailable };
		}

		QFile manifest(manifestInfo.canonicalFilePath());
		if (!manifest.open(QIODevice::ReadOnly)) {
			return { .status = AppearanceCatalogLoadStatus::ManifestUnavailable };
		}

		const QByteArray manifestBytes = manifest.read(maximumManifestBytes + 1);
		if (manifestBytes.size() != manifestInfo.size() || manifestBytes.size() > maximumManifestBytes) {
			return { .status = AppearanceCatalogLoadStatus::ManifestUnavailable };
		}
		QJsonParseError parseError;
		const QJsonDocument document = QJsonDocument::fromJson(manifestBytes, &parseError);
		if (parseError.error != QJsonParseError::NoError || !document.isArray()) {
			return { .status = AppearanceCatalogLoadStatus::InvalidManifest };
		}

		QString appearanceFileName;
		for (const auto &entryValue : document.array()) {
			if (!entryValue.isObject()) {
				return { .status = AppearanceCatalogLoadStatus::InvalidManifest };
			}
			const auto entry = entryValue.toObject();
			if (entry.value(QStringLiteral("type")).toString() != appearanceEntryType) {
				continue;
			}
			if (!appearanceFileName.isEmpty()) {
				return { .status = AppearanceCatalogLoadStatus::InvalidManifest };
			}
			appearanceFileName = entry.value(QStringLiteral("file")).toString();
		}
		if (appearanceFileName.isEmpty()) {
			return { .status = AppearanceCatalogLoadStatus::AppearanceAssetMissing };
		}

		const QFileInfo appearanceInfo(rootDirectory.filePath(appearanceFileName));
		if (QDir::isAbsolutePath(appearanceFileName)
		    || QFileInfo(appearanceFileName).fileName() != appearanceFileName
		    || appearanceFileName == QStringLiteral(".")
		    || appearanceFileName == QStringLiteral("..")) {
			return { .status = AppearanceCatalogLoadStatus::InvalidAssetPath };
		}

		const QString canonicalAppearancePath = appearanceInfo.canonicalFilePath();
		if (canonicalAppearancePath.isEmpty() || appearanceInfo.canonicalPath() != canonicalRoot) {
			return { .status = AppearanceCatalogLoadStatus::InvalidAssetPath };
		}
		if (appearanceInfo.size() <= 0 || appearanceInfo.size() > maximumAppearanceAssetBytes) {
			return { .status = AppearanceCatalogLoadStatus::AppearanceAssetUnavailable };
		}

		QFile appearanceFile(canonicalAppearancePath);
		if (!appearanceFile.open(QIODevice::ReadOnly)) {
			return { .status = AppearanceCatalogLoadStatus::AppearanceAssetUnavailable };
		}
		const QByteArray bytes = appearanceFile.read(maximumAppearanceAssetBytes + 1);
		if (bytes.size() != appearanceInfo.size() || bytes.size() > maximumAppearanceAssetBytes) {
			return { .status = AppearanceCatalogLoadStatus::AppearanceAssetUnavailable };
		}

		const auto *data = reinterpret_cast<const std::byte *>(bytes.constData());
		auto catalog = AppearanceCatalog::decode(std::span<const std::byte>(data, static_cast<std::size_t>(bytes.size())));
		if (!catalog) {
			return { .status = AppearanceCatalogLoadStatus::InvalidAppearanceData };
		}
		return {
			.status = AppearanceCatalogLoadStatus::Ready,
			.catalog = std::move(catalog),
		};
	}

}
