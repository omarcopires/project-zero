import QtQuick
import QtQuick.Layouts



TibiaDialog {
  id: recordKeyboardShortcutDialog
  caption: qsTrId("edit_hotkey_caption").arg(actionDescription)
  width: 400

  property var controller: null;

  property string keySequence: controller != null ? controller.keySequence : "<Empty>"
  property bool keySequenceOccupied: controller != null ? controller.keySequenceOccupied : true
  property bool keySequenceHardcoded: controller != null ? controller.keySequenceHardcoded : true
  property string actionDescription: controller != null ? controller.actionDescription : ""
  property string chatMode: controller != null ? (controller.chatModeOn ? "Chat On" : "Chat Off") : "<error>"
  property bool onlySingleKey: controller != null ? controller.onlySingleKey : false

  initialFocusItem: recordKeyboardShortcutDialog
  KeyNavigation.tab: recordKeyboardShortcutDialog

  ColumnLayout {
    anchors { left: parent.left; right: parent.right; top: parent.top }
    spacing: TibiaStyle.marginUnrelated

    TibiaText {
      text: qsTrId("edit_hotkey_chatmode").arg(chatMode)
      Layout.alignment: Qt.AlignHCenter
    } //TibiaText

    TibiaFrame1PixelDown {
      Layout.fillWidth: true
      Layout.preferredHeight: infoLayout.height

      ColumnLayout {
        id: infoLayout
        anchors { left: parent.left; right: parent.right; top: parent.top;
                  leftMargin: TibiaStyle.marginUnrelated; rightMargin: TibiaStyle.marginUnrelated }
        spacing: TibiaStyle.marginRelated

        TibiaText {
          text: keySequence
          Layout.alignment: Qt.AlignHCenter
          Layout.topMargin: TibiaStyle.marginUnrelated
          Layout.bottomMargin: TibiaStyle.marginUnrelated
        } //TibiaText
      } // ColumnLayout
    } // TibiaFrame1PixelDown

    TibiaText {
      text: qsTrId("edit_hotkey_text").arg(actionDescription)
       + (onlySingleKey ? "\n\n" + qsTrId("only_single_keys_allowed") : "")
      Layout.alignment: Qt.AlignHCenter
      Layout.fillWidth: true
      wrapMode: Text.Wrap
    } //TibiaText

    TibiaText {
      text: keySequenceHardcoded ? qsTrId("hotkey_already_in_use_hardcoded") : (keySequenceOccupied ? qsTrId("hotkey_already_in_use") : "")
      Layout.alignment: Qt.AlignHCenter
      color: TibiaStyle.red1
      opacity: (keySequenceOccupied | keySequenceHardcoded) ? 1 : 0
    } //TibiaText

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } //TibiaHorizontalSeparator

    RowLayout {
      Layout.alignment: Qt.AlignRight

      TibiaButton {
        Layout.alignment: Qt.AlignRight
        text: qsTrId("ok")
        enabled: !keySequenceHardcoded

        onClicked: {
          if (controller != null) {
            controller.onOkButtonClicked();
          }
        } // onClicked
      } //TibiaButton

      TibiaButton {
        Layout.alignment: Qt.AlignRight
        text: qsTrId("clear")

        onClicked: {
          if (controller != null) {
            controller.onClearButtonClicked();
          }
        } // onClicked
      } //TibiaButton

      TibiaButton {
        Layout.alignment: Qt.AlignRight
        text: qsTrId("cancel")

        onClicked: {
          if (controller != null) {
            controller.onCancelButtonClicked();
          }
        } // onClicked
      } //TibiaButton
    } // RowLayout
  } // ColumnLayout
} // TibiaDialog
