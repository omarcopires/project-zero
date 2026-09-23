import QtQuick
import QtQuick.Layouts

import qmlcomponents


RowLayout {
  id: root
  Layout.fillWidth: true
  spacing: TibiaStyle.marginRelated

  property alias key: keyText.text
  property int keyTextWidth: -1
  property alias value: valueText.text
  property string valueTooltip: ""
  property bool valueFillWidth: true
  property alias valueAlignment: valueText.horizontalAlignment
  property int valueTextWidth: -1

  TibiaText {
    id: keyText
    styleType: "Caption"

    Layout.preferredWidth: root.keyTextWidth
    horizontalAlignment: root.keyTextWidth > 0 ? Text.AlignRight : Text.AlignLeft
  } //TibiaText

  TibiaText {
    id: valueText
    Layout.fillWidth: root.valueFillWidth
    Layout.preferredWidth: root.valueTextWidth
    Layout.maximumWidth: Layout.preferredWidth

    Loader {
      anchors.fill: parent
      sourceComponent: valueTooltip.length > 0 ? tooltipComponent : null
      Component {
        id: tooltipComponent
        Tooltip {
          anchors.fill: parent
          text: valueTooltip
        } //Tooltip
      } //Component
    } //Loader
  } //TibiaText
} //RowLayout
