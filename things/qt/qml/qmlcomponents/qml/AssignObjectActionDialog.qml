import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qmlcomponents



TibiaDialog {
  id: dialogRoot
  caption: controller != null
           ? (controller.showActionBarTarget ? qsTrId("actionbar_assign_object_dialog_caption").arg(actionBarName) : qsTrId("actionbar_assign_object_dialog_caption_short"))
           : qsTrId("dummy_unknown")
  width: 300

  property var controller: null
  property string actionBarName: controller != null ? controller.buttonName : qsTrId("actionbar_button_identifier").arg(0).arg(0)

  onReturnPressedFunction: okClicked
  onCancelPressedFunction: closeClicked
  initialFocusItem: dialogRoot

  function okClicked() {
    if (controller != null) {
      controller.onOkClicked(targetType.useObjectTypeEnumId,
                             useEquipSmartModeCheckBox.checked);
    }
  } //function okClicked

  function applyClicked() {
    if (controller != null) {
      controller.onApplyClicked(targetType.useObjectTypeEnumId,
                                useEquipSmartModeCheckBox.checked);
    }
  } //function applyClicked

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

      ColumnLayout {
        Layout.fillWidth: true
        spacing: TibiaStyle.marginRelated

        TibiaFrame1PixelDown {
          id: objectAppearanceFrame
          Layout.preferredHeight: TibiaStyle.buttonWidthWide
          Layout.preferredWidth: Layout.preferredHeight
          Layout.alignment: Qt.AlignTop

          ScalableObjectDisplay{
            id: objectAppearance
            anchors.centerIn: parent
            showBackground: false
            scaleFactor: TibiaStyle.actionBarAssignObjectScaleFactor
            smoothTextureFiltering: controller != null && controller.clientSettingSmoothFiltering
            clip: true

            animated: true
            typeid: controller != null ? controller.objectID : 0
            upgradeTier: controller != null ? controller.upgradeTier : 0
            cumulativeCount: controller != null ? controller.objectCount : 0
            liquidType: controller != null ? controller.liquidType : ObjectAppearanceInstance.EMPTY
            hookDirection: controller != null ? controller.hookDirection : ObjectAppearanceInstance.NONE
          } //SingleObjectAppearanceInstanceRenderer
        } //TibiaFrame1PixelDown

        TibiaButton{
          id: selectObjectButton
          text: qsTrId("hotkeys_select_object")
          Layout.preferredWidth: TibiaStyle.buttonWidthWide
          onClicked: {
            if (controller != null) {
              controller.startTargetSelection();
            }
          } //onClicked
        } //TibiaButton
      } //ColumnLayout

      ColumnLayout {
        id: useObjectOptions
        spacing: TibiaStyle.marginRelated
        Layout.alignment: Qt.AlignTop

        ButtonGroup {
          id: targetType
          property int useObjectTypeEnumId: 0

          checkedButton: {
            if (controller != null) {
              if (controller.useObjectType == 1) {
                return targetTypeSelf;
              } else if (controller.useObjectType == 2) {
                return targetTypeTarget;
              } else if (controller.useObjectType == 3) {
                return targetTypeCrosshair;
              } else if (controller.useObjectType == 4) {
                return targetTypeEquip;
              } else if (controller.useObjectType == 5) {
                return targetTypeMouseCursor;
              }
            }
            return targetTypeUse;
          }

          onCheckedButtonChanged: {
            if (checkedButton == targetTypeSelf) {
              targetType.useObjectTypeEnumId = 1;
            } else if (checkedButton == targetTypeTarget) {
              targetType.useObjectTypeEnumId = 2;
            } else if (checkedButton == targetTypeCrosshair) {
              targetType.useObjectTypeEnumId = 3;
            } else if (checkedButton == targetTypeEquip) {
              targetType.useObjectTypeEnumId = 4;
            } else if (checkedButton == targetTypeMouseCursor) {
              targetType.useObjectTypeEnumId = 5;
            } else {
              targetType.useObjectTypeEnumId = 0;
            }
          } //onCurrentChanged
        } //ButtonGroup

        TibiaRadioButton {
          id: targetTypeSelf
          text: qsTrId("hotkeys_use_on_yourself")
          ButtonGroup.group: targetType
          enabled: controller && controller.canBeMultiUsed
        } //TibiaRadioButton

        TibiaRadioButton {
          id: targetTypeTarget
          text: qsTrId("hotkeys_use_on_target")
          ButtonGroup.group: targetType
          enabled: controller && controller.canBeMultiUsed
        } //TibiaRadioButton

        TibiaRadioButton {
          id: targetTypeCrosshair
          text: qsTrId("hotkeys_with_crosshair")
          ButtonGroup.group: targetType
          enabled: controller && controller.canBeMultiUsed
        } //TibiaRadioButton

        TibiaRadioButton {
          id: targetTypeMouseCursor
          text: qsTrId("hotkeys_use_at_mousecursor")
          ButtonGroup.group: targetType
          enabled: controller && controller.canBeMultiUsed
        } //TibiaRadioButton

        TibiaRadioButton {
          id: targetTypeEquip
          text: qsTrId("hotkeys_equip_object")
          ButtonGroup.group: targetType
          enabled: controller && controller.canBeEquiped
        } //TibiaRadioButton

        TibiaCheckBox {
          id: useEquipSmartModeCheckBox
          Layout.leftMargin: TibiaStyle.paragraphIndentation
          text: qsTrId("hotkeys_equip_smart_mode")
          tooltipText: qsTrId("hotkeys_equip_smart_mode_toolitp")
          enabled: targetTypeEquip.checked
          visible: controller && controller.canHaveSmartMode
          checked: controller && controller.smartModeEnabled
        } //TibiaCheckBox

        TibiaRadioButton {
          id: targetTypeUse
          text: qsTrId("hotkeys_use_object")
          ButtonGroup.group: targetType
          enabled: controller && !controller.canBeMultiUsed
        } //TibiaRadioButton
      } //ColumnLayout
    } //RowLayout

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } //TibiaHorizontalSeparator

    RowLayout {
      Layout.alignment: Qt.AlignRight
      spacing: TibiaStyle.marginRelated

      Item {Layout.fillWidth: true}

      TibiaButton {
        text: qsTrId("ok")
        enabled: objectAppearance.typeid != 0
        onClicked: dialogRoot.okClicked();
      } // TibiaButton

      TibiaButton {
        text: qsTrId("apply")
        enabled: objectAppearance.typeid != 0
        onClicked: dialogRoot.applyClicked();
      } // TibiaButton

      TibiaButton {
        text: qsTrId("cancel")
        onClicked: dialogRoot.closeClicked();
      } // TibiaButton
    } // RowLayout
  } // ColumnLayout
} // TibiaDialog
