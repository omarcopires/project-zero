import QtQuick
import QtQuick.Templates as T


T.Button {
  id: control
  property color buttonColor
  checkable: true

  background: TibiaFrame2PixelUpFilled {
    pinnedToBottom: (control.pressed || control.checked)
    rotation: 0
  }

  Rectangle {
    anchors.fill: parent
    anchors.margins: 2
    color: control.buttonColor
  } // Rectangle
} //Button
