import QtQuick
import qmlcomponents




/*
 * Developer hints for using DynamicallyLoadedMultiImage
 *
 * This Item needs to be 32x32 or 64x64 do work properly
 * best use property smallSize32 or bigSize64
 */

Item {
  id: icon
  property alias dynamicallyLoadedImageManager: dynImage.dynamicallyLoadedImageManager
  property var imageIdentifiers: []
  property int currentImageIndex: 0
  property alias smallSize32: dynImage.smallSize32
  property alias bigSize64: dynImage.bigSize64

  onImageIdentifiersChanged: {
    currentImageIndex = 0;
  } //onImageIdentifiersChanged

  DynamicallyLoadedImage {
    id: dynImage
    anchors.fill: parent
    imageKey: icon.currentImageIndex > -1
      && icon.currentImageIndex < icon.imageIdentifiers.length
         ? icon.imageIdentifiers[icon.currentImageIndex] : "";
  } //DynamicallyLoadedImage

  TibiaIconButton {
    sourceUp: "/images/skin/classic/button-storeimage-previous-up.png"
    sourceDown: "/images/skin/classic/button-storeimage-previous-down.png"
    anchors { right: parent.left; bottom: parent.bottom; }
    visible: icon.currentImageIndex > 0
    onClicked: {
      icon.currentImageIndex -= 1;
    } //onClicked
  } //TibiaIconButton

  TibiaIconButton {
    sourceUp: "/images/skin/classic/button-storeimage-next-up.png"
    sourceDown: "/images/skin/classic/button-storeimage-next-down.png"
    anchors { left: parent.right; bottom: parent.bottom; }
    visible: icon.currentImageIndex < icon.imageIdentifiers.length - 1
    onClicked: {
      icon.currentImageIndex += 1;
    } //onClicked
  } //TibiaIconButton
} // Item

