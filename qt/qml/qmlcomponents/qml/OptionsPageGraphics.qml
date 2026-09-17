import QtQuick
import QtQuick.Layouts

import qmlcomponents


TibiaOptionsPage {
  id: root
  implicitHeight: contentLayout.height

  optionsSet: controller.graphicsOptions

  ColumnLayout {
    id: contentLayout
    anchors { left: parent.left; top: parent.top; right: parent.right }
    spacing: TibiaStyle.marginRelated

    RowLayout {
      Layout.fillWidth: true
      spacing: TibiaStyle.marginRelated

      TibiaText{
        id: graphicsEngineLabel
        Layout.preferredWidth: Math.max(antialiasingModeLabel.width, graphicsEngineLabel.width)
        text: qsTrId("optionsmenu_engine")

        Tooltip {
          id: graphicsEngineTooltip
          anchors.fill: parent
          text: qsTrId("optionsmenu_engine_tooltip")
        } //Tooltip
      } //TibiaText

      TibiaComboBox {
        id: comboBoxRenderer
        Layout.preferredWidth: TibiaStyle.buttonWidthExtraWide
        Layout.preferredHeight: TibiaStyle.comboBoxHeight

        model: optionsSet.rendererListModel

        shouldBeCurrentIndex: optionsSet.rendererIndex
        onActivated: (index) => {
          optionsSet.rendererIndex = index;
        } //onActivated

        Tooltip {
          anchors.fill: parent
          text: graphicsEngineTooltip.text
          enabled: !comboBoxRenderer.down
        } //Tooltip
      } //ComboBox

      Item {
        Layout.fillWidth: true
      } //Item

      TibiaGuiHelp {
        Layout.rightMargin: TibiaStyle.marginRelated
        visible: text != ""
        text: optionsSet.tooltipTextDisabledRenderers
      } //TibiaGuiHelp

    } //RowLayout

    RowLayout {
      Layout.fillWidth: true
      spacing: TibiaStyle.marginRelated


      TibiaText{
        id: antialiasingModeLabel
        text: qsTrId("optionsmenu_antialiasing_mode")
        Layout.preferredWidth: Math.max(antialiasingModeLabel.width, graphicsEngineLabel.width)

        Tooltip {
          id: antialiasingModeTooltip
          anchors.fill: parent
          text: qsTrId("optionsmenu_antialiasing_mode_help")
        } //Tooltip
      } //TibiaText


      TibiaComboBox {
        id: comboBoxAntialiasingMode
        Layout.preferredWidth: TibiaStyle.buttonWidthExtraWide
        Layout.preferredHeight: TibiaStyle.comboBoxHeight

        model: optionsSet.antialiasingModeListModel

        shouldBeCurrentIndex: optionsSet.antialiasingModeIndex
        onCurrentIndexChanged: {
          optionsSet.antialiasingModeIndex = currentIndex;
        } //onCurrentIndexChanged

        Tooltip {
          anchors.fill: parent
          text: antialiasingModeTooltip.text
          maxWidth: TibiaStyle.tooltipRestrictedWidth
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
      shouldBeChecked: optionsSet.borderlessWindow
      onCheckedChanged: {
        optionsSet.borderlessWindow = checked;
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: scaleOnlyByEvenMultiples
      text: qsTrId("optionsmenu_game_window_scale_only_by_even_multiples")
      guiHelpText: qsTrId("optionsmenu_game_window_scale_only_by_even_multiples_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet.scaleOnlyByEvenMultiples
      onCheckedChanged: {
        optionsSet.scaleOnlyByEvenMultiples = checked;
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaFrame1PixelDown {
      Layout.fillWidth: true
      Layout.preferredHeight: frameRateLayout.height + 2 * marginsToContent

      ColumnLayout {
        id: frameRateLayout
        anchors { left: parent.left; top: parent.top; right: parent.right }
        anchors.margins: parent.marginsToContent
        spacing: TibiaStyle.marginRelated

        RowLayout {
          Layout.topMargin: -1 //checkbox text height is one higher than the checbox icon
          spacing: TibiaStyle.marginRelated

          TibiaCheckBox {
            id: vSync
            text: qsTrId("optionsmenu_vsync")
            Layout.fillWidth: true
            enabled: !optionsSet.rendererLimitationsActive
            shouldBeChecked: optionsSet.vSync
            onCheckedChanged: {
              optionsSet.vSync = checked;
            } //onCheckedChanged
          } //TibiaCheckBox

          TibiaGuiHelp {
            text: (optionsSet.rendererLimitationsActive ? qsTrId("optionsmenu_option_not_available_for_active_renderer")
                                                        : "")
                                                        + qsTrId("optionsmenu_vsync_help")
          } //TibiaGuiHelp
        } //RowLayout

        RowLayout {
          spacing: TibiaStyle.marginRelated
          Layout.leftMargin: vSync.indicator.width + vSync.spacing
          visible: optionsSet.isMetal

          TibiaText {
            Layout.fillWidth: true
            styleType: "MessageWarning"
            visible: optionsSet.isMetal

            text: qsTrId("optionsmenu_vsync_disable_macos_warning")
          } //TibiaText
        } //RowLayout

        RowLayout {
          spacing: TibiaStyle.marginRelated

          TibiaCheckBox {
            id: noFpsLimitEnabled
            text: qsTrId("optionsmenu_disable_fps_limit")
            Layout.fillWidth: true
            shouldBeChecked: optionsSet.noFpsLimitEnabled
            enabled: optionsSet.canChangeFpsLimitCheckbox
            onCheckedChanged: {
              optionsSet.noFpsLimitEnabled = checked;
            } //onCheckedChanged
          } //TibiaCheckBox

          TibiaGuiHelp {
            text: qsTrId("optionsmenu_disable_fps_limit_help")
          } //TibiaGuiHelp
        } //RowLayout

        RowLayout {
          spacing: TibiaStyle.marginRelated
          Layout.leftMargin: TibiaStyle.paragraphIndentation

          TibiaMenuSlider {
            id: frameRateLimit
            enabled: !noFpsLimitEnabled.checked
            Layout.fillWidth: true

            text: qsTrId("optionsmenu_framerate_limit")
            minimumValue: 10
            maximumValue: 200
            stepSize: 1
            shouldBeValue: optionsSet.fpsLimit
            onValueChanged: {
              optionsSet.fpsLimit = value;
            } //onValueChanged
          } //TibiaMenuSlider
          TibiaGuiHelp {
              text: qsTrId("optionsmenu_framerate_limit_help")
          } //TibiaGuiHelp
        } //RowLayout

        RowLayout {
          spacing: TibiaStyle.marginRelated
          Layout.leftMargin: TibiaStyle.paragraphIndentation

          TibiaText {
            text: qsTrId("optionsmenu_fps_display").arg(controller !=null ? controller.currentFrameRate : "-")
            Layout.fillWidth: true
          } //TibiaText

          TibiaGuiHelp {
              text: qsTrId("optionsmenu_fps_display_help")
          } //TibiaGuiHelp
        } // RowLayout
      } //ColumnLayout
    } //TibiaFrame1PixelDown
  } //ColumnLayout
} //TibiaOptionsPage
