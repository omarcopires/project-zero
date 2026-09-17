import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import qmlcomponents


Item {
  property int   entryID
  property alias creatureName: creatureNameText.text
  property alias creatureOutfitId: outfitAppearanceInstanceRenderer.outfitId
  property alias creatureOutfitIsObject: outfitAppearanceInstanceRenderer.outfitIsObject
  property alias creatureHeadColor: outfitAppearanceInstanceRenderer.headColor
  property alias creatureTorsoColor: outfitAppearanceInstanceRenderer.torsoColor
  property alias creatureLegsColor: outfitAppearanceInstanceRenderer.legsColor
  property alias creatureDetailColor: outfitAppearanceInstanceRenderer.detailColor
  property alias creatureFirstAddOn: outfitAppearanceInstanceRenderer.firstAddOn
  property alias creatureSecondAddOn: outfitAppearanceInstanceRenderer.secondAddOn
  property bool  isTemporarySelected: false
  property real  healthProgressbarPercent
  property color healthProgressbarColor: "green"
  property real  manaProgressbarPercent
  property color manaProgressbarColor: "blue"
  property bool  showMana: false
  property bool  isInViewport: false
  property bool  isInSharedXPDistance: false
  property bool  isPartyViewActive: false
  property bool  isFiendishMonster: false
  property bool  isLeaderMonster: false
  property bool  isLeaderMinionMonster: false

  property var    frameColorsOuterToInner
  property var    statusIcons
  property alias  isElided: creatureNameText.truncated
  property int    tutorialMarkerID: 0;

  property color  _creatureNameColor: isTemporarySelected ? "#F7F7F7" : (isInViewport ? "#C0C0C0" : "#808080")

  onTutorialMarkerIDChanged: {
    tutorialMarkerLoader.sourceComponent = tutorialMarkerID != 0 ? tutorialMarkerComponent : null
  } //onAcceptsDropChanged

  Tooltip {
    anchors.fill: parent
    text: creatureName
    enabled: creatureNameText.truncated
  } //Tooltip

  Component {
    id: tutorialMarkerComponent
    TibiaTutorialMarker {
      anchors.fill: parent
    } //TibiaTutorialMarker
  } //Component

  readonly property QtObject glowStyle: isFiendishMonster ? TibiaStyle.fiendishMonsterGlow
    : isLeaderMonster ? TibiaStyle.leaderMonsterGlow
                      : TibiaStyle.leaderMinionMonsterGlow

  Loader {
    x: creatureNameText.x
    y: creatureNameText.y
    width: creatureNameText.width
    height: creatureNameText.width

    active: isFiendishMonster || isLeaderMonster || isLeaderMinionMonster

    Component {
      id: glowComponent

      Glow {
        cached: true
        source: creatureNameText
        radius: glowStyle.radius
        samples: glowStyle.samples
        spread: glowStyle.spread
        color: glowStyle.color
      }
    }

    sourceComponent: glowComponent
  }

  GridLayout {
    anchors.fill: parent

    columns: 3
    rows: 3
    columnSpacing: 2
    rowSpacing: 0
    flow: GridLayout.TopToBottom

    Item {
      id: iconWrapper
      Layout.column: 0
      Layout.row: 0
      Layout.columnSpan: 1
      Layout.rowSpan: 2
      height: TibiaStyle.battleListMonsterSize + 2 //monsters are shown with 1 pixel offset
      width: TibiaStyle.battleListMonsterSize + 2

      OutfitAppearanceInstanceRenderer {
        id: outfitAppearanceInstanceRenderer
        anchors.fill: parent
        anchors.margins: 1
        shrinkToFit: true
        animated: false
        showInvisibleOutfit: true
      } //OutfitAppearanceInstanceRenderer

      Repeater {
        model: frameColorsOuterToInner
        Rectangle {
          anchors.fill: parent
          anchors.margins: index
          border.width: 1
          border.color: modelData
          color: "transparent"
        } //Rectangle
      } //Repeater
    } //Item

    TibiaText {
      id: creatureNameText
      Layout.column: 1
      Layout.row: 0
      styleType: "Dialog"
      style: isFiendishMonster ? Text.Outline : Text.Normal
      elide: Text.ElideRight
      color: _creatureNameColor
      Layout.fillWidth: true
    } // TibiaText



    Row {
      Layout.column: 2
      Layout.row: 0
      spacing: 2
      Repeater {
        model: statusIcons
        Image {
          source: modelData
          smooth: false
        } //Image
      } //Repeater
    } //Row

    SlimProgressbar {
      Layout.preferredHeight: TibiaStyle.progressBarSlimHeight
      Layout.fillWidth: true
      Layout.column: 1
      Layout.row: 1
      Layout.columnSpan: 2
      progressbarPercent: (isInSharedXPDistance || !isPartyViewActive) ? healthProgressbarPercent : 1.0
      progressbarColor: (isInSharedXPDistance || !isPartyViewActive) ? healthProgressbarColor : TibiaStyle.grey3
      progressbarBackgroundColor: "transparent"
    } //SlimProgressbar

    Loader {
      Layout.fillWidth: true
      Layout.column: 1
      Layout.row: 2
      Layout.columnSpan: 2
      Layout.topMargin: 1
      Layout.preferredHeight: TibiaStyle.progressBarSlimHeight
      Component {
        id: manaProgressbarComponent
        SlimProgressbar {
          progressbarPercent: (isInSharedXPDistance || !isPartyViewActive) ? manaProgressbarPercent : 1.0
          progressbarColor: (isInSharedXPDistance || !isPartyViewActive) ?  manaProgressbarColor : TibiaStyle.grey3
          progressbarBackgroundColor: "transparent"
        } //SlimProgressbar
      }
      sourceComponent: showMana ? manaProgressbarComponent : undefined
      //sourceComponent: manaProgressbarComponent
    } //Loader
  } //GridLayout

  Loader {
    id: tutorialMarkerLoader
    anchors.fill: parent
    onLoaded: {
      item.markerID = Qt.binding(function() { return tutorialMarkerID });
    } //onLoaded
    z: 999
  } //Loader

} //Item
