import QtQuick
import qmlcomponents

BorderImage {
  readonly property int borderWidth: 4
  readonly property int marginsToContent: borderWidth + TibiaStyle.marginRelated
  smooth: false
  source: "/images/skin/classic/4pixel-up-frame.png"

  border { left: borderWidth; top: borderWidth; right: borderWidth; bottom: borderWidth }
} //BorderImage
