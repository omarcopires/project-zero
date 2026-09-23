import QtQuick

import qmlcomponents

Item {
  id: root
  anchors.fill: parent

  property int barWidth: 2
  property var fillPercentage: 0.0
  property color color: "green"


  readonly property int widthSide: width + barWidth
  readonly property int heightSide: height + barWidth
  readonly property int circumference: 2 * widthSide + 2 * heightSide

  readonly property var totalProgress:
    circumference * Math.min(Math.max(fillPercentage, 0.0), 1.0)

  function localProgress(minProgress: int, maxProgress: int) : int {
    let progressRange = maxProgress - minProgress;
    return Math.min(progressRange,(root.totalProgress - minProgress))
  }

  Rectangle {
    anchors.bottom: parent.top
    anchors.left: parent.left

    color: root.color

    height: root.barWidth
    width: root.localProgress(
      0,
      root.widthSide
    )
  } //Rectangle

  Rectangle {
    anchors.left: parent.right
    anchors.top: parent.top

    color: root.color

    height: root.localProgress(
      root.widthSide,
      root.widthSide + root.heightSide
    )
    width: root.barWidth
  } //Rectangle

  Rectangle {
    anchors.top: parent.bottom
    anchors.right: parent.right

    color: root.color

    height: root.barWidth
    width: root.localProgress(
      root.widthSide + root.heightSide,
      2 * root.widthSide + root.heightSide
    )
  } //Rectangle

  Rectangle {
    anchors.right: parent.left
    anchors.bottom: parent.bottom

    color: root.color

    height: root.localProgress(
      2 * root.widthSide + root.heightSide,
      2 * root.widthSide + 2 * root.heightSide
    )
    width: root.barWidth
  } //Rectangle

} //Item

