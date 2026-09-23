import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml

import qmlcomponents

Item {
  id: root
  implicitWidth: 166
  implicitHeight: 150

  property var tradeController: null

  signal requestTakeFocus()
  signal requestReleaseFocus()

  property int preselectedAmount: tradeController != null ? tradeController.amountPreselected : 1
  property int currencyAppearanceID: tradeController != null ? tradeController.currencyTypeId : 0

  readonly property alias searchFieldVisible: searchField.visible

  property string selectedGoodName: ""

  property int okButtonTutorialMarker: tradeController != null && tradeController.okButtonTutorialMarker
    ? tradeController.okButtonTutorialMarker : 0

  onPreselectedAmountChanged: {
    updateSelectionTimer.restart(); // Try to sync the slider update with the list selection update to avoid UI flicker
  } //onPreselectedAmountChanged

  onTradeControllerChanged: {
    if (tradeController != null) {
      tradeController.requestSaveScrollPositionAndRestoreAfterTradableGoodsListUpdate.connect(root.saveScrollPosition);
      tradeController.requestPositionViewAtBeginning.connect(root.positionViewAtBeginning);
    }
  } //onTradeControllerChanged

  property int _savedScrollPosition: -1
  function saveScrollPosition() {
    if (itemView) {
      _savedScrollPosition = itemView.contentY;
    }
  } //function saveScrollPosition

  function restoreScrollPosition() {
    if (itemView) {
      itemView.contentY = _savedScrollPosition;
    }
    _savedScrollPosition = -1;
  } //function restoreScrollPosition

  function positionViewAtBeginning() {
    if (itemView) {
      itemView.positionViewAtBeginning();
    }
  } //function positionViewAtBeginning

  ColumnLayout {
    anchors.fill: parent
    spacing: TibiaStyle.marginRelated

    RowLayout {
      id: topArea
      Layout.fillWidth: true
      Layout.leftMargin: TibiaStyle.marginNarrow
      Layout.rightMargin: TibiaStyle.marginNarrow
      Layout.maximumHeight: TibiaStyle.containerSlotSize
      Layout.preferredHeight: Layout.maximumHeight
      spacing: TibiaStyle.marginNarrow

      ColumnLayout {
        Layout.fillHeight: true
        spacing: 0

        TibiaText {
          Layout.fillWidth: true
          text: qsTrId("npc_trade_currency")
        } //TibiaText

        Item { Layout.fillHeight: true }

        TibiaText {
          Layout.fillWidth: true
          text: tradeController != null ? tradeController.currencyName : qsTrId("dummy_unknown")
        } //TibiaText
      } //ColumnLayout

      TibiaFrame1PixelDown {
        id: currencyAppearanceView
        Layout.preferredHeight: TibiaStyle.containerSlotSize
        Layout.preferredWidth: Layout.preferredHeight
        visible: root.currencyAppearanceID != 0

        SingleObjectAppearanceInstanceRenderer {
          anchors.fill: parent
          anchors.margins: parent.borderWidth

          animated: true
          typeid: root.currencyAppearanceID
          cumulativeCount: 250
        } //SingleObjectAppearanceInstanceRenderer
      } //TibiaFrame1PixelDown


      ColumnLayout {
        id: buttonColumn
        spacing: TibiaStyle.marginNarrow

        ButtonGroup {
            id: buySellGroup

            checkedButton: tradeController != null && tradeController.npcIsBuying ? buyButton
                                                                                    : sellButton
        } //ButtonGroup

        TibiaButton {
          id: buyButton
          Layout.preferredHeight: Math.floor((topArea.height - buttonColumn.spacing) / 2)
          text: qsTrId("buy")
          tooltipText: qsTrId("npc_trade_buy_tooltip")
          tooltipTextChecked: qsTrId("npc_trade_buy_checked_tooltip")
          checkable: true
          checked: true
          ButtonGroup.group: buySellGroup

          onClicked: {
            if (tradeController != null) {
              searchField.clearSearch();
              itemView.positionViewAtBeginning();
              tradeController.switchToBuyItems();
            }
          } //onClicked
        } //TibiaButton

        TibiaButton {
          id: sellButton
          Layout.preferredHeight: Math.floor((topArea.height - buttonColumn.spacing) / 2)
          text: qsTrId("npc_trade_sell")
          tooltipText: qsTrId("npc_trade_sell_tooltip")
          tooltipTextChecked: qsTrId("npc_trade_sell_checked_tooltip")
          checkable: true
          ButtonGroup.group: buySellGroup

          onClicked: {
            if (tradeController != null) {
              searchField.clearSearch();
              itemView.positionViewAtBeginning();
              tradeController.switchToSellItems();
            }
          } //onClicked
        } //TibiaButton
      } //ColumnLayout
    } //RowLayout


    Rectangle {
      Layout.fillWidth: true
      Layout.fillHeight: true
      Layout.minimumHeight: TibiaStyle.widgetWithScrollBarMinContentHeight + 2*itemViewFrame.borderWidth
      color: TibiaStyle.tableViewBackgroundColor

      TibiaFrame1PixelDown {
        id: itemViewFrame
        anchors.fill: parent
      }  // TibiaFrame1PixelDown

      TibiaScrollView {
        anchors.fill: parent
        anchors.margins: itemViewFrame.borderWidth

        ListView {
          id: itemView
          clip: true

          boundsBehavior: Flickable.StopAtBounds
          interactive: false //prevent flick behavior on touch screens
          highlightMoveDuration: 0
          highlightFollowsCurrentItem: tradeController != null && tradeController.npcIsBuying
          highlightRangeMode: ListView.NoHighlightRange

          model: tradeController != null ? tradeController.traderInventoryModel : null

          //type var is important, otherwise not all changes signals are forwarded, using int and changing to the same value would not trigger onChanged
          readonly property var _shouldBeSelectedTypeId: tradeController != null ? tradeController.selectedTypeId : 0
          readonly property var _shouldBeSelectedLiquidType: tradeController != null ? tradeController.selectedLiquidType : 0
          on_ShouldBeSelectedTypeIdChanged: updateSelectionTimer.restart()
          on_ShouldBeSelectedLiquidTypeChanged: updateSelectionTimer.restart()

          Timer {
            id: updateSelectionTimer
            interval: 0

            onTriggered: itemView.updateSelection()
          } //Timer

          function updateSelection() {
            var NewCurrentIndex = -1;
            if (itemView.model != null) {
              for (var i=0; i < itemView.count; i++) {
                var idx = itemView.model.index(i, 0);
                var typeId = itemView.model.data(idx, itemView.model.appearanceIDEnumValue);
                var liquidType = itemView.model.data(idx, itemView.model.liquidTypeEnumValue);
                if (   typeId == itemView._shouldBeSelectedTypeId
                    && liquidType == itemView._shouldBeSelectedLiquidType) {
                  NewCurrentIndex = i;
                  break;
                }
              }
            }
            itemView.currentIndex = NewCurrentIndex;
            //make sure that onCurrentIndexChanged is triggered to select the first entry if needed
            //or adjust scroll position to show current index if it was already the current index
            currentIndexChanged();

            amountSlider.shouldBeValue = preselectedAmount;

            if (_savedScrollPosition != -1) {
              root.restoreScrollPosition();
            }
          } //function updateSelection

          onCurrentItemChanged:currentItemChangedTimer.restart()
          Timer {
            id: currentItemChangedTimer
            interval: 1
            onTriggered: {
              selectedItem.objectAppearanceInstanceTypeId = itemView.currentItem != null ? itemView.currentItem.appearanceID : 0;
              selectedItem.objectAppearanceInstanceLiquidType = itemView.currentItem != null ? itemView.currentItem.liquidType : ObjectAppearanceInstance.EMPTY;
              selectedItem.objectAppearanceInstanceHookDirection = itemView.currentItem != null ? itemView.currentItem.hookDirection : ObjectAppearanceInstance.NONE;

              root.selectedGoodName = itemView.currentItem != null ? itemView.currentItem.name : "";
            } //onTriggered
          } //Timer

          delegate: Rectangle {
            id: delegateRoot
            width: itemView.width
            height: 35
            color: ListView.isCurrentItem ? TibiaStyle.tableViewSelectionColor : "transparent"

            property alias appearanceID: goodContainerSlot.objectAppearanceInstanceTypeId
            property alias liquidType: goodContainerSlot.objectAppearanceInstanceLiquidType
            property alias hookDirection: goodContainerSlot.objectAppearanceInstanceHookDirection
            property int maximumTradeAmount: model ? model.maximumTradeAmount : 0
            property alias name: goodName.text

            RowLayout {
              anchors.fill: parent
              spacing: TibiaStyle.marginNarrow

              ContainerSlot {
                id: goodContainerSlot
                Layout.leftMargin: TibiaStyle.marginNarrow
                objectAppearanceInstanceTypeId: model ? model.appearanceID : 0
                objectAppearanceInstanceCumulativeCount: 1
                objectAppearanceInstanceLiquidType: model ? model.liquidType : ObjectAppearanceInstance.EMPTY
                objectAppearanceInstanceHookDirection: model ? model.hookDirection : ObjectAppearanceInstance.NONE
                mouseAreaEnabled: false
              } // ContainerSlot

              ColumnLayout {
                spacing: 0
                Layout.preferredWidth: 113 //needed to avoid broken eliding
                Layout.maximumWidth: 113
                TibiaText {
                  id: goodName
                  Layout.fillWidth: true
                  color: TibiaStyle.textColors[model && model.canBeTraded ? styleType : "Disabled"]
                  text: model ? model.name : ""
                } // TibiaText
                TibiaText {
                  Layout.fillWidth: true
                  color: TibiaStyle.textColors[model && model.canBeTraded ? styleType : "Disabled"]
                  text: model ? model.priceAndWeight : ""
                } // TibiaText
              } //ColumnLayout
            } //RowLayout

            MouseArea {
              anchors.fill: parent
              acceptedButtons: Qt.LeftButton | Qt.RightButton

              onClicked: (mouse) => {
                if(tradeController != null) {
                  if (mouse.button == Qt.LeftButton ) {
                    tradeController.traderObjectSelected(delegateRoot.appearanceID,
                                                          delegateRoot.liquidType);
                  } else {
                    tradeController.contextMenuForObject(delegateRoot.appearanceID,
                                                          delegateRoot.liquidType);
                  }
                }
              } //onClicked
            } // MouseArea
          } // delegate: Rectangle
        } //ListView
      } //TibiaScrollView
    } //Rectangle

    ColumnLayout {
      id: bottomArea
      Layout.fillWidth: true
      Layout.leftMargin: TibiaStyle.marginNarrow
      Layout.rightMargin: TibiaStyle.marginNarrow
      spacing: TibiaStyle.marginNarrow

      TibiaTextSearchField {
        id: searchField
        Layout.fillWidth: true
        visible: tradeController && tradeController.showNameFilter

        KeyNavigation.tab: amountEnterField
        KeyNavigation.backtab: amountEnterField

        maximumLength: TibiaStyle.maxCharacterNameLength

        onVisibleChanged: {
          clearSearch();
        } //onVisibleChanged

        onSearchTextChanged: {
          if (tradeController != null) {
            tradeController.requestFilterByName(searchText);
          }
        } //onSearchTextChanged

        onActiveFocusChanged: {
          if (activeFocus) {
            root.requestTakeFocus();
          }
        } //onActiveFocusChanged

        onEscPressedInSearchTextField: {
          root.requestReleaseFocus();
        } //onEscPressedInSearchTextField
      } //TibiaTextSearchField

      RowLayout {
        Layout.fillWidth: true
        spacing: TibiaStyle.marginRelated

        ColumnLayout {
          Layout.alignment: Qt.AlignTop
          spacing: TibiaStyle.marginNarrow

          TibiaSliderNonLinear {
            id: amountSlider
            Layout.fillWidth: true

            minimumValue: itemView.currentItem != null ? Math.min(1, itemView.currentItem.maximumTradeAmount) : 0
            maximumValue: itemView.currentItem != null ? itemView.currentItem.maximumTradeAmount : 0

            linearUntilValue: 50
            relativeLinearWidth: 0.5
            exponentialMidpointPercent: 0.1

            stepSizes: [
              { "threshold": 2000, "stepSize": 1000 },
              { "threshold": 500,  "stepSize": 100 },
              { "threshold": 200,  "stepSize": 25 },
              { "threshold": 100,  "stepSize": 10 },
              { "threshold": 50,   "stepSize": 5 }
            ] //stepSizes

            shouldBeValue: 0

            onValueChangedByHuman: {
              if (tradeController != null) {
                tradeController.setAmountPreselected(value);
              }
            } //onValueChangedByHuman
          } // TibiaSliderNonLinear

          RowLayout {
            spacing: TibiaStyle.marginNarrow

            TibiaText {
              text: qsTrId("npc_trade_amount")
            } //TibiaText

            TibiaIntField {
              id: amountEnterField
              Layout.fillWidth: true
              Layout.preferredHeight: 15

              bottomPadding: 1

              KeyNavigation.tab: searchField
              KeyNavigation.backtab: searchField

              maximumLength: TibiaStyle.maxCharacterNameLength

              horizontalAlignment: TextInput.AlignRight
              property bool _isUpdating: false
              readonly property int _sliderValue: amountSlider.value
              on_SliderValueChanged: {
                _isUpdating = true;
                shouldBeText = _sliderValue;
                _isUpdating = false;
              }
              shouldBeText: ""

              minimumValue: amountSlider.minimumValue
              maximumValue: amountSlider.maximumValue

              onIntValueChanged: {
                if (!_isUpdating) {
                  if (tradeController != null) {
                    tradeController.setAmountPreselected(intValue);
                  }
                }
              } //onIntValueChanged

              onActiveFocusChanged: {
                if (activeFocus) {
                  root.requestTakeFocus();
                }
              } //onActiveFocusChanged

              onEscPressedInTextField: {
                root.requestReleaseFocus();
              } //onEscPressedInTextField
            } //TibiaTextSearchField
          } // RowLayout

          RowLayout {
            spacing: TibiaStyle.marginNarrow

            TibiaText {
              text: qsTrId("npc_trade_price")
            } //TibiaText

            TibiaText {
              id: priceText
              text: tradeController != null ? tradeController.buyOrSellPrice : "0"
              Layout.fillWidth: true
              horizontalAlignment: Text.AlignRight
            } //TibiaText
          } // RowLayout

          RowLayout {
            spacing: TibiaStyle.marginNarrow

            TibiaText {
              text: tradeController != null && tradeController.currencyIsGold ? qsTrId("npc_trade_currency_gold")
                                                                                : qsTrId("npc_trade_currency_stock")
            } //TibiaText

            TibiaText {
              text: tradeController != null ? tradeController.totalBalance : qsTrId("dummy_unknown")

              Layout.fillWidth: true
              horizontalAlignment: Text.AlignRight

              Tooltip {
                anchors.fill: parent
                visible: tradeController != null && tradeController.currencyIsGold
                text: qsTrId("gold_balance_tooltip").arg(tradeController != null ? tradeController.inventoryBalance : qsTrId("dummy_unknown"))
                                                    .arg(tradeController != null ? tradeController.bankBalance : qsTrId("dummy_unknown"))
              } //Tooltip
            } //TibiaText
          } // RowLayout
        } // ColumnLayout

        ColumnLayout {
          Layout.alignment: Qt.AlignTop

          ContainerSlot {
            id: selectedItem
            Layout.alignment: Qt.AlignRight

            objectAppearanceInstanceCumulativeCount: 1

            MouseArea {
              acceptedButtons: Qt.LeftButton | Qt.RightButton
              anchors.fill: parent

              onClicked: (mouse) => {
                if (tradeController != null) {
                  if(mouse.button & Qt.LeftButton) {
                    tradeController.lookSelectedGoods();
                  } else if (itemView.currentItem != null) {
                    tradeController.contextMenuForObject(itemView.currentItem.appearanceID,
                                                          itemView.currentItem.liquidType);
                  } else {
                    //context menu without look and inspect
                    tradeController.contextMenuForObject(0, 0);
                  }
                }
              }
            } // MouseArea
          } // ContainerSlot

          TibiaButton {
            id: okButton

            Timer {
              id: clickDelayTimer
              repeat: false
              interval: 100
              onTriggered: {
                okButton.state = "";
              }
            }

            states: [
              State {
                  name: "TEMPORARY_DISABLED"
                  PropertyChanges { target: okButton; enabled: false }
                  PropertyChanges { target: okButton; checkable: true }
                  PropertyChanges { target: okButton; checked: true }
                }
            ] //states

            text: tradeController != null && tradeController.npcIsBuying ? qsTrId("buy") : qsTrId("npc_trade_sell")
            tooltipText: amountSlider.value == 0
              ? qsTrId(buyButton.checked ? "npc_trade_select_goods_to_buy_tooltip"
                                         : "npc_trade_select_goods_to_sell_tooltip")
              : qsTrId(buyButton.checked ? "npc_trade_ok_buy_tooltip" : "npc_trade_ok_sell_tooltip")
                      .arg(amountSlider.value).arg(selectedGoodName).arg(priceText.text)
            onClicked: {
              if (   tradeController != null
                  && amountSlider.value > 0
                  && itemView.currentIndex >= 0) {
                tradeController.buyOrSellSelectedGoods(amountSlider.value);
                okButton.state = "TEMPORARY_DISABLED";
                clickDelayTimer.start();
              }
            } //onClicked
            Loader {
              anchors.fill: parent
              Component {
                id: tutorialMarkerComponent
                TibiaTutorialMarker { }
              }
              sourceComponent: okButtonTutorialMarker != TibiaStyle.noTutorialMarker ? tutorialMarkerComponent : undefined
              onItemChanged: {
                if (item != null) {
                  item.markerID = Qt.binding( () => {
                    return  okButtonTutorialMarker;
                  });
                }
              }
            }
          } //TibiaButton
        } //ColumnLayout
      } //RowLayout
    } //ColumnLayout
  } //ColumnLayout
} //Item
