import QtQuick
import QtQuick.Controls.Basic
import qmlcomponents



Button {
  id: button
  property string sourceUp
  property string sourceDown
  property string sourceChecked: sourceDown
  property string tooltipText: ""
  property string tooltipTextChecked: ""
  property alias  tooltipMaxWidth: buttonTooltip.maxWidth

  //visibly hides and deactivates the button
  //but it still takes space in Layouts
  property bool hide: false
  opacity: hide ? 0 : 1
  enabled: !hide
  focusPolicy: Qt.NoFocus

  // Paddings must be set to 0 as they determin the min size of the button.
  // The default values would allow no smaller button than 16x12
  leftPadding: 0 //default 8
  rightPadding: 0 //default 8
  topPadding: 0 //default 6
  bottomPadding: 0 //default 6

  background: Image {
    id: backgroundImage
    anchors.fill: parent
    fillMode: Image.Pad
    source: button.pressed ? sourceDown : (button.checked ? sourceChecked : sourceUp)
    smooth: false
  } //background: Image

  //helps to give a checkable button its correct checked state if used from outside
  property bool useButtonShouldBeChecked: false
  property bool buttonShouldBeChecked: false
  onButtonShouldBeCheckedChanged: {
    if(checkable == true) {
      if(checked != buttonShouldBeChecked) {
        checked = buttonShouldBeChecked;
      }
    }
  } //onButtonShouldBeCheckedChanged

  onCheckedChanged: {
    if(checkable == true && useButtonShouldBeChecked == true) {
      if(checked != buttonShouldBeChecked) {
        checked = buttonShouldBeChecked;
      }
    }
  } //onCheckedChanged

  onPressedChanged: {
    if (!button.pressed) {
      SoundHelper.playSound(SoundHelper.BUTTON_RELEASE);
    } else {
      SoundHelper.playSound(SoundHelper.BUTTON_PRESS);
    }
  } //onPressedChanged

  Tooltip {
    id: buttonTooltip
    enabled: (tooltipText != "") || (tooltipTextChecked != "")
    anchors.fill: parent
    text: (parent.checked && tooltipTextChecked != "") ? tooltipTextChecked : tooltipText
  } //Tooltip
} //Button
