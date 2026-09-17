import QtQuick

import qmlcomponents
import "qrc:/qt/qml/qmlcomponents/qml/"

Item {
  id: root
  property point sourcePoint: Qt.point(0,0)
  property point destinationPoint: Qt.point(0,0)
  property string animationType: "none"

  z: 9999

  onAnimationTypeChanged: {
    restartAnimation();
  } //onAnimationTypeChanged

  onSourcePointChanged: {
    restartAnimation();
  } //onSourcePointChanged

  onDestinationPointChanged: {
    restartAnimation();
  } //onDestinationPointChanged

  TutorialMouseCursorAnimation {
    id: animationTemplate
    visible: false
  }

  SequentialAnimation {
    id: animationPlaceholder
    loops: Animation.Infinite
  }

  function restartAnimation() {
    animationPlaceholder.stop();
    animationTemplate.visible = false;
    if (animationType == "draganddrop") {
      createDragAndDropAnimation();
    } else if (animationType == "multiuse") {
      createMultiuseAnimation();
    }
  }

  function createDragAndDropAnimation() {
    animationPlaceholder.animations = [
      animationTemplate.createAnimation()
        .initialize(root.sourcePoint, 0.0, TutorialMouseCursor.CursorType.NO_BUTTON, "")
        .scriptAction( () =>  {
          animationTemplate.visible = true;
        })
        .fadeIn()
        .leftButtonPress(TibiaEnums.Drag)
        .addPause(animationTemplate.mouseClickPause)
        .moveTo(root.destinationPoint)
        .addPause(animationTemplate.mouseClickPause)
        .showHint(TibiaEnums.Drop)
        .addPause(animationTemplate.mouseClickPause)
        .leftButtonRelease()
        .addPause(animationTemplate.mouseClickPause)
        .fadeOut()
        .addPause(1000)
    ];

    animationPlaceholder.running = true;
  }

  function createMultiuseAnimation() {
    animationPlaceholder.animations = [
      animationTemplate.createAnimation()
        .initialize(sourcePoint, 0.0, TutorialMouseCursor.CursorType.NO_BUTTON, "")
        .scriptAction( () =>  {
          animationTemplate.visible = true;
        })
        .fadeIn()
        .leftButtonPress(TibiaEnums.FirstClick)
        .addPause(animationTemplate.mouseClickPause)
        .leftButtonRelease()
        .addPause(animationTemplate.mouseClickPause)
        .fadeOut()
        .moveTo(destinationPoint)
        .fadeIn()
        .leftButtonPress(TibiaEnums.SecondClick)
        .addPause(animationTemplate.mouseClickPause)
        .leftButtonRelease()
        .addPause(animationTemplate.mouseClickPause)
        .fadeOut()
        .leftButtonRelease()
        .addPause(1000)
    ];

    animationPlaceholder.running = true;
  }
}

