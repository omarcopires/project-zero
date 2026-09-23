import QtQuick
import QtQuick.Layouts

import qmlcomponents


TibiaIconButton {
  property QtObject buttonController: panelController != null ? panelController.newsButtonController : null
  highlighted: buttonController != null && buttonController.highlighted

  sourceUp:   "/images/button-news-up.png"
  sourceDown: "/images/button-news-down.png"
  tooltipText: qsTrId("buttonbar_news_open_tooltip")

  onClicked: {
    if (buttonController != null) {
      buttonController.onOpenNewsButtonClicked();
    }
  } //onClicked

  TibiaRectangleHighlight {
    visible: highlighted
  } //TibiaRectangleHighlight

  Image {
    id: buttonHighlight
    anchors.fill: parent
    visible: highlighted
    SequentialAnimation {
      running: highlighted
      loops: Animation.Infinite
      alwaysRunToEnd: true
      SequentialAnimation{
        loops: 3
        alwaysRunToEnd: true
        PropertyAnimation { target: buttonHighlight; property: "source"; to: "image://store-button-animation/0"; duration: 1000 } //wait 1sec
        PropertyAnimation { target: buttonHighlight; property: "source"; to: "image://store-button-animation/1"; duration: 50 }
        PropertyAnimation { target: buttonHighlight; property: "source"; to: "image://store-button-animation/2"; duration: 50 }
        PropertyAnimation { target: buttonHighlight; property: "source"; to: "image://store-button-animation/3"; duration: 50 }
        PropertyAnimation { target: buttonHighlight; property: "source"; to: "image://store-button-animation/4"; duration: 20 }
        PropertyAnimation { target: buttonHighlight; property: "source"; to: "image://store-button-animation/5"; duration: 20 }
        PropertyAnimation { target: buttonHighlight; property: "source"; to: "image://store-button-animation/6"; duration: 20 }
        PropertyAnimation { target: buttonHighlight; property: "source"; to: "image://store-button-animation/7"; duration: 20 }
        PropertyAnimation { target: buttonHighlight; property: "source"; to: "image://store-button-animation/8"; duration: 20 }
        PropertyAnimation { target: buttonHighlight; property: "source"; to: "image://store-button-animation/9"; duration: 20 }
        PropertyAnimation { target: buttonHighlight; property: "source"; to: ""; duration: 50 }
      } //SequentialAnimation
      PropertyAnimation { target: buttonHighlight; property: "source"; to: ""; duration: 2000 } //wait 2sec
    } //SequentialAnimation
  } //Image
} //TibiaIconButton
