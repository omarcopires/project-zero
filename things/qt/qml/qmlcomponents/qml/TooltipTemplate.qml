import QtQuick
import QtQuick.Layouts




Rectangle {
  id: root
  property alias text: tooltipText.text
  property int tooltipMaxWidth: 0
  property bool useRichText: false

  property int clientWidth: parent.width

  border.width: 1
  border.color: "black"

  color: TibiaStyle.tooltipBackgroundColor
  width: textColumn.width + 2*TibiaStyle.tooltipBorderMargin
  height: textColumn.height + 2*TibiaStyle.tooltipBorderMargin

  Column {
    id: textColumn
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    //Math.min() needed as RichText masses with the contentWith and width masses with the implicitWidth
    width: Math.min(tooltipText.implicitWidth, tooltipText.contentWidth)
    TibiaText {
      id: tooltipText

      font: TibiaStyle.tooltipFont
      color: TibiaStyle.tooltipTextColor
      width: (root.tooltipMaxWidth > 0 ? Math.min(root.clientWidth, root.tooltipMaxWidth) : root.clientWidth) - 2*TibiaStyle.tooltipBorderMargin
      wrapMode: Text.Wrap
      elide: Text.ElideNone

      textFormat: root.useRichText ? Text.RichText : Text.AutoText
    } //TibiaText
  } //Column
} //Rectangle
