import QtQuick
import QtQuick.Layouts




TibiaOptionsPage {
  id: root
  implicitHeight: contentLayout.height

  optionsSet: controller != null ? controller.battleSoundsOptions : null
  property QtObject optionsSetSound: controller != null ? controller.soundOptions : null

  ColumnLayout {
    id: contentLayout
    anchors { left: parent.left; top: parent.top; right: parent.right }
    spacing: TibiaStyle.marginRelated

    TibiaText {
      Layout.fillWidth: true
      styleType: "MessageWarning"
      visible: optionsSetSound != null && !optionsSetSound.soundEnabled

      text: qsTrId("optionsmenu_sound_disabled_warning").arg(qsTrId("optionsmenu_sound"))
    } //TibiaText

    TibiaFrame1PixelDownWithGuiHelp {
      Layout.fillWidth: true
      Layout.preferredHeight: ownSoundLayout.height + 2 * marginsToContent
      guiHelpUseRichText: true
      //guiHelpText: qsTrId("optionsmenu_player_hud_help")
      enabled: optionsSetSound != null && optionsSetSound.soundEnabled

      ColumnLayout {
        id: ownSoundLayout
        anchors { left: parent.left; top: parent.top; right: parent.right }
        anchors.margins: parent.marginsToContent
        spacing: TibiaStyle.marginRelated

        TibiaMenuSlider {
          Layout.fillWidth: true

          text: qsTrId("optionsmenu_sound_own_volume")
          unitSymbol: "%"
          minimumValue: 0
          maximumValue: 100
          offAtMinimum: true
          stepSize: 1
          shouldBeValue: optionsSet != null ? optionsSet.ownVolume : 0
          onValueChanged: {
            if (optionsSet != null) {
              optionsSet.ownVolume = value;
            }
          } //onValueChanged
        } //TibiaMenuSlider

        ColumnLayout {
          spacing: TibiaStyle.marginRelated
          enabled: optionsSet != null && optionsSet.ownVolume > 0

          TibiaCheckBox {
            text: qsTrId("optionsmenu_sound_spells_enabled")
            Layout.topMargin: -1 //checkbox text height is one higher than the checbox icon
            shouldBeChecked: optionsSet != null && optionsSet.ownSpellsEnabled
            onCheckedChanged: {
              if (optionsSet != null) {
                optionsSet.ownSpellsEnabled = checked;
              }
            } //onCheckedChanged
          } //TibiaCheckBox

          ColumnLayout {
            Layout.leftMargin: TibiaStyle.paragraphIndentation
            spacing: TibiaStyle.marginRelated
            enabled: optionsSet != null && optionsSet.ownSpellsEnabled

            TibiaCheckBox {
              text: qsTrId("spell_attack")
              Layout.topMargin: -1 //checkbox text height is one higher than the checbox icon
              shouldBeChecked: optionsSet != null && optionsSet.ownAttackSpellsEnabled
              onCheckedChanged: {
                if (optionsSet != null) {
                  optionsSet.ownAttackSpellsEnabled = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckBox

            TibiaCheckBox {
              text: qsTrId("spell_healing")
              Layout.topMargin: -1 //checkbox text height is one higher than the checbox icon
              shouldBeChecked: optionsSet != null && optionsSet.ownHealingSpellsEnabled
              onCheckedChanged: {
                if (optionsSet != null) {
                  optionsSet.ownHealingSpellsEnabled = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckBox

            TibiaCheckBox {
              text: qsTrId("spell_support")
              Layout.topMargin: -1 //checkbox text height is one higher than the checbox icon
              shouldBeChecked: optionsSet != null && optionsSet.ownSupportSpellsEnabled
              onCheckedChanged: {
                if (optionsSet != null) {
                  optionsSet.ownSupportSpellsEnabled = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckBox
          } //ColumnLayout

          TibiaCheckBox {
            text: qsTrId("optionsmenu_sound_weapons_enabled")
            Layout.topMargin: -1 //checkbox text height is one higher than the checbox icon
            shouldBeChecked: optionsSet != null && optionsSet.ownWeaponsEnabled
            onCheckedChanged: {
              if (optionsSet != null) {
                optionsSet.ownWeaponsEnabled = checked;
              }
            } //onCheckedChanged
          } //TibiaCheckBox
        } //ColumnLayout
      } //ColumnLayout
    } //TibiaFrame1PixelDownWithGuiHelp

    TibiaFrame1PixelDownWithGuiHelp {
      Layout.fillWidth: true
      Layout.preferredHeight: othersSoundLayout.height + 2 * marginsToContent
      guiHelpUseRichText: true
      //guiHelpText: qsTrId("optionsmenu_player_hud_help")
      enabled: optionsSetSound != null && optionsSetSound.soundEnabled

      ColumnLayout {
        id: othersSoundLayout
        anchors { left: parent.left; top: parent.top; right: parent.right }
        anchors.margins: parent.marginsToContent
        spacing: TibiaStyle.marginRelated

        TibiaMenuSlider {
          Layout.fillWidth: true

          text: qsTrId("optionsmenu_sound_others_volume")
          unitSymbol: "%"
          minimumValue: 0
          maximumValue: 100
          offAtMinimum: true
          stepSize: 1
          shouldBeValue: optionsSet != null ? optionsSet.othersVolume : 0
          onValueChanged: {
            if (optionsSet != null) {
              optionsSet.othersVolume = value;
            }
          } //onValueChanged
        } //TibiaMenuSlider

        ColumnLayout {
          spacing: TibiaStyle.marginRelated
          enabled: optionsSet != null && optionsSet.othersVolume > 0

          TibiaCheckBox {
            text: qsTrId("optionsmenu_sound_spells_enabled")
            Layout.topMargin: -1 //checkbox text height is one higher than the checbox icon
            shouldBeChecked: optionsSet != null && optionsSet.othersSpellsEnabled
            onCheckedChanged: {
              if (optionsSet != null) {
                optionsSet.othersSpellsEnabled = checked;
              }
            } //onCheckedChanged
          } //TibiaCheckBox

          ColumnLayout {
            Layout.leftMargin: TibiaStyle.paragraphIndentation
            spacing: TibiaStyle.marginRelated
            enabled: optionsSet != null && optionsSet.othersSpellsEnabled

            TibiaCheckBox {
              text: qsTrId("spell_attack")
              Layout.topMargin: -1 //checkbox text height is one higher than the checbox icon
              shouldBeChecked: optionsSet != null && optionsSet.othersAttackSpellsEnabled
              onCheckedChanged: {
                if (optionsSet != null) {
                  optionsSet.othersAttackSpellsEnabled = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckBox

            TibiaCheckBox {
              text: qsTrId("spell_healing")
              Layout.topMargin: -1 //checkbox text height is one higher than the checbox icon
              shouldBeChecked: optionsSet != null && optionsSet.othersHealingSpellsEnabled
              onCheckedChanged: {
                if (optionsSet != null) {
                  optionsSet.othersHealingSpellsEnabled = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckBox

            TibiaCheckBox {
              text: qsTrId("spell_support")
              Layout.topMargin: -1 //checkbox text height is one higher than the checbox icon
              shouldBeChecked: optionsSet != null && optionsSet.othersSupportSpellsEnabled
              onCheckedChanged: {
                if (optionsSet != null) {
                  optionsSet.othersSupportSpellsEnabled = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckBox
          } //ColumnLayout

          TibiaCheckBox {
            text: qsTrId("optionsmenu_sound_weapons_enabled")
            Layout.topMargin: -1 //checkbox text height is one higher than the checbox icon
            shouldBeChecked: optionsSet != null && optionsSet.othersWeaponsEnabled
            onCheckedChanged: {
              if (optionsSet != null) {
                optionsSet.othersWeaponsEnabled = checked;
              }
            } //onCheckedChanged
          } //TibiaCheckBox
        } //ColumnLayout
      } //ColumnLayout
    } //TibiaFrame1PixelDownWithGuiHelp

    TibiaFrame1PixelDownWithGuiHelp {
      Layout.fillWidth: true
      Layout.preferredHeight: creaturesSoundLayout.height + 2 * marginsToContent
      guiHelpUseRichText: true
      //guiHelpText: qsTrId("optionsmenu_player_hud_help")
      enabled: optionsSetSound != null && optionsSetSound.soundEnabled

      ColumnLayout {
        id: creaturesSoundLayout
        anchors { left: parent.left; top: parent.top; right: parent.right }
        anchors.margins: parent.marginsToContent
        spacing: TibiaStyle.marginRelated

        TibiaMenuSlider {
          Layout.fillWidth: true

          text: qsTrId("optionsmenu_sound_creatures_volume")
          unitSymbol: "%"
          minimumValue: 0
          maximumValue: 100
          offAtMinimum: true
          stepSize: 1
          shouldBeValue: optionsSet != null ? optionsSet.creaturesVolume : 0
          onValueChanged: {
            if (optionsSet != null) {
              optionsSet.creaturesVolume = value;
            }
          } //onValueChanged
        } //TibiaMenuSlider

        ColumnLayout {
          spacing: TibiaStyle.marginRelated
          enabled: optionsSet != null && optionsSet.creaturesVolume > 0

          TibiaCheckBox {
            text: qsTrId("optionsmenu_sound_creatures_noises_enabled")
            Layout.topMargin: -1 //checkbox text height is one higher than the checbox icon
            shouldBeChecked: optionsSet != null && optionsSet.creaturesNoisesEnabled
            onCheckedChanged: {
              if (optionsSet != null) {
                optionsSet.creaturesNoisesEnabled = checked;
              }
            } //onCheckedChanged
          } //TibiaCheckBox

          TibiaCheckBox {
            text: qsTrId("optionsmenu_sound_creatures_death_enabled")
            Layout.topMargin: -1 //checkbox text height is one higher than the checbox icon
            shouldBeChecked: optionsSet != null && optionsSet.creaturesDeathEnabled
            onCheckedChanged: {
              if (optionsSet != null) {
                optionsSet.creaturesDeathEnabled = checked;
              }
            } //onCheckedChanged
          } //TibiaCheckBox

          TibiaCheckBox {
            text: qsTrId("optionsmenu_sound_creatures_attacks_enabled")
            Layout.topMargin: -1 //checkbox text height is one higher than the checbox icon
            shouldBeChecked: optionsSet != null && optionsSet.creaturesAttacksEnabled
            onCheckedChanged: {
              if (optionsSet != null) {
                optionsSet.creaturesAttacksEnabled = checked;
              }
            } //onCheckedChanged
          } //TibiaCheckBox
        } //ColumnLayout
      } //ColumnLayout
    } //TibiaFrame1PixelDownWithGuiHelp


  } //ColumnLayout
} //TibiaOptionsPage
