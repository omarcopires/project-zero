import QtQuick

import qmlcomponents

Item {
  anchors.fill: parent
  anchors.margins: -marginToParent
  property int marginToParent: 0

  Image {
    //top
    anchors.bottom: parent.top
    anchors.horizontalCenter: parent.horizontalCenter
    source: "/images/clamp_selector.png"
  } //Image

  Image {
    //right
    anchors.left: parent.right
    anchors.verticalCenter: parent.verticalCenter
    source: "/images/clamp_selector.png"
    rotation: 90
  } //Image

  Image {
    //bottom
    anchors.top: parent.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    source: "/images/clamp_selector.png"
    rotation: 180
  } //Image

  Image {
    //left
    anchors.right: parent.left
    anchors.verticalCenter: parent.verticalCenter
    source: "/images/clamp_selector.png"
    rotation: -90
  } //Image
} //Item
