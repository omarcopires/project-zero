import QtQuick
import QtQuick.Controls

import qmlcomponents

Item {
  id: root
  implicitWidth: dragonHeader.width
  implicitHeight: dragonHeader.height

  readonly property int bottomMargin: TibiaStyle.dragonHeaderMarginToDialog

  Image {
    id: dragonHeader
    anchors.bottom: parent.bottom
    anchors.bottomMargin: root.bottomMargin

    SequentialAnimation {
      running: true
      loops: Animation.Infinite
      alwaysRunToEnd: true

      PropertyAnimation { target: dragonHeader; property: "source"; to: "image://dragonheader-animation/1"; duration: 0 }
      PropertyAnimation { target: dragonHeader; property: "source"; to: "image://dragonheader-animation/2"; duration: 150 }
      PropertyAnimation { target: dragonHeader; property: "source"; to: "image://dragonheader-animation/3"; duration: 150 }
      PropertyAnimation { target: dragonHeader; property: "source"; to: "image://dragonheader-animation/4"; duration: 300 }
      PropertyAnimation { target: dragonHeader; property: "source"; to: "image://dragonheader-animation/5"; duration: 150 }
      PropertyAnimation { target: dragonHeader; property: "source"; to: "image://dragonheader-animation/6"; duration: 150 }
      PropertyAnimation { target: dragonHeader; property: "source"; to: "image://dragonheader-animation/0"; duration: 3000 }
    } //SequentialAnimation
  } //Image
} //Item