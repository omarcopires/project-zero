import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import qmlcomponents

Item {
  id: creatureHUDItem

  //creature hud has a fix size optimal for unscaled worldmap
  width: TibiaStyle.mapWindowPixelPerField
  height: TibiaStyle.mapWindowPixelPerField

  property alias creatureName: creatureName.text
  property real healthPercent: 0.8
  property real manaPercent: 0.6
  property color healthColor: "#ffffff"
  property real scaleFactor: 1.0
  property real lightness: 1.0

  property alias showCreatureName: creatureName.visible
  property bool showHealthBar: false
  property bool showManaBar: false
  property bool showManaShieldBar: false
  property real manaShieldPercent: 0.0
  property bool showBars: false
  property bool showArcs: false
  property real arcBarsOpacity: 0.5
  property real horizontalArcDistancePercent: 1.0
  property real arcBarsHeightPercentage: 1.0
  property int  arcBaseWidth: 10

  property bool isFiendishMonster: false
  property bool isLeaderMonster: false
  property bool isLeaderMinionMonster: false

  property var playerStates: []
  property bool showSpecialConditions: false

  property variant horizontalCreatureIconsDataModel
  property variant verticalCreatureIconsDataModel
  property variant creatureOtherIconsModel

  property bool showCombopointsAndSerene: false
  property bool showCombopointsAndSereneLeft: true
  property int comboPoints: 0
  property bool isSerene: false

  property var creatureHUDInfo: null

  readonly property int barWidth: comboPointBarWidth + 4*(comboPointBarWidth-1) // was 27 classic
  readonly property int comboPointBarWidth: 7
  readonly property int sereneBarWidth: 11
  readonly property int barHeight: 4

  onCreatureHUDInfoChanged: {
    if (creatureHUDInfo != null) {
      creatureName.text = Qt.binding(function() { return creatureHUDInfo.name; });
      showCreatureName = Qt.binding(function() { return creatureHUDInfo.showCreatureName; });
      healthPercent = Qt.binding(function() { return creatureHUDInfo.healthPercent; });
      manaPercent = Qt.binding(function() { return creatureHUDInfo.manaPercent; });
      manaShieldPercent = Qt.binding(function() { return creatureHUDInfo.manaShieldPercent; });
      showHealthBar = Qt.binding(function() { return creatureHUDInfo.showHealthBar; });
      showManaBar = Qt.binding(function() { return creatureHUDInfo.showManaBar; });
      showManaShieldBar = Qt.binding(function() { return creatureHUDInfo.showManaShieldBar; });
      healthColor = Qt.binding(function() { return creatureHUDInfo.healthColor; });
      lightness = Qt.binding(function() { return creatureHUDInfo.lightness; });
      horizontalCreatureIconsDataModel = Qt.binding(function() { return creatureHUDInfo.horizontalCreatureIcons; });
      verticalCreatureIconsDataModel = Qt.binding(function() { return creatureHUDInfo.verticalCreatureIcons; });
      creatureOtherIconsModel = Qt.binding(function() { return creatureHUDInfo.creatureOtherIcons; });
      scaleFactor = Qt.binding(function() { return creatureHUDInfo.scaleFactor; });
      showBars = Qt.binding(function() { return creatureHUDInfo.showBars; });
      showArcs = Qt.binding(function() { return creatureHUDInfo.showArcs; });
      isFiendishMonster = Qt.binding(function() { return creatureHUDInfo.isFiendishMonster; });
      isLeaderMonster = Qt.binding(function() { return creatureHUDInfo.isLeaderMonster; });
      isLeaderMinionMonster = Qt.binding(function() { return creatureHUDInfo.isLeaderMinionMonster; });

      arcBarsOpacity = Qt.binding(function() { return creatureHUDInfo.arcOpacity; });
      horizontalArcDistancePercent = Qt.binding(function() { return creatureHUDInfo.arcDistance; });
      arcBarsHeightPercentage = Qt.binding(function() { return creatureHUDInfo.arcHeight; });
      arcBaseWidth = Qt.binding(function() { return creatureHUDInfo.arcWidth; });
      showCombopointsAndSerene = Qt.binding(function() { return creatureHUDInfo.showCombopointsAndSerene; });
      showCombopointsAndSereneLeft = Qt.binding(function() {return creatureHUDInfo.showCombopointsAndSereneLeft;});
      comboPoints = Qt.binding(function() { return creatureHUDInfo.comboPoints; });
      isSerene = Qt.binding(function() { return creatureHUDInfo.isSerene; });
      playerStates = Qt.binding(function() { return creatureHUDInfo.playerStates; });
      showSpecialConditions = Qt.binding(function() { return creatureHUDInfo.showSpecialConditions; });
    }
  } //onCreatureHUDInfoChanged

  Component {
    id: progressbarComponent
    SlimProgressbar {
      width: creatureHUDItem.barWidth
      height: creatureHUDItem.barHeight
    } //SlimProgressbar
  } //Component


  Component {
    id: combopointsComponent

    RowLayout {
      readonly property color activeColor: TibiaStyle.orange1
      readonly property color inactiveColor: TibiaStyle.grey4
      property int comboPoints: 0

      component ComboPoint: Rectangle {
        border.color: "black"
        border.width: 1
        property bool active: false
        color: active ? activeColor : inactiveColor
      } //component ComboPoint

      spacing: 0

      ComboPoint {
        Layout.preferredWidth: creatureHUDItem.comboPointBarWidth
        Layout.preferredHeight: creatureHUDItem.barHeight
        active: comboPoints > 0
      } //ComboPoint

      ComboPoint {
        Layout.preferredWidth: creatureHUDItem.comboPointBarWidth
        Layout.preferredHeight: creatureHUDItem.barHeight
        Layout.leftMargin: -1 //overlap boarders
        active: comboPoints > 1
      } //ComboPoint

      ComboPoint {
        Layout.preferredWidth: comboPointBarWidth
        Layout.preferredHeight: creatureHUDItem.barHeight
        Layout.leftMargin: -1 //overlap boarders
        active: comboPoints > 2
      } //ComboPoint

      ComboPoint {
        Layout.preferredWidth: comboPointBarWidth
        Layout.preferredHeight: creatureHUDItem.barHeight
        Layout.leftMargin: -1 //overlap boarders
        active: comboPoints > 3
      } //ComboPoint

      ComboPoint {
        Layout.preferredWidth: comboPointBarWidth
        Layout.preferredHeight: creatureHUDItem.barHeight
        Layout.leftMargin: -1 //overlap boarders
        active: comboPoints > 4
      } //ComboPoint

    } // RowLayout
  } // Component

  Component {
    id: sereneComponent

    SlimProgressbar {
      id: sereneBar

      property alias sereneBarColor: sereneBar.progressbarColor
      property alias sereneBarPercent: sereneBar.progressbarPercent

      width: sereneBarWidth
      height: creatureHUDItem.barHeight
    } //SlimProgressbar

  } // Component

  Component {
    id: manaShieldBarComponent

    Rectangle {
      height: 1
      width: creatureHUDItem.barWidth
      color: "black"

      Rectangle {
        anchors { left: parent.left; right: parent.right; leftMargin: 1; rightMargin: 1; }
        height: 1
        color: TibiaStyle.purple2
      } // Rectangle
    } // Rectangle
  } // Component

  property int mapWindowMinHeight: TibiaStyle.mapWindowUnscaledHeight / 2
  property int mapWindowMinWidth: mapWindowMinHeight * TibiaStyle.mapWindowWidthInFields / TibiaStyle.mapWindowHeightInFields
  property int upperMargins: 1
  property int worldmapWidth: parent != null ? Math.max(parent.width, mapWindowMinWidth) : 100000
  property int worldmapHeight: parent != null ? Math.max(parent.height, mapWindowMinHeight) : 100000

  property point anchorPoint: Qt.point(0.5*width, 0)


  onYChanged: {
    clipYToWorldmap(creatureName);
    clipYToWorldmap(symbols);
    clipYToWorldmap(hitpointsManaArcs)
  } //onYChanged

  onXChanged: {
    clipXToWorldmap(creatureName);
    clipXToWorldmap(bars);
    clipXToWorldmap(symbols);
    clipXToWorldmap(hitpointsManaArcs)
  } //onXChanged

  onArcBarsHeightPercentageChanged: {
    if (showArcs || showSpecialConditions) {
      clipXToWorldmap(hitpointsManaArcs)
    }
  }

  function clipXToWorldmap(itemToClip) {
    //reset position
    let newItemToClipX = anchorPoint.x + itemToClip.xOffset;

    //manipulate position if out of bound
    if((creatureHUDItem.x + newItemToClipX) < 0) {
      //out of bound to the left
      itemToClip.x = -creatureHUDItem.x
    } else if((creatureHUDItem.x + newItemToClipX + itemToClip.width) > worldmapWidth) {
      //out of bound to the right
      itemToClip.x = -(itemToClip.width -(worldmapWidth-creatureHUDItem.x))
    } else if (itemToClip.x != newItemToClipX) {
      itemToClip.x = newItemToClipX;
    }
  } //function clipXToWorldmap(itemToClip)

  function clipYToWorldmap(itemToClip) {
    let newItemToClipY = anchorPoint.y + itemToClip.yOffset;
    //manipulate position if out of bound
    if ((creatureHUDItem.y + newItemToClipY) < 0) {
      // out of bounds to the top
      itemToClip.y = -creatureHUDItem.y;
    } else if((creatureHUDItem.y + newItemToClipY + itemToClip.height) > worldmapHeight) {
      //out of bound to the bottom
      itemToClip.y = -(itemToClip.height -(worldmapHeight-creatureHUDItem.y))
    } else if (itemToClip.y != newItemToClipY) {
      itemToClip.y = newItemToClipY;
    }
  } //function clipYToWorldmap(itemToClip)


  TibiaCachedOutlineTextBase {
    id: creatureName
    cacheMode: lightness == 1.0 ? CachedOutlineText.ReleaseImmediately : CachedOutlineText.NoCaching
    font: TibiaStyle.creatureHUDFont
    color: healthColor
    x: anchorPoint.x + xOffset
    y: anchorPoint.y + yOffset
    property int xOffset: - 0.5*width
    property int yOffset: - height - bars.height - upperMargins

    onXOffsetChanged: creatureHUDItem.clipXToWorldmap(this)
    onYOffsetChanged: creatureHUDItem.clipYToWorldmap(this)
  } // TibiaCachedOutlineTextBase

  readonly property QtObject glowStyle: isFiendishMonster ? TibiaStyle.fiendishMonsterGlow
    : isLeaderMonster ? TibiaStyle.leaderMonsterGlow
                      : TibiaStyle.leaderMinionMonsterGlow

  Loader {
    x: creatureName.x
    y: creatureName.y
    width: creatureName.width
    height: creatureName.height

    active: isFiendishMonster || isLeaderMonster || isLeaderMinionMonster

    Component {
      id: glowComponent

      Glow {
        cached: true
        source: creatureName
        radius: glowStyle.radius
        samples: glowStyle.samples
        spread: glowStyle.spread
        color: glowStyle.color
      } // Glow
    } // Component

    sourceComponent: glowComponent
  } // Loader

  Item {
    id: bars
    x: anchorPoint.x + xOffset
    y: creatureName.y + yOffset

    width: creatureHUDItem.barWidth
    height: (healthProgressbar.visible ? creatureHUDItem.barHeight : 0) +
            (manaShieldProgressbar.visible ? 1 : 0) +
            (manaProgressbar.visible ? creatureHUDItem.barHeight : 0) +
            (manaShieldProgressbar.visible ? 0 : upperMargins) +
            (comboPointsBars.visible ? creatureHUDItem.barHeight : 0) +
            (sereneStateBar.visible ? creatureHUDItem: 0)

    property int xOffset: - 0.5*width
    property int yOffset: creatureName.height + upperMargins

    onXOffsetChanged: creatureHUDItem.clipXToWorldmap(this)

    Loader {
      id: healthProgressbar
      sourceComponent: showHealthBar && showBars ? progressbarComponent : undefined
      asynchronous: true
      visible: status == Loader.Ready
      onLoaded: {
        item.progressbarPercent = Qt.binding(function() { return healthPercent });
        item.progressbarColor = Qt.binding(function() { return healthColor })
      } //onLoaded
    } //Loader

    Loader {
      id: manaShieldProgressbar
      width: Math.max(manaShieldPercent <= 0 ? 0 : 3, Math.round(creatureHUDItem.barWidth * manaShieldPercent))
      y: healthProgressbar.visible ? creatureHUDItem.barHeight : 0
      sourceComponent: showManaShieldBar && showManaBar && showBars ? manaShieldBarComponent : undefined
      asynchronous: true
      visible: status == Loader.Ready
    } // Loader

    Loader {
      id: manaProgressbar
      y: (healthProgressbar.visible ? creatureHUDItem.barHeight : 0) +
         (manaShieldProgressbar.visible ? 1 : 0)
      sourceComponent: showManaBar && showBars ? progressbarComponent : undefined
      asynchronous: true
      visible: status == Loader.Ready
      onLoaded: {
        item.progressbarPercent = Qt.binding(function() { return manaPercent });
        item.progressbarColor = "blue"
      } //onLoaded
    } //Loader

    Loader {
      id: comboPointsBars

      y: (healthProgressbar.visible ? creatureHUDItem.barHeight : 0) +
         (manaShieldProgressbar.visible ? 1 : 0) +
         (manaProgressbar.visible ? creatureHUDItem.barHeight : 0)

      sourceComponent: showCombopointsAndSerene && showBars ? combopointsComponent : undefined
      asynchronous: true
      visible: status == Loader.Ready
      onLoaded: {
        item.comboPoints = Qt.binding(function() { return comboPoints; });
      } // onLoaded
    } // Loader

    Loader {
      id: sereneStateBar

      y: (healthProgressbar.visible ? creatureHUDItem.barHeight : 0) +
         (manaShieldProgressbar.visible ? 1 : 0) +
         (manaProgressbar.visible ? creatureHUDItem.barHeight : 0) +
         (comboPointsBars.visible ? creatureHUDItem.barHeight : 0)
      anchors.horizontalCenter: parent.horizontalCenter
      sourceComponent: showCombopointsAndSerene && showBars ? sereneComponent : undefined
      asynchronous: true
      visible: status == Loader.Ready
      onLoaded: {
        item.sereneBarColor = Qt.binding(function() { return creatureHUDItem.isSerene ? TibiaStyle.purple2 : TibiaStyle.grey4 });
        item.sereneBarPercent = Qt.binding(function() { return creatureHUDItem.isSerene ? 1.0 : 1.0 });
      } // onLoaded
    } // Loader


  } //ColumnLayout

  Column {
    spacing: 2
    Column {
      id: symbols

      y: anchorPoint.y + yOffset
      x: anchorPoint.x + xOffset
      property int xOffset: + 16 - 0.5*width
      property int yOffset: upperMargins //margin to bars

      onXOffsetChanged: creatureHUDItem.clipXToWorldmap(this)
      onYOffsetChanged: creatureHUDItem.clipYToWorldmap(this)

      spacing: 2
      Row {
        spacing: 2
        Repeater {
          model: horizontalCreatureIconsDataModel
          Image {
            source: modelData
            smooth: false
          } //Image
        } //Repeater
      } //Row
      Column {
        id: verticalIconsColumn
        spacing: 2
        anchors.horizontalCenter: parent.horizontalCenter
        Repeater {
          model: verticalCreatureIconsDataModel
          RowLayout {
            id: verticalRow
            Image {
              id: verticalItemImage
              source: modelData
              smooth: false
            }
          }
        } //Repeater
      } //Column
    } //Column

    Column {
      spacing: 2
      anchors.left : symbols.left
      anchors.leftMargin: (horizontalCreatureIconsDataModel != null && verticalCreatureIconsDataModel != null && horizontalCreatureIconsDataModel.length > 1 && verticalCreatureIconsDataModel.length > 0) ? (symbols.width/2 - verticalIconsColumn.width/2) : 0
      Repeater {

        model: creatureOtherIconsModel
        delegate: RowLayout {
          spacing: 2
          Layout.fillWidth: true
          Image {
            source: model.image
            smooth: false
          } //Image
          TibiaText {
            id: myText
            text: model.value
            style: Text.Outline
            visible: model.showValue
          } //TibiaText
        } // RowLayout
      } // Repeater
    } //Column
  } //Column

  Loader {
    id: hitpointsManaArcs
    readonly property int verticalOffset: Math.ceil(10 * scaleFactor)

    x: anchorPoint.x + xOffset
    y: anchorPoint.y + yOffset
    property int xOffset: - 0.5 * (item != null ? item.width : 0)
    property int yOffset: - 0.5 * (item != null ? item.height : 0) + verticalOffset

    onXOffsetChanged: creatureHUDItem.clipXToWorldmap(this)
    onYOffsetChanged: creatureHUDItem.clipYToWorldmap(this)
    z: -1 //beneath the name
    source: (showArcs || showSpecialConditions) ? "HitpointsManaArcHud.qml" : ""
    asynchronous: false
    visible: status == Loader.Ready
    onLoaded: {
      item.fillRateHitpoints = Qt.binding(function() { return healthPercent });
      item.hitpointsBaseColor = Qt.binding(function() { return healthColor });
      item.hitpointsHudVisible = Qt.binding(function() { return showHealthBar });
      item.fillRateMana = Qt.binding(function() { return manaPercent });
      item.manaBaseColor = "blue";
      item.manaHudVisible = Qt.binding(function() { return showManaBar });
      item.fillRateManaShield = Qt.binding(function() { return manaShieldPercent; });
      item.manaShieldBaseColor = TibiaStyle.purple1
      item.manaShieldVisible = Qt.binding(function() { return showManaShieldBar; });
      item.showCombopointsAndSerene = Qt.binding(function() { return showCombopointsAndSerene; });
      item.showCombopointsAndSereneOnLeft = Qt.binding(function() {return showCombopointsAndSereneLeft;});
      item.comboPoints = Qt.binding(function() { return comboPoints; });
      item.isSerene = Qt.binding(function() { return creatureHUDItem.isSerene; });
      item.opacity = Qt.binding(function() { return arcBarsOpacity; });
      item.scaleFactor = Qt.binding(function() { return scaleFactor; });
      item.arcBaseWidth = Qt.binding(function() { return arcBaseWidth; });
      item.horizontalArcDistancePercent = Qt.binding(function() { return horizontalArcDistancePercent; });
      item.height = Qt.binding(function() {
        return Math.max(60, Math.ceil(arcBarsHeightPercentage * scaleFactor * TibiaStyle.mapWindowUnscaledHeight));
      } );
      item.playerStates = Qt.binding(function() { return playerStates; });
      item.showSpecialConditions = Qt.binding(function() { return showSpecialConditions; });
      item.showArcs = Qt.binding(function() { return showArcs; });
    } //onLoaded
  } //Loader
} //Item
