import QtQuick

Rectangle {
  id: progressbarBackground
  property real progressbarPercent: 1.0
  property alias progressbarColor: progressbar.color
  property alias progressbarBackgroundColor: progressbarBackground.color
  width: 100
  height: 4
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
      anchors.rightMargin: progressbarWrapper.width - Math.round(progressbarPercent * progressbarWrapper.width)
    }
  }
}
