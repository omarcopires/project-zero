import QtQuick



BorderImage {
  id: frameBI
  property var fillPercentageTop: 0.0
  property var fillPercentageBottom: 0.0

  property alias frameSource: frameBI.source
  property alias backgroundSource: backgroundI.source

  property alias fillSourceTop: fillBITop.source
  property alias fillSourceBottom: fillBIBottom.source

  property alias frameBorder: frameBI.border
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
    id: progressBarFillTop

    anchors.left: !vertical ? (rightToLeft ? undefined : parent.left) : parent.left
    anchors.right: !vertical ? (rightToLeft ? parent.right : undefined) : undefined
    anchors.top: vertical ? (bottomToTop ? undefined : parent.top) : parent.top
    anchors.bottom: vertical ? (bottomToTop ? parent.bottom : undefined) : undefined


    anchors.leftMargin: fillOffset.left
    anchors.rightMargin: fillOffset.right
    anchors.topMargin: fillOffset.top
    anchors.bottomMargin: fillOffset.bottom

    property int maxFillWidth: vertical? Math.floor(parent.width/2) : Math.floor(frameBI.width) - fillOffset.left - fillOffset.right
    width: vertical ? fillBITop.implicitWidth : fillPercentageTop * maxFillWidth

    property int maxFillHeight: !vertical? Math.floor(parent.height/2) : frameBI.height - fillOffset.top - fillOffset.bottom
    height: vertical? (fillPercentageTop * maxFillHeight) : fillBITop.implicitHeight

    BorderImage {
      id: fillBITop
      horizontalTileMode: vertical ? BorderImage.Repeat : BorderImage.Stretch
      verticalTileMode : vertical ? BorderImage.Stretch : BorderImage.Repeat
      anchors.fill: parent
      smooth: false
    } //BorderImage

  } //Item

  Item {
    id: progressBarFillBottom

    anchors.left: !vertical ? (rightToLeft ? undefined : parent.left) : undefined
    anchors.right: !vertical ? (rightToLeft ? parent.right : undefined) : parent.right
    anchors.top: vertical ? (bottomToTop ? undefined : parent.top) : undefined
    anchors.bottom: vertical ? (bottomToTop ? parent.bottom : undefined) : parent.bottom

    anchors.leftMargin: fillOffset.left
    anchors.rightMargin: fillOffset.right
    anchors.topMargin: fillOffset.top
    anchors.bottomMargin: fillOffset.bottom

    property int maxFillWidth: vertical ? Math.floor(parent.width/2) : Math.floor(frameBI.width) - fillOffset.left - fillOffset.right
    width: vertical ? fillBIBottom.implicitWidth : fillPercentageBottom * maxFillWidth

    property int maxFillHeight: !vertical? Math.floor(parent.height/2) : frameBI.height - (fillOffset.top + fillOffset.bottom)
    height: vertical ? (fillPercentageBottom * maxFillHeight) : fillBIBottom.implicitHeight

    BorderImage {
      id: fillBIBottom
      horizontalTileMode: vertical ? BorderImage.Repeat : BorderImage.Stretch
      verticalTileMode : vertical ? BorderImage.Stretch : BorderImage.Repeat
      anchors.fill: parent
      smooth: false
    } //BorderImage
  } //Item
} //BorderImage
