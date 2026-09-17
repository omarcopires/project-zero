import QtQuick
import QtQuick.Layouts



ColumnLayout {
  spacing:0
  BorderImage {
    id: topElement
    Layout.fillWidth: true
    horizontalTileMode: BorderImage.Repeat
    source: "/images/skin/classic/horizontal-line-dark.png"
    smooth: false
  } //Image
  BorderImage {
    id: bottomElement
    Layout.fillWidth: true
    horizontalTileMode: BorderImage.Repeat
    source: "/images/skin/classic/horizontal-line-bright.png"
    smooth: false
  } //Image
} //ColumnLayout
