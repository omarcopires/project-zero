import QtQuick
import QtQuick.Layouts 1.2



/*
 * Developer hints for using TibiaDialog
 *
 * -- Dialog controller ------------------------------------------------------
 *
 * The TibiaDialog component does not declare a "controller" property by default.
 * Nevertheless TDialogControllerBase automatically injects itself into that property
 * when the component is instantiated. If you need a different controller (or
 * additional initial properties), override
 * TDialogControllerBase::initialDialogProperties().
 *
 * -- Mouse click behavior ---------------------------------------------------
 *
 * By default, the dialog does not intercept mouse clicks that occur inside
 * its bounds. Setting personalMouseShield = true creates an invisible
 * MouseArea beneath the content item that consumes all mouse events.
 *
 * -- Dialog controller ------------------------------------------------------
 *
 * Dialogs by default do not have a controller property, and no property is automatically set
 * when the dialog is created. Thus, the programmer should set the "controller" property
 * when the dialog is created in an overridden createDynamicQMLComponents().
 *
 * -- Dialog sizing ----------------------------------------------------------
 *
 * The dialog's width is specified by setting the width property of the TibiaDialog element.
 * The height is calculated based on the height of its (one) child element. Setting the child
 * element to fill the parent element will thus lead to a binding loop! To avoid the problem,
 * set the child's height explicitly, or allow it to be calculated automatically, for example
 * using a layout. Do not anchor the child to the parent's top AND bottom!
 *
 * -- Focus handling ---------------------------------------------------------
 *
 * The element specified with the property "initialFocusItem" will receive active focus when the
 * dialog is shown. If the dialog does not have any items that require focus, set the focus to
 * the dialog itself.
 * When pressing TAB, focus will switch to the next control, which should be considered random
 * (i.e. even OUTSIDE the dialog!) unless the next control has been manually specified.
 * Make sure to set the property KeyNavigation.tab on all elements that could receive focus!
 * The property defines the next element that should receive focus. If you don't want a dialog
 * element to lose focus via tabbing, simply specify the same element as tab target.
 *
 * -- ESC key handling -------------------------------------------------------
 *
 * Pressing ESC will trigger the function specified in onCancelPressedFunction. By convention,
 * this function MUST close the dialog. Thus, every dialog MUST implement a cancelPressedFunction
 * in some way.
 *
 * -- RETURN key handling ----------------------------------------------------
 *
 * By default, pressing Return will cause the function specified in onReturnPressedFunction to be
 * triggered. If a dialog element has active focus that handles Return, returnPressedFunction will
 * NOT be triggered. In that case, the dialog element usually has a signal that can be reacted upon,
 * for example onActivated in TableView. If a dialog can have multiple focus elements, it might be
 * necessary to have the default return function and specific handlers for each element.
 *
 * -- (other) key handling ---------------------------------------------------
 *
 * By default, pressing any other key than Return/Enter or Esc will cause the function
 * onKeyPressedFunction(KeyEvent.key, KeyEvent.modifiers) to be triggered. Dialog elements with active
 * focus may need extra care.
 *
 */

Item {
  id: dialog
  objectName: "dialog"

  default property alias content: container.data
  property string caption: ""
  property bool flagCaption: false
  readonly property alias captionContentWidth: dialogFrameLoader.captionContentWidth
  readonly property alias captionHeight: dialogFrameLoader.captionHeight
  property alias dialogClip: container.clip
  property var onReturnPressedFunction: null
  property var onCancelPressedFunction: null
  property var onKeyPressedFunction: null
  property var initialFocusItem: null
  property bool showCaption: true
  property alias movable: mouseAreaDrag.enabled
  property var centerAtElement: parent
  property Component headerDelegate: null
  property int leftPadding: 0
  property int rightPadding: 0
  property int topPadding: 0
  property bool personalMouseShield: false
  property bool showXButton: personalMouseShield
  property Component customButtonComponent: null

  property bool resizeable: false
  property int minWidth: width
  property int minHeight: height
  property bool _resizing: false
  signal resizeRequest(int newDialogWidth, int newContentHeight)
  property bool remembersPosition: false
  signal positionChanged(int x, int y)

  implicitWidth: 250
  implicitHeight: 150
  clip: true


  height: container.height + container.anchors.topMargin + dialogFocusScope.anchors.topMargin + TibiaStyle.dialogMarginBorder

  visible: false

  readonly property int topMarginsToContent: showCaption
    ? TibiaStyle.dialogHeaderLineHeight + TibiaStyle.dialogMarginBorder - TibiaStyle.dialogFrameWidith
    : TibiaStyle.dialogFrameWidith

  //if dialog becomes visible set the focus to the specified item
  onVisibleChanged: {
    if(visible) {
      dialogFocusScope.focus = true; //make sure the focues is at least in the dialog
      if(initialFocusItem != null) {
        initialFocusItem.forceActiveFocus();
      }
    }
    if(tibiaMouseCursorController != null) { tibiaMouseCursorController.setDefaultCursor(); }
  } //onVisibleChanged
  KeyNavigation.tab: dialogFocusScope
  KeyNavigation.backtab: dialogFocusScope

  Component.onCompleted: centerDialog()

  Connections {
    target: centerAtElement
    function onXChanged() {
      centerDialog();
    }
    function onYChanged() {
      centerDialog();
    }
    function onWidthChanged() {
      centerDialog();
    }
    function onHeightChanged() {
      centerDialog();
    }
  }

  function defaultReturnAction() {
    if (onReturnPressedFunction != null){
      onReturnPressedFunction();
    }
  } //function defaultReturnAction

  function defaultCancelAction() {
    if (onCancelPressedFunction != null){
      onCancelPressedFunction();
    }
  } //function defaultCancelAction

  function defaultKeyPressedAction(event) {
    if (onKeyPressedFunction != null){
      onKeyPressedFunction(event.key, event.modifiers);
    }
  } //function defaultKeyPressedAction

  function startResizing() {
    _resizing = true;
  } //function startResizing

  function finishResizing() {
    _resizing = false;
  } //function finishResizing

  function centerDialog(force=false) {
    if (!_resizing
      && !remembersPosition
      && centerAtElement != null
      && dialog.parent != null
      || force) {
      var centerAtRect = Qt.rect(centerAtElement.x, centerAtElement.y, centerAtElement.width, centerAtElement.height);
      var dialogRect = Qt.rect(dialog.x, dialog.y, dialog.width, dialog.height);
      var centerAtRectMapped = dialog.parent.mapFromItem(centerAtElement, centerAtRect);

      dialog.x = Math.max(0, centerAtRectMapped.x + Math.floor(centerAtRectMapped.width * 0.5  - dialog.width * 0.5));
      dialog.y = Math.max(0, centerAtRectMapped.y + Math.floor(centerAtRectMapped.height * 0.5 - dialog.height * 0.5));
    } else {
      restoreBounds();
    }
  } //function centerDialog()

  function restoreBounds() {
    //restore position so dialog
    if (dialog.parent != null) {
      if (dialog.x + dialog.width > dialog.parent.width) {
        dialog.x = Math.max(0, dialog.parent.width - dialog.width);
      }
      if (dialog.y + dialog.height > dialog.parent.height) {
        dialog.y = Math.max(0, dialog.parent.height - dialog.height);
      }
    }

    //restore with to given limits
    const allowedWidth = clipWidthToLimits(dialog.width);
    const allowedHeight = clipHeightToLimits(dialog.height);
    if (allowedWidth != dialog.width
      || allowedHeight != dialog.height) {
      const possibleNewContentHeight = container.height
        + allowedHeight - dialog.height

      dialog.resizeRequest(
        allowedWidth,
        possibleNewContentHeight
      );
    }
  } //function restoreBounds

  function clipWidthToLimits(requestedWidth: int) : int {
    return Math.min(
      Math.max(dialog.minWidth, centerAtElement ? centerAtElement.width - dialog.x : 0),
      Math.max(dialog.minWidth, requestedWidth),
      TibiaStyle.dialogMaxWidth
    );
  } //function clipWidth

  function clipHeightToLimits(requestedHeight: int) : int {
    return Math.min(
      Math.max(dialog.minHeight, centerAtElement ? centerAtElement.height - dialog.y : 0),
      Math.max(dialog.minHeight, requestedHeight),
      TibiaStyle.dialogMaxHeight
    );
  } //function clipWidth

  onXChanged: posChangedTimer.restart()
  onYChanged: posChangedTimer.restart()

  Timer {
    id: posChangedTimer
    interval: 1
    onTriggered: dialog.posChanged()
  } //Timer

  function posChanged() {
    dialog.restoreBounds();
    dialog.positionChanged(x, y);
  } //function posChanged()

  Keys.onReturnPressed: { defaultReturnAction(); }
  Keys.onEnterPressed:  { defaultReturnAction(); }
  Keys.onCancelPressed: { defaultCancelAction(); }
  Keys.onEscapePressed: { defaultCancelAction(); }
  Keys.onPressed: (event) => { defaultKeyPressedAction(event); }

  FocusScope {
    id: dialogFocusScope
    objectName: "focusElement"
    anchors.fill: parent
    anchors.topMargin: headerLoader.extraHeight + dialog.topPadding
    anchors.leftMargin: dialog.leftPadding
    anchors.rightMargin: dialog.rightPadding

    Loader {
      id: personalMouseShieldLoader
      anchors.fill: parent
      source: dialog.personalMouseShield ? "TibiaMouseShield.qml" : ""
    } //Loader

    MouseArea {
      id: mouseAreaDrag
      anchors { left: parent.left; right: parent.right; top: parent.top}
      height: dialog.showCaption ? TibiaStyle.dialogHeaderLineHeight : 0
      acceptedButtons: Qt.LeftButton | Qt.RightButton

      drag.target: dialog
      drag.axis: Drag.XAndYAxis
      drag.minimumX: 0
      drag.maximumX: dialog.parent!= null
        ? dialog.parent.width - dialog.width
        : drag.maximumX
      drag.minimumY: 0
      drag.maximumY: dialog.parent!= null
        ? dialog.parent.height - dialog.height
        : drag.maximumY

      onClicked: {
        // Prevent strange dialog bouncing when right mouse button is clicked while dragging by eating event
      } //onClicked
    } //MouseArea

    Loader {
      id: dialogFrameLoader
      readonly property var captionContentWidth: item != 0 ? item.captionContentWidth : 0
      readonly property var captionHeight: item != 0 ? item.captionHeight : 0

      sourceComponent: showCaption ? dialogFrameWithCaptionComponent : dialogFrameWithoutCaptionComponent
      anchors.fill: parent

      Component {
        id: dialogFrameWithCaptionComponent
        TibiaDialogFrameWithCaption {
          caption: dialog.flagCaption ? "" : dialog.caption

          RowLayout {
            id: captionFlagLayout
            anchors.left: parent.left
            anchors.right: buttonLayout.left
            spacing: 0

            visible: dialog.flagCaption
            BorderImage {
              Layout.topMargin: -7
              source: "/images/blue-golden-flag-banner.png"
              border { left: 89; top: 0; right: 34; bottom: 0 }
              horizontalTileMode: BorderImage.Repeat

              readonly property int textLeftMargin: 87
              readonly property int textRightMargin: 12

              Layout.maximumWidth: captionFlagLayout.width
              Layout.preferredWidth: textLeftMargin
                + Math.max(70, flagCaptionHidden.contentWidth) //short flags look not nie
                + textRightMargin

              TibiaText {
                id: flagCaption
                anchors.left: parent.left
                anchors.leftMargin: parent.textLeftMargin
                anchors.right: parent.right
                anchors.rightMargin: parent.textRightMargin
                anchors.top: parent.top
                anchors.topMargin: 8

                text: dialog.caption
              } //TibiaText

              TibiaText {
                id: flagCaptionHidden
                text: flagCaption.text
                visible: false
              } //TibiaText
            } //BorderImage

            Item {
              Layout.fillWidth: true
            } //Item
          } //RowLayout

          RowLayout {
            id: buttonLayout
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: parent.borderWidth -1 // buttons are in contact with the frame
            spacing: 4

            Loader {
              id: customButtonComponentLoader
              sourceComponent: dialog.customButtonComponent
            } //Loader

            TibiaIconButton {
              id: xButton
              visible: dialog.showXButton
              sourceUp:   "/images/skin/classic/exit-button-small-up.png"
              sourceDown: "/images/skin/classic/exit-button-small-down.png"
              tooltipText: qsTrId("close_widget_tooltip")
              onClicked: dialog.defaultCancelAction()
            } //TibiaIconButton
          } //RowLayout
        } //TibiaDialogFrameWithCaption
      } //Component dialogFrameWithCaptionComponent

      Component {
        id: dialogFrameWithoutCaptionComponent
        TibiaFrame4Pixel {
          property int captionContentWidth: 0
          property int captionHeight: 0

          TibiaTiledImage {
            anchors.fill: parent
            anchors.margins: parent.borderWidth
            source: "/images/background.png"
          } //BorderImage
        } //TibiaFrame2PixelUpFilled
      } //Component dialogFrameWithoutCaptionComponent
    } //Loader

    //adjust position if size changes and dialog is partly out of the main window
    onHeightChanged: restoreBounds()
    onWidthChanged: restoreBounds()

    //position the dialog in the center of the parent
    Component.onCompleted: {
      dialog.centerDialog();
    } //Component.onCompleted

    Item {
      id: container
      objectName: "dialogContainer"
      anchors {left: parent.left; right: parent.right; top:parent.top;}
      anchors.margins: TibiaStyle.dialogMarginBorder
      anchors.topMargin: dialog.topMarginsToContent

      height: childrenRect.height
      clip: true
    } //Item

    ////////////////////////////////
    // RESIZE HANDLING
    Loader {
      id: resizeLoader
      anchors.right: parent.right
      anchors.bottom: parent.bottom
      anchors.margins: 3

      sourceComponent: dialog.resizeable ? resizeHandler : undefined

      Component {
        id: resizeHandler
        Image {
          id: resizer
          source: "/images/windowresizer.png"
          mirror: true
          smooth: false

          MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            hoverEnabled: true

            property int widthBeforeResize: dialog.width
            property int heightBeforeResize: dialog.height
            property int containerHeightBeforeResize: container.height
            property point globalMouseBeforeResize: Qt.point(0,0)

            function rememberStateBeforeResize(newMousePosition) {
              globalMouseBeforeResize = newMousePosition;
              widthBeforeResize = dialog.width;
              heightBeforeResize = dialog.height
              containerHeightBeforeResize = container.height;

              if(tibiaMouseCursorController != null) {
                tibiaMouseCursorController.setResizeFDiagonal(true);
              }
            } //function rememberStateBeforeResize

            function performResize(pressed, newMousePosition) {
              if(pressed) {
                const mouseChange = Qt.point(
                  newMousePosition.x - globalMouseBeforeResize.x,
                  newMousePosition.y - globalMouseBeforeResize.y);

                const requestedNewHeight = heightBeforeResize + mouseChange.y;
                const possibleNewHeight = clipHeightToLimits(requestedNewHeight);

                const possibleNewContentHeight = containerHeightBeforeResize
                  + possibleNewHeight - heightBeforeResize

                const requestedNewWidth = widthBeforeResize + mouseChange.x;
                const possibleNewWidth = dialog.clipWidthToLimits(requestedNewWidth)

                dialog.resizeRequest(
                  possibleNewWidth,
                  possibleNewContentHeight
                );
              }
            } //function performResize

            onPressed: (mouse) => {
              rememberStateBeforeResize(mapToItem(null, mouse.x, mouse.y));
              dialog.startResizing();
            } //onPressed
            onPositionChanged: (mouse) => {
              performResize(pressed, mapToItem(null, mouse.x, mouse.y));
            } //onPositionChanged
            onEntered: {
              if(tibiaMouseCursorController != null) {
                tibiaMouseCursorController.setResizeFDiagonal(true);
              }
            } //onEntered
            onExited: {
              if(tibiaMouseCursorController != null && !pressed) {
                tibiaMouseCursorController.setResizeFDiagonal(false);
              }
            } //onExited
            onReleased: {
              if(tibiaMouseCursorController != null) {
                tibiaMouseCursorController.setResizeFDiagonal(false);
              }
              dialog.finishResizing();
            } //onReleased
            onVisibleChanged : {
              if(tibiaMouseCursorController != null) {
                tibiaMouseCursorController.setResizeFDiagonal(false);
              }
              dialog.finishResizing();
            } //onVisibleChanged
          }// MouseArea
        } //Image
      } //Component resizeHandler
    } //Loader
    // RESIZE HANDLING
    ////////////////////////////////
  }//FocusScope

  Loader {
    id: headerLoader
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.top
    anchors.bottomMargin: -extraHeight

    // if the item has an bottomMargin property the overlap with the dialogue is considderd
    readonly property int extraHeight: status == Loader.Ready && item !== null
                                      ? height + (item.bottomMargin ?? 0)
                                      : 0

    sourceComponent: dialog.headerDelegate
  } //Loader
} //Item
