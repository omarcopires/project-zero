import QtQuick

Item {
  id: root

  property int typeid: 0
  property int cumulativeCount: 0
  property int liquidType: 0
  property int hookDirection: 0
  property int decoItemObjectID: 0
  property real scaleFactor: 1.0
  property bool animated: false
  property bool smoothTextureFiltering: false

  // The current provider resolves only static, single-sprite object appearances.
  Image {
    anchors.fill: parent
    source: root.typeid > 0 ? "image://appearance/object/" + root.typeid : ""
    fillMode: Image.PreserveAspectFit
    smooth: root.smoothTextureFiltering
    scale: root.scaleFactor
  }
}
