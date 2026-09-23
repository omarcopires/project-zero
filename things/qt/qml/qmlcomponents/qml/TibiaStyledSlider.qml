import QtQuick
import QtQuick.Controls.Basic



Slider {
  id: control

  property alias minimumValue: control.from
  property alias maximumValue: control.to

  live: true

  implicitHeight: sliderScrollBarHandle.implicitHeight
  padding: 0

  readonly property bool handleVisible: from != to
  handle: TibiaScrollBarHandle {
    id: sliderScrollBarHandle
    visible: control.handleVisible
    implicitWidth: 12 //Standalone client 12 = 6+6
    implicitHeight: childrenRect.height
    x: control.leftPadding + (control.horizontal ? control.visualPosition * (control.availableWidth - width) : (control.availableWidth - width) / 2)
    y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : control.visualPosition * (control.availableHeight - height))
    horizontal: true
  } //handle: TibiaScrollBarHandle
  background: TibiaTiledImage {
    id: sliderBackground
    source: "/images/skin/classic/slider-texture.png"
  } //groove: BorderImage
} //Slider
