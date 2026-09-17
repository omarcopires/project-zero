import QtQuick
import QtQuick.Layouts

Item {
  default property alias contents: childrenPlaceholder.children
  property alias caption: captionText.text
  property alias captionHorizontalAlignment: captionText.horizontalAlignment
  property alias captionHeight: frame.captionHeight
  property int innerMargin: TibiaStyle.marginRelated
  property alias spacing: childrenPlaceholder.spacing
  property bool autoHeight: true

  implicitHeight: autoHeight ? childrenPlaceholder.y + childrenPlaceholder.height + innerMargin + 2 : 0

  TibiaFrame2PixelUpFilled {
    id: frame
    readonly property int borderWidth: 2
    readonly property int captionHeight: 17
    readonly property int marginsToContent: borderWidth
    readonly property int topMarginToContent: captionHeight
    anchors.fill: parent


    BorderImage {
      id: headerImage
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
  ColumnLayout {
    id: childrenPlaceholder
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: autoHeight ? undefined : parent.bottom
    anchors.margins: innerMargin
    anchors.topMargin: innerMargin + frame.topMarginToContent
    spacing: 0
  }
}
