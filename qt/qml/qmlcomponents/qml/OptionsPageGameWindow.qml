import QtQuick
import QtQuick.Layouts



TibiaOptionsPage {
  id: root
  implicitHeight: contentLayout.height

  optionsSet: controller != null ? controller.gameWindowOptions : null

  ColumnLayout {
    id: contentLayout
    anchors { left: parent.left; top: parent.top; right: parent.right }
    spacing: TibiaStyle.marginRelated - 1

    TibiaMenuOptionCheckBox {
      id: showTextualEffects
      text: qsTrId("optionsmenu_show_text_effects")
      guiHelpText: qsTrId("optionsmenu_show_text_effects_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet && optionsSet.showTextualEffects
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.showTextualEffects = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: showMessages
      text: qsTrId("optionsmenu_show_messages")
      guiHelpText: qsTrId("optionsmenu_show_messages_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet && optionsSet.showMessages
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.showMessages = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: showPrivateMessages
      text: qsTrId("optionsmenu_show_private_messages")
      guiHelpText: qsTrId("optionsmenu_show_private_messages_help")
      Layout.fillWidth: true
      enabled: showMessages.checked
      shouldBeChecked: optionsSet && optionsSet.showPrivateMessages
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.showPrivateMessages = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: showPotionMessages
      text: qsTrId("optionsmenu_show_potion_messages")
      guiHelpText: qsTrId("optionsmenu_show_potion_messages_help")
      Layout.fillWidth: true
      enabled: showMessages.checked
      shouldBeChecked: optionsSet && optionsSet.showPotionMessages
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.showPotionMessages = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: showOwnSpells
      text: qsTrId("optionsmenu_show_own_spells")
      guiHelpText: qsTrId("optionsmenu_show_own_spells_help")
      Layout.fillWidth: true
      enabled: showMessages.checked
      shouldBeChecked: optionsSet && optionsSet.showOwnSpells
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.showOwnSpells = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: showOthersSpells
      text: qsTrId("optionsmenu_show_others_spells")
      guiHelpText: qsTrId("optionsmenu_show_others_spells_help")
      Layout.fillWidth: true
      enabled: showMessages.checked
      shouldBeChecked: optionsSet && optionsSet.showOthersSpells
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.showOthersSpells = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: showHotkeyUsage
      text: qsTrId("optionsmenu_show_hotkey_usage")
      guiHelpText: qsTrId("optionsmenu_show_hotkey_usage_help")
      Layout.fillWidth: true
      enabled: showMessages.checked
      shouldBeChecked: optionsSet && optionsSet.showHotkeyUsageMessages
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.showHotkeyUsageMessages = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: showLootMessages
      text: qsTrId("optionsmenu_show_loot_messages")
      guiHelpText: qsTrId("optionsmenu_show_loot_messages_help")
      Layout.fillWidth: true
      enabled: showMessages.checked
      shouldBeChecked: optionsSet && optionsSet.showLootMessages
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.showLootMessages = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: showLootHighlighting
      text: qsTrId("optionsmenu_show_loot_highlighting")
      guiHelpText: qsTrId("optionsmenu_show_loot_highlighting_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet && optionsSet.showLootHighlighting
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.showLootHighlighting = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: showBoostedCreatureMessages
      text: qsTrId("optionsmenu_show_boosted_creature_messages")
      guiHelpText: qsTrId("optionsmenu_show_boosted_creature_messages_help")
      Layout.fillWidth: true
      enabled: showMessages.checked
      shouldBeChecked: optionsSet && optionsSet.showBoostedCreatureMessages
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.showBoostedCreatureMessages = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: showOfflineTrainingMessages
      text: qsTrId("optionsmenu_show_offline_training_messages")
      guiHelpText: qsTrId("optionsmenu_show_offline_training_messages_help")
      Layout.fillWidth: true
      enabled: showMessages.checked
      shouldBeChecked: optionsSet && optionsSet.showOfflineTrainingMessages
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.showOfflineTrainingMessages = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: showStoreMessages
      text: qsTrId("optionsmenu_show_store_messages")
      guiHelpText: qsTrId("optionsmenu_show_store_messages_help")
      Layout.fillWidth: true
      enabled: showMessages.checked
      shouldBeChecked: optionsSet && optionsSet.showStoreMessages
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.showStoreMessages = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: showFrames
      text: qsTrId("optionsmenu_show_frames")
      guiHelpText: qsTrId("optionsmenu_show_frames_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet && optionsSet.showFrames
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.showFrames = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: showFramesPvp
      text: qsTrId("optionsmenu_show_frames_pvp")
      guiHelpText: qsTrId("optionsmenu_show_frames_pvp_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet && optionsSet.showFramesPvp
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.showFramesPvp = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: showShowAttackAnimation
      text: qsTrId("optionsmenu_show_attack_animation")
      guiHelpText: qsTrId("optionsmenu_show_attack_animation_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet && optionsSet.showAttackAnimation
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.showAttackAnimation = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: showShowInfoBanner
      text: qsTrId("optionsmenu_show_info_banner")
      guiHelpText: qsTrId("optionsmenu_show_info_banner_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet && optionsSet.showInfoBanner
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.showInfoBanner = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    RowLayout {
      Layout.fillWidth: true
      spacing: TibiaStyle.marginRelated

      TibiaText{
        text: qsTrId("optionsmenu_show_target_frame")
      } //TibiaText

      TibiaComboBox {
        id: showTargetFrameBox
        Layout.preferredWidth: TibiaStyle.comboboxOptionsWidth
        Layout.preferredHeight: TibiaStyle.comboBoxHeight

        // Indices into the model
        readonly property int targetFrameAndHighlight: 0
        readonly property int targetFrameOnly: 1
        readonly property int targetHighlightOnly: 2
        readonly property int targetNoMarker: 3

        model: [
          qsTrId("optionsmenu_show_target_frame_and_highlight"),
          qsTrId("optionsmenu_show_target_frame_only"),
          qsTrId("optionsmenu_show_target_highlight_only"),
          qsTrId("optionsmenu_show_target_nothing")
        ]

        shouldBeCurrentIndex: {
          if (optionsSet != null) {
            if (optionsSet.showTargetFrame && optionsSet.showTargetHighlight) {
              return targetFrameAndHighlight;
            } else if (optionsSet.showTargetFrame && !optionsSet.showTargetHighlight) {
              return targetFrameOnly;
            } else if (!optionsSet.showTargetFrame && optionsSet.showTargetHighlight) {
              return targetHighlightOnly;
            } else {
              return targetNoMarker;
            }
          }
          return targetFrameAndHighlight;
        }
        onCurrentIndexChanged: {
          if (optionsSet != null) {
            let showTargetFrame = currentIndex == targetFrameAndHighlight || currentIndex == targetFrameOnly;
            let showTargetHighlight = currentIndex == targetFrameAndHighlight || currentIndex == targetHighlightOnly;
            optionsSet.setShowTargetFrameHighlight(showTargetFrame, showTargetHighlight);
          }
        } //onCurrentIndexChanged
      } //ComboBox

      Item {
        Layout.fillWidth: true
      } //Item

      TibiaGuiHelp {
        Layout.rightMargin: TibiaStyle.marginRelated
        visible: text != ""
        text: qsTrId("optionsmenu_show_target_frame_help")
      } //TibiaGuiHelp

    } //RowLayout
  } //ColumnLayout
} //TibiaOptionsPage
