import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qmlcomponents
import QtQuick.LegacyControls


TibiaDialog {
  id: dialogRoot
  caption: qsTrId("rewardwall_caption")
  width: 506 + 2 * TibiaStyle.dialogMarginBorder

  property var controller: null

  property bool isPremium: controller != null && controller.isPremium

  onReturnPressedFunction: function() {}
  onCancelPressedFunction: closeDialog

  function closeDialog() {
    if (controller != null) {
      controller.closeButtonClicked();
    }
  } //function closeDialog

  initialFocusItem: dialogRoot
  KeyNavigation.tab: dialogRoot
  KeyNavigation.backtab: dialogRoot

  ColumnLayout {
    anchors { left: parent.left; top: parent.top; right: parent.right }
    spacing: TibiaStyle.marginRelated

    ColumnLayout {
      id: contentLayout
      Layout.fillWidth: true
      spacing: TibiaStyle.marginUnrelated

      TibiaFrame2PixelUpFilledWithCaption {
        id: restingAreaBonusesFrame
        caption: qsTrId("rewardwall_resting_area_bonuses_header")
        Layout.fillWidth: true
        Layout.preferredHeight: restingBonusLayout.height + marginsToContent + topMarginToContent

        ColumnLayout {
          id: restingBonusLayout
          anchors.top: parent.top
          anchors.left: parent.left
          anchors.leftMargin: parent.marginsToContent
          anchors.topMargin: parent.topMarginToContent

          spacing: TibiaStyle.marginRelated

          RowLayout {
            Layout.fillWidth: true
            spacing: TibiaStyle.marginRelated

            Item {
              Layout.preferredWidth: TibiaStyle.rewardWallItemSize
              Layout.preferredHeight: TibiaStyle.rewardWallItemSize

              Image {
                source: {
                  if (controller != null) {
                    if (controller.rewardStreakLength >= 100) {
                      return "/images/dailyreward/icon-rewardstreak-gold.png"
                    } else if (controller.rewardStreakLength >= 50) {
                      return "/images/dailyreward/icon-rewardstreak-silver.png"
                    } else if (controller.rewardStreakLength >= 25) {
                      return "/images/dailyreward/icon-rewardstreak-bronze.png"
                    }
                  }

                  return "/images/dailyreward/icon-rewardstreak-default.png"
                } //source

                TibiaText {
                  x: 16
                  y: 15
                  width:34
                  height: 9
                  verticalAlignment: Text.AlignVCenter
                  horizontalAlignment: Text.AlignHCenter
                  text: controller != null ? controller.rewardStreakLength : "-"
                } //TibiaText

                MouseArea {
                  id: rewardStreakLengthHoverArea
                  anchors.fill: parent
                  z: -1
                  hoverEnabled: dialogRoot.visible
                } //MouseArea
              } //Image

              TibiaProgressBar {
                id: timeLeftKeepRewardStreak
                anchors { left: parent.left; bottom: parent.bottom; right: parent.right }
                height: TibiaStyle.progressBarLargeHeight

                property bool isRunning: controller != null && controller.dailyRewardStreakState == TibiaEnums.Running
                fillPercentage: controller != null ? controller.rewardStreakTimeLeftProgress
                                                   : 0.0

                frameSource: "/images/1pixel-down-frame.png"
                backgroundSource: "/images/backdrop-dark-grey.png"
                fillSource: isRunning ? "/images/progressbar-orange-large.png"
                                      : "/images/progressbar-grey-large.png"

                frameBorder { left: 1; right: 1; top:1; bottom: 1}
                fillOffset { left: 1; right: 1; top:1; bottom: 1}

                TibiaText {
                  anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
                  horizontalAlignment: Text.AlignHCenter
                  styleType: "White"

                  text: controller != null ? controller.rewardStreakTimeLeft : "00:00"
                  visible: text != ""
                } //TibiaText

                Image {
                  anchors.centerIn:parent
                  source: {
                    if (controller != null) {
                      if (   controller.dailyRewardStreakState == TibiaEnums.AlreadyCollected
                          || controller.dailyRewardStreakState == TibiaEnums.NeverCollected) {
                        return "/images/dailyreward/icon-checkmark.png"
                      } else if (controller.dailyRewardStreakState == TibiaEnums.Frozen) {
                        return "/images/icon-lock-red.png"
                      }
                    }
                    return ""
                  }

                  visible: source != ""
                } //Image

                MouseArea {
                  id: rewardStreakExpiringHoverArea
                  anchors.fill: parent
                  z: -1
                  hoverEnabled: dialogRoot.visible
                } //MouseArea
              } //TibiaProgressBar
            } //Item

            Repeater {
              id: restingAreaBonusesRepeater
              model: controller != null ? controller.restingAreaBonuses : null
              property int hoveredBonusIndex: -1
              property QtObject currentHoverMouseArea

              TibiaFrame1PixelDown {
                Layout.preferredWidth: TibiaStyle.rewardWallItemSize
                Layout.preferredHeight: TibiaStyle.rewardWallItemSize

                BorderImage {
                  anchors.fill: parent
                  anchors.margins: parent.borderWidth
                  source: "/images/backdrop-dark-grey.png"
                  horizontalTileMode: BorderImage.Repeat
                  verticalTileMode: BorderImage.Repeat

                  Image {
                    anchors.centerIn: parent
                    source: "image://resting-area-bonuses-levels/" + index
                  } //Image

                  TibiaDisabledOverlay {
                    anchors.fill: parent
                    visible: modelData.isLockedByPremium || modelData.isLockedByRewardStreakLength
                  } //TibiaDisabledOverlay

                  Image {
                    anchors { top: parent.top; left: parent.left }

                    source: "/images/premium/icon-banner-premium.png"
                    visible: modelData.isLockedByPremium
                  } //Image

                  Image {
                    anchors { bottom: parent.bottom; right: parent.right }

                    source: "/images/dailyreward/icon-banner-days.png"
                    visible: modelData.isLockedByRewardStreakLength

                    TibiaText {
                      x: 20
                      y: 14

                      styleType: "White"
                      text: modelData.neededRewardStreakLength
                    } //TibiaText
                  } //Image
                } //Image

                MouseArea {
                  id: restingAreaBonusHoverArea
                  anchors.fill: parent
                  z: -1
                  hoverEnabled: dialogRoot.visible
                  onEntered: {
                    restingAreaBonusesRepeater.currentHoverMouseArea = this;
                    restingAreaBonusesRepeater.hoveredBonusIndex = index;
                  }
                  onExited: {
                    if (restingAreaBonusesRepeater.currentHoverMouseArea === this) {
                      restingAreaBonusesRepeater.hoveredBonusIndex = -1;
                    }
                  }
                } //MouseArea
              } //TibiaFrame1PixelDown
            } //Repeater
          } //RowLayout


          RowLayout {
            Layout.fillWidth: true
            spacing: TibiaStyle.marginRelated

            TibiaCurrencyView {
              Layout.preferredWidth: timeLeftKeepRewardStreak.width
              Layout.alignment: Qt.AlignTop

              iconId: "DailyRewardJoker"
              price: controller != null ? controller.jokersNeededForCollecting <= controller.maxDailyRewardJokerAmount ? controller.jokersNeededForCollecting
                                                                                                                       : ">%1".arg(controller.maxDailyRewardJokerAmount)
                                        : "-"
              tooLowBalance: controller != null && controller.dailyRewardJokerAmount < controller.jokersNeededForCollecting

              MouseArea {
                id: jokersNeededCurrencyViewTextHoverArea
                anchors.fill: parent
                z: -1
                hoverEnabled: dialogRoot.visible
              } //MouseArea
            } //TibiaCurrencyView


            TibiaText {
              Layout.fillWidth: true
              horizontalAlignment: Text.AlignHCenter

              text: {
                var infoText = "";

                if (controller != null) {
                  var streakState = controller.dailyRewardStreakState;

                  if (streakState == TibiaEnums.AlreadyCollected) {
                    infoText = qsTrId("rewardwall_reward_streak_already_collected") + "<br>";
                  } else if (streakState == TibiaEnums.Expired) {
                    infoText = qsTrId("rewardwall_reward_streak_expired").arg(qsTrId("currency_view_daily_reward_joker_tooltip"))
                  } else if (streakState == TibiaEnums.Running) {
                    if (controller.jokersNeededForCollecting > 0) {
                      infoText = qsTrId("rewardwall_reward_streak_running_was_protected");
                    } else {
                      infoText = qsTrId("rewardwall_reward_streak_running");
                    }
                    if (controller.jokersNeededForCollecting < controller.dailyRewardJokerAmount) {
                      infoText = infoText + "<br>" + qsTrId("rewardwall_reward_streak_protected").arg(TibiaStyle.green1);
                    } else {
                      infoText = infoText + "<br>" + qsTrId("rewardwall_reward_streak_not_protected").arg(TibiaStyle.red2);
                    }
                  } else if (streakState == TibiaEnums.Frozen) {
                    infoText = qsTrId("rewardwall_reward_streak_already_frozen");
                  } else if (streakState == TibiaEnums.NeverCollected) {
                    infoText = qsTrId("rewardwall_reward_streak_never_collected");
                  }
                }
                return infoText;
              }

              MouseArea {
                id: rewardStreakStateTextHoverArea
                anchors.fill: parent
                z: -1
                hoverEnabled: dialogRoot.visible
              } //MouseArea
            } //TibiaText
          } //RowLayout
        } //ColumnLayout
      } //TibiaFrame2PixelUpFilledWithCaption

      TibiaFrame2PixelUpFilledWithCaption {
        id: dailyRewards
        caption: qsTrId("rewardwall_daily_rewards_header")
        Layout.fillWidth: true
        Layout.preferredHeight: dailyRewardLayout.height + marginsToContent + topMarginToContent

        ColumnLayout {
          id: dailyRewardLayout
          anchors.top: parent.top
          anchors.left: parent.left
          anchors.leftMargin: parent.marginsToContent
          anchors.topMargin: parent.topMarginToContent
          spacing: 0

          RowLayout {
            spacing: 0

            Repeater {
              id: dailyRewardRepeater
              model: controller != null ? controller.dailyRewards : null

              property int hoveredRewardIndex: -1
              property int hoveredRewardStateIndex: -1
              property QtObject currentHoverRewardIndexMouseArea
              property QtObject currentHoverRewardStateIndexMouseArea

              Item {
                property bool isLastElement: index == (dailyRewardRepeater.count - 1)
                property bool isCurrentReward: controller != null && (index == controller.nextDailyRewardPosition)
                property bool isCollected: controller != null && (index < controller.nextDailyRewardPosition)
                property bool readyToPickedUp: isCurrentReward && (controller != null) && !controller.isDailyRewardLocked

                Layout.preferredWidth: TibiaStyle.rewardWallItemSize + (isLastElement ? 0 : TibiaStyle.marginRelated)
                Layout.preferredHeight: TibiaStyle.rewardWallItemSize + TibiaStyle.marginRelated + TibiaStyle.progressBarLargeHeight

                Item {
                  id: rewardFrame
                  width: TibiaStyle.rewardWallItemSize
                  height: TibiaStyle.rewardWallItemSize

                  TibiaFrame1PixelDown {
                    anchors.fill: parent
                    visible: !readyToPickedUp

                    BorderImage {
                      anchors.fill: parent
                      anchors.margins: parent.borderWidth
                      source: "/images/backdrop-dark-grey.png"
                      horizontalTileMode: BorderImage.Repeat
                      verticalTileMode: BorderImage.Repeat
                    } //Image

                    Image {
                      id: rewardIcon
                      anchors.centerIn: parent
                      source: {
                        if (modelData.containsXPBoost) {
                          return "/images/dailyreward/icon-reward-xpboost.png";
                        } else if (modelData.isFixedItemsReward) {
                          return "/images/dailyreward/icon-reward-fixeditems.png";
                        } else if (modelData.isPickItemsReward) {
                          return "/images/dailyreward/icon-reward-pickitems.png";
                        }
                        return "";
                      } //source
                    } //Image
                  } //TibiaFrame1PixelDown

                  TibiaButton {
                    anchors.fill: parent
                    visible: readyToPickedUp
                    imageSource: rewardIcon.source
                    onClicked: controller != null ? controller.collectRewardButtonClicked() : undefined
                  } //TibiaButton

                  TibiaDisabledOverlay {
                    anchors.fill: parent
                    anchors.margins: 1
                    visible: !isCurrentReward
                  } //TibiaDisabledOverlay

                  MouseArea {
                    id: dailyRewardHoverArea
                    anchors.fill: parent
                    hoverEnabled: dialogRoot.visible
                    onEntered: {
                      dailyRewardRepeater.currentHoverRewardIndexMouseArea = this;
                      dailyRewardRepeater.hoveredRewardIndex = index;
                    }
                    onExited: {
                      if (dailyRewardRepeater.currentHoverRewardIndexMouseArea === this) {
                        dailyRewardRepeater.hoveredRewardIndex = -1;
                      }
                    }

                    propagateComposedEvents: true
                    onClicked: (mouse) => mouse.accepted = false;
                    onPressed: (mouse) => mouse.accepted = false;
                    onReleased: (mouse) => mouse.accepted = false;
                  } //MouseArea
                } //Item

                Image {
                  anchors.left: rewardFrame.right
                  anchors.verticalCenter: rewardFrame.verticalCenter
                  source: isCollected ? "/images/dailyreward/icon-rewardarrow-active.png"
                                      : "/images/dailyreward/icon-rewardarrow-inactive.png"
                  visible: !isLastElement
                } //Image

                Item {
                  anchors.left: parent.left
                  anchors.top: rewardFrame.bottom
                  anchors.topMargin: TibiaStyle.marginRelated
                  width: rewardFrame.width
                  height: TibiaStyle.progressBarLargeHeight

                  TibiaFrame1PixelDown {
                    anchors.fill: parent
                    visible: isCollected

                    BorderImage {
                      anchors.fill: parent
                      anchors.margins: parent.borderWidth
                      source: "/images/backdrop-dark-grey.png"
                      horizontalTileMode: BorderImage.Repeat
                      verticalTileMode: BorderImage.Repeat
                    } //Image

                    Image {
                      anchors.centerIn: parent
                      source: "/images/dailyreward/icon-checkmark.png"
                    } //Image
                  } //TibiaFrame1PixelDown

                  TibiaProgressBar {
                    id: timeUntillPickUp
                    anchors.fill: parent
                    visible: !isCollected && !readyToPickedUp

                    property bool isRunning: controller != null && controller.isDailyRewardLocked && isCurrentReward
                    fillPercentage: controller != null ? (isRunning ? controller.dailyRewardTimeToUnlockProgress
                                                                    : 1.0)
                                                       : 0.0

                    frameSource: "/images/1pixel-down-frame.png"
                    backgroundSource: "/images/backdrop-dark-grey.png"
                    fillSource: isRunning ? "/images/progressbar-orange-large.png"
                                          : "/images/progressbar-grey-large.png"

                    frameBorder { left: 1; right: 1; top:1; bottom: 1}
                    fillOffset { left: 1; right: 1; top:1; bottom: 1}

                    TibiaText {
                      anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
                      horizontalAlignment: Text.AlignHCenter
                      styleType: "White"

                      text: controller != null ? controller.dailyRewardTimeToUnlock : "00:00"
                      visible: parent.isRunning
                    } //TibiaText

                    Image {
                      anchors.centerIn:parent
                      source: "/images/icon-lock-red.png"

                      visible: !parent.isRunning
                    } //Image

                  } //TibiaProgressBar

                  TibiaCurrencyView {
                    anchors.fill: parent
                    iconId: "InstantRewardAccess"
                    visible: readyToPickedUp
                    price: "1"
                    discountPrice: controller != null && controller.isUsingRewardShrine ? "0" : ""
                    tooLowBalance: controller != null ? (controller.instantRewardAccessAmount < 1 && !controller.isUsingRewardShrine) : false
                  } //TibiaCurrencyView

                  MouseArea {
                    id: dailyRewardStateHoverArea
                    anchors.fill: parent
                    hoverEnabled: dialogRoot.visible
                    onEntered: {
                      dailyRewardRepeater.currentHoverRewardStateIndexMouseArea = this;
                      dailyRewardRepeater.hoveredRewardStateIndex = index;
                    }
                    onExited: {
                      if (dailyRewardRepeater.currentHoverRewardStateIndexMouseArea === this) {
                        dailyRewardRepeater.hoveredRewardStateIndex = -1;
                      }
                    }
                  } //MouseArea
                } //Item

              } //Item
            } //Repeater
          } //RowLayout

          Image {
            Layout.alignment: Qt.AlignHCenter
            source: controller != null
                 && controller.rewardStreakLength != 0 //very first reward
                 && controller.nextDailyRewardPosition == 0 ? "/images/dailyreward/icon-rewardarrow-loop-active.png"
                                                            : "/images/dailyreward/icon-rewardarrow-loop-inactive.png"
          } //Image
        } //ColumnLayout
      } //TibiaFrame2PixelUpFilledWithCaption

      TibiaFrame2PixelUpFilled {
        Layout.fillWidth: true
        Layout.preferredHeight: premiumStateLayout.height + 2 * (TibiaStyle.marginRelated + borderWidth)

        RowLayout {
          id: premiumStateLayout
          anchors { left: parent.left; top: parent.top; right: parent.right }
          anchors.margins: TibiaStyle.marginRelated + parent.borderWidth
          spacing: TibiaStyle.marginRelated

          TibiaText {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter

            text: dialogRoot.isPremium ? qsTrId("rewardwall_premium_rewards_active")
                                             : qsTrId("rewardwall_get_better_rewards_with_premium")
          } //TibiaText

          TibiaPremiumStateButton {
            hasPremium: dialogRoot.isPremium
            onClicked: controller ? controller.getPremiumClicked() : undefined
          } //TibiaPremiumStateButton
        } //RowLayout
      } //TibiaFrame2PixelUpFilled

      TibiaFrame2PixelUpFilled {
        Layout.fillWidth: true
        Layout.preferredHeight: 105

        ColumnLayout {
          anchors { left: parent.left; top: parent.top; right: parent.right }
          anchors.margins: TibiaStyle.marginRelated + parent.borderWidth

          TibiaText {
            Layout.fillWidth: true
            visible: rewardStreakLengthHoverArea.enabled && rewardStreakLengthHoverArea.containsMouse

            wrapMode: Text.Wrap
            textFormat: Text.RichText
            onVisibleChanged: { text = controller != null ? controller.rewardStreakLengthHoverText() : qsTrId("dummy_unknown"); }
          } //TibiaText


          TibiaText {
            Layout.fillWidth: true
            visible: jokersNeededCurrencyViewTextHoverArea.enabled && jokersNeededCurrencyViewTextHoverArea.containsMouse
                  || jokersAmountCurrencyViewTextHoverArea.enabled && jokersAmountCurrencyViewTextHoverArea.containsMouse

            wrapMode: Text.Wrap
            textFormat: Text.RichText
            onVisibleChanged: { text = controller != null ? controller.jokersNeededCurrencyViewhHoverText() : qsTrId("dummy_unknown"); }
          } //TibiaText

          TibiaText {
            Layout.fillWidth: true
            visible: rewardStreakExpiringHoverArea.enabled  && rewardStreakExpiringHoverArea.containsMouse
                  || rewardStreakStateTextHoverArea.enabled && rewardStreakStateTextHoverArea.containsMouse

            wrapMode: Text.Wrap
            textFormat: Text.RichText
            onVisibleChanged: { text = controller != null ? controller.rewardStreakStateHoverText() : qsTrId("dummy_unknown"); }
          } //TibiaText

          TibiaText {
            Layout.fillWidth: true
            visible: restingAreaBonusesRepeater.hoveredBonusIndex != -1

            wrapMode: Text.Wrap
            textFormat: Text.RichText
            text: controller != null ? controller.restingBonusHoverText(restingAreaBonusesRepeater.hoveredBonusIndex) : qsTrId("dummy_unknown")
          } //TibiaText

          TibiaText {
            Layout.fillWidth: true
            visible: dailyRewardRepeater.hoveredRewardIndex != -1

            wrapMode: Text.Wrap
            textFormat: Text.RichText
            onVisibleChanged: { text = controller != null ? controller.dailyRewardHoverText(dailyRewardRepeater.hoveredRewardIndex) : qsTrId("dummy_unknown"); }
          } //TibiaText

          TibiaText {
            Layout.fillWidth: true
            visible: dailyRewardRepeater.hoveredRewardStateIndex != -1

            wrapMode: Text.Wrap
            textFormat: Text.RichText
            onVisibleChanged: { text = controller != null ? controller.dailyRewardStateHoverText(dailyRewardRepeater.hoveredRewardStateIndex) : qsTrId("dummy_unknown"); }
          } //TibiaText

        } //ColumnLayout
      } //TibiaFrame2PixelUpFilled
    } //ColumnLayout

    TibiaFrame2PixelUpFilledWithCaption {
      id: historyFrame
      caption: qsTrId("history")
      Layout.fillWidth: true
      Layout.preferredHeight: contentLayout.height
      visible: false

      TibiaTableView {
        id: historyTableView
        anchors { left: parent.left; leftMargin: TibiaStyle.marginRelated;
                  right: parent.right; rightMargin: TibiaStyle.marginRelated;
                  top: parent.top; topMargin: historyFrame.captionHeight + TibiaStyle.marginRelated;
                  bottom: parent.bottom; bottomMargin: TibiaStyle.marginRelated }

        model: controller != null ? controller.history : null
        headerVisible: true
        verticalScrollBarPolicy: ScrollBar.AlwaysOn
        horizontalScrollBarPolicy: ScrollBar.AsNeeded

        rowDelegate: Rectangle {
          height: TibiaStyle.tableViewRowHeight2Lines
          color: styleData.row == undefined ? TibiaStyle.tableViewBackgroundColor
                                            : styleData.selected ? TibiaStyle.tableViewSelectionColor
                                                                 : styleData.alternate ? TibiaStyle.tableViewAlternateBackgroundColor
                                                                                       : TibiaStyle.tableViewItemBackgroundColor
        } // rowDelegate

        TableViewColumn {
          id: timestampColumn
          role: "timestamp"
          title: qsTrId("date_column_header")
          movable: false
          resizable: false
          width: 150
        } //TableViewColumn

        TableViewColumn {
          id: rewardStreakColumn
          role: "newRewardStreakLength"
          title: qsTrId("rewardwall_history_reward_streak_header")
          movable: false
          resizable: false
          width: 50

          delegate: Item {
            anchors.fill: parent

            TibiaText {
              text: styleData.value
              color: modelData != null && modelData.changedBySupport
                ? TibiaStyle.green1
                : styleData.selected
                  ? TibiaStyle.textFieldSelectionTextColor
                  : TibiaStyle.textFieldTextColor
              anchors.fill: parent
              anchors.leftMargin: TibiaStyle.marginNarrow
              anchors.rightMargin: TibiaStyle.marginRelated
              anchors.verticalCenter: parent.verticalCenter
              elide: styleData.elideMode
              horizontalAlignment: Text.AlignRight

              Tooltip {
                anchors.fill: parent
                text: qsTrId("rewardwall_history_changed_by_support_tooltip")
                enabled: modelData != null && modelData.changedBySupport
              } //Tooltip
            } //TibiaText

            TibiaVerticalSeparator {
              anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
            } // TibiaVerticalSeparator
          } //delegate: Item
        } //TableViewColumn

        TableViewColumn {
          role: "description"
          title: qsTrId("rewardwall_history_event_header")
          movable: false
          resizable: false
          width: historyTableView.width - timestampColumn.width - rewardStreakColumn.width - TibiaStyle.scrollBarWidth -2

          delegate: TibiaText {
            anchors.fill:parent
            anchors.leftMargin: TibiaStyle.marginNarrow
            anchors.rightMargin: TibiaStyle.marginRelated

            text: styleData.value
            color: modelData != null && modelData.changedBySupport
              ? TibiaStyle.green1
              : styleData.selected
                ? TibiaStyle.textFieldSelectionTextColor
                : TibiaStyle.textFieldTextColor

            elide: styleData.elideMode
            wrapMode: Text.Wrap
            tooltipMaxWidth: TibiaStyle.tooltipRestrictedWidth
          } //delegate: TibiaText
        } //TableViewColumn
      } //TibiaTableView
    } //TibiaFrame2PixelUpFilledWithCaption

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } //TibiaHorizontalSeparator

    RowLayout {
      Layout.alignment: Qt.AlignRight
      spacing: TibiaStyle.marginRelated

      TibiaCurrencyView {
        Layout.preferredWidth: TibiaStyle.currencyViewWidthNarrow
        rightAligned: true
        balance: controller != null ? controller.dailyRewardJokerAmount : "-"
        iconId: "DailyRewardJoker"

        MouseArea {
          id: jokersAmountCurrencyViewTextHoverArea
          anchors.fill: parent
          z: -1
          hoverEnabled: dialogRoot.visible
        } //MouseArea
      } //TibiaCurrencyView

      RowLayout {
        spacing: TibiaStyle.marginNarrow

        TibiaCurrencyView {
          Layout.preferredWidth: TibiaStyle.currencyViewWidthShort
          rightAligned: true
          balance: controller != null ? controller.instantRewardAccessAmount : "-"
          iconId: "InstantRewardAccess"
        } //TibiaCurrencyView

        TibiaButton {
          Layout.preferredHeight: closeButton.height
          Layout.preferredWidth: TibiaStyle.buttonWidthStoreSmall
          color: "blue"
          imageSource: "/images/icon-store-16x10.png"
          tooltipText: qsTrId("rewardwall_get_more_instant_reward_access_tooltip")

          onClicked: controller ? controller.getMoreInstantRewardAccessClicked () : undefined
        } //TibiaIconButton
      } //RowLayout

      Item {Layout.fillWidth: true}

      TibiaButton {
        text: historyFrame.visible ? qsTrId("back") : qsTrId("history")

        onClicked: {
          // The order in which elements are made invisible/visible is important:
          // Unless elements are made invisible first, the dialog height temporarily increases,
          // which leads to an undesired repositioning of the dialog in y direction
          if (!historyFrame.visible && controller != null) {
            controller.historyButtonClicked();
            contentLayout.visible = false;
            historyFrame.visible = true;
          } else {
            historyFrame.visible = false;
            contentLayout.visible = true;
          }
        } //onClicked
      } //TibiaButton

      TibiaButton {
        id: closeButton
        text: qsTrId("close")

        onClicked: dialogRoot.closeDialog();
      } // TibiaButton
    } // RowLayout
  } // ColumnLayout

} // TibiaDialog
