import QtQuick
import QtQuick.Layouts

import qmlcomponents



TibiaSidebarPanel {
  id: inventorySidebarWidget

  signal slotClicked(int SlotID, int MouseButton, int KeyboardModifier)
  signal slotEntered(int SlotID)
  signal slotExited(int SlotID)
  signal slotStartDrag(int SlotID, QtObject Source)
  signal slotDragDropped(int SlotID)
  signal slotTargetSelected(int SlotID)
  signal stopClicked()
  signal showCapacityWarningTooltip()
  signal hideCapacityWarningTooltip()

  property int soulpointsValue: 0
  property int capacityValue: 0
  property bool hasZeroCapacity: false
  property bool hasCapacityBoost: false
  property int loadedInventorySlots: 0
  property alias playerStates: statesBar.playerStatesList
  property bool adventurersBlessing: false
  property string blessingButtonColor: "grey"
  property string blessingButtonTooltip: ""
  property var leftSideContainerSlots
  property var middleContainerSlots
  property var rightSideContainerSlots
  property bool inventoryMinimizedInController: false
  property var lastShownCapacityWarningTimestamp: 0

  property bool applyDualWielding : panelController ? panelController.hasDualWielding : false
  property int dualWieldingObjectID: panelController ? panelController.dualWieldingObjectID : 0

  property var inventoryContainerSlotsModel

  onInventoryContainerSlotsModelChanged: {
    leftSideContainerSlots  = [inventoryContainerSlotsModel[2],   // NECK = 2,
                               inventoryContainerSlotsModel[6],   // LEFT_HAND = 6
                               inventoryContainerSlotsModel[9]];  // FINGER = 9
    middleContainerSlots    = [inventoryContainerSlotsModel[1],   // HEAD = 1,
                               inventoryContainerSlotsModel[4],   // TORSO = 4,
                               inventoryContainerSlotsModel[7],   // LEGS = 7,
                               inventoryContainerSlotsModel[8]];  // FEET = 8,
    rightSideContainerSlots = [inventoryContainerSlotsModel[3],   // BACK = 3,
                               inventoryContainerSlotsModel[5],   // RIGHT_HAND = 5
                               inventoryContainerSlotsModel[10]]; // HIP = 10
  } //onInventoryContainerSlotsModelChanged

  states: [
    State {
      name: "" // Regular inventory state
      StateChangeScript {
        name: "maximizeStateEntered"
        script: {
          if (panelController != null) {
            panelController.inventoryMinimized = false;
          }
        }
      }
    },
    State {
      name: "MINIMIZED"
      PropertyChanges { target: statusBar; width: 108 }
      PropertyChanges { target: combatControls; state: "MINIMIZED" }
      StateChangeScript {
        name: "minimizeStateEntered"
        script: {
          if (panelController != null) {
            panelController.inventoryMinimized = true;
          }
        }
      }
    } //State
  ] //states

  onPanelControllerChanged: {
    if (panelController != null) {
      soulpointsValue = Qt.binding(function() { return panelController.soulpoints; });
      capacityValue = Qt.binding(function() { return panelController.capacity; });
      hasZeroCapacity = Qt.binding(function() { return panelController.hasZeroCapacity; });
      hasCapacityBoost = Qt.binding(function() { return panelController.hasCapacityBoost; });
      playerStates = Qt.binding(function() { return panelController.showPlayerStatesInBar ? panelController.playerStates : null; });
      adventurersBlessing = Qt.binding(function() { return panelController.adventurersBlessing; });
      blessingButtonColor = Qt.binding(function() { return panelController.blessingButtonColor; });
      blessingButtonTooltip = Qt.binding(function() { return panelController.blessings; });
      inventoryMinimizedInController = Qt.binding(function() { return panelController.inventoryMinimized; });
      combatControls.panelController = panelController
    } else {
      soulpointsValue = 0;
      capacityValue = 0;
      hasZeroCapacity = false;
      hasCapacityBoost = false;
      playerStates = null;
      adventurersBlessing = false;
      combatControls.panelController = null;
      blessingButtonColor = "grey";
      blessingButtonTooltip = "";
      inventoryMinimizedInController = false;
    }
  } //onPanelControllerChanged

  onInventoryMinimizedInControllerChanged: {
    inventorySidebarWidget.state = inventoryMinimizedInController ? "MINIMIZED" : "";
  }

  Component {
    id: containerSlotTemplate
    ContainerSlot {
      slotID: modelData.slotID
      slotText: modelData.text
      managedContainerTooltipText: modelData.managedContainerTooltip

      opacity: (applyDualWielding && modelData.slotID == 5) ? 0.5 : 1

      objectAppearanceInstanceTypeId: (applyDualWielding && modelData.slotID == 5) ? dualWieldingObjectID : modelData.objectID
      objectAppearanceInstanceCumulativeCount: modelData.objectCount
      objectAppearanceInstanceLiquidType: modelData.liquidType
      objectAppearanceInstanceHookDirection: modelData.hookDirection
      objectAppearanceInstanceUpgradeTier: modelData.upgradeTier

      acceptsDrop: modelData.acceptsDrop
      slotBackgroundImageSource: modelData.backgroundImage
      showGoldenBorder: adventurersBlessing
      tutorialMarkerID: modelData.tutorialMarkerID


      mirrorImage : (applyDualWielding && modelData.slotID == 5) ? (true) : false

      Component.onCompleted: {
        clicked.connect(inventorySidebarWidget.slotClicked);
        entered.connect(inventorySidebarWidget.slotEntered);
        exited.connect(inventorySidebarWidget.slotExited);
        startDrag.connect(inventorySidebarWidget.slotStartDrag);
        dragDropped.connect(inventorySidebarWidget.slotDragDropped);
        targetSelected.connect(inventorySidebarWidget.slotTargetSelected);
      } //Component.onCompleted
      onContainsDragChanged: { }
    } //ContainerSlot
  } //Component

  Connections {
    id: panelControllerConnections
    target: panelController
    function onShowCapacityWarning() {
      const TWO_MINUTES = 2 * 60;
      let currentTimestamp = new Date().getTime() / 1000;
      if(lastShownCapacityWarningTimestamp + TWO_MINUTES < currentTimestamp) {
        lastShownCapacityWarningTimestamp = currentTimestamp;
        showCapacityWarningTooltip();
      }
    }
    function onGamesessionDisconnected() {
      lastShownCapacityWarningTimestamp = 0;
      hideCapacityWarningTooltip();
    }
  }

  Component {
    id: capacityWarningTooltipComponent

    Rectangle {
      id: capacityWarningTooltip
      property bool isFirstCapacityWarning: true
      property var _originalParent: null

      width: capacityWarningTextWrapper.width
      height: capacityWarningTextWrapper.height

      Timer {
        interval: 100
        running: true
        repeat: true
        onTriggered: () => {
          repositionTooltip();
        }
      }

      border.width: 1
      border.color: "black"
      color: TibiaStyle.tooltipBackgroundColor
      ColumnLayout {
        id: capacityWarningTextWrapper
        TibiaText {
          id: capacityWarningText
          wrapMode: Text.Wrap
          text: qsTrId("inventory_capacity_warning1")
          styleType: "MessageCritical"
          Layout.margins: TibiaStyle.tooltipBorderMargin
          Layout.fillWidth: true
          Layout.maximumWidth: TibiaStyle.sidebarWidth
        }
      }
      MouseArea {
        anchors.fill: parent
        onClicked: {
          if (capacityWarningTooltip.isFirstCapacityWarning) {
            capacityWarningTooltip.isFirstCapacityWarning = false;
            capacityWarningText.text = qsTrId("inventory_capacity_warning2")
          } else {
            hideTooltip();
          }
        }
      }
      Component.onCompleted: {
        _originalParent = capacityWarningTooltip.parent

        let window = TooltipHelper.findWindowContentItemForQuickItem(this);
        if (window) {
          capacityWarningTooltip.parent = window;
          repositionTooltip();
        }
      }
      function repositionTooltip() {
        let window = TooltipHelper.findWindowContentItemForQuickItem(this);
        if (!window) {
          return;
        }
        let point = _originalParent.mapToItem(parent, 0,_originalParent.parent.height);
        var newX = point.x;
        var newY = point.y;
        newX = Math.max(0, Math.min(newX, window.width - this.width));
        newY = Math.max(0, Math.min(newY, window.height - this.height));
        x = newX;
        y = newY;
      }

      function hideTooltip() {
        inventorySidebarWidget.hideCapacityWarningTooltip();
      }
    }
  }

  RowLayout {
    id: wrapper
    anchors {left: parent.left; top: parent.top}
    spacing: 0

    Component {
      id: soulOrCapacityComponent
      Item {
        property string slotCaption: "caption"
        property string slotText: "text"
        property string slotStyleType: "InventoryOverlay"
        property alias borderImageVisible: borderImage.visible
        property alias tooltipText: tooltip.text

        width: 34
        height: 20
        Optimized1PixelBorderImage {
          id: borderImage
          anchors.fill: parent
          borderimagesource: "/images/containerslot.png"
        } // OptimizedBorderImage1PixelBorder
        TibiaText {
          id: textCaption
          text: slotCaption
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.top: parent.top
          anchors.topMargin: -1
          styleType: "InventoryOverlay"
          font.weight: Font.ExtraBold
          font.pixelSize: 8
        } //TibiaText
        TibiaText {
          text: slotText
          transform: Scale {xScale: 0.8; origin.x: 17}
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.top: textCaption.bottom
          anchors.topMargin: -3
          styleType: slotStyleType
          renderType: Text.QtRendering
        } //TibiaText

        Tooltip {
          id: tooltip
          anchors.fill: parent
          maxWidth: TibiaStyle.tooltipRestrictedWidth
        } //Tooltip
      } //Item
    } // Component

    Loader {
      Layout.preferredWidth: inventoryMinimizedInController ? 46 : TibiaStyle.minimapViewportWidth
      Layout.preferredHeight: inventoryMinimizedInController ? 42 : 142

      sourceComponent: inventoryMinimizedInController ? inventoryMinimizedComponent : inventoryMaximizedComponent
    }

    Component {
      id: inventoryMaximizedComponent

      Item {
        id: inventoryMaximized

        TibiaIconButton {
          id: minButton
          sourceUp:   "/images/skin/classic/min-button-small-up.png"
          sourceDown: "/images/skin/classic/min-button-small-down.png"
          tooltipText: qsTrId("inventory_minimize_inventory_tooltip")
          onClicked: { inventorySidebarWidget.state = "MINIMIZED"; }
        } //TibiaIconButton

        TibiaIconButton {
          id: iconBlessingMaximized
          anchors.left: minButton.right
          anchors.leftMargin: 2
          sourceUp: "/images/blessings/button-blessings-" + blessingButtonColor + "-idle.png"
          sourceDown: "/images/blessings/button-blessings-" + blessingButtonColor + "-pressed.png"

          onClicked: {
            if (panelController != null) {
              panelController.onBlessingsButtonClicked();
            }
          }

          Tooltip {
            anchors.fill: parent
            text: blessingButtonTooltip
          } //Tooltip

          Lenshelp {
            anchors.fill: parent
            z: 100
            caption: qsTrId("inventory_blessing_lenshelp_caption")
            content: qsTrId("inventory_blessing_lenshelp")
          } //Lenshelp
        } // TibiaIconButton

        TibiaIconButton {
          anchors.right: parent.right
          sourceUp:   "/images/button-store-inbox-up.png"
          sourceDown: "/images/button-store-inbox-down.png"
          Layout.alignment: Qt.AlignVCenter
          tooltipText: qsTrId("inventory_store_inbox_button_tooltip")
          onClicked: panelController!=null ?  panelController.onStoreInboxButtonClicked() : undefined

          Lenshelp {
            anchors.fill: parent
            z: 100
            caption: qsTrId("inventory_store_inbox_lenshelp_caption")
            content: qsTrId("inventory_store_inbox_lenshelp")
          } //Lenshelp
        } //TibiaIconButton

        Row {
          spacing: 3
          Column {
            spacing: 2

            Item {
              height: 12
              width: 1
            } //Item

            Repeater {
              model: leftSideContainerSlots
              delegate: containerSlotTemplate;
            } //Repeater

            Loader {
              sourceComponent: soulOrCapacityComponent
              onLoaded: {
                item.slotCaption = qsTrId("inventory_soulpoints");
                item.slotText = Qt.binding(function() { return soulpointsValue; }) ;
                item.tooltipText = qsTrId("inventory_soulpoints_tooltip");
              } //onLoaded

              Lenshelp {
                anchors.fill: parent
                z: 100
                caption: qsTrId("inventory_soulpoints_lenshelp_caption")
                content: qsTrId("inventory_soulpoints_lenshelp")
              } //Lenshelp
            } //Loader
          } //Column
          Column {
            spacing: 2
            Repeater {
              model: middleContainerSlots
              delegate: containerSlotTemplate;
            } //Repeater
          } //Column
          Column {
            spacing: 2
            Item {
              height: 12
              width: 1
            } //Item
            Repeater {
              model: rightSideContainerSlots
              delegate: containerSlotTemplate;
            } //Repeater
            Item {
              id: capacityWrapper
              width: capacityComponentLoader.width
              height: capacityComponentLoader.height
                Loader {
                id: capacityComponentLoader
                sourceComponent: soulOrCapacityComponent
                onLoaded: {
                  item.slotCaption = qsTrId("inventory_capacity");
                  item.slotText = Qt.binding(function() { return capacityValue; }) ;
                  item.slotStyleType = Qt.binding(function() { return hasZeroCapacity ? "ModifierZero" : (hasCapacityBoost ? "ModifierPositive"
                                                                                                                          : "InventoryOverlay"); });
                  item.tooltipText = qsTrId("inventory_capacity_tooltip")
                } //onLoaded

                Loader {
                  id: capacityWarningTooltipLoader
                  //anchors.fill: capacityComponentLoader

                  Connections {
                    target: inventorySidebarWidget
                    function onShowCapacityWarningTooltip() {
                      capacityWarningTooltipLoader.sourceComponent = capacityWarningTooltipComponent;
                    }
                    function onHideCapacityWarningTooltip() {
                      capacityWarningTooltipLoader.sourceComponent = undefined;
                    }
                  }
                  onLoaded: {
                    Qt.callLater( () => {
                      // must be called asynchronously to get the correct layout position
                      //item.showTooltip();
                      // item.onTooltipVisibleChanged.connect( () => {
                      //   if (item && !item.tooltipVisible) {
                      //     capacityWarningTooltipLoader.sourceComponent = undefined;
                      //   }
                      // });
                    });
                  }
                } //Loader

              } //Loader
              Lenshelp {
                anchors.fill: parent
                z: 100
                caption: qsTrId("inventory_capacity_lenshelp_caption")
                content: qsTrId("inventory_capacity_lenshelp")
              } //Lenshelp
            } // Item
          } //Column
        } //Row

        Lenshelp {
          anchors.fill: parent
          triggerRect: mapFromItem(panelRoot, 0, 0, panelRoot.width, panelRoot.height)
          z: -1
          caption: qsTrId("inventory_lenshelp_caption")
          content: qsTrId("inventory_lenshelp")
        } //Lenshelp

      }  // inventory maximized
    } // Component

    Component {
      id: inventoryMinimizedComponent

      Item {
        id: inventoryMinimized

        TibiaIconButton {
          id: maxButton
          anchors {left: parent.left; top: parent.top }
          sourceUp:   "/images/skin/classic/max-button-small-up.png"
          sourceDown: "/images/skin/classic/max-button-small-down.png"
          tooltipText: qsTrId("inventory_maximize_inventory_tooltip")
          onClicked: { inventorySidebarWidget.state = ""; }
        } //TibiaIconButton

        TibiaIconButton {
          id: enableExpertMode
          anchors {left: parent.left; bottom: parent.bottom }
          sourceUp: enabled ? "/images/button-expert-small-up.png" : "/images/button-expert-small-disabled.png";
          sourceDown: enabled ? "/images/button-expert-small-down.png" : "/images/button-expert-small-disabled.png";
          tooltipText: qsTrId("inventory_expert_button_tooltip")

          enabled: combatControls.exportModeButtonEnable
          onEnabledChanged: {
            combatControls.expertModeEnabled = false;
          } //onEnabledChanged

          checkable: true

          onClicked: {
            combatControls.expertModeEnabled = !combatControls.expertModeEnabled;
          } //onClicked

          buttonShouldBeChecked: combatControls.expertModeEnabled
          useButtonShouldBeChecked: true

          Lenshelp {
            anchors.fill: parent
            z: 100
            triggerRect: mapFromItem(panelRoot, 0, 0, panelRoot.width, panelRoot.height)
            caption: qsTrId("inventory_expert_button_lenshelp_caption")
            content: qsTrId("inventory_expert_button_lenshelp")
          } //Lenshelp
        } //TibiaIconButton

        Optimized1PixelBorderImage {
          id: borderImage
          anchors.fill: parent
          anchors.leftMargin: 14
          borderimagesource: "/images/containerslot.png"
          Rectangle {
            id: highlightBorder
            anchors.fill: parent
            color: "transparent"
            border.color: "white"
            border.width: 1
            z: 999
            visible: minimizedInventoryDropArea.containsDrag
          } //Rectangle

          TibiaObjectDropArea {
            id: minimizedInventoryDropArea
            anchors.fill: parent
            onDropped: {
              inventorySidebarWidget.slotDragDropped(0); // 0 = Any Inventoryslot
            } //onDropped
          } //TibiaObjectDropArea

          Column {
            spacing: 2
            Loader {
              sourceComponent: soulOrCapacityComponent
              onLoaded: {
                item.slotCaption = qsTrId("inventory_capacity");
                item.borderImageVisible = false;
                item.slotText = Qt.binding(function() { return capacityValue; }) ;
                item.slotStyleType = Qt.binding(function() { return hasZeroCapacity ? "ModifierZero" : (hasCapacityBoost ? "ModifierPositive"
                                                                                                                         : "InventoryOverlay"); });
              } //onLoaded
              Loader {
                id: capacityWarningTooltipLoader
                anchors.fill: parent

                Connections {
                  target: inventorySidebarWidget
                  function onShowCapacityWarningTooltip() {
                    capacityWarningTooltipLoader.sourceComponent = capacityWarningTooltipComponent;
                  }
                }

                onLoaded: {
                  Qt.callLater( () => {
                    // must be called asynchronously to get the correct layout position
                    item.showTooltip();
                    item.onTooltipVisibleChanged.connect( () => {
                      if (!item.tooltipVisible) {
                        capacityWarningTooltipLoader.sourceComponent = undefined;
                      }
                    });
                  });
                }
              } //Loader

              Lenshelp {
                anchors.fill: parent
                z: 100
                caption: qsTrId("inventory_capacity_lenshelp_caption")
                content: qsTrId("inventory_capacity_lenshelp") + qsTrId("inventory_minimized_lenshelp")
              } //Lenshelp
            } //Loader

            Loader {
              sourceComponent: soulOrCapacityComponent
              onLoaded: {
                item.slotCaption = qsTrId("inventory_soulpoints");
                item.borderImageVisible = false;
                item.slotText = Qt.binding(function() { return soulpointsValue; }) ;
              } //onLoaded

              Lenshelp {
                anchors.fill: parent
                z: 100
                caption: qsTrId("inventory_soulpoints_lenshelp_caption")
                content: qsTrId("inventory_soulpoints_lenshelp") + qsTrId("inventory_minimized_lenshelp")
              } //Lenshelp
            } //Loader
          } // Column
        } //BorderImage

        Lenshelp {
          anchors.fill: parent
          triggerRect: mapFromItem(panelRoot, 0, 0, panelRoot.width, panelRoot.height)
          z: -1
          caption: qsTrId("inventory_minimized_lenshelp_caption")
          content: qsTrId("inventory_minimized_lenshelp")
        } //Lenshelp
      }  // inventory minimized
    } // Component
  } //Row wrapper

  CombatControls {
    id: combatControls

    anchors { right: parent.right; top: parent.top }
  } //CombatControls

  RowLayout {
    id: statusBar
    anchors {left: parent.left; top: wrapper.bottom; topMargin: 2}
    width: TibiaStyle.minimapViewportWidth
    spacing: TibiaStyle.marginNarrow

    TibiaIconButton {
      id: iconBlessingMinimized
      Layout.alignment: Qt.AlignTop
      sourceUp: "/images/blessings/button-blessings-" + blessingButtonColor + "-idle.png"
      sourceDown: "/images/blessings/button-blessings-" + blessingButtonColor + "-pressed.png"
      visible: inventoryMinimizedInController

      onClicked: {
        if (panelController != null) {
          panelController.onBlessingsButtonClicked();
        }
      }

      Tooltip {
        anchors.fill: parent
        text: blessingButtonTooltip
      } //Tooltip

      Lenshelp {
        anchors.fill: parent
        caption: qsTrId("inventory_blessing_lenshelp_caption")
        content: qsTrId("inventory_blessing_lenshelp")
      } //Lenshelp
    } //Image

    StatesBar {
      id: statesBar
      Layout.fillWidth: true

      //playerStatesList set by alias property
      Lenshelp {
        anchors.fill: parent
        caption: qsTrId("inventory_states_lenshelp_caption")
        content: qsTrId("inventory_states_lenshelp")
      } //Lenshelp
    } // StatesBar
  } //RowLayout

  TibiaButton {
    text: qsTrId("inventory_stop_button")
    textYOffset: -1
    height: statusBar.height
    width: TibiaStyle.sideBarPanelRightSideWith
    anchors { right: parent.right; top: statusBar.top }
    tooltipText: qsTrId("inventory_stop_tooltip")
    onClicked: {
      inventorySidebarWidget.stopClicked();
    } //onClicked

    Lenshelp {
      anchors.fill: parent
      caption: qsTrId("inventory_stop_lenshelp_caption")
      content: qsTrId("inventory_stop_lenshelp")
    } //Lenshelp
  } //TibiaButton
} //TibiaSidebarPanel
