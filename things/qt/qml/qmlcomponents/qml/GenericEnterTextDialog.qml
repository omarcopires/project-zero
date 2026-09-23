import QtQuick
import QtQuick.Layouts



TibiaDialog {
  id: root
  caption: controller != null ? controller.caption : qsTrId("dummy_unknown")
  width: dialogWidth > 0 ? dialogWidth : Math.ceil(Math.max(360, captionContentWidth + 2*TibiaStyle.dialogMarginBorder))

  onWidthChanged: {
    root.centerDialog();
  } //onWidthChanged


  property QtObject controller: null

  readonly property bool intOnly: controller != null && controller.intOnly
  readonly property int dialogWidth: controller !=null ? controller.dialogWidth : -1

  function sendEnteredText() {
    if(null != controller) {
      controller.onOkClicked(enteredTextField.text);
    }
  } //function sendEnteredText()


  onReturnPressedFunction: sendEnteredText
  onCancelPressedFunction: controller!=null ? controller.onCancelClicked : null
  initialFocusItem: enteredTextField

  ColumnLayout {
    id: columns
    anchors { left: parent.left; right: parent.right}
    spacing: TibiaStyle.marginUnrelated

    ColumnLayout {
      spacing: TibiaStyle.marginRelated
      Layout.fillWidth: true

      TibiaText {
        Layout.fillWidth: true
        wrapMode: Text.Wrap
        text: controller != null ? controller.description : "Description:"
      } //TibiaText

      TibiaTextField {
        id: enteredTextField
        Layout.fillWidth: true
        KeyNavigation.tab: enteredTextField
        focus: true

        maximumLength: controller != null ? controller.maxInputLength : -1
        shouldBeText: controller != null ? (root.intOnly && controller.enteredText != "" ? Number(controller.enteredText).toString(10) : controller.enteredText) : ""
        readOnly: controller != null && controller.readOnly

        property var numberVal: RegularExpressionValidator { regularExpression: /[0-9]{0,9}/; }
        validator: {
          if (root.intOnly) {
            return numberVal;
          }

          return null;
        }
      } //TibiaTextField
    } //ColumnLayout

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } //TibiaHorizontalSeparator

    RowLayout {
      Layout.fillWidth: true
      spacing: TibiaStyle.marginUnrelated

      Item {
        Layout.fillWidth: true
      } //Item

      TibiaButton{
        id: okButton
        text: controller != null ? controller.confirmLable :  qsTrId("ok")
        onClicked: { sendEnteredText(); }
      } //TibiaButton

      TibiaButton{
        id: cancelButton
        text: qsTrId("cancel")
        onClicked: controller!=null ?  controller.onCancelClicked() : undefined
      } //TibiaButton
    } //RowLayout

  }//ColumnLayout
} //TibiaDialog
