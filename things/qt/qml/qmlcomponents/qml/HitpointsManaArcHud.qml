import QtQuick
import QtQuick.Layouts

import qmlcomponents


Item {
  id: hudRoot

  readonly property real fillColorAlpha: 0.75

  property real fillRateHitpoints: 1.0
  property color hitpointsBaseColor: "green"
  property bool hitpointsHudVisible: true
  property real fillRateMana: 1.0
  property color manaBaseColor: "blue"
  property bool manaHudVisible: true
  property real fillRateManaShield: 1.0
  property color manaShieldBaseColor: TibiaStyle.purple1
  property color comboPointsBaseColor: TibiaStyle.orange1
  property bool manaShieldVisible: true
  property int  arcBaseWidth: 10
  property bool showCombopointsAndSerene: false
  property int comboPoints: 0
  property bool isSerene: false
  property bool showCombopointsAndSereneOnLeft: true

  property real arcWidth: Math.ceil(arcBaseWidth * scaleFactor)
  property real arcBorderWidth: 1.25

  property real scaleFactor: 1.0

  property real horizontalArcDistancePercent: 1.0

  property bool showSpecialConditions: false
  property var playerStates: null
  property bool showArcs: false
  property real hitpointHudSpaceToSpecialBar: 0
  property var _playerStatesHelperModel: null

  onPlayerStatesChanged: {
    if (playerStates) {
      _playerStatesHelperModel = AbstractItemModelHelper.wrapInHelperProxyModel(playerStates);
    } else {
      _playerStatesHelperModel = null;
    }
  }

  onScaleFactorChanged: {
    hitpointsHud.requestPaint();
    manaHud.requestPaint();
  } //onScaleFactorChanged

  onFillRateHitpointsChanged: {
    hitpointsHud.requestPaint();
  } //onFillRateHitpointsChanged

  onHitpointsBaseColorChanged: {
    hitpointsHud.requestPaint();
  } //onHitpointsBaseColorChanged


 onShowCombopointsAndSereneChanged: {
   if (showCombopointsAndSereneOnLeft) {
     hitpointsHud.opacity = hitpointsHudVisible || showCombopointsAndSerene ? 1.0 : 0.0;
     hitpointsHud.requestPaint();
   } else {
     manaHud.requestPaint();
   }
 }

 onComboPointsChanged: {
   if (showCombopointsAndSereneOnLeft) {
     hitpointsHud.requestPaint();
   } else {
     manaHud.requestPaint();
   }
 }

 onIsSereneChanged: {
   if (showCombopointsAndSereneOnLeft) {
     hitpointsHud.requestPaint();
   } else {
     manaHud.requestPaint();
   }
 }

 onShowCombopointsAndSereneOnLeftChanged: {
   if (showCombopointsAndSereneOnLeft) {
     hitpointsHud.opacity = hitpointsHudVisible || showCombopointsAndSerene ? 1.0 : 0.0;
   }
   hitpointsHud.requestPaint();
   manaHud.requestPaint();
 }


  onFillRateManaChanged: {
    manaHud.requestPaint();
  } //onFillRateManaChanged

  onFillRateManaShieldChanged: {
    manaHud.requestPaint();
  } //onFillRateManaChanged

  onManaShieldVisibleChanged: {
    manaHud.requestPaint();
  } // onManaShieldVisibleChanged

  onHitpointsHudVisibleChanged: {
    hitpointsHud.opacity = hitpointsHudVisible || showCombopointsAndSerene ? 1.0 : 0.0
    hitpointsHud.requestPaint();
  }

  onManaHudVisibleChanged: {
    manaHud.opacity = manaHudVisible ? 1.0 : 0.0
  }

  onShowSpecialConditionsChanged: {
    refreshImplicitWidth();
  }

  function refreshImplicitWidth() {
    implicitWidth = hitpointsHudWrapper.width + manaHud.width + arcSpacer.width;
    updateSpecialConditionsBarPosition();
  }

  function updateSpecialConditionsBarPosition() {
    // -- dynamic positioning of hitpointHud and special conditions bar, depending on the width of the HUD

    // global HUD offset, set outside of this component (CreatureHUD.qml), magic number :/
    let xOffset = 8 * scaleFactor;

    // calc the space required for the special conditions bar
    let requiredSpecialConditionsBarSpaceUnscaled = Math.ceil(specialConditionsBar.width + specialConditionsBar.marginToArcScaled / scaleFactor);
    let requiredSpecialConditionsBarSpace = Math.ceil(specialConditionsBar.width * scaleFactor + specialConditionsBar.marginToArcScaled);

    // calc required unscaled values
    let hudLayoutWidthUnscaled = Math.ceil(hudMainLayout.width / scaleFactor);
    let remainingSpaceUnscaled = Math.ceil(Math.max(0, (TibiaStyle.mapWindowUnscaledWidth - hudLayoutWidthUnscaled) / 2 - xOffset));

    // determine if the special conditions bar should maintain position
    let freezeSpecialConditionsBarPosition = remainingSpaceUnscaled <= requiredSpecialConditionsBarSpaceUnscaled;
    // calc the margin space required at the left of the hitpointHud
    let hitpointHudMarginLeft = freezeSpecialConditionsBarPosition ? requiredSpecialConditionsBarSpace : 0;

    // set the space the hitpointHud needs to keep
    hitpointHudSpaceToSpecialBar = freezeSpecialConditionsBarPosition ? hitpointHudMarginLeft - remainingSpaceUnscaled * scaleFactor : 0;

    // set special conditions bar position according to calculated data
    specialConditionsBar.x = freezeSpecialConditionsBarPosition ? Math.ceil(-remainingSpaceUnscaled * scaleFactor) : -requiredSpecialConditionsBarSpace;
  }

  Component.onCompleted: {
    refreshImplicitWidth();
  }

  RowLayout {
    id: hudMainLayout
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    spacing: 0

    visible: hudRoot.showArcs

    RowLayout {
      id: hitpointsHudWrapper
      spacing: 0

      ArcProgressBar {
        id: hitpointsHud
        Layout.fillHeight: true
        // this is set dynamically depending on the total size of the hud, to keep the special conditions bar visible
        Layout.leftMargin: hitpointHudSpaceToSpecialBar
        arcWidth: hudRoot.hitpointsHudVisible && (hudRoot.showCombopointsAndSerene && hudRoot.showCombopointsAndSereneOnLeft)
          ? hudRoot.arcWidth / 2
          : hudRoot.arcWidth
        borderWidth: hudRoot.arcBorderWidth
        borderColor: Qt.rgba(0.0,0.0,0.0,1.0)
        rightArc: false
        showSerene: (hudRoot.showCombopointsAndSerene && hudRoot.showCombopointsAndSereneOnLeft)
        isSerene: hudRoot.isSerene

        readonly property var comboPointsfillRate: comboPoints == 0 ? 0.0 :
                                                  (comboPoints == 1 ? 0.2 :
                                                  (comboPoints == 2 ? 0.4 :
                                                  (comboPoints == 3 ? 0.6 :
                                                  (comboPoints == 4 ? 0.8 : 1.0))))

        readonly property color hitpointsColor: Qt.rgba(hitpointsBaseColor.r, hitpointsBaseColor.g, hitpointsBaseColor.b, hudRoot.fillColorAlpha)
        readonly property color comboPointsColor: Qt.rgba(comboPointsBaseColor.r, comboPointsBaseColor.g, comboPointsBaseColor.b, hudRoot.fillColorAlpha)

        progressBarsFillRates: {
          if (hudRoot.hitpointsHudVisible && hudRoot.showCombopointsAndSerene && hudRoot.showCombopointsAndSereneOnLeft) {
            return [fillRateHitpoints, comboPointsfillRate];
          } else if (hudRoot.hitpointsHudVisible) {
            return [fillRateHitpoints];
          } else if (hudRoot.showCombopointsAndSerene && hudRoot.showCombopointsAndSereneOnLeft) {
            return [comboPointsfillRate]
          }

          return [fillRateHitpoints]
        }

        progressBarsColors:{
          if (hudRoot.hitpointsHudVisible && hudRoot.showCombopointsAndSerene && hudRoot.showCombopointsAndSereneOnLeft) {
            return [hitpointsColor, comboPointsColor];
          } else if (hudRoot.hitpointsHudVisible) {
            return [hitpointsColor];
          } else if (hudRoot.showCombopointsAndSerene && hudRoot.showCombopointsAndSereneOnLeft) {
            return [comboPointsColor]
          }

          return [hitpointsColor]
        }

        progressBarsToDivide:{
          if (hudRoot.hitpointsHudVisible && hudRoot.showCombopointsAndSerene && hudRoot.showCombopointsAndSereneOnLeft) {
            return [2];
          } else if (hudRoot.hitpointsHudVisible) {
            return [];
          } else if (hudRoot.showCombopointsAndSerene && hudRoot.showCombopointsAndSereneOnLeft) {
            return [1]
          }

          return []
        }

        progressBarDivisionFillRates: (hudRoot.showCombopointsAndSerene && hudRoot.showCombopointsAndSereneOnLeft) ? [0.2, 0.4, 0.6, 0.8] : []

        onWidthChanged: refreshImplicitWidth()

      }
    }

    Item {
      id: arcSpacer
      Layout.preferredWidth: Math.ceil((TibiaStyle.mapWindowUnscaledWidth * scaleFactor - hitpointsHudWrapper.width - manaHud.width) * horizontalArcDistancePercent)
      onWidthChanged: refreshImplicitWidth()
    }

    ArcProgressBar { // if a mana shield is shown, we ignore showing combopoints. This should not be a problem, the mana shield can only be seen by druids and sorcerers. It simnplifies the code to ignore this option.
      id: manaHud
      Layout.fillHeight: true
      property bool showManaShield: manaShieldVisible && hudRoot.fillRateManaShield
      property var manaAndShieldFillRates: [fillRateMana, fillRateManaShield]
      property var manaFillRate: [fillRateMana]
      arcWidth: (showManaShield ? hudRoot.arcWidth / 2 : ((hudRoot.showCombopointsAndSerene && !hudRoot.showCombopointsAndSereneOnLeft) ? hudRoot.arcWidth / 2  : hudRoot.arcWidth))
      borderWidth: hudRoot.arcBorderWidth
      borderColor: Qt.rgba(0.0,0.0,0.0,1.0)
      rightArc: true
      showSerene: (hudRoot.showCombopointsAndSerene && !hudRoot.showCombopointsAndSereneOnLeft)
      isSerene: hudRoot.isSerene

      readonly property var comboPointsfillRate: comboPoints == 0 ? 0.0 :
                                                (comboPoints == 1 ? 0.2 :
                                                (comboPoints == 2 ? 0.4 :
                                                (comboPoints == 3 ? 0.6 :
                                                (comboPoints == 4 ? 0.8 : 1.0))))

      readonly property color comboPointsColor: Qt.rgba(comboPointsBaseColor.r, comboPointsBaseColor.g, comboPointsBaseColor.b, hudRoot.fillColorAlpha)

      
      // TO DO
      progressBarsFillRates: {
        if (showManaShield) {
          return manaAndShieldFillRates;
        } else {
          if (hudRoot.showCombopointsAndSerene && !hudRoot.showCombopointsAndSereneOnLeft) {
            return [manaFillRate, comboPointsfillRate];
          }
          return manaFillRate;       
        }
      }
      
      progressBarsColors:{
        if (showManaShield) {
          return [Qt.rgba(manaBaseColor.r, manaBaseColor.g, manaBaseColor.b, hudRoot.fillColorAlpha),
          Qt.rgba(manaShieldBaseColor.r, manaShieldBaseColor.g, manaShieldBaseColor.b, hudRoot.fillColorAlpha)];
        } else {
          if (hudRoot.showCombopointsAndSerene && !hudRoot.showCombopointsAndSereneOnLeft) {
            return [Qt.rgba(manaBaseColor.r, manaBaseColor.g, manaBaseColor.b, hudRoot.fillColorAlpha), comboPointsColor];
          }
        
          return [Qt.rgba(manaBaseColor.r, manaBaseColor.g, manaBaseColor.b, hudRoot.fillColorAlpha)];
        }
      }
      
      progressBarsToDivide:{
        if (!showManaShield && hudRoot.showCombopointsAndSerene && !hudRoot.showCombopointsAndSereneOnLeft) {
          return [2];
        }
        return [];
      }
      
      progressBarDivisionFillRates: (!showManaShield && hudRoot.showCombopointsAndSerene && !hudRoot.showCombopointsAndSereneOnLeft) ? [0.2, 0.4, 0.6, 0.8] : []

      onWidthChanged: refreshImplicitWidth()
    }
  }

  Item {
    id: specialConditionsBar

    // layout config settings
    readonly property int barPaddingHorizontal: 2
    readonly property int barPaddingVertical: 6
    readonly property int marginToArcScaled: 6 * scaleFactor
    readonly property int iconSpacing: 4
    readonly property int maxIconCount: 6

    visible: hudRoot.showSpecialConditions

    onVisibleChanged: refreshImplicitWidth()

    scale: scaleFactor
    transformOrigin: Item.Left
    anchors.verticalCenter: hudMainLayout.verticalCenter

    width: specialConditionsMainLayout.width + barPaddingHorizontal * 2
    height: specialConditionsMainLayout.height + barPaddingVertical * 2

    onWidthChanged: refreshImplicitWidth()

    onHeightChanged: {
      backdrop.height = height;
    }

    Item {
      id: specialConditionsBarContent
      anchors.fill: parent
      visible: playerStates && playerStates.rowCount() > 0

      Rectangle {
        id: backdrop
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        opacity: 0.5
        radius: width / 2
        color: "black"

        Behavior on height {
          NumberAnimation {
            duration: 100
            easing.type: Easing.Linear
          }
        }
      }

      ColumnLayout {
        id: specialConditionsMainLayout
        spacing: specialConditionsBar.iconSpacing
        anchors.top: parent.top
        anchors.topMargin: specialConditionsBar.barPaddingVertical
        anchors.horizontalCenter: parent.horizontalCenter

        Repeater {
          model: Math.min(specialConditionsBar.maxIconCount, (_playerStatesHelperModel ? _playerStatesHelperModel.rowCount() : 0))

          Image {
            property var entry: _playerStatesHelperModel.sourceItemDataByRowIndex(modelData)

            source: entry.imageSource
            smooth: false
            Layout.preferredWidth: 9
            Layout.preferredHeight: 9
          }
        }

        Image {
          source: "/images/creatures/icon-dots.png"
          smooth: false
          Layout.alignment: Qt.AlignCenter
          visible: _playerStatesHelperModel && _playerStatesHelperModel.rowCount() > specialConditionsBar.maxIconCount
        }
      }
    }
  }
} //Item
