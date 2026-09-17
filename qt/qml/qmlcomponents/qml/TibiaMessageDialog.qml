import QtQuick
import QtQuick.Layouts

import qmlenumvalues


TibiaDialog {
  id: root
  caption: "Message"
  implicitWidth: 300
  property string message: "Default text"
  property alias checkBoxText: checkBox.text
  property alias checkBoxIsChecked: checkBox.shouldBeChecked
  property var buttons
  property var controller
  property bool textCentered: false
  property var messageDialogTextFormat: {
    if (controller!= null) {
      switch (controller.messageDialogTextFormat) {
        case MessageDialogController.PLAIN_TEXT: return Text.PlainText;
        case MessageDialogController.STYLED_TEXT: return Text.StyledText;
        case MessageDialogController.RICH_TEXT: return Text.RichText;
        case MessageDialogController.MARKDOWN_TEXT: return Text.MarkdownText;
      }
    }

    return Text.PlainText;
  }

  onControllerChanged: {
    if (controller != null) {
      onReturnPressedFunction = () => controller.onDialogReturnKeyPressed();
      onCancelPressedFunction = () => controller.onDialogEscapeKeyPressed();
      onKeyPressedFunction = (key, modifier) => controller.onDialogKeyPressed(key, modifier);
    } else {
      onReturnPressedFunction = null;
      onCancelPressedFunction = null;
      onKeyPressedFunction = null;
    }
  } // onControllerChanged

  //keep focus to the dialog itself, no tab navigation wanted
  initialFocusItem: root
  KeyNavigation.tab: root

  function adjustDialogWidth() {
    var neededTextWidth = textLengthMeasurement.contentWidth;
    var neededButtonBarWidth = checkBox.width + TibiaStyle.marginRelated + buttonRepeaterLayout.width;

    root.width = Math.ceil(Math.max(root.implicitWidth,
                                    Math.min(TibiaStyle.clientMinWidth * 0.75,
                                             Math.max(neededTextWidth,
                                                      neededButtonBarWidth) + 2 * TibiaStyle.dialogMarginBorder)));
    root.centerDialog();
  } //function adjustWidth

  TibiaText {
    id: textLengthMeasurement
    text: message
    textFormat: messageDialogTextFormat
    wrapMode: Text.NoWrap
    horizontalAlignment: textCentered ? Text.AlignHCenter : Text.AlignLeft
    visible: false

    onTextChanged: root.adjustDialogWidth()
  } //TibiaText

  ColumnLayout {
    anchors { left: parent.left; right: parent.right }
    spacing: TibiaStyle.marginUnrelated

    TibiaText {
      id: messageText
      text: message
      textFormat: messageDialogTextFormat
      wrapMode: Text.Wrap
      horizontalAlignment: textCentered ? Text.AlignHCenter : Text.AlignLeft
      Layout.fillWidth: true

      onLinkHovered: {
        if (tibiaMouseCursorController) {
          tibiaMouseCursorController.setPointingHand(link !== "")
        }
      }

      onLinkActivated:{
        Qt.openUrlExternally(link)
      }
    } // TibiaText

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } // TibiaHorizontalSeparator

    Item {
      Layout.fillWidth: true
      Layout.preferredHeight: Math.max(buttonRepeaterLayout.height,
                                       checkBox.visible? checkBox.height: 0)

      TibiaMenuOptionCheckBox {
        id: checkBox
        text: ""
        visible: text != ""
        shouldBeChecked: false
        onWidthChanged: root.adjustDialogWidth()
      } //TibiaMenuOptionCheckBox

      RowLayout {
        id: buttonRepeaterLayout
        anchors.verticalCenter: parent. verticalCenter
        anchors.right: parent.right
        spacing: TibiaStyle.marginRelated
        onWidthChanged: root.adjustDialogWidth()

        Repeater {
          id: buttonRepeater
          model: buttons

          TibiaButton {
            text: model.modelData.label
            onClicked: {
              if (controller != null) {
                controller.onDialogButtonClicked(model.modelData.identifier,
                                                 checkBox.checked)
              }
            } // onClicked
          } // TibiaButton
        } // Repeater
      } // RowLayout
    } //Item
  } // ColumnLayout

} //TibiaDialog
