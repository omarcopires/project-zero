import QtQuick

import qmlcomponents


Item {
  id: containerSlot

  property int slotID
  property alias slotText: slotTextItem.text
  property alias slotTooltip: itemTooltip.text
  property alias managedContainerTooltipText: managedContainerTooltip.text
  property string slotBackgroundImageSource
  property bool showGoldenBorder: false
  property bool showSelectionBorder: false
  property bool isInManualSortMode: false
  property bool containsDrag
  property bool containsMouse: false
  property int tutorialMarkerID: 0;
  property alias mouseAreaEnabled: containerMouseArea.enabled
  property alias slotBackgroundVisible: containerSlotBorder.visible
  property string lootvalueImageSourceUnderItem: ""
  property string lootvalueImageSourceOverItem: ""

  property int objectAppearanceInstanceTypeId: 0
  property int objectAppearanceInstanceUpgradeTier: 0
  property int objectAppearanceInstanceCumulativeCount: 0
  property int objectAppearanceInstanceLiquidType: ObjectAppearanceInstance.EMPTY
  property int objectAppearanceInstanceHookDirection: ObjectAppearanceInstance.NONE
  property int objectAppearanceInstanceDecoItemObjectID: 0

  property bool acceptsDrop: false
  property bool isUpdatable: true
  property bool showPointingHandCursor: false
  property bool forceShowDropMarker: false

  property bool showProficiencyLevel: false
  property bool hasProficiencyMastery: false
  property int proficiencyLevel: 0

  property bool mirrorImage: false

  property bool _highlightBorderVisible: false

  onAcceptsDropChanged: {
    slotDropAreaLoader.sourceComponent = acceptsDrop ? dropAreaComponent : null
    if (!acceptsDrop) {
      containerSlot._highlightBorderVisible = false;
      containerSlot.containsDrag = false;
    }
  } //onAcceptsDropChanged

  onTutorialMarkerIDChanged: {
    tutorialMarkerLoader.sourceComponent = tutorialMarkerID != 0 ? tutorialMarkerComponent : null
  } //onAcceptsDropChanged

  signal clicked(int SlotID, int MouseButton, int KeyboardModifier)
  signal doubleClicked(int SlotID, int MouseButton, int KeyboardModifier)
  signal entered(int SlotID)
  signal exited(int SlotID)
  signal targetSelected(int SlotID)
  signal startDrag(int SlotID, QtObject Source)
  signal dragDropped(int SlotID)

  implicitHeight: TibiaStyle.containerSlotSize
  implicitWidth: implicitHeight

  Loader {
    Component {
      id: highlightBorderComponent
      Rectangle {
        id: highlightBorder
        color: "transparent"
        border.color: isUpdatable ? "white" : "red"
        border.width: 1
      } //Rectangle
    }
    z: 999
    anchors.fill: parent
    sourceComponent: forceShowDropMarker || showSelectionBorder || _highlightBorderVisible ? highlightBorderComponent : undefined
  }

  property real lastMouseX: 0
  property real lastMouseY: 0
  property int lastPressedX: -1
  property int lastPressedY: -1
  property bool alreadyStartedDragging: false

  function onSlotEntered() {
    containerSlot.entered(slotID);
    if (showPointingHandCursor && tibiaMouseCursorController != null) {
      tibiaMouseCursorController.setPointingHand(true);
      containsMouse = true;
    }
  } //function onSlotEntered()
  function onSlotExited() {
    containerSlot.exited(slotID);
    if (showPointingHandCursor && tibiaMouseCursorController != null) {
      tibiaMouseCursorController.setPointingHand(false);
      containsMouse = false;
    }
  } //function onSlotExited()

  function isDecoItemKit() {
    return objectAppearanceInstanceDecoItemObjectID > 0;
  }

  Component {
    id: dropAreaComponent
    TibiaObjectDropArea {
      id: slotDropArea
      anchors.fill: parent
      anchors.leftMargin: -1 * TibiaStyle.containerSlotsMargin
      anchors.topMargin: -1 * TibiaStyle.containerSlotsMargin

      onDropped: {
        if (isUpdatable) {
          containerSlot.dragDropped(slotID);
        }
      } //onDropped

      onEntered: {
        containerSlot.onSlotEntered()
      } //onEntered
      onExited: {
        containerSlot.onSlotExited();
      } //onExited

      Component.onCompleted: {
        containerSlot._highlightBorderVisible = Qt.binding(function() { return containsDrag; });
        containerSlot.containsDrag = Qt.binding(function() { return containsDrag; });
      } //Component.onCompleted
    } //TibiaObjectDropArea
  } //Component

  Component {
    id: tutorialMarkerComponent
    TibiaTutorialMarker {
      anchors.fill: parent
      markerID: containerSlot.tutorialMarkerID
    } //TibiaTutorialMarker
  } //Component

  MouseArea {
    id: containerMouseArea
    anchors.fill: parent
    drag.threshold: TibiaStyle.dragThreshold
    acceptedButtons: Qt.RightButton | Qt.LeftButton

    property bool dualMouseClickEmulationActive: false

    onClicked: (mouse) => {
      if (!alreadyStartedDragging && mouse.buttons == 0) {
        if (!dualMouseClickEmulationActive) {
          containerSlot.clicked(slotID, mouse.button, mouse.modifiers);
        } else {
          // Left+Right is mapped to MiddleMouse
          containerSlot.clicked(slotID, Qt.MiddleButton, Qt.NoModifier);
        }
      }
    } //onClicked

    onDoubleClicked: (mouse) => {
      containerSlot.doubleClicked(slotID, mouse.button, mouse.modifiers);
    } //onClicked

    onPressed: (mouse) => {
      lastPressedX = mouse.x;
      lastPressedY = mouse.y;
      alreadyStartedDragging = false;
      if (mouse.buttons == (Qt.LeftButton | Qt.RightButton)) {
        dualMouseClickEmulationActive = true;
      } else {
        dualMouseClickEmulationActive = false;
      }
    } //onPressed

    onPositionChanged: (mouse) => {
      if (mouse.buttons == Qt.LeftButton && !alreadyStartedDragging) {
        var dragDistance = Math.sqrt(Math.pow(lastPressedX - mouse.x, 2) + Math.pow(lastPressedY - mouse.y, 2));
        if (dragDistance >= drag.threshold) {
          alreadyStartedDragging = true;
          containerSlot.startDrag(slotID, containerMouseArea);
        }
      }
    } //onPositionChanged

    hoverEnabled: !dummyLenshelpToDetectLenshelpMode.enabled
    onEntered: {
      containerSlot.onSlotEntered();
    } //onEntered
    onExited: {
      containerSlot.onSlotExited();
    } //onExited

    Tooltip {
      id: itemTooltip
      anchors.fill: parent
      enabled: text != null && text != ""
      onHoverEnter: { if (showPointingHandCursor && tibiaMouseCursorController != null) { tibiaMouseCursorController.setPointingHand(true); } }
      onHoverLeave: { if (showPointingHandCursor && tibiaMouseCursorController != null) { tibiaMouseCursorController.setPointingHand(false); } }
    } // Tooltip
  } //MouseArea

  Lenshelp {
    // The MouseArea above interferes with the lenshelp mechanism due to ist "hoverEnabled: true" property.
    // This zero-size Lenshelp element exists to detect when the lenshelp mode becomes active. When that happens,
    // the hoverEnabled property of the MouseArea above gets deactivated, in order to stop interfering with other
    // Lenshelp elements' mouse-hover detection mechanism.
    id: dummyLenshelpToDetectLenshelpMode
  } //Lenshelp

  Loader {
    id: slotDropAreaLoader
    anchors.fill: parent
  } //Loader

  TibiaTargetSelection {
    anchors.fill: parent
    onTargetSelected: {
      containerSlot.targetSelected(slotID);
    } //onTargetSelected
  } //TibiaTargetSelection

  Loader {
    id: tutorialMarkerLoader
    anchors.fill: parent
    onLoaded: {
      item.markerID = Qt.binding(function() { return tutorialMarkerID });
    } //onLoaded
    z: 999
  } //Loader

  Optimized1PixelBorderImage {
    id: containerSlotBorder
    anchors.fill: parent
    borderimagesource: "/images/containerslot.png"
  } // OptimizedBorderImage1PixelBorder

  Loader {
    Component {
      id: goldenBorderComponent
      BorderImage {
        id: goldenBorder
        border { left: 1; top: 1; right: 1; bottom: 1 }
        horizontalTileMode: BorderImage.Stretch
        verticalTileMode: BorderImage.Stretch
        source: "/images/containerslot-goldenborder.png"
        smooth: false
      } //BorderImage
    } // Component
    sourceComponent: showGoldenBorder ? goldenBorderComponent : undefined
    anchors.fill: parent
  }


  Item {
    id: slotInner
    anchors.fill: parent
    anchors.margins: containerSlot.slotBackgroundVisible ? 1 : 0

    Loader {
      Component {
        id: lootvalueImageUnderItemComponent
        Image {
          id: glowBorder
          source: lootvalueImageSourceUnderItem
          smooth: false
        } //BorderImage
      }
      sourceComponent: lootvalueImageSourceUnderItem != "" ? lootvalueImageUnderItemComponent : undefined
    }

    Image {
      id: slotEmptyPicture
      anchors.fill: parent
      source: slotBackgroundImageSource
      visible: appearanceLoader.sourceComponent == undefined
      smooth: false
    } //Image

    Loader {
      id: appearanceLoader
      anchors.fill: parent
      sourceComponent: containerSlot.objectAppearanceInstanceTypeId != 0 ? appearanceInstanceRendererComponent
                                                                         : undefined

      Component {
        id: appearanceInstanceRendererComponent
        SingleObjectAppearanceInstanceRenderer {
          id: bodyslotRenderer
          animated: true
          typeid: containerSlot.objectAppearanceInstanceTypeId
          cumulativeCount: containerSlot.objectAppearanceInstanceCumulativeCount
          liquidType: containerSlot.objectAppearanceInstanceLiquidType
          hookDirection: containerSlot.objectAppearanceInstanceHookDirection
          decoItemObjectID: containerSlot.objectAppearanceInstanceDecoItemObjectID

          transform: [
            Matrix4x4 {
              matrix: mirrorImage ? Qt.matrix4x4(-1, 0, 0, bodyslotRenderer.width, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1) : Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
            }
          ]
        } //SingleObjectAppearanceInstanceRenderer
      } //Component
    } //Loader

    TibiaCachedOutlineText {
      id: slotTextItem
      anchors { left: parent.left; leftMargin: -1;
                right: parent.right;
                bottom: parent.bottom }
      styleType: "InventoryOverlay"
      horizontalAlignment: Text.AlignRight
      font: slotTextItemSizeMeasurement.truncated ? TibiaStyle.defaultTightFont : TibiaStyle.defaultTextFont

      TibiaTextBase {
        id: slotTextItemSizeMeasurement
        anchors.fill: parent
        visible: false
        text: parent.text
        styleType: parent.styleType
        horizontalAlignment: parent.horizontalAlignment
        font: TibiaStyle.defaultTextFont
      } //TibiaTextBase
    } //TibiaCachedOutlineText

    Image {
      id: lootContainerIcon
      anchors { right: parent.right; bottom: parent.bottom; top: undefined}
      anchors.margins: 1
      source: containerSlot.isDecoItemKit() ? "/images/icon-boxed.png" : "/images/icon-loot-container.png"
      visible: managedContainerTooltip.text != "" || containerSlot.isDecoItemKit()
      smooth: false
      Tooltip {
        id: managedContainerTooltip
        anchors.fill: parent
      } //Tooltip

      states: State {
        name: "anchoredToTop"
        when: slotTextItem.text.length > 0

        AnchorChanges {
          target: lootContainerIcon
          anchors.bottom: undefined
          anchors.top: lootContainerIcon.parent.top
        }
      } // State
    } // Image

    Loader {
      Component {
        id: lootvalueImageOverItemComponent
        Image {
          id: glowBorder
          source: lootvalueImageSourceOverItem
          smooth: false
        } //BorderImage
      } //Component
      sourceComponent: lootvalueImageSourceOverItem != "" ? lootvalueImageOverItemComponent : undefined
    } //Loader

    Loader {
      anchors.top: parent.top
      anchors.right: parent.right
      Component {
        id: upgradeTierComponent
        Image {
          source: "image://upgrade-tiers/" + (objectAppearanceInstanceUpgradeTier-1)
          smooth: false
        } //Image
      } //Component
      sourceComponent: objectAppearanceInstanceUpgradeTier > 0 ? upgradeTierComponent : undefined
    } //Loader

    Loader {
      id: proficiencyLevelLoader
      anchors.fill: slotInner
      anchors.leftMargin: 1
      anchors.bottomMargin: 1
      Component {
        id: proficiencyLevelComponent
        Repeater {
          model: containerSlot.proficiencyLevel
          Image {
            required property int index

            anchors.bottom: parent.bottom
            x: index * sourceSize.width - index
            source: containerSlot.hasProficiencyMastery
              ? "/images/proficiency/icon-star-tiny-gold.png"
              : "/images/proficiency/icon-star-tiny-silver.png"
            visible: (index + 1) <= containerSlot.proficiencyLevel
            smooth: false
          } //Image
        } //Repeater
      } //Component
      sourceComponent: containerSlot.showProficiencyLevel ? proficiencyLevelComponent : undefined
    } //Loader

  } //Item
} // Item
