import QtQuick
import QtQuick.LegacyControls
import QtQuick.Layouts

TibiaDialog {
  id: root
  caption: qsTrId("calendar_caption")
  width: 780

  property var controller: null
  property date todayDate: new Date()
  onControllerChanged: {
    if (controller != null) {
      root.todayDate = controller.todayDateServer;
    } else {
      root.todayDate = new Date();
    }
  } //onControllerChanged

  initialFocusItem: root
  KeyNavigation.tab: root
  KeyNavigation.backtab: root

  onCancelPressedFunction: onCloseClicked

  function onCloseClicked() {
    if (controller != null) {
      controller.closeButtonClicked();
    }
  } //function onCloseClicked


  property variant events: controller != null ? controller.eventsMap : { }

  ColumnLayout {
    id: rootLayout
    anchors { left: parent.left; top: parent.top; right: parent.right }
    spacing: TibiaStyle.marginUnrelated

    Item {
      Layout.fillWidth: true
      Layout.preferredHeight: monthNavigationLayout.height

      RowLayout {
        id: monthNavigationLayout
        anchors.centerIn: parent
        spacing: 0

        TibiaButton {
          Layout.preferredWidth: height
          imageSource: "/images/icon-arrow.png"
          imageSourceDisabled: "/images/icon-arrow-disabled.png"
          enabled: calendar.minimumDate < calendar.visibleDate
          onClicked: {
            calendar.showPreviousMonth();
          }//onClicked
        } //TibiaButton

        TibiaText {
          Layout.preferredWidth: 120
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          text:   calendar.__locale.standaloneMonthName(calendar.visibleMonth)
                + new Date(calendar.visibleYear, calendar.visibleMonth, 1).toLocaleDateString(calendar.__locale, " yyyy")
        } //TibiaText

        TibiaButton {
          Layout.preferredWidth: height
          imageSource: "/images/icon-arrow.png"
          imageSourceDisabled: "/images/icon-arrow-disabled.png"
          imageMirrored: true
          enabled: calendar.visibleDate < calendar.firstDayMaximumMonth
          onClicked: {
            calendar.showNextMonth();
          }//onClicked
        } //TibiaButton
      } //RowLayout

      TibiaText {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        text: controller != null ? controller.currentTimeServer : ""
      } //TibiaText
    } //Item

    TibiaFrame1PixelDown {
      Layout.fillWidth: true
      Layout.preferredHeight: 426

      CalendarOld {
        id: calendar
        anchors.fill: parent
        anchors.margins: parent.borderWidth
        anchors.rightMargin: 0
        z: -1

        selectedDate: root.todayDate
        minimumDate: controller != null ? controller.minimumDate : new Date()
        maximumDate: controller != null ? controller.maximumDate : new Date()

        visibleMonth: root.todayDate.getMonth()
        visibleYear: root.todayDate.getFullYear()
        onVisibleMonthChanged: asyncVisibleDateUpdater.restart()
        onVisibleYearChanged: asyncVisibleDateUpdater.restart()
        Timer {
          id: asyncVisibleDateUpdater
          interval: 1
          onTriggered: {
            calendar.visibleDate = new Date(calendar.visibleYear,
                                            calendar.visibleMonth,
                                            1);
          }
        } //Timer

        property date visibleDate: new Date()
        property date firstDayMaximumMonth: new Date(maximumDate.getFullYear(), maximumDate.getMonth(), 1)

        onVisibleDateChanged: {
          // selectedDate is not used within the event schedule
          // if it is set to a day in a month which is not the visible month this day can no longer be used to navigate to the next or previous month
          // therefore we set it to the first day of the visible month just to have it out of the way.
          selectedDate = visibleDate;
        } //onVisibleDateChanged

        locale: Qt.locale("en_GB")
        dayOfWeekFormat: Locale.LongFormat

        frameVisible: false
        navigationBarVisible : false

        style: CalendarStyle {
          gridVisible: false
          __gridLineWidth: 0 //should not be needed but is

          background: Item { }

          dayOfWeekDelegate: TibiaCalendarDayCaption {
            caption: control.__locale.dayName(styleData.dayOfWeek, control.dayOfWeekFormat)
            rightFrameVisible: styleData.index != 6
          } //dayOfWeekDelegate:TibiaCalendarDayCaption

          dayDelegate: TibiaCalendarDay {
            property string dateString: styleData.date.toLocaleDateString(calendar.__locale, "yyyy-MM-dd")
            //need to use .getTime() which gives the timestamp https://stackoverflow.com/a/493018/5134351
            isToday: styleData.date.getTime() == root.todayDate.getTime()
            isVisibleMonth: styleData.visibleMonth
            dayOfMonthNumber: styleData.date.getDate()
            eventModel: root.events[dateString]
            rightFrameVisible: styleData.date.getDay() != 0
            tooltip: controller != null ? controller.getTooltipForDay(dateString) : ""
            seasonalTooltip: controller != null ? controller.getSeasonalTooltipForDay(dateString) : ""
          } //dayDelegate: TibiaCalendarDay
        } //style: CalendarStyle
      } //Calendar
    } //TibiaFrame1PixelDown

    TibiaText {
      text: qsTrId("calendar_serversave_explanation")
    }

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } //TibiaHorizontalSeparator

    RowLayout {
      Layout.alignment: Qt.AlignRight
      spacing: TibiaStyle.marginRelated

      Item { Layout.fillWidth: true }

      TibiaButton {
        id: closeButton
        text: qsTrId("close")
        onClicked: root.onCloseClicked()
      } // TibiaButton
    } // RowLayout
  } // ColumnLayout
} // TibiaDialog
