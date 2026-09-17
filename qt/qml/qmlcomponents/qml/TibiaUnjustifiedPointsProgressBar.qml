import QtQuick



BorderImage {
  id: progressBarFrame
  property alias fillPercentage: progressBarFill.fillPercentage
  property int killsToNextSkull: 0

  source: "/images/skin/classic/unjustified-points-bar-background.png"
  border { left: 1; right: 1; top: 1; bottom: 1 }
  horizontalTileMode: BorderImage.Repeat
  smooth: false

  Item {
    id: progressBarFill
    anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
    anchors.margins: 1
    
    property var fillPercentage: 0.0
    width: Math.floor(fillPercentage * parent.width)

    BorderImage {
      smooth: false
      property string barColor: {
        if (progressBarFrame.killsToNextSkull > 2) {
          return "green";
        }
        else if (progressBarFrame.killsToNextSkull > 1) {
          return "yellow";
        }
        else {
          return "red";
        }
      }
      anchors.fill: parent
      source: "/images/skin/classic/unjustified-points-bar-texture-" + barColor + ".png"
      horizontalTileMode: BorderImage.Repeat
      verticalTileMode: BorderImage.Repeat 
    } //Image
  } //Item
} //BorderImage
