import QtQuick
import QtQuick.Layouts



TibiaDialog {
  id: marketDialog
  caption: qsTrId("market")
  width: 1000

  property var controller: null
  property alias itemDetailsModel: marketDetails.itemDetailsModel
  property alias itemStatisticsModel: marketDetails.itemStatisticsModel
  property alias buyOffersModel: marketOffers.buyOffersModel
  property alias sellOffersModel: marketOffers.sellOffersModel
  property alias historicBuyOffersModel: historyView.buyOffersModel
  property alias historicSellOffersModel: historyView.sellOffersModel
  property alias ownBuyOffersModel: ownOffersView.buyOffersModel
  property alias ownSellOffersModel: ownOffersView.sellOffersModel
  property alias maximumOfferCreationAmount: marketOffers.maximumOfferCreationAmount
  property alias canCreateNewOffer: marketOffers.canCreateNewOffer
  property alias tradePacketSize: marketOffers.tradePacketSize
  property int selectedAppearanceTypeID: 0

  onCancelPressedFunction: cancelButtonAction
  initialFocusItem: marketCategories

  function cancelButtonAction() {
    if (marketDialog.state != "OFFERS") {
      marketDialog.state = "OFFERS";
    } else if (marketDialog.state == "OFFERS" && controller != null) {
      controller.onCloseButtonPressed();
    }
  } //function cancelButtonAction()

  function setIndexForItemView(Index)
  {
    marketCategories.selectItemIndex(Index);
  }

  onControllerChanged: {
    marketOffers.controller = controller;
    ownOffersView.controller = controller;

    if (controller != null) {
      controller.disconnectFromControllerRequest.connect(marketDialog.disconnectFromControllerRequest)
      controller.itemListSelectionRequest.connect(marketCategories.selectItemIndex);

      marketCategories.categorySelected.connect(controller.onMarketCategorySelected);
      marketCategories.filterSelected.connect(controller.onMarketFilterSelected);
      marketCategories.itemSelected.connect(controller.onMarketCategoryItemSelected);
      marketCategories.classificationFilterWasSelected.connect(controller.onClassificationFilterWasSelected);
      marketCategories.tierFilterWasSelected.connect(controller.onTierFilterWasSelected);
    }
  } // onControllerChanged

  function disconnectFromControllerRequest() {
    if (controller != null) {
      controller.disconnectFromControllerRequest.disconnect(marketDialog.disconnectFromControllerRequest);
      controller.itemListSelectionRequest.disconnect(marketCategories.selectItemIndex);

      marketCategories.categorySelected.disconnect(controller.onMarketCategorySelected);
      marketCategories.filterSelected.disconnect(controller.onMarketFilterSelected);
      marketCategories.itemSelected.disconnect(controller.onMarketCategoryItemSelected);
      marketCategories.classificationFilterWasSelected.disconnect(controller.onClassificationFilterWasSelected);
      marketCategories.tierFilterWasSelected.disconnect(controller.onTierFilterWasSelected);
    }
  } //function disconnectFromControllerRequest()


  states: [
    State {
      name: "OFFERS"
      StateChangeScript { script: (function() {
        if (controller != null) {
          controller.onMarketRefreshOffers();
        }})()}
    },
    State {
      name: "DETAILS"
      PropertyChanges { target: marketOffers; visible: false; }
      PropertyChanges { target: marketDetails; visible: true; }
      PropertyChanges { target: closeButton; text: qsTrId("market"); }
    },
    State {
      name: "MYOFFERS"
      PropertyChanges { target: marketDialog; caption: qsTrId("market_my_offers"); }
      PropertyChanges { target: categoryAndOfferView; visible: false; }
      PropertyChanges { target: ownOffersView; visible: true; }
      PropertyChanges { target: categoryAndOfferViewButtonGroup; visible: false; }
      PropertyChanges { target: myOfferAndHistoryButtonGroup; visible: true; }
      PropertyChanges { target: closeButton; text: qsTrId("market"); }
      StateChangeScript { script: (function() {
        if (controller != null) {
          controller.onMarketOwnOffersOpened();
        }})()}
    },
    State {
      name: "OFFERHISTORY"
      PropertyChanges { target: marketDialog; caption: qsTrId("market_offer_history"); }
      PropertyChanges { target: categoryAndOfferView; visible: false; }
      PropertyChanges { target: historyView; visible: true; }
      PropertyChanges { target: categoryAndOfferViewButtonGroup; visible: false; }
      PropertyChanges { target: myOfferAndHistoryButtonGroup; visible: true; }
      PropertyChanges { target: closeButton; text: qsTrId("market"); }
      StateChangeScript { script: (function() {
        if (controller != null) {
          controller.onMarketHistoryOpened();
        }})()}
    }
  ] // States

  state: "OFFERS"

  ColumnLayout {
    spacing: TibiaStyle.marginUnrelated
    anchors { left: parent.left; right: parent.right; top: parent.top }
    height: 600

    RowLayout {
      id: categoryAndOfferView
      Layout.fillWidth: true
      Layout.fillHeight: true
      spacing: TibiaStyle.marginUnrelated

      MarketCategorySelection {
        id: marketCategories
        Layout.maximumWidth: 160
        useObjectCount: true
        categoryViewHeight: TibiaStyle.marketCategoryViewHeight

        categoryModel: controller != null ? controller.categories : null
        categoryItemModel: controller != null ? controller.appearanceTypeListModel : null
        showLockerOnlyShouldBeChecked: controller != null && controller.showLockerOnly

        enableTierAndClassificationSelection : controller != null ? controller.enableTierAndClassificationSelection : false
        enableTierSelection : controller != null ? controller.enableTierSelection : false
        availableTiers: controller != null ? controller.availableTiers : null
        indexOfSelectedTier: controller != null ? controller.indexOfSelectedTier : -1
        availableClassifications: controller != null ? controller.availableClassifications : null
        indexOfSelectedClassification: controller != null ? controller.indexOfSelectedClassification : -1

        onEscPressedInSearchTextField: {
          marketDialog.cancelButtonAction();
        } //onEscPressedInSearchTextField
      } // MarketCategorySelection

      MarketOffersView {
        id: marketOffers
        Layout.alignment: Qt.AlignTop
        Layout.fillWidth: true
        Layout.fillHeight: true

        selectedAppearanceTypeID: marketDialog.selectedAppearanceTypeID
      } // MarketOffersView

      MarketDetailsView {
        id: marketDetails
        controller: marketDialog.controller
        visible: false
        Layout.fillWidth: true
        Layout.fillHeight: true
      } // MarketDetailsView
    } // RowLayout

    MarketHistoryView {
      id: historyView
      Layout.fillWidth: true
      Layout.fillHeight: true
      visible: false
    } // MarketHistoryView

    MarketOwnOffers {
      id: ownOffersView
      Layout.fillWidth: true
      Layout.fillHeight: true
      visible: false
    } // MarketOwnOffers

    // Content items end here, the following items are all related to the buttons controlling the dialog

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } // TibiaHorizontalSeparator

    RowLayout {
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignRight
      spacing: TibiaStyle.marginRelated

      TibiaCurrentBalanceView {
        Layout.preferredWidth: TibiaStyle.currencyViewWidthLong
        balanceType: "GoldCoin"
      } //TibiaCurrentBalanceView

      TibiaCurrentBalanceView {
        Layout.preferredWidth: TibiaStyle.currencyViewWidth
        balanceType: "TibiaCoinTransferable"
      } //TibiaCurrentBalanceView

      TibiaGetCoinsButton {
        Layout.preferredWidth: TibiaStyle.buttonWidthBroad
        Layout.leftMargin: -(parent.spacing - TibiaStyle.marginNarrow)
        onClicked: {
          if (controller != null) {
            controller.onGetCoinsButtonClicked();
          }
        } //onClicked
      } //TibiaGetCoinsButton

      Item {
        Layout.fillWidth: true
      } //Item

      Item {
        id: categoryAndOfferViewButtonGroup
        property int buttonWidth: 75
      } // Item

      TibiaButton {
        text: qsTrId("market_offers_button")
        visible: categoryAndOfferViewButtonGroup.visible
        Layout.preferredWidth: categoryAndOfferViewButtonGroup.buttonWidth

        onClicked: {
          marketDialog.state = "OFFERS";
        }
      } // TibiaButton

      TibiaButton {
        text: qsTrId("details")
        visible: categoryAndOfferViewButtonGroup.visible
        Layout.preferredWidth: categoryAndOfferViewButtonGroup.buttonWidth

        onClicked: {
          marketDialog.state = "DETAILS";
        }
      } // TibiaButton

      TibiaButton {
        text: qsTrId("market_my_offers")
        visible: categoryAndOfferViewButtonGroup.visible
        Layout.preferredWidth: categoryAndOfferViewButtonGroup.buttonWidth

        onClicked: {
          marketDialog.state = "MYOFFERS";
        }
      } // TibiaButton

      Item {
        id: myOfferAndHistoryButtonGroup
        visible: false
      } // Item

      TibiaButton {
        text: qsTrId("market_current_offers_button")
        visible: myOfferAndHistoryButtonGroup.visible
        Layout.preferredWidth: categoryAndOfferViewButtonGroup.buttonWidth

        onClicked: {
          marketDialog.state = "MYOFFERS";
        }
      } // TibiaButton

      TibiaButton {
        text: qsTrId("market_offer_history")
        visible: myOfferAndHistoryButtonGroup.visible
        Layout.preferredWidth: categoryAndOfferViewButtonGroup.buttonWidth

        onClicked: {
          marketDialog.state = "OFFERHISTORY";
        }
      } // TibiaButton

      TibiaButton {
        id: closeButton
        text: qsTrId("close")
        Layout.preferredWidth: categoryAndOfferViewButtonGroup.buttonWidth

        onClicked: {
          cancelButtonAction();
        }
      } // TibiaButton
    } // RowLayout

  } // ColumnLayout
} // TibiaDialog
