import QtQuick
import QtQuick.Layouts



RowLayout {
  spacing: 0

  BorderImage {
    Layout.fillHeight: true
    verticalTileMode: BorderImage.Repeat
    source: "/images/skin/classic/vertical-line-dark.png"
    smooth: false
  } // Image
  BorderImage {
    Layout.fillHeight: true
    verticalTileMode: BorderImage.Repeat
    source: "/images/skin/classic/vertical-line-bright.png"
    smooth: false
  } // Image
} // RowLayout
