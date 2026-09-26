#include <gtest/gtest.h>

#include "assets/sprite_image_status.h"
#include "assets/sprite_sheet_catalog_status.h"
#include "assets/sprite_sheet_loader.h"
#include "support/cip_sprite_sheet_fixture.h"

#include <QBuffer>
#include <QColor>
#include <QFile>
#include <QImage>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QPainter>
#include <QTemporaryDir>

#include <cstddef>
#include <optional>
#include <span>
#include <vector>

namespace {

	QByteArray makeManifest(const QJsonArray &entries) {
		return QJsonDocument(entries).toJson(QJsonDocument::Compact);
	}

	QJsonObject makeSpriteEntry(
		const QString &fileName,
		const int firstSpriteId,
		const int lastSpriteId,
		const int spriteType = 0
	) {
		return {
			{ QStringLiteral("type"), QStringLiteral("sprite") },
			{ QStringLiteral("file"), fileName },
			{ QStringLiteral("firstspriteid"), firstSpriteId },
			{ QStringLiteral("lastspriteid"), lastSpriteId },
			{ QStringLiteral("spritetype"), spriteType },
			{ QStringLiteral("area"), 0 },
		};
	}

	bool writeFile(const QString &path, const QByteArray &bytes) {
		QFile file(path);
		return file.open(QIODevice::WriteOnly) && file.write(bytes) == bytes.size();
	}

	std::optional<std::vector<std::byte>> makeCompressedBitmap(QImage &image) {
		QByteArray bitmapBytes;
		QBuffer buffer(&bitmapBytes);
		if (!buffer.open(QIODevice::WriteOnly) || !image.save(&buffer, "BMP")) {
			return std::nullopt;
		}
		const auto *bytes = reinterpret_cast<const std::byte*>(bitmapBytes.constData());
		return test_support::makeCipSpriteSheet(
			std::span<const std::byte>(bytes, static_cast<std::size_t>(bitmapBytes.size()))
		);
	}

}

TEST(SpriteSheetLoader, CropsSpriteByCatalogIdAndCachesSheet) {
	QTemporaryDir directory;
	ASSERT_TRUE(directory.isValid());

	QImage bitmap(384, 384, QImage::Format_RGB32);
	bitmap.fill(Qt::black);
	QPainter painter(&bitmap);
	painter.fillRect(QRect(0, 0, 32, 32), QColor(Qt::red));
	painter.fillRect(QRect(32, 0, 32, 32), QColor(Qt::green));
	painter.fillRect(QRect(64, 0, 32, 32), QColor(Qt::blue));
	painter.end();
	const auto compressed = makeCompressedBitmap(bitmap);
	ASSERT_TRUE(compressed.has_value());
	QByteArray compressedBytes(
		reinterpret_cast<const char*>(compressed->data()),
		static_cast<qsizetype>(compressed->size())
	);
	ASSERT_TRUE(writeFile(directory.filePath(QStringLiteral("sprites-1.bmp.lzma")), compressedBytes));
	ASSERT_TRUE(writeFile(
		directory.filePath(QStringLiteral("catalog-content.json")),
		makeManifest(QJsonArray { makeSpriteEntry(QStringLiteral("sprites-1.bmp.lzma"), 100, 102) })
	));

	assets::SpriteSheetLoader loader;
	ASSERT_EQ(loader.loadCatalog(directory.path()), assets::SpriteSheetCatalogStatus::Ready);
	ASSERT_EQ(loader.sheetCount(), 1U);

	const auto first = loader.loadSpriteImage(100);
	ASSERT_EQ(first.status, assets::SpriteImageStatus::Ready);
	ASSERT_EQ(first.image.size(), QSize(32, 32));
	EXPECT_EQ(first.image.pixelColor(0, 0), QColor(Qt::red));

	const auto second = loader.loadSpriteImage(101);
	ASSERT_EQ(second.status, assets::SpriteImageStatus::Ready);
	EXPECT_EQ(second.image.pixelColor(0, 0), QColor(Qt::green));

	const auto third = loader.loadSpriteImage(102);
	ASSERT_EQ(third.status, assets::SpriteImageStatus::Ready);
	EXPECT_EQ(third.image.pixelColor(0, 0), QColor(Qt::blue));
	EXPECT_EQ(loader.loadSpriteImage(103).status, assets::SpriteImageStatus::SpriteNotFound);
}

TEST(SpriteSheetLoader, UsesCellDimensionsFromSpriteSheetType) {
	QTemporaryDir directory;
	ASSERT_TRUE(directory.isValid());

	QImage bitmap(384, 384, QImage::Format_RGB32);
	bitmap.fill(Qt::black);
	QPainter painter(&bitmap);
	painter.fillRect(QRect(0, 0, 32, 64), QColor(Qt::yellow));
	painter.end();
	const auto compressed = makeCompressedBitmap(bitmap);
	ASSERT_TRUE(compressed.has_value());
	ASSERT_TRUE(writeFile(
		directory.filePath(QStringLiteral("sprites-2.bmp.lzma")),
		QByteArray(reinterpret_cast<const char*>(compressed->data()), static_cast<qsizetype>(compressed->size()))
	));
	ASSERT_TRUE(writeFile(
		directory.filePath(QStringLiteral("catalog-content.json")),
		makeManifest(QJsonArray { makeSpriteEntry(QStringLiteral("sprites-2.bmp.lzma"), 200, 200, 1) })
	));

	assets::SpriteSheetLoader loader;
	ASSERT_EQ(loader.loadCatalog(directory.path()), assets::SpriteSheetCatalogStatus::Ready);
	const auto sprite = loader.loadSpriteImage(200);
	ASSERT_EQ(sprite.status, assets::SpriteImageStatus::Ready);
	EXPECT_EQ(sprite.image.size(), QSize(32, 64));
	EXPECT_EQ(sprite.image.pixelColor(0, 0), QColor(Qt::yellow));
}

TEST(SpriteSheetLoader, RejectsOverlappingSpriteRanges) {
	QTemporaryDir directory;
	ASSERT_TRUE(directory.isValid());
	ASSERT_TRUE(writeFile(
		directory.filePath(QStringLiteral("catalog-content.json")),
		makeManifest(QJsonArray {
			makeSpriteEntry(QStringLiteral("a.lzma"), 10, 20),
			makeSpriteEntry(QStringLiteral("b.lzma"), 20, 30),
		})
	));

	assets::SpriteSheetLoader loader;
	EXPECT_EQ(loader.loadCatalog(directory.path()), assets::SpriteSheetCatalogStatus::OverlappingSpriteRanges);
	EXPECT_EQ(loader.sheetCount(), 0U);
	EXPECT_EQ(loader.loadSpriteImage(10).status, assets::SpriteImageStatus::CatalogUnavailable);
}

TEST(SpriteSheetLoader, RejectsSpriteRangesLargerThanSheetCapacity) {
	QTemporaryDir directory;
	ASSERT_TRUE(directory.isValid());
	ASSERT_TRUE(writeFile(
		directory.filePath(QStringLiteral("catalog-content.json")),
		makeManifest(QJsonArray {
			makeSpriteEntry(QStringLiteral("too-many.lzma"), 0, 144),
		})
	));

	assets::SpriteSheetLoader loader;
	EXPECT_EQ(loader.loadCatalog(directory.path()), assets::SpriteSheetCatalogStatus::InvalidManifest);
}

TEST(SpriteSheetLoader, RejectsAssetFileEscapingAssetsDirectory) {
	QTemporaryDir directory;
	ASSERT_TRUE(directory.isValid());
	ASSERT_TRUE(writeFile(
		directory.filePath(QStringLiteral("catalog-content.json")),
		makeManifest(QJsonArray { makeSpriteEntry(QStringLiteral("../outside.lzma"), 0, 0) })
	));

	assets::SpriteSheetLoader loader;
	EXPECT_EQ(loader.loadCatalog(directory.path()), assets::SpriteSheetCatalogStatus::InvalidManifest);
}
