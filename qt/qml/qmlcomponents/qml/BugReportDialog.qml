import QtQuick
import QtQuick.Layouts

import QtQuick.LegacyControls


TibiaDialog {
  id: bugReportDialog
  caption: qsTrId("bugreport_caption")
  width: 300

  property var controller: null;
  property alias classifications: classificationTable.model
  property int preselectedClassificationIndex: controller != null ? controller.preselectedClassificationIndex : -1;

  onPreselectedClassificationIndexChanged: {
    if (preselectedClassificationIndex > -1 && preselectedClassificationIndex < classifications.length) {
      classificationTable.selection.clear();
      classificationTable.selection.select(preselectedClassificationIndex, preselectedClassificationIndex);
      classificationTable.positionViewAtRow(preselectedClassificationIndex, ListView.Contain);
    }
  }

  onReturnPressedFunction: function() {
    if (sendButton.enabled) {
      sendButton.clicked();
    }
  }

  onCancelPressedFunction: function() {
    cancelButton.clicked()
  }

  initialFocusItem: commentTextArea

  ColumnLayout {
    spacing: 0

    anchors {
      top: parent.top;
      left: parent.left;
      right: parent.right;
    }

    TibiaText {
      Layout.fillWidth: true
      Layout.bottomMargin: TibiaStyle.marginRelated
      wrapMode: Text.Wrap
      text: qsTrId("bugreport_description")
    }

    TibiaTableView {
      id: classificationTable
      Layout.fillWidth: true
      Layout.preferredHeight: 50
      model: controller != null ? controller.classifications : []
      KeyNavigation.tab: commentTextArea

      TableViewColumn { }
    }

    TibiaTextArea {
      id: commentTextArea
      KeyNavigation.tab: classificationTable
      Layout.fillWidth: true
      Layout.preferredHeight: 150
      maximumLength: 1024
      wrapMode: TextEdit.Wrap
    }

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
      Layout.topMargin: TibiaStyle.marginUnrelated
      Layout.bottomMargin: TibiaStyle.marginUnrelated
    } //TibiaHorizontalSeparator

    RowLayout {
      spacing: TibiaStyle.marginRelated

      TibiaText {
        visible: notAllowedInfo.visible
        styleType: "MessageWarning"
        text: qsTrId("bugreport_not_allowed")
      } //TibiaText

      TibiaGuiHelp {
        id: notAllowedInfo
        color: "orange"
        text: controller != null ? controller.notAllowedReason : ""
        visible: text.length > 0
      } //TibiaGuiHelp

      Item {
        Layout.fillWidth: true
      } //Item

      TibiaButton {
        id: sendButton
        enabled: commentTextArea.length > 0 && !notAllowedInfo.visible
        text: qsTrId("send")

        onClicked: {
          if (controller != null) {
            classificationTable.selection.forEach(function (RowIndex) {
              controller.requestSendBugReport(RowIndex, commentTextArea.text);
            });
          }
        } //onClicked
      } // TibiaButton

      TibiaButton {
        id: cancelButton
        text: qsTrId("cancel")

        onClicked: {
          if (controller != null) {
            controller.requestClose();
          }
        } //onClicked
      } // TibiaButton
    } // RowLayout
  } // ColumnLayout
} // TibiaDialog
