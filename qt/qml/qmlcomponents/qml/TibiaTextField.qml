import QtQuick
import QtQuick.Controls.Basic

TextField {
  id: textField
  implicitHeight: TibiaStyle.textFieldHeight
  leftPadding: TibiaStyle.marginRelated
  rightPadding: TibiaStyle.marginNarrow
  topPadding: 2
  bottomPadding: text.length == 0 ? 3 : 2 // Placeholder text somehow needs more bottom padding

  property bool contextMenuEnabled: true
  readonly property bool hasSelection: selectedText.length > 0
  property bool allowNewline: false
  property bool allowSpaces: true

  property string shouldBeText: ""
  onShouldBeTextChanged: {
    if (text != shouldBeText) {
      text = shouldBeText;
    }
  } //onShouldBeTextChanged

  background: Item {
    Rectangle {
      anchors.fill: parent
      color: TibiaStyle.textFieldBackgroundColor
    } //Rectangle

    TibiaFrame1PixelDown {
      id: backgroundImage
      anchors.fill: parent
    } //TibiaFrame1PixelDown
  } //background: Item

  font: TibiaStyle.defaultTextFont
  color: textField.enabled ? TibiaStyle.textFieldTextColor : TibiaStyle.textFieldDisabledTextColor
  selectionColor: TibiaStyle.textFieldSelectionColor
  placeholderTextColor: textField.enabled ? TibiaStyle.textColors["Disabled"] : TibiaStyle.textColors["Dark"]

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.RightButton

    onClicked: {
      if (textField.contextMenuEnabled && tibiaContextMenuController != null) {
        tibiaContextMenuController.showContextMenuForTextInputQmlItem(textField);
      }
    } //onClicked
  } // MouseArea

  Keys.onPressed: (event) => {
    if(typeof tibiaTextCopyController === 'undefined' || tibiaTextCopyController == null) {
      return;
    }

    if((event.key == Qt.Key_C) && (event.modifiers & Qt.ControlModifier)) { //CTR+C
      tibiaTextCopyController.copyFromTextInputQmlItemIfPossible(textField);
      event.accepted = true;
    } else if((event.key == Qt.Key_X) && (event.modifiers & Qt.ControlModifier)) { //CTR+X
      tibiaTextCopyController.cutFromTextInputQmlItemIfPossible(textField);
      event.accepted = true;
    }
  } //Keys.onPressed

  onTextChanged: {
    // do not mangle passwords
    if (echoMode == TextInput.Normal) {
      var modifiedText = text.replace(TibiaStyle.regExpSingleNonASCIIChar,"?");
      if (text != modifiedText) {
        var savedCursorPosition = cursorPosition;
        text = modifiedText;
        cursorPosition = savedCursorPosition;
      }
    }

    // remove newlines from input
    if(!allowNewline) {
      text = text.replace("\n", " ");
    }

    if (!allowSpaces) {
      modifiedText = text.replace(/[ \t]/, "");
      if (text != modifiedText) {
        savedCursorPosition = cursorPosition;
        text = modifiedText;
        cursorPosition = Math.max(savedCursorPosition - 1, 0);
      }
    }
  } // onTextChanged
} //TextField
