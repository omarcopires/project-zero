import QtQuick
import QtQuick.Layouts

import qmlcomponents


Rectangle {
  id: root
  property bool isToday: false
  property bool isVisibleMonth: false
  property bool isSelected: false
  property bool isValid: true
  property string dayOfMonthNumber: ""
  property alias eventModel: eventRepeater.model
  property alias rightFrameVisible: rightFrame.visible
  property string tooltip: ""
  property string seasonalTooltip: ""
  property bool isEntryOfCalendar: true

  color: {
    if (root.isSelected) {
      return TibiaStyle.calenderSelectedDayBackgroundColor;
    } else if(root.isToday) {
      return TibiaStyle.calenderCurrentDayBackgroundColor;
    } else if (root.isVisibleMonth) {
      return TibiaStyle.calenderVisibleMonthBackgroundColor;
    }
    return TibiaStyle.calenderOtherMonthBackgroundColor
  } //color

  TibiaVerticalSeparator {
    id: rightFrame
    anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
  } //TibiaVerticalSeparator

  TibiaHorizontalSeparator {
    id: topFrame
    anchors { left: parent.left; right: parent.right; top: parent.top; }
  } //TibiaHorizontalSeparator

  ColumnLayout {
    id: contentLayout
    anchors { left: parent.left; top: parent.top; right: parent.right }
    anchors.topMargin: topFrame.height
    anchors.rightMargin: rightFrame.visible ? rightFrame.width : 0
    spacing: TibiaStyle.marginNarrow

    RowLayout {
      id: dateNumberSeasonalIcon
      spacing: TibiaStyle.marginRelated
      Layout.topMargin: (!root.isEntryOfCalendar && root.seasonalTooltip != "") ? TibiaStyle.marginNarrow : 0
      Layout.bottomMargin: (!root.isEntryOfCalendar && root.seasonalTooltip != "") ? TibiaStyle.marginNarrow : 0
      Layout.leftMargin: (!root.isEntryOfCalendar && root.seasonalTooltip != "") ? TibiaStyle.marginNarrow : 0

      visible: dateNumber.text.length > 0 || root.seasonalTooltip != ""

      TibiaText {
        id: dateNumber
        styleType: root.isValid ? (!root.isToday ? "Dialog" : "CalendarDateCurrent") : "CalendarDateInvalid"
        text: root.dayOfMonthNumber
        color: root.isSelected ? TibiaStyle.white4 : (TibiaStyle.textColors[enabled ? styleType : "Disabled"])
        visible: text.length > 0
      } //TibiaText

      Image {
        id: seasonalIcon
        source: "/images/news/icon-seasonalevent.png"
        visible: root.seasonalTooltip != ""

        Tooltip {
          anchors.fill: parent
          useRichText: true
          maxWidth: TibiaStyle.tooltipRestrictedWidth
          text: root.seasonalTooltip
        } // Tooltip
      } //Image
    } // RowLayout


    Repeater {
      id: eventRepeater
      // root.height = available hight
      // add contentLayout.spacing to make devision easier as we can just ignore the fact that spacing is only used n-1 times for n elements
      property int maxVisibleEvents: Math.floor((root.height + contentLayout.spacing - contentLayout.anchors.topMargin
                                                 - (dateNumberSeasonalIcon.visible ? (dateNumberSeasonalIcon.height + contentLayout.spacing) : 0))
                                                / (TibiaStyle.calendarEventEntryHeight + contentLayout.spacing))

      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: TibiaStyle.calendarEventEntryHeight
        visible: index < eventRepeater.maxVisibleEvents
        color: root.isVisibleMonth ? modelData.primaryColor : modelData.secondaryColor

        TibiaText {
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          anchors.leftMargin: TibiaStyle.marginNarrow
          styleType: root.isVisibleMonth ? "Dialog" : "Caption"
          text: "<div>" + (modelData.startsOrEndsThatDay ? "*" : "") + modelData.title + "</div>" //div needed to auto enable RichText but also allow elide which is not working for Text.RichText
        } //TibiaText

        Tooltip {
          id: dayTooltip
          anchors.fill: parent
          useRichText: true
          maxWidth: TibiaStyle.tooltipRestrictedWidth
          text: root.tooltip
        } //Tooltip
      } //Rectangle
    } //Repeater
  } // ColumnLayout
} //Rectangle
