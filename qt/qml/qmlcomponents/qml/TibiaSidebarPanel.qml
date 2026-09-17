import QtQuick
import QtQuick.Layouts




MouseArea {
  id: sidebarPanel
  property var panelRoot: this

  default property alias content: sidebarPanelContent.data
  property alias panelController: sidebarPanelContent.controller
  property int extraContentPixel: 0 //TIBIA-29062

  signal positionInSidebarChanged()

  //////////////////////////////////////////////////////////////////////////////////////////////////////
  // UI CHACHING
  property bool allowUICaching: true
  // UI CHACHING
  //////////////////////////////////////////////////////////////////////////////////////////////////////
  // GLOBAL RECOGNITION OF SIDEBAR AS PARENT

  property var parentWhileDragging: sidebarPanel
  onParentChanged: {
    if(parent != null && parent.objectName == "sidebarUpperPane") {
      parentWhileDragging = sidebarPanel.parent.parent;
    } else {
      parentWhileDragging = sidebarPanel;
    }
  } //onParentChanged

  // GLOBAL RECOGNITION OF SIDEBAR AS PARENT
  //////////////////////////////////////////////////////////////////////////////////////////////////////
  // SIZE PARAMETERS
  implicitWidth: TibiaStyle.sidebarWidth - 2*TibiaStyle.sideBarPanelPaneBorderWidth
  Layout.fillWidth: true

  implicitHeight: sidebarPanelContent.childrenRect.height + TibiaStyle.sideBarPanelVerticalDistance

  // SIZE PARAMETERS
  //////////////////////////////////////////////////////////////////////////////////////////////////////
  // DRAG ITEM
  Item {
    id: sidebarPanelContetWrapper
    width: TibiaStyle.sidebarWidth - 2*TibiaStyle.sideBarPanelPaneBorderWidth
    height: sidebarPanelContent.childrenRect.height + TibiaStyle.sideBarPanelVerticalDistance
    z:1 //atop of the drop areas

    //////////////////////////////////////////////////////////////////////////////////////////////////////
    // CONTENT ITEM
    Item {
      id: sidebarPanelContent
      objectName: "sidebarPanelContent"
      anchors.fill: sidebarPanelContetWrapper
      anchors.leftMargin: TibiaStyle.sideBarPanelHorizontalBorderDistance - extraContentPixel
      anchors.rightMargin: TibiaStyle.sideBarPanelHorizontalBorderDistance - extraContentPixel
      anchors.topMargin: TibiaStyle.sideBarPanelVerticalDistance * 0.5 - extraContentPixel
      anchors.bottomMargin: TibiaStyle.sideBarPanelVerticalDistance * 0.5 - extraContentPixel
      z: 1
      layer.enabled: UICachingEnabled

      property QtObject controller: null
    } //Item
    // CONTENT ITEM
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    // DRAG BACKGROUND
    TibiaTiledImage {
      anchors.fill: parent
      source: "/images/background.png"
      visible: parent.Drag.active
      z: 0
    }
    // DRAG BACKGROUND
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    // DRAG PROPETIES

    Drag.keys: TibiaStyle.dragKeySidebarPanel
    Drag.active: sidebarPanel.mouseDragActive
    Drag.source: sidebarPanel

    Drag.hotSpot.x: Math.ceil(sidebarPanel.width * 0.5)

    property real prevY: 0
    property real dragY: 0
    onYChanged: {
      if (Drag.active) {
        // keep track for the snap back animation
        dragY = sidebarPanel.mapFromItem(parentWhileDragging, 0, sidebarPanelContetWrapper.y).y;

        // when moving to the left, the hot spot is the left edge and vice versa
        Drag.hotSpot.y = y < prevY ? 1 : height-1;
        prevY = y;
      }
    } //onXChanged

    state: Drag.active ? "DRAGGING" : ""
    transitions: [
      Transition {
        to: "DRAGGING"
        PropertyAction { target: sidebarPanelContetWrapper; property: "parent"; value: parentWhileDragging }
      }, //Transition
      Transition {
        from: "DRAGGING"
        SequentialAnimation {
          PropertyAction { target: sidebarPanelContetWrapper; property: "parent"; value: sidebarPanel }
          NumberAnimation {
            target: sidebarPanelContetWrapper
            duration: 50
            easing.type: Easing.OutQuad
            property: "y"
            from: sidebarPanelContetWrapper.dragY
            to: 0
          } //NumberAnimation
        } //SequentialAnimation
      } //Transition
    ] //transitions

    // DRAG PROPETIES
    //////////////////////////////////////////////////////////////////////////////////////////////////////
  } //Item

  // DRAG ITEM
  //////////////////////////////////////////////////////////////////////////////////////////////////////
  // DRAG & DROP

  //identifier needed to sort panels within the enclosing GridView
  property int identifier
  Layout.row: identifier

  property bool mouseDragActive: drag.active && pressed
  drag.target: sidebarPanelContetWrapper
  drag.axis: Drag.YAxis
  drag.minimumY: drag.active ? 0 : -Number.MAX_VALUE //trick to allow to drag directly to the top before parent was changed in transition
  drag.maximumY: parentWhileDragging.height - sidebarPanel.height

  function swapPanelsPositionWith(dragSource, upwards) {
    var targetIdentifier = sidebarPanel.identifier;
    var sourceIdentifier = dragSource.identifier;

    var neighbours = areNeighbours(sidebarPanel, dragSource);
    var neighboursSwap = neighbours && ((upwards && (targetIdentifier < sourceIdentifier)) || (!upwards && (targetIdentifier > sourceIdentifier)))

    if (neighboursSwap) {
      //move the second column to avoid duplicated use of the same cell
      sidebarPanel.Layout.column = 1;
      sidebarPanel.identifier = sourceIdentifier;
      dragSource.identifier = targetIdentifier;
      sidebarPanel.Layout.column = 0;
      sidebarPanel.positionInSidebarChanged(); //emit signal
    }
  } //function swapPanelsPositionWith(dragSource)

  function areNeighbours(panel1, panel2) {
    var topPanel = panel1;
    var bottomPanel = panel2;
    if (panel1.identifier > panel2.identifier) {
      topPanel = panel2;
      bottomPanel = panel1;
    }

    return Math.abs((topPanel.y + topPanel.height) - bottomPanel.y) <= 1;
  } //function areNeighbours(panel1, panel2)

  DropArea {
    id: topDropArea
    anchors {right: sidebarPanel.right; left: sidebarPanel.left; top: sidebarPanel.top }
    height: Math.floor(sidebarPanel.height * 0.5)
    z: 0

    enabled: !mouseDragActive

    keys: [ TibiaStyle.dragKeySidebarPanel ]
    onEntered: (drag) => {
      swapPanelsPositionWith(drag.source, true);
    } //onEntered
  } //DropArea

  DropArea {
    id: bottomDropArea
    anchors {right: sidebarPanel.right; left: sidebarPanel.left; bottom: sidebarPanel.bottom }
    height: Math.ceil(sidebarPanel.height * 0.5)
    z: 0

    enabled: !mouseDragActive

    keys: [ TibiaStyle.dragKeySidebarPanel ]
    onEntered: (drag) => {
      swapPanelsPositionWith(drag.source, false);
    } //onEntered
  } //DropArea

  // DRAG & DROP
  //////////////////////////////////////////////////////////////////////////////////////////////////////
} //MouseArea
