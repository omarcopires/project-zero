import QtQuick
import QtQuick.Controls.Basic



TibiaScrollView {
  id: control
  property alias cursorPosition: textArea.cursorPosition
  property alias length: textArea.length
  property alias maximumLength: textArea.maximumLength
  property alias readOnly: textArea.readOnly
  property alias text: textArea.text
  property alias color: textArea.color
  property alias textFormat: textArea.textFormat
  property alias wrapMode: textArea.wrapMode

  horizontalScrollBarPolicy: ScrollBar.AlwaysOff
  topPadding: pixelBorder.borderWidth
  bottomPadding: pixelBorder.borderWidth
  leftPadding: pixelBorder.borderWidth
  rightPadding: pixelBorder.borderWidth

  function forceActiveFocus()
  {
    textArea.forceActiveFocus()
  }

  background: TibiaFrame1PixelDown {
    id: pixelBorder
    width: control.width
    height: control.height
  }  // TibiaFrame1PixelDown

  ScrollBar.vertical.anchors {
    right: control.right; rightMargin: pixelBorder.borderWidth;
    top: control.top; topMargin: pixelBorder.borderWidth;
    bottom: control.bottom; bottomMargin: pixelBorder.borderWidth;
  }

  TextArea {
    id: textArea
    property int maximumLength: -1
    property bool contextMenuEnabled: true
    property bool hasSelection: selectedText.length > 0
    font: TibiaStyle.textFieldFont
    color: TibiaStyle.textFieldTextColor
    selectionColor: TibiaStyle.textFieldSelectionColor
    renderType: TibiaStyle.textRenderingType
    leftPadding: TibiaStyle.marginRelated
    rightPadding: TibiaStyle.scrollBarWidth
    topPadding: TibiaStyle.marginNarrow * 2
    bottomPadding: TibiaStyle.marginNarrow * 2
    wrapMode: TextEdit.Wrap

    Keys.onPressed: (event) => {
      if (maximumLength > -1 && text.length >= maximumLength
          && !(event.key == Qt.Key_Backspace || event.key == Qt.Key_Delete
               || event.key == Qt.Key_Left || event.key == Qt.Key_Right
               || event.key == Qt.Key_Up || event.key == Qt.Key_Down
               || event.key == Qt.Key_Escape || event.key == Qt.Key_Tab
               || event.key == Qt.Key_Home || event.key == Qt.Key_End
               || (event.key == Qt.Key_X && event.modifiers & Qt.ControlModifier))) {
        // Hack: Prevent all keys causing text to be inserted from being accepted, while hopefully
        // stil retaining other useful keys. This should be removed when Qt provides proper size limiting.
        event.accepted = true;
      }

      if(typeof tibiaTextCopyController === 'undefined' || tibiaTextCopyController == null) {
        return;
      }

      if((event.key == Qt.Key_C) && (event.modifiers & Qt.ControlModifier)) { //CTRL+C
        tibiaTextCopyController.copyFromTextInputQmlItemIfPossible(textArea);
        event.accepted = true;
      } else if((event.key == Qt.Key_X) && (event.modifiers & Qt.ControlModifier)) { //CTRL+X
        tibiaTextCopyController.cutFromTextInputQmlItemIfPossible(textArea);
        event.accepted = true;
      }
    }

    onTextChanged: {
      if (maximumLength > -1 && text.length > maximumLength) {
        // Needs to be set twice to avoide error message
        cursorPosition = maximumLength;
        text = text.substr(0, maximumLength);
        cursorPosition = maximumLength;
      }

      if (!readOnly) {
        var modifiedText = text.replace(TibiaStyle.regExpSingleNonASCIIChar,"?");
        if (text != modifiedText) {
          var savedCursorPosition = cursorPosition;
          text = modifiedText;
          cursorPosition = savedCursorPosition;
        }
      }
    } // onTextChanged

    background: Rectangle {
      width: textArea.width
      height: textArea.height
      color: TibiaStyle.textFieldBackgroundColor
    }

    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.RightButton

      onClicked: {
        if (textArea.contextMenuEnabled && tibiaContextMenuController != null) {
          tibiaContextMenuController.showContextMenuForTextInputQmlItem(textArea);
        }
      } //onClicked
    } // MouseArea
  } //TextArea
} // ScrollView
