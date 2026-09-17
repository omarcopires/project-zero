import QtQuick
import QtQuick.Layouts



TibiaDialog {
  id: root
  caption: qsTrId("crashreport_dialog_caption")
  width: 620

  required property var controller

  onCancelPressedFunction: function() {
    root.sendReport(false)
  } //onCancelPressedFunction

  function sendReport(FullReport) {
   if (controller != null) {
      controller.sendReport(commentText.text, FullReport);
    }
  } //function sendReport

  initialFocusItem: commentText

  ColumnLayout {
    anchors { left: parent.left; right: parent.right; top: parent.top }
    spacing: TibiaStyle.marginUnrelated

    TibiaText {
      text: qsTrId("crashreport_dialog_description")
      Layout.fillWidth: true
      wrapMode: Text.Wrap
    } //TibiaText

    ColumnLayout {
      Layout.fillWidth: true
      spacing: TibiaStyle.marginRelated

      RowLayout {
        spacing: 0

        TibiaText {
          text: qsTrId("crashreport_dialog_basic_report_caption")
        } //TibiaText

        Item {
          Layout.fillWidth: true
        } //Item

        TibiaGuiHelp {
          text: qsTrId("crashreport_dialog_basic_report_description")
        } //TibiaGuiHelp
      } //RowLayout

      TibiaTextArea {
        Layout.fillWidth: true
        Layout.preferredHeight: 120
        wrapMode: Text.Wrap
        text: controller.minimalInformation
        readOnly: true
        KeyNavigation.tab: commentText
      } //TibiaTextArea

      TibiaText {
        text: qsTrId("crashreport_dialog_user_comment")
        Layout.fillWidth: true
        wrapMode: Text.Wrap
      } //TibiaText

      TibiaTextField {
        id: commentText
        Layout.fillWidth: true
        KeyNavigation.tab: commentText
        placeholderText: qsTrId("enter_comment")
        maximumLength: 1024
      } //TibiaTextField
    } //ColumnLayout

    ColumnLayout {
      Layout.fillWidth: true
      spacing: TibiaStyle.marginRelated

      RowLayout {
        spacing: 0

        TibiaText {
          text: qsTrId("crashreport_dialog_full_report_caption")
        } //TibiaText

        Item {
          Layout.fillWidth: true
        } //Item

        TibiaGuiHelp {
          text: qsTrId("crashreport_dialog_full_report_description")
        } //TibiaGuiHelp
      } //RowLayout

      TibiaText {
        text: qsTrId("crashreport_dialog_full_report_legal_info")
        Layout.fillWidth: true
        wrapMode: Text.Wrap
      } //TibiaText

      RowLayout {
        spacing: TibiaStyle.marginRelated
        visible: characterNameField.text.length > 0

        TibiaText {
          text: qsTrId("character") + ":"
        } //TibiaText

        TibiaTextField {
          id: characterNameField
          Layout.fillWidth: true
          readOnly: true
          text: controller.characterName
        } //TibiaTextField
      } //RowLayout

      TibiaTextArea {
        Layout.fillWidth: true
        Layout.preferredHeight: 100
        wrapMode: Text.Wrap
        text: controller.logMessages
        readOnly: true
        KeyNavigation.tab: commentText
      } //TibiaTextArea
    } //ColumnLayout

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } //TibiaHorizontalSeparator

    RowLayout {
      Layout.alignment: Qt.AlignRight
      spacing: TibiaStyle.marginRelated

      TibiaButton {
        Layout.preferredWidth: TibiaStyle.buttonWidthWider
        text: qsTrId("crashreport_dialog_send_full_report")

        onClicked: root.sendReport(true)
      } // TibiaButton

      TibiaButton {
        text: qsTrId("cancel")

        onClicked: root.onCancelPressedFunction();
      } // TibiaButton
    } // RowLayout
  } // ColumnLayout
} // TibiaDialog

