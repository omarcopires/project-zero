import QtQuick

import qmlcomponents
import "qrc:/qt/qml/qmlcomponents/qml/"

Item {
  id: worldmap
  readonly property var appearanceInstanceRenderer: appearanceInstanceRenderer
  readonly property var monsterPosition: _monsterPosition
  readonly property int monsterTutorialMarkerID: monsterTutorialMarker.markerID
  property alias monsterHUDVisible: monsterHUDInfo.visible

  property int worldmapFieldsX: 3
  property int worldmapFieldsY: 4
  property int baseplateOffset: 8

  property bool animated: true
  property var outfitAppearanceInstance: null

  readonly property var _playerPosition: Qt.point(32, 64 + 16)
  readonly property var _monsterPosition: Qt.point(32, 32)

  implicitWidth: 32 * worldmapFieldsX
  implicitHeight: 32 * worldmapFieldsY

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
    id: monsterComponent
    OutfitAppearanceInstance {
      typeid: 529
      position: _monsterPosition
    }
  }

  Component {
    id: monsterCorpseComponent
    ObjectAppearanceInstance {
      typeid: 17427
      position: _monsterPosition
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
    property bool showBars: true
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
    showManaBar: true
  }
  CreatureHUDInfoBase {
    id: monsterHUDInfo
    property bool visible: true
    name: visible ? "Salamander" : ""
    showBars: visible
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

  function changeMana(creatureType, percent) {
    let hud = monsterHUDInfo;
    if (creatureType == TutorialEnums.CreatureType.Player) {
        hud = playerHUDInfo;
    }
    hud.manaPercent = percent;
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

  function showMonsterAndPlayer() {
    var appearanceInstancesList = []
    worldmap.outfitAppearanceInstance = outfitComponent.createObject(appearanceInstanceRenderer);
    appearanceInstancesList.push(worldmap.outfitAppearanceInstance);
    appearanceInstancesList.push(monsterComponent.createObject(appearanceInstanceRenderer));
    appearanceInstanceRenderer.appearanceInstances = appearanceInstancesList;
  }

  function showMonsterCorpseAndPlayer() {
    var appearanceInstancesList = []
    worldmap.outfitAppearanceInstance = outfitComponent.createObject(appearanceInstanceRenderer);
    appearanceInstancesList.push(worldmap.outfitAppearanceInstance);
    appearanceInstancesList.push(monsterCorpseComponent.createObject(appearanceInstanceRenderer));
    appearanceInstanceRenderer.appearanceInstances = appearanceInstancesList;
  }

  Component.onCompleted: {
    showMonsterAndPlayer();
  }

  Rectangle {
    id: monsterTargetBorder

    function hideAfter(duration) {
      visible = true;
      hideAfterPauseAnimation.duration = duration;
      hideAfterPauseAnimation.start();
    }
    visible: false
    x: _monsterPosition.x
    y: _monsterPosition.y
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
      id: monsterBaseplate
      x: _monsterPosition.x
      y: _monsterPosition.y
      width: 32
      height: 32
      TibiaTutorialMarker {
        id: monsterTutorialMarker
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
    id: monsterHUD
    x: _monsterPosition.x - baseplateOffset
    y: _monsterPosition.y - baseplateOffset
    Component.onCompleted: {
      creatureHUDInfo = monsterHUDInfo;
    }
  }
}
