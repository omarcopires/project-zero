import QtQuick
import QtQuick.Layouts
import qmlcomponents



BorderImage {
  id: root

  readonly property int pillArchWidth: 5
  readonly property int arrowSlideWidth: width - 2 * pillArchWidth
  border { left: pillArchWidth; top: 0; right: pillArchWidth; bottom: 0 }
  horizontalTileMode: BorderImage.Stretch
  source: "/images/gauge.png"
  smooth: false

  //values that can be set
  property real targetValue: 0.0
  property string targetValueString: "0"
  property real currentValue: 1.0
  property string currentValueString: "1"
  property real maxDeviationPercentage: 0.5
  
  //values to calculate the arrow position
  readonly property real deviationValue: Math.max(0.01, targetValue * maxDeviationPercentage) //minimum value just to avoid devision by zero
  readonly property real deviationPercentage: Math.min(Math.max(-1.0, (currentValue - targetValue) / deviationValue), 1.0)

  function toFixed(Value, Precision) {
    var Power = Math.pow(10, Precision || 0);
    return String(Math.round(Value * Power) / Power);
  }

  Rectangle {
    anchors.centerIn: root
    width: 1
    height: root.height
    color: TibiaStyle.black1
  } //Rectangle

  Image {
    id: gaugeArrow
    smooth: false
    anchors.bottom: root.bottom
    source: "/images/gauge-arrow.png"
    readonly property int middlePos: root.pillArchWidth + root.arrowSlideWidth * 0.5 - width * 0.5
    readonly property int arrowMoveRange: Math.floor(root.arrowSlideWidth * 0.5)

    //arrow should never be aligned with the left or right side of the gauge
    //to prevent this for even width gauges the minimum value was introduced
    x: Math.max(1, Math.floor(middlePos + root.deviationPercentage * arrowMoveRange)) 
  } //Image

  Tooltip {
    anchors.fill: parent
    //see texthelper.cpp:15 and http://doc.qt.io/qt-5/qml-qtquick-text.html#elide-prop
    text: qsTrId("gauge_tooltip").arg(currentValueString.split("\x9C")[0])
                                 .arg(targetValueString.split("\x9C")[0])
  }
} //BorderImage
