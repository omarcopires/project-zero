import QtQuick
import QtQuick.Layouts



TibiaDialog {
  id: hirelingDialog
  caption: controller != null && qsTrId("hirelingconfiguration_caption")
  width: 350

  property var controller: null

  onReturnPressedFunction: function() {
    if (okButton.enabled && controller != null) {
      controller.requestHireling(
        hirelingName.text,
        hirelingSexComboBox.model.get(hirelingSexComboBox.currentIndex).sex);
    }
  }

  onCancelPressedFunction: function() {
    if (controller != null) {
      controller.requestClose();
    }
  }

  initialFocusItem: hirelingName

  ColumnLayout {
    anchors { left: parent.left; right: parent.right}
    spacing: TibiaStyle.marginUnrelated

    TibiaText {
      Layout.fillWidth: true
      text: qsTrId("hirelingconfiguration_description")
      wrapMode: Text.Wrap
    }

    GridLayout {
      columns: 2
      columnSpacing: TibiaStyle.marginUnrelated
      rowSpacing: TibiaStyle.marginUnrelated

      TibiaText {
        text: qsTrId("hirelingconfiguration_hireling_name")
      }

      TibiaTextField {
        id: hirelingName
        Layout.fillWidth: true
        maximumLength: TibiaStyle.maxCharacterNameLength
        KeyNavigation.tab: hirelingSexComboBox
        KeyNavigation.backtab: hirelingSexComboBox
      }

      TibiaText {
        text: qsTrId("hirelingconfiguration_hireling_sex")
      }

      TibiaComboBox {
        id: hirelingSexComboBox
        currentIndex: 0
        Layout.fillWidth: true
        KeyNavigation.tab: hirelingName
        KeyNavigation.backtab: hirelingName
        textRole: "text"
        valueRole: "sex"

        model: ListModel {
          ListElement { text: qsTrId("hirelingconfiguration_sex_male"); sex: 1 }
          ListElement { text: qsTrId("hirelingconfiguration_sex_female"); sex: 2 }
        }
      }
    } // GridLayout

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } // TibiaHorizontalSeparator


    RowLayout {
      spacing: TibiaStyle.marginUnrelated

      Item {
        Layout.fillWidth: true
      } // Item

      TibiaButton {
        id: okButton
        text: qsTrId("store_buy_now")
        color: enabled ? "blue" : "grey"
        textStyle: "Default"
        enabled: controller != null && hirelingName.text.length > 1
        Layout.preferredWidth: TibiaStyle.buttonWidthBroad

        onClicked: {
          onReturnPressedFunction();
        }
      } // TibiaButton

      TibiaButton {
        id: cancelButton
        text: qsTrId("cancel")
        Layout.preferredWidth: TibiaStyle.buttonWidthBroad

        onClicked: {
          onCancelPressedFunction();
        }
      } // TibiaButton
    } // RowLayout
  }// ColumnLayout
} // TibiaDialog
