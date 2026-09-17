import QtQuick
import QtQuick.Layouts

import qmlcomponents


TibiaDialog {
  id: root
  caption: qsTrId("stash_caption")
  width:   TibiaStyle.containerSlotSize*numSlotsPerRow + TibiaStyle.containerSlotsMargin *(numSlotsPerRow + 1)
         + TibiaStyle.scrollBarWidth + 2*TibiaStyle.dialogMarginBorder + 2*scrollAreaFrame.borderWidth

  property var controller: null
  property bool resetStashScrollbarPosition: false
  readonly property int numSlotsPerRow: 20
  readonly property int numVisibleRows: 11

  initialFocusItem: serachFieldFrame
  KeyNavigation.tab: serachFieldFrame
  KeyNavigation.backtab: serachFieldFrame

  onCancelPressedFunction: onCloseClicked

  Component {
    id: dynamicTimerComponent
    Timer {
    }
  }

  property int _execLaterCount: 0
  function execLater(contextObject, delay, callback, args) {
    var timer = dynamicTimerComponent.createObject(contextObject);
    let targetDelay = delay === undefined ? 100 : delay;
    let delayFactor = 1.0;

    if (_execLaterCount <= 2*numVisibleRows) {
      delayFactor = 0;
    } else {
      delayFactor = Math.min(1.0, _execLaterCount / (numSlotsPerRow*numVisibleRows))
    }

    timer.interval = Math.floor(delayFactor*targetDelay);
    timer.repeat = false;
    timer.triggered.connect(() => {
      callback(args)
      root._execLaterCount = root._execLaterCount -1;
      timer.destroy();
    });

    root._execLaterCount = root._execLaterCount +1;
    timer.start();

    return timer;
  }


  function onCloseClicked() {
    if (controller != null) {
      controller.closeButtonClicked();
    }
    if (tibiaMouseCursorController != null) {
      tibiaMouseCursorController.setPointingHand(false);
    }
  } //function onCloseClicked

  function slotClicked(TypeID, MouseButton, KeyboardModifiers) {
      if (controller != null) {
      controller.slotClicked(TypeID, MouseButton, KeyboardModifiers);
    }
  } //function slotClicked

  function onManageQuickLootClickedFunction() {
    if (controller != null) {
      controller.requestOpenManageQuickLootDialog();
    }
  } //onManageQuickLootClickedFunction

  ColumnLayout {
    anchors { left: parent.left; top: parent.top; right: parent.right }
    spacing: TibiaStyle.marginUnrelated

    RowLayout {
      spacing: TibiaStyle.marginRelated

      TibiaTextSearchField {
        id: serachFieldFrame
        Layout.fillWidth: true

        shouldBeText:  controller.nameFilter

        onSearchTextChanged: {
          root.resetStashScrollbarPosition = true;
          controller.nameFilter = searchText;
        } //onSearchTextChanged
      } //TibiaTextSearchField

      TibiaComboBox {
        id: categoryFilterComboBox
        Layout.preferredWidth: 190
        model: controller != null ? controller.categoryFilterModel : null
        shouldBeCurrentIndex: controller != null ? controller.categoryFilterIndex : 0
        onCurrentIndexChanged: {
          if (controller != null) {
            root.resetStashScrollbarPosition = true;
            controller.categoryFilterIndex = currentIndex;
          }
        } //onCurrentIndexChanged
      } // TibiaComboBox

      TibiaComboBox {
        id: traderFilterComboBox
        Layout.preferredWidth: 190 //different sizes to allow full display without elide
        popupMaxHeight: 400
        model: controller != null ? controller.traderFilterModel : null
        shouldBeCurrentIndex: controller != null ? controller.traderFilterIndex : 0
        onCurrentIndexChanged: {
          if (controller != null) {
            root.resetStashScrollbarPosition = true;
            controller.traderFilterIndex = currentIndex;
          }
        } //onCurrentIndexChanged
      } // TibiaComboBox

      TibiaComboBox {
        id: sortDirectionComboBox
        Layout.preferredWidth: 190
        Layout.leftMargin: TibiaStyle.marginWide - parent.spacing

        readonly property var _shouldBeValue: controller.sortOrder
        shouldBeCurrentIndex: {
          for (let i = 0; i < sortModel.count; ++i) {
            if (sortModel.get(i).value == _shouldBeValue) {
              return i;
            }
          }
          return 0;
        }
        textRole: "text"
        valueRole: "value"
        model: ListModel {
          id: sortModel
          ListElement { text: qsTrId("stash_sort_az");
                        value: TibiaEnums.ESortOrder.AtoZ }
          ListElement { text: qsTrId("stash_sort_za");
                        value: TibiaEnums.ESortOrder.ZtoA }
          ListElement { text: qsTrId("stash_sort_market_expensive_on_top");
                        value: TibiaEnums.ESortOrder.MarketExpensiveOnTop }
          ListElement { text: qsTrId("stash_sort_market_expensive_on_bottom");
                        value: TibiaEnums.ESortOrder.MarketExpensiveOnBottom }
          ListElement { text: qsTrId("stash_sort_total_market_expensive_on_top");
                        value: TibiaEnums.ESortOrder.TotalMarketExpensiveOnTop }
          ListElement { text: qsTrId("stash_sort_total_market_expensive_on_bottom");
                        value: TibiaEnums.ESortOrder.TotalMarketExpensiveOnBottom }
          ListElement { text: qsTrId("stash_sort_sell_expensive_on_top");
                        value: TibiaEnums.ESortOrder.SellExpensiveOnTop }
          ListElement { text: qsTrId("stash_sort_sell_expensive_on_bottom");
                        value: TibiaEnums.ESortOrder.SellExpensiveOnBottom }
          ListElement { text: qsTrId("stash_sort_total_sell_expensive_on_top");
                        value: TibiaEnums.ESortOrder.TotalSellExpensiveOnTop }
          ListElement { text: qsTrId("stash_sort_total_sell_expensive_on_bottom");
                        value: TibiaEnums.ESortOrder.TotalSellExpensiveOnBottom }
          ListElement { text: qsTrId("stash_sort_largest_stock_on_top");
                        value: TibiaEnums.ESortOrder.LargestStockOnTop }
          ListElement { text: qsTrId("stash_sort_largest_stock_on_bottom");
                        value: TibiaEnums.ESortOrder.LargestStockOnBottom }
        } //model: ListModel

        onActivated: (index) => {
          controller.sortOrder = sortModel.get(index).value
        } //onActivated
      } //TibiaComboBox
    } //RowLayout

    TibiaFrame1PixelDown {
      id: scrollAreaFrame
      Layout.fillWidth: true
      Layout.preferredHeight:   Math.floor(TibiaStyle.containerSlotSize*(numVisibleRows+0.5))
                              + TibiaStyle.containerSlotsMargin*(numVisibleRows + 1)
                              + 2*scrollAreaFrame.borderWidth

      TibiaScrollView {
        anchors.fill: parent
        anchors.margins: parent.borderWidth
        anchors.leftMargin: parent.borderWidth + TibiaStyle.containerSlotsMargin

        GridView {
          id: itemsGridView
          topMargin: TibiaStyle.containerSlotsMargin
          bottomMargin: TibiaStyle.containerSlotsMargin

          cellWidth: TibiaStyle.containerSlotSize + TibiaStyle.containerSlotsMargin
          cellHeight: cellWidth

          interactive: false //prevent flick behavior on touch screens
          boundsBehavior: Flickable.StopAtBounds

          // three additional rows as delegate buffer for smoother scrolling
          cacheBuffer: TibiaStyle.containerSlotSize * 3

          footer: Item {
            height: TibiaStyle.containerSlotsMargin
          } //header: Item

          model: controller != null ? controller.stashModel : null

          onCountChanged: {
            //make sure the cursor is correct when the content changes
            if (tibiaMouseCursorController != null) {
              tibiaMouseCursorController.setPointingHand(false);
            }

            //var oldGridPosition = contentY;
            //model = stashContentModel;
            //
            //// Restore scroll position
            //if (!root.resetStashScrollbarPosition) {
            //  contentY  = contentHeight < height ? 0 : oldGridPosition;
            //} else {
            //  root.resetStashScrollbarPosition = false;
            //}
          } //onModelChanged

          delegate: ContainerSlot {
            id: containerSlot
            property var _typeID: model.typeID
            property var _execLaterTimer: null

            Component.onDestruction: {
              if (_execLaterTimer) {
                if (_execLaterTimer.running) {
                  root._execLaterCount = root._execLaterCount -1
                  _execLaterTimer.stop();
                  _execLaterTimer.destroy();
                }
                _execLaterTimer = null;
              }
            } //Component.onDestruction

            on_TypeIDChanged: {
              if (_typeID) {
                _execLaterTimer = root.execLater(containerSlot, 100, showAppearanceTypeID, _typeID);
              } else {
                containerSlot.objectAppearanceInstanceTypeId = 0;
              }
            } //on_TypeIDChanged

            function showAppearanceTypeID(appearanceTypeID) {
              containerSlot.objectAppearanceInstanceTypeId = appearanceTypeID;
            } //function showAppearanceTypeID

            showPointingHandCursor: true
            slotID: model.typeID
            mouseAreaEnabled: true
            slotText: model.countString
            slotTooltip: model.typeName != ""
              ? "%1x %2"
                .arg(TextHelper.formatNumberWithThousandSeparators(model.typeCount))
                .arg(model.typeName)
              : ""
            objectAppearanceInstanceCumulativeCount: model.cumulativeCount
            lootvalueImageSourceUnderItem: model.lootvalueImageSourceUnderItem
            lootvalueImageSourceOverItem: model.lootvalueImageSourceOverItem

            Component.onCompleted: {
              clicked.connect(root.slotClicked);
            } //Component.onCompleted
          } //delegate: ContainerSlot
        } // GridView
      } //TibiaScrollView
    } //TibiaFrame1PixelDown


    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } //TibiaHorizontalSeparator

    RowLayout {
      Layout.alignment: Qt.AlignRight
      spacing: TibiaStyle.marginRelated

      TibiaButton {
        Layout.preferredWidth: TibiaStyle.buttonWidthWidest

        text: qsTrId("managecontainer_caption")
        onClicked: onManageQuickLootClickedFunction()
      } //TibiaButton

      Item {Layout.fillWidth: true}

      TibiaButton {
        id: closeButton
        text: qsTrId("close")
        onClicked: root.onCloseClicked()
      } // TibiaButton
    } // RowLayout
  } // ColumnLayout

} // TibiaDialog
