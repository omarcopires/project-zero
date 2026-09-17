import QtQuick
import QtQuick.Layouts



TibiaOptionsPage {
  id: root
  implicitHeight: contentLayout.height

  optionsSet: controller != null ? controller.gameplayOptions : null

  ColumnLayout {
    id: contentLayout
    anchors { left: parent.left; top: parent.top; right: parent.right }
    spacing: TibiaStyle.marginRelated

    TibiaMenuOptionCheckBox {
      id: allowAllToInspectPlayer
      text: qsTrId("optionsmenu_allow_all_to_inspect_player")
      guiHelpText: qsTrId("optionsmenu_allow_all_to_inspect_player_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet && optionsSet.allowAllToInspectPlayer
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.allowAllToInspectPlayer = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: autoChaseOff
      text: qsTrId("optionsmenu_auto_chase_off")
      guiHelpText: qsTrId("optionsmenu_auto_chase_off_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet && optionsSet.autoChaseOff
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.autoChaseOff = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: quickLootAllCorpsesInArea
      text: qsTrId("optionsmenu_quick_loot_all_corpses_in_area")
      guiHelpText: qsTrId("optionsmenu_quick_loot_all_corpses_in_area_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet && optionsSet.quickLootAllCorpsesInArea
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.quickLootAllCorpsesInArea = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox
  } //ColumnLayout
} //TibiaOptionsPage
