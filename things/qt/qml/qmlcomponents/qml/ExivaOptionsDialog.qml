import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qmlcomponents


TibiaDialog {
  id: dialogRoot
  caption: qsTrId("exivaoptions_caption")
  width: 450

  property var controller: null

  initialFocusItem: dialogRoot
  KeyNavigation.tab: dialogRoot

  onReturnPressedFunction: onOkClicked
  onCancelPressedFunction: onCloseClicked

  function onCloseClicked() {
    if (controller != null) {
      controller.closeButtonClicked();
    }
  } //function onCloseClicked

  function onApplyClicked() {
    if (controller != null) {
      controller.applyButtonClicked(characterWhitelist.text,
                                    guildWhitelist.text);
    }
  } //function onApplyClicked

  function onOkClicked() {
    if (controller != null) {
      onApplyClicked();
      onCloseClicked();
    }
  } //function onOkClicked

  property string characterWhitelistString: controller != null ? controller.characterWhitelist : ""
  property string guildWhitelistString: controller != null ? controller.guildWhitelist : ""

  onCharacterWhitelistStringChanged: {
    characterWhitelist.cursorPosition = 0;
    characterWhitelist.text = characterWhitelistString;
    characterWhitelist.cursorPosition = characterWhitelistString.length;
  } //onCharacterWhitelistStringChanged

  onGuildWhitelistStringChanged: {
    guildWhitelist.cursorPosition = 0;
    guildWhitelist.text = guildWhitelistString;
    guildWhitelist.cursorPosition = guildWhitelistString.length;
  } //onGuildWhitelistStringChanged

  ColumnLayout {
    anchors { left: parent.left; top: parent.top; right: parent.right }
    spacing: TibiaStyle.marginUnrelated

    ColumnLayout {
      id: contentLayout
      Layout.fillWidth: true
      spacing: TibiaStyle.marginRelated

      ButtonGroup {
        id: allowEveryoneExlusiveGroup
        property bool allowEveryoneSelected: controller != null && controller.allowEveryone
        onAllowEveryoneSelectedChanged: {
          if (allowEveryoneSelected) {
            checkedButton = allowEveryoneRadioButton;
          } else {
            checkedButton = allowSelectedGroupsRadioButton;
          }
        } //onAllowEveryoneSelectedChanged

        checkedButton: allowSelectedGroupsRadioButton
        onCheckedButtonChanged: {
          if (controller != null) {
            if (checkedButton == allowEveryoneRadioButton) {
              controller.allowEveryone = true;
            } else {
              controller.allowEveryone = false;
            }
          }
        } //onCheckedButtonChanged

      } //ButtonGroup

      TibiaRadioButton {
        id: allowEveryoneRadioButton
        text: qsTrId("exivaoptions_allow_everyone")
        ButtonGroup.group: allowEveryoneExlusiveGroup
      } //TibiaRadioButton

      TibiaRadioButton {
        id: allowSelectedGroupsRadioButton
        text: qsTrId("exivaoptions_allow_selected_groups")
        ButtonGroup.group: allowEveryoneExlusiveGroup
      } //TibiaRadioButton

      ColumnLayout {
        id: selectedGroupsLayout
        Layout.fillWidth: true
        Layout.leftMargin: TibiaStyle.paragraphIndentation
        spacing: TibiaStyle.marginRelated
        enabled: !allowEveryoneExlusiveGroup.allowEveryoneSelected

        TibiaMenuOptionCheckBox {
          id: allowGuild
          Layout.fillWidth: true
          text: qsTrId("exivaoptions_allow_guild")
          checked: controller != null && controller.allowGuild
          shouldBeChecked: controller != null && controller.allowGuild
          Binding {
            target: controller
            property: "allowGuild"
            value: allowGuild.checked
          } //Binding
        } //TibiaMenuOptionCheckBox

        TibiaMenuOptionCheckBox {
          id: allowParty
          Layout.fillWidth: true
          text: qsTrId("exivaoptions_allow_party")
          checked: controller != null && controller.allowParty
          shouldBeChecked: controller != null && controller.allowParty
          Binding {
            target: controller
            property: "allowParty"
            value: allowParty.checked
          } //Binding
        } //TibiaMenuOptionCheckBox

        TibiaMenuOptionCheckBox {
          id: allowVIPs
          Layout.fillWidth: true
          text: qsTrId("exivaoptions_allow_VIPs")
          checked: controller != null && controller.allowVIPs
          shouldBeChecked: controller != null && controller.allowVIPs
          Binding {
            target: controller
            property: "allowVIPs"
            value: allowVIPs.checked
          } //Binding
        } //TibiaMenuOptionCheckBox

        TibiaMenuOptionCheckBox {
          id: allowCharacterWhitelist
          Layout.fillWidth: true
          text: qsTrId("exivaoptions_allow_characterr_whitelist")
          checked: controller != null && controller.allowCharacterWhitelist
          shouldBeChecked: controller != null && controller.allowCharacterWhitelist
          Binding {
            target: controller
            property: "allowCharacterWhitelist"
            value: allowCharacterWhitelist.checked
          } //Binding
        } //TibiaMenuOptionCheckBox

        ColumnLayout {
          Layout.fillWidth: true
          Layout.leftMargin: TibiaStyle.paragraphIndentation

          TibiaText {
            Layout.fillWidth: true
            text: qsTrId("exivaoptions_character_whitelist_caption") + " " + qsTrId("edit_text_one_per_line")
          } //TibiaText

          TibiaTextArea {
            id: characterWhitelist
            Layout.fillWidth: true
            Layout.preferredHeight: 100
            KeyNavigation.tab: characterWhitelist
            textFormat: TextEdit.PlainText
            enabled: allowCharacterWhitelist.checked
            color: enabled ? TibiaStyle.textFieldTextColor
                           : TibiaStyle.textFieldDisabledTextColor
            maximumLength: 2200 //max 5000 byte in one client message so keep this low enpugh
          } //TibiaTextArea
        } //ColumnLayout

        TibiaMenuOptionCheckBox {
          id: allowGuildWhitelist
          Layout.fillWidth: true
          text: qsTrId("exivaoptions_allow_guild_whitelist")
          checked: controller != null && controller.allowGuildWhitelist
          shouldBeChecked: controller != null && controller.allowGuildWhitelist
          Binding {
            target: controller
            property: "allowGuildWhitelist"
            value: allowGuildWhitelist.checked
          } //Binding
        } //TibiaMenuOptionCheckBox

        ColumnLayout {
          Layout.fillWidth: true
          Layout.leftMargin: TibiaStyle.paragraphIndentation

          TibiaText {
            Layout.fillWidth: true
            text: qsTrId("exivaoptions_guild_whitelist_caption") + " " + qsTrId("edit_text_one_per_line")
          } //TibiaText

          TibiaTextArea {
            id: guildWhitelist
            Layout.fillWidth: true
            Layout.preferredHeight: 100
            KeyNavigation.tab: guildWhitelist
            textFormat: TextEdit.PlainText
            enabled: allowGuildWhitelist.checked
            color: enabled ? TibiaStyle.textFieldTextColor
                           : TibiaStyle.textFieldDisabledTextColor
            maximumLength: 2200 //max 5000 byte in one client message so keep this low enpugh
          } //TibiaTextArea
        } //ColumnLayout

        TibiaText {
          Layout.fillWidth: true
          text: qsTrId("exivaoptions_allow_guild_war_info")
          wrapMode: Text.Wrap
        } //TibiaText
      } //ColumnLayout
    } //ColumnLayout

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } //TibiaHorizontalSeparator

    RowLayout {
      Layout.alignment: Qt.AlignRight
      spacing: TibiaStyle.marginRelated

      Item {Layout.fillWidth: true}

      TibiaButton{
        id: okButton
        text: qsTrId("ok")
        onClicked: dialogRoot.onOkClicked()
      } //TibiaButton

      TibiaButton{
        id: applyButton
        text: qsTrId("apply")
        onClicked: dialogRoot.onApplyClicked()
      } //TibiaButton

      TibiaButton {
        id: closeButton
        text: qsTrId("close")
        onClicked: dialogRoot.onCloseClicked()
      } // TibiaButton
    } // RowLayout
  } // ColumnLayout

} // TibiaDialog
