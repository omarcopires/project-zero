import QtQuick

QtObject {
  id: root

  property int typeid: 0
  property point position: Qt.point(0, 0)
  property point shift: Qt.point(0, 0)
  property int elevation: 0
  property int currentElevation: 0
  property size spriteSize: Qt.size(32, 32)
  property rect boundingRect: Qt.rect(position.x, position.y, spriteSize.width, spriteSize.height)
  property int cumulativeCount: 0
  property int liquidType: 0
  property int hookDirection: 0
  property int decoItemObjectID: 0
  readonly property string imageKind: "object"
}
