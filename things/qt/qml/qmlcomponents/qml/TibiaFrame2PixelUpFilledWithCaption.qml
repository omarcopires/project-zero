import QtQuick

TibiaFrame2PixelUpFilled {
  readonly property int borderWidth: 2
  readonly property int captionHeight: 17
  readonly property int marginsToContent: borderWidth + TibiaStyle.marginRelated
  readonly property int topMarginToContent: captionHeight + TibiaStyle.marginRelated
  property alias caption: captionText.text
  property alias captionHorizontalAlignment: captionText.horizontalAlignment

  BorderImage {
    id: headerImage
    smooth: false
    anchors { left: parent.left; top: parent.top; right: parent.right }
    border { left: parent.borderWidth; top: parent.borderWidth; right: parent.borderWidth; bottom: 1 }
    horizontalTileMode: BorderImage.Repeat
    verticalTileMode: BorderImage.Repeat
    source: "/images/2pixel-up-header-smoother.png"
  } //Image

  TibiaText {
    id: captionText
    height: parent.captionHeight
    anchors { left: parent.left; top: parent.top; right: parent.right }
    anchors.leftMargin: parent.borderWidth + TibiaStyle.marginNarrow
    anchors.rightMargin: parent.borderWidth + TibiaStyle.marginNarrow
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
    styleType: "Caption"
    elide: Text.ElideRight
  } //TibiaText
} //TibiaFrame2PixelUpFilled
