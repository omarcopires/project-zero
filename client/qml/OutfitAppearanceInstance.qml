import QtQuick

QtObject {
  id: root

  enum LookDirection {
    NORTH = 0,
    EAST = 1,
    SOUTH = 2,
    WEST = 3
  }

  property int typeid: 0
  property point position: Qt.point(0, 0)
  property point shift: Qt.point(0, 0)
  property int elevation: 0
  property int currentElevation: 0
  property size spriteSize: Qt.size(32, 32)
  property rect boundingRect: Qt.rect(position.x, position.y, spriteSize.width, spriteSize.height)
  property color headColor: "black"
  property color torsoColor: "black"
  property color legsColor: "black"
  property color detailColor: "black"
  property bool firstAddOn: false
  property bool secondAddOn: false
  property int lookDirection: OutfitAppearanceInstance.SOUTH
  property bool moving: false
  property int movementSpeedInMillisecondsPerField: 0
  readonly property string imageKind: "outfit"
}
