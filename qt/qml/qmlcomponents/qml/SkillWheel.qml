import QtQuick
import Qt5Compat.GraphicalEffects

import qmlcomponents



Item {
  id: root
  implicitHeight: 522
  implicitWidth: 522

  property bool useBlending: false
  property int vocation: TibiaEnums.Knight
  property var skillParameters: []
  property var cornerParameters: []

  property var hoveredSkillId: null
  property var selectedSkillId: null
  property var hoveredLargePerkQuarter: null
  property var selectedLargePerkQuarter: null
  property var hoveredVesselQuarter: null
  property var selectedVesselQuarter: null

  signal skillRightClicked(int skillId, int keyboardModifiers)

  readonly property int _SKILL_WIDTH: 50

  readonly property int skillWheelGlobalCenterX: skillWheelCanvas.mapToItem(root, 0, 0).x +  skillWheelCanvas._CENTRE_X
  readonly property int skillWheelGlobalCenterY: skillWheelCanvas.mapToItem(root, 0, 0).x +  skillWheelCanvas._CENTRE_Y

  readonly property var _SKILL_LIST: [
    //top left quater
    {
       id: TibiaEnums.QTL0,
       radiusIndex: 0,
       startAngleGrad: 180,
       endAngleGrad: 270,
       quarter: TibiaEnums.TopLeft
     },
     {
       id: TibiaEnums.QTL1,
       radiusIndex: 1,
       startAngleGrad: 180,
       endAngleGrad: 225,
       quarter: TibiaEnums.TopLeft
     },
     {
       id: TibiaEnums.QTL3,
       radiusIndex: 1,
       startAngleGrad: 225,
       endAngleGrad: 270,
       quarter: TibiaEnums.TopLeft
     },
     {
       id: TibiaEnums.QTL2,
       radiusIndex: 2,
       startAngleGrad: 180,
       endAngleGrad: 210,
       quarter: TibiaEnums.TopLeft
     },
     {
       id: TibiaEnums.QTL4,
       radiusIndex: 2,
       startAngleGrad: 210,
       endAngleGrad: 240,
       quarter: TibiaEnums.TopLeft
     },
     {
       id: TibiaEnums.QTL6,
       radiusIndex: 2,
       startAngleGrad: 240,
       endAngleGrad: 270,
       quarter: TibiaEnums.TopLeft
     },
     {
       id: TibiaEnums.QTL5,
       radiusIndex: 3,
       startAngleGrad: 195,
       endAngleGrad: 225,
       quarter: TibiaEnums.TopLeft
     },
     {
       id: TibiaEnums.QTL7,
       radiusIndex: 3,
       startAngleGrad: 225,
       endAngleGrad: 255,
       quarter: TibiaEnums.TopLeft
     },
     {
       id: TibiaEnums.QTL8,
       radiusIndex: 4,
       startAngleGrad: 195,
       endAngleGrad: 255,
       quarter: TibiaEnums.TopLeft
     },
     //top right quater
     {
       id: TibiaEnums.QTR0,
       radiusIndex: 0,
       startAngleGrad: 270,
       endAngleGrad: 360,
       quarter: TibiaEnums.TopRight
     },
     {
       id: TibiaEnums.QTR3,
       radiusIndex: 1,
       startAngleGrad: 270,
       endAngleGrad: 315,
       quarter: TibiaEnums.TopRight
     },
     {
       id: TibiaEnums.QTR1,
       radiusIndex: 1,
       startAngleGrad: 315,
       endAngleGrad: 360,
       quarter: TibiaEnums.TopRight
     },
     {
       id: TibiaEnums.QTR6,
       radiusIndex: 2,
       startAngleGrad: 270,
       endAngleGrad: 300,
       quarter: TibiaEnums.TopRight
     },
     {
       id: TibiaEnums.QTR4,
       radiusIndex: 2,
       startAngleGrad: 300,
       endAngleGrad: 330,
       quarter: TibiaEnums.TopRight
     },
     {
       id: TibiaEnums.QTR2,
       radiusIndex: 2,
       startAngleGrad: 330,
       endAngleGrad: 360,
       quarter: TibiaEnums.TopRight
     },
     {
       id: TibiaEnums.QTR7,
       radiusIndex: 3,
       startAngleGrad: 285,
       endAngleGrad: 315,
       quarter: TibiaEnums.TopRight
     },
     {
       id: TibiaEnums.QTR5,
       radiusIndex: 3,
       startAngleGrad: 315,
       endAngleGrad: 345,
       quarter: TibiaEnums.TopRight
     },
     {
       id: TibiaEnums.QTR8,
       radiusIndex: 4,
       startAngleGrad: 285,
       endAngleGrad: 345,
       quarter: TibiaEnums.TopRight
     },
     //bottom left quater
     {
       id: TibiaEnums.QBL0,
       radiusIndex: 0,
       startAngleGrad: 90,
       endAngleGrad: 180,
       quarter: TibiaEnums.BottomLeft
     },
     {
       id: TibiaEnums.QBL3,
       radiusIndex: 1,
       startAngleGrad: 90,
       endAngleGrad: 135,
       quarter: TibiaEnums.BottomLeft
     },
     {
       id: TibiaEnums.QBL1,
       radiusIndex: 1,
       startAngleGrad: 135,
       endAngleGrad: 180,
       quarter: TibiaEnums.BottomLeft
     },
     {
       id: TibiaEnums.QBL6,
       radiusIndex: 2,
       startAngleGrad: 90,
       endAngleGrad: 120,
       quarter: TibiaEnums.BottomLeft
     },
     {
       id: TibiaEnums.QBL4,
       radiusIndex: 2,
       startAngleGrad: 120,
       endAngleGrad: 150,
       quarter: TibiaEnums.BottomLeft
     },
     {
       id: TibiaEnums.QBL2,
       radiusIndex: 2,
       startAngleGrad: 150,
       endAngleGrad: 180,
       quarter: TibiaEnums.BottomLeft
     },
     {
       id: TibiaEnums.QBL7,
       radiusIndex: 3,
       startAngleGrad: 105,
       endAngleGrad: 135,
       quarter: TibiaEnums.BottomLeft
     },
     {
       id: TibiaEnums.QBL5,
       radiusIndex: 3,
       startAngleGrad: 135,
       endAngleGrad: 165,
       quarter: TibiaEnums.BottomLeft
     },
     {
       id: TibiaEnums.QBL8,
       radiusIndex: 4,
       startAngleGrad: 105,
       endAngleGrad: 165,
       quarter: TibiaEnums.BottomLeft
     },
     //bottom right quater
     {
       id: TibiaEnums.QBR0,
       radiusIndex: 0,
       startAngleGrad: 0,
       endAngleGrad: 90,
       quarter: TibiaEnums.BottomRight
     },
     {
       id: TibiaEnums.QBR1,
       radiusIndex: 1,
       startAngleGrad: 0,
       endAngleGrad: 45,
       quarter: TibiaEnums.BottomRight
     },
     {
       id: TibiaEnums.QBR3,
       radiusIndex: 1,
       startAngleGrad: 45,
       endAngleGrad: 90,
       quarter: TibiaEnums.BottomRight
     },
     {
       id: TibiaEnums.QBR2,
       radiusIndex: 2,
       startAngleGrad: 0,
       endAngleGrad: 30,
       quarter: TibiaEnums.BottomRight
     },
     {
       id: TibiaEnums.QBR4,
       radiusIndex: 2,
       startAngleGrad: 30,
       endAngleGrad: 60,
       quarter: TibiaEnums.BottomRight
     },
     {
       id: TibiaEnums.QBR6,
       radiusIndex: 2,
       startAngleGrad: 60,
       endAngleGrad: 90,
       quarter: TibiaEnums.BottomRight
     },
     {
       id: TibiaEnums.QBR5,
       radiusIndex: 3,
       startAngleGrad: 15,
       endAngleGrad: 45,
       quarter: TibiaEnums.BottomRight
     },
     {
       id: TibiaEnums.QBR7,
       radiusIndex: 3,
       startAngleGrad: 45,
       endAngleGrad: 75,
       quarter: TibiaEnums.BottomRight
     },
     {
       id: TibiaEnums.QBR8,
       radiusIndex: 4,
       startAngleGrad: 15,
       endAngleGrad: 75,
       quarter: TibiaEnums.BottomRight
     },
  ] //_SKILL_LIST

  readonly property var _LARGE_PERK_LIST: [
    {
      quarter: TibiaEnums.TopLeft
    }
    , {
      quarter: TibiaEnums.TopRight
    }
    , {
      quarter: TibiaEnums.BottomLeft
    }
    , {
      quarter: TibiaEnums.BottomRight
    }
  ] //_LARGE_PERK_LIST

  function quarterName(quarter) {
    if (quarter == TibiaEnums.TopLeft) {
      return "TopLeft";
    } else if (quarter == TibiaEnums.TopRight) {
      return "TopRight";
    } else if (quarter == TibiaEnums.BottomLeft) {
      return "BottomLeft";
    } else if (quarter == TibiaEnums.BottomRight) {
      return "BottomRight";
    }
    return "TopLeft";
  } //quarterName

  function baseColorForQuarter(quarter) {
    if (quarter == TibiaEnums.TopLeft) {
      return TibiaStyle.skillWheelTopLeftBaseColor;
    } else if (quarter == TibiaEnums.TopRight) {
      return TibiaStyle.skillWheelTopRightBaseColor;
    } else if (quarter == TibiaEnums.BottomLeft) {
      return TibiaStyle.skillWheelBottomLeftBaseColor;
    } else if (quarter == TibiaEnums.BottomRight) {
      return TibiaStyle.skillWheelBottomRightBaseColor;
    }
    return "red";
  } //function baseColorForQuarter

  function fillColorForQuarter(quarter) {
    if (quarter == TibiaEnums.TopLeft) {
      return TibiaStyle.skillWheelTopLeftFillColor;
    } else if (quarter == TibiaEnums.TopRight) {
      return TibiaStyle.skillWheelTopRightFillColor;
    } else if (quarter == TibiaEnums.BottomLeft) {
      return TibiaStyle.skillWheelBottomLeftFillColor;
    } else if (quarter == TibiaEnums.BottomRight) {
      return TibiaStyle.skillWheelBottomRightFillColor;
    }
    return "red";
  } //function fillColorForQuarter

  function innerRadiusForRadiusIndex(radiusIndex) {
    //+1 allows to use a radius of 0
    return radiusIndex * (root._SKILL_WIDTH + TibiaStyle.skillWheelLineWidth) + 1;
  } //function innerRadiusForRadiusIndex

  function outerRadiusForRadiusIndex(radiusIndex) {
    return innerRadiusForRadiusIndex(radiusIndex) + root._SKILL_WIDTH;
  } //function outerRadiusForRadiusIndex

  function addClosedSlicePathToContext(innerRadius,
                                       outerRadius,
                                       startAngleRad,
                                       endAngleRad,
                                       ctx) {
    ctx.beginPath();
    if (innerRadius == 0) {
      ctx.moveTo(skillWheelCanvas._CENTRE_X, skillWheelCanvas._CENTRE_Y)
    } else {
      ctx.arc(skillWheelCanvas._CENTRE_X,
              skillWheelCanvas._CENTRE_Y,
              innerRadius,
              startAngleRad,
              endAngleRad,
              false);
    }
    ctx.arc(skillWheelCanvas._CENTRE_X,
            skillWheelCanvas._CENTRE_Y,
            outerRadius,
            endAngleRad,
            startAngleRad,
            true);
    ctx.closePath();
  } //function addClosedSlicePathToContext

  function getArrayEntryWithId(id, array) {
    let foundEntry = null;
    for (const entry of array) {
      if(entry.id == id) {
        foundEntry = entry;
        break;
      }
    }
    return foundEntry;
  } //function getArrayEntryWithId

  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


  Image {
    id: skillWheelBackdrop
    anchors.centerIn: parent
    source: "/images/skillwheel/backdrop_skillwheel.png"
    smooth: false
    visible: blendLoader.item == null
  } //Image

  Canvas {
    id: skillWheelCanvas
    anchors.centerIn: parent
    width: skillWheelBackdrop.width
    height: skillWheelBackdrop.height
    visible: blendLoader.item == null

    readonly property var __anyRedrawProperty: {
      root.skillParameters;
      return root.skillParameters;
    }

    on__AnyRedrawPropertyChanged: {
      changeTimer.restart()
    } //__anyOutfitPropertyChanged

    Timer {
      id: changeTimer
      interval: 0

      onTriggered: {
        skillWheelCanvas.requestPaint();
      }
    } //Timer

    readonly property int _CENTRE_X: width / 2
    readonly property int _CENTRE_Y: height / 2
    readonly property int _RADIUS: Math.min(width, height) / 2

    function drawSlice(radiusIndex,
                       startAngleGrad,
                       endAngleGrad,
                       quarter,
                       fillPercent,
                       unlocked,
                       ctx) {
      let startAngleRad = startAngleGrad * TibiaStyle.gradToRad;
      let endAngleRad = endAngleGrad * TibiaStyle.gradToRad;

      let innerRadius = root.innerRadiusForRadiusIndex(radiusIndex);
      let outerRadius = root.outerRadiusForRadiusIndex(radiusIndex);

      let fillRadius = innerRadius + fillPercent * (outerRadius - innerRadius);
      fillRadius = fillPercent < 0.5 ? Math.ceil(fillRadius) : Math.floor(fillRadius);

      if (fillPercent > 0) {
        //filled area
        root.addClosedSlicePathToContext(innerRadius,
                                         fillRadius,
                                         startAngleRad,
                                         endAngleRad,
                                         ctx);
        ctx.fillStyle = root.fillColorForQuarter(quarter);
        ctx.fillRule = Qt.OddEvenFill;
        ctx.fill();
      }

      if (unlocked) {
        //full area
        root.addClosedSlicePathToContext(innerRadius,
                                         outerRadius,
                                         startAngleRad,
                                         endAngleRad,
                                         ctx);
        ctx.fillStyle = root.baseColorForQuarter(quarter);
        ctx.fillRule = Qt.OddEvenFill;
        ctx.fill();
      }
    } //function drawSlice

    onPaint: {
      let ctx = getContext("2d");
      ctx.reset()

      //draw slice
      for (const skill of root._SKILL_LIST) {
        let fillPercent = 0.0;
        let unlocked = false;
        let entry = getArrayEntryWithId(skill["id"],
                                        root.skillParameters);
        if (entry != null) {
          fillPercent = entry["fillPercent"];
          unlocked = entry["unlocked"];
        }

        drawSlice(skill["radiusIndex"],
                  skill["startAngleGrad"],
                  skill["endAngleGrad"],
                  skill["quarter"],
                  fillPercent,
                  unlocked,
                  ctx);
      }
    } //onPaint
  } //Canvas

  Loader {
    id: blendLoader
    anchors.centerIn: parent
    width: skillWheelBackdrop.width
    height: skillWheelBackdrop.height
    Component {
      id: blendComponent
        Blend {
          anchors.fill: parent
          source: skillWheelBackdrop
          foregroundSource: skillWheelCanvas
          cached: false
          mode: "addition"
        } //Blend
    } //Component
    sourceComponent: root.useBlending ? blendComponent : undefined
  } //Loader

  Canvas {
    id: hoverCanvas
    anchors.centerIn: parent
    width: skillWheelBackdrop.width
    height: skillWheelBackdrop.height
    visible: blendHoverLayerLoader.item == null

    readonly property var __anyRedrawProperty: {
      root.skillParameters;
      root.hoveredSkillId;
      return root.hoveredSkillId != false;
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

    function drawHoverMarker(radiusIndex,
                             startAngleGrad,
                             endAngleGrad,
                             ctx) {
      root.addClosedSlicePathToContext(root.innerRadiusForRadiusIndex(radiusIndex),
                                       root.outerRadiusForRadiusIndex(radiusIndex),
                                       startAngleGrad * TibiaStyle.gradToRad,
                                       endAngleGrad * TibiaStyle.gradToRad,
                                       ctx);
      ctx.fillStyle = TibiaStyle.skillWheelHoverColor;
      ctx.fillRule = Qt.OddEvenFill;
      ctx.fill();
    } //function drawMarker

    onPaint: {
      let ctx = getContext("2d");
      ctx.reset()

      //draw markers
      if (root.hoveredSkillId != null) {
        for (const skill of root._SKILL_LIST) {
          if (skill["id"] == root.hoveredSkillId) {
            drawHoverMarker(skill["radiusIndex"],
                            skill["startAngleGrad"],
                            skill["endAngleGrad"],
                            ctx);
            break;
          }
        }
      }
    } //onPaint
  } //Canvas

  Loader {
    id: blendHoverLayerLoader
    anchors.centerIn: parent
    width: skillWheelBackdrop.width
    height: skillWheelBackdrop.height
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

  Repeater {
    model: root._SKILL_LIST

    Image {
      id: perkDelegateRoot
      smooth: false

      source: {
        let entry = getArrayEntryWithId(modelData["id"],
                                        root.skillParameters);
        if (entry != null) {
          return entry["largeImage"];
        }

        return "";
      } //source

      function getMeanRadius(data) {
        let meanRadius = (  root.innerRadiusForRadiusIndex(modelData["radiusIndex"])
                          + root.outerRadiusForRadiusIndex(modelData["radiusIndex"]))
                         / 2;

        return meanRadius + (meanRadius < root.outerRadiusForRadiusIndex(0) ? 2 : 0)
      } //function getMeanRadius

      function getMeanAngleRad(data) {
        return (  modelData["startAngleGrad"]
                + modelData["endAngleGrad"])
               / 2
               * TibiaStyle.gradToRad;
      } //function getMeanAngle

      x: Math.round(Math.cos(getMeanAngleRad(modelData)) * getMeanRadius(modelData)
         + root.skillWheelGlobalCenterX - (width / 2))
      y: Math.round(Math.sin(getMeanAngleRad(modelData)) * getMeanRadius(modelData)
         + root.skillWheelGlobalCenterY - (height / 2))


      Image {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        //icon has 3 pixel rows and columns outside parent, this is intentional
        anchors.bottomMargin: -3
        anchors.leftMargin: -3
        smooth: false

        source: {
          let entry = getArrayEntryWithId(modelData["id"],
                                          root.skillParameters);
          if (entry != null) {
            return "image://icons-skillwheel-smallperks/" + (entry["smallPerkId"]);
          }
          return ""
        } //color
      } //Image
      Loader {
        property int modType: {
          let entry = getArrayEntryWithId(modelData["id"], root.skillParameters);
          if (entry != null) {
            return entry["modType"];
          }
          return TibiaEnums.GemModTypeNone;
        }
        Component {
          id: gemModImageComponent
          Image {
            property int modType: TibiaEnums.GemModTypeNone
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: modType == TibiaEnums.GemModTypeSupreme ? -1 : -1
            anchors.topMargin: modType == TibiaEnums.GemModTypeSupreme ? 4 : -1
            smooth: false
            source: {
              if (modType == TibiaEnums.GemModTypeBasic) {
                return "/images/skillwheel/icon-skillwheel-vesselresonance-basic.png";
              } else if (modType == TibiaEnums.GemModTypeSupreme) {
                return "/images/skillwheel/icon-skillwheel-vesselresonance-supreme.png";
              } else {
                return "";
              }
            }
          }
        }
        onItemChanged: {
          if (item) {
            item.modType = modType;
          }
        }
        sourceComponent: modType != TibiaEnums.GemModTypeNone ? gemModImageComponent : undefined
      }
    } //Image
  } //Repeater

  Repeater {
    id: cornerRepeater
    model: root._LARGE_PERK_LIST

    SkillWheelCorner {
      anchors.top: quarter == TibiaEnums.TopLeft || quarter == TibiaEnums.TopRight ? parent.top : undefined
      anchors.left: quarter == TibiaEnums.TopLeft || quarter == TibiaEnums.BottomLeft ? parent.left : undefined
      anchors.bottom: quarter == TibiaEnums.BottomLeft || quarter == TibiaEnums.BottomRight ? parent.bottom : undefined
      anchors.right: quarter == TibiaEnums.TopRight || quarter == TibiaEnums.BottomRight ? parent.right : undefined
      useBlending: root.useBlending

      quarter: modelData["quarter"]
      baseColor: root.fillColorForQuarter(quarter)
      fillColor: root.fillColorForQuarter(quarter)
      wheelCentreX: skillWheelCanvas._CENTRE_X
      wheelCentreY: skillWheelCanvas._CENTRE_Y

      readonly property var parameters : {
        let entry = getArrayEntryWithId(quarter,
                                        root.cornerParameters);
        if (entry != null) {
          return entry;
        }

        return null;
      } //parameters

      largePerkId: parameters != null ? parameters["largePerkId"] : 0
      level: parameters != null ? parameters["level"] : 0
      fillPercent: parameters != null ? parameters["fillPercent"] : 0
      gemImageSource: parameters != null ? parameters["gemImageSource"] : ""
      socketBezelSource: parameters != null ? parameters["socketBezelSource"] : ""

      largePerkHovered: quarter == root.hoveredLargePerkQuarter
      largePerkSelected: quarter == root.selectedLargePerkQuarter
      vesselHovered: quarter == root.hoveredVesselQuarter
      vesselSelected: quarter == root.selectedVesselQuarter
    } //SkillWheelCorner
  } //Repeater

  Image {
    id: skillWheelOultines
    anchors.centerIn: skillWheelBackdrop
    source: switch (root.vocation) {
      case TibiaEnums.Knight: "/images/skillwheel/backdrop_skillwheel_front_knight.png"; break
      case TibiaEnums.Paladin: "/images/skillwheel/backdrop_skillwheel_front_paladin.png"; break
      case TibiaEnums.Sorcerer: "/images/skillwheel/backdrop_skillwheel_front_sorc.png"; break
      case TibiaEnums.Druid: "/images/skillwheel/backdrop_skillwheel_front_druid.png"; break
      case TibiaEnums.Monk: "/images/skillwheel/backdrop_skillwheel_front_monk.png"; break
      default: "/images/skillwheel/backdrop_skillwheel_front_knight.png"; break
    }
    smooth: false
  } //Image

  Canvas {
    id: selectionCanvas
    anchors.centerIn: parent
    width: skillWheelBackdrop.width
    height: skillWheelBackdrop.height

    readonly property var __anyRedrawProperty: {
      root.skillParameters;
      root.selectedSkillId;
      return root.selectedSkillId != false;
    }

    on__AnyRedrawPropertyChanged: {
      selectionCanvasChangeTimer.restart()
    } //__anyOutfitPropertyChanged

    Timer {
      id: selectionCanvasChangeTimer
      interval: 0

      onTriggered: {
        selectionCanvas.requestPaint();
      }
    } //Timer

    function drawSelectionMarker(radiusIndex,
                                 startAngleGrad,
                                 endAngleGrad,
                                 ctx) {
      root.addClosedSlicePathToContext(root.innerRadiusForRadiusIndex(radiusIndex) - TibiaStyle.skillWheelLineWidth / 2,
                                       root.outerRadiusForRadiusIndex(radiusIndex) + TibiaStyle.skillWheelLineWidth / 2,
                                       startAngleGrad * TibiaStyle.gradToRad,
                                       endAngleGrad * TibiaStyle.gradToRad,
                                       ctx);
      ctx.lineWidth = TibiaStyle.skillWheelLineWidth;
      ctx.strokeStyle = "white";
      ctx.stroke();
    } //function drawMarker

    onPaint: {
      let ctx = getContext("2d");
      ctx.reset()

      //draw markers
      if (root.selectedSkillId != null) {
        for (const skill of root._SKILL_LIST) {
          if (skill["id"] == root.selectedSkillId) {
            drawSelectionMarker(skill["radiusIndex"],
                                skill["startAngleGrad"],
                                skill["endAngleGrad"],
                                ctx);
            break;
          }
        }
      }
    } //onPaint
  } //Canvas

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.RightButton | Qt.LeftButton
    hoverEnabled: true

    function getSkillForPosition(mouse) {
      let posInWheel = mapToItem(skillWheelCanvas,
                                 mouse.x,
                                 mouse.y);
      let posX = posInWheel.x - skillWheelCanvas._CENTRE_X;
      let posY = posInWheel.y - skillWheelCanvas._CENTRE_Y;

      let radius = Math.sqrt(posX * posX + posY * posY);
      let angle = Math.atan(posY / posX) * TibiaStyle.radToGrad;
      if (posX < 0) {
        angle += 180;
      } else if (posX > 0 && posY < 0) {
        angle += 360;
      }

      let skillId = null;

      for (const slice of root._SKILL_LIST) {
        //include outlines
        let innerRadius = root.innerRadiusForRadiusIndex(slice["radiusIndex"]) - TibiaStyle.skillWheelLineWidth / 2;
        let outerRadius = root.outerRadiusForRadiusIndex(slice["radiusIndex"]) + TibiaStyle.skillWheelLineWidth / 2;

        if(   innerRadius <= radius && radius <= outerRadius
           && slice["startAngleGrad"] <= angle && angle < slice["endAngleGrad"]) {
           skillId = slice["id"];
           break;
        }
      }

      return skillId;
    } //function getSkillForPosition

    function getLargePerkForPosition(mouse) {
      let largePerkQuarter = null;

      for (const largePerk of root._LARGE_PERK_LIST) {
        for(let i = 0; i < cornerRepeater.count; ++i) {
          let cornerItem = cornerRepeater.itemAt(i);
          if (largePerk["quarter"] == cornerItem.quarter) {
            if (cornerItem.isPointInLargePerk(mapToItem(cornerItem,
                                                        mouse.x,
                                                        mouse.y))) {
                largePerkQuarter = cornerItem.quarter;
                break;
            }
          }
        }
      }

      return largePerkQuarter;
    } //function getLargePerkForPosition

    function getVesselForPosition(mouse) {
      let vesselQuarter = null;

      for (const vessel of root._LARGE_PERK_LIST) {
        for(let i = 0; i < cornerRepeater.count; ++i) {
          let cornerItem = cornerRepeater.itemAt(i);
          if (vessel["quarter"] == cornerItem.quarter) {
            if (cornerItem.isPointInVessel(mapToItem(cornerItem,
                                                     mouse.x,
                                                     mouse.y))) {
                vesselQuarter = cornerItem.quarter;
                break;
            }
          }
        }
      }

      return vesselQuarter;
    } //function getVesselForPosition

    onPositionChanged: (mouse) => {
      root.hoveredSkillId = getSkillForPosition(mouse);
      root.hoveredLargePerkQuarter = getLargePerkForPosition(mouse);
      root.hoveredVesselQuarter = getVesselForPosition(mouse);
    } //onPositionChanged

    onClicked: (mouse) => {
      root.selectedSkillId = getSkillForPosition(mouse);
      root.selectedLargePerkQuarter = getLargePerkForPosition(mouse);
      root.selectedVesselQuarter = getVesselForPosition(mouse);

      if (selectedSkillId != null) {
        if (mouse.button == Qt.RightButton) {
          root.skillRightClicked(root.selectedSkillId, mouse.modifiers);
        }
      }
    } //onClicked
  } //MouseArea
} //Item
