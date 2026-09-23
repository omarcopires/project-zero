import QtQuick
import QtQuick.Layouts
import qmlcomponents



Item {
  id: root

  /////////////////////////////////////////////////////////
  //properties to manipulate the progress
  property alias model: progressRepeater.model
  property int maximumProgress: model != null
    ? thresholdForSegment(segmentCount - 1)
    : 0
  property string thresholdRole: "maxValue"
  property int thresholdRoleIndex: -1
  property int maxSegmentCount: segmentCount
  property int totalProgress: 0

  /////////////////////////////////////////////////////////
  //properties to change appearance
  property alias spacing: progressLayout.spacing
  property int barHeight: TibiaStyle.progressBarLargeHeight
  property url frameSource: "/images/1pixel-down-frame.png"
  property int frameWidth: 1
  property url backgroundSource: "/images/backdrop-dark-grey.png"
  property url fillSourceInProgress: "/images/progressbar-orange-large.png"
  property url fillSourceFull: "/images/progressbar-green-large.png"

  property bool isFullyUnlocked: totalProgress >= maximumProgress
  property int segmentWidth: Math.floor((width - spacing*(maxSegmentCount-1)) / maxSegmentCount)

  /////////////////////////////////////////////////////////
  //properties for information
  readonly property alias segmentCount: progressRepeater.count
  readonly property int remainingWidth: width - (segmentCount * segmentWidth + (segmentCount -1) * spacing)
  readonly property bool hasFillerElement: root.maxSegmentCount > root.segmentCount
  readonly property url barFillSource: isFullyUnlocked
    ? fillSourceFull
    : fillSourceInProgress

  height: barHeight
  implicitHeight: barHeight
  Layout.preferredHeight: barHeight
  Layout.fillHeight: false

  /////////////////////////////////////////////////////////
  // user provided functions and components

  // the function has one paramter with the following members:
  // index, min, max, remaining,range, progress, fillPercentage, totalProgress, isFullyUnlocked
  // the delegate can bind to a property segmentInfo which has the same properties
  property var segmentTooltipFunction: null
  property Component segmentDecorationDelegate: null

  /////////////////////////////////////////////////////////
  //functions
  function calculateFillPercentage(maximum: int, current: int) : real {
    if (!isFullyUnlocked) {
      let maximumValue = Math.max(maximum, 1.0);
      let currentValue = Math.min(Math.max(current, 0.0), maximumValue);
      return currentValue / maximumValue;
    } else {
      return 1.0;
    }
  } //function calculateFillPercentage

  function thresholdForSegment(index: int) : int {
    if (model != null &&  0 <= index && index < segmentCount) {
      if (   (typeof model.index === "function")
          && (typeof model.data === "function")
          && root.thresholdRoleIndex >= 0) {
        let idx = model.index(index, 0);
        return model.data(idx, root.thresholdRoleIndex);
      } else if (typeof model.get === "function") {
        return model.get(index)[root.thresholdRole];
      } else {
        return model[index][root.thresholdRole];
      }
    }
    return 0;
  } //function thresholdForSegment

  function fillPercentageForSegment(index: int) : real {
    if (model != null &&  0 <= index && index < segmentCount) {
      return progressRepeater.itemAt(index).fillPercentage
    }
    return 0.0
  } //  function fillPercentageForSegment

  /////////////////////////////////////////////////////////
  //QML Layout
  RowLayout {
    id: progressLayout
    spacing: 0
    anchors.fill: parent

    Repeater {
      id: progressRepeater
      model: null

      delegate: TibiaProgressBar {
        id: segmentDelegate

        required property var model
        required property int index

        Layout.fillHeight: true
        Layout.preferredWidth: root.segmentWidth
          //last element gets extra space
          + (!root.hasFillerElement && index == (root.segmentCount - 1) ? root.remainingWidth : 0)

        QtObject {
          id: segmentInfo
          readonly property alias index: segmentDelegate.index
          readonly property int min: index > 0
            ? root.thresholdForSegment(index - 1)
            : 0
          readonly property int max: root.thresholdForSegment(index)
          readonly property int remaining: max > totalProgress
            ? max - root.totalProgress
            : 0
          readonly property int range: max - min
          readonly property int progress: totalProgress - min
          readonly property real fillPercentage: root.calculateFillPercentage(
            range,
            progress
          )
          readonly property bool unlocked: fillPercentage >= 1.0
          readonly property int totalProgress: root.totalProgress //TibiaProgressBarSegmented.qml:143 Invalid alias reference. Unable to find id "root"
          readonly property int isFullyUnlocked: root.isFullyUnlocked
        } //QtObject segmentInfo

        fillPercentage: segmentInfo.fillPercentage

        frameSource: root.frameSource
        backgroundSource: root.backgroundSource
        fillSource: root.barFillSource

        frameBorder { left: root.frameWidth; right: root.frameWidth; top: root.frameWidth; bottom: root.frameWidth }
        fillOffset { left: root.frameWidth; right: root.frameWidth; top: root.frameWidth; bottom: root.frameWidth }

        Loader {
          id: tooltipLoader
          anchors.fill: parent
          active: root.segmentTooltipFunction != null
          sourceComponent: Tooltip {
            text: root.segmentTooltipFunction(segmentInfo)
          } //sourceComponent: Tooltip
        } //Loader

        Loader {
          id: decorationLoader
          anchors.fill: parent
          active: root.segmentDecorationDelegate != null
          sourceComponent: root.segmentDecorationDelegate

          onLoaded: {
            if (typeof item.segmentInfo !== 'undefined') {
              item.segmentInfo = Qt.binding(function() { return segmentInfo; });
            }
          } //onLoaded
        } //Loader
      } //delegate: TibiaProgressBar
    } //Repeater

    TibiaProgressBar {
      id: fillerProgressBar
      Layout.fillHeight: true
      Layout.fillWidth:true

      visible: root.hasFillerElement

      frameSource: root.frameSource
      backgroundSource: root.backgroundSource
      fillSource: root.barFillSource

      frameBorder { left: root.frameWidth; right: root.frameWidth; top: root.frameWidth; bottom: root.frameWidth }
      fillOffset { left: root.frameWidth; right: root.frameWidth; top: root.frameWidth; bottom: root.frameWidth }
    } //TibiaProgressBar
  } // RowLayout
} // Item
