import QtQuick
import QtQuick.Layouts
import qmlcomponents



TibiaDialog {
  id: dialogRoot
  caption: controller != null
          ? (controller.showActionBarTarget ? qsTrId("actionbar_assign_passiveability_dialog_caption").arg(actionBarName) : qsTrId("actionbar_assign_passiveability_dialog_caption_short"))
          : qsTrId("dummy_unknown")
  width: 275

  property var controller: null
  property string actionBarName: controller != null ? controller.buttonName : qsTrId("actionbar_button_identifier").arg(0).arg(0)
  property bool passiveAbilitySelected: controller != null && controller.passiveAbilityName != ""

  onReturnPressedFunction: okClicked
  onCancelPressedFunction: closeClicked
  initialFocusItem: passiveAbilityList

  function okClicked() {
    if (controller != null) {
      controller.onOkClicked();
    }
  } //function okClicked

  function assignPassiveAbility() {
    if (controller != null) {
      controller.onApplyClicked();
    }
  } //function assignPassiveAbility

  function closeClicked() {
    if (controller != null) {
      controller.onCloseClicked();
    }
  } //function closeClicked

  ColumnLayout {
    anchors { left: parent.left; right: parent.right }
    spacing: TibiaStyle.marginUnrelated

    RowLayout {
      Layout.fillWidth: true
      spacing: TibiaStyle.marginRelated

      Image {
        Layout.preferredHeight: TibiaStyle.passiveAbilityListIconSize
        source: controller != null ? controller.passiveAbilityIconUrl : ""
      } //Image

      ColumnLayout {
        spacing: 0
        Layout.fillWidth: true

        TibiaText {
          Layout.fillWidth: true
          text: controller != null ? controller.passiveAbilityName : ""
          visible: dialogRoot.passiveAbilitySelected
        } // TibiaText

        TibiaText {
          Layout.fillWidth: true
          visible: !dialogRoot.passiveAbilitySelected
          text: qsTrId("actionbar_assign_passiveability_dialog_no_passiveability_selected")
        } //TibiaText
      } //ColumnLayout
    } //RowLayout

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } //TibiaHorizontalSeparator

    ColumnLayout {
      Layout.fillWidth: true
      spacing: TibiaStyle.marginRelated

      TibiaFrame1PixelDown {
        Layout.fillWidth: true
        Layout.preferredHeight: 120

        Rectangle {
          anchors.fill: parent
          anchors.margins: parent.borderWidth
          color: TibiaStyle.tableViewBackgroundColor

          TibiaScrollView {
            anchors.fill: parent
            contentWidth: passiveAbilityList.width

            PassiveAbilityList {
              id: passiveAbilityList

              //KeyNavigation.tab: parameterTextField

              model: controller != null ? controller.passiveAbilityListModel : null
              externalSelectedIndex: controller != null ? controller.passiveAbilityListIndex : -1

              onPassiveAbilitySelected: (passiveAbilityEnumId) => {
                if (controller != null) {
                  controller.passiveAbilitySelected(passiveAbilityEnumId);
                }
              } //onPassiveAbilitySelected
            } //PassiveAbilityList
          } //TibiaScrollView
        } //Rectangle
      } // TibiaFrame1PixelDown
    } //ColumnLayout

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } //TibiaHorizontalSeparator

    RowLayout {
      Layout.alignment: Qt.AlignRight
      spacing: TibiaStyle.marginRelated

      Item {Layout.fillWidth: true}

      TibiaButton {
        text: qsTrId("ok")
        onClicked: dialogRoot.okClicked();
        enabled: dialogRoot.passiveAbilitySelected
      } // TibiaButton

      TibiaButton {
        text: qsTrId("apply")
        onClicked: dialogRoot.assignPassiveAbility();
        enabled: dialogRoot.passiveAbilitySelected
      } // TibiaButton

      TibiaButton {
        text: qsTrId("cancel")
        onClicked: dialogRoot.closeClicked();
      } // TibiaButton
    } // RowLayout
  } // ColumnLayout
} // TibiaDialog
