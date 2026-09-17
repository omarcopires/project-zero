import QtQuick
import QtQuick.Layouts

Rectangle {
  implicitWidth: 100
  implicitHeight: TibiaStyle.calendarDayCaptionHeight
  color: TibiaStyle.calendarDayCaptionBackgroundColor

  property alias caption: capitonText.text
  property alias rightFrameVisible: rightFrame.visible

  TibiaText {
    id: capitonText
    styleType: "Dialog"
    anchors.centerIn: parent
    text: qsTrId("calendar_current_events_caption")
  } //TibiaText

  TibiaVerticalSeparator {
    id: rightFrame
    anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
  } //TibiaVerticalSeparator
} //Rectangle
