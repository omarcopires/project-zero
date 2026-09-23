import QtQuick
import QtQuick.Layouts
import qmlcomponents



TibiaDialog {
  id: root
  property var controller: null
  property string messageText: controller != null ? controller.messageText : ""
  property bool textCentered: false
  property var messageDialogTextFormat: Text.PlainText


  caption: qsTrId("warning")
  implicitWidth: 300

  function adjustDialogWidth() {
    var neededTextWidth = textLengthMeasurement.contentWidth;
    var neededButtonBarWidth = TibiaStyle.marginRelated + buttonRepeaterLayout.width;

    root.width = Math.ceil(Math.max(root.implicitWidth,
                                    Math.min(TibiaStyle.clientMinWidth * 0.75,
                                             Math.max(neededTextWidth,
                                                      neededButtonBarWidth) + 2 * TibiaStyle.dialogMarginBorder)));
    root.centerDialog();
  } //function adjustWidth


  TibiaText {
    id: textLengthMeasurement
    text: root.messageText
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
      text: root.messageText
      textFormat: messageDialogTextFormat
      wrapMode: Text.Wrap
      horizontalAlignment: textCentered ? Text.AlignHCenter : Text.AlignLeft
      Layout.fillWidth: true
    } // TibiaText

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } // TibiaHorizontalSeparator

    RowLayout {
      id: buttonRepeaterLayout
      spacing: TibiaStyle.marginRelated

      Item {
        Layout.fillWidth: true
      } //Item

      TibiaButton {
        id: confirmButton
        property int secondsRemaining: controller != null ? controller.secondsRemaining : 0
        property bool showCountdown: controller != null ? controller.showCountdown : false
        text: showCountdown
          ? secondsRemaining > 0
            ? secondsRemaining
            : qsTrId("ok")
          : qsTrId("ok")
        enabled: false
        onSecondsRemainingChanged: {
          if (secondsRemaining == 0) {
            enabled = true;
          }
        }
        
        onClicked: {
          if (controller != null) {
            controller.requestClose();
          }
        } //onClicked
      } // TibiaButton

    } // RowLayout
  } // ColumnLayout
} // TibiaDialog
