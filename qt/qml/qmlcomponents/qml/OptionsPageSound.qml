import QtQuick
import QtQuick.Layouts




TibiaOptionsPage {
  id: root
  implicitHeight: contentLayout.height

  optionsSet: controller != null ? controller.soundOptions : null
  readonly property int volumeSliderSmallWidth: 118
  enabled: optionsSet != null && optionsSet.soundEngineInitialized

  ColumnLayout {
    id: contentLayout
    anchors { left: parent.left; top: parent.top; right: parent.right }
    spacing: TibiaStyle.marginRelated

    RowLayout {
      TibiaText {
        Layout.rightMargin: TibiaStyle.marginUnrelated
        text: qsTrId("optionsmenu_sound_used_sound_device")
        Tooltip {
          id: soundDeviceTooltip
          anchors.fill: parent
          text: qsTrId("optionsmenu_sound_used_sound_device_tooltip")
        } //Tooltip
      }

      TibiaComboBox {
        id: comboBoxSoundDevice
        Layout.fillWidth: true
        Layout.preferredHeight: TibiaStyle.comboBoxHeight

        model: optionsSet.soundDeviceListModel

        onModelChanged: {
          let index = 0;
          if (model) {
            var newShouldBeIndex = shouldBeCurrentIndex;
            model.forEach( (item, index) => {
              if (item === optionsSet.soundDevice) {
                newShouldBeIndex = index;
                return;
              }
            });
            shouldBeCurrentIndex = newShouldBeIndex;
          }
        }

        onActivated: (index) => {
          optionsSet.soundDevice = model[index];
        } //onActivated

        Tooltip {
          anchors.fill: parent
          text: soundDeviceTooltip.text
          enabled: root.enabled
        } //Tooltip
      } //ComboBox
    }


    TibiaMenuSlider {
      Layout.fillWidth: true

      text: qsTrId("optionsmenu_sound_master_volume")
      withFrame: true
      unitSymbol: "%"
      minimumValue: 0
      maximumValue: 100
      offAtMinimum: true
      reserverGuiHelpSpace: true
      stepSize: 1
      shouldBeValue: optionsSet != null ? optionsSet.masterVolume : 0
      disabled: root.enabled == false
      onValueChanged: {
        if (optionsSet != null) {
          optionsSet.masterVolume = value;
        }
      } //onValueChanged
    } //TibiaMenuSlider

    ColumnLayout {
      id: subLayout
      Layout.fillWidth: true
      spacing: TibiaStyle.marginRelated
      property bool disabled: optionsSet != null && !optionsSet.soundEnabled

      TibiaFrame1PixelDownWithGuiHelp {
        Layout.fillWidth: true
        Layout.preferredHeight: musicLayout.height + 2 * marginsToContent

        ColumnLayout {
          id: musicLayout
          anchors { left: parent.left; top: parent.top; right: parent.right }
          anchors.margins: parent.marginsToContent
          spacing: TibiaStyle.marginRelated

          TibiaMenuSlider {
            Layout.fillWidth: true
            disabled: subLayout.disabled

            text: qsTrId("optionsmenu_sound_music_volume")
            unitSymbol: "%"
            minimumValue: 0
            maximumValue: 100
            offAtMinimum: true
            reserverGuiHelpSpace: true
            stepSize: 1
            shouldBeValue: optionsSet != null ? optionsSet.musicVolume : 0
            onValueChanged: {
              if (optionsSet != null) {
                optionsSet.musicVolume = value;
              }
            } //onValueChanged
          } //TibiaMenuSlider

          TibiaCheckBox {
            text: qsTrId("optionsmenu_sound_anthem_enabled")
            Layout.fillWidth: true
            Layout.topMargin: -1 //checkbox text height is one higher than the checbox icon
            enabled: optionsSet != null && optionsSet.musicVolume > 0 && !subLayout.disabled
            shouldBeChecked: optionsSet != null && optionsSet.anthemEnabled
            onCheckedChanged: {
              if (optionsSet != null) {
                optionsSet.anthemEnabled = checked;
              }
            } //onCheckedChanged
          } //TibiaCheckBox
        } //ColumnLayout
      } //TibiaFrame1PixelDownWithGuiHelp

      TibiaMenuSlider {
        Layout.fillWidth: true
        disabled: subLayout.disabled

        text: qsTrId("optionsmenu_sound_ambience_volume")
        withFrame: true
        unitSymbol: "%"
        minimumValue: 0
        maximumValue: 100
        offAtMinimum: true
        reserverGuiHelpSpace: true
        stepSize: 1
        shouldBeValue: optionsSet != null ? optionsSet.ambienceVolume : 0
        onValueChanged: {
          if (optionsSet != null) {
            optionsSet.ambienceVolume = value;
          }
        } //onValueChanged
      } //TibiaMenuSlider

      TibiaFrame1PixelDownWithGuiHelp {
        Layout.fillWidth: true
        Layout.preferredHeight: itemsLayout.height + 2 * marginsToContent

        ColumnLayout {
          id: itemsLayout
          anchors { left: parent.left; top: parent.top; right: parent.right }
          anchors.margins: parent.marginsToContent
          spacing: TibiaStyle.marginRelated

          TibiaMenuSlider {
            Layout.fillWidth: true
            disabled: subLayout.disabled

            text: qsTrId("optionsmenu_sound_items_volume")
            unitSymbol: "%"
            minimumValue: 0
            maximumValue: 100
            offAtMinimum: true
            reserverGuiHelpSpace: true
            stepSize: 1
            shouldBeValue: optionsSet != null ? optionsSet.itemsVolume : 0
            onValueChanged: {
              if (optionsSet != null) {
                optionsSet.itemsVolume = value;
              }
            } //onValueChanged
          } //TibiaMenuSlider

          ColumnLayout {
            spacing: TibiaStyle.marginRelated
            enabled: optionsSet != null && optionsSet.itemsVolume > 0 && !subLayout.disabled

            TibiaCheckBox {
              text: qsTrId("optionsmenu_sound_eating_enabled")
              Layout.fillWidth: true
              Layout.topMargin: -1 //checkbox text height is one higher than the checbox icon
              shouldBeChecked: optionsSet != null && optionsSet.eatingEnabled
              onCheckedChanged: {
                if (optionsSet != null) {
                  optionsSet.eatingEnabled = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckBox

            TibiaCheckBox {
              text: qsTrId("optionsmenu_sound_move_item_enabled")
              Layout.fillWidth: true
              Layout.topMargin: -1 //checkbox text height is one higher than the checbox icon
              shouldBeChecked: optionsSet != null && optionsSet.moveItemEnabled
              onCheckedChanged: {
                if (optionsSet != null) {
                  optionsSet.moveItemEnabled = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckBox
          } //ColumnLayout
        } //ColumnLayout
      } //TibiaFrame1PixelDownWithGuiHelp

      TibiaMenuSlider {
        Layout.fillWidth: true
        disabled: subLayout.disabled

        text: qsTrId("optionsmenu_sound_events_volume")
        withFrame: true
        unitSymbol: "%"
        minimumValue: 0
        maximumValue: 100
        offAtMinimum: true
        guiHelpText: qsTrId("optionsmenu_sound_events_volume_info")
        reserverGuiHelpSpace: true
        stepSize: 1
        shouldBeValue: optionsSet != null ? optionsSet.eventsVolume : 0
        onValueChanged: {
          if (optionsSet != null) {
            optionsSet.eventsVolume = value;
          }
        } //onValueChanged
      } //TibiaMenuSlider
    } //ColumnLayout
  } //ColumnLayout
} //TibiaOptionsPage
