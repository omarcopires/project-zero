import QtQuick
import QtQuick.Layouts

import qmlcomponents

Item {
  id: root
  implicitWidth: dragonHeader.width
  implicitHeight: dragonHeader.height

  readonly property int bottomMargin: -23

  Image {
    id: dragonHeader
    anchors.bottom: parent.bottom
    anchors.bottomMargin: root.bottomMargin
    source: "/images/tutorial/backdrop_crest.png"
  } //Image
} //Item