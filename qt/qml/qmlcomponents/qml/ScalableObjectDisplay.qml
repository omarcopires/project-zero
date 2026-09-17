import QtQuick
import QtQuick.Effects
import qmlcomponents



Item {
  id: root

  property bool showBackground: true

  property alias smoothTextureFiltering: objectRenderer.smoothTextureFiltering
  property alias animated: objectRenderer.animated
  property alias scaleFactor: objectRenderer.scaleFactor
  property alias typeid: objectRenderer.typeid
  property int upgradeTier: 0
  property alias cumulativeCount: objectRenderer.cumulativeCount
  property alias liquidType: objectRenderer.liquidType
  property alias hookDirection: objectRenderer.hookDirection
  property alias decoItemObjectID: objectRenderer.decoItemObjectID
  property bool mysteryObject: false
  property bool mirrorImage: false

  implicitHeight: objectRenderer.width
                + (showBackground ? 2 : 0)
  implicitWidth: implicitHeight

  Loader {
    anchors.fill: parent
    Component {
      id: backgroundComponent
      BorderImage {
        source: "/images/backdrop-dark-grey.png"
        horizontalTileMode: BorderImage.Repeat
        verticalTileMode: BorderImage.Repeat

        TibiaFrame1PixelDown {
          anchors.fill: parent
        } //TibiaFrame1PixelDown
      } //BorderImage
    } //Component

    sourceComponent: root.showBackground ? backgroundComponent : undefined
  } //Leader

  SingleObjectAppearanceInstanceRenderer {
    id: objectRenderer
    anchors.centerIn: parent
    width: Math.ceil(TibiaStyle.mapWindowPixelPerField * scaleFactor)
    height: width

    opacity: GlobalConstants.isSoftwareRenderer && root.mysteryObject ? TibiaStyle.noShaderBlackoutOpacity : 1
    transform: [
      Matrix4x4 {
        matrix: mirrorImage ? Qt.matrix4x4(-1, 0, 0, objectRenderer.width, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1) : Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
      }
    ]
  } //SingleObjectAppearanceInstanceRenderer

  Loader {
    height: objectRenderer.height
    width: objectRenderer.width
    anchors.centerIn: parent
    sourceComponent: !GlobalConstants.isSoftwareRenderer && root.mysteryObject ? mysteryShaderComponent : undefined

    Component {
      id: mysteryShaderComponent
        MultiEffect {
          brightness: -1.0
        source: objectRenderer
        } // MultiEffect
    } // Component
  } // Loader

  Loader {
    anchors.top: objectRenderer.top
    anchors.right: objectRenderer.right
    Component {
      id: upgradeTierComponent
      Image {
        source: (root.scaleFactor < 1.5 ? "image://upgrade-tiers/"
                                        : "image://upgrade-tiers-big/")
             + (root.upgradeTier-1)
        smooth: false
      } //Image
    } //Component
    sourceComponent: root.upgradeTier > 0 ? upgradeTierComponent : undefined
  } //Loader
} //Item
