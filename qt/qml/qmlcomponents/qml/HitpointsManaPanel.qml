import QtQuick
import QtQuick.Layouts

import qmlcomponents


TibiaSidebarPanel {
  visible: panelController != null ? panelController.visible : true

  ColumnLayout {
    anchors.left: parent.left
    anchors.right: parent.right
    spacing: TibiaStyle.marginNarrow

    EnergyBar {
      symbolImage: "/images/hitpoints-symbol.png"
      barBorderImage: "/images/hitpoints-manapoints-bar-border.png"
      barFillImage: "/images/hitpoints-bar-filled.png"
      currentValue: panelController != null ? panelController.currentHitpoints : 0
      maxValue: panelController != null ? panelController.maxHitpoints : 0
    } // EnergyBar

    EnergyBar {
      symbolImage: "/images/mana-symbol.png"
      barBorderImage: "/images/hitpoints-manapoints-bar-border.png"
      barFillImage: "/images/mana-bar-filled.png"
      currentValue: panelController != null ? panelController.currentMana : 0
      maxValue: panelController != null ? panelController.maxMana : 0
    } // EnergyBar
  } // ColumnLayout

  Lenshelp {
    anchors.fill: parent
    triggerRect: mapFromItem(panelRoot, 0, 0, panelRoot.width, panelRoot.height)
    caption: qsTrId("hp_mana_lenshelp_caption")
    content: qsTrId("hp_mana_lenshelp")
  } //Lenshelp

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.RightButton
    onClicked: {
      if (panelController != null) {
        panelController.requestContextMenu();
      }
    } // onClicked
  } // MouseArea
} //TibiaSidebarPanel
