import QtQuick
import QtQuick.Layouts

Item
{
  id: root
  property alias source: invisibleImage.source
  property alias sourceSize: invisibleImage.sourceSize

  implicitWidth: invisibleImage.sourceSize.width
  implicitHeight: invisibleImage.sourceSize.height

//  Component.onCompleted: {
//    if (width == 0) {
//      width = invisibleImage.sourceSize.width;
//    }
//    if (height == 0) {
//      height = invisibleImage.sourceSize.height;
//    }
//  }

  onWidthChanged: refresh()
  onHeightChanged: refresh()

  function refresh() {
    if (root.width > invisibleImage.sourceSize.width || root.height > invisibleImage.sourceSize.height) {
      imageComponentLoader.sourceComponent = borderImageComponent;
    } else {
      imageComponentLoader.sourceComponent = imageComponent;
    }
  }

  Image {
    id: invisibleImage
    visible: false
//    onStatusChanged: {
//      if (image.status == Image.Ready) {
//        if (root.width == 0) {
//          root.width = sourceSize.width;
//        }
//        if (root.height == 0) {
//          root.height = sourceSize.height;
//        }
//      }
//    }

    onSourceSizeChanged: {
      root.refresh();
    }
  }
  Loader {
    id: imageComponentLoader
    sourceComponent: imageComponent
    anchors.fill: parent
  }
  Component {
    id: imageComponent
    Image {
      id: image
      source: invisibleImage.source
      fillMode: Image.Pad
      smooth: false
      verticalAlignment: Image.AlignTop
      horizontalAlignment: Image.AlignLeft
    } //Button
  }
  Component {
    id: borderImageComponent
    BorderImage
    {
      id: borderImage
      source: invisibleImage.source
      smooth: false
      horizontalTileMode: BorderImage.Repeat
      verticalTileMode: BorderImage.Repeat
    }
  }
}

