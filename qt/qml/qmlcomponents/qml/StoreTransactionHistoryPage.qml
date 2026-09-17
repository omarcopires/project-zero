import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qmlcomponents
import qmlenumvalues
import QtQuick.LegacyControls


ColumnLayout {

  property var controller: null
  property var transactionPage: controller != null ? controller.transactionPage : null

  TibiaTableView {
    id: historyTable
    Layout.fillWidth: true
    Layout.fillHeight: true
    verticalScrollBarPolicy: ScrollBar.AlwaysOff
    model: transactionPage != null ? transactionPage.transactionEntries : null

    onModelChanged: {
      nextPageButton.enabled = true;
      prevPageButton.enabled = true;
    } //onModelChanged

    headerVisible: true
    alternatingRowColors: true

    Image {
      anchors.centerIn: parent
      source: "/images/dynamic/dynamic-image-loading.png"
      visible: controller != null && controller.transactionHistoryLoading
    } // Image

    rowDelegate: Rectangle {
      height: 15
      color: {
        if (styleData.row < historyTable.rowCount) {
          return styleData.selected
           ? TibiaStyle.tableViewSelectionColor
           : historyTable.alternatingRowColors
             ? styleData.alternate
               ? TibiaStyle.tableViewAlternateBackgroundColor
               : TibiaStyle.tableViewItemBackgroundColor
             : TibiaStyle.tableViewBackgroundColor;
        } else {
          return "transparent";
        }
      }
    }

    TableViewColumn {
      id: dateColumn
      role: "dateString"
      title: qsTrId("date_column_header")
      width: 150
      movable: false
      resizable: false

      delegate: TibiaText {
        anchors.fill: parent
        anchors.leftMargin: TibiaStyle.marginNarrow
        anchors.rightMargin: TibiaStyle.marginRelated
        text: styleData.value
        verticalAlignment: Text.AlignVCenter
        color: styleData.selected
          ? TibiaStyle.textFieldSelectionTextColor
          : TibiaStyle.textFieldTextColor
      }
    } //TableViewColumn

    TableViewColumn {
      id: balanceColumn
      role: "changeText"
      title: qsTrId("store_history_caption_balance")
      width: 90
      movable: false
      resizable: false
      horizontalAlignment: Text.AlignRight

      delegate: Item {
        anchors.fill: parent

        TibiaText {
          anchors { left: parent.left; leftMargin: TibiaStyle.marginNarrow;
                     right: (modelData != null && (modelData.transactionType == THistoryEntry.TRANSACTION_TYPE_GIFT_OR_REFUND) ? balanceSeparator.left : coinIcon.left); rightMargin: TibiaStyle.marginRelated }
          text: styleData.value
          color: {
            if (modelData != null) {
              if (modelData.transactionType == THistoryEntry.TRANSACTION_TYPE_POSITIVE) {
                return TibiaStyle.storeColorPositiveBalance;
              } else if (modelData.transactionType == THistoryEntry.TRANSACTION_TYPE_NEGATIVE) {
                return TibiaStyle.storeColorNegativeBalance;
              } else if (modelData.transactionType == THistoryEntry.TRANSACTION_TYPE_GIFT_OR_REFUND) {
                return TibiaStyle.storeColorGiftRefund;
              }
            }
            return TibiaStyle.textFieldTextColor;
          } //color

          elide: styleData.elideMode
          horizontalAlignment: styleData.textAlignment
        }//TibiaText

        Image {
          id: coinIcon
          anchors { right: parent.right; rightMargin: TibiaStyle.marginRelated
                    top: parent.top; topMargin: 1 }
          visible: modelData != null && (modelData.transactionType != THistoryEntry.TRANSACTION_TYPE_GIFT_OR_REFUND)
          source: {
            if (modelData != null) {
              if (modelData.changeValue == 0) {
                return "";
              }
              if (modelData.currencyType == THistoryEntry.TIBIA_COINS) {
                return "/images/icon-tibiacoin.png";
              }
              if (modelData.currencyType == THistoryEntry.TRUSTED_TIBIA_COINS) {
                return "/images/icon-tibiacointransferable.png";
              }
              if (modelData.currencyType == THistoryEntry.TOURNAMENT_COINS) {
                return "/images/icon-currency-tournamentcoin.png";
              }
            }
            return "";
          } //source
          smooth: false
        } //Image

        TibiaVerticalSeparator {
          id: balanceSeparator
          visible: historyTable.headerVisible && historyTable.columnCount > 1
                   && styleData.column < historyTable.columnCount-1
          anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
        } // TibiaVerticalSeparator
      } //itemDelegate: Item
    } //TableViewColumn

    TableViewColumn {
      id: descriptionColumn
      role: "description"
      title: qsTrId("store_history_caption_description")
      width: historyTable.contentItem.width - dateColumn.width - balanceColumn.width - detailButtonColumn.width
      movable: false
      resizable: false

      delegate: TibiaText {
        anchors.fill: parent
        anchors.leftMargin: TibiaStyle.marginNarrow
        anchors.rightMargin: TibiaStyle.marginRelated
        text: styleData.value
        verticalAlignment: Text.AlignVCenter
        color: styleData.selected
          ? TibiaStyle.textFieldSelectionTextColor
          : TibiaStyle.textFieldTextColor
      }
    } //TableViewColumn


    TableViewColumn {
      id: detailButtonColumn
      width: 50
      delegate: Item {
        TibiaButton {
          anchors.fill: parent
          text: qsTrId("details")
          visible: (modelData != null && modelData.detailsAvailable)
          onClicked: {
            if (modelData != null) {
              controller.requestTransactionDetailsAndShowPage(modelData.transactionID);
            }
          } // onClicked
        } //TibiaButton
      } // Item
    } // TableViewColumn



  } // TibiaTableView

  RowLayout {
    TibiaButton {
      id: prevPageButton
      text: qsTrId("previous_page")
      Layout.preferredWidth: TibiaStyle.buttonWidthWide
      opacity: transactionPage != null && transactionPage.canLoadPreviousPage ? 1 : 0

      onClicked: {
        if (controller != null && transactionPage != null && transactionPage.canLoadPreviousPage) {
          controller.previousTransactionPage();
          nextPageButton.enabled = false;
          prevPageButton.enabled = false;
        }
      } //onClicked
    } //TibiaButton

    TibiaText {
      text: qsTrId("page_current_and_max")
          .arg(transactionPage != null ? transactionPage.currentPage + 1: 1)
          .arg(transactionPage != null ? transactionPage.numberOfPages : 1)
      horizontalAlignment: Text.AlignHCenter
      Layout.fillWidth: true
      opacity: prevPageButton.opacity == 1 || nextPageButton.opacity == 1 ? 1 : 0
    } //TibiaText

    TibiaButton {
      id: nextPageButton
      text: qsTrId("next_page")
      Layout.preferredWidth: TibiaStyle.buttonWidthWide
      opacity: transactionPage != null && transactionPage.canLoadNextPage ? 1 : 0

      onClicked: {
        if (controller != null && transactionPage != null && transactionPage.canLoadNextPage) {
          controller.nextTransactionPage();
          nextPageButton.enabled = false;
          prevPageButton.enabled = false;
        }
      } //onClicked
    } //TibiaButton
  } // RowLayout
} // ColumnLayout
