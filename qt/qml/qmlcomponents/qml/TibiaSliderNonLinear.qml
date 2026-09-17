import QtQuick
import QtQuick.Layouts

import qmlcomponents

/*
 * Developer hints for using TibiaSliderNonLinear
 *
 * The slider hase three possible modes depending on the parameters linearUntilValue, exponentialMidpointPercent and maximumValue.
 * nonLinear:
 * If possible the slieder uses the first relativeLinearWidth area to distribute linearUntilValue linear
 * The remaining area uses a expotential distribution with its mid point at exponentialMidpointPercent*maximumValue.
 *
 * biLinear:
 * If 'nonLinear' is not possible the left part behave same as with 'nonLinear'
 * The reamaining area is also linear but distributes the values linearUntilValue up to maximumValue
 *
 * linear:
 * If 'biLinear' is no longer logical the hole slider is a linear slider from minValue to maximumValue
 *
 * Use 'shouldBeValue' to set the value of the slider
 * Read the current slider value form the read only property 'value'
 *
 * It is possible to define dynamic step sizes for different value areas
 * 'stepSizes' is an array starting with the step size for the highest values.
 * Use an empty list [] for step sizes of always 1.
 * Set 'stepSizes' like this:
 * stepSizes: [
 *   { "threshold": 2000, "stepSize": 1000 },
 *   { "threshold": 500,  "stepSize": 100 },
 *   { "threshold": 200,  "stepSize": 25 },
 *   { "threshold": 100,  "stepSize": 10 },
 *   { "threshold": 50,   "stepSize": 5 }
 * ]
 */


Column {
  id: root

  property int minimumValue: 1
  property int maximumValue: 10000
  property int linearUntilValue: 50
  property real relativeLinearWidth: 0.5
  property real exponentialMidpointPercent: 0.1

  // This signal is emitted when the "value" changes and the change was initiated by the human, e.g. by keyboard or mouse input.
  // The signal is not emitted when "value" changes due to program logic, e.g. by setting shouldBeValue.
  signal valueChangedByHuman()

  // Helps to give the slider its correct value if used from outside. The value is dynamically clamped,
  // i.e. you can set a shouldBeValue which is out-of-range and later adjust the range.
  property int shouldBeValue: minimumValue

  readonly property int value: clampValueToLimits(shouldBeValue)

  // Guard flag to prevent binding loops
  property bool _isUpdating: false

  // The step size applies to values above the threshold
  property var stepSizes: [
    { "threshold": 2000, "stepSize": 1000 },
    { "threshold": 500,  "stepSize": 100 },
    { "threshold": 200,  "stepSize": 25 },
    { "threshold": 100,  "stepSize": 10 },
    { "threshold": 50,   "stepSize": 5 }
  ] //stepSizes


  TibiaWheelHandler {
    onWheel: (event) => {
      var direction = event.angleDelta.y > 0 ? 1 : -1;
      slider.value = slider.value + direction * 0.10;
    }
  }

  readonly property real _sliderPosition: sliderPositionForValue(value)

  on_SliderPositionChanged: {
    if (!_isUpdating) {
      slider.setValueWithoutUpdatingShouldBeValue(_sliderPosition);
    }
  }

  function setShouldBeValueWithoutUpdatingSlider(newValue) {
    _isUpdating = true;
    shouldBeValue = valueForSliderPosition(newValue);
    _isUpdating = false;
  }


  function getStepSizeForValue(num) {
    var stepSize = 1;
    for (var i = 0; i < stepSizes.length; i++) {
      if (num > stepSizes[i].threshold) {
        stepSize = stepSizes[i].stepSize;
        break;
      }
    }
    return stepSize;
  } //function getStepSizeForValue

  function getNextStepSizeThresholdForValue(num) {
    var threshold = stepSizes[0].threshold;
    var thresholdFound = false;
    for (var i = 0; i < stepSizes.length; i++) {
      threshold = stepSizes[i].threshold;
      if (num > stepSizes[i].threshold) {
        thresholdFound = true;
        break;
      }
    }
    if (!thresholdFound) {
      threshold = 1;
    }
    return threshold;
  } //function getNextStepSizeThresholdForValue

  function clamp(num, min, max) {
    return Math.min(Math.max(num, min), max);
  } //function clamp

  function clampValueToLimits(num) {
    return clamp(num, minimumValue, maximumValue);
  } //function clampValueToLimits

  //https://www.delftstack.com/howto/javascript/javascript-round-to-nearest-10/
  function roundToNextMultipleOf(num, multiple) {
    return Math.round(num / multiple) * multiple;
  } //function roundToNextMultipleOf


  //https://stackoverflow.com/questions/7246622/how-to-create-a-slider-with-a-non-linear-scale
  readonly property bool _maxValuePositive: maximumValue > 0
  readonly property real _min: _maxValuePositive ? Math.max(linearUntilValue, minimumValue) : 0 //x
  readonly property real _mid: _maxValuePositive ? (_max * exponentialMidpointPercent)      : 1 //y
  readonly property real _max: _maxValuePositive ? maximumValue                             : 5 //z

  readonly property real _paramA: (_min*_max - _mid*_mid) / (_min - 2*_mid + _max);       //(xz - y^2 ) / (x - 2y + z)
  readonly property real _paramB: (_mid - _min) * (_mid - _min) / (_min - 2*_mid + _max); //(y - x)^2 / (x - 2y + z)
  readonly property real _paramC: 2 * Math.log((_max-_mid) / (_mid-_min));                //2 * log((z-y) / (y-x))

  readonly property string _mode: {
    if (_mid > 2*linearUntilValue) {
      return "nonLinear";
    } else if (maximumValue > 2 * linearUntilValue) {
      return "biLinear";
    } else {
      return "linear";
    }
  } //readonly property string _mode

  function valueForSliderPosition(position) {
      var rightSliderPartNormalized = (position - relativeLinearWidth) / (1 - relativeLinearWidth)
      var expPart = _paramA + _paramB * Math.exp(_paramC * rightSliderPartNormalized);

      var linearLeftPart  = minimumValue + (linearUntilValue - minimumValue) * position / (relativeLinearWidth > 0 ? relativeLinearWidth : 1)
      var linearRightPart = linearUntilValue + (maximumValue - linearUntilValue) * rightSliderPartNormalized

      //console.log("DisplayValue:", position, "=>", linearLeftPart, linearRightPart, "exp", rightSliderPartNormalized, "=>", expPart);

      var retValue = linearLeftPart;

      if (_mode == "nonLinear") {
        retValue = position < relativeLinearWidth ? linearLeftPart : expPart;
      } else if (_mode == "biLinear") {
        retValue = position < relativeLinearWidth ? linearLeftPart : linearRightPart
      } else {
        retValue = minimumValue + position * (maximumValue - minimumValue);
      }

      // If the slider is at its rightmost position, its value will often be
      // reported as 0.999~. By rounding it off at 10 digits, it will instead be
      // considered 1.0 and properly return the maximum slider value.
      const sliderValueRoundedWithHighPrecision = parseFloat(position.toFixed(10))
      if (0.0 < position && sliderValueRoundedWithHighPrecision < 1.0) {
        retValue = roundToNextMultipleOf(retValue,
                                         getStepSizeForValue(retValue));
      }

      return Math.round(retValue);
  } //function valueForSliderPosition

  function sliderPositionForValue(num) {
    if (maximumValue == minimumValue) {
      return 0; // avoid division by zero below
    }
    var expPart = Math.log((num - _paramA) / _paramB) / _paramC;
    var logSliderValue = expPart * (1 - relativeLinearWidth) + relativeLinearWidth

    var linearSliderLeft = (num - minimumValue) * relativeLinearWidth / (linearUntilValue - minimumValue)
    var linearSliderRight = relativeLinearWidth + (num - linearUntilValue) / (maximumValue - linearUntilValue) * (1 - relativeLinearWidth)

    //console.log("SliderPosition:", num, "=>", linearSliderLeft, linearSliderRight, "exp", expPart, "=>", logSliderValue);

    var retValue = linearSliderLeft;

    if (_mode == "nonLinear") {
      retValue = num < linearUntilValue ? linearSliderLeft : logSliderValue
    } else if (_mode == "biLinear") {
      retValue = num < linearUntilValue ? linearSliderLeft : linearSliderRight
    } else {
      retValue = (num - minimumValue) /(maximumValue - minimumValue);
    }

    return clamp(retValue, slider.minimumValue, slider.maximumValue); // clamp is important for the case that slider.maximumValue==0
  } //function sliderPositionForValue


  function leftRightPressed(modifiers, plus) {
    var newValue = value;
    var oldValue = value;
    var direction = +1;
    if (!plus) {
      direction = -1;
    }

    if (modifiers != Qt.NoModifier) {
      // why does this branch not consider getStepSizeForValue ??
      var stepSize = 1;
      if (modifiers & Qt.ShiftModifier) {
        stepSize *= TibiaStyle.sliderModifierShift
      }
      if (modifiers & Qt.ControlModifier ) {
        stepSize *= TibiaStyle.sliderModifierControl
      }
      newValue = newValue + direction * stepSize;
    } else {
      var stepSize = getStepSizeForValue(direction > 0 ? oldValue+1 : oldValue);
      newValue = oldValue + direction * stepSize;

      var oldThreshold = getNextStepSizeThresholdForValue(oldValue);
      var newThreshold = getNextStepSizeThresholdForValue(newValue);

      if (direction < 0 && oldThreshold > newThreshold) {
        newValue = oldThreshold;
      } else {
        newValue = roundToNextMultipleOf(newValue,
                                         getStepSizeForValue(newValue));
      }
    }
    newValue = clampValueToLimits(newValue);
    shouldBeValue = newValue;
    root.valueChangedByHuman()
  } //function leftRightPressed

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

      property bool _isUpdating: false

      function setValueWithoutUpdatingShouldBeValue(newValue) {
        _isUpdating = true;         
        value = newValue;
        _isUpdating = false;
      }

      //slider range is 0-1. 0 does not need to be included to allow minimum values other than 0
      minimumValue: 0
      readonly property real _maximumValue: root.maximumValue > root.minimumValue && root._maxValuePositive ? 1 : 0
      on_MaximumValueChanged: {
        // prevent updating the "shouldBeValue" if "value" gets clamped
        _isUpdating = true;
        maximumValue = _maximumValue;
        _isUpdating = false;
      }
      stepSize: root._maxValuePositive ? slider.maximumValue / root.maximumValue : 1

      value: 0

      // User interaction
      onValueChanged: {
        if (!_isUpdating) {
          root.setShouldBeValueWithoutUpdatingSlider(slider.value);
          root.valueChangedByHuman()
        }
      }

      Component.onCompleted: {
        _maximumValueChanged();
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
