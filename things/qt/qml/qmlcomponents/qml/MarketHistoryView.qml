import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.LegacyControls



ColumnLayout {
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
             - statusColumn.width
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
        title: qsTrId("market_ended_at_header")
        width: TibiaStyle.columnWidthDateTime
        movable: false
      } //TableViewColumn
      TableViewColumn {
        id: statusColumn
        role: "auctionStatus"
        title: qsTrId("status")
        width: TibiaStyle.marketColumnWidthStatus
        movable: false
      } //TableViewColumn
    } // TibiaTableView
  } // Component

  TibiaText {
    text: qsTrId("market_sell_offers").arg(sellOffersModel != null ? sellOffersModel.length : 0)
    styleType: "Dialog"
    Layout.preferredHeight: TibiaStyle.buttonHeightDefault
    verticalAlignment: Text.AlignVCenter
  } // TibiaText

  Loader {
    Layout.fillWidth: true
    Layout.fillHeight: true
    sourceComponent: offersTable

    onLoaded: {
      item.model = Qt.binding(function() { return sellOffersModel; });
    }
  } // Loader

  TibiaText {
    text: qsTrId("market_buy_offers").arg(buyOffersModel != null ? buyOffersModel.length : 0)
    styleType: "Dialog"
    Layout.preferredHeight: TibiaStyle.buttonHeightDefault
    verticalAlignment: Text.AlignVCenter
  } // TibiaText

  Loader {
    Layout.fillWidth: true
    Layout.fillHeight: true
    sourceComponent: offersTable

    onLoaded: {
      item.model = Qt.binding(function() { return buyOffersModel; });
    }
  } // Loader
} // ColumnLayout
