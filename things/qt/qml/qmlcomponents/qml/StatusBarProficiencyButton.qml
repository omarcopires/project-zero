import QtQuick

import qmlcomponents

TibiaButton {
  id: root

  enum PositionType {
    TopBottom,
    Left,
    Right
  }

  property bool isHighlighted: false
  property int positionType: StatusBarProficiencyButton.PositionType.TopBottom

  imageSourceUp: "/images/icon-proficiencytree-open.png"
  imageYOffset: {
    if (pressed) {
      return -1
    } else {
      if (positionType == StatusBarProficiencyButton.PositionType.TopBottom) {
        return -1
      }
    }
    return 0
  }
  imageXOffset: {
    if (pressed) {
      if (positionType == StatusBarProficiencyButton.PositionType.TopBottom) {
        return -1
      } else if (positionType == StatusBarProficiencyButton.PositionType.Left) {
        return -2
      }
    }
    return 0
  }

  tooltipText: qsTrId("statusbar_proficiency_button_tooltip")

  TibiaRectangleHighlight {
    visible: root.isHighlighted
  } //TibiaRectangleHighlight

  Lenshelp {
    anchors.fill: parent
    anchors.margins: -1
    caption: qsTrId("statusbar_proficiency_button_lenshelp_caption")
    content: qsTrId("statusbar_proficiency_button_lenshelp_content")
  } //Lenshelp
}
