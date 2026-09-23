import QtQuick

import qmlcomponents


Item {

  id: root

  property OutfitPreset outfitPreset: outfitPreset

  property int floorTileID: 0
  property int socketID: 0
  property var lookDirection: OutfitAppearanceInstance.SOUTH
  property bool moving: false
  property var movementSpeed: 1000
  property alias scaleFactor: appearanceInstanceRenderer.scaleFactor
  property alias smoothTextureFiltering: appearanceInstanceRenderer.smoothTextureFiltering

  property var _outfitAppearanceInstance: null
  property var _mountAppearanceInstance: null
  property var _summonAppearanceInstance: null
  property var _socketAppearanceInstance: null

  property var _floorBaseOffset: Qt.point(-16, -16)

  property var _outfitOffset: Qt.point(0,0)
  property var _summonOffset: {
    return Qt.point(_outfitOffset.x + 64, _outfitOffset.y);
  }

  onFloorTileIDChanged: refreshView()
  onLookDirectionChanged: refreshView()
  onMovingChanged: refreshView()
  onMovementSpeedChanged: refreshView()
  onSocketIDChanged: refreshView()
  onOutfitPresetChanged: {
    presetConnections.target = root.outfitPreset;
    outfitColorConnections.target = root.outfitPreset.outfitColor;
    mountColorConnections.target = root.outfitPreset.mountColor;

    refreshView();
  }

  OutfitPreset {
    id: outfitPreset
  }

  Connections {
    id: presetConnections
    target: null
    function onPresetChanged() {
      refreshView();
    }
  }

  Connections {
    id: outfitColorConnections
    target: null
    function onColorChanged() {
      refreshView()
    }
  }

  Connections {
    id: mountColorConnections
    target: null
    function onColorChanged() {
      refreshView()
    }
  }

  Component.onCompleted: {
    refreshView();
  }

  function refreshView() {
    var OffsetWhenSummonIsShown = Qt.point(0, 0);
    if (root.outfitPreset) {
      if (root.outfitPreset.summonID != 0) {
        OffsetWhenSummonIsShown = Qt.point(-32, 0);
      }
      root._outfitOffset = Qt.point((width / appearanceInstanceRenderer.scaleFactor) / 2 + OffsetWhenSummonIsShown.x,
                      (height / appearanceInstanceRenderer.scaleFactor) / 2 + OffsetWhenSummonIsShown.y);
    }
    if (refreshComponentsTimer.running == false) {
      refreshComponentsTimer.start();
    }
  }

  Component {
    id: floorTileComponent
    ObjectAppearanceInstance {
      typeid: root.floorTileID
    }
  }
  Component {
    id: socketComponent
    ObjectAppearanceInstance {
      typeid: root.socketID
    }
  }
  Component {
    id: outfitComponent
    OutfitAppearanceInstance {
      id: outfitAppearanceInstance
      typeid: root.outfitPreset.outfitID
      headColor: root.outfitPreset.outfitColor.headColor
      torsoColor: root.outfitPreset.outfitColor.torsoColor
      legsColor: root.outfitPreset.outfitColor.legsColor
      detailColor: root.outfitPreset.outfitColor.detailColor
      firstAddOn: root.outfitPreset.outfitFirstAddOn
      secondAddOn: root.outfitPreset.outfitSecondAddOn
      lookDirection: root.lookDirection
      moving: root.moving
      movementSpeedInMillisecondsPerField: root.movementSpeed
      position: Qt.point(32, 32)
      mounted: root.outfitPreset.mountID != 0
    }
  }

  Component {
    id: mountComponent
    OutfitAppearanceInstance {
      id: outfitAppearanceInstance
      typeid: root.outfitPreset.mountID

      headColor: root.outfitPreset.mountColor.headColor
      torsoColor: root.outfitPreset.mountColor.torsoColor
      legsColor: root.outfitPreset.mountColor.legsColor
      detailColor: root.outfitPreset.mountColor.detailColor
      lookDirection: root.lookDirection
      moving: root.moving
      movementSpeedInMillisecondsPerField: root.movementSpeed
      position: Qt.point(32, 32)
    }
  }

  Component {
    id: objectAppearanceComponent

    ObjectAppearanceInstance {
      typeid: root.outfitPreset.outfitID
    }
  } // Component


  Timer {
    id: updateTimer
    interval: 20
    running: true
    repeat: true
    onTriggered: {
      appearanceInstanceRenderer.moveTiles();
    }
  }

  Timer {
    id: refreshComponentsTimer
    interval: 0
    running: false
    repeat: false
    onTriggered: {
      appearanceInstanceRenderer.refreshComponents();
      appearanceInstanceRenderer.moveTiles();
    }
  }

  AppearanceInstanceRenderer {
    id: appearanceInstanceRenderer
    property var lastTimestamp: 0;
    property var pixelsToMove: 0;
    property var baseOffset: Qt.point(32 * 8, 32 * 8)
    property var floorTilesSize: Qt.size(0,0)
    property var cameraOffset: _floorBaseOffset

    function moveTiles() {
      var completePixels = 0;
      var currentMilliseconds = new Date().getTime();
      if (root.moving) {
        var difference = currentMilliseconds - lastTimestamp;
        pixelsToMove += difference / root.movementSpeed * 32.0
        completePixels = parseInt(pixelsToMove)
        if (completePixels > 0) {
          pixelsToMove -= completePixels
        }
      } else {
        cameraOffset = _floorBaseOffset;
        pixelsToMove = 0;
      }
      lastTimestamp = currentMilliseconds;
      if (root.lookDirection == OutfitAppearanceInstance.NORTH) {
        cameraOffset = Qt.point(cameraOffset.x, cameraOffset.y - completePixels);
      } else if (root.lookDirection == OutfitAppearanceInstance.SOUTH) {
        cameraOffset = Qt.point(cameraOffset.x, cameraOffset.y + completePixels);
      } else if (root.lookDirection == OutfitAppearanceInstance.EAST) {
        cameraOffset = Qt.point(cameraOffset.x + completePixels, cameraOffset.y);
      } else if (root.lookDirection == OutfitAppearanceInstance.WEST) {
        cameraOffset = Qt.point(cameraOffset.x - completePixels, cameraOffset.y);
      }
      cameraOffset = Qt.point(cameraOffset.x % baseOffset.x, cameraOffset.y % baseOffset.y)
      var newOffset = Qt.point(cameraOffset.x + baseOffset.x, cameraOffset.y + baseOffset.y);
      appearanceInstanceRenderer.cameraPosition = newOffset;

      var elevation = 0;
      if (root._socketAppearanceInstance) {
        elevation = root._socketAppearanceInstance.elevation;
      }

      var shift = Qt.point(0, 0);
      if (root._outfitAppearanceInstance) {
        if (root.outfitPreset.mountID == 0) {
          shift.x = -1 * root._outfitAppearanceInstance.shift.x;
          shift.y = -1 * root._outfitAppearanceInstance.shift.y;
        } else if (root._mountAppearanceInstance) {
          shift.x = -1 * root._mountAppearanceInstance.shift.x;
          shift.y = -1 * root._mountAppearanceInstance.shift.y;
        }

        if (root.outfitPreset.isObjectOutfit && (elevation > 0)) {
            shift.x = 32;
            shift.y = 32;
        }
      }

      let socketPosition = Qt.point(root._outfitOffset.x + newOffset.x,
                                    root._outfitOffset.y + newOffset.y);
      let outfitPosition = Qt.point(shift.x + root._outfitOffset.x + newOffset.x - elevation,
                                    shift.y + root._outfitOffset.y + newOffset.y - elevation);
      let mountPosition = outfitPosition;
      let summonPosition = Qt.point(_summonOffset.x + newOffset.x,
                                    _summonOffset.y + newOffset.y);
      if (root._socketAppearanceInstance) {
        root._socketAppearanceInstance.position = socketPosition;
      }
      if (root._outfitAppearanceInstance) {
        root._outfitAppearanceInstance.position = outfitPosition;
      }
      if (root._mountAppearanceInstance) {
        root._mountAppearanceInstance.position = mountPosition;
      }
      if (root._summonAppearanceInstance) {
        root._summonAppearanceInstance.position = summonPosition;
      }
    }

    function refreshComponents() {
      var appearanceInstancesList = []

      if (root.outfitPreset == null) {
        return;
      }

      floorTilesSize = Qt.size((width / scaleFactor) * 2 + 2 * baseOffset.x, (height / scaleFactor) * 2 + 2 * baseOffset.y);

      if (floorTileID != 0) {
        for (var x = 0; x < floorTilesSize.width; x += 32) {
          for (var y = 0; y < floorTilesSize.height; y += 32) {
            var object = floorTileComponent.createObject(appearanceInstanceRenderer);
            object.position = Qt.point(x, y);
            appearanceInstancesList.push(object);
          }
        }
      }

      root._socketAppearanceInstance = socketComponent.createObject(appearanceInstanceRenderer);
      if (root.socketID != 0 && root.moving == false) {
        appearanceInstancesList.push(root._socketAppearanceInstance);
      }

      root._mountAppearanceInstance = mountComponent.createObject(appearanceInstanceRenderer);
      if (root.outfitPreset.mountID != 0) {
        appearanceInstancesList.push(root._mountAppearanceInstance);
      }
      root._summonAppearanceInstance = mountComponent.createObject(appearanceInstanceRenderer);
      if (root.outfitPreset.summonID != 0) {
        root._summonAppearanceInstance.position = Qt.point(64,64);
        root._summonAppearanceInstance.typeid = root.outfitPreset.summonID;
        appearanceInstancesList.push(root._summonAppearanceInstance);
      }        
      if (root.outfitPreset.outfitID != 0) {
        
        if (root.outfitPreset.isObjectOutfit) {
          root._outfitAppearanceInstance = objectAppearanceComponent.createObject(appearanceInstanceRenderer);
        } else {
          root._outfitAppearanceInstance = outfitComponent.createObject(appearanceInstanceRenderer);
        }
        appearanceInstancesList.push(root._outfitAppearanceInstance);
      }

      appearanceInstances = appearanceInstancesList;
      refreshAppearanceInstances();
    }

    anchors.fill: parent
    scaleFactor: 2.0
    smoothTextureFiltering: false
    clip: true
    animated: true
    appearanceInstances: []
  }

}
