import QtQuick
import QtQuick.Layouts

import qmlcomponents



Item {
  id: root
  Layout.preferredWidth: TibiaStyle.buttonWidthBroad
  implicitHeight: TibiaStyle.buttonHeightDefault

  property alias text: button.text
  property alias disabledReason: tooltip.text

  signal clicked();

  TibiaButton {
    id: button
    anchors.fill: parent

    enabled: root.disabledReason.length == 0
    onClicked: root.clicked();
  } //TibiaButton

  Tooltip {
    id: tooltip
    anchors.fill: parent
    maxWidth: TibiaStyle.tooltipRestrictedWidth
  } //Tooltip
} //Item
