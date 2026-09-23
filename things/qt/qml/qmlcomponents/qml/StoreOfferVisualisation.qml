import QtQuick
import QtQuick.Layouts
import qmlcomponents
import qmlenumvalues


Loader {
  property var visualisation: null
  property var dynamicallyLoadedImageManager: null
  property bool smoothTextureFiltering: false
  property int sourceImageSize: -1
  property bool scaleUp: false

  sourceComponent: {
    if (visualisation != null) {
      return visualisation.visualisationType == TOfferVisualisation.VISUALISATION_IMAGE_IDENTIFIER
        ? dynamicImageComponent : appearanceRendererComponent;
    } else {
      return undefined;
    }
  } // sourceComponent

  Component {
    id: appearanceRendererComponent

    AppearanceInstanceRenderer {
      id: appearanceInstanceRenderer
      property var visualisation: null

      anchors.fill: parent
      animated: true
      center: true
      scaleFactor: width / 64

      onVisualisationChanged: {
        if (visualisation != null) {
          var createdAppearanceInstance = null;
          if (visualisation.visualisationType == TOfferVisualisation.VISUALISATION_OUTFIT ||
              visualisation.visualisationType == TOfferVisualisation.VISUALISATION_MOUNT) {
            createdAppearanceInstance = outfitComponent.createObject(appearanceInstanceRenderer);
            createdAppearanceInstance.typeid = visualisation.appearanceTypeID;
            createdAppearanceInstance.headColor = visualisation.headColor;
            createdAppearanceInstance.torsoColor = visualisation.torsoColor;
            createdAppearanceInstance.legsColor = visualisation.legsColor;
            createdAppearanceInstance.detailColor = visualisation.detailColor;
            createdAppearanceInstance.firstAddOn = visualisation.hasAddon1;
            createdAppearanceInstance.secondAddOn = visualisation.hasAddon2;
          } else if (visualisation.visualisationType == TOfferVisualisation.VISUALISATION_OBJECT) {
            createdAppearanceInstance = objectComponent.createObject(appearanceInstanceRenderer);
            createdAppearanceInstance.typeid = visualisation.appearanceTypeID;
            createdAppearanceInstance.hookDirection = ObjectAppearanceInstance.SOUTH;
          } else if (visualisation.visualisationType == TOfferVisualisation.VISUALISATION_BOTH_GENDER_OUTFITS) {
            createdAppearanceInstance = outfitComponent.createObject(appearanceInstanceRenderer);
            createdAppearanceInstance.typeid = visualisation.appearanceTypeForGenderToShow;
            createdAppearanceInstance.headColor = visualisation.headColor;
            createdAppearanceInstance.torsoColor = visualisation.torsoColor;
            createdAppearanceInstance.legsColor = visualisation.legsColor;
            createdAppearanceInstance.detailColor = visualisation.detailColor;
            createdAppearanceInstance.firstAddOn = visualisation.hasAddon1;
            createdAppearanceInstance.secondAddOn = visualisation.hasAddon2;
          }
          if (createdAppearanceInstance != null) {
            appearanceInstances = [createdAppearanceInstance];
          }
        }
      } // onVisualisationChanged
    } // AppearanceInstanceRenderer
  } // Component

  Component {
    id: outfitComponent

    OutfitAppearanceInstance {
      lookDirection: OutfitAppearanceInstance.SOUTH
      moving: false
      movementSpeedInMillisecondsPerField: 1000
      position: Qt.point(32, 32)
    }
  } // Component

  Component {
    id: objectComponent

    ObjectAppearanceInstance {
      position: Qt.point(0, 0)
    }
  } // Component

  Component {
    id: dynamicImageComponent

    DynamicallyLoadedImage {
      anchors.fill: parent
    }
  } // Component

  onLoaded: {
    if (visualisation != null && visualisation.visualisationType == TOfferVisualisation.VISUALISATION_IMAGE_IDENTIFIER) {
      item.imageKey = Qt.binding(function() { return visualisation != null ? visualisation.imageIdentifier : ""; });
      item.dynamicallyLoadedImageManager = Qt.binding(function() { return dynamicallyLoadedImageManager; });
      item.sourceImageSize = Qt.binding(function() { return sourceImageSize; });
      item.scaleUp = Qt.binding(function() { return scaleUp; });
    } else {
      item.visualisation = Qt.binding(function() { return visualisation; });
      item.smoothTextureFiltering = Qt.binding(function() { return smoothTextureFiltering; });
    }
  }

} // Loader
