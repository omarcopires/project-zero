import QtQuick



BorderImage {
  readonly property int borderWidth: 3
  readonly property int marginsToContent: borderWidth + TibiaStyle.marginRelated

  border { left: borderWidth; top: borderWidth; right: borderWidth; bottom: borderWidth }
  horizontalTileMode: BorderImage.Repeat
  verticalTileMode: BorderImage.Repeat
  source: "/images/3pixel-frame-borderimage.png"  
  smooth: false
} //BorderImage
