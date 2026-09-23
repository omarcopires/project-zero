import QtQuick
import QtQuick.Layouts
import QtQuick.LegacyControls



TibiaDialog {
  property var controller: null;

  caption: controller != null ? controller.dialogTitle : qsTrId("dummy_unknown")
  width: 245

  function answerDialog(ButtonIndex) {
    if (controller != null) {
      if (selectionTable.selection.count > 0) {
        selectionTable.selection.forEach(function (RowIndex) {
          controller.answerButtonClicked(ButtonIndex, RowIndex);
        });
      } else {
        controller.answerButtonClicked(ButtonIndex, -1);
      }
    }
  }

  onReturnPressedFunction: function() {
    answerDialog(controller != null ? controller.defaultEnterButtonIndex : 0);
  }

  onCancelPressedFunction: function() {
    answerDialog(controller != null ? controller.defaultEscapeButtonIndex : 0);
  }

  initialFocusItem: selectionTable

  ColumnLayout {
    spacing: TibiaStyle.marginRelated

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

    TibiaTableView {
      id: selectionTable
      Layout.fillWidth: true
      model: controller != null ? controller.selectionList : null
      visible: model != null && model.length > 0

      property int minimumRows: 3
      property int maximumRows: 10
      property int paddingBottomAndTop: 2
      property int lineHeight: 16

      Layout.preferredHeight: Math.max(minimumRows, Math.min(model != null ? model.length : 0, maximumRows)) * lineHeight + paddingBottomAndTop

      TableViewColumn {
      }

      onRowCountChanged: {
        // Make sure at least one row is always selected
        if (selection.count == 0 && rowCount > 0) {
          selection.select(0, 0);
        }
      } // onRowCountChanged

      onActivated: onReturnPressedFunction();
    } // TibiaTableView

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
      Layout.topMargin: TibiaStyle.marginUnrelated
    } // TibiaHorizontalSeparator

    RowLayout {
      Layout.alignment: Qt.AlignRight
      Layout.topMargin: TibiaStyle.marginRelated
      spacing: TibiaStyle.marginUnrelated

      Repeater {
        model: controller != null ? controller.answerButtons : null
        delegate: TibiaButton {
          text: modelData

          onClicked: answerDialog(index);
        } // delegate: TibiaButton
      } // Repeater
    } // RowLayout
  } // ColumnLayout
} // TibiaDialog
