import QtQuick

TextInput {
  id: textInput
  property bool contextMenuEnabled: true
  readonly property bool hasSelection: selectedText.length > 0

  font: TibiaStyle.defaultTextFont
  color: enabled ? TibiaStyle.textFieldTextColor : TibiaStyle.textFieldDisabledTextColor
  selectedTextColor: TibiaStyle.textFieldSelectionTextColor
  selectionColor: TibiaStyle.textFieldSelectionColor
  verticalAlignment: TextInput.AlignVCenter

  selectByMouse : true

  onTextChanged: {
    var modifiedText = text.replace(TibiaStyle.regExpSingleNonASCIIChar,"?");
    if (text != modifiedText) {
      var savedCursorPosition = cursorPosition;
      text = modifiedText;
      cursorPosition = savedCursorPosition;
    }
  } // onTextChanged

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.RightButton

    onClicked: {
      if (textInput.contextMenuEnabled && tibiaContextMenuController != null) {
        tibiaContextMenuController.showContextMenuForTextInputQmlItem(textInput);
      }
    } //onClicked
  } // MouseArea

  Keys.onPressed: (event) => {
    if(typeof tibiaTextCopyController === 'undefined' || tibiaTextCopyController == null) {
      return;
    }

    if((event.key == Qt.Key_C) && (event.modifiers & Qt.ControlModifier)) { //CTR+C
      tibiaTextCopyController.copyFromTextInputQmlItemIfPossible(textInput);
      event.accepted = true;
    } else if((event.key == Qt.Key_X) && (event.modifiers & Qt.ControlModifier)) { //CTR+X
      tibiaTextCopyController.cutFromTextInputQmlItemIfPossible(textInput);
      event.accepted = true;
    }
  } //Keys.onPressed
} //TextField
