import QtQuick

import qmlcomponents

BorderImage {
  anchors.fill: parent
  anchors.margins: -boarderWidth
  readonly property int boarderWidth: 1
  border { left: boarderWidth; top: boarderWidth; right: boarderWidth; bottom: boarderWidth }
  visible: parent.enabled
  source: "/images/rectangle-highlight.png"
  smooth: false
} //BorderImage
