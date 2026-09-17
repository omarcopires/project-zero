import QtQuick
import qmlcomponents



Image {
  property string tooltipText: ""
  property string sourceUp: ""
  property string sourceDown: ""
  property var triggerFunction: (function(mouse) { }) //mouse == null means no mouse information

  property alias pressed: buttonFake.pressed

  source: buttonFake.pressed ? sourceDown : sourceUp

  MouseArea {
    id: buttonFake
    anchors.fill: parent

    property bool autoincrement: false
    property bool pressed: false
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onClicked: (mouse) => {
      if (mouse.button == Qt.RightButton) {
        return
      }
      triggerFunction(mouse)
    }
    onPressed: (mouse) => {
      if (mouse.button == Qt.RightButton) {
        return
      }
      pressed = true;
    }
    onReleased: (mouse) => {
      if (mouse.button == Qt.RightButton) {
        return
      }
      autoincrement = false;
      pressed = false;
    }

    Timer {
      running: buttonFake.pressed
      interval: 350 //number taken form ScrollBar.qml
      onTriggered: buttonFake.autoincrement = true
    } //Timer

    Timer {
      running: buttonFake.autoincrement
      interval: 60 //number taken form ScrollBar.qml
      repeat: true
      onTriggered: triggerFunction(null)
    } //Timer
  } //MouseAra

  onEnabledChanged: {
    if (!enabled) {
      buttonFake.autoincrement = false
    }
  }

  Tooltip {
    enabled: (tooltipText != "") && !buttonFake.pressed
    anchors.fill: parent
    text: tooltipText
  } //Tooltip
} //Image
