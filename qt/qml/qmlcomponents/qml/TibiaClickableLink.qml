import QtQuick

import qmlcomponents


TibiaText {
  font: TibiaStyle.defaultLinkFont

  signal linkClicked()

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    onEntered: {
      if(tibiaMouseCursorController != null) { tibiaMouseCursorController.setPointingHand(true); }
    }
    onExited: {
      if(tibiaMouseCursorController != null) { tibiaMouseCursorController.setPointingHand(false); }
    }
    onClicked: {
      if (controller != null) {
        linkClicked();
      }
    } //onClicked
  } //MouseArea
} //TibiaText
