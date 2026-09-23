import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qmlcomponents
import QtQuick.LegacyControls



ColumnLayout {
  property var controller: null
  property var buyOffersModel: null
  property var sellOffersModel: null
  property int maximumOfferCreationAmount: 0
  property bool canCreateNewOffer: false
  property int tradePacketSize: 1
  property int selectedAppearanceTypeID: 0

  property int selectedSellOfferIndex: -1
  property int selectedBuyOfferIndex: -1

  property string priceOrProfit: "0"
  property string creationFee: "0"
  property string totalPriceOrProfit: "0"

  spacing: TibiaStyle.marginUnrelated

  function resetOfferCreation() {
    piecePriceText.text = "";
    createAmountSlider.value = 0;
    requestUpdateForMaximumOfferCreationAmount();
  } //function resetOfferCreation()

  function requestUpdateForMaximumOfferCreationAmount() {
    if (controller != null) {
      controller.onMarketOfferMaximumAmountRequest(
        sellOfferRadioButton.checked ? "sell" : "buy",
        parseInt(piecePriceText.text));
    }
  } //function requestUpdateForMaximumOfferCreationAmount()

  function updateSummaryValues() {
    if (controller != null) {
      var piecePriceInt = parseInt(piecePriceText.text);
      var offerType = sellOfferRadioButton.checked ? "sell" : "buy";
      priceOrProfit = controller.getPriceOrProfitMultistring(createAmountSlider.value, piecePriceInt);
      creationFee = controller.getMarketFeeMultistring(createAmountSlider.value, piecePriceInt);
      totalPriceOrProfit = controller.getTotalPriceOrProfitMultistring(offerType, createAmountSlider.value, piecePriceInt);
    }
  } //function updateSummaryValues()

  onBuyOffersModelChanged: {
    selectedBuyOfferIndex = -1;
    piecePriceText.text = "";
    createAmountSlider.value = 0;
    requestUpdateForMaximumOfferCreationAmount();
    updateSummaryValues();
  } //onBuyOffersModelChanged

  onSellOffersModelChanged: {
    selectedSellOfferIndex = -1;
    piecePriceText.text = "";
    createAmountSlider.value = 0;
    requestUpdateForMaximumOfferCreationAmount();
    updateSummaryValues();
  } //onSellOffersModelChanged

  onSelectedAppearanceTypeIDChanged: {
    if(selectedAppearanceTypeID == 0) {
      createAmountSlider.value = 0;
    } else {
      createAmountSlider.value = createAmountSlider.minimumValue;
    }
    requestUpdateForMaximumOfferCreationAmount();
  } //onProductSelectedChanged

  Component {
    id: offerTableView

    TibiaTableView {
      id: tableView

      property var itemSelectedFunction: null

      headerVisible: true
      alternatingRowColors: true
      horizontalScrollBarPolicy: ScrollBar.AsNeeded
      verticalScrollBarPolicy: ScrollBar.AlwaysOn

      TableViewColumn { role: "bidder"; title: qsTrId("name"); width: 244; movable: false }
      TableViewColumn { role: "amountText"; title: qsTrId("market_amount_header"); width: 130; horizontalAlignment: Text.AlignRight; movable: false }
      TableViewColumn { role: "piecePriceText"; title: qsTrId("market_piece_price_header"); width: 130; horizontalAlignment: Text.AlignRight; movable: false }
      TableViewColumn { role: "totalPriceText"; title: qsTrId("market_total_price_header"); width: 130; horizontalAlignment: Text.AlignRight; movable: false }
      TableViewColumn { role: "endsAtTime"; title: qsTrId("market_ends_at_header"); width: 150; movable: false }

      selection.onSelectionChanged: {
        selection.forEach(function(rowIndex) {
          if (itemSelectedFunction != null) {
            itemSelectedFunction(rowIndex);
          }
        });
        if (selection.count == 0 && itemSelectedFunction != null) {
          itemSelectedFunction(-1);
        }
      } // onSelectionChanged

      itemDelegate: Item {
        anchors.fill: parent

        TibiaText {
          text: styleData.value
          styleType: "Dialog"
          anchors.fill: parent
          anchors.leftMargin: 2
          anchors.rightMargin: TibiaStyle.marginRelated
          anchors.verticalCenter: parent.verticalCenter
          elide: styleData.elideMode
          horizontalAlignment: styleData.textAlignment

          color: (modelData != null && modelData.isDubious)
            ? (styleData.selected ? "#B01111" : "#C87D7D")
            : styleData.selected
              ? TibiaStyle.textFieldSelectionTextColor
              : ((modelData != null && modelData.maximumAcceptAmount > 0)
                ? TibiaStyle.textFieldTextColor
                : "#808080")
        } // TibiaText

        TibiaVerticalSeparator {
          visible: styleData.column < tableView.columnCount - 1
          anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
        } // TibiaVerticalSeparator
      } // itemDelegate
    } // TibiaTableVie
  } // Component

  Component {
    id: offerAcceptViewComponent

    ColumnLayout {
      id: offerAcceptViewRoot
      property alias headerText: headerText.text
      property var model: null
      property int modelIndex: -1
      property var offerTableComponent: null

      spacing: 0// TibiaStyle.marginRelated

      function updateTotalValue() {
        //validSelection property is not up to date at this point ...
        if (amountSlider.value > 0
            && offerAcceptViewRoot.model != null
            && offerAcceptViewRoot.modelIndex >= 0
            && offerAcceptViewRoot.modelIndex < model.length) {
          totalValueText.totalValue = model[offerAcceptViewRoot.modelIndex].formatTotalValue(amountSlider.value);
        } else {
          totalValueText.totalValue = "0";
        }
      } //function updateTotalValue()

      onModelIndexChanged: {
        amountSlider.value = 0;
        updateTotalValue();
      } //onModelIndexChanged

      onModelChanged: {
        amountSlider.value = 0;
        updateTotalValue();
      } //onModelChanged

      RowLayout {
        TibiaText {
          id: headerText
          Layout.fillWidth: true
        } // TibiaText

        Layout.alignment: Qt.AlignRight
        spacing: TibiaStyle.marginRelated

        TibiaText {
          text: qsTrId("market_label_amount")
        } // TibiaText

        TibiaText {
          Layout.preferredWidth: TibiaStyle.market5DigitsNumberSpace
          text: TextHelper.formatNumberWithThousandSeparators(amountSlider.value)
          horizontalAlignment: Text.AlignRight
        } //TibiaText

        TibiaSlider {
          id: amountSlider
          property bool validSelection: model != null && modelIndex >= 0 && modelIndex < model.length

          Layout.preferredWidth: TibiaStyle.marketAmountSliderWidth
          minimumValue: validSelection && maximumValue > 0 ? tradePacketSize : 0
          maximumValue: validSelection ? (model[modelIndex].maximumAcceptAmount- (model[modelIndex].maximumAcceptAmount % tradePacketSize)) : 0
          stepSize: tradePacketSize
          value: 0

          onValueChanged: {
            updateTotalValue();
          } //onValueChanged

          onMinimumValueChanged: {
            //no binding for value as it is overwritten when slider is moved
            value = minimumValue;
            updateTotalValue();
          } //onMinimumValueChanged
        } // TibiaSlider

        TibiaText {
          Layout.leftMargin: -(parent.spacing - TibiaStyle.marginWide)
          text: qsTrId("market_label_total")
        } // TibiaText

        TibiaText {
          id: totalValueText
          property string totalValue: "0"

          Layout.preferredWidth: TibiaStyle.market7DigitsNumberSpace
          text: totalValue
          horizontalAlignment: Text.AlignRight
        } //TibiaText

        Image {
          Layout.leftMargin: -(parent.spacing - TibiaStyle.marginNarrow)
          source: "/images/icon-goldcoin.png"
        } //Image

        TibiaButton {
          text: qsTrId("accept")
          enabled: amountSlider.value > 0

          onClicked: {
            if (controller != null && amountSlider.value > 0) {
              controller.onMarketOfferAccept(model[modelIndex].terminationTimestamp,
                                             model[modelIndex].terminationTimestampUniqueIdentifier,
                                             amountSlider.value);
              if (offerTableComponent != null) {
                offerTableComponent.resetSelection();
              }
            }
          } // onClicked
        } // TibiaButton
      } //RowLayout
    } //ColumnLayout
  } //Component

  ColumnLayout {
    spacing: TibiaStyle.marginRelated

    Loader {
      Layout.fillWidth: true
      sourceComponent: offerAcceptViewComponent

      onLoaded: {
        item.headerText = qsTrId("market_sell_offers_nocount");
        item.model = Qt.binding(function() { return sellOffersModel; });
        item.modelIndex = Qt.binding(function() { return selectedSellOfferIndex; });
        item.offerTableComponent= Qt.binding(function() { return sellOfferLoader; });
      } //onLoaded
    } // Loader

    Loader {
      id: sellOfferLoader
      Layout.fillWidth: true
      Layout.fillHeight: true
      sourceComponent: offerTableView
      onLoaded: {
        item.model = Qt.binding(function() { return sellOffersModel; });
        item.itemSelectedFunction = function(RowIndex) {
          selectedSellOfferIndex = RowIndex;
        }
      } //onLoaded
      function resetSelection() {
        if (item) {
          item.selection.clear();
          item.currentRow = -1;
        }
      } //function resetSelection()
    } // Loader
  } //ColumnLayout

  ColumnLayout {
    spacing: TibiaStyle.marginRelated

    Loader {
      Layout.fillWidth: true
      sourceComponent: offerAcceptViewComponent

      onLoaded: {
        item.headerText = qsTrId("market_buy_offers_nocount");
        item.model = Qt.binding(function() { return buyOffersModel; });
        item.modelIndex = Qt.binding(function() { return selectedBuyOfferIndex; });
        item.offerTableComponent= Qt.binding(function() { return buyOfferLoader; });
      } //onLoaded
    } // Loader

    Loader {
      id: buyOfferLoader
      Layout.fillWidth: true
      Layout.fillHeight: true
      sourceComponent: offerTableView
      onLoaded: {
        item.model = Qt.binding(function() { return buyOffersModel; });
        item.itemSelectedFunction = function(RowIndex) {
          selectedBuyOfferIndex = RowIndex;
        }
      } //onLoaded
      function resetSelection() {
        if (item) {
          item.selection.clear();
          item.currentRow = -1;
        }
      } //function resetSelection()
    } // Loader
  } //ColumnLayout

  // From here on, the "Create Offer" interface

  ColumnLayout {
    Layout.fillWidth: true
    spacing: TibiaStyle.marginRelated

    TibiaText {
      Layout.alignment: Qt.AlignLeft
      text: qsTrId("market_create_offer")
      styleType: "Dialog"
    } //TibiaText

    RowLayout {
      Layout.fillWidth: true
      spacing: TibiaStyle.marginWide

      ColumnLayout {
        //sell or buy
        Layout.alignment: Qt.AlignTop
        spacing: TibiaStyle.marginRelated

        ButtonGroup {
          id: sellOrBuyGroup

          onCheckedButtonChanged: {
            piecePriceText.text = "";
            createAmountSlider.value = 0;
            requestUpdateForMaximumOfferCreationAmount();
          } //onCheckedButtonChanged
        } //ButtonGroup

        TibiaRadioButton {
          id: sellOfferRadioButton
          text: qsTrId("market_sell_button")
          tooltipText: qsTrId("market_sell_button_tooltip")
          checked: true
          ButtonGroup.group: sellOrBuyGroup
        } //TibiaRadioButton

        TibiaRadioButton {
          text: qsTrId("buy")
          tooltipText: qsTrId("market_buy_button_tooltip")
          ButtonGroup.group: sellOrBuyGroup
        } //TibiaRadioButton
      } //ColumnLayout

      Item { Layout.fillWidth: true }

      GridLayout {
        //amount and piece price
        Layout.alignment: Qt.AlignTop
        columnSpacing: TibiaStyle.marginRelated
        rowSpacing: TibiaStyle.marginRelated

        TibiaText {
          Layout.row: 0
          Layout.column: 0
          Layout.rowSpan: 2
          Layout.alignment: Qt.AlignRight | Qt.AlignTop
          text: qsTrId("market_label_amount")
        } //TibiaText

        TibiaText {
          Layout.row: 0
          Layout.column: 1
          text: TextHelper.formatNumberWithThousandSeparators(createAmountSlider.value)
        } //TibiaText

        TibiaSlider {
          id: createAmountSlider
          Layout.preferredWidth: 150
          Layout.row: 1
          Layout.column: 1
          minimumValue: maximumOfferCreationAmount > 0 ? tradePacketSize : 0
          maximumValue: maximumOfferCreationAmount - (maximumOfferCreationAmount % tradePacketSize)
          stepSize: tradePacketSize
          value: 0

          onValueChanged: {
            updateSummaryValues();
          } //onValueChanged
        } //TibiaSlider

        TibiaText {
          Layout.row: 2
          Layout.column: 0
          Layout.alignment: Qt.AlignRight
          text: qsTrId("market_piece_price")
        } //TibiaText

        TibiaTextField {
          id: piecePriceText
          Layout.row: 2
          Layout.column: 1
          Layout.preferredWidth: createAmountSlider.Layout.preferredWidth
          validator: RegularExpressionValidator { regularExpression: /[0-9]{0,12}/; }
          maximumLength: 12
          enabled: sellOrBuyGroup.checkedButton != null
          KeyNavigation.tab: piecePriceText

          onEnabledChanged: {
            if (!enabled) {
              text = "";
            }
          } //onEnabledChanged

          onTextChanged: {
            requestUpdateForMaximumOfferCreationAmount();
            updateSummaryValues();
          } //onTextChanged

          Image {
            anchors.right: parent.right
            anchors.rightMargin: 3
            anchors.verticalCenter: parent.verticalCenter
            source: "/images/icon-goldcoin.png"
          } //Image
        } //TibiaTextField
      } //GridLayout

      GridLayout {
        //summary
        Layout.alignment: Qt.AlignTop
        Layout.maximumWidth: 200
        Layout.preferredWidth: Layout.maximumWidth

        columns: 3
        columnSpacing: TibiaStyle.marginRelated
        rowSpacing: TibiaStyle.marginRelated

        TibiaText {
          Layout.preferredWidth: 82
          Layout.alignment: Qt.AlignRight
          horizontalAlignment: Text.AlignRight
          text: sellOfferRadioButton.checked ? qsTrId("market_label_gross_profit")
                                             : qsTrId("market_label_price")
        } //TibiaText

        TibiaText {
          Layout.fillWidth: true
          horizontalAlignment: Text.AlignRight
          elide: Text.ElideRight
          text: priceOrProfit
        } //TibiaText

        Image {
          source: "/images/icon-goldcoin.png"
        } //Image

        TibiaText {
          Layout.alignment: Qt.AlignRight
          text: qsTrId("market_label_fee")
        } //TibiaText

        TibiaText {
          Layout.fillWidth: true
          horizontalAlignment: Text.AlignRight
          elide: Text.ElideRight
          text: creationFee
        } //TibiaText

        Image {
          source: "/images/icon-goldcoin.png"
        } //Image

        TibiaHorizontalSeparator {
          Layout.columnSpan: 3
          Layout.topMargin: -3
          Layout.bottomMargin: -3
          Layout.fillWidth: true
        } // TibiaHorizontalSeparator

        TibiaText {
          Layout.alignment: Qt.AlignRight
          text: sellOfferRadioButton.checked ? qsTrId("market_label_total_profit")
                                             : qsTrId("market_label_total_price")
        } //TibiaText

        TibiaText {
          Layout.fillWidth: true
          horizontalAlignment: Text.AlignRight
          elide: Text.ElideRight
          text: totalPriceOrProfit
        } //TibiaText

        Image {
          source: "/images/icon-goldcoin.png"
        } //Image
      } //GridLayout
    } //RowLayout


    RowLayout {
      spacing: TibiaStyle.marginRelated

      TibiaButton {
        imageSource: "/images/icon-tibiastore.png"
        imageAnchor: "left"
        text: qsTrId("market_open_store").arg(
          controller != null ? controller.selectedCategoryName : qsTrId("dummy_unknown"));
        color: "blue"
        Layout.preferredWidth: TibiaStyle.buttonWidthWider
        // Changing the visibility of the element causes the box to become wider, thus breaking the layout
        enabled: controller != null && controller.showStoreDeeplink
        opacity: controller != null && controller.showStoreDeeplink ? 1 : 0
        textXOffset: TibiaStyle.marginUnrelated

        onClicked: {
          if (controller != null) {
            controller.onStoreDeeplinkClicked();
          }
        }
      } // TibiaButton

      Item {
        Layout.fillWidth: true
      } // Item

      TibiaCheckBox {
        id: anonymousCheckBox
        text: qsTrId("market_anonymous_offer")
        tooltipText: qsTrId("market_anonymous_offer_tooltip")
      } //TibiaCheckBox

      TibiaButton {
        text: qsTrId("market_create_offer_button")
        enabled: createAmountSlider.value > 0 && parseInt(piecePriceText.text) > 0 && canCreateNewOffer

        onClicked: {
          if (controller != null) {
            controller.onMarketOfferCreate(sellOfferRadioButton.checked ? "sell" : "buy",
                                           createAmountSlider.value,
                                           parseInt(piecePriceText.text),
                                           anonymousCheckBox.checked)
          }
          resetOfferCreation();
        } //onClicked
      } //TibiaButton
    } //RowLayout
  } //ColumnLayout
} // ColumnLayout
