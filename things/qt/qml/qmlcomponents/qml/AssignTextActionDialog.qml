import QtQuick
import QtQuick.Layouts
import qmlcomponents



TibiaDialog {
  id: dialogRoot
  caption: controller != null
          ? (controller.showActionBarTarget ? qsTrId("actionbar_assign_text_dialog_caption").arg(actionBarName) : qsTrId("actionbar_assign_text_dialog_caption_short"))
          : qsTrId("dummy_unknown")
  width: 275

  property var controller: null
  property string actionBarName: controller != null ? controller.buttonName : qsTrId("actionbar_button_identifier").arg(0).arg(0)

  onReturnPressedFunction: okClicked
  onCancelPressedFunction: closeClicked
  initialFocusItem: textInput

  function okClicked() {
    if (controller != null && textInput.text != "") {
      controller.onOkClicked(textInput.text, sendAutomatically.checked);
    }
  } //function okClicked

  function assignText() {
    if (controller != null && textInput.text != "") {
      controller.onApplyClicked(textInput.text, sendAutomatically.checked);
    }
  } //function assignText

  function closeClicked() {
    if (controller != null) {
      controller.onCloseClicked();
    }
  } //function closeClicked


  ColumnLayout {
    anchors { left: parent.left; right: parent.right }
    spacing: TibiaStyle.marginUnrelated

    ColumnLayout {
      Layout.fillWidth: true
      spacing: TibiaStyle.marginRelated

      TibiaText {
        text: qsTrId("text_caption")
      } //TibiaText

      TibiaTextField {
        id: textInput
        KeyNavigation.tab: textInput
        Layout.fillWidth: true
        text: controller != null ? controller.text : ""
        maximumLength: TibiaStyle.chatInputMaxLength
      } //TibiaTextField

      TibiaMenuOptionCheckBox {
        id: sendAutomatically
        Layout.fillWidth: true
        text: qsTrId("hotkeys_send_automatically")

        checked: controller != null && controller.sendAutomatically
      } //TibiaMenuOptionCheckBox
    } //ColumnLayout

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } //TibiaHorizontalSeparator

    RowLayout {
      Layout.alignment: Qt.AlignRight
      spacing: TibiaStyle.marginRelated

      Item {Layout.fillWidth: true}

      TibiaButton {
        text: qsTrId("ok")
        enabled: textInput.text != ""
        onClicked: dialogRoot.okClicked();
      } // TibiaButton

      TibiaButton {
        text: qsTrId("apply")
        enabled: textInput.text != ""
        onClicked: dialogRoot.assignText();
      } // TibiaButton

      TibiaButton {
        text: qsTrId("cancel")
        onClicked: dialogRoot.closeClicked();
      } // TibiaButton
    } // RowLayout
  } // ColumnLayout
} // TibiaDialog
