import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml
import QtQuick.Templates as T

import qmlcomponents

T.ScrollView {
  id: control

  property alias horizontalScrollBarPolicy: horizontalScrollbar.policy
  property alias verticalScrollBarPolicy: verticalScrollbar.policy

  readonly property int needRightPadding: verticalScrollbar.visible ? TibiaStyle.scrollBarWidth : 0
  readonly property int needBottomPadding: horizontalScrollbar.visible ? TibiaStyle.scrollBarWidth : 0

  // make sure the content does not go under the scroll bar in most cases
  rightPadding: needRightPadding
  rightInset : rightPadding
  bottomPadding: needBottomPadding
  bottomInset : rightPadding

  // in earlier versions of QtQuick ScrollView did clip there content now we need to do this explicitly
  clip: true

  // enable mouse wheel scrolling only when horizontal scrollbar is visible
  // it enables to use alt+mousewheel since the WheelHandler doesnt work with the AltModifier
  wheelEnabled: horizontalScrollbar.visible

  component TibiaScrollViewFlickHelper: TibiaWheelHandler {
    property var contentItem: null
    property var lastWheelEventTimestamp: 0

    onWheel: (event) => {
      var defaultOffset = 1;
      var currentDateMilliseconds = Date.now();
      if (currentDateMilliseconds < lastWheelEventTimestamp + 20) {
        defaultOffset = 3;
      } else if (currentDateMilliseconds < lastWheelEventTimestamp + 50) {
        defaultOffset = 2;
      }
      lastWheelEventTimestamp = currentDateMilliseconds;

      var defaultScrollbar = verticalScrollbar;
      if ((horizontalScrollbar.visible && !verticalScrollbar.visible) && ((event.modifiers & Qt.NoModifier) == Qt.NoModifier)) {
        // move the horizontal scrollbar with angleDelta.y if only this scrollbar is visible
        moveScrollbar(horizontalScrollbar, event.angleDelta.y, defaultOffset);
        event.accepted = true;
      }
      if (horizontalScrollbar.visible && ((event.modifiers & Qt.AltModifier) == Qt.AltModifier)) {
        moveScrollbar(horizontalScrollbar, event.angleDelta.x, defaultOffset);
        event.accepted = true;
      }
      if (verticalScrollbar.visible && ((event.modifiers & Qt.NoModifier) == Qt.NoModifier)) {
        moveScrollbar(verticalScrollbar, event.angleDelta.y, defaultOffset);
        event.accepted = true;
      }
    }

    function moveScrollbar(scrollbar, angleDelta, amount) {
      if (angleDelta < 0) {
        for (var i = 0; i < amount; i++) {
          scrollbar.increase();
        }
      } else {
        for (var i = 0; i < amount; i++) {
          scrollbar.decrease();
        }
      }
    }
  }

  onContentItemChanged: {
    if (contentItem == null) {
      return;
    }

    const newWheelHandler = Qt.createQmlObject(`
        import QtQuick

        TibiaScrollView.TibiaScrollViewFlickHelper { }
        `,
        contentItem
    );
    newWheelHandler.contentItem = contentItem;

    /*HISTORY
    * to achieve the proper scroll behaviour in QtQuick.Controls <=1.6 we added the following lines to many components within a TibiaScrollView
    * boundsBehavior: Flickable.StopAtBounds
    * interactive: false //prevent flick behavior on touch screens
    *
    * As things have change and whe can not asure to hit every scrollable / flickable component
    * we present the everyhting is a nail if you have a hammer methode.
    *
    * Tags: Qt6 QtQuick2 workaround Qt5.15
    *
    * Refereces:
    * - https://forum.qt.io/post/514077
    */

    if (contentItem.hasOwnProperty("interactive")) {
      contentItem.interactive = true;
    }
    if (contentItem.hasOwnProperty("boundsBehavior")) {
      contentItem.boundsBehavior = Flickable.StopAtBounds;
    }
    if (contentItem.hasOwnProperty("pixelAligned")) {
      contentItem.pixelAligned = true;
    }
  } //onContentItemChanged


  ScrollBar.vertical: TibiaScrollBar {
    id: verticalScrollbar
    policy: ScrollBar.AlwaysOn
  } //ScrollBar.vertical: TibiaScrollBar
  ScrollBar.horizontal: TibiaScrollBar {
    id: horizontalScrollbar
    policy: ScrollBar.AlwaysOff
  } //ScrollBar.vertical: TibiaScrollBar
} //ScrollView
