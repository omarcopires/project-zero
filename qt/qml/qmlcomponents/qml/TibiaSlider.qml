import QtQuick
import QtQuick.Layouts

import qmlcomponents

Column {
  id: root

  property alias minimumValue:       slider.from
  property alias maximumValue:       slider.to
  property alias stepSize:           slider.stepSize
  property alias value:              slider.value
  property bool roundValue:          true

  //helps to give the slider its correct value if used from outside
  property int shouldBeValue: 0
  onShouldBeValueChanged: {
    if (value != shouldBeValue) {
      value = shouldBeValue;
    }
  } //onButtonShouldBeCheckedChanged

  TibiaWheelHandler {
    onWheel: (event) => {
      let direction = event.angleDelta.y > 0 ? 1 : -1;
      let multipleOf15Degrees = Math.abs(event.angleDelta.y / 8) / 15; // 15 degrees is the normal value for a wheel turn
      let wheelModifier = ((maximumValue - minimumValue) / 100.0) * 10.0 * direction * multipleOf15Degrees;
      if (root.stepSize != 1) {
        wheelModifier = Math.ceil(wheelModifier / root.stepSize) * root.stepSize
      }
      value = value + wheelModifier
    }
  }

  function leftRightPressed(modifiers, plus) {
    var factor = 1;

    if (modifiers & Qt.ShiftModifier) {
      factor *= TibiaStyle.sliderModifierShift;
    }
    if (modifiers & Qt.ControlModifier ) {
      factor *= TibiaStyle.sliderModifierControl;
    }

    if (plus) {
      value += factor * stepSize;
    } else {
      value -= factor * stepSize;
    }
  } //function leftRightPressed(mouse, plus)

  RowLayout {
    anchors { left: parent.left; right:parent.right; }
    spacing: 0

    TibiaAutorepeatIconButton {
      tooltipText: qsTrId("slider_button_tooltip")
      sourceUp: "/images/skin/classic/slider-buttonleft-up.png"
      sourceDown: "/images/skin/classic/slider-buttonleft-down.png"
      triggerFunction: (mouse) => leftRightPressed(mouse?.modifiers ?? Qt.NoModifier, false);
    } //TibiaAutorepeatIconButton

    TibiaStyledSlider {
      id: slider
      Layout.fillWidth: true
      Layout.preferredHeight: implicitHeight
      onValueChanged: {
        if (root.roundValue) {
          var newValue = parseInt(value + 0.5);
          if (value != newValue) {
            value = newValue;
          }
        }
      }

      Keys.onLeftPressed: (event) => {
        root.leftRightPressed(event.modifiers, false)
        event.accepted = true
      }

      Keys.onRightPressed: (event) => {
        root.leftRightPressed(event.modifiers, true)
        event.accepted = true
      }
    } //TibiaStyledSlider

    TibiaAutorepeatIconButton {
      tooltipText: qsTrId("slider_button_tooltip")
      sourceUp: "/images/skin/classic/slider-buttonright-up.png"
      sourceDown: "/images/skin/classic/slider-buttonright-down.png"
      triggerFunction: (mouse) => leftRightPressed(mouse?.modifiers ?? Qt.NoModifier, true);
    } //TibiaAutorepeatIconButton
  } //RowLayout
} //Column
