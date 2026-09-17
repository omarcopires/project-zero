import QtQuick
import QtQuick.Layouts

import qmlcomponents
import qmlenumvalues
import QtQuick.LegacyControls


TibiaDialog {
  id: root
  caption: qsTrId("transaction_details_dialog_caption")
  width: 600

  property var controller: null

  initialFocusItem: root
  KeyNavigation.tab: root

  onReturnPressedFunction: function() {}
  onCancelPressedFunction: onCloseClicked

  function onCloseClicked() {
    if (controller != null) {
      controller.requestClose();
    }
  } //function onCancelClicked

  ColumnLayout {

    id: outerColumnLayout
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    spacing: 10

    Loader {

      Layout.alignment: Qt.AlignHCenter

      Component {
        id: singleTransactionComponent


        ColumnLayout {
          id: innerLayout


          GridLayout {
            id: singleTransactionTable
            Layout.alignment: Qt.AlignHCenter

            rows: 6
            flow: GridLayout.TopToBottom
            columnSpacing: 10

            TibiaText {
              text: qsTrId("transaction_details_date")
            } // TibiaText

            TibiaText {
              text: qsTrId("transaction_details_description")
            } // TibiaText

            TibiaText {
              text: qsTrId("character") + ":"
            } // TibiaText

            TibiaText {
              text: (controller != null && controller.singleTransactionGoldBalanceChange < 0) ? qsTrId("transaction_details_coins_purchased") : qsTrId("transaction_details_coins_sold")
            } // TibiaText

            TibiaText {
              text: qsTrId("transaction_details_piece_price")
            } // TibiaText

            TibiaText {
              text: (controller != null && controller.singleTransactionGoldBalanceChange > 0) ? qsTrId("transaction_details_gold_balance_positive") : qsTrId("transaction_details_gold_balance_negative")
            } // TibiaText

            TibiaText {
              text: controller != null ? controller.singleTransactionDate : ""
            } // TibiaText

            TibiaText {
              text: controller != null ? controller.singleTransactionDescription : ""
            } // TibiaText

            TibiaText {
              text: controller != null ? controller.singleTransactionCharacterName : ""
            } // TibiaText


            TibiaBalanceTextWithIcon {
              value: controller != null ? controller.singleTransactionCoinBalanceChange : 0
              iconSource: "/images/icon-tibiacointransferable.png"
            } // TibiaBalanceTextWithIcon


            TibiaBalanceTextWithIcon {
              value: controller != null ? controller.singleTransactionPiecePrice : 0
              iconSource: "/images/icon-goldcoin.png"
            } // TibiaBalanceTextWithIcon


            TibiaBalanceTextWithIcon {
              value: controller != null ? controller.singleTransactionGoldBalanceChange : 0
              iconSource: "/images/icon-goldcoin.png"
            } // TibiaBalanceTextWithIcon


          } // GridLayout

        } // ColumnLayout
      } // Component

      Component {
        id: multiTransactionComponent

        ColumnLayout {
          id: innerLayoutMultiTransaction


          GridLayout {
            id: multiTransactionTable

            Layout.alignment: Qt.AlignHCenter

            rows: 6
            flow: GridLayout.TopToBottom
            columnSpacing: 10

            TibiaText {
              text: qsTrId("character") + ":"
            } // TibiaText

            TibiaText {
              text: qsTrId("transaction_details_total_offer")
            } // TibiaText

            TibiaText {
              text: qsTrId("transaction_details_piece_price")
            } // TibiaText

            TibiaText {
              text: qsTrId("transaction_details_received_gold")
            } // TibiaText

            TibiaText {
              text: qsTrId("transaction_details_sold_coins")
            } // TibiaText

            TibiaText {
              text: qsTrId("transaction_details_coins_remaining_market")
            } // TibiaText

            TibiaText {
              text: controller != null ? controller.multiTransactionCharacterName : ""
            } // TibiaText


            TibiaBalanceTextWithIcon {
              value: controller != null ? controller.multiTransactionTotalCoins : 0
              iconSource: "/images/icon-tibiacointransferable.png"
            } // TibiaBalanceTextWithIcon


            TibiaBalanceTextWithIcon {
              value: controller != null ? controller.multiTransactionPiecePrice : 0
              iconSource: "/images/icon-goldcoin.png"
            } // TibiaBalanceTextWithIcon


            TibiaBalanceTextWithIcon {
              value: controller != null ? (controller.multiTransactionReceivedGold) : 0
              iconSource: "/images/icon-goldcoin.png"
            } // TibiaBalanceTextWithIcon


            TibiaBalanceTextWithIcon {
              value: controller != null ? controller.multiTransactionSoldCoins : 0
              iconSource: "/images/icon-tibiacointransferable.png"
            } // TibiaBalanceTextWithIcon


            TibiaBalanceTextWithIcon {
              value: controller != null ? controller.multiTransactionCoinsReainingInMarket : 0
              iconSource: "/images/icon-tibiacointransferable.png"
            } // TibiaBalanceTextWithIcon


          } // GridLayout


          RowLayout {

            Layout.bottomMargin: TibiaStyle.marginRelated
            Layout.topMargin: TibiaStyle.marginRelated
            Layout.alignment: Qt.AlignHCenter

            TibiaHorizontalSeparator {
              id: leftSeparator
            } //TibiaHorizontalSeparator

            TibiaText {
              id: headlineText
              text: qsTrId("transaction_details_history_headline")
              Layout.alignment: Qt.AlignCenter
            } // TibiaText

            TibiaHorizontalSeparator {
              id: rightSeparator
            } //TibiaHorizontalSeparator

          } // RowLayout


          TibiaTableView {
            id: historyTable

            KeyNavigation.tab: root

            model: controller != null ? controller.multiTransactionChildTransactionList : null

            headerVisible: true
            alternatingRowColors: true
            Layout.preferredWidth: 560
            Layout.preferredHeight: 150

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
            } //TableViewColumn

            TableViewColumn {
              id: descriptionColumn
              role: "description"
              title: qsTrId("transaction_details_description_column")
              width: historyTable.contentItem.width - dateColumn.width - balanceColumn.width
              movable: false
              resizable: false
            } //TableViewColumn

            TableViewColumn {
              id: balanceColumn
              role: "description"
              title: qsTrId("transaction_details_balance_column")
              width: 90
              movable: false
              resizable: false
              horizontalAlignment: Text.AlignRight

              delegate: Item {
                anchors.fill: parent

                RowLayout {
                  anchors.left: parent.left
                  anchors.right: parent.right
                  anchors.rightMargin: 1
                  spacing: TibiaStyle.marginNarrow
                  TibiaText {
                    readonly property string balanceChangeString: modelData != null ? TextHelper.formatNumberWithThousandSeparatorsAndThousandShortcutsAsMultiString(modelData.balanceChange, true) : "0"
                    text: balanceChangeString
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignRight
                    Layout.fillWidth: true
                  } //TibiaText

                  Image {
                    source: (modelData != null && modelData.currency == QmlChildTransaction.TibiaCoins) ? "/images/icon-tibiacointransferable.png" : "/images/icon-goldcoin.png"
                    smooth: false
                    visible: controller != null
                    Layout.leftMargin: TibiaStyle.marginNarrow
                    Layout.alignment: Qt.AlignRight
                  } //Image
                } //RowLayout

                TibiaVerticalSeparator {
                  visible: historyTable.headerVisible && historyTable.columnCount > 1
                       && styleData.column < historyTable.columnCount-1
                  anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
                } // TibiaVerticalSeparator
              } //itemDelegate: Item
            } //TableViewColumn



          } // TibiaTableView


        } // ColumnLayout


      } // Component


      Component {
        id: waitForDataComponent

        ColumnLayout {

          RowLayout {

            Layout.bottomMargin: TibiaStyle.marginRelated
            Layout.topMargin: TibiaStyle.marginRelated
            Layout.alignment: Qt.AlignHCenter

            TibiaHorizontalSeparator {
              id: leftSeparator
            } //TibiaHorizontalSeparator

            TibiaText {
              id: headlineText
              text: qsTrId("data_loading_wait")
              Layout.alignment: Qt.AlignCenter
            } // TibiaText

            TibiaHorizontalSeparator {
              id: rightSeparator
            } //TibiaHorizontalSeparator

          } // RowLayout


          Image {
            source: "/images/dynamic/dynamic-image-loading.png"
            Layout.alignment: Qt.AlignHCenter
          } // Image


        } // ColumnLayout

      } // Component


      sourceComponent: controller != null
                       ? ( controller.transactionLoaded
                           ? (controller.transactionType == MarketCoinTransactionDetailsDialogController.SingleTransaction ? singleTransactionComponent : multiTransactionComponent)
                           : waitForDataComponent )
                       : null

      onLoaded: {
        root.centerDialog();
      } // onLoaded

    } // Loader


    TibiaHorizontalSeparator {
      Layout.fillWidth: true
      Layout.bottomMargin: TibiaStyle.marginRelated
      Layout.topMargin: TibiaStyle.marginRelated
    } //TibiaHorizontalSeparator


    TibiaButton {
      id: closeButton
      text: qsTrId("close")
      Layout.alignment: Qt.AlignRight
      onClicked: root.onCloseClicked()
    } // TibiaButton

  } // ColumnLayout


} //TibiaDialog
