import QtQuick
import QtQuick.Layouts

import qmlcomponents


TibiaOptionsPage {
  id: root
  implicitHeight: contentLayout.height

  optionsSet: controller != null ? controller.interfaceOptions : null

  ColumnLayout {
    id: contentLayout
    anchors { left: parent.left; top: parent.top; right: parent.right }
    spacing: TibiaStyle.marginRelated

    TibiaMenuOptionCheckBox {
      id: highlightMouseTarget
      text: qsTrId("optionsmenu_highlight_object_mouse_target")
      guiHelpText: qsTrId("optionsmenu_highlight_object_mouse_target_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet && optionsSet.highlightMouseTarget
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.highlightMouseTarget = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: systemCursor
      text: qsTrId("optionsmenu_system_cursor")
      guiHelpText: qsTrId("optionsmenu_system_cursor_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet && optionsSet.systemCursor
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.systemCursor = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: animatedMouseCursor
      text: qsTrId("optionsmenu_animated_mouse_cursor")
      guiHelpText: qsTrId("optionsmenu_animated_mouse_cursor_help")
      guiHelpUseRichText: true
      Layout.fillWidth: true
      shouldBeChecked: optionsSet && optionsSet.animatedMouseCursor
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.animatedMouseCursor = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: bigMouseCursor
      text: qsTrId("optionsmenu_big_mouse_cursor")
      guiHelpText: qsTrId("optionsmenu_big_mouse_cursor_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet && optionsSet.bigMouseCursor
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.bigMouseCursor = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: showCooldownBar
      text: qsTrId("optionsmenu_show_cooldown_bar")
      guiHelpText: qsTrId("optionsmenu_show_cooldown_bar_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet && optionsSet.showCooldownBar
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.showCooldownBar = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: showLinkCopyWarning
      text: qsTrId("optionsmenu_show_link_copy_warning")
      guiHelpText: qsTrId("optionsmenu_show_link_copy_warning_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet && optionsSet.showLinkCopyWarning
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.showLinkCopyWarning = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaFrame1PixelDownWithGuiHelp {
      Layout.fillWidth: true
      Layout.preferredHeight: expireInformationOptions.height + 2 * marginsToContent

      ColumnLayout {
        id: expireInformationOptions
        anchors { left: parent.left; top: parent.top; right: parent.right }
        anchors.margins: parent.marginsToContent
        spacing: TibiaStyle.marginRelated

        RowLayout {
          Layout.fillWidth: true
          spacing: TibiaStyle.marginRelated

          TibiaText{
            id: colorizeLootLabel
            text: qsTrId("optionsmenu_colorize_loot")
          } //TibiaText

          TibiaComboBox {
            id: comboBoxColorizeLootStyle
            Layout.preferredWidth: TibiaStyle.comboboxOptionsWidth
            Layout.preferredHeight: TibiaStyle.comboBoxHeight

            model: optionsSet != null ? optionsSet.colorizeLootStyleListModel : null

            shouldBeCurrentIndex: optionsSet != null ? optionsSet.colorizeLootStyleIndex : 0
            onCurrentIndexChanged: {
              if (optionsSet != null) {
                optionsSet.colorizeLootStyleIndex = currentIndex;
              }
            } //onCurrentIndexChanged

          } //ComboBox

          Item {
            Layout.fillWidth: true
          } //Item

          TibiaGuiHelp {
            visible: text != ""
            text: qsTrId("optionsmenu_colorize_loot_help")
          } //TibiaGuiHelp
        } //RowLayout

        RowLayout {
          Layout.topMargin: -1 //checkbox text height is one higher than the checbox icon
          spacing: TibiaStyle.marginRelated

          TibiaCheckBox {
            id: expireInInventory
            text: qsTrId("optionsmenu_expireininventory_enabled")
            Layout.fillWidth: true
            shouldBeChecked: optionsSet != null && optionsSet.showExpireInInventory
            onCheckedChanged: {
              if (optionsSet != null) {
                optionsSet.showExpireInInventory = checked;
              }
            } //onCheckedChanged
          } //TibiaCheckBox

          TibiaGuiHelp {
            text: qsTrId("optionsmenu_expireininventory_help")
          } //TibiaGuiHelp
        } //RowLayout

        RowLayout {
          Layout.topMargin: -1 //checkbox text height is one higher than the checbox icon
          spacing: TibiaStyle.marginRelated

          TibiaCheckBox {
            id: expireInContainers
            text: qsTrId("optionsmenu_expireincontainers_enabled")
            Layout.fillWidth: true
            shouldBeChecked: optionsSet != null && optionsSet.showExpireInContainers
            onCheckedChanged: {
              if (optionsSet != null) {
                optionsSet.showExpireInContainers = checked;
              }
            } //onCheckedChanged
          } //TibiaCheckBox

          TibiaGuiHelp {
            text: qsTrId("optionsmenu_expireincontainers_help")
          } //TibiaGuiHelp
        } //RowLayout

        RowLayout {
          Layout.topMargin: -1 //checkbox text height is one higher than the checbox icon
          spacing: TibiaStyle.marginRelated

          TibiaCheckBox {
            id: expireWhenUnused
            text: qsTrId("optionsmenu_expirewhenunused_enabled")
            Layout.fillWidth: true
            shouldBeChecked: optionsSet != null && optionsSet.showExpireWhenUnused
            enabled: expireInInventory.checked || expireInContainers.checked
            onCheckedChanged: {
              if (optionsSet != null) {
                optionsSet.showExpireWhenUnused = checked;
              }
            } //onCheckedChanged
          } //TibiaCheckBox

          TibiaGuiHelp {
            text: qsTrId("optionsmenu_expirewhenunused_help")
          } //TibiaGuiHelp
        } //RowLayout

      } //ColumnLayout
    } //TibiaFrame1PixelDownWithGuiHelp
  } //ColumnLayout
} //TibiaOptionsPage
