import QtQuick
import QtQuick.Layouts
import qmlcomponents



TibiaDialog {
  id: root
  caption: qsTrId("confirm_move_to_stash_caption")
  implicitWidth: 400

  property var controller: null;

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
      text: qsTrId("confirm_move_to_stash_text")
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
         text: qsTrId("confirmation_do_not_show_again")
         shouldBeChecked: controller != null && !controller.showThisDialogAgain
      } //TibiaMenuOptionCheckBox

      Item {
        Layout.fillWidth: true
      } //Item

      TibiaButton {
        text: qsTrId("yes")
        onClicked: onReturnPressedFunction();
      } // TibiaButton

      TibiaButton {
        id: cancelButton
        text: qsTrId("no")

        onClicked: onCancelPressedFunction();
      } // TibiaButton
    } // RowLayout
  } // ColumnLayout
} // TibiaDialog
