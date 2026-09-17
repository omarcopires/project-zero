import QtQuick



Item {
  property alias topLeftSource: topLeft.source
  property alias bottomLeftSource: bottomLeft.source
  property alias bottomRightSource: bottomRight.source
  property alias topRightSource: topRight.source

  property alias topSource: topImg.source
  property alias bottomSource: bottomImg.source
  property alias leftSource: leftImg.source
  property alias rightSource: rightImg.source

  Image {
    id: topLeft
    anchors.top: parent.top
    anchors.left: parent.left
    smooth: false
  } //Image

  Image {
    id: bottomLeft
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    smooth: false
  } //Image

  Image {
    id: bottomRight
    anchors.bottom: parent.bottom
    anchors.right: parent.right
    smooth: false
  } //Image

  Image {
    id: topRight
    anchors.top: parent.top
    anchors.right: parent.right
    smooth: false
  } //Image

  TibiaTiledImage {
    id: topImg
    anchors.top: parent.top
    anchors.left: topLeft.right
    anchors.right: topRight.left
  } //Image

  TibiaTiledImage {
    id: bottomImg
    anchors.bottom: parent.bottom
    anchors.left: topLeft.right
    anchors.right: topRight.left
  } //Image

  TibiaTiledImage {
    id: leftImg
    anchors.left: parent.left
    anchors.top: topLeft.bottom
    anchors.bottom: bottomLeft.top
  } //Image

  TibiaTiledImage {
    id: rightImg
    anchors.right: parent.right
    anchors.top: topRight.bottom
    anchors.bottom: bottomRight.top
  } //Image
} //Item
