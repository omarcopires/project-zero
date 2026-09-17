import QtQuick



BorderImage {
  readonly property int borderWidth: 2
  readonly property int marginsToContent: borderWidth + TibiaStyle.marginRelated
  property bool pinnedToBottom: false //ATTENTION: makes the whole content of the object upside down :D
  property bool dark: false

  border { left: borderWidth; top: borderWidth; right: borderWidth; bottom: borderWidth }
  horizontalTileMode: BorderImage.Repeat
  verticalTileMode: BorderImage.Repeat
  source: dark ? (pinnedToBottom ? "/images/2pixel-up-frame-borderimage-dark-upside-down.png"
                                 : "/images/2pixel-up-frame-borderimage-dark.png")
               : (pinnedToBottom ? "/images/2pixel-up-frame-borderimage-upside-down.png"
                                 : "/images/2pixel-up-frame-borderimage.png")
  smooth: false
  rotation: pinnedToBottom ? 180 : 0
} //BorderImage
