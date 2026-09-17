import QtQuick

import qmlcomponents


AppearanceInstanceRenderer {
  id: outfitRenderer

  property int outfitId: 0
  property bool outfitIsObject: false
  property color headColor: "black"
  property color torsoColor: "black"
  property color legsColor: "black"
  property color detailColor: "black"
  property bool firstAddOn: false
  property bool secondAddOn: false

  property var lookDirection: OutfitAppearanceInstance.SOUTH
  property bool moving: false

  property bool showNoOutfitImage: true
  property bool showInvisibleOutfit: false

  animated: true
  center: true
  smoothTextureFiltering: false

  // Whenever any property of the following list changes, the outfit is recreated.
  onOutfitIdChanged: changeTimer.restart()
  onHeadColorChanged: changeTimer.restart()
  onTorsoColorChanged: changeTimer.restart()
  onLegsColorChanged: changeTimer.restart()
  onDetailColorChanged: changeTimer.restart()
  onFirstAddOnChanged: changeTimer.restart()
  onSecondAddOnChanged: changeTimer.restart()
  onLookDirectionChanged: changeTimer.restart()
  onMovingChanged: changeTimer.restart()
  onOutfitIsObjectChanged: changeTimer.restart()

  Timer {
    id: changeTimer
    interval: 0

    onTriggered: {
      reloadOutfitAppearance()
    }
  } // Timer

  Component {
    id: outfitAppearanceComponent

    OutfitAppearanceInstance {
    }
  } // Component

  Component {
    id: objectAppearanceComponent

    ObjectAppearanceInstance {
    }
  } // Component

  function reloadOutfitAppearance() {
    if (outfitId != 0 || showInvisibleOutfit) {
      if (!outfitIsObject) {
        var createdAppearanceInstance = outfitAppearanceComponent.createObject(outfitRenderer);
        createdAppearanceInstance.typeid = outfitId;
        createdAppearanceInstance.headColor = headColor;
        createdAppearanceInstance.torsoColor = torsoColor;
        createdAppearanceInstance.legsColor = legsColor;
        createdAppearanceInstance.detailColor = detailColor;
        createdAppearanceInstance.firstAddOn = firstAddOn;
        createdAppearanceInstance.secondAddOn = secondAddOn;
        createdAppearanceInstance.lookDirection = lookDirection;
        createdAppearanceInstance.moving = moving
      } else {
        var createdAppearanceInstance = objectAppearanceComponent.createObject(outfitRenderer);
        createdAppearanceInstance.typeid = outfitId;
      }
      appearanceInstances = [createdAppearanceInstance]
    } else {
      appearanceInstances = []
    }
  } // function reloadOutfitAppearance

  Image {
    source: visible ? "/images/unknownoutfit.png" : ""
    visible: outfitRenderer.outfitId == 0 && showNoOutfitImage && !showInvisibleOutfit
    anchors.centerIn: parent
    smooth: false
    Tooltip {
      anchors.fill: parent
      text: qsTrId("characterselection_no_outfit_tooltip")
    } //Tooltip
  } //Image
} // AppearanceInstanceRenderer
