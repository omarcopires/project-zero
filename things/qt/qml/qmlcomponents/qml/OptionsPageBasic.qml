import QtQuick
import QtQuick.Layouts

import qmlcomponents


Item {
  id: root
  implicitWidth: 550
  implicitHeight: contentLayout.height

  clip: true

  KeyNavigation.tab: root

  property var controller: null
  property QtObject optionsSetControls: controller != null ? controller.controlsOptions : null
  property QtObject optionsSetGameplay: controller != null ? controller.gameplayOptions : null
  property QtObject optionsSetHud: controller != null ? controller.hudOptions : null
  property QtObject optionsSetActionBars: controller != null ? controller.actionBarsOptions : null
  property QtObject optionsSetGraphics: controller != null ? controller.graphicsOptions : null
  property QtObject optionsSetInterface: controller != null ? controller.interfaceOptions : null
  property QtObject optionsSetSound: controller != null ? controller.soundOptions : null
  readonly property int comboBoxWidth: TibiaStyle.comboboxOptionsWidth
  readonly property int __comboBoxLabelWidth: 150

  ColumnLayout {
    id: contentLayout
    anchors { left: parent.left; top: parent.top; right: parent.right }
    spacing: TibiaStyle.marginRelated

    TibiaFrame2PixelUpFilledWithCaption {
      caption: qsTrId("optionsmenu_gameplay")
      Layout.fillWidth: true
      Layout.preferredHeight: gameplayLayout.height + marginsToContent + topMarginToContent

      ColumnLayout {
        id: gameplayLayout
        anchors { left: parent.left; top: parent.top; right: parent.right }
        anchors.margins: parent.marginsToContent
        anchors.topMargin: parent.topMarginToContent
        spacing: TibiaStyle.marginRelated

        RowLayout {
          TibiaText {
            text: qsTrId("optionsmenu_mouse_preset")
            Layout.preferredWidth: __comboBoxLabelWidth
          } // TibiaText

          TibiaComboBox {
            id: controlScheme
            Layout.preferredWidth: root.comboBoxWidth
            model: optionsSetControls != null ? optionsSetControls.controlSchemeListModel : null
            shouldBeCurrentIndex: optionsSetControls != null ? optionsSetControls.controlSchemeIndex : 0
            onCurrentIndexChanged: {
              if (optionsSetControls != null) {
                optionsSetControls.controlSchemeIndex = currentIndex;
              }
            } //onCurrentIndexChanged
          } //TibiaComboBox

          TibiaComboBox {
            id: lootScheme
            Layout.preferredWidth: root.comboBoxWidth
            visible: optionsSetControls != null && optionsSetControls.controlSchemeIndex == 0
            model: optionsSetControls != null ? optionsSetControls.lootSchemeListModel : null
            shouldBeCurrentIndex: optionsSetControls != null ? optionsSetControls.lootSchemeIndex : 0
            onCurrentIndexChanged: {
              if (optionsSetControls != null) {
                optionsSetControls.lootSchemeIndex = currentIndex;
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

        TibiaMenuOptionCheckBox {
          id: allowAllToInspectPlayer
          text: qsTrId("optionsmenu_allow_all_to_inspect_player")
          guiHelpText: qsTrId("optionsmenu_allow_all_to_inspect_player_help")
          Layout.fillWidth: true
          shouldBeChecked: optionsSetGameplay && optionsSetGameplay.allowAllToInspectPlayer
          onCheckedChanged: {
            if (optionsSetGameplay != null) {
              optionsSetGameplay.allowAllToInspectPlayer = checked;
            }
          } //onCheckedChanged
        } //TibiaMenuOptionCheckBox

        TibiaMenuOptionCheckBox {
          id: autoChaseOff
          text: qsTrId("optionsmenu_auto_chase_off")
          guiHelpText: qsTrId("optionsmenu_auto_chase_off_help")
          Layout.fillWidth: true
          shouldBeChecked: optionsSetGameplay && optionsSetGameplay.autoChaseOff
          onCheckedChanged: {
            if (optionsSetGameplay != null) {
              optionsSetGameplay.autoChaseOff = checked;
            }
          } //onCheckedChanged
        } //TibiaMenuOptionCheckBox

        TibiaMenuOptionCheckBox {
          id: quickLootAllCorpsesInArea
          text: qsTrId("optionsmenu_quick_loot_all_corpses_in_area")
          guiHelpText: qsTrId("optionsmenu_quick_loot_all_corpses_in_area_help")
          Layout.fillWidth: true
          shouldBeChecked: optionsSetGameplay && optionsSetGameplay.quickLootAllCorpsesInArea
          onCheckedChanged: {
            if (optionsSetGameplay != null) {
              optionsSetGameplay.quickLootAllCorpsesInArea = checked;
            }
          } //onCheckedChanged
        } //TibiaMenuOptionCheckBox
      } //ColumnLayout
    } //TibiaFrame2PixelUpFilledWithCaption

    TibiaFrame2PixelUpFilledWithCaption {
      caption: qsTrId("optionsmenu_interface")
      Layout.fillWidth: true
      Layout.preferredHeight: interfaceLayout.height + marginsToContent + topMarginToContent

      ColumnLayout {
        id: interfaceLayout
        anchors { left: parent.left; top: parent.top; right: parent.right }
        anchors.margins: parent.marginsToContent
        anchors.topMargin: parent.topMarginToContent
        spacing: TibiaStyle.marginRelated

        RowLayout {
          spacing: TibiaStyle.marginRelated

          TibiaText{
            text: qsTrId("optionsmenu_hud_style")
            Layout.preferredWidth: __comboBoxLabelWidth
          } //TibiaText

          TibiaCheckBox {
            id: playerShowBars
            text: qsTrId("optionsmenu_show_bars")
            shouldBeChecked: optionsSetHud != null && optionsSetHud.playerHudShowBars
            onCheckedChanged: {
              if (optionsSetHud != null) {
                optionsSetHud.playerHudShowBars = checked;
              }
            } //onCheckedChanged
          } //TibiaCheckBox

          TibiaCheckBox {
            id: playerShowArcs
            Layout.leftMargin: TibiaStyle.marginRelated
            text: qsTrId("optionsmenu_show_arcs")
            shouldBeChecked: optionsSetHud != null && optionsSetHud.playerHudShowArcs
            onCheckedChanged: {
              if (optionsSetHud != null) {
                optionsSetHud.playerHudShowArcs = checked;
              }
            } //onCheckedChanged
          } //TibiaCheckBox

          Item {
            Layout.fillWidth: true
          } //Item

          TibiaGuiHelp {
            Layout.rightMargin: TibiaStyle.alignGuiHelpWithAndWithoutFrame //to align with the the otther GuiHelp icons
            useRichText: true
            text: qsTrId("optionsmenu_player_hud_besict_help")
          } //TibiaGuiHelp
        } //RowLayout

        OptionsPageActionBarsShowHideSection {
          Layout.fillWidth: true
          optionsSetActionBars: root.optionsSetActionBars
        } //OptionsPageActionBarsShowHideSection

        RowLayout {
          Layout.fillWidth: true
          spacing: TibiaStyle.marginRelated

          TibiaText{
            id: colorizeLootLabel
            text: qsTrId("optionsmenu_colorize_loot")
            Layout.preferredWidth: __comboBoxLabelWidth
          } //TibiaText

          TibiaComboBox {
            id: comboBoxColorizeLootStyle
            Layout.preferredWidth: root.comboBoxWidth
            Layout.preferredHeight: TibiaStyle.comboBoxHeight

            model: optionsSetInterface != null ? optionsSetInterface.colorizeLootStyleListModel : null

            shouldBeCurrentIndex: optionsSetInterface != null ? optionsSetInterface.colorizeLootStyleIndex : 0
            onCurrentIndexChanged: {
              if (optionsSetInterface != null) {
                optionsSetInterface.colorizeLootStyleIndex = currentIndex;
              }
            } //onCurrentIndexChanged

          } //ComboBox

          Item {
            Layout.fillWidth: true
          } //Item

          TibiaGuiHelp {
            Layout.rightMargin: TibiaStyle.marginRelated
            visible: text != ""
            text: qsTrId("optionsmenu_colorize_loot_help")
          } //TibiaGuiHelp

        } //RowLayout
      } //ColumnLayout
    } //TibiaFrame2PixelUpFilledWithCaption

    TibiaFrame2PixelUpFilledWithCaption {
      caption: qsTrId("optionsmenu_graphics")
      Layout.fillWidth: true
      Layout.preferredHeight: graphicsLayout.height + marginsToContent + topMarginToContent

      ColumnLayout {
        id: graphicsLayout
        anchors { left: parent.left; top: parent.top; right: parent.right }
        anchors.margins: parent.marginsToContent
        anchors.topMargin: parent.topMarginToContent
        spacing: TibiaStyle.marginRelated

        RowLayout {
          Layout.fillWidth: true
          spacing: TibiaStyle.marginRelated


          TibiaText{
            id: antialiasingModeLabel
            text: qsTrId("optionsmenu_antialiasing_mode")
            Layout.preferredWidth: __comboBoxLabelWidth

            Tooltip {
              id: antialiasingModeTooltip
              anchors.fill: parent
              text: qsTrId("optionsmenu_antialiasing_mode_help")
            } //Tooltip
          } //TibiaText


          TibiaComboBox {
            id: comboBoxAntialiasingMode
            Layout.preferredWidth: root.comboBoxWidth
            Layout.preferredHeight: TibiaStyle.comboBoxHeight

            model: optionsSetGraphics != null ? optionsSetGraphics.antialiasingModeListModel : null

            shouldBeCurrentIndex: optionsSetGraphics != null ? optionsSetGraphics.antialiasingModeIndex : 0
            onCurrentIndexChanged: {
              if (optionsSetGraphics != null) {
                optionsSetGraphics.antialiasingModeIndex = currentIndex;
              }
            } //onCurrentIndexChanged

            Tooltip {
              anchors.fill: parent
              text: antialiasingModeTooltip.text
              enabled: !comboBoxAntialiasingMode.down
            } //Tooltip
          } //ComboBox
          Item {
            Layout.fillWidth: true
          } //Item

          TibiaGuiHelp {
            Layout.rightMargin: TibiaStyle.marginRelated
            visible: text != ""
            text: qsTrId("optionsmenu_antialiasing_mode_help")
          } //TibiaGuiHelp
        }

        TibiaMenuOptionCheckBox {
          id: borderlessWindow
          text: qsTrId("optionsmenu_fullscreen")
          guiHelpText: qsTrId("optionsmenu_fullscreen_help")
          Layout.fillWidth: true
          shouldBeChecked: optionsSetGraphics != null && optionsSetGraphics.borderlessWindow
          onCheckedChanged: {
            if (optionsSetGraphics != null) {
              optionsSetGraphics.borderlessWindow = checked;
            }
          } //onCheckedChanged
        } //TibiaMenuOptionCheckBox
      } //ColumnLayout
    } //TibiaFrame2PixelUpFilledWithCaption

    TibiaFrame2PixelUpFilledWithCaption {
      caption: qsTrId("optionsmenu_sound")
      Layout.fillWidth: true
      Layout.preferredHeight: soundLayout.height + marginsToContent + topMarginToContent

      ColumnLayout {
        id: soundLayout
        anchors { left: parent.left; top: parent.top; right: parent.right }
        anchors.margins: parent.marginsToContent
        anchors.topMargin: parent.topMarginToContent
        spacing: TibiaStyle.marginRelated

        TibiaMenuSlider {
          Layout.fillWidth: true

          text: qsTrId("optionsmenu_sound_master_volume")
          withFrame: true
          unitSymbol: "%"
          minimumValue: 0
          maximumValue: 100
          offAtMinimum: true
          stepSize: 1
          shouldBeValue: optionsSetSound != null ? optionsSetSound.masterVolume : 0
          onValueChanged: {
            if (optionsSetSound != null) {
              optionsSetSound.masterVolume = value;
            }
          } //onValueChanged
        } //TibiaMenuSlider

      } //ColumnLayout
    } //TibiaFrame2PixelUpFilledWithCaption
  } //ColumnLayout

  TibiaButton {
    anchors { bottom: parent.bottom; right: parent.right }
    text: qsTrId("reset")
    tooltipText: qsTrId("optionsmenu_reset_tooltip")
    onClicked: {
      if (controller != null) {
        controller.requestResetCurrentPageToDefault();
      }
    } //onClicked
  } //TibiaButton
} //Item
