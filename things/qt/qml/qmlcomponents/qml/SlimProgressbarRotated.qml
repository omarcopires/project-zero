import QtQuick

Rectangle {
  id: progressbarBackground
  property real progressbarPercent: 1.0
  property alias progressbarColor: progressbar.color
  property alias progressbarBackgroundColor: progressbarBackground.color
  width: 4
  height: 100
  border.width: 1
  border.color: "black"
  color: "black"
  visible: true

  Item {
    id: progressbarWrapper
    anchors.fill: parent
    anchors.margins: 1

    Rectangle {
      id: progressbar
      anchors.fill: parent
      anchors.topMargin: progressbarWrapper.height - Math.round(progressbarPercent * progressbarWrapper.height)
    }
  }
}
