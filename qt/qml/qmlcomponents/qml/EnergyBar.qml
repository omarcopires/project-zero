import QtQuick
import QtQuick.Layouts



RowLayout {
  property int currentValue: 0
  property int maxValue: 0
  property alias symbolImage: symbol.source
  property alias barBorderImage: outerBar.source
  property alias barFillImage: barFill.source

  spacing: TibiaStyle.marginNarrow

  Image {
    id: symbol
    smooth: false
  } // Image

  Image {
    id: outerBar
    smooth: false

    Image {
      id: barFill
      horizontalAlignment: Image.AlignLeft
      fillMode: Image.Pad

      property double fillPercent: maxValue > 0 ? Math.max(0.0, Math.min(1.0, (currentValue / maxValue))) : 0
      width: Math.round(outerBar.width * fillPercent) // XXX: The software renderer uses incorrect width for very small decimal values, so round to integer
      smooth: false
    } // Image
  } // Image

  Item {
    Layout.fillWidth: true
  } //Item

  TibiaText {
    text: currentValue
    Layout.preferredWidth: TibiaStyle.sideBarPanelRightSideWith
    Layout.preferredHeight: outerBar.height
    verticalAlignment: Text.AlignVCenter
  } // TibiaText
} // RowLayout
