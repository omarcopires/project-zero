import QtQuick
import QtQuick.Layouts



TibiaOptionsPage {
  id: root
  implicitHeight: contentLayout.height

  optionsSet: controller != null ? controller.consoleOptions : null

  ColumnLayout {
    id: contentLayout
    anchors { left: parent.left; top: parent.top; right: parent.right }
    spacing: TibiaStyle.marginRelated

    TibiaMenuOptionCheckBox {
      id: showInfoMessages
      text: qsTrId("optionsmenu_show_info_messagese")
      guiHelpText: qsTrId("optionsmenu_show_info_messages_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet && optionsSet.showInfoMessages
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.showInfoMessages = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: showEventMessages
      text: qsTrId("optionsmenu_show_event_messages")
      guiHelpText: qsTrId("optionsmenu_show_event_messages_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet && optionsSet.showEventMessages
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.showEventMessages = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: showStatusMessages
      text: qsTrId("optionsmenu_show_status_messages")
      guiHelpText: qsTrId("optionsmenu_show_status_messages_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet && optionsSet.showStatusMessages
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.showStatusMessages = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: showStatusMessagesOfOthers
      text: qsTrId("optionsmenu_show_other_status_messages")
      guiHelpText: qsTrId("optionsmenu_show_other_status_messages_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet && optionsSet.showStatusMessagesOfOthers
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.showStatusMessagesOfOthers = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: openNewPrivateMessagesInNewTab
      text: qsTrId("optionsmenu_open_new_private_messages_in_new_tab")
      guiHelpText: qsTrId("optionsmenu_open_new_private_messages_in_new_tab_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet && optionsSet.openNewPrivateMessagesInNewTab
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.openNewPrivateMessagesInNewTab = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: showTimestamps
      text: qsTrId("optionsmenu_show_timestamps")
      guiHelpText: qsTrId("optionsmenu_show_timestamps_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet && optionsSet.showTimestamps
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.showTimestamps = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: showTimestampsSeconds
      text: qsTrId("optionsmenu_show_timestamps_seconds")
      guiHelpText: qsTrId("optionsmenu_show_timestamps_seconds_help")
      Layout.fillWidth: true
      enabled: showTimestamps.checked
      shouldBeChecked: optionsSet && optionsSet.showTimestampsSeconds
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.showTimestampsSeconds = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: showLevels
      text: qsTrId("optionsmenu_show_levels")
      guiHelpText: qsTrId("optionsmenu_show_levels_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet && optionsSet.showLevels
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.showLevels = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox
  } //ColumnLayout
} //TibiaOptionsPage
