import QtQuick
import QtQuick.Layouts



TibiaDialog {
  property var controller: null;

  caption: controller != null ? controller.dialogCaption : qsTrId("dummy_unknown")
  width: 250

  onCancelPressedFunction: function() {
    if (controller != null) {
      controller.abortWait();
    }
  }

  initialFocusItem: abortButton

  ColumnLayout {
    spacing: TibiaStyle.marginUnrelated

    anchors {
      left: parent.left
      right: parent.right
      top: parent.top
    }

    TibiaText {
      text: controller != null ? controller.dialogText : qsTrId("dummy_unknown")
      styleType: "Dialog"
      Layout.fillWidth: true
      wrapMode: Text.Wrap
    } // TibiaText

    TibiaProgressBarClassicRed {
      fillPercentage: controller != null ? controller.fillPercentage : 0.0;
      Layout.fillWidth: true
    } // TibiaProgressBarClassicRed

    TibiaText {
      text: controller != null ? controller.waitTextWithRemainingDuration : qsTrId("please_wait")
      styleType: "Dialog"
      Layout.fillWidth: true
      wrapMode: Text.Wrap
    } // TibiaText

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } // TibiaHorizontalSeparator

    RowLayout {
      Layout.alignment: Qt.AlignRight
      spacing: TibiaStyle.marginUnrelated

      TibiaButton {
        id: abortButton
        text: qsTrId("abort")

        onClicked: onCancelPressedFunction();
      } // TibiaButton
    } // RowLayout
  } // ColumnLayout
} // TibiaDialog
