import QtQuick
import QtQuick.Layouts




TibiaOptionsPage {
  id: root
  implicitHeight: contentLayout.height

  optionsSet: controller != null ? controller.effectsOptions : null

  ColumnLayout {
    id: contentLayout
    anchors { left: parent.left; top: parent.top; right: parent.right }
    spacing: TibiaStyle.marginRelated

    TibiaFrame1PixelDown {
      Layout.fillWidth: true
      Layout.preferredHeight: effectsLayout.height + 2 * marginsToContent

      ColumnLayout {
        id: effectsLayout
        anchors { left: parent.left; top: parent.top; right: parent.right }
        anchors.margins: parent.marginsToContent
        spacing: TibiaStyle.marginRelated

        RowLayout {
          Layout.topMargin: -1 //checkbox text height is one higher than the checbox icon
          spacing: TibiaStyle.marginRelated

          TibiaCheckBox {
            id: lightEffectsEnabled
            text: qsTrId("optionsmenu_show_light_effects")
            Layout.fillWidth: true
            enabled: optionsSet != null && !optionsSet.rendererLimitationsActive
            shouldBeChecked: optionsSet != null && optionsSet.lightEffects
            onCheckedChanged: {
              if (optionsSet != null) {
                optionsSet.lightEffects = checked;
              }
            } //onCheckedChanged
          } //TibiaCheckBox

          TibiaGuiHelp {
            useRichText: true
            text: (optionsSet != null && optionsSet.rendererLimitationsActive ? qsTrId("optionsmenu_option_not_available_for_active_renderer")
                                                                              : "")
                                                                              + qsTrId("optionsmenu_light_effects_help")
          } //TibiaGuiHelp
        } //RowLayout

        ColumnLayout {
          spacing: TibiaStyle.marginRelated
          Layout.fillWidth: true
          Layout.leftMargin: TibiaStyle.paragraphIndentation
          Layout.rightMargin: TibiaStyle.noGuiHelphIndentation
          enabled: lightEffectsEnabled.checked

          TibiaMenuSlider {
            id: ambientLightSlider
            Layout.fillWidth: true

            text: qsTrId("optionsmenu_ambient_light")
            unitSymbol: "%"
            minimumValue: 0
            maximumValue: 100
            stepSize: 1
            shouldBeValue: optionsSet != null ? optionsSet.ambientLightLevel : 0
            onValueChanged: {
              if (optionsSet != null) {
                optionsSet.ambientLightLevel = value;
              }
            } //onValueChanged
          } //TibiaMenuSlider

          TibiaMenuSlider {
            id: levelSeparatorSlider
            Layout.fillWidth: true

            text: qsTrId("optionsmenu_level_separator")
            unitSymbol: "%"
            minimumValue: 0
            maximumValue: 100
            stepSize: 1
            shouldBeValue: optionsSet != null ? optionsSet.levelSeparatorLevel : 0
            onValueChanged: {
              if (optionsSet != null) {
                optionsSet.levelSeparatorLevel = value;
              }
            } //onValueChanged
          } //TibiaMenuSlider

          TibiaMenuSlider {
            id: lightAttenuationCloudsAndIndoorSlider
            Layout.fillWidth: true

            text: qsTrId("optionsmenu_light_attenuation_clouds")
            unitSymbol: "%"
            minimumValue: 0
            maximumValue: 100
            offAtMinimum: true
            stepSize: 1
            shouldBeValue: optionsSet != null ? optionsSet.lightAttenuationCloudsIndoor : 0
            onValueChanged: {
              if (optionsSet != null) {
                optionsSet.lightAttenuationCloudsIndoor = value;
              }
            } //onValueChanged
          } //TibiaMenuSlider
        } //ColumnLayout
      } //ColumnLayout
    } //TibiaFrame1PixelDown

    TibiaFrame1PixelDown {
      Layout.fillWidth: true
      Layout.preferredHeight: effectsOpacityLayout.height + 2 * marginsToContent

      ColumnLayout {
        id: effectsOpacityLayout
        anchors { left: parent.left; top: parent.top; right: parent.right }
        anchors.margins: parent.marginsToContent
        spacing: TibiaStyle.marginRelated

        RowLayout {
          Layout.topMargin: -1 //checkbox text height is one higher than the checbox icon
          spacing: TibiaStyle.marginRelated

          TibiaText {
            text: qsTrId("optionsmenu_effects_opacity")
            Layout.fillWidth: true
          } //TibiaText

          TibiaGuiHelp {
            useRichText: true
            text: (optionsSet != null && optionsSet.rendererLimitationsActive ? qsTrId("optionsmenu_option_not_available_for_active_renderer")
                : "")
              + qsTrId("optionsmenu_effects_opacity_help")
          } //TibiaGuiHelp
        } //RowLayout

        ColumnLayout {
          spacing: TibiaStyle.marginRelated
          Layout.fillWidth: true
          Layout.leftMargin: TibiaStyle.paragraphIndentation
          Layout.rightMargin: TibiaStyle.noGuiHelphIndentation

          TibiaMenuSlider {
            Layout.fillWidth: true

            text: qsTrId("optionsmenu_own_effects_opacity")
            unitSymbol: "%"
            minimumValue: 0
            maximumValue: 100
            stepSize: 1
            shouldBeValue: optionsSet != null ? optionsSet.ownEffectsOpacity : 0
            onValueChanged: {
              if (optionsSet != null) {
                optionsSet.ownEffectsOpacity = value;
              }
            } //onValueChanged
          } //TibiaMenuSlider

          TibiaMenuSlider {
            id: otherPlayersEffectsOpacitySlider
            Layout.fillWidth: true

            text: qsTrId("optionsmenu_other_players_effects_opacity")
            unitSymbol: "%"
            minimumValue: 0
            maximumValue: 100
            stepSize: 1
            shouldBeValue: optionsSet != null ? optionsSet.otherPlayersEffectsOpacity : 0
            onValueChanged: {
              if (optionsSet != null) {
                optionsSet.otherPlayersEffectsOpacity = value;
              }
            } //onValueChanged
          } //TibiaMenuSlider

          TibiaMenuSlider {
            id: monsterEffectsOpacitySlider
            Layout.fillWidth: true

            text: qsTrId("optionsmenu_monster_effects_opacity")
            unitSymbol: "%"
            minimumValue: 0
            maximumValue: 100
            stepSize: 1
            shouldBeValue: optionsSet != null ? optionsSet.monsterEffectsOpacity : 0
            onValueChanged: {
              if (optionsSet != null) {
                optionsSet.monsterEffectsOpacity = value;
              }
            } //onValueChanged
          } //TibiaMenuSlider

          TibiaMenuSlider {
            id: monsterBossAreaEffectsOpacitySlider
            Layout.fillWidth: true

            text: qsTrId("optionsmenu_monster_bossarea_effects_opacity")
            unitSymbol: "%"
            minimumValue: 0
            maximumValue: 100
            stepSize: 1
            shouldBeValue: optionsSet != null ? optionsSet.monsterBossAreaEffectsOpacity : 0
            onValueChanged: {
              if (optionsSet != null) {
                optionsSet.monsterBossAreaEffectsOpacity = value;
              }
            } //onValueChanged
          } //TibiaMenuSlider
        } //ColumnLayout
      } //ColumnLayout
    } //TibiaFrame1PixelDown
  } //ColumnLayout
} //TibiaOptionsPage
