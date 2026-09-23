import QtQuick

import qmlcomponents

Image {
  id: buttonHighlight
  property bool running: false
  property double animationSpeedFactor: 1.0
  property int highlightLoops: 3
  property int pauseBetweenLoops: 30000
  property int pauseBetweenHighlights: 5000

  smooth: true
  visible: running

  SequentialAnimation {
    running: buttonHighlight.running
    loops: Animation.Infinite
    alwaysRunToEnd: true

    SequentialAnimation{
      id: frameAnimation
      property int frameIndex: -1

      loops: highlightLoops
      alwaysRunToEnd: true

      onFrameIndexChanged: {
        if (frameIndex >= 0) {
          buttonHighlight.source = `image://store-button-animation/${frameAnimation.frameIndex}`;
        } else {
          buttonHighlight.source = "";
        }
      }

      PropertyAction { target: frameAnimation; property: "frameIndex"; value: 0}    PauseAnimation { duration: 50 * animationSpeedFactor }
      PropertyAction { target: frameAnimation; property: "frameIndex"; value: 1}    PauseAnimation { duration: 50 * animationSpeedFactor }
      PropertyAction { target: frameAnimation; property: "frameIndex"; value: 2}    PauseAnimation { duration: 50 * animationSpeedFactor }
      PropertyAction { target: frameAnimation; property: "frameIndex"; value: 3}    PauseAnimation { duration: 20 * animationSpeedFactor }
      PropertyAction { target: frameAnimation; property: "frameIndex"; value: 4}    PauseAnimation { duration: 20 * animationSpeedFactor }
      PropertyAction { target: frameAnimation; property: "frameIndex"; value: 5}    PauseAnimation { duration: 20 * animationSpeedFactor }
      PropertyAction { target: frameAnimation; property: "frameIndex"; value: 6}    PauseAnimation { duration: 20 * animationSpeedFactor }
      PropertyAction { target: frameAnimation; property: "frameIndex"; value: 7}    PauseAnimation { duration: 20 * animationSpeedFactor }
      PropertyAction { target: frameAnimation; property: "frameIndex"; value: 8}    PauseAnimation { duration: 20 * animationSpeedFactor }
      PropertyAction { target: frameAnimation; property: "frameIndex"; value: 9}    PauseAnimation { duration: 20 * animationSpeedFactor }
      PropertyAction { target: frameAnimation; property: "frameIndex"; value: -1}   PauseAnimation { duration: 20 * animationSpeedFactor }
      
      PauseAnimation { duration: pauseBetweenHighlights }
    } //SequentialAnimation
    PauseAnimation { duration: pauseBetweenLoops }
  } //SequentialAnimation
} //Image
