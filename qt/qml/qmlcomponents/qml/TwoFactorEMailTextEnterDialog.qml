import QtQuick
import QtQuick.Layouts



TibiaDialog {
  id: enterTextDialog
  caption: "Generic Text Input Dialog"
  width: Math.ceil(Math.max(360, captionContentWidth + 2*TibiaStyle.dialogMarginBorder))

  onWidthChanged: {
    enterTextDialog.centerDialog();
  } //onWidthChanged


  property QtObject controller: null
  property alias description: descriptionText.text
  property alias maxInputLength: enteredTextField.maximumLength
  property alias enteredText: enteredTextField.text
  property alias buttonDescription: buttonText.text
  property bool intOnly: false
  property bool buttonVisible: false
  property alias additionalInfo: additionalInfoText.text
  property bool additionalInfoTextVisible: false

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
        id: descriptionText
        Layout.fillWidth: true
        wrapMode: Text.Wrap
        text: "Description:"
        styleType: "Dialog"
      } //TibiaText
      
      TibiaTextField {
        id: enteredTextField
        Layout.fillWidth: true
        KeyNavigation.tab: enteredTextField
        focus: true
        property var numberVal: RegularExpressionValidator { regularExpression: /[0-9]{0,9}/; }
        validator: {
          if (enterTextDialog.intOnly) {
            return numberVal;
          }
          
          return null;
        }
      } //TibiaTextField

      TibiaText {
        id: additionalInfoText
        visible: additionalInfoTextVisible
        Layout.fillWidth: true
        wrapMode: Text.Wrap
      } // TibiaText
    } //ColumnLayout
    
    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } //TibiaHorizontalSeparator
    
    RowLayout {
      Layout.fillWidth: true
      spacing: TibiaStyle.marginUnrelated

      TibiaButton {
        id: buttonText
        visible: buttonVisible
        onClicked: controller!=null ?  controller.onButtonClicked() : undefined
        tooltipText: qsTrId("request_two_factor_email_code_request_new_code_button_tooltip")
      } // TibiaButton
      
      Item {
        Layout.fillWidth: true
      } //Item
    
      TibiaButton{
        id: okButton
        text: qsTrId("ok")
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
