import QtQuick
import QtQuick.Layouts
import qmlcomponents



TibiaSidebarPanel {
  id: minimapPanel

  property var currentLayer: 0

  onCurrentLayerChanged: {
    mapLayersSlider.currentLayer = currentLayer;
  }

  onPanelControllerChanged: {
    if (panelController != null) {
      minimapPanel.currentLayer = Qt.binding(function() { return panelController.currentLayer; });
    } else {
      minimapPanel.currentLayer = 0;
    }
  }

  TibiaFrame1PixelDown {
    anchors.left: parent.left

    width: TibiaStyle.minimapViewportWidth
    height: TibiaStyle.minimapViewportHeight

    Minimap {
      id: minimap
      objectName: "minimap"

      anchors.fill: parent
      anchors.margins: 1

      clip: true

      property int crosshairX: 0
      property int crosshairY: 0
      property bool crosshairVisible: false;
      property bool crosshairIsDark: false

      onCrosshairXChanged: {
        automap_crosshair.x = crosshairX - automap_crosshair.width / 2;
      }
      onCrosshairYChanged: {
        automap_crosshair.y = crosshairY - automap_crosshair.height / 2;
      }
      onCrosshairVisibleChanged: {
        automap_crosshair.visible = crosshairVisible;
      }

      Image {
        id: automap_crosshair
        source: minimap.crosshairIsDark ? "/images/automap-crosshair-dark.png" : "/images/automap-crosshair-light.png"
        visible: false
        smooth: false
      } // Image

      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        property int lastMouseX: 0
        property int lastMouseY: 0
        property int lastPressedX: -1
        property int lastPressedY: -1
        property bool currentlyDragging: false

        onPressed: (mouse) => {
          lastPressedX = mouse.x;
          lastPressedY = mouse.y;
          currentlyDragging = false;
        } // onPressed

        onPositionChanged: (mouse) => {
          if (panelController != null) {
            panelController.onMinimapMouseMoved(mouse.x, mouse.y);

            if (((mouse.buttons & Qt.LeftButton) != 0) && (!currentlyDragging)) {
              var dragDistance = Math.sqrt(Math.pow(lastPressedX - mouse.x, 2) + Math.pow(lastPressedY - mouse.y, 2));
              if (dragDistance >= drag.threshold) {
                currentlyDragging = true;
                lastMouseX = lastPressedX;
                lastMouseY = lastPressedY;
              }
            }

            if (currentlyDragging) {
              panelController.onMinimapDragged(lastMouseX - mouse.x, lastMouseY - mouse.y);
            }

            lastMouseX = mouse.x;
            lastMouseY = mouse.y;
          }
        } // onPositionChanged

        onReleased: (mouse) => {
          if (panelController != null && !currentlyDragging) {
            if (minimapMarkerOverlay.infoOfCurrentlyHoveredMinimapMarker != null) {
              panelController.onMinimapMarkerClick(minimapMarkerOverlay.infoOfCurrentlyHoveredMinimapMarker, mouse.button, mouse.modifiers);
            } else {
              panelController.onMinimapClick(mouse.x, mouse.y, mouse.button, mouse.modifiers);
            }
          }
        } // onReleased

        onWheel: (wheel) => {
          if (panelController != null) {
            if (wheel.angleDelta.y > 0) {
              panelController.onZoomInButtonClicked();
            } else if (wheel.angleDelta.y < 0) {
              panelController.onZoomOutButtonClicked();
            }
          }
        } // onWheel
      } // MouseArea

      Item {
        id: minimapMarkerOverlay
        objectName: "minimapMarkerOverlay"
        anchors.fill: parent

        property var infoOfCurrentlyHoveredMinimapMarker: null
        //property var minimapController: panelController
        property bool highlightsVisible: false

        Timer {
          interval: 500
          repeat: true
          running: true
          onTriggered: {
            minimapMarkerOverlay.highlightsVisible = !minimapMarkerOverlay.highlightsVisible;
          }
        }

      } // Item
    } // Minimap Quickitem
  } //TibiaFrame1PixelDown

  TibiaMinimapRose {
    id: minimapRose
    anchors.top: parent.top
    anchors.right: parent.right
    anchors.rightMargin: -1

    timeOfDayNormalized: panelController != null ? panelController.timeOfDayNormalized : 0.0
  
    onMouseButtonClicked: (offsetX, offsetY) => {
      if (panelController != null) {
        panelController.onMinimapRoseButtonClicked(offsetX, offsetY)
      }
    } //onMouseButtonClicked
  } //TibiaMinimapRose

  ColumnLayout {
    id: buttonsWrapper
    anchors.left: minimapRose.left
    anchors.bottom: mapLayersSlider.bottom
    spacing: 0
  
    TibiaIconButton {
      id: automap_button_zoomout
      sourceUp: "/images/automap-button-zoomout-up.png"
      sourceDown: "/images/automap-button-zoomout-down.png"
      tooltipText: qsTrId("minimap_zoom_out_tooltip")
  
      onClicked: {
        if (panelController != null) {
          panelController.onZoomOutButtonClicked();
        }
      } //onClicked
    } //TibiaIconButton
  
    TibiaIconButton {
      id: automap_button_zoomin
      sourceUp: "/images/automap-button-zoomin-up.png"
      sourceDown: "/images/automap-button-zoomin-down.png"
      tooltipText: qsTrId("minimap_zoom_in_tooltip")
  
      onClicked: {
        if (panelController != null) {
          panelController.onZoomInButtonClicked();
        }
      } //onClicked
    } //TibiaIconButton
  
    TibiaIconButton {
      id: goToCyclopediaMapButton
      sourceUp: "/images/automap-button-cyclopediamap-up.png"
      sourceDown: "/images/automap-button-cyclopediamap-down.png"
      tooltipText: qsTrId("minimap_cyclopedia_map_tooltip")
  
      onClicked: {
        if (panelController != null) {
          panelController.onCyclopediaMapButtonClicked();
        }
      }//onClicked
    } //TibiaIconButton
  } //ColumnLayout

  TibiaMapLayersSlider {
    id: mapLayersSlider
    anchors.right: parent.right
    anchors.top: minimapRose.bottom
    anchors.topMargin: 1
    onCurrentLayerChanged: {
      if (panelController != null) {
        panelController.currentLayer = currentLayer;
      }
    } //onCurrentLayerChanged
    tooltip: qsTrId("minimap_change_layer_tooltip")
  } //TibiaMapLayersSlider

  Lenshelp {
    anchors.fill: parent
    triggerRect: mapFromItem(panelRoot, 0, 0, panelRoot.width, panelRoot.height)
    caption: qsTrId("minimap_lenshelp_caption")
    content: qsTrId("minimap_lenshelp")
  } //Lenshelp
} //TibiaSidebarPanel
