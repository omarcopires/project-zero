import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qmlcomponents



TibiaSidebarWidget {
  id: root
  caption: qsTrId("depot_search_caption")
  picSource: "/images/icon-widget-search.png"

  initialContentHeight: 350
  minContentHeight: Math.max(searchResultLayout.Layout.minimumHeight, detailListLayout.Layout.minimumHeight)
  maxContentHeight: 392 //enough to show a full 32 slot detail list
  levelUpButtonVisible: root.showDetailList
  highlightFocus: widgetController != null && widgetController.hasFocus

  readonly property bool showDetailList: widgetController != null && widgetController.showDetailList
  readonly property int totalCountDepot: widgetController != null ? widgetController.totalCountDepot : 0
  readonly property int totalCountStash: widgetController != null ? widgetController.totalCountStash : 0
  readonly property int totalCountInbox: widgetController != null ? widgetController.totalCountInbox : 0

  function categoryListSelectionRequest(Index) {
    if (widgetController != null) {
      if (Index > -1) {
        itemSelection.selectCategoryIndex(Index);
      }
    }
  } //function categoryListSelectionRequest(Index)

  onWidgetControllerChanged: {
    if (widgetController != null) {
      widgetController.requestWidgetControlToTakeFocus.connect(itemSelection.setFocusToSearchTextField);
      widgetController.categoryListSelectionRequest.connect(root.categoryListSelectionRequest);
    }
  } //onWidgetControllerChanged



  ColumnLayout {
    id: searchResultLayout
    anchors.fill: parent
    spacing: TibiaStyle.marginRelated
    visible: !root.showDetailList

    MarketCategorySelection {
      id: itemSelection
      Layout.fillWidth: true
      Layout.fillHeight: true

      widgetLayout: true
      useObjectCount: true
      categoryViewHeight: TibiaStyle.cyclopediaObjectCategoryViewHeight
      focusOnComboboxes: false

      categoryModel: widgetController != null ? widgetController.categories : null
      categoryItemModel: widgetController != null ? widgetController.appearanceTypeListModel : null
      showLockerOnlyShouldBeChecked: widgetController != null && widgetController.showLockerOnly

      enableTierAndClassificationSelection : widgetController != null ? widgetController.enableTierAndClassificationSelection : false
      enableTierSelection : widgetController != null ? widgetController.enableTierSelection : false
      availableTiers: widgetController != null ? widgetController.availableTiers : null
      indexOfSelectedTier: widgetController != null ? widgetController.indexOfSelectedTier : -1
      availableClassifications: widgetController != null ? widgetController.availableClassifications : null
      indexOfSelectedClassification: widgetController != null ? widgetController.indexOfSelectedClassification : -1
      npcFilterVisible: true
      availableNPCs: widgetController != null ? widgetController.availableNPCs : null
      indexOfSelectedNPC: widgetController != null ? widgetController.indexOfSelectedNPC : -1

      Connections {
        function onCategorySelected(CategoryIdentifier, FilterByLevel, FilterByVocation, OnlyOneHandWeapons, OnlyTwoHandWeapons, ShowLockerOnly) {
          widgetController != null ? widgetController.requestCategorySelect(CategoryIdentifier, FilterByLevel, FilterByVocation, OnlyOneHandWeapons, OnlyTwoHandWeapons, ShowLockerOnly) : null
        }
        function onFilterSelected(NameFilter, FilterByLevel, FilterByVocation, OnlyOneHandWeapons, OnlyTwoHandWeapons, ShowLockerOnly) {
          widgetController != null ? widgetController.requestNameSelect(NameFilter, FilterByLevel, FilterByVocation, OnlyOneHandWeapons, OnlyTwoHandWeapons, ShowLockerOnly) : null
        }
        function onItemSelected(AppearanceId, UpgradeTier) {
          widgetController != null ? widgetController.requestItemSelect(AppearanceId, UpgradeTier) : null
        }
        function onItemChosen(AppearanceId, UpgradeTier) {
          widgetController != null ? widgetController.requestItemChosen(AppearanceId, UpgradeTier) : null
        }
        function onItemClicked(AppearanceId, UpgradeTier, MouseButton, KeyboardModifiers) {
          widgetController != null ? widgetController.onSearchedItemClicked(AppearanceId, UpgradeTier, MouseButton, KeyboardModifiers) : null
        }
        function onFocusEnteredTextInput() {
          widgetController != null ? widgetController.takeFocus() : null
        }
        function onClassificationFilterWasSelected(CurrentIndex, NameFilter, FilterByLevel, FilterByVocation, OnlyOneHandWeapons, OnlyTwoHandWeapons, ShowLockerOnly) {
          widgetController != null ? widgetController.onClassificationFilterWasSelected(CurrentIndex, NameFilter, FilterByLevel, FilterByVocation, OnlyOneHandWeapons, OnlyTwoHandWeapons, ShowLockerOnly) : null
        }
        function onTierFilterWasSelected(CurrentIndex, NameFilter, FilterByLevel, FilterByVocation, OnlyOneHandWeapons, OnlyTwoHandWeapons, ShowLockerOnly) {
          widgetController != null ? widgetController.onTierFilterWasSelected(CurrentIndex, NameFilter, FilterByLevel, FilterByVocation, OnlyOneHandWeapons, OnlyTwoHandWeapons, ShowLockerOnly) : null
        }
        function onNpcFilterWasSelected(CurrentIndex, NameFilter, FilterByLevel, FilterByVocation, OnlyOneHandWeapons, OnlyTwoHandWeapons, ShowLockerOnly) {
          widgetController != null ? widgetController.onNpcFilterWasSelected(CurrentIndex, NameFilter, FilterByLevel, FilterByVocation, OnlyOneHandWeapons, OnlyTwoHandWeapons, ShowLockerOnly) : null
        }
        function onAcceptedTextInput() {
          if(widgetController != null && itemSelection.hasSelectedItem) {
            widgetController.requestSearch();
          }
        } //onAcceptedTextInput
        function onEscPressedInSearchTextField() {
          widgetController != null ? widgetController.releaseFocus() : null
        }
      } //Connections
    } // MarketCategorySelection

    RowLayout {
      Layout.fillWidth: true
      Layout.bottomMargin: TibiaStyle.marginNarrow
      Layout.leftMargin: TibiaStyle.marginNarrow
      Layout.rightMargin: TibiaStyle.marginNarrow
      spacing: TibiaStyle.marginRelated

      Item { Layout.fillWidth: true }

      TibiaButton {
        Layout.preferredHeight: TibiaStyle.buttonHeightDefault
        Layout.preferredWidth: Layout.preferredHeight
        imageSource: "/images/icon-refresh.png"
        tooltipText: qsTrId("depot_search_refresh_tooltip")
        onClicked: widgetController != null ? widgetController.requestRefresh() : undefined
      } //TibiaButton

      TibiaButton {
        Layout.preferredHeight: TibiaStyle.buttonHeightDefault
        Layout.preferredWidth: Layout.preferredHeight
        imageSource: "/images/icon-displayresults.png"
        tooltipText: qsTrId("depot_search_search_tooltip")

        enabled: itemSelection.hasSelectedItem
        onClicked: widgetController != null ? widgetController.requestSearch() : undefined

        TibiaDisabledOverlay {
          anchors.fill: parent
          anchors.margins: 1
          visible: !parent.enabled
        } //TibiaDisabledOverlay
      } //TibiaButton
    } //RowLayout
  } //ColumnLayout

  ColumnLayout {
    id: detailListLayout
    anchors.fill: parent
    spacing: TibiaStyle.marginNarrow
    visible: root.showDetailList

    ColumnLayout {
      spacing: TibiaStyle.marginRelated
      Layout.leftMargin: TibiaStyle.marginNarrow
      Layout.rightMargin: TibiaStyle.marginNarrow

      TibiaText {
        Layout.fillWidth: true
        text: widgetController != null ? widgetController.detailListObjectName : qsTrId("unknown")
      } //TibiaText

      GridLayout {
        Layout.fillWidth: true
        columns: 3
        rowSpacing: TibiaStyle.marginNarrow
        columnSpacing: TibiaStyle.marginRelated

        ButtonGroup {
          id: storageLocationExlusiveGroup
          //property int useObjectTypeEnumId: 0

          checkedButton: {
            if (root.totalCountDepot > 0) {
              return depotButton;
            } else if (root.totalCountStash > 0) {
              return stashButton;
            } else if (root.totalCountInbox > 0) {
              return inboxButton;
            }

            return depotButton;
          } //checkedButton

          property int selectedButtonIndex: {
            if (storageLocationExlusiveGroup.checkedButton == depotButton) {
              return 0;
            } else if (storageLocationExlusiveGroup.checkedButton == stashButton) {
              return 1;
            } else if (storageLocationExlusiveGroup.checkedButton == inboxButton) {
              return 2;
            }
            return 0;
          }
        } //ButtonGroup

        TibiaButton {
          id: depotButton
          Layout.fillWidth: true
          Layout.preferredHeight: TibiaStyle.buttonHeightAppearance
          imageSource: "/images/icon-depot.png"
          tooltipText: qsTrId("depot_search_storage_location_tooltip").arg(qsTrId("depot"))
          ButtonGroup.group: storageLocationExlusiveGroup
          checkable: true

          enabled: root.totalCountDepot > 0
          TibiaDisabledOverlay {
            anchors.fill: parent
            anchors.margins: 1
            visible: !parent.enabled
          } //TibiaDisabledOverlay
        } //TibiaButton

        TibiaButton {
          id: stashButton
          Layout.fillWidth: true
          Layout.preferredHeight: TibiaStyle.buttonHeightAppearance
          imageSource: "/images/icon-supplystash.png"
          tooltipText: qsTrId("depot_search_storage_location_tooltip").arg(qsTrId("stash"))
          ButtonGroup.group: storageLocationExlusiveGroup
          checkable: true

          enabled: root.totalCountStash > 0
          TibiaDisabledOverlay {
            anchors.fill: parent
            anchors.margins: 1
            visible: !parent.enabled
          } //TibiaDisabledOverlay
        } //TibiaButton

        TibiaButton {
          id: inboxButton
          Layout.fillWidth: true
          Layout.preferredHeight: TibiaStyle.buttonHeightAppearance
          imageSource: "/images/icon-inbox.png"
          tooltipText: qsTrId("depot_search_storage_location_tooltip").arg(qsTrId("inbox"))
          ButtonGroup.group: storageLocationExlusiveGroup
          checkable: true

          enabled: root.totalCountInbox > 0
          TibiaDisabledOverlay {
            anchors.fill: parent
            anchors.margins: 1
            visible: !parent.enabled
          } //TibiaDisabledOverlay
        } //TibiaButton

        TibiaText {
          Layout.fillWidth: true
          horizontalAlignment: Text.AlignRight
          text: widgetController != null ? widgetController.totalCountDepotString : "0"
          tooltipText: (root.totalCountDepot == 1 ? qsTrId("depot_search_storage_location_count_tooltip_singular")
                                                  : qsTrId("depot_search_storage_location_count_tooltip").arg(TextHelper.formatNumberWithThousandSeparators(root.totalCountDepot)))
                                                           .arg(qsTrId("depot"))
        } //TibiaText

        TibiaText {
          Layout.fillWidth: true
          horizontalAlignment: Text.AlignRight
          text: widgetController != null ? widgetController.totalCountStashString : "0"
          tooltipText: (root.totalCountStash == 1 ? qsTrId("depot_search_storage_location_count_tooltip_singular")
                                                  : qsTrId("depot_search_storage_location_count_tooltip").arg(TextHelper.formatNumberWithThousandSeparators(root.totalCountStash)))
                                                          .arg(qsTrId("stash"))
        } //TibiaText

        TibiaText {
          Layout.fillWidth: true
          horizontalAlignment: Text.AlignRight
          text: widgetController != null ? widgetController.totalCountInboxString : "0"
          tooltipText: (root.totalCountInbox == 1 ? qsTrId("depot_search_storage_location_count_tooltip_singular")
                                                  : qsTrId("depot_search_storage_location_count_tooltip").arg(TextHelper.formatNumberWithThousandSeparators(root.totalCountInbox)))
                                                           .arg(qsTrId("inbox"))
        } //TibiaText
      } //Grid
    } //ColumnLayout

    MouseArea {
      id: detailListView
      Layout.fillHeight: true
      Layout.fillWidth: true
      //for some reason the preferredHeight of depotInboxView is used as minimumHeight which is not correct
      //Layout.minimumHeight: containerContent.Layout.minimumHeight
      Layout.minimumHeight: TibiaStyle.widgetWithScrollBarMinContentHeight
      acceptedButtons: Qt.LeftButton

      property bool slotContainsDrag: false

      Rectangle {
        id: highlightBorder
        anchors.fill: parent
        color: "transparent"
        border.color: "red"
        border.width: 1
        z: 999
        visible: dropArea.containsDrag || detailListView.slotContainsDrag
      } //Rectangle

      TibiaObjectDropArea {
        id: dropArea
        anchors.fill: parent

        onEntered: {
          if (widgetController != null) {
            widgetController.emptySlotAreaEntered();
          }
        } //onEntered
        onExited: {
          if (widgetController != null) {
            widgetController.emptySlotAreaExited();
          }
        } //onExited

        TibiaScrollView {
          id: containerScrollView
          anchors.fill: parent

          Flickable {
            id: flickContent

            interactive: false //prevent flick behavior on touch screens
            boundsBehavior: Flickable.StopAtBounds

            contentHeight: containerContent.height
            contentWidth: parent.width

            ColumnLayout {
              id: containerContent
              spacing: 0
              anchors.left: parent.left
              anchors.right: parent.right
              anchors.leftMargin: TibiaStyle.containerContentLeftMargin

              ListView {
                id: stashView
                Layout.fillWidth: true
                Layout.minimumHeight: TibiaStyle.containerSlotSize
                spacing: TibiaStyle.containerSlotsMargin
                visible: storageLocationExlusiveGroup.checkedButton == stashButton

                boundsBehavior: Flickable.StopAtBounds
                interactive: false //prevent flick behavior on touch screens

                highlightFollowsCurrentItem: false

                model: widgetController != null ? widgetController.stashAppearanceTypeListModel : null

                delegate: RowLayout {
                  spacing: TibiaStyle.marginRelated

                  ContainerSlot {
                    slotID: model.typeID
                    slotText: model.countString
                    slotTooltip: model.countAndNameTooltip
                    objectAppearanceInstanceTypeId: model.displayTypeID
                    objectAppearanceInstanceCumulativeCount: model.cumulativeCount
                    objectAppearanceInstanceUpgradeTier: model.upgradeTier
                    lootvalueImageSourceUnderItem: model.lootvalueImageSourceUnderItem
                    lootvalueImageSourceOverItem: model.lootvalueImageSourceOverItem

                    acceptsDrop: true
                    isUpdatable: false
                    mouseAreaEnabled: true

                    onDragDropped: { }

                    onContainsDragChanged: {
                      detailListView.slotContainsDrag = containsDrag;
                    } //onContainsDragChanged

                    Component.onCompleted: {
                      clicked.connect(stashSlotClicked);
                    } //Component.onCompleted

                    function stashSlotClicked(SlotID, MouseButton, KeyboardModifier) {
                      if (widgetController != null) {
                        widgetController.slotClicked(1, SlotID, MouseButton, KeyboardModifier);
                      }
                    } //function stashSlotClicked
                  } //ContainerSlot

                  TibiaButton {
                    Layout.preferredWidth: TibiaStyle.buttonWidthWide
                    text: qsTrId("selectamount_retrieve_caption")
                    onClicked: {
                      if (widgetController != null) {
                        widgetController.requestRetrieveFromStash(model.typeID);
                      }
                    } //onClicked
                  } //TibiaButton
                } //delegate: RowLayout
              } //ListView

              GridView {
                id: depotInboxView
                Layout.fillWidth: true
                Layout.minimumHeight: TibiaStyle.containerSlotSize
                Layout.preferredHeight: contentHeight
                visible: storageLocationExlusiveGroup.checkedButton == depotButton
                      || storageLocationExlusiveGroup.checkedButton == inboxButton

                cellWidth: TibiaStyle.containerSlotSize + TibiaStyle.containerSlotsMargin
                cellHeight: cellWidth

                interactive: false //prevent flick behavior on touch screens
                boundsBehavior: Flickable.StopAtBounds

                model: {
                  if (widgetController != null) {
                    if(storageLocationExlusiveGroup.checkedButton == depotButton) {
                      return widgetController.depotAppearanceTypeListModel;
                    } else if (storageLocationExlusiveGroup.checkedButton == inboxButton) {
                      return widgetController.inboxAppearanceTypeListModel;
                    }
                  }
                  return null;
                } //model

                delegate: ContainerSlot {
                  slotID: index
                  slotText: model.cumulativeCount > 1 ? model.cumulativeCount : ""
                  objectAppearanceInstanceTypeId: model.typeID
                  objectAppearanceInstanceCumulativeCount: model.cumulativeCount
                  objectAppearanceInstanceUpgradeTier: model.upgradeTier
                  lootvalueImageSourceUnderItem: model.lootvalueImageSourceUnderItem
                  lootvalueImageSourceOverItem: model.lootvalueImageSourceOverItem
                  objectAppearanceInstanceLiquidType: model.liquideType
                  objectAppearanceInstanceHookDirection: model.hookDirection
                  managedContainerTooltipText: model.managedContainerTooltip

                  acceptsDrop: objectAppearanceInstanceTypeId != 0
                  isUpdatable: false
                  mouseAreaEnabled: true

                  onDragDropped: { }

                  onContainsDragChanged: {
                    detailListView.slotContainsDrag = containsDrag;
                  } //onContainsDragChanged

                  Component.onCompleted: {
                    clicked.connect(slotClicked);
                    entered.connect(slotEntered);
                    exited.connect(slotExited);
                    startDrag.connect(slotStartDrag);
                    //dragDropped.connect(slotDragDropped);
                    targetSelected.connect(slotTargetSelected);
                  } //Component.onCompleted

                  function slotClicked(SlotID, MouseButton, KeyboardModifier) {
                    if (widgetController != null) {
                      widgetController.slotClicked(storageLocationExlusiveGroup.selectedButtonIndex,
                                                   SlotID,
                                                   MouseButton,
                                                   KeyboardModifier);
                    }
                  } //function slotClicked

                  function slotEntered(SlotID) {
                    if (widgetController != null) {
                      widgetController.slotEntered(storageLocationExlusiveGroup.selectedButtonIndex,
                                                   SlotID);
                    }
                  } //function slotEntered

                  function slotExited(SlotID) {
                    if (widgetController != null) {
                      widgetController.slotExited(storageLocationExlusiveGroup.selectedButtonIndex,
                                                  SlotID);
                    }
                  } //function slotExited

                  function slotStartDrag(SlotID, Source) {
                    if (widgetController != null) {
                      widgetController.slotStartDrag(storageLocationExlusiveGroup.selectedButtonIndex,
                                                     SlotID,
                                                     Source);
                    }
                  } //function slotStartDrag

                  function slotTargetSelected(SlotID) {
                    if (widgetController != null) {
                      widgetController.slotTargetSelected(storageLocationExlusiveGroup.selectedButtonIndex,
                                                          SlotID);
                    }
                  } //function slotTargetSelected
                } //delegate: ContainerSlot
              } //GridView
            } //ColumnLayout
          } //Flickable
        } //TibiaScrollView
      } //TibiaObjectDropArea
    } //MouseArea

    Item {
      Layout.preferredWidth: retrieveFromDepotInboxButton.width
      Layout.preferredHeight: retrieveFromDepotInboxButton.height
      Layout.alignment: Qt.AlignHCenter
      Layout.bottomMargin: TibiaStyle.marginNarrow

      TibiaButton {
        id: retrieveFromDepotInboxButton
        width: TibiaStyle.buttonWidthWidest
        text: qsTrId("depot_search_retrieve_displayed")

        visible: storageLocationExlusiveGroup.checkedButton == depotButton
              || storageLocationExlusiveGroup.checkedButton == inboxButton

        enabled: widgetController != null && widgetController.isAppearanceAllowedToRetrieve
               && (   storageLocationExlusiveGroup.checkedButton == depotButton && root.totalCountDepot > 0
                   || storageLocationExlusiveGroup.checkedButton == inboxButton && root.totalCountInbox > 0)

        onClicked: {
          if (widgetController != null) {
            widgetController.requestRetrieveFromDepotInbox(storageLocationExlusiveGroup.selectedButtonIndex);
          }
        } //onClicked
      } //TibiaButton

      Tooltip {
        anchors.fill: parent
        enabled: !retrieveFromDepotInboxButton.enabled && widgetController != null && !widgetController.isAppearanceAllowedToRetrieve

        text: qsTrId("depot_search_no_containers_tooltip")
      } //Tooltip
    } //Item
  } //ColumnLayout

  Lenshelp {
    anchors.fill: parent
    triggerRect: mapFromItem(widgetRoot, 0, 0, widgetRoot.width, widgetRoot.height)
    caption: qsTrId("depot_search_lenshelp_caption")
    content: qsTrId("depot_search_lenshelp")
   } //Lenshelp
} //TibiaSidebarWidget
