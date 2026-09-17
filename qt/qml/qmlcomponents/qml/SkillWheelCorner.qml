import QtQuick
import Qt5Compat.GraphicalEffects

import qmlcomponents


Item {
  id: root
  implicitHeight: cornerImage.height
  implicitWidth: cornerImage.width
  property bool useBlending: true

  property var quarter: TibiaEnums.TopLeft
  property color baseColor: TibiaStyle.skillWheelTopLeftBaseColor
  property color fillColor: TibiaStyle.skillWheelTopLeftFillColor
  property color hoverColor: TibiaStyle.skillWheelHoverColor

  property var largePerkId: null
  property int level: 0
  property real fillPercent: 0.0
  property url gemImageSource: ""
  property url socketBezelSource: ""

  property int wheelCentreX: quarter == TibiaEnums.TopLeft || quarter == TibiaEnums.BottomLeft ? width : 0
  property int wheelCentreY: quarter == TibiaEnums.TopLeft || quarter == TibiaEnums.TopRight ? height : 0

  property bool largePerkHovered: false
  property bool largePerkSelected: false
  property bool vesselHovered: false
  property bool vesselSelected: false

  readonly property var anchorsTop: quarter == TibiaEnums.TopLeft || quarter == TibiaEnums.TopRight ? top : undefined
  readonly property var anchorsLeft: quarter == TibiaEnums.TopLeft || quarter == TibiaEnums.BottomLeft ? left : undefined
  readonly property var anchorsBottom: quarter == TibiaEnums.BottomLeft || quarter == TibiaEnums.BottomRight ? bottom : undefined
  readonly property var anchorsRight: quarter == TibiaEnums.TopRight || quarter == TibiaEnums.BottomRight ? right : undefined

  readonly property int baseAngleGrad: {
    if (quarter == TibiaEnums.TopLeft) {
      return 180;
    } else if (quarter == TibiaEnums.TopRight) {
      return 270;
    } else if (quarter == TibiaEnums.BottomLeft) {
      return 90;
    } else if (quarter == TibiaEnums.BottomRight) {
      return 0;
    }
    return 0;
  } //baseAngleGrad

  readonly property int relativWheelCentreX: {
    if (   quarter == TibiaEnums.TopLeft
        || quarter == TibiaEnums.BottomLeft) {
      return wheelCentreX;
    } else if (   quarter == TibiaEnums.TopRight
               || quarter == TibiaEnums.BottomRight) {
      return cornerBackground.width - wheelCentreX;
    }
    return wheelCentreX;
  } //relativWheelCentreX

  readonly property int relativWheelCentreY: {
    if (   quarter == TibiaEnums.TopLeft
        || quarter == TibiaEnums.TopRight) {
      return wheelCentreY;
    } else if (   quarter == TibiaEnums.BottomLeft
               || quarter == TibiaEnums.BottomRight) {
      return cornerBackground.height - wheelCentreY;
    }
    return wheelCentreY;
  } //relativeWheelCentreY

  readonly property int largePerkQuarterRadius: 311
  readonly property int largePerkRadius: 25
  readonly property real largePerkAngle: 45
  readonly property int largePerkCentreX: Math.round(Math.cos((baseAngleGrad + largePerkAngle) * TibiaStyle.gradToRad) * largePerkQuarterRadius) + relativWheelCentreX
  readonly property int largePerkCentreY: Math.round(Math.sin((baseAngleGrad + largePerkAngle) * TibiaStyle.gradToRad) * largePerkQuarterRadius) + relativWheelCentreY

  readonly property int vesselQuarterRadius: 287
  readonly property int vesselRadius: 17
  readonly property real vesselAngleAlpha: 11.3
  readonly property real vesselAngle: largePerkAngle + vesselAngleAlpha * (quarter == TibiaEnums.TopRight || quarter == TibiaEnums.BottomLeft ? -1 : 1)
  readonly property int vesselCentreX: Math.round(Math.cos((baseAngleGrad + vesselAngle) * TibiaStyle.gradToRad) * vesselQuarterRadius) + relativWheelCentreX
  readonly property int vesselCentreY: Math.round(Math.sin((baseAngleGrad + vesselAngle) * TibiaStyle.gradToRad) * vesselQuarterRadius) + relativWheelCentreY

  readonly property int imageRoationAngleGrad: {
    if (root.quarter == TibiaEnums.TopLeft) {
      return 0;
    } else if (root.quarter == TibiaEnums.TopRight) {
      return 90;
    } else if (root.quarter == TibiaEnums.BottomLeft) {
      return 270;
    } else if (root.quarter == TibiaEnums.BottomRight) {
      return 180;
    }
    return 0;
  } //imageRoationAngleGrad

  function isPointInLargePerk(pos) {
    let posInBackground = mapToItem(cornerBackground,
                                    pos.x,
                                    pos.y);
    let diffX = largePerkCentreX - posInBackground.x;
    let diffY = largePerkCentreY - posInBackground.y;
    let lenSquared = diffX * diffX + diffY * diffY;

    return lenSquared <= largePerkRadius*largePerkRadius;
  } //function isPointInLargePerk

  function isPointInVessel(pos) {
    let posInBackground = mapToItem(cornerBackground,
                                    pos.x,
                                    pos.y);
    let diffX = vesselCentreX - posInBackground.x;
    let diffY = vesselCentreY - posInBackground.y;
    let lenSquared = diffX * diffX + diffY * diffY;

    return lenSquared <= vesselRadius*vesselRadius;
  } //function isPointInVessel

  function addClosedLargePerkCirclePathToContext(fillPercent,
                                                 ctx) {
    let startAngleGrad = -90;
    ctx.beginPath();
    if (fillPercent != 1.0) {
      ctx.moveTo(root.largePerkCentreX,
                 root.largePerkCentreY);
    }
    ctx.arc(root.largePerkCentreX,
            root.largePerkCentreY,
            root.largePerkRadius,
            startAngleGrad * TibiaStyle.gradToRad,
            (fillPercent * 360 + startAngleGrad) * TibiaStyle.gradToRad,
            false);
    ctx.closePath();
  } //function addClosedLargePerkCirclePathToContext


  function addClosedVesselCirclePathToContext(ctx) {
    ctx.beginPath();
    ctx.arc(root.vesselCentreX,
            root.vesselCentreY,
            root.vesselRadius,
            0 * TibiaStyle.gradToRad,
            360 * TibiaStyle.gradToRad,
            false);
    ctx.closePath();
  } //function addClosedVesselCirclePathToContext

  function addImageSourceQuarterPostfix(baseName) {
    if (root.quarter == TibiaEnums.TopLeft) {
      return baseName + "_TL.png";
    } else if (root.quarter == TibiaEnums.TopRight) {
      return baseName + "_TR.png";
    } else if (root.quarter == TibiaEnums.BottomLeft) {
      return baseName + "_BL.png";
    } else if (root.quarter == TibiaEnums.BottomRight) {
      return baseName + "_BR.png";
    }
    return baseName + "_TL.png";
  } //function addImageSourceQuarterPostfix()

  function addImageSourceVesselQuarterPostfix(baseName) {
    let name = baseName;
    if (root.socketBezelSource != "") {
      name = name + "_socketenabled";
    } else {
      name = name + "_socketdisabled";
    }

    return root.addImageSourceQuarterPostfix(name);
  } //function addImageSourceVesselQuarterPostfix

  // If any of the below properties are changed, the canvas has to be repainted.
  onWidthChanged: mainCanvas.requestPaint()
  onHeightChanged: mainCanvas.requestPaint()
  onQuarterChanged: mainCanvas.requestPaint()
  onBaseColorChanged: mainCanvas.requestPaint()
  onFillColorChanged: mainCanvas.requestPaint()
  onWheelCentreXChanged: mainCanvas.requestPaint()
  onWheelCentreYChanged: mainCanvas.requestPaint()
  onFillPercentChanged: mainCanvas.requestPaint()

  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


  Image {
    id: cornerBackground
    anchors.top: root.anchorsTop
    anchors.left: root.anchorsLeft
    anchors.bottom: root.anchorsBottom
    anchors.right: root.anchorsRight
    visible: blendLoader.item == null

    source: root.addImageSourceVesselQuarterPostfix("/images/skillwheel/backdrop_skillwheel_largebonus")
  } //Image

  Canvas {
    id: mainCanvas
    anchors.top: root.anchorsTop
    anchors.left: root.anchorsLeft
    anchors.bottom: root.anchorsBottom
    anchors.right: root.anchorsRight
    width: cornerBackground.width
    height: cornerBackground.height
    visible: blendLoader.item == null

    onPaint: {
      let ctx = getContext("2d");
      ctx.reset()

      //draw large perk progress
      root.addClosedLargePerkCirclePathToContext(root.fillPercent,
                                                 ctx);
      ctx.fillStyle = root.fillColor;
      ctx.fillRule = Qt.OddEvenFill;
      ctx.fill();

      root.addClosedLargePerkCirclePathToContext(1,
                                                 ctx);
      ctx.fillStyle = root.baseColor;
      ctx.fillRule = Qt.OddEvenFill;
      ctx.fill();

      //draw blob colours
      let innerRadius = 270;
      let outerRadius = 285;
      let blobStartAngleRad = (baseAngleGrad + 40) * TibiaStyle.gradToRad;
      let blobEndAngleRad = (baseAngleGrad + 50) * TibiaStyle.gradToRad;

      ctx.beginPath();
      ctx.arc(relativWheelCentreX,
              relativWheelCentreY,
              innerRadius,
              blobStartAngleRad,
              blobEndAngleRad,
              false);
      ctx.arc(relativWheelCentreX,
              relativWheelCentreY,
              outerRadius,
              blobEndAngleRad,
              blobStartAngleRad,
              true);
      ctx.closePath();
      ctx.fillStyle = root.fillcolor;
      ctx.fillRule = Qt.OddEvenFill;
      ctx.fill();
      ctx.fillStyle = root.baseColor;
      ctx.fillRule = Qt.OddEvenFill;
      ctx.fill();
    } //onPaint
  } //Canvas

  Loader {
    id: blendLoader
    anchors.top: root.anchorsTop
    anchors.left: root.anchorsLeft
    anchors.bottom: root.anchorsBottom
    anchors.right: root.anchorsRight
    width: cornerBackground.width
    height: cornerBackground.height
    Component {
      id: blendComponent
        Blend {
          anchors.fill: parent
          source: cornerBackground
          foregroundSource: mainCanvas
          cached: false
          mode: "addition"
        } //Blend
    } //Component
    sourceComponent: root.useBlending ? blendComponent : undefined
  } //Loader

  Canvas {
    id: hoverCanvas
    anchors.top: root.anchorsTop
    anchors.left: root.anchorsLeft
    anchors.bottom: root.anchorsBottom
    anchors.right: root.anchorsRight
    width: cornerBackground.width
    height: cornerBackground.height
    visible: blendHoverLayerLoader.item == null

    readonly property var __anyRedrawProperty: {
      root.largePerkHovered;
      root.vesselHovered;
      return root.largePerkHovered != false;
    }

    on__AnyRedrawPropertyChanged: {
      hoverCanvasChangeTimer.restart()
    } //__anyOutfitPropertyChanged

    Timer {
      id: hoverCanvasChangeTimer
      interval: 0

      onTriggered: {
        hoverCanvas.requestPaint();
      }
    } //Timer

    onPaint: {
      let ctx = getContext("2d");
      ctx.reset()

      if (root.largePerkHovered) {
        root.addClosedLargePerkCirclePathToContext(1,
                                                   ctx);
        ctx.fillStyle = root.hoverColor;
        ctx.fillRule = Qt.OddEvenFill;
        ctx.fill();
      }

      if (root.vesselHovered) {
        root.addClosedVesselCirclePathToContext(ctx);
        ctx.fillStyle = root.hoverColor;
        ctx.fillRule = Qt.OddEvenFill;
        ctx.fill();
      }
    } //onPaint
  } //Canvas

  Loader {
    id: blendHoverLayerLoader
    anchors.top: root.anchorsTop
    anchors.left: root.anchorsLeft
    anchors.bottom: root.anchorsBottom
    anchors.right: root.anchorsRight
    width: cornerBackground.width
    height: cornerBackground.height
    Component {
      id: blendHoverLayerComponent
        Blend {
          anchors.fill: parent
          source: blendLoader
          foregroundSource: hoverCanvas
          cached: false
          mode: "addition"
        } //Blend
    } //Component
    sourceComponent: root.useBlending ? blendHoverLayerComponent : undefined
  } //Loader

  Image {
    id: decoration
    anchors.top: root.anchorsTop
    anchors.left: root.anchorsLeft
    anchors.bottom: root.anchorsBottom
    anchors.right: root.anchorsRight
    visible: blendDecrationDetailsLayerLoader.item == null

    opacity: visible ? 0.4 : 1

    source: root.addImageSourceQuarterPostfix("/images/skillwheel/backdrop_skillwheel_largebonus_light")
  } //Image

  Loader {
    id: blendDecrationDetailsLayerLoader
    anchors.top: root.anchorsTop
    anchors.left: root.anchorsLeft
    anchors.bottom: root.anchorsBottom
    anchors.right: root.anchorsRight
    width: cornerBackground.width
    height: cornerBackground.height
    Component {
      id: blendDecrationDetailsComponent
        Blend {
          anchors.fill: parent
          source: blendHoverLayerLoader
          foregroundSource: decoration
          cached: false
          mode: "addition"
        } //Blend
    } //Component
    sourceComponent: root.useBlending ? blendDecrationDetailsComponent : undefined
  } //Loader

  Image {
    id: cornerImage
    source: {
       if (root.level == 0) {
        return root.addImageSourceQuarterPostfix("/images/skillwheel/backdrop_skillwheel_largebonus_front0");
      } else if (root.level == 1) {
        return root.addImageSourceQuarterPostfix("/images/skillwheel/backdrop_skillwheel_largebonus_front1");
      } else if (root.level == 2) {
        return root.addImageSourceQuarterPostfix("/images/skillwheel/backdrop_skillwheel_largebonus_front2");
      } else if (root.level == 3) {
        return root.addImageSourceQuarterPostfix("/images/skillwheel/backdrop_skillwheel_largebonus_front3");
      }
      return root.addImageSourceQuarterPostfix("/images/skillwheel/backdrop_skillwheel_largebonus_front0");
    } //source
  } //Image

  Image {
    anchors.top: root.anchorsTop
    anchors.left: root.anchorsLeft
    anchors.bottom: root.anchorsBottom
    anchors.right: root.anchorsRight
    anchors.margins: 24

    source: "image://icons-skillwheel-largeperks/" + root.largePerkId;
  } //Image

  Image {
    id: cornerImageLargePerkSelectionMarker
    source: "/images/skillwheel/marker_largeperk.png"
    visible: root.largePerkSelected
    property int markerOffsetX: -Math.round(width / 2) + 41
    property int markerOffsetY: -Math.round(height / 2) + 41
    property int mirrorX: root.quarter == TibiaEnums.TopRight || root.quarter == TibiaEnums.BottomRight
    property int mirrorY: root.quarter == TibiaEnums.BottomRight || root.quarter == TibiaEnums.BottomLeft
    property int markerPosX: mirrorX ? root.width - markerOffsetX - width : markerOffsetX
    property int markerPosY: mirrorY ? root.height - markerOffsetY - height : markerOffsetY
    x: markerPosX
    y: markerPosY
  } //Image

  Item {
    width: cornerImageVesselSelectionMarker.width
    height: cornerImageVesselSelectionMarker.height

    property int markerOffsetX: -Math.round(width / 2) + 101
    property int markerOffsetY: -Math.round(height / 2) + 22
    property int mirrorX: root.quarter == TibiaEnums.TopRight || root.quarter == TibiaEnums.BottomRight
    property int mirrorY: root.quarter == TibiaEnums.BottomRight || root.quarter == TibiaEnums.BottomLeft
    property int markerPosX: mirrorX ? root.width - markerOffsetX - width : markerOffsetX
    property int markerPosY: mirrorY ? root.height - markerOffsetY - height : markerOffsetY
    x: markerPosX
    y: markerPosY

    Image {
      id: cornerImageVesselSelectionMarker
      anchors.centerIn: parent
      source: "/images/skillwheel/marker_skillwheelsocket.png"
      visible: root.vesselSelected
    } //Image

    Image {
      anchors.centerIn: parent
      source: root.gemImageSource
    } //Image

    Image {
      anchors.centerIn: parent
      source: root.socketBezelSource
    } //Image
  } //Item
} //Item
