import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T


import qmlcomponents

T.Button {
  id: control
  property string iconPath
  property var iconOffset: Qt.point(0,0)
  implicitWidth: 16
  implicitHeight: 16

  checkable: true

  background: Image {
    id: buttonFrameImage
    anchors.fill: parent
    fillMode: Image.Pad
    source: (control.pressed || control.checked)  ? "/images/skin/classic/button-textured-down.png"
                                                  : "/images/skin/classic/button-textured-up.png"
    ColumnLayout {
      anchors.centerIn: buttonFrameImage
      Image {
        Layout.leftMargin: control.iconOffset.x
        Layout.topMargin: control.iconOffset.y
        source: control.iconPath
      } //Image
    }
  } //background: Image

  onPressedChanged: {
    if (!control.pressed) {
      SoundHelper.playSound(SoundHelper.BUTTON_RELEASE);
    } else {
      SoundHelper.playSound(SoundHelper.BUTTON_PRESS);
    }
  } //onPressedChanged

} //Button


