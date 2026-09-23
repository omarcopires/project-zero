import QtQuick



MouseArea {
  id: mouseShild
  anchors.fill: parent

  property alias mouseShieldVisible: viewBlocker.visible

  acceptedButtons: Qt.AllButtons
  hoverEnabled: true
  preventStealing: true

  signal anyButtonClicked()

  //consume mouse events
  onCanceled: {}
  onClicked: anyButtonClicked()
  onDoubleClicked: {}
  onEntered: {
    if (tibiaMouseCursorController != null) {
      tibiaMouseCursorController.onMouseShieldEntered();
    }
  }
  onExited: {
    if (tibiaMouseCursorController != null) {
      tibiaMouseCursorController.onMouseShieldExited();
    }
  }
  onPositionChanged: {}
  onPressAndHold: {}
  onPressed: {}
  onReleased: {}
  onWheel: {}

  Rectangle {
    id: viewBlocker
    anchors.fill: parent
    color: "black"
    opacity: 0.5
    visible: false
  }

  Item {
    objectName: "placeholder"
    anchors.fill: parent
  }
} //MouseArea
