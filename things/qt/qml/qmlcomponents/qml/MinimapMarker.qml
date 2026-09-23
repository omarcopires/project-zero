import QtQuick
import qmlcomponents


Item {
  id: minimapMarkerItem

  // Show the marker highlight during the first 15 seconds after lastModifiedTimestamp.
  property var highlightShowDurationMillis: 15000

  property var minimapMarkerInfo: null
  property var minimapMarkerInfoSymbol: minimapMarkerInfo != null ? minimapMarkerInfo.symbol : "image://minimap-markers/0"
  property var minimapMarkerInfoTooltiptext: minimapMarkerInfo != null ? minimapMarkerInfo.tooltiptext : ""
  property var minimapMarkerInfoLastModifiedTimestamp: minimapMarkerInfo != null ? minimapMarkerInfo.lastModifiedTimestamp : null

  // The C++-Code always updates parent and minimapMarkerInfo in the same order, but its safer this way:
  onMinimapMarkerInfoLastModifiedTimestampChanged: { updateHighlightIfAllDataAvailable(); }
  onParentChanged:                                 { updateHighlightIfAllDataAvailable(); }

  function updateHighlightIfAllDataAvailable() {
    if (parent != null && minimapMarkerInfoLastModifiedTimestamp != null) {
      updateHighlight();
    }
  }

  function updateHighlight() {
    var hideHighlightAfterMillis = minimapMarkerInfoLastModifiedTimestamp.getTime()
                                 + highlightShowDurationMillis
                                 - new Date().getTime();

    if (hideHighlightAfterMillis > 0) {

      highlight.visible = Qt.binding(function() { return parent != null && parent.highlightsVisible; });
      hideHighlightTimer.interval = hideHighlightAfterMillis;
      hideHighlightTimer.restart();

    } // else don't show highlight
  }

  Timer {
    id: hideHighlightTimer
    repeat: false
    running: false
    onTriggered: {
      highlight.visible = false;    // remove the binding to the highlightsVisible property
    }
  }

  Image {
    id: highlight
    source: "/images/minimap/background-for-highlighting-markers.png"
    anchors.horizontalCenter: symbol.horizontalCenter
    anchors.verticalCenter: symbol.verticalCenter
    smooth: false
    visible: false
  }

  Image {
    id: symbol
    source: minimapMarkerInfoSymbol
    smooth: false

    Tooltip {
      text: minimapMarkerItem.minimapMarkerInfoTooltiptext
      anchors.fill: parent
      hideOnPositionChange: false

      onHoverEnter: {
        if (minimapMarkerItem.parent != null) {
          minimapMarkerItem.parent.infoOfCurrentlyHoveredMinimapMarker = minimapMarkerInfo;
        }
      }
      onHoverLeave: {
        if (minimapMarkerItem.parent != null) {
          minimapMarkerItem.parent.infoOfCurrentlyHoveredMinimapMarker = null;
        }
      }
    }
  } // Image symbol
} // Item
