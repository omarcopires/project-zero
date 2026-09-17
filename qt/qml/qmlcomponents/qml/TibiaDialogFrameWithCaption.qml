import QtQuick

BorderImage {
  property alias caption: captionText.text
  readonly property alias captionContentWidth: captionText.contentWidth
  readonly property int captionHeight: TibiaStyle.dialogHeaderLineHeight
  property int borderToContentMargin: TibiaStyle.dialogContentToFrameMargin
  readonly property int borderWidth: TibiaStyle.dialogFrameWidith
  readonly property int marginsToContent: borderWidth + borderToContentMargin
  readonly property int topMarginToContent: captionHeight + borderToContentMargin

  border { left: 4; top: 17; right: 4; bottom: 4 }
  horizontalTileMode: BorderImage.Repeat
  verticalTileMode: BorderImage.Repeat
  source: "/images/skin/classic/dialog-frame-borderimage.png"

  // settins smooth to false here seems to trigger a very subtle bug in combination with NVIDIA graphics cards with newer drivers
  // see: TIBIA-21144
  // smooth: false

  TibiaText {
    id: captionText
    styleType: "Caption"
    height: parent.border.top
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.leftMargin: TibiaStyle.marginUnrelated
    anchors.rightMargin: TibiaStyle.marginUnrelated
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
  } //TibiaText
} //BorderImage