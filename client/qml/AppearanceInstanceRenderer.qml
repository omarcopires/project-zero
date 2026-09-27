import QtQuick

/*
 * Project-owned compatibility renderer. It draws static object appearances
 * through the client's registered provider. Race/outfit catalogs, animation,
 * effects and multi-layer composition require the original native renderer.
 */
Item {
  id: root

  property var appearanceInstances: []
  property point cameraPosition: Qt.point(0, 0)
  property bool center: false
  property bool shrinkToFit: false
  property bool animated: false
  property bool smoothTextureFiltering: false
  property real scaleFactor: 1.0
  property bool rendererSupportsGraphicEffects: false
  readonly property rect completeBoundingRect: childrenRect

  function createAppearanceInstanceByRaceID(raceID) {
    // Race IDs require the proprietary race-to-outfit catalog, which this
    // client does not contain. Returning null preserves the QML's fallback.
    return null;
  }

  function getRaceName(raceID) {
    return "";
  }

  Repeater {
    model: root.appearanceInstances

    delegate: Image {
      required property var modelData
      readonly property real instanceX: modelData.position ? modelData.position.x : 0
      readonly property real instanceY: modelData.position ? modelData.position.y : 0
      x: root.width / 2 + (instanceX - root.cameraPosition.x) * root.scaleFactor - width / 2
      y: root.height / 2 + (instanceY - root.cameraPosition.y) * root.scaleFactor - height / 2
      width: modelData.spriteSize ? modelData.spriteSize.width * root.scaleFactor : 32 * root.scaleFactor
      height: modelData.spriteSize ? modelData.spriteSize.height * root.scaleFactor : 32 * root.scaleFactor
      source: modelData.typeid > 0 && modelData.imageKind === "object"
        ? "image://appearance/object/" + modelData.typeid
        : ""
      fillMode: Image.PreserveAspectFit
      smooth: root.smoothTextureFiltering
      visible: source !== ""
    }
  }
}
