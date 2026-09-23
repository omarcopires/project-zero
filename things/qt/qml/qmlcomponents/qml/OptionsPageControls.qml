import QtQuick
import QtQuick.Layouts



TibiaOptionsPage {
  id: root
  implicitHeight: contentLayout.height

  optionsSet: controller != null ? controller.controlsOptions : null
  readonly property int comboBoxWidth: TibiaStyle.comboboxOptionsWidth

  ColumnLayout {
    id: contentLayout
    anchors { left: parent.left; top: parent.top; right: parent.right }
    spacing: TibiaStyle.marginRelated

    RowLayout {
      TibiaText {
        text: qsTrId("optionsmenu_mouse_preset")
      } // TibiaText

      TibiaComboBox {
        id: controlScheme
        Layout.preferredWidth: root.comboBoxWidth
        model: optionsSet != null ? optionsSet.controlSchemeListModel : null
        shouldBeCurrentIndex: optionsSet != null ? optionsSet.controlSchemeIndex : 0
        onCurrentIndexChanged: {
          if (optionsSet != null) {
            optionsSet.controlSchemeIndex = currentIndex;
          }
        } //onCurrentIndexChanged
      } //TibiaComboBox

      TibiaComboBox {
        id: lootScheme
        Layout.preferredWidth: root.comboBoxWidth
        visible: optionsSet != null && optionsSet.controlSchemeIndex == 0
        model: optionsSet != null ? optionsSet.lootSchemeListModel : null
        shouldBeCurrentIndex: optionsSet != null ? optionsSet.lootSchemeIndex : 0
        onCurrentIndexChanged: {
          if (optionsSet != null) {
            optionsSet.lootSchemeIndex = currentIndex;
          }
        } //onCurrentIndexChanged
      } // TibiaComboBox

      Item {
        Layout.fillWidth: true
      } //Item

      TibiaGuiHelp {
        Layout.rightMargin: TibiaStyle.alignGuiHelpWithAndWithoutFrame //to align with the the otther GuiHelp icons
        useRichText: true
        text: qsTrId("optionsmenu_mouse_preset_help")
      } //TibiaGuiHelp
    } //RowLayout

    TibiaFrame1PixelDown {
      Layout.fillWidth: true
      Layout.preferredHeight: keyboardDelayLayout.height + 2 * marginsToContent

      ColumnLayout {
        id: keyboardDelayLayout
        anchors { left: parent.left; top: parent.top; right: parent.right }
        anchors.margins: parent.marginsToContent
        spacing: TibiaStyle.marginRelated

        RowLayout {
          spacing: TibiaStyle.marginRelated

          TibiaCheckBox {
            id: useDefaultKeyboardDelay
            text: qsTrId("optionsmenu_use_default_keyboarddelay").arg(optionsSet != null ? optionsSet.defaultKeyboardDelayMillis : 250)
            Layout.fillWidth: true
            shouldBeChecked: optionsSet != null && optionsSet.useDefaultKeyboardDelay
            onCheckedChanged: {
              if (optionsSet != null) {
                optionsSet.useDefaultKeyboardDelay = checked;
              }
            } //onCheckedChanged
          } //TibiaCheckBox

          TibiaGuiHelp {
            text: qsTrId("optionsmenu_keyboarddelay_tooltip")
          } //TibiaGuiHelp
        } //RowLayout

        RowLayout {
          Layout.leftMargin: TibiaStyle.paragraphIndentation
          spacing: TibiaStyle.marginRelated

          TibiaMenuSlider {
            id: keyboardDelaySlider
            enabled: !useDefaultKeyboardDelay.checked
            Layout.fillWidth: true
            text: qsTrId("optionsmenu_keyboarddelay")
            unitSymbol: "ms"
            minimumValue: 0
            maximumValue: 1000
            stepSize: 1
            shouldBeValue: optionsSet != null ? optionsSet.keyboardDelayMillis : 0
            onValueChanged: {
              if (optionsSet != null) {
                optionsSet.keyboardDelayMillis = value;
              }
            } //onValueChanged

            styleType: {
              if (value < 50) {
                return "MessageCritical";
              } else if (value < 250) {
                return "MessageWarning";
              }
              return "Dialog";
            } //styleType
          } //TibiaMenuSlider

          TibiaGuiHelp {
            id: keyboardDelaySliderGuiHelp
            enabled: opacity == 1
            opacity: keyboardDelaySlider.value < 250 && !useDefaultKeyboardDelay.checked ? 1 : 0
            text: keyboardDelaySlider.value < 50 ? qsTrId("optionsmenu_use_keyboarddelay_critical")
                                                 : qsTrId("optionsmenu_use_keyboarddelay_warning")
            color: keyboardDelaySlider.value < 50 ? "red" : "orange"
          } //TibiaGuiHelp
        } //RowLayout
      } //ColumnLayout
    } //TibiaFrame1PixelDown

    TibiaFrame1PixelDown {
      Layout.fillWidth: true
      Layout.preferredHeight: rotationControlsLayout.height + 2 * marginsToContent

      ColumnLayout {
        id: rotationControlsLayout
        anchors { left: parent.left; top: parent.top; right: parent.right }
        anchors.margins: parent.marginsToContent
        spacing: TibiaStyle.marginUnrelated

        RowLayout {
          id: rotationKeyLayout
          Layout.fillWidth: true
          spacing: TibiaStyle.marginUnrelated

          TibiaText {
            text: qsTrId("optionsmenu_keys_for_rotation_caption")
          } //TibiaText

          TibiaCheckBox {
            id:checkBoxCtrl
            text: qsTrId("optionsmenu_rotation_key_ctrl")
            shouldBeChecked: optionsSet != null && optionsSet.rotateWithCtrl
            onCheckedChanged: {
              if (optionsSet != null) {
                optionsSet.rotateWithCtrl = checked;
              }
            } //onCheckedChanged
          } //TibiaCheckBox

          TibiaCheckBox {
            id:checkBoxShift
            text: qsTrId("optionsmenu_rotation_key_shift")
            shouldBeChecked: optionsSet != null && optionsSet.rotateWithShift
            onCheckedChanged: {
              if (optionsSet != null) {
                optionsSet.rotateWithShift = checked;
              }
            } //onCheckedChanged
          } //TibiaCheckBox

          TibiaCheckBox {
            id:checkBoxAlt
            text: qsTrId("optionsmenu_rotation_key_alt")
            Layout.fillWidth: true
            shouldBeChecked: optionsSet != null && optionsSet.rotateWithAlt
            onCheckedChanged: {
              if (optionsSet != null) {
                optionsSet.rotateWithAlt = checked;
              }
            } //onCheckedChanged
          } //TibiaCheckBox

          TibiaGuiHelp {
            text: qsTrId("optionsmenu_keys_for_rotation_tooltip")
          } //TibiaGuiHelp
        } //RowLayout

        RowLayout {
          id: alwaysTurnTowardsMoveDirection
          spacing: TibiaStyle.marginRelated

          TibiaCheckBox {
            text: qsTrId("optionsmenu_always_turn_towards_move_direction")
            Layout.fillWidth: true
            shouldBeChecked: optionsSet && optionsSet.alwaysTurnTowardsMoveDirection
            onCheckedChanged: {
              if (optionsSet != null) {
                optionsSet.alwaysTurnTowardsMoveDirection = checked;
              }
            } //onCheckedChanged
          } //TibiaMenuOptionCheckBox

          TibiaGuiHelp {
            text: qsTrId("optionsmenu_always_turn_towards_move_direction_help")
          } //TibiaGuiHelp
        } //RowLayout
      } //ColumnLayout
    } //TibiaFrame1PixelDownWithGuiHelp

    TibiaMenuOptionCheckBox {
      id: ctrlToDragStacks
      text: qsTrId("optionsmenu_drag_and_drop_default_action_is_ask_for_amount")
      guiHelpText: qsTrId("optionsmenu_drag_and_drop_default_action_is_ask_for_amount_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet && optionsSet.ctrlToDragStacks
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.ctrlToDragStacks = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox
  } //ColumnLayout
} //TibiaOptionsPage
