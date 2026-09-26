#include "assets/sprite_sheet_loader.h"

#include "assets/lzma_stream_decoder.h"

#include <QByteArray>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>
#include <QStringView>

#include <algorithm>
#include <cmath>
#include <limits>
#include <optional>
#include <span>
#include <utility>

namespace assets {
	namespace {

		constexpr qint64 maximumManifestBytes = 4 * 1024 * 1024;
		constexpr qint64 maximumCompressedSheetBytes = 16 * 1024 * 1024;
		constexpr std::size_t spriteSheetPixelWidth = 384;
		constexpr std::size_t spriteSheetPixelHeight = 384;
		constexpr std::size_t maximumBitmapHeaderBytes = 4096;
		constexpr std::size_t maximumDecodedSheetBytes =
			spriteSheetPixelWidth * spriteSheetPixelHeight * 4 + maximumBitmapHeaderBytes;
		constexpr std::uint64_t maximumDecoderMemoryBytes = 64 * 1024 * 1024;
		constexpr int maximumCachedSheetBytes = 8 * 1024 * 1024;
		constexpr auto manifestFileName = QStringView(u"catalog-content.json");
		constexpr auto spriteEntryType = QStringView(u"sprite");

		struct SpriteCellSize {
			int width;
			int height;
		};

		std::optional<SpriteSheetType> parseSpriteSheetType(const QJsonValue &value) {
			if (!value.isDouble()) {
				return std::nullopt;
			}

			const double numericValue = value.toDouble();
			if (!std::isfinite(numericValue) || std::floor(numericValue) != numericValue
			    || numericValue < 0 || numericValue > std::numeric_limits<std::uint8_t>::max()) {
				return std::nullopt;
			}

			switch (static_cast<std::uint8_t>(numericValue)) {
				case static_cast<std::uint8_t>(SpriteSheetType::Standard):
					return SpriteSheetType::Standard;
				case static_cast<std::uint8_t>(SpriteSheetType::Tall):
					return SpriteSheetType::Tall;
				case static_cast<std::uint8_t>(SpriteSheetType::Wide):
					return SpriteSheetType::Wide;
				case static_cast<std::uint8_t>(SpriteSheetType::Large):
					return SpriteSheetType::Large;
				case static_cast<std::uint8_t>(SpriteSheetType::ExtraLarge):
					return SpriteSheetType::ExtraLarge;
				case static_cast<std::uint8_t>(SpriteSheetType::Huge):
					return SpriteSheetType::Huge;
				case static_cast<std::uint8_t>(SpriteSheetType::Enormous):
					return SpriteSheetType::Enormous;
			}
			return std::nullopt;
		}

		SpriteCellSize cellSizeFor(const SpriteSheetType type) {
			switch (type) {
				case SpriteSheetType::Standard:
					return { 32, 32 };
				case SpriteSheetType::Tall:
					return { 32, 64 };
				case SpriteSheetType::Wide:
					return { 64, 32 };
				case SpriteSheetType::Large:
					return { 64, 64 };
				case SpriteSheetType::ExtraLarge:
					return { 96, 96 };
				case SpriteSheetType::Huge:
					return { 128, 128 };
				case SpriteSheetType::Enormous:
					return { 160, 160 };
			}
			return { 0, 0 };
		}

		std::optional<std::uint32_t> readUnsignedInteger(const QJsonObject &object, const QString &key) {
			const QJsonValue value = object.value(key);
			if (!value.isDouble()) {
				return std::nullopt;
			}
			const double number = value.toDouble();
			if (!std::isfinite(number) || std::floor(number) != number || number < 0
			    || number > std::numeric_limits<std::uint32_t>::max()) {
				return std::nullopt;
			}
			return static_cast<std::uint32_t>(number);
		}

		bool isSafeFileName(const QString &fileName) {
			return !fileName.isEmpty() && !QDir::isAbsolutePath(fileName)
				&& QFileInfo(fileName).fileName() == fileName
				&& fileName != QStringLiteral(".")
				&& fileName != QStringLiteral("..");
		}

	}

	SpriteSheetLoader::SpriteSheetLoader() : m_sheetCache(maximumCachedSheetBytes) {}

	SpriteSheetCatalogStatus SpriteSheetLoader::loadCatalog(const QString &assetsDirectory) {
		m_sheetCache.clear();
		m_sheets.clear();
		m_assetsDirectory.clear();

		const QFileInfo rootInfo(assetsDirectory);
		const QString canonicalRoot = rootInfo.canonicalFilePath();
		if (canonicalRoot.isEmpty() || !rootInfo.isDir()) {
			return m_catalogStatus = SpriteSheetCatalogStatus::InvalidAssetsDirectory;
		}

		const QDir rootDirectory(canonicalRoot);
		const QFileInfo manifestInfo(rootDirectory.filePath(manifestFileName.toString()));
		if (manifestInfo.canonicalFilePath().isEmpty() || manifestInfo.canonicalPath() != canonicalRoot
		    || manifestInfo.size() <= 0 || manifestInfo.size() > maximumManifestBytes) {
			return m_catalogStatus = SpriteSheetCatalogStatus::ManifestUnavailable;
		}

		QFile manifest(manifestInfo.canonicalFilePath());
		if (!manifest.open(QIODevice::ReadOnly)) {
			return m_catalogStatus = SpriteSheetCatalogStatus::ManifestUnavailable;
		}
		const QByteArray manifestBytes = manifest.read(maximumManifestBytes + 1);
		if (manifestBytes.size() != manifestInfo.size() || manifestBytes.size() > maximumManifestBytes) {
			return m_catalogStatus = SpriteSheetCatalogStatus::ManifestUnavailable;
		}

		QJsonParseError parseError;
		const QJsonDocument document = QJsonDocument::fromJson(manifestBytes, &parseError);
		if (parseError.error != QJsonParseError::NoError || !document.isArray()) {
			return m_catalogStatus = SpriteSheetCatalogStatus::InvalidManifest;
		}

		std::vector<SheetEntry> sheets;
		for (const QJsonValue &value : document.array()) {
			if (!value.isObject()) {
				return m_catalogStatus = SpriteSheetCatalogStatus::InvalidManifest;
			}
			const QJsonObject object = value.toObject();
			if (object.value(QStringLiteral("type")).toString() != spriteEntryType.toString()) {
				continue;
			}

			const QString fileName = object.value(QStringLiteral("file")).toString();
			const auto firstSpriteId = readUnsignedInteger(object, QStringLiteral("firstspriteid"));
			const auto lastSpriteId = readUnsignedInteger(object, QStringLiteral("lastspriteid"));
			const auto spriteType = parseSpriteSheetType(object.value(QStringLiteral("spritetype")));
			const auto area = readUnsignedInteger(object, QStringLiteral("area"));
			if (!isSafeFileName(fileName) || !firstSpriteId || !lastSpriteId || !spriteType || !area
			    || *lastSpriteId < *firstSpriteId) {
				return m_catalogStatus = SpriteSheetCatalogStatus::InvalidManifest;
			}

			const SpriteCellSize cellSize = cellSizeFor(*spriteType);
			const std::uint64_t capacity = static_cast<std::uint64_t>(spriteSheetPixelWidth / cellSize.width)
				* (spriteSheetPixelHeight / cellSize.height);
			const std::uint64_t rangeSize = static_cast<std::uint64_t>(*lastSpriteId) - *firstSpriteId + 1;
			if (rangeSize > capacity) {
				return m_catalogStatus = SpriteSheetCatalogStatus::InvalidManifest;
			}

			sheets.push_back({
				.fileName = fileName,
				.firstSpriteId = *firstSpriteId,
				.lastSpriteId = *lastSpriteId,
				.type = *spriteType,
			});
		}

		if (sheets.empty()) {
			return m_catalogStatus = SpriteSheetCatalogStatus::EmptyCatalog;
		}
		std::sort(sheets.begin(), sheets.end(), [](const SheetEntry &left, const SheetEntry &right) {
			return left.firstSpriteId < right.firstSpriteId;
		});
		for (std::size_t index = 1; index < sheets.size(); ++index) {
			if (sheets[index].firstSpriteId <= sheets[index - 1].lastSpriteId) {
				return m_catalogStatus = SpriteSheetCatalogStatus::OverlappingSpriteRanges;
			}
		}

		m_assetsDirectory = canonicalRoot;
		m_sheets = std::move(sheets);
		return m_catalogStatus = SpriteSheetCatalogStatus::Ready;
	}

	SpriteSheetImageResult SpriteSheetLoader::loadSpriteImage(const std::uint32_t spriteId) {
		if (m_catalogStatus != SpriteSheetCatalogStatus::Ready) {
			return { .status = SpriteImageStatus::CatalogUnavailable };
		}

		const SheetEntry *entry = findSheet(spriteId);
		if (entry == nullptr) {
			return { .status = SpriteImageStatus::SpriteNotFound };
		}

		SpriteImageStatus sheetStatus = SpriteImageStatus::Ready;
		const QImage *sheet = m_sheetCache.object(entry->fileName);
		if (sheet == nullptr) {
			const QImage loadedSheet = loadSheet(*entry, sheetStatus);
			if (loadedSheet.isNull()) {
				return { .status = sheetStatus };
			}
			const int cost = static_cast<int>(loadedSheet.sizeInBytes());
			m_sheetCache.insert(entry->fileName, new QImage(loadedSheet), cost);
			sheet = m_sheetCache.object(entry->fileName);
			if (sheet == nullptr) {
				return { .status = SpriteImageStatus::SpriteSheetUnavailable };
			}
		}

		const SpriteCellSize cellSize = cellSizeFor(entry->type);
		const std::uint32_t localIndex = spriteId - entry->firstSpriteId;
		const std::uint32_t columns = static_cast<std::uint32_t>(spriteSheetPixelWidth / cellSize.width);
		const std::uint32_t column = localIndex % columns;
		const std::uint32_t row = localIndex / columns;
		const int x = static_cast<int>(column) * cellSize.width;
		const int y = static_cast<int>(row) * cellSize.height;
		if (x + cellSize.width > sheet->width() || y + cellSize.height > sheet->height()) {
			return { .status = SpriteImageStatus::SpriteOutOfRange };
		}
		QImage sprite = sheet->copy(x, y, cellSize.width, cellSize.height);
		if (sprite.isNull()) {
			return { .status = SpriteImageStatus::InvalidBitmap };
		}
		return { .status = SpriteImageStatus::Ready, .image = std::move(sprite) };
	}

	std::size_t SpriteSheetLoader::sheetCount() const noexcept {
		return m_sheets.size();
	}

	const SpriteSheetLoader::SheetEntry *SpriteSheetLoader::findSheet(const std::uint32_t spriteId) const noexcept {
		const auto found = std::lower_bound(
			m_sheets.begin(),
			m_sheets.end(),
			spriteId,
			[](const SheetEntry &entry, const std::uint32_t id) {
				return entry.lastSpriteId < id;
			}
		);
		return found != m_sheets.end() && found->firstSpriteId <= spriteId ? &*found : nullptr;
	}

	QImage SpriteSheetLoader::loadSheet(const SheetEntry &entry, SpriteImageStatus &status) {
		const QFileInfo fileInfo(QDir(m_assetsDirectory).filePath(entry.fileName));
		const QString canonicalPath = fileInfo.canonicalFilePath();
		if (canonicalPath.isEmpty() || fileInfo.canonicalPath() != m_assetsDirectory
		    || fileInfo.size() <= 0 || fileInfo.size() > maximumCompressedSheetBytes) {
			status = SpriteImageStatus::SpriteSheetUnavailable;
			return {};
		}

		QFile file(canonicalPath);
		if (!file.open(QIODevice::ReadOnly)) {
			status = SpriteImageStatus::SpriteSheetUnavailable;
			return {};
		}
		const QByteArray compressedBytes = file.read(maximumCompressedSheetBytes + 1);
		if (compressedBytes.size() != fileInfo.size() || compressedBytes.size() > maximumCompressedSheetBytes) {
			status = SpriteImageStatus::SpriteSheetUnavailable;
			return {};
		}

		const auto *data = reinterpret_cast<const std::byte*>(compressedBytes.constData());
		const auto decoded = decodeCipSpriteSheet(
			std::span<const std::byte>(data, static_cast<std::size_t>(compressedBytes.size())),
			maximumDecodedSheetBytes,
			maximumDecoderMemoryBytes
		);
		if (decoded.status != LzmaDecodeStatus::Decoded
		    || decoded.output.size() > static_cast<std::size_t>(std::numeric_limits<int>::max())) {
			status = SpriteImageStatus::InvalidCompressedData;
			return {};
		}

		const QByteArray bitmap(
			reinterpret_cast<const char*>(decoded.output.data()),
			static_cast<qsizetype>(decoded.output.size())
		);
		QImage image = QImage::fromData(bitmap, "BMP");
		if (image.isNull() || image.width() != static_cast<int>(spriteSheetPixelWidth)
		    || image.height() != static_cast<int>(spriteSheetPixelHeight)) {
			status = SpriteImageStatus::InvalidBitmap;
			return {};
		}
		image = image.convertToFormat(QImage::Format_RGBA8888);
		if (image.isNull()) {
			status = SpriteImageStatus::InvalidBitmap;
		}
		return image;
	}

}
