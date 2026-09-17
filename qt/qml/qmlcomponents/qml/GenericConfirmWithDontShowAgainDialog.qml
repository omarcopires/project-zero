import QtQuick
import QtQuick.Layouts

TibiaDialog {
  id: root
  property var controller: null;
  property string captionText: controller != null ? controller.captionText : ""
  property string contentText: controller != null ? controller.contentText : ""
  property string dontShowAgainText: controller != null ? controller.dontShowAgainText : ""

  caption: captionText
  implicitWidth: 400


  onReturnPressedFunction: function() {
    if (controller != null) {
      controller.onYesClicked(!dontAskAgainCheckbox.checked);
    }
  } //onReturnPressedFunction

  onCancelPressedFunction: function() {
    if (controller != null) {
      controller.onNoClicked();
    }
  } //onCancelPressedFunction

  initialFocusItem: root
  KeyNavigation.tab: root

  ColumnLayout {
    anchors { left: parent.left; right: parent.right; top: parent.top }
    spacing: TibiaStyle.marginUnrelated

    TibiaText {
      Layout.fillWidth: true
      text: root.contentText
      wrapMode: Text.Wrap
    } // TibiaText

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } // TibiaHorizontalSeparator

    RowLayout {
      Layout.fillWidth: true
      spacing: TibiaStyle.marginRelated

       TibiaMenuOptionCheckBox {
         id: dontAskAgainCheckbox
         text: root.dontShowAgainText
         shouldBeChecked: root.controller != null && !root.controller.showThisDialogAgain
      } //TibiaMenuOptionCheckBox

      Item {
        Layout.fillWidth: true
      } //Item

      TibiaButton {
        text: qsTrId("yes")
        onClicked: root.onReturnPressedFunction();
      } // TibiaButton

      TibiaButton {
        id: cancelButton
        text: qsTrId("no")

        onClicked: root.onCancelPressedFunction();
      } // TibiaButton
    } // RowLayout
  } // ColumnLayout
} // TibiaDialog
