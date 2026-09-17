import QtQuick
import QtQuick.Layouts


Item {
  id: sidebar
  Layout.fillHeight: true
  Layout.preferredWidth: TibiaStyle.sidebarWidth

  property QtObject controller: null
  property int sidebarId: controller != null ? controller.sidebarId : -1

  property alias remainingHeight: fillPane.height

  function onApplyWindowBounds() {
    sidebarOuter.applyWindowBounds();
  } //function onTriggerScrollChatListToEnd()

  property bool checkBoundsEnabled: true
  onCheckBoundsEnabledChanged: onApplyWindowBounds()

  property bool triggerCheckBoundsEnabled: true
  onTriggerCheckBoundsEnabledChanged: {
    if(triggerCheckBoundsEnabled) {
      checkBoundsReenableTimer.start();
    } else {
      checkBoundsEnabled = false;
    }
  } //onTriggerCheckBoundsEnabledChanged

  Timer {
    id: checkBoundsReenableTimer
    interval: 50
    onTriggered: {
      checkBoundsEnabled = true;
    } //onTriggered
  } //Timer

  ColumnLayout {
    id: sidebarOuter
    anchors.fill: parent
    spacing:0

    //////////////////////////////////////////////////////////////////////////////////////////////////////
    // UPPER PANE aka PANEL PANE

    TibiaFrame2PixelUpFilled {
      id: upperPaneVisualItem

      visible: sidebarUpperPane.childrenRect.height > 0 //height should only contain visible children

      Layout.fillWidth: true
      Layout.preferredHeight: sidebarUpperPane.height + (visible ? 2*upperPaneWrapper.anchors.margins : 0)

      Item {
        //item just to re-parent the dragged panels to
        id: upperPaneWrapper
        objectName: "upperPaneWrapper"
        anchors.fill: parent
        anchors.margins: upperPaneVisualItem.borderWidth

        GridLayout {
          id: sidebarUpperPane
          objectName: "sidebarUpperPane"
          //can not be anchored to bottom as this would create binding loop for preferredHeight
          anchors {left: parent.left; right: parent.right; top: parent.top}
          columns: 1
          rowSpacing: 0
          columnSpacing: 0

          onHeightChanged: {
            sidebarOuter.applyWindowBounds();
          } //onHeightChanged
        } //GridLayout
      } //Item

    } //TibiaFrame2PixelUpFilled

    // UPPER PANE aka PANEL PANE
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    // LOWER PANE aka WIDGET PANE

    Item {
      //item just to re-parent the dragged widget to
      id: lowerPaneWrapper
      objectName: "lowerPaneWrapper"
      Layout.fillWidth: true
      Layout.preferredHeight: sidebarLowerPane.height

      GridLayout {
        id: sidebarLowerPane
        objectName: "sidebarLowerPane"
        //can not be anchored to bottom as this would create binding loop for preferredHeight
        anchors {left: parent.left; right: parent.right; top: parent.top}
        columns: 2
        rowSpacing: 0
        columnSpacing : 0

        property int remainingHeight: sidebarOuter.height - lowerPaneWrapper.height - (upperPaneVisualItem.visible ? upperPaneVisualItem.height : 0)

        onHeightChanged: {
          sidebarOuter.applyWindowBounds();
        } //onHeightChanged

        property int lastChildrenLength: 0
        onChildrenChanged: {
          //make sure a widget was added
          if(lastChildrenLength < children.length && children.length > 0) {
            var newWidget = children[children.length-1];

            //set the initial container size as soon as it is added to the side bar
            newWidget.applyInitialContentHeight();

            //now try to fit the new widget into the side bar
            var neededHeight = newWidget.widgetHeight - remainingHeight
            if(neededHeight > 0) {
              neededHeight = tryShrinkTaktikShrinkThanCloseBottomToTop(neededHeight, newWidget.identifier);
            }
          }
          lastChildrenLength = children.length;
        } //onChildrenChanged

        function getBottomToTopVisibleWidgetList() {
          var childrenCopy = new Array();
          for (var i=0; i < children.length; i++) {
            if(children[i].visible) { //ignore invisible childs
              childrenCopy.push(children[i]);
            }
          }
          childrenCopy.sort(function(widget1, widget2) {return widget2.identifier - widget1.identifier;} );
          return childrenCopy;
        } //function getBottomToTopVisibleWidgetList

        function tryExpantLowerWidgets(identifier, amountToExpand) {
          var widgetsBottomToTop = getBottomToTopVisibleWidgetList();
          for (var i=0;( i < widgetsBottomToTop.length) && (amountToExpand > 0) && (widgetsBottomToTop[i].identifier > identifier); i++) {
            amountToExpand = widgetsBottomToTop[i].tryExpandUpwards(amountToExpand);
          }
          return amountToExpand;
        } //function tryExpantLowerWidgets

        function tryShrinkLowerWidgets(identifier, amountToShrink) {
          if (sidebar.checkBoundsEnabled) {
            var widgetsBottomToTop = getBottomToTopVisibleWidgetList();
            for (var i=0;( i < widgetsBottomToTop.length) && (amountToShrink > 0) && (widgetsBottomToTop[i].identifier > identifier); i++) {
              amountToShrink = widgetsBottomToTop[i].tryShrink(amountToShrink);
            }
          }
          return amountToShrink;
        } //function tryShrinkLowerWidgets

        function tryShrinkTaktikShrinkEachBeforeClose(amountToShrink) {
          if (sidebar.checkBoundsEnabled) {
            var widgetsBottomToTop = getBottomToTopVisibleWidgetList();
            for (var i=0; i<widgetsBottomToTop.length && amountToShrink > 0; i++) {
              amountToShrink = widgetsBottomToTop[i].tryShrink(amountToShrink);
              if(amountToShrink > 0) {
                amountToShrink = widgetsBottomToTop[i].tryClose(amountToShrink);
              }
            }
          }
          return amountToShrink;
        } //function tryShrinkTaktikShrinkEachBeforeClose

        function tryShrinkTaktikShrinkAllBeforeClose(amountToShrink, fitMeIndentifier) {
          if (sidebar.checkBoundsEnabled) {
            var widgetsBottomToTop = getBottomToTopVisibleWidgetList();
            for (var i=0; i<widgetsBottomToTop.length && amountToShrink > 0; i++) {
              amountToShrink = widgetsBottomToTop[i].tryShrink(amountToShrink);
            }
            for (var i=0; i<widgetsBottomToTop.length && amountToShrink > 0; i++) {
              if(widgetsBottomToTop[i].identifier !=  fitMeIndentifier) {
                amountToShrink = widgetsBottomToTop[i].tryClose(amountToShrink);
              }
            }
          }
          return amountToShrink;
        } //function tryShrinkTaktikShrinkAllBeforeClose

        function tryShrinkTaktikShrinkThanCloseBottomToTop(amountToShrink, fitMeIndentifier) {
          if (sidebar.checkBoundsEnabled) {
            var widgetsBottomToTop = getBottomToTopVisibleWidgetList();

            //find the widget that should be fitted in
            var fitMeInWidget = null;
            var fitMeInWidgetMaxHightFromShrinking = 0;
            for (var i=0; i<widgetsBottomToTop.length; i++) {
              if(widgetsBottomToTop[i].identifier ==  fitMeIndentifier) {
                fitMeInWidget = widgetsBottomToTop[i];
                fitMeInWidgetMaxHightFromShrinking = fitMeInWidget.maxHightFromShrinking();
                //shrinking the fitMeInWidget is enough to fit it
                if(amountToShrink - fitMeInWidgetMaxHightFromShrinking <= 0) {
                  amountToShrink = fitMeInWidget.tryShrink(amountToShrink);
                  return amountToShrink;
                }
                break;
              }
            }

            amountToShrink = amountToShrink - fitMeInWidgetMaxHightFromShrinking;
            for (var i=0; i<widgetsBottomToTop.length && amountToShrink > 0; i++) {
              //try shrink than close for all other widgets than the fitMeInWidget
              if(widgetsBottomToTop[i].identifier !=  fitMeIndentifier) {
                amountToShrink = widgetsBottomToTop[i].tryShrink(amountToShrink);
                if(amountToShrink > 0) {
                  amountToShrink = widgetsBottomToTop[i].tryClose(amountToShrink);
                }
              }
              //if shrinking the fitMeInWidget is enough to fit it in we are done.
              if (amountToShrink <= 0) {
                break;
              }
            }
            //actually fit in the fitMeInWidget
            if (fitMeInWidget != null) {
              var fitMeWidgetAmountToShrink = fitMeInWidgetMaxHightFromShrinking;
              if (amountToShrink < 0) {
                //we know what shrink is maximal possible
                //if we have extra space, eg. from closing, we can reduce the needed shrink
                fitMeWidgetAmountToShrink = fitMeWidgetAmountToShrink + amountToShrink;
              }
              fitMeInWidget.tryShrink(fitMeWidgetAmountToShrink);
            }
          }
          return amountToShrink;
        } //function tryShrinkTaktikShrinkThanCloseBottomToTop
      } //GridLayout
    } //Item


    // LOWER PANE aka WIDGET PANE
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    // HANDLE SHRINK OF CLIENT

    property int oldHeight

    Component.onCompleted: {
      oldHeight = height;
    } //Component.onCompleted

    onHeightChanged: {
      var sideBarHeightChange = oldHeight - height;

      if(sideBarHeightChange > fillPane.height) {
        sidebarLowerPane.tryShrinkTaktikShrinkEachBeforeClose(sideBarHeightChange - fillPane.height);
      }
      oldHeight = height;
    } //onHeightChanged

    function applyWindowBounds() {
      if (sidebar.checkBoundsEnabled) {
        adjustOutofWindowBoundsTimer.start();
      }
    } //function applyWindowBounds()

    Timer {
      id: adjustOutofWindowBoundsTimer
      interval: 1 //give QML just a bit time to adjust to all the changes
      onTriggered: {
        sidebarOuter.adjustOutOfWindowBounds();
      } //onTriggered
    } //Timer

    function adjustOutOfWindowBounds() {
      //mainly used for the change of the upper pane size
      //lower pane also triggers this but only if bounds the widgets minimum sizes exceed the left over space this will fire
      var sidebarOutOfBound = (upperPaneVisualItem.Layout.preferredHeight + lowerPaneWrapper.Layout.preferredHeight) - sidebar.height;

      if(sidebarOutOfBound > 0) {
        sidebarLowerPane.tryShrinkTaktikShrinkEachBeforeClose(sidebarOutOfBound);
      }
    } //onImplicitHeightChanged

    // HANDLE SHRINK OF CLIENT
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    // FILL PANE

    TibiaFrame2PixelUpFilled {
      id: fillPane
      Layout.fillWidth: true
      Layout.fillHeight: true

      z:-1
      Layout.minimumHeight: 0

      pinnedToBottom: true
    } //TibiaFrame2PixelUpFilled

    // FILL PANE
    //////////////////////////////////////////////////////////////////////////////////////////////////////
  } //ColumnLayout

  ///////////////////////////////////////////////////////////////////////////////////////////////////////
  // DRAG WIDGETS RECEIVER
  DropArea {
    id: widgetDroptArea
    anchors.fill: parent

    enabled: controller != null && controller.acceptsWidgetDrops

    keys: [ TibiaStyle.dragKeyWidgetSidebar ]
    onDropped: {
      drag.source.requestMoveToSidebar(sidebarId);
    } //onDropped
  } //DropArea

  Rectangle {
    anchors.fill: parent
    visible: widgetDroptArea.containsDrag
    color: "transparent"
    border.width: 2
    border.color: "white"
  } //Rectangle
  // DRAG WIDGETS RECEIVER
  ///////////////////////////////////////////////////////////////////////////////////////////////////////
} //Item
