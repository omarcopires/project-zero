import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.LegacyControls



ColumnLayout {
  property var controller: null
  property var buyOffersModel: null
  property var sellOffersModel: null

  spacing: TibiaStyle.marginUnrelated

  Component {
    id: offersTable

    TibiaTableView {
      id: tableView
      headerVisible: true
      alternatingRowColors: true
      horizontalScrollBarPolicy: ScrollBar.AsNeeded
      verticalScrollBarPolicy: ScrollBar.AlwaysOn

      TableViewColumn {
        role: "itemNameWithTier"
        title: qsTrId("market_item_name_header")
        width: tableView.contentItem.width
             - amountColumn.width
             - piecePriceColumn.width
             - totalPriceColumn.width
             - endsAtTimeColumn.width
             - TibiaStyle.marketColumnWidthStatus //so it alligns with the history tab
        movable: false
      } //TableViewColumn
      TableViewColumn {
        id: amountColumn
        role: "amountText"
        title: qsTrId("market_amount_header")
        width: TibiaStyle.marketColumnWidthAmountText
        horizontalAlignment: Text.AlignRight
        movable: false
      } //TableViewColumn
      TableViewColumn {
        id: piecePriceColumn
        role: "piecePriceText"
        title: qsTrId("market_piece_price_header")
        width: TibiaStyle.marketColumnWidthPriceText
        horizontalAlignment: Text.AlignRight
        movable: false
      } //TableViewColumn
      TableViewColumn {
        id: totalPriceColumn
        role: "totalPriceText"
        title: qsTrId("market_total_price_header")
        width: TibiaStyle.marketColumnWidthPriceText
        horizontalAlignment: Text.AlignRight
        movable: false
      } //TableViewColumn
      TableViewColumn {
        id: endsAtTimeColumn
        role: "endsAtTime"
        title: qsTrId("market_ends_at_header")
        width: TibiaStyle.columnWidthDateTime
        movable: false
        resizable: false
      } //TableViewColumn
    } // TibiaTableView
  } // Component

  RowLayout {
    TibiaText {
      Layout.fillWidth: true
      text: qsTrId("market_sell_offers").arg(sellOffersModel != null ? sellOffersModel.length : 0)
      styleType: "Dialog"
    } // TibiaText

    TibiaButton {
      id: cancelSellOffer
      Layout.preferredWidth: TibiaStyle.buttonWidthBroad
      text: qsTrId("market_cancel_offer_button")
      enabled: false

      onClicked: {
        if (controller != null && sellOffersTable.item.selection.count > 0) {
          controller.onMarketOfferCancel(
            sellOffersTable.item.model[sellOffersTable.item.currentRow].terminationTimestamp,
            sellOffersTable.item.model[sellOffersTable.item.currentRow].terminationTimestampUniqueIdentifier);
        }
      } // onClicked
    } // TibiaButton
  } // RowLayout

  Loader {
    id: sellOffersTable
    Layout.fillWidth: true
    Layout.fillHeight: true
    sourceComponent: offersTable

    onLoaded: {
      item.model = Qt.binding(function() { return sellOffersModel; });
      cancelSellOffer.enabled = Qt.binding(function() { return item.selection.count > 0; });
    }
  } // Loader

  RowLayout {
    TibiaText {
      Layout.fillWidth: true
      text: qsTrId("market_buy_offers").arg(buyOffersModel != null ? buyOffersModel.length : 0)
      styleType: "Dialog"
    } // TibiaText

    TibiaButton {
      id: cancelBuyOffer
      Layout.preferredWidth: TibiaStyle.buttonWidthBroad
      text: qsTrId("market_cancel_offer_button")
      enabled: false

      onClicked: {
        if (controller != null && buyOffersTable.item.selection.count > 0) {
          controller.onMarketOfferCancel(
            buyOffersTable.item.model[buyOffersTable.item.currentRow].terminationTimestamp,
            buyOffersTable.item.model[buyOffersTable.item.currentRow].terminationTimestampUniqueIdentifier);
        }
      } // onClicked
    } // TibiaButton
  } // RowLayout

  Loader {
    id: buyOffersTable
    Layout.fillWidth: true
    Layout.fillHeight: true
    sourceComponent: offersTable

    onLoaded: {
      item.model = Qt.binding(function() { return buyOffersModel; });
      cancelBuyOffer.enabled = Qt.binding(function() { return item.selection.count > 0; });
    }
  } // Loader
} // ColumnLayout
