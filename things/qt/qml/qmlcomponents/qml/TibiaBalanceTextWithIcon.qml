import QtQuick
import QtQuick.Layouts

import qmlcomponents



Item {

  property real value: 0
  property var iconSource: ""
  property bool leftAligned: true
  property int rowLayoutSpacing: TibiaStyle.marginNarrow

  implicitHeight: innerRowLayout.height
  implicitWidth: innerRowLayout.width

  RowLayout {

    id: innerRowLayout
    anchors.left: parent.left
    anchors.top: parent.top
    anchors.right: parent.right

    spacing: rowLayoutSpacing

    TibiaText {
      text: TextHelper.formatNumberWithThousandSeparators(Math.abs(value))
      elide: leftAligned ? Text.ElideLeft : Text.ElideRight
      horizontalAlignment: leftAligned ? Text.AlignLeft : Text.AlignRight
    } //TibiaText

    Image {
      source:  iconSource
      smooth: false
      Layout.leftMargin: TibiaStyle.marginNarrow
      Layout.alignment: leftAligned ? Qt.AlignLeft : Qt.AlignRight
    } //Image
  } //RowLayout

} // Item
