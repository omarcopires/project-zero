import QtQuick



BorderImage {
  id: frameBI
  property var fillPercentage: 0.0

  property alias frameSource: frameBI.source
  property alias backgroundSource: backgroundI.source
  property alias fillSource: fillBI.source

  property alias frameBorder: frameBI.border
  property alias fillBorder: fillBI.border
  property TibiaDirectionContainer fillOffset: TibiaDirectionContainer {}

  property bool vertical: false

  property bool rightToLeft: false
  property alias bottomToTop: frameBI.rightToLeft

  horizontalTileMode: BorderImage.Repeat
  verticalTileMode: BorderImage.Repeat
  smooth: false

  BorderImage {
    id: backgroundI
    anchors.fill: parent
    anchors.leftMargin: frameBorder.left
    anchors.rightMargin: frameBorder.right
    anchors.topMargin: frameBorder.top
    anchors.bottomMargin: frameBorder.bottom
    horizontalTileMode: BorderImage.Repeat
    verticalTileMode: BorderImage.Repeat 
    smooth: false
  } //Image

  Item {
    id: progressBarFill

    anchors.left: !vertical ? (rightToLeft ? undefined : parent.left) : parent.left
    anchors.right: !vertical ? (rightToLeft ? parent.right : undefined) : parent.right
    anchors.top: vertical ? (bottomToTop ? undefined : parent.top) : parent.top
    anchors.bottom: vertical ? (bottomToTop ? parent.bottom : undefined) :parent.bottom

    anchors.leftMargin: fillOffset.left
    anchors.rightMargin: fillOffset.right
    anchors.topMargin: fillOffset.top
    anchors.bottomMargin: fillOffset.bottom
    
    property int maxFillWidth: Math.floor(frameBI.width) - fillOffset.left - fillOffset.right
    width: fillPercentage * maxFillWidth

    property int maxFillHeight: Math.floor(frameBI.height) - fillOffset.top - fillOffset.bottom
    height: fillPercentage * maxFillHeight

    BorderImage {
      id: fillBI
      horizontalTileMode: vertical ? BorderImage.Repeat : BorderImage.Stretch 
      verticalTileMode : vertical ? BorderImage.Stretch : BorderImage.Repeat 
      anchors.fill: parent
      smooth: false
    } //BorderImage
  } //Item
} //BorderImage
