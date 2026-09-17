import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import qmlcomponents
import "qrc:/qt/qml/qmlcomponents/qml"

Item {
  id: root

  // the animation works the following way:
  // the frame 1 will be shown for 100ms. The backdrop will not be resized
  // then the frame 2 to 6 will be 

  property string caption: ""
  property string text: ""
  property int animationPercent: 0
  property var iconData: { }
  property int referenceTimestamp: _REFERENCE_ANIMATION_DURATION_MS * (animationPercent / 100.0)
  readonly property int backdropWidth: backdropWrapper.width

  property int rightBorderCurrentFrame: 0
  property int currentBackdropWidth: 0

  readonly property int _REFERENCE_ANIMATION_DURATION_MS: 570
  readonly property int _BACKDROP_GROWTH_START_MS: 300
  readonly property int _BACKDROP_GROWTH_STOP_MS: 560
  readonly property int _CLOSED_WIDTH: 76
  readonly property int _NEARLY_OPENED_WIDTH: 273
  readonly property int _OPENED_WIDTH: bannerBackdrop.width

  function calculateRightBorderFrame() {
    if (root.referenceTimestamp == 0) {
      root.rightBorderCurrentFrame = 0;
    } else if (root.referenceTimestamp < root._BACKDROP_GROWTH_START_MS) {
      root.rightBorderCurrentFrame = 1;
    } else if (root.backdropWidth < 176) {
      root.rightBorderCurrentFrame = 2;
    } else if (root.backdropWidth < 210) {
      root.rightBorderCurrentFrame = 3;
    } else if (root.backdropWidth < 229) {
      root.rightBorderCurrentFrame = 4;
    } else if (root.backdropWidth < 254) {
      root.rightBorderCurrentFrame = 5;
    } else if (root.referenceTimestamp < root._BACKDROP_GROWTH_STOP_MS) {
      root.rightBorderCurrentFrame = 6;
    } else if (root.referenceTimestamp < 570) {
      root.rightBorderCurrentFrame = 7;
    } else {
      root.rightBorderCurrentFrame = -1;
    }
  }

  function calculateBackdropWidth() {
    if (root.referenceTimestamp <= _BACKDROP_GROWTH_START_MS) {
      root.currentBackdropWidth = root._CLOSED_WIDTH;
    } else if (root.referenceTimestamp <= _BACKDROP_GROWTH_STOP_MS) {
      const animationTime = _BACKDROP_GROWTH_STOP_MS - _BACKDROP_GROWTH_START_MS;
      const distance = _NEARLY_OPENED_WIDTH - _CLOSED_WIDTH;
      root.currentBackdropWidth = _CLOSED_WIDTH + distance * ((root.referenceTimestamp - _BACKDROP_GROWTH_START_MS) / animationTime)
    } else if (root.referenceTimestamp < _REFERENCE_ANIMATION_DURATION_MS) {
      root.currentBackdropWidth = root._NEARLY_OPENED_WIDTH;
    } else {
      root.currentBackdropWidth = root._OPENED_WIDTH;
    }
  }

  Component.onCompleted: {
    calculateBackdropWidth();
    calculateRightBorderFrame();
  }

  onAnimationPercentChanged: {
    Qt.callLater( () => {
      // call later so that the reference timestamp was correctly calculated
      calculateBackdropWidth();
      calculateRightBorderFrame();
    });
  }

  implicitWidth: bannerBackdrop.width 
  implicitHeight: bannerBackdrop.height

  Item {
    id: bannerWrapper
    implicitWidth: bannerBackdrop.width
    implicitHeight: bannerBackdrop.height

    Item {
      id: backdropWrapper
      height: bannerBackdrop.height
      width: root.currentBackdropWidth
      clip: true
      Image {
        id: bannerBackdrop
        source: "qrc:/images/tutorial/backdrop-infobanner-bottom.png"
      }
      Image {
        x: 111
        y: 6
        source: "qrc:/images/tutorial/backdrop-infobanner-ornaments.png"
      }
      TibiaText {
        x: 77
        y: 14
        width: 272 - x
        height: 32 - y
        text: root.caption
        font: TibiaStyle.infoBannerCaptionFont
        horizontalAlignment: Text.AlignHCenter
        color: "#ffe1b5"
        antialiasing: true
      }
      TibiaText {
        x: 77
        y: 44
        width: 273 - x
        horizontalAlignment: Text.AlignHCenter
        text: root.text
        wrapMode: Text.Wrap
        elide: Text.ElideRight
        maximumLineCount: 2
      }
    }
    InfoBannerIcon {
      x: 3
      y: -17
      iconData: root.iconData
    }
    Image {
      id: rightBorderImage
      anchors.left: backdropWrapper.right
      anchors.bottom: backdropWrapper.bottom
      anchors.leftMargin: {
        if (root.rightBorderCurrentFrame < 2) {
          return -7;
        } else if (root.rightBorderCurrentFrame == 6) {
          return 0;
        } else {
          return -6;
        }
      }
      anchors.bottomMargin: 1
      source: {
        if (root.rightBorderCurrentFrame >= 0) {
          return `qrc:/images/tutorial/backdrop-infobanner-anim${root.rightBorderCurrentFrame}.png`;
        } else {
          return "";
        }
      }
    }
    Image {
      x: 0
      y: -6
      source: "qrc:/images/tutorial/backdrop-infobanner-mid.png"
    }
    Image {
      x: 47
      y: 44
      source: "qrc:/images/tutorial/backdrop-infobanner-top.png"
    }
  }
  MultiEffect {
    visible: true
    anchors.fill: bannerWrapper
    source: bannerWrapper
    shadowEnabled: true
    shadowHorizontalOffset: 8
    shadowVerticalOffset: 8
    shadowBlur: 0
    opacity: 0.33
    z: -1
  }

}
