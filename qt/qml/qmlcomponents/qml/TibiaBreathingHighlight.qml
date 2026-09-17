import QtQuick

import qmlcomponents



Rectangle {
  id: root
  anchors.fill: parent

  property int duration: 2000
  property color breathColor: "white"
  property alias loops: animation.loops
  property alias running: animation.running

  color: "transparent"
  border.width: 1
  border.color: "transparent"

  SequentialAnimation {
    id: animation
    loops: 10
    running: true
    ColorAnimation {
      target: root
      property: "border.color"
      from: "transparent"
      to: root.breathColor
      duration: root.duration
      easing.type: Easing.OutQuad
    } //ColorAnimation
    ColorAnimation {
      target: root
      property: "border.color"
      from: root.breathColor
      to: "transparent"
      duration: root.duration
      easing.type: Easing.OutQuad
    } //ColorAnimation
  } //SequentialAnimation
} //Rectangle
