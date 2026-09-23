import QtQuick
import qmlcomponents




Item {
  id: mapLayersSlider
  property int currentLayer: 0
  property int minimumLayer: 0
  property int maximumLayer: 15
  property bool noLayers: false

  property alias tooltip: layerSliderTooltip.text

  height: layersCanvas.height
  width: 20

  Component.onCompleted: layersCanvasRequestPaintTimer.restart()
  onMinimumLayerChanged: layersCanvasRequestPaintTimer.restart()
  onMaximumLayerChanged: layersCanvasRequestPaintTimer.restart()
  onNoLayersChanged: layersCanvasRequestPaintTimer.restart()
  onCurrentLayerChanged: {
    correctLayers();
    layersCanvas.requestPaint();
    indicator.y = currentLayer * 4;
  } //onCurrentLayerChanged

  Timer {
    id: layersCanvasRequestPaintTimer
    interval: 0
    repeat: false
    onTriggered: {
      correctLayers();
      layersCanvas.requestPaint()
    }
  } //Timer

  function correctLayers() {
    var newMinimumLayer = Math.max(0, minimumLayer);
    var newMaximumLayer = Math.max(newMinimumLayer, Math.min(maximumLayer, 15));
    var newCurrentLayer = Math.min(newMaximumLayer, Math.max(newMinimumLayer, mapLayersSlider.currentLayer));

    if (newMinimumLayer != minimumLayer) {
      minimumLayer = newMinimumLayer;
    }
    if (newMaximumLayer != maximumLayer) {
      maximumLayer = newMaximumLayer;
    }
    if (newCurrentLayer != currentLayer) {
      currentLayer = newCurrentLayer;
    }
  } //function correctLayers

  function moveLayer(direction)
  {
    if (direction > 0) {
      mapLayersSlider.currentLayer = mapLayersSlider.currentLayer - 1;
    } else if (direction < 0) {
      mapLayersSlider.currentLayer = mapLayersSlider.currentLayer + 1;
    }
  } //function moveLayer

  function setLayerValue(value)
  {
    mapLayersSlider.currentLayer = value
  } //function setLayerValue

  function findNearestLayerValue(y)
  {
    y = Math.max(0, Math.min(dragArea.height, y));
    var nearestLayerValue = Math.abs(parseInt((y - 3) / 4));
    return nearestLayerValue;
  } //function findNearestLayerValue

  MouseArea {
    id: dragArea
    property bool _dragged: false
    property var _clickPoint: Qt.point(0,0)
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    hoverEnabled: false

    onWheel: (wheel) => {
      moveLayer(wheel.angleDelta.y);
    } //onWheel

    onPositionChanged: (mouse) => {
      if (mouse.buttons == Qt.LeftButton) {
        var dragDistance = Math.sqrt(Math.pow(_clickPoint.x - mouse.x, 2) + Math.pow(_clickPoint.y - mouse.y, 2));
        if (_dragged == true || dragDistance >= TibiaStyle.dragThreshold) {
          _dragged = true;
          setLayerValue(findNearestLayerValue(mouse.y));
        }
      }
    } //onPositionChanged

    onPressed: (mouse) => {
      if (mouse.buttons == Qt.LeftButton) {
        _dragged = false
        _clickPoint = Qt.point(mouse.x, mouse.y);
      }
    } //onPressed

    onReleased: (mouse) => {
      if (mouse.button == Qt.LeftButton) {
        if (_dragged == false) {
          var clickedLayer = findNearestLayerValue(mouse.y);
          if (clickedLayer >= 0 && clickedLayer < 7) {
            moveLayer(1);
          } else if (clickedLayer > 7 && clickedLayer <= 15) {
            moveLayer(-1);
          }
        }
      }
    } //onReleased
    z: 999

    Tooltip {
      id: layerSliderTooltip
      enabled: true
      anchors.fill: parent
    } //Tooltip
  } //MouseArea

  TibiaVerticalSeparator {
    anchors.top: parent.top
    anchors.topMargin: 3
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 3
    anchors.right: parent.right
    anchors.rightMargin: 2
    visible: !noLayers
  } //TibiaVerticalSeparator

  Image {
    id: indicator
    source: "/images/automap-indicator-slider-left.png"
    anchors.right: parent.right
    smooth: false
    visible: !noLayers
  } //Image

  Canvas {
    id: layersCanvas
    anchors.left: parent.left
    property int selectedIndex: mapLayersSlider.currentLayer
    property int minimumLayer: mapLayersSlider.minimumLayer
    property int maximumLayer: mapLayersSlider.maximumLayer
    property bool isActive: !mapLayersSlider.noLayers
    height: 67
    width: 14
    antialiasing: false
    smooth: false

    onPaint: {
      correctLayers();

      var ctx = getContext('2d');

      ctx.save();
      ctx.clearRect(0, 0, width, height);

      ctx.lineWidth = 1;

      var shape = [
          "      bb      "
        , "    bbffbb    "
        , "  bbffffffbb  "
        , "bbhhffffffffbb"
        , "  bbhhffffbb  "
        , "    bbhhbb    "
        , "    ssbbss    "
        , "     ssss     "
      ];

      var shapeWidth = shape[0].length;
      var shapeHeight = shape.length;

      function createImage(borderColor, fillColor, withShadow, isSelected) {
        var shapedata = context.createImageData(shapeWidth, shapeHeight);
        for (var y = 0; y < shape.length; y++) {
          var lineString = shape[y];
          for (var x = 0; x < lineString.length; x++) {
            var pixelIndex = (y * shapeWidth + x) * 4;

            var colorChar = lineString.charAt(x);
            var tempColor = Qt.rgba(0,0,0,0);
            if (colorChar == "b") {
              tempColor = Qt.lighter(borderColor, isSelected ? 2.5 : 1.0);
            } else if (colorChar == "f") {
              tempColor = Qt.lighter(fillColor, isSelected ? 2.0 : 1.0);
            } else if (colorChar == "h") {
              tempColor = Qt.lighter(fillColor, isSelected ? 3.0 : 1.5);
            } else if (withShadow && colorChar == "s") {
              tempColor = Qt.lighter(borderColor, 1.0);
              tempColor.a = tempColor.a * 0.5
            }
            shapedata.data[pixelIndex]   = parseInt(tempColor.r * 255);
            shapedata.data[pixelIndex+1] = parseInt(tempColor.g * 255);
            shapedata.data[pixelIndex+2] = parseInt(tempColor.b * 255);
            shapedata.data[pixelIndex+3] = parseInt(tempColor.a * 255);
          }
        }
        return shapedata;
      }

      function drawShape(borderColor, fillColor, withShadow, isSelected, elementIndex) {
        var shapedata = createImage(borderColor, fillColor, withShadow, isSelected);
        context.drawImage(shapedata, 0, elementIndex * 4);
      }

      var colors = [];
      for (var i = 0; i < 7; i++) {
        colors.push({"border":Qt.darker("#2E4955", 1.0 + i * 0.1), "fill": Qt.darker("#64A8C3", 1.0 + i * 0.1)});
      }
      colors.push({"border":Qt.darker("#303B20", 1.0), "fill": Qt.darker("#708C44", 1.0)});
      for (var i = 8; i <= 15; i++) {
        colors.push({"border":Qt.darker("#3B2820", 1.0 + (i-8) * 0.1), "fill": Qt.darker("#8C5944", 1.0 + (i-8) * 0.1)});
      }

      for (var i = 0; i < colors.length; i++) {
        if (i < minimumLayer || i > maximumLayer || !isActive) {
          colors[i] = {"border": Qt.darker("#aa414141", 1.0 + i * 0.1), "fill": Qt.darker("#aa939393", 1.0 + i * 0.1)};
        }
      }

      for (var i = colors.length - 1; i >= 0; i--) {
        var tempColors = colors[i];
        drawShape(colors[i]["border"], colors[i]["fill"], i != 15, i == selectedIndex && isActive, i)
      }

      ctx.restore();
    } //onPaint
  } //Canvas
} //Item
