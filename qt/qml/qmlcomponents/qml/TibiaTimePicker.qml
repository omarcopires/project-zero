import QtQuick
import QtQuick.Layouts

import qmlcomponents


RowLayout {
  id: root
  spacing: TibiaStyle.marginNarrow

  readonly property int hour: hourPicker.value >= 0 ? hourPicker.value : -1
  readonly property int minute: minutePicker.value >= 0 ? minutePicker.value : -1

  property int shouldBeHour: -1
  property int shouldBeMinute: -1
  onShouldBeHourChanged: {
    if (0 <= shouldBeHour && shouldBeHour < 24) {
      hourPicker.shouldBeCurrentIndex = shouldBeHour + 1;
    } else {
      hourPicker.shouldBeCurrentIndex = 0;
    }
  } //onShouldBeHourChanged
  onShouldBeMinuteChanged: {
    if (0 <= shouldBeMinute && shouldBeMinute < 60) {
      minutePicker.shouldBeCurrentIndex = Math.floor(shouldBeMinute / 15) + 1;
    } else {
      minutePicker.shouldBeCurrentIndex = 0;
    }
  } //onShouldBeMinuteChanged

  function reset() {
    hourPicker.currentIndex = 0;
    minutePicker.currentIndex = 0;
  } //function reset()

  TibiaComboBox {
    id: hourPicker
    Layout.preferredWidth: 50
    readonly property int value: parseInt(currentText)
    model: [ "--",
             "00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11",
             "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23" ]
  } //TibiaComboBox

  TibiaText {
    text: ":"
  } //TibiaText

  TibiaComboBox {
    id: minutePicker
    Layout.preferredWidth: 50
    readonly property int value: parseInt(currentText)
    model: ["--", "00", "15", "30", "45"]
  } //TibiaComboBox
} //RowLayout
