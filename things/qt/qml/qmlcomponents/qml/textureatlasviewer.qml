import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import QtCore
import qmlcomponents


Rectangle {

  id: rootElement

  property var controller: null
  property int currentZoomFactorIndex: 8
  property var zoomFactors: [0.0625, 0.125, 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 3.0, 4.0, 5.0, 10.0]
  property real zoomFactor: zoomFactors[currentZoomFactorIndex]

  z: 9999
  visible: true
  color: "grey"
  border.color: "black"

  x: 100
  y: 100

  function containTextureAtlas() {
    if (!Window.window) {
      return;
    }
    var newX = x;
    var newY = y;
    if (x + rootElement.width < 50) {
      newX = 50 - rootElement.width;
    } else if (x > Window.window.width - 50) {
      newX = Window.window.width - 50;
    }
    if (y + rootElement.height < 50) {
      newY = 50 - rootElement.height;
    } else if (y > Window.window.height - 50) {
      newY = Window.window.height - 50;
    }
    if (x != newX) {
      Qt.callLater( () => {
        x = newX;
      });
    }
    if (y != newY) {
      Qt.callLater( () => {
        y = newY;
      });
    }
  }

  onXChanged: containTextureAtlas()
  onYChanged: containTextureAtlas()
  onWidthChanged: containTextureAtlas()
  onHeightChanged: containTextureAtlas()
  width: textureAtlasWrapper.width + 2
  height: textureAtlasWrapper.height + 2

  Settings {
    id: settings
    category: "TextureAtlasViewer"

    property alias x: rootElement.x
    property alias y: rootElement.y
    property alias zoomFactorIndex: rootElement.currentZoomFactorIndex
    property alias opacity: rootElement.opacity
  }

  ColumnLayout {
    id: textureAtlasWrapper

    // Rectangle {
    //   Layout.fillWidth: true
    //   Layout.preferredHeight: 20
    //   Layout.leftMargin: 1
    //   Layout.topMargin: 1
    //   color: "darkGrey"
    // }

    TextureAtlasViewer {
      id: textureAtlasViewer
      Layout.preferredWidth: atlasWidth * zoomFactor
      Layout.preferredHeight: atlasHeight * zoomFactor
      Layout.margins: 1
      clip: true

      MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true
        acceptedButtons: Qt.MiddleButton
        drag.target: rootElement
        onWheel: (wheel) => {
          if (wheel.modifiers & Qt.ControlModifier) {
            if (wheel.angleDelta.y > 0) {
              currentZoomFactorIndex = Math.min(currentZoomFactorIndex + 1, zoomFactors.length - 1);
            } else if (wheel.angleDelta.y <0) {
              currentZoomFactorIndex = Math.max(currentZoomFactorIndex - 1, 0);
            }
            hintText.showHintText("Zoom: " + zoomFactors[currentZoomFactorIndex] + "x");
            wheel.accepted = true;
          } else if (wheel.modifiers & Qt.AltModifier) {
            if (wheel.angleDelta.x > 0) {
              rootElement.opacity = Math.min(rootElement.opacity + 0.1, 1.0);
            } else if (wheel.angleDelta.x <0) {
              rootElement.opacity = Math.max(rootElement.opacity - 0.1, 0.1);
            }
            hintText.showHintText("Opacity: " + parseInt(rootElement.opacity * 100) + "%");
            wheel.accepted = true;
          } else {
            wheel.accepted = false;
          }
        }
      }

    }
  }
  TibiaCachedOutlineText {
    id: hintText
    x: 10
    y: 10
    cacheMode: CachedOutlineText.NoCaching

    Component.onCompleted: {
      showHintText("Alt+Mousewheel: Change Opacity\nCtrl+Mousewheel: Change Zoom\nMiddle Mouse Button: Move");
    }

    function showHintText(newText) {
      text = newText;
      fadeAnimation.stop();
      hintText.opacity = 1.0;
      fadeAnimation.restart();
    }

    SequentialAnimation {
      id: fadeAnimation
      running: true
      loops: 1
      alwaysRunToEnd: true
      PauseAnimation { duration: 2000 } // Pause for 2 seconds
      PropertyAnimation {
        target: hintText
        property: "opacity"
        from: 1
        to: 0
        duration: 1000 // Fade out over 2 seconds
      }
    }
  }
}
