import QtQuick
import QtQuick.Layouts
import QtQuick.LegacyControls


CalendarOld {
  locale: Qt.locale("en_GB")
  dayOfWeekFormat: Locale.ShortFormat

  frameVisible: false
  navigationBarVisible : true

  style: CalendarStyle {
    gridVisible: false
    __gridLineWidth: 0 //should not be needed but is

    background: Item { }

    navigationBar: Rectangle {
      height: 20
      color: TibiaStyle.calenderNavigationBarBackgroundColor
      RowLayout {
        anchors.fill: parent
        TibiaButton {
          Layout.preferredWidth: parent.width / 7
          imageSource: "/images/skin/classic/icon-left-arrow.png"
          onClicked: control.showPreviousMonth()
        }
        TibiaText {
          Layout.fillWidth: true
          text: styleData.title
          horizontalAlignment: Qt.AlignHCenter
        }
        TibiaButton {
          Layout.preferredWidth: parent.width / 7
          imageSource: "/images/skin/classic/icon-right-arrow.png"
          onClicked: control.showNextMonth()
        }
      }
    }


    dayOfWeekDelegate: TibiaCalendarDayCaption {
      caption: control.__locale.dayName(styleData.dayOfWeek, control.dayOfWeekFormat)
      rightFrameVisible: styleData.index != 6
    } //dayOfWeekDelegate:TibiaCalendarDayCaption

    dayDelegate: TibiaCalendarDay {
      //need to use .getTime() which gives the timestamp https://stackoverflow.com/a/493018/5134351
      isToday: false // styleData.date.getTime() == (new Date()).getTime()
      isSelected: styleData.selected
      isValid: styleData.valid
      isVisibleMonth: styleData.visibleMonth
      dayOfMonthNumber: styleData.date.getDate()
      rightFrameVisible: styleData.date.getDay() != 0
      MouseArea {
        id: hoverMouseArea
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        anchors.fill: parent
        onEntered: {
          if (tibiaMouseCursorController != null && styleData.valid) {
            tibiaMouseCursorController.setPointingHand(true);
          }
        }
        onExited: {
          if (tibiaMouseCursorController != null) {
            tibiaMouseCursorController.setPointingHand(false);
          }
        }
      }
    } //dayDelegate: TibiaCalendarDay
  } //style: CalendarStyle
} //Calendar
