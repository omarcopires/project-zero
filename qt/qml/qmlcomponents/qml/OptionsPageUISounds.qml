import QtQuick
import QtQuick.Layouts




TibiaOptionsPage {
  id: root
  implicitHeight: contentLayout.height

  optionsSet: controller != null ? controller.uiSoundsOptions : null
  property QtObject optionsSetSound: controller != null ? controller.soundOptions : null

  ColumnLayout {
    id: contentLayout
    anchors { left: parent.left; top: parent.top; right: parent.right }
    spacing: TibiaStyle.marginRelated

    TibiaText {
      Layout.fillWidth: true
      styleType: "MessageWarning"
      visible: optionsSetSound != null && !optionsSetSound.soundEnabled

      text: qsTrId("optionsmenu_sound_disabled_warning").arg(qsTrId("optionsmenu_sound"))
    } //TibiaText

    TibiaMenuSlider {
      Layout.fillWidth: true
      disabled: optionsSetSound != null && !optionsSetSound.soundEnabled

      text: qsTrId("optionsmenu_sound_ui_volume")
      withFrame: true
      unitSymbol: "%"
      minimumValue: 0
      maximumValue: 100
      offAtMinimum: true
      stepSize: 1
      shouldBeValue: optionsSet != null ? optionsSet.uiVolume : 0
      onValueChanged: {
        if (optionsSet != null) {
          optionsSet.uiVolume = value;
        }
      } //onValueChanged
    } //TibiaMenuSlider

    ColumnLayout {
      id: subLayout
      spacing: TibiaStyle.marginRelated
      property bool disabled: (optionsSet != null && optionsSet.uiVolume == 0)
                          ||  (optionsSetSound != null && !optionsSetSound.soundEnabled)


      TibiaMenuOptionCheckBox {
        text: qsTrId("optionsmenu_sound_ui_interactions_enabled")
        Layout.fillWidth: true
        enabled: !subLayout.disabled
        shouldBeChecked: optionsSet != null && optionsSet.uiInteractionsEnabled
        onCheckedChanged: {
          if (optionsSet != null) {
            optionsSet.uiInteractionsEnabled = checked;
          }
        } //onCheckedChanged
      } //TibiaMenuOptionCheckBox

      TibiaFrame1PixelDownWithGuiHelp {
        Layout.fillWidth: true
        Layout.preferredHeight: playerStatusLayout.height + 2 * marginsToContent
        guiHelpUseRichText: true
        //guiHelpText: qsTrId("optionsmenu_player_hud_help")

        ColumnLayout {
          id: playerStatusLayout
          anchors { left: parent.left; top: parent.top; right: parent.right }
          anchors.margins: parent.marginsToContent
          spacing: TibiaStyle.marginRelated
          enabled: !subLayout.disabled

          TibiaCheckBox {
            text: qsTrId("optionsmenu_sound_party_enabled")
            Layout.topMargin: -1 //checkbox text height is one higher than the checbox icon
            shouldBeChecked: optionsSet != null && optionsSet.partyEnabled
            onCheckedChanged: {
              if (optionsSet != null) {
                optionsSet.partyEnabled = checked;
              }
            } //onCheckedChanged
          } //TibiaCheckBox

          TibiaCheckBox {
            text: qsTrId("optionsmenu_sound_vip_enabled")
            Layout.topMargin: -1 //checkbox text height is one higher than the checbox icon
            shouldBeChecked: optionsSet != null && optionsSet.vipEnabled
            onCheckedChanged: {
              if (optionsSet != null) {
                optionsSet.vipEnabled = checked;
              }
            } //onCheckedChanged
          } //TibiaCheckBox
        } //ColumnLayout
      } //TibiaFrame1PixelDownWithGuiHelp

      TibiaFrame1PixelDownWithGuiHelp {
        Layout.fillWidth: true
        Layout.preferredHeight: chatLayout.height + 2 * marginsToContent
        guiHelpUseRichText: true

        ColumnLayout {
          id: chatLayout
          anchors { left: parent.left; top: parent.top; right: parent.right }
          anchors.margins: parent.marginsToContent
          spacing: TibiaStyle.marginRelated

          TibiaCheckBox {
            text: qsTrId("optionsmenu_sound_chat_enabled")
            Layout.topMargin: -1 //checkbox text height is one higher than the checbox icon
            enabled: !subLayout.disabled
            shouldBeChecked: optionsSet != null && optionsSet.chatEnabled
            onCheckedChanged: {
              if (optionsSet != null) {
                optionsSet.chatEnabled = checked;
              }
            } //onCheckedChanged
          } //TibiaCheckBox

          ColumnLayout {
            id: chatSubLayout
            Layout.leftMargin: TibiaStyle.paragraphIndentation
            spacing: TibiaStyle.marginRelated
            property bool disabled: optionsSet != null && !optionsSet.chatEnabled
                                 || subLayout.disabled

            TibiaCheckBox {
              text: qsTrId("optionsmenu_sound_party_messages_enabled")
              Layout.topMargin: -1 //checkbox text height is one higher than the checbox icon
              enabled: !chatSubLayout.disabled
              shouldBeChecked: optionsSet != null && optionsSet.partyMessagesEnabled
              onCheckedChanged: {
                if (optionsSet != null) {
                  optionsSet.partyMessagesEnabled = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckBox

            TibiaCheckBox {
              text: qsTrId("optionsmenu_sound_guild_messages_enabled")
              Layout.topMargin: -1 //checkbox text height is one higher than the checbox icon
              enabled: !chatSubLayout.disabled
              shouldBeChecked: optionsSet != null && optionsSet.guildMessagesEnabled
              onCheckedChanged: {
                if (optionsSet != null) {
                  optionsSet.guildMessagesEnabled = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckBox

            TibiaCheckBox {
              text: qsTrId("optionsmenu_sound_private_messages_without_tab_enabled").arg(qsTrId("chat_channel_name_local_chat"))
              Layout.topMargin: -1 //checkbox text height is one higher than the checbox icon
              enabled: !chatSubLayout.disabled
              shouldBeChecked: optionsSet != null && optionsSet.privateMessagesWithoutTabEnabled
              onCheckedChanged: {
                if (optionsSet != null) {
                  optionsSet.privateMessagesWithoutTabEnabled = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckBox

            RowLayout {
              spacing: TibiaStyle.marginRelated

              TibiaCheckBox {
                text: qsTrId("optionsmenu_sound_private_messages_enabled")
                Layout.topMargin: -1 //checkbox text height is one higher than the checbox icon
                enabled: !chatSubLayout.disabled
                shouldBeChecked: optionsSet != null && optionsSet.privateMessagesEnabled
                onCheckedChanged: {
                  if (optionsSet != null) {
                    optionsSet.privateMessagesEnabled = checked;
                  }
                } //onCheckedChanged
              } //TibiaCheckBox

              Item { Layout.fillWidth: true }

              TibiaGuiHelp {
                text: qsTrId("optionsmenu_sound_private_messages_info")
              } //TibiaGuiHelp
            } //RowLayout

            TibiaCheckBox {
              text: qsTrId("chat_channel_name_npcs")
              Layout.topMargin: -1 //checkbox text height is one higher than the checbox icon
              enabled: !chatSubLayout.disabled
              shouldBeChecked: optionsSet != null && optionsSet.npcMessageseEnabled
              onCheckedChanged: {
                if (optionsSet != null) {
                  optionsSet.npcMessageseEnabled = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckBox

            RowLayout {
              spacing: TibiaStyle.marginRelated

              TibiaCheckBox {
                text: qsTrId("optionsmenu_sound_global_messages_enabled")
                Layout.topMargin: -1 //checkbox text height is one higher than the checbox icon
                enabled: !chatSubLayout.disabled
                shouldBeChecked: optionsSet != null && optionsSet.globalMessagesEnabled
                onCheckedChanged: {
                  if (optionsSet != null) {
                    optionsSet.globalMessagesEnabled = checked;
                  }
                } //onCheckedChanged
              } //TibiaCheckBox

              Item { Layout.fillWidth: true }

              TibiaGuiHelp {
                text: qsTrId("optionsmenu_sound_global_message_info")
              } //TibiaGuiHelp
            } //RowLayout

            TibiaCheckBox {
              text: qsTrId("optionsmenu_sound_team_finder_messages_enabled")
              Layout.topMargin: -1 //checkbox text height is one higher than the checbox icon
              enabled: !chatSubLayout.disabled
              shouldBeChecked: optionsSet != null && optionsSet.teamFinderMessagesEnabled
              onCheckedChanged: {
                if (optionsSet != null) {
                  optionsSet.teamFinderMessagesEnabled = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckBox

            TibiaCheckBox {
              text: qsTrId("optionsmenu_sound_raid_messages_enabled")
              Layout.topMargin: -1 //checkbox text height is one higher than the checbox icon
              enabled: !chatSubLayout.disabled
              shouldBeChecked: optionsSet != null && optionsSet.raidMessagesEnabled
              onCheckedChanged: {
                if (optionsSet != null) {
                  optionsSet.raidMessagesEnabled = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckBox

            RowLayout {
              spacing: TibiaStyle.marginRelated

              TibiaCheckBox {
                text: qsTrId("optionsmenu_sound_system_messages_enabled")
                Layout.topMargin: -1 //checkbox text height is one higher than the checbox icon
                enabled: !chatSubLayout.disabled
                shouldBeChecked: optionsSet != null && optionsSet.systemMessagesEnabled
                onCheckedChanged: {
                  if (optionsSet != null) {
                    optionsSet.systemMessagesEnabled = checked;
                  }
                } //onCheckedChanged
              } //TibiaCheckBox

              Item { Layout.fillWidth: true }

              TibiaGuiHelp {
                text: qsTrId("optionsmenu_sound_system_messages_info")
              } //TibiaGuiHelp
            } //RowLayout
          } //ColumnLayout
        } //ColumnLayout
      } //TibiaFrame1PixelDownWithGuiHelp
    } //ColumnLayout
  } //ColumnLayout
} //TibiaOptionsPage
