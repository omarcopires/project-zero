import QtQuick
import qmlcomponents

Item {
  id: root

  readonly property int spellRange: _spellRange 

  property var spellPreviewData: {}

  property var _appearanceInstances: []

   property int floorTileID: 8284

  property int targetObjectID: 5787
  property double shrinkFactor: 1
  property rect previewSize: Qt.rect(0,0,0,0)
  property point cameraPosition: Qt.point(-32,-32)
  property int _spellRange: 0

  clip: true

  onSpellPreviewDataChanged: {
    Qt.callLater(recreatePreviewAnimation);
  }

  onWidthChanged: {
    Qt.callLater(recreatePreviewAnimation);
  }
  onHeightChanged: {
    Qt.callLater(recreatePreviewAnimation);
  }

  function calculatePreviewRect() {
    var points = []
    if (spellPreviewData && spellPreviewData["timestamps"]) {
      var timestamps = spellPreviewData["timestamps"];
      for (let timestampData of timestamps) {
        for (let actionData of timestampData["actions"]) {
          switch (actionData["action"]) {
            case "objecttype": 
            case "fieldEffect":
            case "missile": {
              let x = actionData["x"];
              let y = actionData["y"];
              let point = Qt.point(x, y);
              points.push(point);
              break;
            }
          }
        }
      }
    }
    let minLeft = 0;
    let minTop = 0;
    let maxRight = 0;
    let maxBottom = 0;

    for (var point of points) {
      minLeft = Math.min(minLeft, point.x);
      minTop = Math.min(minTop, point.y);
      maxRight = Math.max(maxRight, point.x);
      maxBottom = Math.max(maxBottom, point.y);
    }
    root.previewSize = Qt.rect(minLeft, minTop, maxRight - minLeft + 1, maxBottom - minTop + 1);
    
    let previewSizePixels = Qt.rect(root.previewSize.x * 32, root.previewSize.y * 32, root.previewSize.width * 32, root.previewSize.height * 32)
    let extraCameraOffset = Qt.point(0,0)
    let newShrinkFactor = Math.max(1.0, previewSizePixels.width / width, previewSizePixels.height / height);

    root.shrinkFactor = newShrinkFactor;
    root.cameraPosition = Qt.point(previewSizePixels.x - 32, previewSizePixels.y - 32);
    root._spellRange = spellPreviewData ? spellPreviewData["range"] ?? 0 : 0;
  }

  Component {
    id: appearanceInstanceComponent
    ObjectAppearanceInstance {
    }
  }

  Component {
    id: floorTileComponent
    ObjectAppearanceInstance {
      typeid: root.floorTileID
    }
  }

  Component {
    id: outfitComponent
    OutfitAppearanceInstance {
      typeid: 128
      headColor: ColorHelper.createColorFromEightBitHSV(115)
      torsoColor: ColorHelper.createColorFromEightBitHSV(113)
      legsColor: ColorHelper.createColorFromEightBitHSV(39)
      detailColor: ColorHelper.createColorFromEightBitHSV(115)
      lookDirection: OutfitAppearanceInstance.EAST
      moving: false
    }
  }

  Component {
    id: targetComponent
    ObjectAppearanceInstance {
      typeid: 15710
    }
  }

  function createAppearanceInstance(appearanceInstanceTypeID, x, y) {
    let position = Qt.point(x, y);
    let newAppearanceInstance = appearanceInstanceComponent.createObject(root, {
      "typeid": appearanceInstanceTypeID,
      "position": position
    })
    return newAppearanceInstance;
  }

  Component {
    id: scriptActionComponent
    ScriptAction {
      property var callback: () => {}
      script: {
        callback();
      }
    }
  }

  Component {
    id: pauseAnimationComponent
    PauseAnimation {
      duration: 3000
    }
  }

  SequentialAnimation {
    id: previewAnimation
    running: true
    loops: Animation.Infinite
  }

  function executeSpellAction(actionData) {
    let playerPosition = Qt.point(0,0);
    switch (actionData["action"]) {
      case "missile": {
        let missileID = actionData["missileID"];
        let distanceX = actionData["x"];
        let distanceY = actionData["y"];
        let sourceSubfieldPosition = Qt.point((playerPosition.x + 0) * 32, playerPosition.y * 32);
        let destSubfieldPosition = Qt.point((playerPosition.x + distanceX) * 32, (playerPosition.y + distanceY) * 32);
        appearanceInstanceRenderer.showMissileEffect(missileID, sourceSubfieldPosition, destSubfieldPosition);
        break;
      }
      case "fieldEffect": {
        let effectID = actionData["effectID"]
        let distanceX = actionData["x"]
        let distanceY = actionData["y"]
        let subfieldPosition = Qt.point((playerPosition.x + distanceX) * 32, (playerPosition.y + distanceY) * 32);
        appearanceInstanceRenderer.showGraphicalEffect(effectID, subfieldPosition);
        break;
      }
      case "objecttype": {
        let objecttypeID = actionData["objecttypeID"]
        let distanceX = actionData["x"]
        let distanceY = actionData["y"]
        let subfieldPosition = Qt.point((playerPosition.x + distanceX) * 32, (playerPosition.y + distanceY) * 32);
        let fieldObject = createAppearanceInstance(objecttypeID, subfieldPosition.x, subfieldPosition.y);
        appearanceInstanceRenderer.appearanceInstances.push(fieldObject);
        break;
      }
      case "clearField": {
        let distanceX = actionData["x"]
        let distanceY = actionData["y"]
        let objecttypeID = actionData["objecttypeID"]
        let subfieldPosition = Qt.point((playerPosition.x + distanceX) * 32, (playerPosition.y + distanceY) * 32);
        let filteredAppearanceInstances = appearanceInstanceRenderer.appearanceInstances.filter((object) => {
          if (object.position == subfieldPosition && object.typeid == objecttypeID) {
            return false;
          }
          return true;
        });
        appearanceInstanceRenderer.appearanceInstances = filteredAppearanceInstances;
        break;
      }
      case "target": {
        let distanceX = actionData["x"]
        let distanceY = actionData["y"]
        let subfieldPosition = Qt.point((playerPosition.x + distanceX) * 32, (playerPosition.y + distanceY) * 32);
        let fieldObject = createAppearanceInstance(root.targetObjectID, subfieldPosition.x, subfieldPosition.y);
        appearanceInstanceRenderer.appearanceInstances.push(fieldObject);
        break;
      }
    }
  }

  function recreatePreviewAnimation() {
    calculatePreviewRect();

    previewAnimation.animations = [];

    if (spellPreviewData === undefined) {
      previewAnimation.stop();
      return;
    }

    previewAnimation.animations.push(scriptActionComponent.createObject(previewAnimation, { "callback": () => {
      appearanceInstanceRenderer.appearanceInstances = [];
      appearanceInstanceRenderer.refreshAppearanceInstances();
    }}));

    let initActions = spellPreviewData["initActions"]

    previewAnimation.animations.push(scriptActionComponent.createObject(previewAnimation, { "callback": () => {
      if (floorTileID != 0) {
        for (var x = root.previewSize.left - 1; x <= root.previewSize.right + 1; x += 1) {
          for (var y = root.previewSize.top - 1; y < root.previewSize.bottom + 1; y += 1) {
            var object = createAppearanceInstance(root.floorTileID, x * 32, y * 32);
            appearanceInstanceRenderer.appearanceInstances.push(object);
          }
        }
      }
      var outfit = outfitComponent.createObject(appearanceInstanceRenderer);
      appearanceInstanceRenderer.appearanceInstances.push(outfit);

      if (initActions) {
        for (let actionData of initActions) {
          executeSpellAction(actionData);
        } 
      }
      
    }}));

    previewAnimation.animations.push(pauseAnimationComponent.createObject(previewAnimation, { "duration": 1000 }));

    let timestampsSum = 0
    if (spellPreviewData && spellPreviewData["timestamps"]) {
      var timestamps = spellPreviewData["timestamps"];
      for (let timestampData of timestamps) {
        let timestamp = timestampData["timestamp"]
        let pauseBefore = timestamp
        if (pauseBefore > 0) {
          previewAnimation.animations.push(pauseAnimationComponent.createObject(previewAnimation, { "duration": pauseBefore }));
        }
        let actions = timestampData["actions"];
        previewAnimation.animations.push(scriptActionComponent.createObject(previewAnimation, { "callback": () => {
          let playerPosition = Qt.point(0,0);
          for (let actionData of actions) {
            executeSpellAction(actionData);
          }
          appearanceInstanceRenderer.refreshAppearanceInstances(true);
        }}));
      }
    }
    previewAnimation.animations.push(scriptActionComponent.createObject(previewAnimation, { "callback": () => {
      appearanceInstanceRenderer.refreshAppearanceInstances(true);
    }}));

    previewAnimation.animations.push(pauseAnimationComponent.createObject(previewAnimation, { "duration": 2000 }));

    previewAnimation.restart();
  }



  AppearanceInstanceRenderer {
    id: appearanceInstanceRenderer
    width: (root.previewSize.width + 2) * 32
    height: (root.previewSize.height + 2) * 32
    property var lastTimestamp: 0;
    property var pixelsToMove: 0;
    property var floorTilesSize: Qt.size(0,0)
    scaleFactor: 1.0
    animated: true
    cameraPosition: root.cameraPosition
    appearanceInstances: root._appearanceInstances
  }

  ShaderEffectSource {
    id: shaderEffectSource

    property double scaleFactor: 1

    width: ((root.previewSize.width + 2) * 32) / root.shrinkFactor
    height: ((root.previewSize.height + 2) * 32) / root.shrinkFactor
    anchors.centerIn: parent
    sourceItem: appearanceInstanceRenderer
    mipmap: true
    wrapMode: ShaderEffectSource.ClampToEdge
    hideSource: true
    live: true
    smooth: true
    recursive: false
  } //ShaderEffectSource

  

}