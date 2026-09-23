import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qmlenumvalues


TibiaDialog {
  id: root
  caption: isRename ? qsTrId("skill_wheel_manage_presets_caption_rename")
                    : qsTrId("skill_wheel_manage_presets_caption_new")
  width: 625

  property var controller: null
  readonly property bool isRename: controller != null && controller.manageMode == SkillWheelPresetManagmentDialogController.Rename
  readonly property string currentPresetName: controller != null ? controller.currentPresetName : ""

  onReturnPressedFunction: okClicked
  onCancelPressedFunction: closeClicked
  initialFocusItem: presetName

  function okClicked() {
    if (controller != null) {
      if (isRename) {
        controller.onOkClicked(SkillWheelPresetManagmentDialogController.Rename);
      } else {
        controller.onOkClicked(newPresetType.newPrestTypeEnumId);
      }
    }
  } //function okClicked

  function closeClicked() {
    if (controller != null) {
      controller.onCloseClicked();
    }
  } //function closeClicked

  ColumnLayout {
    anchors { left: parent.left; right: parent.right }
    spacing: TibiaStyle.marginUnrelated

    ColumnLayout {
      id: nameLayout
      spacing: TibiaStyle.marginRelated

      RowLayout {
        spacing: TibiaStyle.marginRelated

        TibiaText {
          text: qsTrId("skill_wheel_manage_presets_preset_name") +":"
        } //TibiaText

        TibiaGuiHelp {
          visible: controller != null && !controller.nameIsValid
          color: "orange"
          text: qsTrId("skill_wheel_manage_presets_invalid_name_info")
        } //TibiaGuiHelp
      } //RowLayout

      TibiaTextField {
        id: presetName
        Layout.fillWidth: true
        shouldBeText: root.isRename ? root.currentPresetName : ""
        maximumLength: controller != null ? controller.maxNameLength : TibiaStyle.maxCharacterNameLength
        placeholderText: qsTrId("skill_wheel_manage_presets_preset_name_placeholder");
        onTextChanged: {
          if (controller != null) {
            controller.setNewName(presetName.text)
          }
        } //onTextChanged
      } //TibiaTextField
    } //ColumnLayout

    ColumnLayout {
      id: newPresetLayout
      spacing: TibiaStyle.marginRelated

      visible: !root.isRename

      ButtonGroup {
        id: newPresetType
        property var newPrestTypeEnumId: 0

        checkedButton: {
          if (controller != null) {
            switch (controller.manageMode) {
              case SkillWheelPresetManagmentDialogController.NewEmptyPreset:
                return emptyPreset;
              case SkillWheelPresetManagmentDialogController.CopyPreset:
                return copyPrest;
              case SkillWheelPresetManagmentDialogController.ImportPreset:
                return importPreset;
              default:
                break;
            }
          }
          return emptyPreset
        }

        onCheckedButtonChanged: {
          if (checkedButton == emptyPreset) {
            newPresetType.newPrestTypeEnumId = SkillWheelPresetManagmentDialogController.NewEmptyPreset;
          } else if (checkedButton == copyPrest) {
            newPresetType.newPrestTypeEnumId = SkillWheelPresetManagmentDialogController.CopyPreset;
          } else if (checkedButton == importPreset) {
            newPresetType.newPrestTypeEnumId = SkillWheelPresetManagmentDialogController.ImportPreset;
          } else {
            newPresetType.newPrestTypeEnumId = SkillWheelPresetManagmentDialogController.NewEmptyPreset;
          }
        } //onCheckedButtonChanged
      } //ButtonGroup

      TibiaRadioButton {
        id: emptyPreset
        ButtonGroup.group: newPresetType
        text: qsTrId("skill_wheel_manage_presets_empty_preset")
      } //TibiaRadioButton

      TibiaRadioButton {
        id: copyPrest
        Layout.fillWidth: true
        ButtonGroup.group: newPresetType
        text: qsTrId("skill_wheel_manage_presets_copy_current_preset").arg(root.currentPresetName)
      } //TibiaRadioButton

      ColumnLayout {
        spacing: TibiaStyle.marginRelated

        RowLayout {
          spacing: TibiaStyle.marginRelated

          TibiaRadioButton {
            id: importPreset
            ButtonGroup.group: newPresetType
            text: qsTrId("import")
          } //TibiaRadioButton

          TibiaGuiHelp {
            id: importError
            visible: hasError
            color: "orange"
            readonly property bool hasError: newPresetType.newPrestTypeEnumId == SkillWheelPresetManagmentDialogController.ImportPreset
              && controller != null
              && controller.importStringError.length > 0
            text: hasError ? controller.importStringError : ""
          } //TibiaGuiHelp
        } //RowLayout

        TibiaTextField {
          id: importString
          Layout.fillWidth: true
          maximumLength: 256
          placeholderText: qsTrId("skill_wheel_manage_presets_import_string_placeholder");

          onActiveFocusChanged: {
            if (activeFocus) {
              importPreset.checked = true;
            }
          } //onActiveFocusChanged

          onTextChanged: {
            importPreset.checked = true;
            if (controller != null) {
              controller.setImportString(importString.text)
            }
          } //onTextChanged
        } //TibiaTextField
      } //ColumnLayout
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
        enabled: controller != null && controller.nameIsValid && !importError.hasError
        onClicked: root.okClicked();
      } // TibiaButton

      TibiaButton {
        text: qsTrId("cancel")
        onClicked: root.closeClicked();
      } // TibiaButton
    } // RowLayout
  } // ColumnLayout
} // TibiaDialog
