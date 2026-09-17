import QtQuick

import qmlcomponents


TibiaText {
  signal clicked(string link)

  textFormat: Text.RichText

  onHoveredLinkChanged: {
    if (hoveredLink) {
      if(tibiaMouseCursorController != null) { tibiaMouseCursorController.setPointingHand(true); }
    } else {
      if(tibiaMouseCursorController != null) { tibiaMouseCursorController.setPointingHand(false); }
    }
  }

  onLinkActivated: {
    clicked(link);
  }

} //TibiaText
