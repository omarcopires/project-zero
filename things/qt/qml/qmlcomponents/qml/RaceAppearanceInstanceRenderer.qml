import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import qmlcomponents



/****************************************************************************
* The use of OutfitAppearanceInstanceRenderer might be easier in some cases *
*****************************************************************************/

Item {
  id: root
  property int raceID: 0
  property bool isUnknown: false
  property bool autofit: true
  property bool moving: true
  property var maxScaleFactorForAutoFit: 1.0

  property string raceName: appearanceInstanceRenderer.getRaceName(raceID)

  property alias cameraPosition: appearanceInstanceRenderer.cameraPosition
  property alias scaleFactor: appearanceInstanceRenderer.scaleFactor
  property alias smoothTextureFiltering: appearanceInstanceRenderer.smoothTextureFiltering
  property alias center: appearanceInstanceRenderer.center
  property alias animated: appearanceInstanceRenderer.animated
  property alias rendererSupportsGraphicEffects: appearanceInstanceRenderer.rendererSupportsGraphicEffects

  property var _boundingRect: Qt.rect(0,0,0,0)
  property int _raceID: appearanceInstanceRenderer.rendererSupportsGraphicEffects ? raceID : isUnknown ? 0 : raceID

  Loader {
    Component {
      id: unknownMonsterComponent
      Image {
        source: "/images/icon-questionmark.png"
        smooth: false
      } //Image
    } //Component
    anchors.centerIn: parent
    sourceComponent: appearanceInstanceRenderer.rendererSupportsGraphicEffects ? null : isUnknown ? unknownMonsterComponent : null
  } //Loader

  AppearanceInstanceRenderer {
    id: appearanceInstanceRenderer
    anchors.fill: parent

    clip: false
    animated: true
    smoothTextureFiltering: true
    center: true

    function updateRaceOutfitAppearanceInstance() {
      var raceOutfitAppearanceInstance = createAppearanceInstanceByRaceID(_raceID);
      if (raceOutfitAppearanceInstance != null) {
        raceOutfitAppearanceInstance.moving = root.moving;
        appearanceInstances = [raceOutfitAppearanceInstance];
        cameraPosition = Qt.point(raceOutfitAppearanceInstance.boundingRect.left, raceOutfitAppearanceInstance.boundingRect.top);
        _boundingRect = Qt.binding(function() { return raceOutfitAppearanceInstance.boundingRect });
      } else {
        appearanceInstances = [];
      }
    } //function updateRaceOutfitAppearanceInstance

    Component.onCompleted: {
      updateRaceOutfitAppearanceInstance();
      caculateAutoFitScaleFactor();
    } //Component.onCompleted
  } //AppearanceInstanceRenderer

  MultiEffect {
    height: parent.height
    width: parent.width
    anchors.centerIn: parent
    brightness: isUnknown ? -1.0 : 0.0
    source: appearanceInstanceRenderer
  } // MultiEffect

  function caculateAutoFitScaleFactor() {
    if (_boundingRect) {
      var maxSize = Math.max(_boundingRect.width, _boundingRect.height);
      if (autofit && maxSize > 0) {
        var calculatedScaleFactor = width / maxSize;
        // only shrink appearances
        appearanceInstanceRenderer.scaleFactor = Math.min(root.maxScaleFactorForAutoFit, calculatedScaleFactor);
      }
    }
  } //function caculateAutoFitScaleFactor

  on_BoundingRectChanged: {
    caculateAutoFitScaleFactor();
  } //on_BoundingRectChanged

  onAutofitChanged: {
    caculateAutoFitScaleFactor();
  } //onAutofitChanged

  onWidthChanged: {
    caculateAutoFitScaleFactor();
  }

  onHeightChanged: {
    caculateAutoFitScaleFactor();
  }

  on_RaceIDChanged: {
    appearanceInstanceRenderer.updateRaceOutfitAppearanceInstance();
  } //on_RaceIDChanged

  onMovingChanged: {
    appearanceInstanceRenderer.updateRaceOutfitAppearanceInstance();
  } //onMovingChanged

} //Item
