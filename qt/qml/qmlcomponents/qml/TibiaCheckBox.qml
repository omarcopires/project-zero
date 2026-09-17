import QtQuick
import QtQuick.Controls.Basic

import qmlcomponents


CheckBox {
  id: tibiaCheckBox
  property var styleType: "Dialog"
  property string tooltipText: ""
  property string tooltipTextChecked: ""
  property int labelMargin: TibiaStyle.labelMargin
  property int checkboxWidth: 0

  spacing: tibiaCheckBox.labelMargin
  padding: 0
  display: AbstractButton.TextBesideIcon
  focusPolicy: Qt.NoFocus

  //helps to give the check box its correct checked state if used from outside
  property bool shouldBeChecked: false
  onShouldBeCheckedChanged: {
    if (checked != shouldBeChecked) {
      checked = shouldBeChecked;
    }
  } //onButtonShouldBeCheckedChanged

  indicator: Image {
    id: checkboxImage
    source: tibiaCheckBox.checked
      ? (tibiaCheckBox.enabled
        ? "/images/skin/classic/checkbox-checked.png"
        : "/images/skin/classic/checkbox-checked-disabled.png")
      : "/images/skin/classic/checkbox-unchecked.png"

    Component.onCompleted: {
      tibiaCheckBox.checkboxWidth = width;
    }
  } //indicator: Image

  contentItem: TibiaText {
    text: tibiaCheckBox.text
    styleType: tibiaCheckBox.styleType
    leftPadding: tibiaCheckBox.indicator.width + tibiaCheckBox.spacing
  } //label: TibiaText

  Tooltip {
    enabled: (tooltipText != "") || (tooltipTextChecked != "")
    anchors.fill: parent
    text: (parent.checked && tooltipTextChecked != "") ? tooltipTextChecked : tooltipText
  } //Tooltip
} //CheckBox
