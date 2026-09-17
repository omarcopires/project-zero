import QtQuick
import QtQuick.Layouts

import qmlcomponents
import "qrc:/qt/qml/qmlcomponents/qml/"

ColumnLayout {
  property int auctionEndTimestamp: 0
  property int selectedAuctionEndTimestamp: 0

  property int minimumAuctionEndTimestamp: 0
  property int maximumAuctionEndTimestamp: 0

  property var _auctionEndDate: new Date()
  property int _auctionEndHour: 0
  property int _auctionEndMinute: 0

  Timer {
    id: updateTimer
    property var newAuctionEndTimestamp: 0
    interval: 0
    repeat: false
    onTriggered: {
      var tempTimestamp = calculateRoundedAndClampedTimestamp(newAuctionEndTimestamp);
      var newAuctionEndDate = new Date(tempTimestamp * 1000);
      dayPicker.selectedDate = newAuctionEndDate;
      _auctionEndDate = newAuctionEndDate;
      _auctionEndHour = newAuctionEndDate.getHours();
      _auctionEndMinute = newAuctionEndDate.getMinutes();
      selectedAuctionEndTimestamp = newAuctionEndDate.getTime() / 1000;
      refreshPickedDate();
    }
  }

  onAuctionEndTimestampChanged: {
    var newAuctionEndDate = new Date(auctionEndTimestamp * 1000);
    _auctionEndDate = newAuctionEndDate;
    _auctionEndHour = newAuctionEndDate.getHours();
    _auctionEndMinute = newAuctionEndDate.getMinutes();
    refreshPickedDate();
  }

  property var _minimumAuctionDate: {
    return new Date(minimumAuctionEndTimestamp * 1000);
  }

  property var _maximumAuctionDate: {
    return new Date(maximumAuctionEndTimestamp * 1000);
  }

  function refreshAuctionEndTimestamp() {
    var newDate = dayPicker.selectedDate;
    newDate.setHours(hourPicker.value, minutePicker.value, 0, 0);

    var newDateTimestamp = Math.round(newDate.getTime() / 1000);
    if (newDateTimestamp != selectedAuctionEndTimestamp) {
      updateTimer.newAuctionEndTimestamp = newDateTimestamp;
      updateTimer.start();
    }
  }

  function refreshPickedDate() {
    timePicker.shouldBeHour = _auctionEndHour;
    timePicker.shouldBeMinute = _auctionEndMinute;
    timePicker.refreshPickedTime();
  }

  function clamp(num, min, max) {
    return num <= min ? min : num >= max ? max : num;
  }

  function calculateRoundedAndClampedTimestamp(timestamp) {
    var roundedTimestamp = parseInt((timestamp / (15 * 60)) * (15 * 60));
    roundedTimestamp = clamp(roundedTimestamp, minimumAuctionEndTimestamp, maximumAuctionEndTimestamp);
    return roundedTimestamp;
  }

  spacing: TibiaStyle.marginRelated

  TibiaText {
    id: summaryCaptionText
    Layout.fillWidth: true
    Layout.margins: TibiaStyle.marginRelated
    horizontalAlignment : Text.AlignHCenter
    textFormat: Text.RichText
    text: {
      var minimumLocaleTimestring = TextHelper.formatDateTime(minimumAuctionEndTimestamp, false);
      var maximumLocaleTimestring = TextHelper.formatDateTime(maximumAuctionEndTimestamp, false);

      return qsTrId("charactertrade_change_auction_end_time").arg(minimumLocaleTimestring).arg(maximumLocaleTimestring);
    }
    wrapMode: Text.WordWrap
  }

  ColumnLayout {
    id: calendarLayout
    Layout.alignment: Qt.AlignHCenter
    Layout.fillHeight: true
    TibiaFrame1PixelDown {
      Layout.preferredWidth: 250
      Layout.fillHeight: true
      TibiaCalendarDatePicker {
        id: dayPicker
        anchors.fill: parent
        anchors.margins: parent.borderWidth
        minimumDate: _minimumAuctionDate
        maximumDate: _maximumAuctionDate
        selectedDate: _auctionEndDate
        onSelectedDateChanged: {
          refreshAuctionEndTimestamp();
        }
      }
    }

    RowLayout {
      id: timePicker
      Layout.maximumWidth: calendarLayout.width

      property int shouldBeHour: 0
      property int shouldBeMinute: 0

      onShouldBeHourChanged: {
        refreshPickedTime();
      }
      onShouldBeMinuteChanged: {
        refreshPickedTime();
      }

      function refreshPickedTime() {
        hourPicker.shouldBeCurrentIndex = shouldBeHour;
        minutePicker.shouldBeCurrentIndex = Math.floor(shouldBeMinute / 15);
      }

      spacing: TibiaStyle.marginNarrow

      Layout.alignment: Qt.AlignTop

      function reset() {
        hourPicker.currentIndex = 0;
        minutePicker.currentIndex = 0;
      } //function reset()

      Item {
        Layout.fillWidth: true
      }
      TibiaText {
        text: qsTrId("charactertrade_end_time")
      } //TibiaText

      TibiaComboBox {
        id: hourPicker
        Layout.preferredWidth: 50
        readonly property int value: parseInt(currentText)
        onValueChanged: {
          refreshAuctionEndTimestamp();
        }
        popupMaxHeight: 200
        model: [ "00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11",
                 "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23" ]
      } //TibiaComboBox

      TibiaText {
        text: ":"
      } //TibiaText

      TibiaComboBox {
        id: minutePicker
        Layout.preferredWidth: 50
        readonly property int value: parseInt(currentText)
        onValueChanged: {
          refreshAuctionEndTimestamp();
        }
        model: ["00", "15", "30", "45"]
      } //TibiaComboBox
      Item {
        Layout.fillWidth: true
      }

    } //RowLayout
  }
}
