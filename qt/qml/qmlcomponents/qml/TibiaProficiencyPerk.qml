import QtQuick
import QtQuick.Effects

import qmlcomponents
import qmlenumvalues


Item {
  id: perkComponent

  required property url imageSource
  required property bool hasAugmentEffect
  required property url augmentEffectImageSource
  required property bool isShaped
  required property int perkRank
  property bool hasHighlight: false
  property bool isActive: true
  property bool isSelected: false
  property bool showLockIcon: false
  property bool isInteractive: false
  property string perkName: ""
  property string perkDescription: ""

  signal perkPressed()

  readonly property int scaleFactor: TibiaStyle.proficiencyPerkScaleFactor

  implicitWidth: TibiaStyle.proficiencyPerkSize * scaleFactor
  implicitHeight: implicitWidth

  Image {
    id: highlightAnimation
    anchors.centerIn: parent
    visible: perkComponent.hasHighlight
    width: sourceSize.width * perkComponent.scaleFactor
    height: sourceSize.height * perkComponent.scaleFactor
    source: baseSource + "0"
    smooth: false

    readonly property string baseSource: perkComponent.isShaped
      ? "image://backdrop-weaponmastery-shaped-highlight/"
      : "image://backdrop-weaponmastery-highlight/"

    SequentialAnimation {
      id: highlightSeqAnimation
      running: perkComponent.hasHighlight
      loops: Animation.Infinite
      alwaysRunToEnd: false

      // The animation already starts at zero, so it should continue with 1 and then restart with 0 at the end
      PropertyAnimation { target: highlightAnimation; property: "source"; to: highlightAnimation.baseSource + "1"; duration: 150 }
      PropertyAnimation { target: highlightAnimation; property: "source"; to: highlightAnimation.baseSource + "2"; duration: 150 }
      PropertyAnimation { target: highlightAnimation; property: "source"; to: highlightAnimation.baseSource + "3"; duration: 150 }
      PropertyAnimation { target: highlightAnimation; property: "source"; to: highlightAnimation.baseSource + "4"; duration: 150 }
      PropertyAnimation { target: highlightAnimation; property: "source"; to: highlightAnimation.baseSource + "5"; duration: 150 }
      PropertyAnimation { target: highlightAnimation; property: "source"; to: highlightAnimation.baseSource + "6"; duration: 150 }
      PropertyAnimation { target: highlightAnimation; property: "source"; to: highlightAnimation.baseSource + "7"; duration: 150 }
      PropertyAnimation { target: highlightAnimation; property: "source"; to: highlightAnimation.baseSource + "8"; duration: 150 }
      PropertyAnimation { target: highlightAnimation; property: "source"; to: highlightAnimation.baseSource + "9"; duration: 150 }
      PropertyAnimation { target: highlightAnimation; property: "source"; to: highlightAnimation.baseSource + "10"; duration: 150 }
      PropertyAnimation { target: highlightAnimation; property: "source"; to: highlightAnimation.baseSource + "11"; duration: 150 }
      PropertyAnimation { target: highlightAnimation; property: "source"; to: highlightAnimation.baseSource + "12"; duration: 150 }
      PropertyAnimation { target: highlightAnimation; property: "source"; to: highlightAnimation.baseSource + "13"; duration: 150 }
      PropertyAnimation { target: highlightAnimation; property: "source"; to: highlightAnimation.baseSource + "14"; duration: 150 }
      PropertyAnimation { target: highlightAnimation; property: "source"; to: highlightAnimation.baseSource + "15"; duration: 150 }
      PropertyAnimation { target: highlightAnimation; property: "source"; to: highlightAnimation.baseSource + "16"; duration: 150 }
      PropertyAnimation { target: highlightAnimation; property: "source"; to: highlightAnimation.baseSource + "17"; duration: 150 }
      PropertyAnimation { target: highlightAnimation; property: "source"; to: highlightAnimation.baseSource + "18"; duration: 150 }
      PropertyAnimation { target: highlightAnimation; property: "source"; to: highlightAnimation.baseSource + "19"; duration: 150 }
      PropertyAnimation { target: highlightAnimation; property: "source"; to: highlightAnimation.baseSource + "20"; duration: 150 }
      PropertyAnimation { target: highlightAnimation; property: "source"; to: highlightAnimation.baseSource + "21"; duration: 150 }
      PropertyAnimation { target: highlightAnimation; property: "source"; to: highlightAnimation.baseSource + "22"; duration: 150 }
      PropertyAnimation { target: highlightAnimation; property: "source"; to: highlightAnimation.baseSource + "23"; duration: 150 }
      PropertyAnimation { target: highlightAnimation; property: "source"; to: highlightAnimation.baseSource + "24"; duration: 150 }
      PropertyAnimation { target: highlightAnimation; property: "source"; to: highlightAnimation.baseSource + "25"; duration: 150 }
      PropertyAnimation { target: highlightAnimation; property: "source"; to: highlightAnimation.baseSource + "26"; duration: 150 }
      PropertyAnimation { target: highlightAnimation; property: "source"; to: highlightAnimation.baseSource + "0"; duration: 150 }
    } //SequentialAnimation
  } // Image

  Image {
    // The perk graphic
    id: perkImage
    anchors.centerIn: parent
    source: perkComponent.imageSource
    width: sourceSize.width * perkComponent.scaleFactor
    height: sourceSize.height * perkComponent.scaleFactor
    smooth: false
    visible: false
  } // Image

  MultiEffect {
    id: shaderPerkImage
    source: perkImage
    width: perkImage.width
    height: perkImage.height
    anchors.centerIn: parent
    saturation: !perkComponent.isActive ? -1.0 : 0.0

    Tooltip {
      anchors.fill: parent
      delayInMs: 0
      enabled: perkComponent.isInteractive
      text: "%1\n\n%2".arg(perkComponent.perkName).arg(perkComponent.perkDescription)

      onMouseButtonPressed: {
        perkComponent.perkPressed()
      } //onMouseButtonPressed
      onHoverEnter: {
        if (tibiaMouseCursorController != null) {
          tibiaMouseCursorController.setPointingHand(true)
          if (!perkComponent.isActive) {
            shaderPerkImage.saturation = -0.5
          }
        }
      } //onEntered

      onHoverLeave: {
        if (tibiaMouseCursorController != null) {
          tibiaMouseCursorController.setDefaultCursor()
          shaderPerkImage.saturation = Qt.binding(
            () => { return !perkComponent.isActive ? -1.0 : 0.0 }
          )
        }
      } //onExited
    } // Tooltip
  } // MultiEffect

  Image {
    id: borderImage
    // The active/inactive perk border
    anchors.centerIn: parent
    source: perkComponent.isActive
      ? "/images/proficiency/border-weaponmasterytreeicons-active.png"
      : "/images/proficiency/border-weaponmasterytreeicons-inactive.png"
    width: sourceSize.width * perkComponent.scaleFactor
    height: sourceSize.height * perkComponent.scaleFactor
    smooth: false

    TibiaClampSelection {
      marginToParent: 4
      visible: perkComponent.isSelected
    } //TibiaClampSelection
  } //Image

  Image {
    id: augmentEffectTypeImage
    anchors.horizontalCenter: shaderPerkImage.right
    anchors.verticalCenter: shaderPerkImage.top
    source: perkComponent.hasAugmentEffect ? perkComponent.augmentEffectImageSource : ""
    width: sourceSize.width * perkComponent.scaleFactor
    height: sourceSize.height * perkComponent.scaleFactor
    smooth: false
    visible: false
  } //Image

  MultiEffect {
    source: augmentEffectTypeImage
    width: augmentEffectTypeImage.width
    height: augmentEffectTypeImage.height
    anchors { horizontalCenter: shaderPerkImage.right;
              verticalCenter: shaderPerkImage.top; }
    saturation: shaderPerkImage.saturation
  } //MultiEffect

  Image {
    anchors { horizontalCenter: shaderPerkImage.horizontalCenter;
              verticalCenter: shaderPerkImage.bottom }
    source: perkComponent.showLockIcon ? "/images/icon-lock-grey.png" : ""
    width: sourceSize.width * perkComponent.scaleFactor
    height: sourceSize.height * perkComponent.scaleFactor
    smooth: false
  } //Image

  Image {
    anchors.horizontalCenter: shaderPerkImage.left
    anchors.verticalCenter: shaderPerkImage.bottom

    source: perkComponent.isActive
      ? "/images/proficiency/backdrop_manipulation_rank.png"
      : "/images/proficiency/backdrop_manipulation_rank_disabled.png"
    width: sourceSize.width * perkComponent.scaleFactor
    height: sourceSize.height * perkComponent.scaleFactor
    smooth: false

    visible: perkComponent.isShaped

    TibiaText {
      anchors.centerIn: parent
      text: perkComponent.perkRank
    } //TibiaText
  } //Image
} //Item
