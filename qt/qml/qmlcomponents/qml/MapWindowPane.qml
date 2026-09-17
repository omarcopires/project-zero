import QtQuick
import Qt5Compat.GraphicalEffects

import qmlcomponents



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// The Z-Order in this file is imporatent to allow mouse events to be handled properly
// From bottom to top the mouse order is:
// worldmapContainer < worldmapCreatureHUDOverlay < speechBubbleOverlay < numericalEffectOverlay < mouseAreaDrag < worldmapDropArea < tutorialMarkerOverlay
//
// The logic is that tuorial must at all time be working, Drop is happening when we are already dragging so it comes above.
// As there is no current plan to have clickable speech bubbles it comes underneeth the mouse and drop area.
// Alle others are as the overlapping was in the old client.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


TibiaTiledImage {
  id: mapWindowPane

  //BACKGROUND OF THE MAPWINDOW
  source: "/images/background.png"

  property QtObject mapWindowController: null
  property bool scaleOnlyByEvenMultiples: __validController && mapWindowController.mapWindowScaleOnlyByEvenMultiples
  property bool useLightMap: __validController && mapWindowController.useLightMap
  property var  antialiasingMode: __validController ? mapWindowController.antialiasingMode : TibiaEnums.AntialiasingModeNone

  property int scaleInPercent: 100

  readonly property int mapWindowHeight: __mapWindowHeight
  readonly property real mapWindowScaleFactor: mapWindowHeight / TibiaStyle.mapWindowUnscaledHeight
  readonly property int maximumHeight: __mapWindowMaximumHeight
  readonly property int minimumHeight: TibiaStyle.mapWindowUnscaledHeight / 2.0 + __completeBorderSize
  readonly property int minimumWidth: TibiaStyle.mapWindowUnscaledWidth / 2.0 + __completeBorderSize

  property bool __validController: false
  property int  __mapWindowHeight: TibiaStyle.mapWindowUnscaledHeight
  property int  __mapWindowMaximumHeight: TibiaStyle.mapWindowUnscaledHeight
  property bool __mapWindowScaled: false
  property bool __mapWindowShaderAntialiasingNeeded: false
  property bool __showNumericalEffects: __validController ? mapWindowController.showNumericalEffects : true
  property bool __mapWindowHasEvenMultipleScaleFactor: false
  property bool __NeedsRetroScale: false
  property bool __NeedsScale: false

  readonly property real __mapwindowAspectRatio: TibiaStyle.mapWindowWidthInFields / TibiaStyle.mapWindowHeightInFields
  readonly property int  __mapWindowMargin: TibiaStyle.mapWindowMargins + downFrame.borderWidth
  readonly property int  __completeBorderSize: __mapWindowMargin * 2
  readonly property real __nextEvenMultipleScaleFactor: Math.ceil(mapWindowScaleFactor);

  function clearShaders() {
    // Temporarily unloads shaders to clear old cached images
    __NeedsScale =  false
    __NeedsRetroScale =  false
    Qt.callLater( () => {calculateScaleFactorAndAntialiasing();});
  }

  function calculateHeightForDesiredMapWindowHeight(desiredMapWindowHeight) {
    return desiredMapWindowHeight + __completeBorderSize;
  }

  function calculateValidHeightForDesiredHeight(desiredHeight) {
    let maximumHeight = calculateMaximumHeight(desiredHeight);
    let desiredHeightPercentage = (desiredHeight - __completeBorderSize) / TibiaStyle.mapWindowUnscaledHeight;
    let closestInteger = Math.round(desiredHeightPercentage);

    // check if value is near the next multiple integral (+/-5%)
    if (Math.abs(desiredHeightPercentage - closestInteger) <= 0.05) {
      desiredHeightPercentage = closestInteger;
      desiredHeight = calculateHeightForDesiredMapWindowHeight(desiredHeightPercentage * TibiaStyle.mapWindowUnscaledHeight);
    }
    let resultingHeight = parseInt(Math.max(minimumHeight, Math.min(desiredHeight, maximumHeight)));
    return resultingHeight;
  }

  function calculateMaximumHeight(desiredHeight) {
    var mapwindowMaxAvailableSpace = Qt.size(parseInt(mapWindowPane.width) - __completeBorderSize, parseInt(desiredHeight) - __completeBorderSize);
    var mapwindowMaxHeight =  Math.floor(mapwindowMaxAvailableSpace.width / __mapwindowAspectRatio);

    if (scaleOnlyByEvenMultiples) {
      mapwindowMaxHeight = Math.min(mapwindowMaxAvailableSpace.height, mapwindowMaxHeight);
      mapwindowMaxHeight = parseInt(mapwindowMaxHeight / TibiaStyle.mapWindowUnscaledHeight) * TibiaStyle.mapWindowUnscaledHeight;
    }
    mapwindowMaxHeight = Math.max(TibiaStyle.mapWindowUnscaledHeight / 2, mapwindowMaxHeight);

    var newMaxHeight = calculateHeightForDesiredMapWindowHeight(mapwindowMaxHeight);
    return newMaxHeight;
  }

  function recalculateMaximumHeight() {
    var mapwindowMaxAvailableSpace = Qt.size(parseInt(mapWindowPane.width) - __completeBorderSize, parseInt(mapWindowPane.height) - __completeBorderSize);
    var newMaxHeight = calculateMaximumHeight(mapwindowMaxAvailableSpace.height);
    if (mapWindowPane.__mapWindowMaximumHeight != newMaxHeight) {
      mapWindowPane.__mapWindowMaximumHeight = newMaxHeight;
    }
  }

  Component.onCompleted: {
    recalculateMaximumHeight();
    scaledCheckTimer.start();
  }

  onHeightChanged: {
    recalculateMaximumHeight();
    scaledCheckTimer.start();
  }

  onWidthChanged: {
    recalculateMaximumHeight();
    scaledCheckTimer.start();
  }

  onScaleOnlyByEvenMultiplesChanged: {
    recalculateMaximumHeight();
  }

  function calculateScaleFactorAndAntialiasing() {
    var nextEvenMultipleScaleFactor = Math.ceil(mapWindowScaleFactor);
    var NewNeedsRetroScale = false;
    __NeedsScale = mapWindowScaleFactor != 1.0;
    if (antialiasingMode == TibiaEnums.AntialiasingModeNone) {
      __mapWindowShaderAntialiasingNeeded = false;
    } else if (antialiasingMode == TibiaEnums.AntialiasingModeAntialiasing) {
      __mapWindowShaderAntialiasingNeeded = true;
    } else if (antialiasingMode == TibiaEnums.AntialiasingModeRetro) {
      NewNeedsRetroScale = mapWindowScaleFactor > 1.0;
      __mapWindowShaderAntialiasingNeeded = true;
    }
    if (NewNeedsRetroScale != __NeedsRetroScale) {
      __NeedsRetroScale = NewNeedsRetroScale;
    }
  }

  onAntialiasingModeChanged: {
    scaledCheckTimer.start();
  }

  //mapWindowController reacts on unusedWidthChanged signal!
  property int unusedWidth: width - downFrame.width - 2 * __mapWindowMargin

  onMapWindowControllerChanged: {
    if(mapWindowController != null) {
      __validController = true;
    } else {
      __validController = false;
    }
  } //onMapWindowControllerChanged

  Timer {
    id: scaledCheckTimer
    interval: 0;
    running: false;
    repeat: false
    onTriggered: {
      var isScaled = false;
      if (mapWindowScaleFactor != 1.0) {
        isScaled = true;
      } else {
        isScaled = false;
      }
      if (mapWindowPane.__mapWindowScaled != isScaled) {
        mapWindowPane.__mapWindowScaled = isScaled;
      }
      var isEvenMultiple = (mapWindowPane.mapWindowScaleFactor == Math.ceil(mapWindowPane.mapWindowScaleFactor));
      if (mapWindowPane.__mapWindowHasEvenMultipleScaleFactor != isEvenMultiple) {
        mapWindowPane.__mapWindowHasEvenMultipleScaleFactor = isEvenMultiple;
      }
      calculateScaleFactorAndAntialiasing();
    } //onTriggered
  } //Timer

  TibiaFrame1PixelDown {
    id: downFrame
    anchors.horizontalCenter : parent.horizontalCenter
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.margins: TibiaStyle.mapWindowMargins

    width: Math.ceil((parent.height - __completeBorderSize) * __mapwindowAspectRatio) + 2*borderWidth

    Rectangle {
      id: mapwindow

      clip: true

      signal mapWindowClicked(int MouseX, int MouseY, int MouseButton, int KeyboardModifiers)
      signal mapWindowStartDrag(int MouseX, int MouseY, QtObject Source)
      signal mapWindowDragDropped(int MouseX, int MouseY)
      signal mapWindowTargetSelected(int MouseX, int MouseY)

      onHeightChanged: {
        mapWindowPane.__mapWindowHeight = height;
      }

      objectName: "mapWindow"
      anchors.fill: parent
      anchors.margins: parent.borderWidth

      color: "black"

      MouseArea {
        id: mouseAreaDrag
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        hoverEnabled: true
        z: numericalEffectOverlay.z + 1

        property real lastMouseX: 0
        property real lastMouseY: 0
        property int lastPressedX: -1
        property int lastPressedY: -1
        property bool alreadyStartedDragging: false
        property bool dualMouseClickEmulationActive: false

        drag.threshold: TibiaStyle.dragThreshold

        onEntered: {
          if (__validController) {
            mapWindowController.onMapWindowEntered();
          }
        } //onEntered

        onExited: {
          if (__validController) {
            mapWindowController.onMapWindowExited();
          }
        } //onExited

        onPressed: (mouse) => {
          lastPressedX = mouse.x;
          lastPressedY = mouse.y;
          alreadyStartedDragging = false;

          if (mouse.buttons == (Qt.LeftButton | Qt.RightButton)) {
            dualMouseClickEmulationActive = true;
          } else {
            dualMouseClickEmulationActive = false;
          }
        } //onPressed

        onPositionChanged: (mouse) => {
          if (__validController && mouse.buttons == Qt.LeftButton && !alreadyStartedDragging) {
            var dragDistance = Math.sqrt(Math.pow(lastPressedX - mouse.x, 2) + Math.pow(lastPressedY - mouse.y, 2));
            if (dragDistance >= drag.threshold) {
              alreadyStartedDragging = true;
              mapwindow.mapWindowStartDrag(lastPressedX,
                                           lastPressedY,
                                           mouseAreaDrag);
            }
          }
        }//onPositionChanged

        onClicked: (mouse) => {
          if (!alreadyStartedDragging && mouse.buttons == 0) {
            if (!dualMouseClickEmulationActive) {
              mapwindow.mapWindowClicked(mouse.x, mouse.y, mouse.button, mouse.modifiers);
            } else {
              // Left+Right is mapped to MiddleMouse
              mapwindow.mapWindowClicked(mouse.x, mouse.y, Qt.MiddleButton, Qt.NoModifier);
            }
          }
        } //onClicked
      }//MouseArea

      TibiaObjectDropArea {
        id: worldmapDropArea
        anchors.fill: parent
        z: mouseAreaDrag.z + 1
        onDropped: (drop) => {
          if (__validController) {
            drop.accepted = true;
            mapwindow.mapWindowDragDropped(drop.x, drop.y);
          }
        } //onDropped
      } //TibiaObjectDropArea
      TibiaTargetSelection {
        anchors.fill: parent
        onTargetSelected: (MouseX, MouseY) => {
          mapwindow.mapWindowTargetSelected(MouseX, MouseY);
        } //onTargetSelected
      } //TibiaTargetSelection


      // Wrapping the Worldmap in this container increases the framerate in state UNSCALED.
      // the extra item is to only scale one image not the single worldmap sub sprides
      Item {
        id: worldmapContainer

        property var worldmapContainerResultingComponent: lightmapBlendLoader.item != null ? lightmapBlendLoader.item : worldmap

        anchors.centerIn: parent
        width: TibiaStyle.mapWindowUnscaledWidth
        height: TibiaStyle.mapWindowUnscaledHeight

        Item {
          id: worldmapWrapper

          visible: true

          anchors.centerIn: parent
          width: TibiaStyle.mapWindowUnscaledWidth
          height: TibiaStyle.mapWindowUnscaledHeight

          Item { // purpose of this container: provide offset and clipping for LightMap
            id: lightmapContainer
            anchors.fill: parent
            visible: false // Blend.foregroundSource does not need to be visible

            LightMap {
              id: lightmap
              objectName: "lightmap"
              scale: 32  // 32 pixels per WorldmapField
            } //LightMap
          } //Item lightmapContainer

          WorldMap {
            id: worldmap
            objectName: "worldmap"
            anchors.fill: parent
            visible: lightmapBlendLoader.item == null
          } //WorldMap

          Loader {
            id: lightmapBlendLoader
            anchors.fill: worldmapWrapper
            Component {
              id: lightmapBlendComponent
              Item { // this wrapper element is necessary so that layer.enabled works as intended (TIBIA-24263)
                Blend {
                  anchors.fill: parent
                  source: worldmap
                  foregroundSource: lightmapContainer
                  cached: false
                  mode: "multiply"
                  layer.enabled: true // this is necessary so that SmoothRetro works also when light effects are enabled (TIBIA-24263)
                } //Blend
              }
            }
            sourceComponent: useLightMap ? lightmapBlendComponent : undefined
          }
        } // worldmap wrapper

      } //Item worldmapContainer

      Loader {
        id: applyScaleWorldmapLoader
        Component {
          id: applyScaleWorldmap

          ShaderEffectSource {
            id: shaderEffectSource
            sourceItem: worldmapContainer.worldmapContainerResultingComponent
            mipmap: false
            wrapMode: ShaderEffectSource.ClampToEdge
            hideSource: true
            live: true
            smooth: __NeedsRetroScale == true || __mapWindowShaderAntialiasingNeeded
            recursive: false
            textureSize: {
              var newTextureSize = null;
              if (__NeedsRetroScale) {
                newTextureSize = Qt.size(TibiaStyle.mapWindowUnscaledWidth * __nextEvenMultipleScaleFactor, TibiaStyle.mapWindowUnscaledHeight * __nextEvenMultipleScaleFactor);
              } else {
                newTextureSize = Qt.size(0, 0);
              }
              return newTextureSize;
            }
          } //ShaderEffectSource
        } //Component applyScaleWorldmap

        anchors.fill: parent
        sourceComponent: __NeedsScale ? applyScaleWorldmap : undefined // __mapWindowHasEvenMultipleScaleFactor == false || __mapWindowShaderAntialiasingNeeded ? applyScaleWorldmap : undefined
      } //Loader

      Item {
        id: worldmapCreatureHUDOverlay
        objectName: "worldmapCreatureHUDOverlay"
        anchors.fill: parent
        z: worldmapContainer.z +1
      } //Item

      SpeechBubbleOverlay {
        id: speechBubbleOverlay
        objectName: "speechBubbleOverlay"
        anchors.fill: parent
        z: worldmapCreatureHUDOverlay.z + 1
      } //SpeechBubbleOverlay

      NumericalEffectOverlay {
        id: numericalEffectOverlay
        objectName: "numericalEffectOverlay"
        anchors.fill: parent
        z: speechBubbleOverlay.z + 1
        visible: __showNumericalEffects
        clip: true
      }//NumericalEffectOverlay

      Item {
        id: tutorialMarkerOverlay
        objectName: "tutorialMarkerOverlay"
        anchors.fill: parent
        z: worldmapDropArea.z + 1
      }//Item

      onWidthChanged: () => {
        mapWindowPane.scaleInPercent = parseInt((width / TibiaStyle.mapWindowUnscaledWidth) * 100.0)
      }
    } //Rectangle
  } //TibiaFrame1PixelDown
} //BorderImage
