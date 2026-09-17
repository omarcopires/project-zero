import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qmlcomponents

import "qrc:/qt/qml/qmlcomponents/qml/"

TibiaDialog {
  id: root
  width: 240

  required property var controller     // versichert, dass controller immer vorhanden ist

  /* -------- Dialog‑Rahmen -------- */
  caption: qsTrId("offline_training")
  initialFocusItem: cancelButton

  onReturnPressedFunction: function() {}
  onCancelPressedFunction: function() {
    controller.requestClose();
  } //onCancelPressedFunction

  ColumnLayout {
    id: column
    anchors { left: parent.left; right: parent.right; top: parent.top;}
    spacing: TibiaStyle.marginUnrelated

    /* --- Erklaerungssatz --- */
    TibiaText {
      Layout.fillWidth: true
      horizontalAlignment: Text.AlignHCenter
      wrapMode: Text.Wrap
      text: qsTrId("multi_offline_training_explaination")
    } // TibiaText

    ColumnLayout {
      spacing: TibiaStyle.marginRelated

      Repeater {
        model: controller.skillsModel

        RowLayout {
          spacing: TibiaStyle.marginRelated

          SkillWidgetEntry {
            Layout.fillWidth: true

            Component.onCompleted: {
              skillModelData = modelData;
            } // Component.onCompleted
          } // SkillWidgetEntry

          TibiaButton {
            text: qsTrId("multi_offline_training_train")
            onClicked: controller.startOfflineTraining(modelData.trainingSkill)
          } //TibiaButton
        } //Rowlayout
      } // Repeater
    } //ColumnLayout

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } //TibiaHorizontalSeparator

    RowLayout {
      Layout.alignment: Qt.AlignRight
      spacing: TibiaStyle.marginRelated

      TibiaButton {
        id: cancelButton
        text: qsTrId("cancel")
        onClicked: onCancelPressedFunction();
      } //TibiaButton
    } // RowLayout
  }
}
