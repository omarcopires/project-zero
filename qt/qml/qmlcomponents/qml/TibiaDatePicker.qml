import QtQuick
import QtQuick.Layouts

import qmlcomponents


RowLayout {
  id: root
  Layout.fillWidth: true
  spacing: TibiaStyle.marginNarrow

  property int numberOfPossibleYears: 2
  readonly property int day: Number(dayPicker.currentText)
  readonly property int month: Number(monthPicker.currentText)
  readonly property int year: Number(yearPicker.currentText)
  property date selectedDate: new Date()

  onDayChanged: {
    root.selectedDate = new Date(root.year,
                                 root.month-1,
                                 root.day);
  } //onDayChanged

  onMonthChanged: updateDaysInMonthModelTimer.restart()
  onYearChanged: updateDaysInMonthModelTimer.restart()

  Component.onCompleted: {
    var tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate()+1);

    var years = [];
    for (var i = 0; i < root.numberOfPossibleYears; ++i) {
      years[years.length] = tomorrow.getFullYear() + i;
    }

    yearPicker.model = years;
    monthPicker.currentIndex = tomorrow.getMonth(); //0-11
    dayPicker.currentIndex = tomorrow.getDate() -1; //1-31

    updateDaysInMonthModelTimer.running = false;
  } //Component.onCompleted

  Timer {
    id: updateDaysInMonthModelTimer
    repeat: false
    interval: 1
    onTriggered: {
      //Timer is needed as calling a function in the onChanged handlers leads to access of an unitialized value
      var selectedMonth = new Date(root.year,
                                   root.month-1,
                                   1);
      var nextMonth = new Date(selectedMonth.getFullYear(),
                               selectedMonth.getMonth()+1,
                               0);

      if (dayPicker.model == null || dayPicker.model.length != nextMonth.getDate()) {
        var daysOfMonth = [];
        for (var i = 1; i <= nextMonth.getDate(); ++i) {
          daysOfMonth[daysOfMonth.length] = i;
        }
        var selectedDayIndex = dayPicker.currentIndex;
        dayPicker.model = daysOfMonth;
        dayPicker.currentIndex = selectedDayIndex < daysOfMonth.length ? selectedDayIndex : 0;
      }
      root.selectedDate = new Date(root.year,
                                   root.month-1,
                                   root.day);
    } //onTriggered
  } //Timer

  TibiaComboBox {
    id: yearPicker
    Layout.preferredWidth: 70
    model: [2019]
  } //TibiaComboBox

  TibiaText {
    text: "-"
  } //TibiaText

  TibiaComboBox {
    id: monthPicker
    Layout.preferredWidth: 50
    model: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
  } //TibiaComboBox

  TibiaText {
    text: "-"
  } //TibiaText

  TibiaComboBox {
    id: dayPicker
    Layout.preferredWidth: 50
    model: Array.from({ length: 31 }, (_, index) => index + 1)
  } //TibiaComboBox

} //RowLayout
