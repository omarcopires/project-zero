import QtQuick

  // this qml element is only for special cases where a small BorderImage with 1 pixel border is drawn (e.g. Container-Slots or Action-Buttons)
  // it constructs a ready image that can be drawn as whole (via a special image provider) instead of drawing it as BorderImage
  // This results in about 10 times less vertices in draw commands
Image {
  id: image

  property string borderimagesource: ""

  smooth: false
  function refresh() {
    image.sourceSize = Qt.size(width, height);
    if (width > 0 && height > 0) {
      image.source = "image://optimized1pixelborderimage/" + image.borderimagesource;
    } else {
      image.source = "";
    }
  }

  onBorderimagesourceChanged: {
    image.refresh();
  }

  Component.onCompleted: {
    refresh();
  }
  onWidthChanged: {
    refresh();
  }
  onHeightChanged: {
    refresh();
  }
}
