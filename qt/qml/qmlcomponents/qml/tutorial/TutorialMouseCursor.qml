import QtQuick

import "qrc:/qt/qml/qmlcomponents/qml/"

Rectangle {
  id: root
  implicitWidth: cursorLayout.width
  implicitHeight: cursorLayout.height

  property var cursorType: TutorialMouseCursor.CursorType.NO_BUTTON;
  property alias text: mouseText.text
  property alias cursorOpacity: mouseImage.opacity
  property alias textOpacity: mouseText.opacity

  property point _mouseHotspotOffset: Qt.point(-10, -9)

  enum CursorType {
      NO_BUTTON,
      LEFT_BUTTON,
      TARGET_NO_BUTTON,
      TARGET_LEFT_BUTTON
  }

  onCursorTypeChanged: {
    mouseImage.source = cursorTypeImage(root.cursorType);
  }

  function cursorTypeImage(cursorType) {
    switch (cursorType) {
      case TutorialMouseCursor.CursorType.NO_BUTTON:           return "image://tutorial-mouse-hint-icons/2";
      case TutorialMouseCursor.CursorType.LEFT_BUTTON:         return "image://tutorial-mouse-hint-icons/3";
      case TutorialMouseCursor.CursorType.TARGET_NO_BUTTON:    return "image://tutorial-mouse-hint-icons/0";
      case TutorialMouseCursor.CursorType.TARGET_LEFT_BUTTON:  return "image://tutorial-mouse-hint-icons/1";
    }
    return "";
  }

  Item {
    id: cursorLayout
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.leftMargin: -10
    anchors.topMargin: -9
    Image {
      id: mouseImage
    } // Image
    TibiaText {
      id: mouseText
      anchors.top: mouseImage.bottom
      anchors.horizontalCenter: mouseImage.horizontalCenter
      style: Text.Outline
      styleColor: TibiaStyle.lenshelpCaptionOutlineColor
      opacity: mouseImage.opacity
      text: "click"
    }
  }

  Component {
    id: pauseAnimation
    PauseAnimation { }
  }

  component CursorAnimationBase : SequentialAnimation {
    id: baseAnimation

    required property var mouseCursor
//    default property alias contents: placeholderAnimation.children
    property var pauseBefore: undefined
    property var pauseAfter: undefined

    // Component.onCompleted: {
    //   if (pauseBefore) {
    //     var newPauseAnimation = pauseAnimation.createObject(this);
    //     newPauseAnimation.duration = pauseBefore;
    //     baseAnimation.animations.unshift(newPauseAnimation);
    //   }
    //   if (pauseAfter) {
    //     var newPauseAnimation = pauseAnimation.createObject(this);
    //     newPauseAnimation.duration = pauseAfter;
    //     baseAnimation.animations.push(newPauseAnimation);
    //   }
    // }
  }

  component CursorAnimationInitialize: CursorAnimationBase {
    property int x: 0
    property int y: 0
    property double opacity: 0.0
    property var cursorType: TutorialMouseCursor.CursorType.NO_BUTTON
    property string text: ""
    ScriptAction {
      script: {
          mouseCursor.x = x;
          mouseCursor.y = y;
          mouseCursor.cursorOpacity = opacity;
          mouseCursor.cursorType = cursorType;
          mouseCursor.text = text;
      }
    }
  }

  component CursorAnimationSwitchCursorType : CursorAnimationBase {
    property var cursorTypeBefore: TutorialMouseCursor.CursorType.NO_BUTTON
    property var cursorTypeAfter: TutorialMouseCursor.CursorType.NO_BUTTON
    property var textBefore: undefined
    property var textAfter: undefined
    ScriptAction { script: {
      mouseCursor.cursorType = cursorTypeBefore;
      if (textBefore) {
        mouseCursor.text = textBefore;
      }
    }}
    ScriptAction { script: {
      mouseCursor.cursorType = cursorTypeAfter;
      if (textAfter) {
        mouseCursor.text = textAfter;
      }
    }}
  }
}
