import QtQuick

import qmlcomponents
import "qrc:/qt/qml/qmlcomponents/qml/"

Item {
  id: worldmap
  readonly property var appearanceInstanceRenderer: appearanceInstanceRenderer
  readonly property var npcPosition: _npcPosition
  property alias monsterHUDVisible: monsterHUDInfo.visible
  readonly property int npcTutorialMarkerID: npcTutorialMarker.markerID

  property int worldmapFieldsX: 2
  property int worldmapFieldsY: 4
  property int baseplateOffset: 8

  property bool animated: true
  property var outfitAppearanceInstance: null

  readonly property var _playerPosition: Qt.point(32, 96)
  readonly property var _npcPosition: Qt.point(32, 32)
  readonly property var _counterPosition: Qt.point(32, 64)

  width: 32 * worldmapFieldsX
  height: 32 * worldmapFieldsY

  Component {
    id: outfitComponent
    OutfitAppearanceInstance {
      typeid: 129
      headColor: ColorHelper.createColorFromEightBitHSV(115)
      torsoColor: ColorHelper.createColorFromEightBitHSV(113)
      legsColor: ColorHelper.createColorFromEightBitHSV(39)
      detailColor: ColorHelper.createColorFromEightBitHSV(115)
      lookDirection: OutfitAppearanceInstance.NORTH
      position: _playerPosition
    }
  }

  Component {
    id: npcComponentTrader
    OutfitAppearanceInstance {
      typeid: 136
      headColor: ColorHelper.createColorFromEightBitHSV(78)
      torsoColor: ColorHelper.createColorFromEightBitHSV(19)
      legsColor: ColorHelper.createColorFromEightBitHSV(58)
      detailColor: ColorHelper.createColorFromEightBitHSV(10)
      lookDirection: OutfitAppearanceInstance.SOUTH
      position: _npcPosition
    }
  }

  Component {
    id: npcComponentBanker
    OutfitAppearanceInstance {
      typeid: 132
      headColor: ColorHelper.createColorFromEightBitHSV(57)
      torsoColor: ColorHelper.createColorFromEightBitHSV(113)
      legsColor: ColorHelper.createColorFromEightBitHSV(95)
      detailColor: ColorHelper.createColorFromEightBitHSV(96)
      lookDirection: OutfitAppearanceInstance.SOUTH
      position: _npcPosition
    }
  }

  Component {
    id: objectComponent
    ObjectAppearanceInstance {
    }
  }

  component CreatureHUDInfoBase: QtObject {
    property string name: ""
    property bool showCreatureName: true
    property real healthPercent: 1.0
    property real manaPercent: 1.0
    property real manaShieldPercent: 1.0
    property bool showHealthBar: true
    property bool showManaBar: false
    property bool showManaShieldBar: false
    property color healthColor: ColorHelper.createColorForHealthPercent(healthPercent)
    property var horizontalCreatureIconsDataModel: []
    property var verticalCreatureIconsDataModel: []
    property real scaleFactor: 1.0
    property bool showBars: false
    property bool showArcs: false
    property bool isFiendishMonster: false
    property bool showCombopointsAndSerene: false
    property int comboPoints: 0
    property bool isSerene: false
    property real arcOpacity: 1.0
    property real arcDistance: 1.0
    property real arcHeight: 1.0
    property int  arcWidth: 1
  }

  CreatureHUDInfoBase {
    id: playerHUDInfo
    showBars: false
    showCreatureName: false
  }
  CreatureHUDInfoBase {
    id: monsterHUDInfo
    property bool visible: true
    name: visible ? "Salamander" : ""
    showBars: visible
  }
  CreatureHUDInfoBase {
    id: fritzHUDInfo
    name: qsTrId("tutorial_text_bank_npc_name")
  }
  CreatureHUDInfoBase {
    id: amandaHUDInfo
    name: qsTrId("tutorial_text_loot_npc_name")
  }


  Component {
    id: numericalEffectComponent
    TibiaText {
      id: text
      property int   value: 0
      style: Text.Outline
      text: value
      function start() {
        offsetAnimation.start();
      }

      NumberAnimation {
        id: offsetAnimation
        target: text
        property: "y"
        from: text.y
        to: text.y - 20
        duration: 1000

        onFinished: () => {
          text.destroy();
        }
      }
    }
  }

  Component {
    id: gameMessageComponent
    TibiaText {
      id: text
      property int offset: 0
      style: Text.Outline
      function start() {
        durationAnimation.start();
      }

      PauseAnimation {
        id: durationAnimation
        duration: 1000
        onFinished: () => {
          text.destroy();
        }
      }
    }
  }

  function showGraphicalEffect(creatureType, effect) {
    let point = Qt.point(32,32);
    if (creatureType == TutorialEnums.CreatureType.Player) {
        point = Qt.point(32, 64)
    }
    appearanceInstanceRenderer.showGraphicalEffect(effect, point);
  }

  function showNumericalEffect(creatureType, value, numericalColor) {
    let point = Qt.point(32 + 32, 32);
    if (creatureType == TutorialEnums.CreatureType.Player) {
        point = Qt.point(32 + 32, 64)
    }
    createNumericalEffect(point, value, ColorHelper.createColorFromEightBitRGB(numericalColor));
  }

  function changeMonsterTargetBorder(visible, color) {
    let border = monsterTargetBorder;
    border.visible = visible;
    border.border.color = color;
  }

  function showTemporaryTargetBorder(creatureType, duration, color) {
    let border = monsterTargetBorder;
    if (creatureType == TutorialEnums.CreatureType.Player) {
        border = playerTargetBorder
    }
    border.border.color = color;
    border.hideAfter(duration);
  }

  function changeHealth(creatureType, percent) {
    let hud = monsterHUDInfo;
    if (creatureType == TutorialEnums.CreatureType.Player) {
        hud = playerHUDInfo;
    }
    hud.healthPercent = percent;
  }

  function createNumericalEffect(position, value, color) {
      let effect = numericalEffectComponent.createObject(worldmap, {
        x: position.x,
        y: position.y,
        value: value,
        color: color
      });
      effect.start();
  }

  function showGamewindowMessage(position, text, numericalColor) {
    let effect = gameMessageComponent.createObject(worldmap, {
      x: position.x,
      y: position.y,
      text: text,
      color: ColorHelper.createColorFromEightBitRGB(numericalColor)
    });
    effect.start();
  }

  function showTraderAndPlayer() {
    var appearanceInstancesList = []
    worldmap.outfitAppearanceInstance = outfitComponent.createObject(appearanceInstanceRenderer);
    appearanceInstancesList.push(worldmap.outfitAppearanceInstance);
    var counter = objectComponent.createObject(appearanceInstanceRenderer, {
      typeid: 2317, // counter
      position: _counterPosition
    });
    appearanceInstancesList.push(counter);
    appearanceInstancesList.push(objectComponent.createObject(appearanceInstanceRenderer, {
      typeid: 34342, // scales
      position: _counterPosition,
      currentElevation: 6
    }));
    appearanceInstancesList.push(npcComponentTrader.createObject(appearanceInstanceRenderer));
    appearanceInstanceRenderer.appearanceInstances = appearanceInstancesList;

    npcHUD.creatureHUDInfo = amandaHUDInfo;
  }

  function showBankerAndPlayer() {
    var appearanceInstancesList = []
    worldmap.outfitAppearanceInstance = outfitComponent.createObject(appearanceInstanceRenderer);
    appearanceInstancesList.push(worldmap.outfitAppearanceInstance);
    var counter = objectComponent.createObject(appearanceInstanceRenderer, {
      typeid: 2317, // counter
      position: _counterPosition
    });
    appearanceInstancesList.push(counter);
    appearanceInstancesList.push(objectComponent.createObject(appearanceInstanceRenderer, {
      typeid: 27446, // gold dust
      position: _counterPosition,
      currentElevation: 6
    }));
    appearanceInstancesList.push(npcComponentBanker.createObject(appearanceInstanceRenderer));
    appearanceInstanceRenderer.appearanceInstances = appearanceInstancesList;

    npcHUD.creatureHUDInfo = fritzHUDInfo;
  }

  Component.onCompleted: {
  }

  Rectangle {
    id: monsterTargetBorder

    function hideAfter(duration) {
      visible = true;
      hideAfterPauseAnimation.duration = duration;
      hideAfterPauseAnimation.start();
    }
    visible: false
    x: _npcPosition.x
    y: _npcPosition.y
    width: 32
    height: 32
    color: "transparent"
    border.color: "red"
    border.width: 2
    PauseAnimation {
      id: hideAfterPauseAnimation
      duration: 0
      onFinished: () => {
        monsterTargetBorder.visible = false;
      }
    }
  }

  AppearanceInstanceRenderer {
    id: appearanceInstanceRenderer

    Timer {
      id: refreshTimer
      interval: 10
      repeat: true
      running: true
      onTriggered: () =>  {
        appearanceInstanceRenderer.update();
      }
    }

    anchors.fill: parent
    scaleFactor: 1.0
    smoothTextureFiltering: false
    clip: true
    animated: worldmap.animated
    appearanceInstances: []
    Item {
      id: npcBaseplate
      x: _npcPosition.x
      y: _npcPosition.y
      width: 32
      height: 32
      TibiaTutorialMarker {
        id: npcTutorialMarker
        anchors.fill: parent
        markerID: TutorialHelper.nextUniqueTutorialMarkerID()
      } //TibiaTutorialMarker
    }

  }

  CreatureHUD {
    id: playerHUD
    x: _playerPosition.x - baseplateOffset
    y: _playerPosition.y - baseplateOffset + 8
    Component.onCompleted: {
      creatureHUDInfo = playerHUDInfo;
    }
  }

  CreatureHUD {
    id: npcHUD
    x: _npcPosition.x - baseplateOffset
    y: _npcPosition.y
  }
}
