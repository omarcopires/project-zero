import QtQuick
import QtQuick.Layouts
import qmlcomponents



/*
 * Developer hints for using TibiaSidebarWidget
 *
 * Widget controller
 *
 * Sidebar widgets automatically have a widgetController property, which will be set by
 * the sidebar when the widget is created.
 *
 * Widget icon
 *
 * The icon can be set using the picSource property, which should be a QRC resource URI.
 *
 * Widget sizing
 *
 * The widget is always as wide as the containing sidebar. Do not set the width explicitly,
 * but instead anchor the first child item, which will usually be a Layout, to the left and right
 * sides of the parent element. The widget's height should be calculated automatically based on the
 * height of its children, not set explicitly.
 * To control the widget's initial, minimal and maximal size, use the properties
 * min-/max-/initialContentHeight. Do not touch min-/max-/initialHeight, as those include the widget's
 * decorations such as the widget header, which cannot be influenced from the widget content itself!
 * By default, a widget can be as small and as large as space is available. To prevent a widget from
 * growing endlessly, specify maxContentHeight, for example by setting it to the layout's computed height.
 */

MouseArea {
  id: sidebarWidget
  property var widgetRoot: this

  default property alias content: sidebarWidgetContent.data
  property alias customButtonContainerData: customButtonContainer.data
  property alias caption: captionText.text
  property alias captionStyleType: captionText.styleType;
  property bool highlightCaption: false
  property bool showHighlightFlash: true

  property string picSource
  property int iconTypeid: 0
  property int iconCumulativeCount: 0
  property int iconLiquidType: ObjectAppearanceInstance.EMPTY
  property int iconHookDirection: ObjectAppearanceInstance.NONE
  property int iconDecoItemObjectID: 0

  property alias levelUpButtonVisible: levelUpButton.visible
  property alias highlightFocus: highlightFrame.focusHighlightVisible

  property QtObject widgetController: null

  property alias widgetHeight: sidebarWidgetContetWrapper.height
  implicitWidth: sidebarWidgetContetWrapper.width
  implicitHeight: widgetHeight
  clip: true

  property int minContentHeight: TibiaStyle.defaultInitialContentHeight
  property int maxContentHeight: 1000000  // Arbitrary large value
  property int initialContentHeight: TibiaStyle.defaultInitialContentHeight

  property int maximizedContentHeight: (maximized ? widgetHeight : maximizedHeight) - TibiaStyle.widgetMinimizedHeight

  property int minHeight: minContentHeight + TibiaStyle.widgetMinimizedHeight
  property int maxHeight: maxContentHeight + TibiaStyle.widgetMinimizedHeight
  property int initialHeight: Math.max(minContentHeight, initialContentHeight) + TibiaStyle.widgetMinimizedHeight
  property bool maxHeightIsLazilyEnforced: false

  signal manuallyResizing();
  signal maximizedContentHeightHasChanged();

  onMaximizedContentHeightChanged: {
    sidebarWidget.maximizedContentHeightHasChanged();
  } //onMaximizedContentHeightChanged

  Component {
    id: resourceIcon
    Image {
      id: picImage
      asynchronous: true
      source: picSource
      fillMode: Image.PreserveAspectFit
      anchors.fill: parent
      smooth: false
      visible: iconTypeid == 0
    } //Image
  }

  Component {
    id: appearanceInstanceSpriteInfoIcon

    SingleObjectAppearanceInstanceRenderer {
      smoothTextureFiltering: true

      animated: true
      typeid: iconTypeid
      cumulativeCount: iconCumulativeCount
      liquidType: iconLiquidType
      hookDirection: iconHookDirection
      decoItemObjectID: iconDecoItemObjectID
    } //SingleObjectAppearanceInstanceRenderer
  } //Component

  function highlightFlash() {
    highlightFrame.flash();
  }

  function highlightFlashRepeated() {
    highlightFrame.flash(3);
  }

  signal positionInSidebarChanged()

  //////////////////////////////////////////////////////////////////////////////////////////////////////
  // UI CHACHING
  property bool allowUICaching: true
  property bool _PauseUICaching: false
  readonly property bool layerEnabled: UICachingEnabled && allowUICaching && !_PauseUICaching
  // UI CHACHING
  //////////////////////////////////////////////////////////////////////////////////////////////////////
  // GLOBAL SETTING

  // GLOBAL RECOGNITION OF SIDEBAR AS PAREN
  property bool validSidebarParent: false
  property var parentWhileDragging: widgetController != null ? widgetController.gameWindowQuickItem : sidebarWidget
  property int parentSidebarId: widgetController != null ? widgetController.parentSidebarId : 255
  property string sidbarInternalDragKey: TibiaStyle.dragKeyWidgetInternal.arg(parentSidebarId)
  onParentChanged: {
    if(parent != null && parent.objectName == "sidebarLowerPane") {
      validSidebarParent = true;
    } else {
      validSidebarParent = false;
    }
    updateAnimationTargetLocation();
  } //onParentChanged

  //CHECK IF COMPONENT IS COMPLETE
  property bool componentComplet: false
  Component.onCompleted: {
    componentComplet = true;
    widgetHeight = minHeight; //initially min Height, the initial content height is applied when added to the sidebar
    Qt.callLater( () => {
      if (sidebarWidget && sidebarWidget.showHighlightFlash) {
        highlightFlash();
      }
    });
  }


  // DRAG & DROP
  property point animationTargetLocation: Qt.point(-1,-1)
  function updateAnimationTargetLocation() {
    animationTargetLocation = parentWhileDragging.mapFromItem(sidebarWidget, 0, 0);
  } //function updateAnimationTargetLocation()

  onYChanged: updateAnimationTargetLocation()

  // GLOBAL RECOGNITION OF SIDEBAR AS PARENT
  //////////////////////////////////////////////////////////////////////////////////////////////////////
  // BACKGROUND WHILE DRAGGING
  TibiaFrame2PixelUpFilled {
    anchors.fill: parent
    dark: true
    visible: sidebarWidgetContetWrapper.parent != sidebarWidget
  } //TibiaFrame2PixelUpFilled
  // BACKGROUND WHILE DRAGGING
  //////////////////////////////////////////////////////////////////////////////////////////////////////
  // DRAG ITEM

  BorderImage {
    id: sidebarWidgetContetWrapper
    border { left: TibiaStyle.widgetBorderWidth; top: TibiaStyle.widgetHeaderLineHeight ; right: TibiaStyle.widgetBorderWidth; bottom: TibiaStyle.widgetBorderWidth }
    horizontalTileMode: BorderImage.Repeat
    verticalTileMode: BorderImage.Repeat
    z: sidebarWidget.mouseDragActive ? 999 : 1
    source: "/images/skin/classic/widget-borderimage.png"
    smooth: false
    layer.enabled: sidebarWidget.layerEnabled

    width: TibiaStyle.sidebarWidth

    Rectangle {
      id: highlightFrame
      anchors.fill: parent
      visible: flashVisible || focusHighlightVisible
      color: "transparent"
      border.width: 2
      border.color: "white"

      property bool flashVisible: false
      property bool focusHighlightVisible: false

      function flash(loops = 1) {
        highlightFrame.flashVisible = true
        flashAnimation.loops = loops && loops > 0 ? loops : 1
        flashAnimation.start()
      } //function flash()

      SequentialAnimation on opacity {
        id: flashAnimation
        alwaysRunToEnd: false

        PropertyAnimation { to: 1.0; duration: 0 }
        PropertyAnimation { to: 1.0; duration: 350 }
        PropertyAnimation { to: 0.0; duration: 0 }
        PropertyAnimation { to: 0.0; duration: 350 }

        onStopped: {
          highlightFrame.flashVisible = false
          highlightFrame.opacity = 1.0
        }
      } //SequentialAnimation
    } //Rectangle

    ////////////////////////////////
    // DRAW HEAD LINE + CONTENT ITEM

    ColumnLayout {
      anchors.fill: sidebarWidgetContetWrapper
      anchors.margins: 0
      spacing:0

      /////////////////
      // DRAW HEAD LINE
      Item {
        Layout.fillWidth: true
        Layout.fillHeight: false
        Layout.preferredHeight: TibiaStyle.widgetHeaderLineHeight
        Layout.minimumHeight: TibiaStyle.widgetHeaderLineHeight
        Layout.maximumHeight: TibiaStyle.widgetHeaderLineHeight
        Layout.alignment: Qt.AlignTop

        RowLayout {
          id: headLine
          anchors.fill: parent
          anchors.margins:0
          anchors.leftMargin: TibiaStyle.widgetBorderWidth
          anchors.rightMargin: TibiaStyle.widgetBorderWidth -1 // buttons are in contact with the frame
          spacing: 4

          Item {
            id: containerIconWrapper
            Layout.preferredHeight: 12
            Layout.preferredWidth: 12
            Loader {
              id: containerIconLoader
              anchors.fill: parent

              states: [
                State {
                  name: "RESOURCE_CONTAINER_ICON"
                  when: iconTypeid == 0
                  PropertyChanges { target: containerIconLoader; sourceComponent: resourceIcon }
                }, //State
                State {
                  name: "APPEARANCE_INSTANCE_CONTAINER_ICON"
                  when: iconTypeid != 0
                  PropertyChanges { target: containerIconLoader; sourceComponent: appearanceInstanceSpriteInfoIcon }
                } //State
              ] //states
            } //Loader
          } //Item

          TibiaText {
            id: captionText
            text: "Sidebar Element"
            styleType: sidebarWidget.highlightCaption ? "WidgetCaptionHighilght" : "Caption"
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            verticalAlignment: Text.AlignVCenter
          } //TibiaText


          /////////////////
          // CUSTOM BUTTONS

          RowLayout {
            id: customButtonContainer
            Layout.fillHeight: false
            spacing:0

          } //RowLayout

          /////////////////
          // BUTTONS

          RowLayout {
            id: buttonContainer
            Layout.fillHeight: false
            spacing:0

            TibiaIconButton {
              id: levelUpButton
              sourceUp:   "/images/skin/classic/container-level-up-up.png"
              sourceDown: "/images/skin/classic/container-level-up-down.png"
              tooltipText: qsTrId("container_up_tooltip")
              onClicked: widgetController!=null ?  widgetController.onLevelUpClicked() : undefined;
              visible: false
            } //TibiaIconButton

            TibiaIconButton {
              id: minButton
              sourceUp:   "/images/skin/classic/min-button-small-up.png"
              sourceDown: "/images/skin/classic/min-button-small-down.png"
              tooltipText: qsTrId("widget_max_min_tooltip")
              onClicked: {maximized = false;}
              visible: maximized
            } //TibiaIconButton

            TibiaIconButton {
              id: maxButton
              sourceUp:   "/images/skin/classic/max-button-small-up.png"
              sourceDown: "/images/skin/classic/max-button-small-down.png"
              tooltipText: minButton.tooltipText
              onClicked: {maximized = true;}
              visible: !maximized
            } //TibiaIconButton

            TibiaIconButton {
              id: closeButton
              sourceUp:   "/images/skin/classic/exit-button-small-up.png"
              sourceDown: "/images/skin/classic/exit-button-small-down.png"
              tooltipText: qsTrId("close_widget_tooltip")
              onClicked: widgetController!=null ?  widgetController.onCloseClicked() : undefined
            } //TibiaIconButton
          } //RowLayout
        } //RowLayout
      } //Item

      ////////////////
      // CONTENT ITEM
      Item {
        Layout.fillWidth: true
        Layout.fillHeight: true

        visible: maximized
        Item {
          id: sidebarWidgetContent
          objectName: "sidebarWidgetContent"
          anchors.fill: parent
          anchors.margins: TibiaStyle.widgetBorderWidth
          anchors.topMargin: 0
          clip: false
        } //Item
      } //Item

    } //ColumnLayout
    // DRAW HEAD LINE + CONTENT ITEM
    ////////////////////////////////
    // DRAW RESIZE HANDLES
    Image {
      id: resizer
      anchors.left: sidebarWidgetContetWrapper.left
      anchors.bottom: sidebarWidgetContetWrapper.bottom
      anchors.margins: 3
      source: "/images/windowresizer.png"
      z: sidebarWidgetContent.z + 1
      visible: maximized && resizeable
      smooth: false

      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        enabled: resizeable
        z: sidebarWidgetContent.z - 1
        hoverEnabled: true

        onPressed: { rememberStateBeforeResize(mapToItem(null, 0, mouseY).y); }
        onEntered: {
          if(widgetController != null) { widgetController.setCursorToResizeVertical(true); }
        }
        onExited: {
          if(widgetController != null && !pressed) {
            widgetController.setCursorToResizeVertical(false);
          }
        }
        onReleased: {
          if(widgetController != null) { widgetController.setCursorToResizeVertical(false); }
        }
        onPositionChanged: { resizeHeight(pressed, mapToItem(null, 0, mouseY).y); }
      }// MouseArea
    } //Image

    MouseArea {
      anchors {left: sidebarWidgetContetWrapper.left; right: sidebarWidgetContetWrapper.right; bottom: sidebarWidgetContetWrapper.bottom}
      // TIBIA-14161
      // there seems to be a calculation error so that the drag handle of the next widget is selected instead of the resize
      // handle of this widget (even though the mouse cursor is switched to resize)
      // By adding a minimum margin to the bottom it seems to work
      anchors.bottomMargin: 0.01
      height: TibiaStyle.widgetBorderWidth
      z: sidebarWidgetContent.z +1
      acceptedButtons: Qt.LeftButton
      visible: resizeable
      enabled: resizeable
      hoverEnabled: true

      onPressed: { rememberStateBeforeResize(mapToItem(null, 0, mouseY).y); }
      onEntered: {
        if(widgetController != null) { widgetController.setCursorToResizeVertical(true); }
      }
      onExited: {
        if(widgetController != null && !pressed) {
          widgetController.setCursorToResizeVertical(false);
        }
      }
      onReleased: { if(widgetController != null) { widgetController.setCursorToResizeVertical(false); } }
      onPositionChanged: { resizeHeight(pressed, mapToItem(null, 0, mouseY).y); }
    }// MouseArea

    // DRAW RESIZE HANDLES
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    // DRAG PROPETIES

    Drag.keys: [ sidbarInternalDragKey, TibiaStyle.dragKeyWidgetSidebar ]
    Drag.active: mouseDragActive
    Drag.source: sidebarWidget

    //move the hotspot to the middle, so it reacts with neighbouring sidebars only if the user realy draggs it there
    Drag.hotSpot.x: Math.ceil(sidebarWidget.width * 0.5)
    Drag.hotSpot.y: allowFreeDrag ? Math.ceil(sidebarWidget.height * 0.5) : nonFreeDragHotSpotY

    property real prevY: 0
    property int nonFreeDragHotSpotY: 1
    onYChanged: {
      if (Drag.active) {
        // when moving to the left, the hot spot is the left edge and vice versa
        nonFreeDragHotSpotY = y < prevY ? 1 : height-1;
        prevY = y;
      }
    } //onYChanged

    state: Drag.active ? "DRAGGING" : ""
    transitions: [
      Transition {
        to: "DRAGGING"
        PropertyAction { target: sidebarWidgetContetWrapper; property: "parent"; value: parentWhileDragging }
        //when starting drag place the drag object relative where it was before
        PropertyAction { target: sidebarWidgetContetWrapper; property: "y"; value: sidebarWidget.animationTargetLocation.y }
        PropertyAction { target: sidebarWidgetContetWrapper; property: "x"; value: sidebarWidget.animationTargetLocation.x }
      }, //Transition
      Transition {
        from: "DRAGGING"
        ScriptAction { script: moveBackTimer.start() }
      } //Transition
    ] //transitions

    Timer {
      id: moveBackTimer
      interval: 2 //needed to react to chagnes within the GridLayout
      onTriggered: {
        moveBackAnimation.start();
      } //onTriggered
    } //Timer

    SequentialAnimation {
      id: moveBackAnimation
      running: false
      alwaysRunToEnd: true
      ParallelAnimation {
        NumberAnimation {
          target: sidebarWidgetContetWrapper
          duration: 100
          easing.type: Easing.OutCubic
          property: "y"
          to: sidebarWidget.animationTargetLocation.y
        } //NumberAnimation
        NumberAnimation {
          target: sidebarWidgetContetWrapper
          duration: 100
          easing.type: Easing.OutCubic
          property: "x"
          to: sidebarWidget.animationTargetLocation.x
        } //NumberAnimation
      } //ParallelAnimation
      PropertyAction { target: sidebarWidgetContetWrapper; property: "parent"; value: sidebarWidget }
      ParallelAnimation {
        PropertyAction { target: sidebarWidgetContetWrapper; property: "y"; value: 0 }
        PropertyAction { target: sidebarWidgetContetWrapper; property: "x"; value: 0 }
      } //ParallelAnimation
    } //SequentialAnimation

    // DRAG PROPETIES
    //////////////////////////////////////////////////////////////////////////////////////////////////////

  } //BorderImage
  // DRAG ITEM
  //////////////////////////////////////////////////////////////////////////////////////////////////////
  // RESIZE FUNCTIONS

  property int globalMouseYBeforeResize: 0
  property int sizeBeforeResize: 0
  property int remainingHeightLocalCalculation: 0
  property bool resizeable: maximized && minHeight < maxHeight
  property bool validMaxHeight: minHeight <= maxHeight

  onImplicitHeightChanged: {
    height = implicitHeight;
  } //onImplicitHeightChanged

  onMinHeightChanged: {
    //currently widget is smaller than the new minHeight so act
    if((minHeight > widgetHeight) && componentComplet && maximized) {
      //see if we have a parent to check for remaining height
      if(validSidebarParent) {
        var needeHeight = minHeight - widgetHeight;
        //not enough space left try to get more space
        if(needeHeight > sidebarWidget.parent.remainingHeight) {
          sidebarWidget.parent.tryShrinkTaktikShrinkAllBeforeClose(needeHeight, identifier);
        }
      }
      //so now we have enough space
      widgetHeight = minHeight;
    }
  } //onMinHeightChanged

  onMaxHeightChanged: {
    if((maxHeight < widgetHeight && componentComplet) && !maxHeightIsLazilyEnforced) {
      widgetHeight = maxHeight;
    }
  } //onMaxHeightChanged


  function rememberStateBeforeResize(newMouseY) {
    globalMouseYBeforeResize = newMouseY;
    sizeBeforeResize = widgetHeight;
    if(validSidebarParent) {
      remainingHeightLocalCalculation = sidebarWidget.parent.remainingHeight;
    }
    if(widgetController != null) {
      widgetController.setCursorToResizeVertical(true);
    }

    sidebarWidget.manuallyResizing();
  } //function rememberStateBeforeResize

  function resizeHeight(pressed, newMouseY) {
    sidebarWidget._PauseUICaching = true
    if(pressed) {
      var mouseChange = newMouseY - globalMouseYBeforeResize;
      var requestedNewHeight = sizeBeforeResize + mouseChange;
      tryChangeHeightTo(requestedNewHeight);

      sidebarWidget.manuallyResizing();
    }
    sidebarWidget._PauseUICaching = false
  } //function resizeHeight

  function tryChangeHeightTo(requestedNewHeight) {
    sidebarWidget._PauseUICaching = true
    var requestedDelta = requestedNewHeight - widgetHeight
    //clamp height to max an min
    requestedNewHeight = Math.max(requestedNewHeight, minHeight);
    if (validMaxHeight) { //valid maxHeight
      var currentMaxHeight = maxHeightIsLazilyEnforced ? Math.max(widgetHeight, maxHeight) : maxHeight;
      requestedNewHeight = Math.min(requestedNewHeight, currentMaxHeight);
    }

    //early out if size does not change - or at least must not be increased because it is currently too big
    if((requestedNewHeight == widgetHeight)
      || (maxHeightIsLazilyEnforced && (widgetHeight > maxHeight) && (requestedDelta > 0))) {
      return;
    }

    //calculate how much it differs to the current size
    var requestedHightChange = requestedNewHeight - widgetHeight; //+ expande; - shrink

    //is expanding
    if(requestedHightChange > 0) {
      var heightThatWasNotAquiredByShrinking = 0;
      //remaining height is not enough try to shrink other widgets
      if(remainingHeightLocalCalculation < requestedHightChange) {
        heightThatWasNotAquiredByShrinking = sidebarWidget.parent.tryShrinkLowerWidgets(identifier, requestedHightChange - remainingHeightLocalCalculation);
        remainingHeightLocalCalculation = 0;
      } else {
        remainingHeightLocalCalculation -= requestedHightChange;
      }
      requestedHightChange = Math.max(requestedHightChange - heightThatWasNotAquiredByShrinking, 0);
    }

    //calulate the actual new size
    var newHeight = widgetHeight + requestedHightChange;

    //change the hight if it realy changes
    if(newHeight != widgetHeight) {
      widgetHeight = newHeight;

      //if size gets reduced expand widgets below the current widget
      if(requestedHightChange < 0 && validSidebarParent) {
        remainingHeightLocalCalculation += sidebarWidget.parent.tryExpantLowerWidgets(identifier, -requestedHightChange);
      }
    }
    sidebarWidget._PauseUICaching = false
  } //function tryChangeHightTo

  function maxHightFromShrinking() {
    return widgetHeight - minHeight;
  } //function maxHightFromShrinking()

  function tryShrink(amountToShrink) {
    sidebarWidget._PauseUICaching = true
    var maxPossibleShrink = maxHightFromShrinking();
    var retValue = 0;

    if(maxPossibleShrink == 0 || maximized == false) {
      retValue = amountToShrink;
    } else if(maxPossibleShrink >= amountToShrink) {
      widgetHeight -= amountToShrink;
      retValue = 0;
    } else {
      widgetHeight = minHeight;
      retValue = amountToShrink - maxPossibleShrink;
    }
    sidebarWidget._PauseUICaching = false
    return retValue;
  } //function tryShrink

  function tryClose(amountToShrink) {
    sidebarWidget._PauseUICaching = true
    var retValue = 0;
    if(widgetController != null) {
      widgetController.onRequestClose();
      retValue = amountToShrink - widgetHeight;
    } else {
      retValue = amountToShrink;
    }
    sidebarWidget._PauseUICaching = false
    return retValue;
  } //function tryClose

  function tryExpandUpwards(amountToExpand) {
    //expanding upwards means total hight of all widgets doesn't exeed the current hight of the side bar
    var maxPossibleExpand = validMaxHeight ? maxHeight - widgetHeight : amountToExpand;

    if(maxPossibleExpand == 0 || maximized == false) {
      return amountToExpand;
    }else if(maxPossibleExpand >= amountToExpand) {
      widgetHeight += amountToExpand;
      return 0;
    } else {
      widgetHeight = maxHeight;
      return amountToExpand - maxPossibleExpand;
    }
  } //function tryExpandUpwards

  function applyInitialContentHeight() {
    sidebarWidget._PauseUICaching = true
    if(maximized) {
      if(initialHeight > widgetHeight) {
        //size on creation is minHeight, so only apply initialHeight if it is bigger than than the current widgetHeight
        widgetHeight = initialHeight;
      }
    } else {
      //widget is currently minimized so prepare size when it becomes maximized
      maximizedHeight = initialHeight;
      widgetHeight = TibiaStyle.widgetMinimizedHeight;
    }
    sidebarWidget._PauseUICaching = false
  } //function applyInitialContentHeight()

  // RESIZE FUNCTIONS
  //////////////////////////////////////////////////////////////////////////////////////////////////////
  // MAXIMIZE & MINIMIZE FUNCTIONS

  property bool maximized: true
  property int maximizedHeight: initialHeight

  onMaximizedChanged: {
    if(maximized) {
      //widget enters maximized state

      //make sure widget was added to sidebar
      if(validSidebarParent) {
        var remainingHeight = sidebarWidget.parent.remainingHeight;
        var neededHeight = maximizedHeight - widgetHeight - remainingHeight;
        widgetHeight = maximizedHeight;
        if(neededHeight > 0) {
          neededHeight = sidebarWidget.tryShrink(neededHeight);
          if(neededHeight > 0) {
            neededHeight = sidebarWidget.parent.tryShrinkTaktikShrinkAllBeforeClose(neededHeight, sidebarWidget.identifier);
          }
        }

        // the sidebar was shrinked more than needed so expand maximized widget as far as possible/needed
        if(widgetHeight < maximizedHeight && neededHeight < 0) {
          widgetHeight += Math.min(-neededHeight, maximizedHeight - widgetHeight);
        }
      }
      else {
        widgetHeight = maximizedHeight;
      }
    } else {
      //widget enters minimized state
      maximizedHeight = widgetHeight;
      widgetHeight = TibiaStyle.widgetMinimizedHeight;
    }
  } //onMaximizedChanged

  // MAXIMZIE MINIMIZE AREA AT TOP OF WIDGET
  onDoubleClicked: (mouse) => {
    if(mouse.y <= TibiaStyle.widgetHeaderLineHeight) {
      maximized = !maximized;
    }
  } //onDoubleClicked

  // MAXIMIZE & MINIMIZE FUNCTIONS
  //////////////////////////////////////////////////////////////////////////////////////////////////////
  // DRAG & DROP

  //identifier needed to sort widgets within the enclosing GridView
  property int identifier: 0
  Layout.row: identifier

  //prevent X drag from happening to easy
  property bool allowFreeDrag: false
  property real mouseDownX: 0
  onPressed: {
    allowFreeDrag = false;
    mouseDownX = mouseX;
  } //onPressed

  onPositionChanged: {
    if (!allowFreeDrag && Math.abs(mouseDownX - mouseX) > TibiaStyle.dragStickTreshold) {
      allowFreeDrag = true;
    }
  } //onPositionChanged

  //drag parameters
  property bool mouseDragActive: drag.active && pressed
  drag.target: sidebarWidgetContetWrapper
  drag.axis: allowFreeDrag ? Drag.XAndYAxis : Drag.YAxis
  drag.minimumY: drag.active ? 0 : -Number.MAX_VALUE //trick to allow to drag directly to the top, before parent was changed in transition
  drag.maximumY: parentWhileDragging.height - sidebarWidget.height
  drag.minimumX: drag.active ? 0 : -Number.MAX_VALUE //trick to allow to drag directly to the left, before parent was changed in transition
  drag.maximumX: parentWhileDragging.width - sidebarWidget.width


  function swapWidgetsPositionWith(dragSource, upwards) {
    var targetIdentifier = sidebarWidget.identifier;
    var sourceIdentifier = dragSource.identifier;

    var neighbhors = areNeighbours(sidebarWidget, dragSource);

    var freeDragJumpSwap = dragSource.allowFreeDrag && !neighbhors;
    var neighbhorsSwap = neighbhors && ((upwards && (targetIdentifier < sourceIdentifier)) || (!upwards && (targetIdentifier > sourceIdentifier)))

    if (freeDragJumpSwap || neighbhorsSwap) {
      //move the second column to avoid duplicated use of the same cell
      sidebarWidget.Layout.column = 1;
      sidebarWidget.identifier = sourceIdentifier;
      dragSource.identifier = targetIdentifier;
      sidebarWidget.Layout.column = 0;
      sidebarWidget.positionInSidebarChanged(); //emit signal
    }
  } //function swapWidgetsPositionWith(dragSource)

  function areNeighbours(widget1, widget2) {
    var topWidget = widget1;
    var bottomWidget = widget2;
    if (widget1.identifier > widget2.identifier) {
      topWidget = widget2;
      bottomWidget = widget1;
    }

    return Math.abs((topWidget.y + topWidget.height) - bottomWidget.y) <= 1;
  } //function areNeighbours(widget1, widget2)

  DropArea {
    id: topDropArea
    anchors {right: sidebarWidget.right; left: sidebarWidget.left; top: sidebarWidget.top }
    height: Math.floor(sidebarWidget.height * 0.5)
    z: 0

    enabled: !mouseDragActive

    keys: [ sidbarInternalDragKey ]
    onEntered: (drag) => {
      swapWidgetsPositionWith(drag.source, true);
    } //onEntered
  } //DropArea

  DropArea {
    id: bottomDropArea
    anchors {right: sidebarWidget.right; left: sidebarWidget.left; bottom: sidebarWidget.bottom }
    height: Math.ceil(sidebarWidget.height * 0.5)
    z: 0

    enabled: !mouseDragActive

    keys: [ sidbarInternalDragKey ]
    onEntered: (drag) => {
      swapWidgetsPositionWith(drag.source, false);
    } //onEntered
  } //DropArea

  // MOVE TO OTHER SIDEBAR
  onMouseDragActiveChanged: {
    if(widgetController != null) {
      widgetController.onSetDragActive(mouseDragActive);
    }
    updateAnimationTargetLocation();
  } //drag.onActiveChanged

  //needed to create dop events
  onReleased: drag.target.Drag.drop()

  function requestMoveToSidebar(targetSidebar) {
    if (widgetController!=null) {
      widgetController.onRequestMoveToSidebar(targetSidebar)
    }
  } //function requestMoveToSidebar(targetSidebar)
  // MOVE TO OTHER SIDEBAR

  // DRAG & DROP
  //////////////////////////////////////////////////////////////////////////////////////////////////////
} //MouseArea
