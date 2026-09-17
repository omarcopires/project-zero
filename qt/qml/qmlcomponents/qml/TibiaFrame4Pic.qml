import QtQuick




/********************************************
* Old client arranges the immages like this
* = top
* | left
* # right
* - bottom
*
* ================================
* |                              #
* |                              #
* |                              #
* |------------------------------#
********************************************/


Item {
  property alias topSource: topImg.source
  property alias bottomSource: bottom.source
  property alias leftSource: leftImg.source
  property alias rightSource: rightImg.source

  TibiaTiledImage {
    id: topImg
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
  } //Image

  TibiaTiledImage {
    id: leftImg
    anchors.left: parent.left
    anchors.top: topImg.bottom
    anchors.bottom: parent.bottom
  } //Image

  TibiaTiledImage {
    id: rightImg
    anchors.right: parent.right
    anchors.top: topImg.bottom
    anchors.bottom: parent.bottom
  } //Image

  TibiaTiledImage {
    id: bottom
    anchors.bottom: parent.bottom
    anchors.left: leftImg.right
    anchors.right: rightImg.left
  } //Image
} //Item
