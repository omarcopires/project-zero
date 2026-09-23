import QtQuick

MouseArea {
  id: filterMouseArea

  property bool showDebugOverlay: false

  Component {
    id: tutorialDebugOverlay

    Rectangle {
      color: Qt.rgba(0.5 + Math.random() * 0.5, 0.5 + Math.random() * 0.5, 0.5 + Math.random() * 0.5, 1.0)
      opacity: 0.3
      border.width: 1
      border.color: "white"
    }  // Rectangle
  } //Component

  hoverEnabled: true
  preventStealing: true
  acceptedButtons: Qt.AllButtons

  onCanceled: {}
  onClicked: {}
  onDoubleClicked: {}
  onEntered: {}
  onExited: {}
  onPositionChanged: {}
  onPressAndHold: {}
  onPressed: {}
  onReleased: {}
  onWheel: {}

  z: 999

  Loader {
    id: debugOverlayLoader
    sourceComponent: showDebugOverlay ? tutorialDebugOverlay : null
    anchors.fill: parent
  } //Loader


} // MouseArea

