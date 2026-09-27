#include <gtest/gtest.h>

#include "presentation/rendering/appearance_image_provider.h"
#include "support/cip_sprite_sheet_fixture.h"

#include "appearances.pb.h"

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
#include <string>
#include <vector>

namespace {

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
		const auto *bytes = reinterpret_cast<const std::byte *>(bitmapBytes.constData());
		return test_support::makeCipSpriteSheet(
			std::span<const std::byte>(bytes, static_cast<std::size_t>(bitmapBytes.size()))
		);
	}

	QByteArray appearanceAsset() {
		tibia::protobuf::appearances::Appearances appearances;
		auto *appearance = appearances.add_object();
		appearance->set_id(4200);
		auto *frameGroup = appearance->add_frame_group();
		frameGroup->set_fixed_frame_group(tibia::protobuf::appearances::FIXED_FRAME_GROUP_OBJECT_INITIAL);
		auto *spriteInfo = frameGroup->mutable_sprite_info();
		spriteInfo->set_pattern_width(1);
		spriteInfo->set_pattern_height(1);
		spriteInfo->set_pattern_depth(1);
		spriteInfo->set_layers(1);
		spriteInfo->add_sprite_id(100);

		std::string bytes;
		if (!appearances.SerializeToString(&bytes)) {
			return {};
		}
		return QByteArray(bytes.data(), static_cast<qsizetype>(bytes.size()));
	}

}

TEST(AppearanceImageProvider, ResolvesStaticAppearanceToCatalogSprite) {
	QTemporaryDir directory;
	ASSERT_TRUE(directory.isValid());

	QImage bitmap(384, 384, QImage::Format_RGB32);
	bitmap.fill(Qt::black);
	QPainter painter(&bitmap);
	painter.fillRect(QRect(0, 0, 32, 32), QColor(Qt::red));
	painter.end();
	const auto compressed = makeCompressedBitmap(bitmap);
	ASSERT_TRUE(compressed.has_value());
	const QByteArray compressedBytes(
		reinterpret_cast<const char *>(compressed->data()),
		static_cast<qsizetype>(compressed->size())
	);
	ASSERT_TRUE(writeFile(directory.filePath(QStringLiteral("sprites.lzma")), compressedBytes));
	ASSERT_TRUE(writeFile(directory.filePath(QStringLiteral("appearances.dat")), appearanceAsset()));

	const QJsonArray manifest {
		QJsonObject {
			{ QStringLiteral("type"), QStringLiteral("appearances") },
			{ QStringLiteral("file"), QStringLiteral("appearances.dat") },
		},
		QJsonObject {
			{ QStringLiteral("type"), QStringLiteral("sprite") },
			{ QStringLiteral("file"), QStringLiteral("sprites.lzma") },
			{ QStringLiteral("firstspriteid"), 100 },
			{ QStringLiteral("lastspriteid"), 100 },
			{ QStringLiteral("spritetype"), 0 },
			{ QStringLiteral("area"), 0 },
		},
	};
	ASSERT_TRUE(writeFile(
		directory.filePath(QStringLiteral("catalog-content.json")),
		QJsonDocument(manifest).toJson(QJsonDocument::Compact)
	));

	client::presentation::rendering::AppearanceImageProvider provider(directory.path());
	QSize size;
	const QImage image = provider.requestImage(QStringLiteral("object/4200"), &size, {});

	ASSERT_FALSE(image.isNull());
	EXPECT_EQ(size, QSize(32, 32));
	EXPECT_EQ(image.pixelColor(0, 0), QColor(Qt::red));
}

TEST(AppearanceImageProvider, RejectsMultilayerAppearanceUntilLayerCompositionIsSupported) {
	tibia::protobuf::appearances::Appearances appearances;
	auto *appearance = appearances.add_object();
	appearance->set_id(4201);
	auto *spriteInfo = appearance->add_frame_group()->mutable_sprite_info();
	spriteInfo->set_pattern_width(1);
	spriteInfo->set_pattern_height(1);
	spriteInfo->set_pattern_depth(1);
	spriteInfo->set_layers(2);
	spriteInfo->add_sprite_id(100);
	spriteInfo->add_sprite_id(101);
	std::string bytes;
	ASSERT_TRUE(appearances.SerializeToString(&bytes));

	QTemporaryDir directory;
	ASSERT_TRUE(directory.isValid());
	ASSERT_TRUE(writeFile(
		directory.filePath(QStringLiteral("appearances.dat")),
		QByteArray(bytes.data(), static_cast<qsizetype>(bytes.size()))
	));
	QImage bitmap(384, 384, QImage::Format_RGB32);
	bitmap.fill(Qt::black);
	const auto compressed = makeCompressedBitmap(bitmap);
	ASSERT_TRUE(compressed.has_value());
	ASSERT_TRUE(writeFile(
		directory.filePath(QStringLiteral("sprites.lzma")),
		QByteArray(reinterpret_cast<const char *>(compressed->data()), static_cast<qsizetype>(compressed->size()))
	));
	const QJsonArray manifest {
		QJsonObject {
			{ QStringLiteral("type"), QStringLiteral("appearances") },
			{ QStringLiteral("file"), QStringLiteral("appearances.dat") },
		},
		QJsonObject {
			{ QStringLiteral("type"), QStringLiteral("sprite") },
			{ QStringLiteral("file"), QStringLiteral("sprites.lzma") },
			{ QStringLiteral("firstspriteid"), 100 },
			{ QStringLiteral("lastspriteid"), 101 },
			{ QStringLiteral("spritetype"), 0 },
			{ QStringLiteral("area"), 0 },
		},
	};
	ASSERT_TRUE(writeFile(
		directory.filePath(QStringLiteral("catalog-content.json")),
		QJsonDocument(manifest).toJson(QJsonDocument::Compact)
	));

	client::presentation::rendering::AppearanceImageProvider provider(directory.path());
	EXPECT_TRUE(provider.requestImage(QStringLiteral("object/4201"), nullptr, {}).isNull());
}

TEST(AppearanceImageProvider, RejectsRequestsWhenAssetsAreNotConfigured) {
	client::presentation::rendering::AppearanceImageProvider provider(QString {});
	QSize size(32, 32);

	const QImage image = provider.requestImage(QStringLiteral("object/4200"), &size, {});

	EXPECT_TRUE(image.isNull());
	EXPECT_TRUE(size.isEmpty());
}

TEST(AppearanceImageProvider, RejectsMalformedAppearanceIdentifiers) {
	client::presentation::rendering::AppearanceImageProvider provider(QString {});

	EXPECT_TRUE(provider.requestImage(QStringLiteral("invalid/4200"), nullptr, {}).isNull());
	EXPECT_TRUE(provider.requestImage(QStringLiteral("object/not-a-number"), nullptr, {}).isNull());
	EXPECT_TRUE(provider.requestImage(QStringLiteral("object/4200/extra"), nullptr, {}).isNull());
}
