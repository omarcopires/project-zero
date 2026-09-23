import QtQuick
import QtQuick.Controls.Basic

import qmlcomponents


RadioButton {
  id: control
  property string tooltipText: ""
  property string tooltipTextChecked: ""

  spacing: TibiaStyle.labelMargin
  padding: 0
  focusPolicy: Qt.NoFocus

  indicator: Image {
    id: checkboxImage
    smooth: false
    source: !checked ? "/images/skin/classic/radiobutton-unchecked.png"
                     : (enabled ? "/images/skin/classic/radiobutton-checked.png"
                                : "/images/skin/classic/radiobutton-checked-disabled.png")
  } //indicator: Image

  contentItem: TibiaText {
    text: control.text
    leftPadding: control.indicator.width + control.spacing
    verticalAlignment: Text.AlignVCenter
  } //label: TibiaText

  Tooltip {
    enabled: (tooltipText != "") || (tooltipTextChecked != "")
    anchors.fill: parent
    text: (parent.checked && tooltipTextChecked != "") ? tooltipTextChecked : tooltipText
  } //Tooltip
} //RadioButton
