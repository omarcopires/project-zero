import QtQuick
import QtQuick.Layouts

import qmlcomponents


Item {
  id: currencyView
  implicitHeight: TibiaStyle.currencyViewHeight
  implicitWidth: TibiaStyle.currencyViewWidth

  property bool rightAligned: false
  property alias price: priceText.text // Convenience alias
  property alias balance: priceText.text // Convenience alias
  property alias discountPrice: discountPriceText.text
  property string discountIconId: ""
  property alias iconSource: currencyIconImage.source
  property string tooltipText: ""
  property bool hasDiscount: discountPrice.length > 0 && price != discountPrice
  property bool tooLowBalance: false
  property string styleType: ""

  property string iconId: ""

  property string __iconIdSource: ""
  property string __iconIdTooltip: ""
  property string __discountIconIdSource: ""
  property string __discountIconIdTooltip: ""


  function __getCurrencyDetailForId(id) {
    const CURRENCY_DETAILS = {
      "GoldCoin": {
        "icon": "/images/icon-goldcoin.png",
        "tooltip": qsTrId("currency_view_gold_tooltip")
      },
      "TibiaCoin": {
        "icon": "/images/icon-tibiacoin.png",
        "tooltip": qsTrId("currency_view_tibiacoins_tooltip")
      },
      "TibiaCoinTransferable": {
        "icon": "/images/icon-tibiacointransferable.png",
        "tooltip": qsTrId("currency_view_tibiacoins_transferable_tooltip")
      },
      "PreyWildcards": {
        "icon": "/images/prey-wildcards-icon.png",
        "tooltip": qsTrId("currency_view_preywildcard_tooltip")
      },
      "InstantRewardAccess": {
        "icon": "/images/instant-reward-access-icon.png",
        "tooltip": qsTrId("currency_view_instant_reward_access_tooltip")
      },
      "DailyRewardJoker": {
        "icon": "/images/icon-daily-reward-joker.png",
        "tooltip": qsTrId("currency_view_daily_reward_joker_tooltip")
      },
      "MonsterBonusPoints": {
        "icon": "/images/charm-points.png",
        "tooltip": qsTrId("currency_view_monster_bonus_points_tooltip")
      },
      "MinorCharmEchoes": {
        "icon": "/images/minor-charm-echoes.png",
        "tooltip": qsTrId("currency_view_minor_charm_echoes_tooltip")
      },
      "BankGoldCoin": {
        "icon": "/images/icon-bankaccount.png",
        "tooltip": qsTrId("currency_view_bank_account_tooltip")
      },
      "GuildBankGoldCoin": {
        "icon": "/images/icon-guildaccount.png",
        "tooltip": qsTrId("currency_view_guild_account_tooltip")
      },
      "PreyHuntingTaskTokens": {
        "icon": "/images/preyhuntingtask-tokens.png",
        "tooltip": qsTrId("currency_view_prey_hunting_task_tokens_tooltip")
      },
      "Dust": {
        "icon": "/images/icon-currency-dust.png",
        "tooltip": qsTrId("currency_view_dust_tooltip")
      },
      "Slivers": {
        "icon": "/images/icon-currency-sliver.png",
        "tooltip": qsTrId("currency_view_slivers_tooltip")
      },
      "ExaltedCore": {
        "icon": "/images/icon-currency-exaltedcore.png",
        "tooltip": qsTrId("currency_view_exalted_core_tooltip")
      },
      "LesserFragments": {
        "icon": "/images/skillwheel/icon-fragments-lesser.png",
        "tooltip": qsTrId("currency_view_lesser_fragments_tooltip")
      },
      "GreaterFragments": {
        "icon": "/images/skillwheel/icon-fragments-greater.png",
        "tooltip": qsTrId("currency_view_greater_fragments_tooltip")
      },
      "BountyPoints": {
        "icon": "/images/taskboard/icon-currency-bountypoints.png",
        "tooltip": qsTrId("currency_view_bountypoints_tooltip")
      },
      "TaskReroll": {
        "icon": "/images/taskboard/icon-currency-taskreroll.png",
        "tooltip": qsTrId("currency_view_taskreroll_tooltip")
      },
      "SoulSeals": {
        "icon": "/images/taskboard/icon-currency-soulseals.png",
        "tooltip": qsTrId("currency_view_soulseals_tooltip")
      },
      "LunarAscensionOrbs": {
        "icon": "/images/icon_lunar_ascension_orb_currency.png",
        "tooltip": qsTrId("currency_view_lunar_ascension_orb_tooltip")
      },
    };

    if (id in CURRENCY_DETAILS) {
      return CURRENCY_DETAILS[id];
    } else {
      return {
        "icon": "",
        "tooltip": ""
      }
    }
  } //function __getCurrencyDetailForId(id)

  function getIconSourceForId(id) {
    return __getCurrencyDetailForId(id).icon;
  } //function getIconSourceForId(id)

  function getIconTooltipForId(id) {
    return __getCurrencyDetailForId(id).tooltip;
  } //function getIconTooltipForId(id)

  onIconIdChanged: {
    __iconIdSource = getIconSourceForId(iconId);
    __iconIdTooltip = getIconTooltipForId(iconId);
  } //onIconIdChanged

  onDiscountIconIdChanged: {
    if (discountIconId != "") {
      __discountIconIdSource = getIconSourceForId(discountIconId);
      __discountIconIdTooltip = getIconTooltipForId(discountIconId);
    } else {
      __discountIconIdSource = "";
      __discountIconIdTooltip = "";
    }
  } //onDiscountIconIdChanged

  RowLayout {
    id: outerWrapper
    anchors.fill: parent
    anchors.leftMargin: TibiaStyle.marginNarrow + frame.borderWidth
    anchors.rightMargin: TibiaStyle.marginNarrow + frame.borderWidth
    anchors.verticalCenter: parent.verticalCenter
    spacing: 0

    RowLayout {
      spacing: 0
      Layout.alignment: rightAligned ? Qt.AlignRight : Qt.AlignHCenter

      TibiaText {
        id: priceText

        Timer {
          id: delayedLayoutTimer
          running: false
          repeat: false
          interval: 0
          onTriggered: {
            if (parent.Layout.maximumWidth != priceText.newMaximumWidth) {
              parent.Layout.maximumWidth = priceText.newMaximumWidth;
            }
            if (parent.Layout.leftMargin != priceText.newLeftMargin) {
              parent.Layout.leftMargin = priceText.newLeftMargin;
            }
          }
        }

        property int newMaximumWidth: parseInt(Math.max(outerWrapper.width - remainderWrapper.width, 0))
        property int newLeftMargin: -1 * (width - contentWidth)
        Component.onCompleted: {
          delayedLayoutTimer.start();
        }
        onNewMaximumWidthChanged: {
          delayedLayoutTimer.start();
        }

        Layout.alignment: Qt.AlignRight
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignRight
        font: hasDiscount ? TibiaStyle.defaultTextFontStrikeout : TibiaStyle.defaultTextFont
        styleType: hasDiscount ? "Disabled" : (tooLowBalance ? "CurrencyLowBalance" : (currencyView.styleType != "" ?  currencyView.styleType : "Dialog"))
        Tooltip {
          text: tooltipText
          anchors.fill: parent
          enabled: text.length > 0
        } //Tooltip
      } //TibiaText

      RowLayout {
        id: remainderWrapper
        readonly property bool childVisible: originalCurrencyIconImage.visible
                                          || discountPriceText.visible
                                          || currencyIconImage.visible
        Layout.maximumWidth: childVisible ? -1 : 0
        spacing: 0

        Image {
          id: originalCurrencyIconImage
          smooth: false
          visible: source != ""
          opacity: 0.3
          source: discountIconId != "" ? __iconIdSource : ""
          Tooltip {
            anchors.fill: parent
            text: visible ? __iconIdTooltip : ""
            enabled: text.length > 0
          } //Tooltip
        } //Image

        TibiaText {
          id: discountPriceText
          Layout.leftMargin: TibiaStyle.marginRelated
          visible: hasDiscount
          elide: Text.ElideRight
          horizontalAlignment: Text.AlignRight
          styleType: tooLowBalance ? "CurrencyLowBalance" : (currencyView.styleType != "" ?  currencyView.styleType : "Dialog")
          Tooltip {
            text: tooltipText
            anchors.fill: parent
            enabled: text.length > 0
          } //Tooltip
        } //TibiaText

        Image {
          id: currencyIconImage
          smooth: false
          property string iconSource: discountIconId != "" ? __discountIconIdSource : __iconIdSource
          property string iconTooltip: discountIconId != "" ? __discountIconIdTooltip : __iconIdTooltip

          visible: source != ""
          source: iconId.length > 0 ? iconSource : ""
          Tooltip {
            anchors.fill: parent
            text: visible ? currencyIconImage.iconTooltip : ""
            enabled: text.length > 0
          } //Tooltip
        } //Image
      } //RowLayout
    } //RowLayout
  } //RowLayout

  TibiaFrame1PixelDown {
    id: frame
    anchors.fill: parent
    z: -1
    BorderImage {
      smooth: false
      anchors.fill: parent
      anchors.margins: 1
      source: "/images/backdrop-dark-grey.png"
      horizontalTileMode: BorderImage.Repeat
      verticalTileMode: BorderImage.Repeat
      visible: true
      // cache is set to false because of a strange error (TIBIA-17267)
      // when used in a grid view delegate and scrolling down sometimes the backgroung graphics seem to
      // be drawn over the currencyIconImage. setting cache to false prevents this
      cache: false
    } //Image
  } //TibiaFrame1PixelDown
} //Item
