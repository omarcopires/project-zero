import QtQuick

import qmlcomponents
import "qrc:/qt/qml/qmlcomponents/qml/"

Item {
  id: root

  property var mouseCursor: mouseCursor

  readonly property int  mouseFadeDuration:   500
  readonly property int  movementDuration:   1000
  readonly property int  mouseClickPause:     500

  TutorialMouseCursor {
    id: mouseCursor
  }

  Component {
    id: initializeAnimationComponent
    ScriptAction {
        id: root
        required property var mouseCursor
        required property var position
        required property double opacity
        required property var cursorType
        required property string text
        script: {
            mouseCursor.x = position.x;
            mouseCursor.y = position.y;
            mouseCursor.cursorOpacity = opacity;
            mouseCursor.cursorType = cursorType;
            mouseCursor.text = text;
            mouseCursor.visible = true;
        }
    }
  }

  Component {
    id: pauseAnimationComponent
    PauseAnimation {}
  }

  Component {
    id: switchCursorComponent
    ScriptAction {
      required property var mouseCursor
      required property var cursor
      script: {
        mouseCursor.cursorType = cursor;
      }
    }
  }

  Component {
    id: changeTextComponent
    ScriptAction {
      required property var mouseCursor
      property string text: ""
      script: {
        mouseCursor.text = text;
      }
    }
  }

  Component {
    id: fadeInComponent
    NumberAnimation {
      required property var mouseCursor
      target: mouseCursor
      property: "cursorOpacity"
      to: 1.0
      duration: mouseFadeDuration
    }
  }

  Component {
    id: fadeOutComponent
    NumberAnimation {
      required property var mouseCursor
      target: mouseCursor
      property: "cursorOpacity"
      to: 0.0
      duration: mouseFadeDuration
    }
  }

  Component {
    id: moveComponent
    PathAnimation {
      id: root
      required property var mouseCursor
      required property var source
      required property var destination

      property var midpoint: Qt.point((source.x + destination.x) / 2, (source.y + destination.y) / 2)

      function calculateControlPoint() {
          var midX = (source.x + destination.x) / 2;
          var midY = (source.y + destination.y) / 2;

          var length = Math.sqrt(Math.pow(destination.x - source.x, 2) + Math.pow(destination.y - source.y, 2));
          var offsetLength = length * 0.03; // 5% of complete length

          var angle = Math.atan2(destination.y - source.y, destination.x - source.x) + Math.PI / 2;

          var offsetX = Math.cos(angle) * offsetLength;
          var offsetY = Math.sin(angle) * offsetLength;

          return Qt.point(midX + offsetX, midY + offsetY);
      }

      function calculateOffset(percent) {
          var distanceX = (destination.x - source.x) * percent / 100;
          var distanceY = (destination.y - source.y) * percent / 100;
          return Qt.point(midpoint.x + distanceX, midpoint.y + distanceY);
      }

      target: mouseCursor
      duration: movementDuration
      path: Path {
        startX: Math.floor(root.source.x)
        startY: Math.floor(root.source.y)
        PathCurve {
          property var offset: calculateControlPoint(); // 10% Abweichung
          x: Math.floor(offset.x)
          y: Math.floor(offset.y)
        }
        PathCurve {
          x: Math.floor(root.destination.x)
          y: Math.floor(root.destination.y)
        }
      }
      easing.type: Easing.InOutQuad
    }
  }

  Component {
    id: scriptActionComponent
    ScriptAction {
      required property var callback
      script: {
        callback();
      }
    }
  }


  Component {
    id: animationPlaceholderPlaceholder

    SequentialAnimation {

      property var _startingPosition: Qt.point(0,0)
      property var _currentPosition: Qt.point(0,0)

      function initialize(point, opacity, cursorType, text) {

        var initializeAnimation = initializeAnimationComponent.createObject(this, {
          mouseCursor: root.mouseCursor,
          position: point,
          opacity: opacity,
          cursorType: cursorType,
          text: text
        });
        _startingPosition = point;
        _currentPosition = point;
        this.animations.push(initializeAnimation);
        return this;
      }

      function addPause(duration) {
        var pauseAnimation = pauseAnimationComponent.createObject(this, {
          duration: duration
        });
        this.animations.push(pauseAnimation);
        return this;
      }

      function switchCursor(cursor) {
        let animation = switchCursorComponent.createObject(this, {
          mouseCursor: root.mouseCursor,
          cursor: cursor
        });
        this.animations.push(animation);
        return this;
      }

      function changeText(text) {
        let animation = changeTextComponent.createObject(this, {
          mouseCursor: root.mouseCursor,
          text: text
        });
        this.animations.push(animation);
        return this;
      }

      function fadeIn() {
        let animation = fadeInComponent.createObject(this, {
          mouseCursor: root.mouseCursor
        });
        this.animations.push(animation);
        return this;
      }

      function fadeOut() {
        let animation = fadeOutComponent.createObject(this, {
          mouseCursor: root.mouseCursor
        });
        this.animations.push(animation);
        return this;
      }

      function moveTo(position) {
        let animation = moveComponent.createObject(this, {
          mouseCursor: root.mouseCursor,
          source: _currentPosition,
          destination: position
        });
        _currentPosition = position;
        this.animations.push(animation);
        return this;
      }

      function scriptAction(callback) {
        let animation = scriptActionComponent.createObject(this, {
          callback: callback
        });
        this.animations.push(animation);
        return this;
      }

      function leftButtonPress(buttonHint) {
        showHint(buttonHint);
        addPause(mouseClickPause);
        switchCursor(TutorialMouseCursor.CursorType.LEFT_BUTTON);
        return this;
      }

      function leftButtonRelease() {
        switchCursor(TutorialMouseCursor.CursorType.NO_BUTTON);
        showHint(TibiaEnums.NoHint);
        return this;
      }

      function clickPress() {
        return leftButtonPress(TibiaEnums.Click)
      }

      function clickRelease() {
        return leftButtonRelease();
      }

      function showHint(enumValue) {
        switch (enumValue) {
          case TibiaEnums.NoHint:
            changeText("");
            break;
          case TibiaEnums.Click:
            changeText(qsTrId("tutorial_mouse_cursor_click"));
            break;
          case TibiaEnums.Drag:
            changeText(qsTrId("tutorial_mouse_cursor_drag"));
            break;
          case TibiaEnums.Drop:
            changeText(qsTrId("tutorial_mouse_cursor_drop"));
            break;
          case TibiaEnums.FirstClick:
            changeText(qsTrId("tutorial_mouse_cursor_first_click"));
            break;
          case TibiaEnums.SecondClick:
            changeText(qsTrId("tutorial_mouse_cursor_second_click"));
            break;
        }
        return this;
      }

      function click() {
        clickPress();
        addPause(mouseClickPause);
        clickRelease();
        return this;
      }
    }
  }

  function createAnimation() {
    return animationPlaceholderPlaceholder.createObject(this);
  }
}
