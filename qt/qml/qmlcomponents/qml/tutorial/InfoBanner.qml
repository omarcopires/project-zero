import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import qmlcomponents
import "qrc:/qt/qml/qmlcomponents/qml"

Item {
  id: root

  property alias caption: infoBannerAnimation.caption
  property alias text: infoBannerAnimation.text
  property alias iconData: infoBannerAnimation.iconData
  property int duration: 0
  readonly property int _ANIMATION_TIME: 570
  readonly property int _FADE_TIME: 150

  readonly property int _CLOSED_WIDTH: 70

  signal finished()

  function openBanner() {
    root.state = "open";
  }
  function closeBanner() {
    durationTimer.stop();
    root.state = "closed";
  }

  implicitWidth: infoBannerAnimation.width
  implicitHeight: infoBannerAnimation.height

  InfoBannerAnimation {
    id: infoBannerAnimation
    opacity: 0.0
  }

  Timer {
    id: durationTimer
    interval: root.duration
    repeat: false
    onTriggered: {
      root.closeBanner();
    }
  }

  state: "closed"

  states: [
    State {
      name: "open"
      PropertyChanges {
        target: infoBannerAnimation
        animationPercent: 100
      }
      PropertyChanges {
        target: infoBannerAnimation
        opacity: 1.0
      }
    },
    State {
      name: "closed"
      PropertyChanges {
        target: infoBannerAnimation
        animationPercent: 0
      }
      PropertyChanges {
        target: infoBannerAnimation
        opacity: 0.0
      }
    }
  ]
  transitions: [
    Transition {
      from: "closed"
      to: "open"
      SequentialAnimation {
        NumberAnimation {
          target: infoBannerAnimation
          properties: "opacity"
          duration: root._FADE_TIME;
        }
        NumberAnimation {
          target: infoBannerAnimation
          properties: "animationPercent"
          duration: root._ANIMATION_TIME;
          easing.type: Easing.OutQuad
        }
        ScriptAction {
          script: {
            durationTimer.start();
          }
        }
      }
    },
    Transition {
      from: "open"
      to: "closed"
      SequentialAnimation {

        NumberAnimation {
          target: infoBannerAnimation
          properties: "animationPercent"
          duration: root._ANIMATION_TIME;
          easing.type: Easing.OutQuad
        }
        NumberAnimation {
          target: infoBannerAnimation
          properties: "opacity"
          duration: root._FADE_TIME;
        }
        ScriptAction {
          script: {
            root.finished();
          }
        }
      }
    }
  ]
}
