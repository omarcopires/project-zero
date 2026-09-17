import QtQuick
import qmlcomponents

Image {
  id: automap_button_rose

  property string stateString: "idle"
  property double timeOfDayNormalized: 0.0

  signal mouseButtonClicked(var offsetX, var offsetY);

  source: "/images/automap-rose-" + stateString + ".png"
  clip: true
  smooth: false
  function adjustTimeDisplay() {
    // TimeOfDayNormalized starts with "midnight", but the sliding image starts with "noon"
    var automapRoseWidth = timedisplay.width;
    if (automapRoseWidth == 0) {
      return;
    }
    var normalizedSinceNoon = timeOfDayNormalized + 0.5;
    var offset = automapRoseWidth * normalizedSinceNoon;
    offset = offset % automapRoseWidth;
    offset = offset + 6; // the automap rose has a border of 6 pixels
    timedisplay.x = -1 * offset
  }

  onTimeOfDayNormalizedChanged: {
    adjustTimeDisplay();
  }

  Component.onCompleted: {
    adjustTimeDisplay();
  }

  Tooltip {
    anchors.fill: parent
    text: qsTrId("minimap_scroll_tooltip")
  }

  MouseArea {
    property int calculatedOffsetX: 0
    property int calculatedOffsetY: 0

    anchors.fill: parent
    acceptedButtons: Qt.LeftButton
    hoverEnabled: true

    function determineStateForOffsets() {
      var directions = [
        ["nw", "n", "ne"],
        ["w", "idle", "e"],
        ["sw", "s", "se"]
      ];
      automap_button_rose.stateString = directions[calculatedOffsetY + 1][calculatedOffsetX + 1];
    }

    function refreshCalculatedOffsets(x, y) {
      var normalizedX = x / (automap_button_rose.width - 1.0);
      var shiftedNormalizedX = normalizedX * 2 - 1;
      var normalizedY = y / (automap_button_rose.height - 1.0);
      var shiftedNormalizedY = normalizedY * 2 - 1;

      var distanceFromCenter = Math.sqrt(shiftedNormalizedX * shiftedNormalizedX + shiftedNormalizedY * shiftedNormalizedY);

      calculatedOffsetX = 0;
      calculatedOffsetY = 0;
      if (distanceFromCenter >= 0.33) {
        if (normalizedX >= 0.66) {
          calculatedOffsetX = 1;
        } else if (normalizedX <= 0.33) {
          calculatedOffsetX = -1;
        }

        if (normalizedY >= 0.66) {
          calculatedOffsetY = 1;
        } else if (normalizedY <= 0.33) {
          calculatedOffsetY = -1;
        }
      }
    }

    onClicked: (mouse) => {
      refreshCalculatedOffsets(mouse.x, mouse.y);
      determineStateForOffsets();
      mouseButtonClicked(calculatedOffsetX, calculatedOffsetY);
    }

    onPositionChanged: (mouse) => {
      refreshCalculatedOffsets(mouse.x, mouse.y);
      determineStateForOffsets();
    } // onPositionChanged

    onExited: {
      calculatedOffsetX = 0;
      calculatedOffsetY = 0;
      determineStateForOffsets();
    }
  } // MouseArea

  Image {
    id: timedisplay
    objectName: "timedisplay"
    source: "/images/timedisplay-scroll.png"
    z: -1
    anchors.verticalCenter: automap_button_rose.verticalCenter
    smooth: false
  } // Image

  // duplicate the timedisplay image, so it appears like it is infinite / wraps around
  Image {
    source: "/images/timedisplay-scroll.png"
    z: timedisplay.z
    anchors.left: timedisplay.right
    anchors.top: timedisplay.top
    smooth: false
  } // Image

  Image {
    source: "/images/timedisplay-glass.png"
    anchors.horizontalCenter: automap_button_rose.horizontalCenter
    anchors.verticalCenter: automap_button_rose.verticalCenter
    smooth: false
  } // Image

} // Image


