import QtQuick
import QtQuick.Layouts

import qmlcomponents


ColumnLayout {
  property var balanceType: "GoldCoin"

  Component {
    id: tibiaCoinBalanceLongComponent
    TibiaFrame1PixelDown {
      height: TibiaStyle.currencyViewHeight
      clip: true //for very high number of tibia couns this avoids to bad graphics glitches
      BorderImage {
        smooth: false
        anchors.fill: parent
        anchors.margins: 1

        source: "/images/backdrop-dark-grey.png"
        horizontalTileMode: BorderImage.Repeat
        visible: true
        // cache is set to false because of a strange error (TIBIA-17267)
        // when used in a grid view delegate and scrolling down sometimes the backgroung graphics seem to
        // be drawn over the currencyIconImage. setting cache to false prevents this
        cache: false
      } //Image

      RowLayout {
        anchors { left: parent.left; right: parent.right }
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: parent.borderWidth + TibiaStyle.marginNarrow
        anchors.rightMargin: parent.borderWidth + TibiaStyle.marginNarrow
        spacing: 0

        Item {
          Layout.fillWidth: true
        } //Item

        TibiaText {
          text: storeAndResourceBalanceHelper.storeBalance != null
                ? (storeAndResourceBalanceHelper.storeBalance.isUpdating
                  ? qsTrId("store_balance_updating")
                  : (storeAndResourceBalanceHelper.storeBalance.isValid ? storeAndResourceBalanceHelper.storeBalance.totalBalanceString : "-"))
                : "-"
        } //TibiaText

        Image {
          smooth: false
          source: "/images/icon-tibiacoin.png"
          Tooltip {
            anchors.fill: parent
            text: qsTrId("currency_view_tibiacoins_tooltip")
          } //Tooltip
        } //Image

        TibiaText {
          Layout.leftMargin: TibiaStyle.marginRelated
          text: qsTrId("store_including")
        } //TibiaText

        TibiaText {
          Layout.leftMargin: TibiaStyle.marginNarrow
          text: storeAndResourceBalanceHelper.storeBalance != null
                ? (storeAndResourceBalanceHelper.storeBalance.isUpdating
                  ? qsTrId("store_balance_updating")
                  : (storeAndResourceBalanceHelper.storeBalance.isValid ? storeAndResourceBalanceHelper.storeBalance.confirmedBalanceString : "-"))
                : "-"
        } //TibiaText

        Image {
          smooth: false
          source: "/images/icon-tibiacointransferable.png"
          Tooltip {
            anchors.fill: parent
            text: storeAndResourceBalanceHelper.storeBalance.reservedTibiaCoins > 0 ? qsTrId("currency_view_tibiacoins_transferable_tooltip_reserved_coins").arg(storeAndResourceBalanceHelper.storeBalance.reservedTibiaCoinsString)  : qsTrId("currency_view_tibiacoins_transferable_tooltip")
          } //Tooltip
        } //Image

        TibiaText {
          text: ")"
        } //TibiaText
      } //RowLayout
    } //TibiaFrame1PixelDown
  } //Component

  Component {
    id: tibiaGoldBalanceComponent
    TibiaCurrencyView {
      balance: TextHelper.formatNumberWithThousandSeparatorsAndThousandShortcutsAsMultiString(storeAndResourceBalanceHelper.totalGoldBalance)
      rightAligned: true
      iconId: "GoldCoin"
      Component.onCompleted: {
        tooltipText = Qt.binding(function() {
          return qsTrId("gold_balance_tooltip").arg(storeAndResourceBalanceHelper.inventoryGoldBalanceString)
                                               .arg(storeAndResourceBalanceHelper.bankGoldBalanceString);
        });
      } //Component.onCompleted
    } // TibiaCurrencyView
  } //Component

  Component {
    id: tibiaBankGoldBalanceComponent
    TibiaCurrencyView {
      balance: TextHelper.formatNumberWithThousandSeparatorsAndThousandShortcutsAsMultiString(storeAndResourceBalanceHelper.bankGoldBalance)
      rightAligned: true
      iconId: "BankGoldCoin"
    } // TibiaCurrencyView
  } //Component

  Component {
    id: tibiaGuildBankGoldBalanceComponent
    TibiaCurrencyView {
      balance: TextHelper.formatNumberWithThousandSeparatorsAndThousandShortcutsAsMultiString(storeAndResourceBalanceHelper.guildBankGoldBalance)
      rightAligned: true
      iconId: "GuildBankGoldCoin"
    } // TibiaCurrencyView
  } //Component

  Component {
    id: tibiaCoinBalanceComponent
    TibiaCurrencyView {
      property var storeBalance: storeAndResourceBalanceHelper.storeBalance
      property var showTransferable: false
      balance: storeBalance != null
        ? (storeBalance.isUpdating
          ? qsTrId("market_coins_updating")
          : (storeBalance.isValid ? (showTransferable ? storeBalance.confirmedBalanceString : storeBalance.totalBalanceString) : "-"))
        : "-"
      rightAligned: true
      iconId: showTransferable ? "TibiaCoinTransferable" : "TibiaCoin"
      tooltipText: storeBalance != null ? qsTrId("tibia_coins_amount_tooltip").arg(storeBalance.totalBalanceString)
                                                                              .arg(storeBalance.confirmedBalanceString)
                                        : ""
    } //TibiaCurrencyView
  } //Component

  Component {
    id: genericResourceBalanceComponent
    TibiaCurrencyView {
      rightAligned: true
      iconId: balanceType
    } // TibiaCurrencyView
  } //Component

  Loader {
    Layout.preferredWidth: parent.width
    width: parent.width
    sourceComponent: undefined
    Component.onCompleted: {
      sourceComponent = Qt.binding(function() {
        if (balanceType == "GoldCoin") {
          return tibiaGoldBalanceComponent;
        } else if (balanceType == "TibiaCoin") {
          return tibiaCoinBalanceComponent;
        } else if (balanceType == "TibiaCoinTransferable") {
          return tibiaCoinBalanceComponent;
        } else if (balanceType == "TibiaCoinLong") {
          return tibiaCoinBalanceLongComponent;
        } else if (balanceType == "BankGoldCoin") {
          return tibiaBankGoldBalanceComponent;
        } else if (balanceType == "GuildBankGoldCoin" && storeAndResourceBalanceHelper.hasGuildBankGoldBalance) {
          return tibiaGuildBankGoldBalanceComponent;
        } else if (balanceType == "PreyHuntingTaskTokens") {
          return genericResourceBalanceComponent;
        } else if (balanceType == "PreyWildcards") {
          return genericResourceBalanceComponent;
        } else if (balanceType == "Dust") {
          return genericResourceBalanceComponent;
        } else if (balanceType == "Slivers") {
          return genericResourceBalanceComponent;
        } else if (balanceType == "ExaltedCore") {
          return genericResourceBalanceComponent;
        } else if (balanceType == "LesserFragments") {
          return genericResourceBalanceComponent;
        } else if (balanceType == "GreaterFragments") {
          return genericResourceBalanceComponent;
        } else if (balanceType == "LunarAscensionOrbs") {
          return genericResourceBalanceComponent;
        } else {
          return undefined;
        }
      });
    } //Component.onCompleted

    onItemChanged: {
      if (balanceType == "TibiaCoin") {
        item.showTransferable = false;
      } else if (balanceType == "TibiaCoinTransferable") {
        item.showTransferable = true;
      } else if (balanceType == "PreyHuntingTaskTokens") {
        item.balance = Qt.binding(function() {
          return TextHelper.formatNumberWithThousandSeparatorsAndThousandShortcutsAsMultiString(storeAndResourceBalanceHelper.preyHuntingTaskTokens);
        });
      } else if (balanceType == "PreyWildcards") {
        item.balance = Qt.binding(function() {
          return TextHelper.formatNumberWithThousandSeparatorsAndThousandShortcutsAsMultiString(storeAndResourceBalanceHelper.preyWildcards);
        });
      } else if (balanceType == "Dust") {
        item.balance = Qt.binding(function() {
          return TextHelper.formatTwoNumbersWithThousandSeparatorsAndThousandShortcutsAsMultiString("%1/%2", storeAndResourceBalanceHelper.exaltedDustBalance, storeAndResourceBalanceHelper.exaltedDustMaximum, false);
        });
      } else if (balanceType == "Slivers") {
        item.balance = Qt.binding(function() {
          return TextHelper.formatNumberWithThousandSeparatorsAndThousandShortcutsAsMultiString(storeAndResourceBalanceHelper.exaltedSliversCount);
        });
      } else if (balanceType == "ExaltedCore") {
        item.balance = Qt.binding(function() {
          return TextHelper.formatNumberWithThousandSeparatorsAndThousandShortcutsAsMultiString(storeAndResourceBalanceHelper.exaltedCoreCount);
        });
      } else if (balanceType == "LesserFragments") {
        item.balance = Qt.binding(function() {
          return TextHelper.formatNumberWithThousandSeparatorsAndThousandShortcutsAsMultiString(storeAndResourceBalanceHelper.lesserFragmentCount);
        });
      } else if (balanceType == "GreaterFragments") {
        item.balance = Qt.binding(function() {
          return TextHelper.formatNumberWithThousandSeparatorsAndThousandShortcutsAsMultiString(storeAndResourceBalanceHelper.greaterFragmentCount);
        });
      } else if (balanceType == "LunarAscensionOrbs") {
        item.balance = Qt.binding(function() {
          return TextHelper.formatNumberWithThousandSeparatorsAndThousandShortcutsAsMultiString(storeAndResourceBalanceHelper.lunarAscensionOrbsAmount);
        });
      }
    } //onItemChanged
  } //Loader
} //ColumnLayout

