import QtQuick



Rectangle {
  property alias borderWidth: frame.borderWidth
  color: TibiaStyle.tableViewBackgroundColor

  TibiaFrame1PixelDown {
    id: frame
    anchors.fill: parent
  } // TibiaFrame1PixelDown
} // Rectangle
