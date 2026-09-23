import QtQuick
import QtQuick.Layouts
import qmlcomponents



TibiaSidebarWidget {
  id: playerTradeWidget
  caption: qsTrId("player_trade_caption")
  picSource: "/images/skin/classic/icon-trade.png"
  minHeight: 100
  initialHeight: 100

  property int containerSlotOuterSize: 37
  //maxContentHeight is set in tradableGoodsOuterParent.onContentHeightChanged to avoid binding loop
  //maxContentHeight: mainLayout.height - tradableGoodsOuterParent.height + Math.max(containerSlotOuterSize, tradableGoodsOuterParent.contentHeight)

  property bool tradeActive: widgetController != null && widgetController.counterOffer.length > 0

  ColumnLayout {
    id: mainLayout
    anchors.fill: parent
    spacing: 0

    RowLayout {
      Layout.fillWidth: true
      Layout.leftMargin: TibiaStyle.playerTradeBorderMargin
      spacing: verticalSeparator.width + 2*verticalSeparator.anchors.leftMargin

      TibiaText {
        id: ownName
        styleType: "Dialog"
        text: widgetController != null ? widgetController.ownName : ""
        Layout.preferredWidth: ownTradeItemsGrid.width - parent.Layout.leftMargin
        font: TibiaStyle.playerTradeSmallFont
        //horizontalAlignment: Text.AlignHCenter
      } //TibiaText

      TibiaText {
        id: tradePartnerName
        styleType: "Dialog"
        text: widgetController != null ? widgetController.tradePartnerName : ""
        Layout.preferredWidth: tradePartnerItemsGrid.width
        font: TibiaStyle.playerTradeSmallFont
        //horizontalAlignment: Text.AlignHCenter
      } //TibiaText

      Item {
        Layout.fillWidth: true
      } //Item
    } //RowLayout

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    }

    TibiaScrollView {
      Layout.fillWidth: true
      Layout.fillHeight: true

      Flickable {
        id: tradableGoodsOuterParent
        contentHeight: Math.max(ownTradeItemsGrid.height, tradePartnerItemsGrid.height)

        interactive: false //prevent flick behavior on touch screens

        onContentHeightChanged: {
          playerTradeWidget.maxContentHeight = mainLayout.height - tradableGoodsOuterParent.height + Math.max(containerSlotOuterSize, tradableGoodsOuterParent.contentHeight)
        } //onContentHeightChanged

        GridView {
          id: ownTradeItemsGrid
          anchors.left: parent.left
          anchors.top: parent.top
          width: containerSlotOuterSize * 2
          height: Math.ceil(count / 2) * containerSlotOuterSize
          model: widgetController != null ? widgetController.ownOffer : null

          clip: true
          cellWidth: containerSlotOuterSize
          cellHeight: containerSlotOuterSize


          delegate: Item {
            ContainerSlot {
              slotID: modelData.slotID
              objectAppearanceInstanceTypeId: modelData.appearanceID
              objectAppearanceInstanceCumulativeCount: modelData.objectCount
              objectAppearanceInstanceUpgradeTier: modelData.objectUpgradeTier
              objectAppearanceInstanceLiquidType: modelData.liquidType
              objectAppearanceInstanceHookDirection: modelData.hookDirection
              slotText: modelData.objectCount > 1 ? modelData.objectCount : ""
              x: 2
              y: 2

              onClicked: (SlotID, MouseButton, KeyboardModifier) => {
                if (widgetController != null) {
                  if (MouseButton == Qt.LeftButton) {
                    widgetController.lookOwnTradeSide(SlotID);
                  } else if (MouseButton == Qt.RightButton) {
                    widgetController.showContextMenuOwnTradeSide(SlotID);
                  }
                }
              } //onClicked
            } //ContainerSlot
          } //delegate: Item
        } // GridView

        TibiaVerticalSeparator {
          id: verticalSeparator
          anchors.top: parent.top
          anchors.left: ownTradeItemsGrid.right
          anchors.leftMargin: 2
          anchors.bottom: parent.bottom
          width: 2
        } //TibiaVerticalSeparator

        GridView {
          id: tradePartnerItemsGrid
          anchors.left: verticalSeparator.right
          anchors.leftMargin: 2
          anchors.top: parent.top
          width: containerSlotOuterSize * 2
          height: Math.ceil(count / 2.0) * containerSlotOuterSize
          model: widgetController != null ? widgetController.counterOffer : null

          clip: true
          cellWidth: containerSlotOuterSize
          cellHeight: containerSlotOuterSize

          delegate: Item {
            ContainerSlot {
              slotID: modelData.slotID
              objectAppearanceInstanceTypeId: modelData.appearanceID
              objectAppearanceInstanceCumulativeCount: modelData.objectCount
              objectAppearanceInstanceUpgradeTier: modelData.objectUpgradeTier
              objectAppearanceInstanceLiquidType: modelData.liquidType
              objectAppearanceInstanceHookDirection: modelData.hookDirection
              slotText: modelData.objectCount > 1 ? modelData.objectCount : ""
              x: 2
              y: 2

              onClicked: (SlotID, MouseButton, KeyboardModifier) => {
                if (widgetController != null) {
                  if (MouseButton == Qt.LeftButton) {
                    widgetController.lookCounterOfferTradeSide(SlotID);
                  } else if (MouseButton == Qt.RightButton) {
                    widgetController.showContextMenuCounterOfferTradeSide(SlotID);
                  }
                }
              } //onClicked
            } // ContainerSlot
          } // delegate: Item
        } // GridView
      } // Flickable
    } // TibiaScrollView

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } //TibiaHorizontalSeparator

    RowLayout {
      Layout.fillWidth: true
      Layout.margins: TibiaStyle.playerTradeBorderMargin
      spacing: TibiaStyle.marginRelated

      Item {
        Layout.fillWidth: true
        visible: acceptButton.visible
      } //Item

      TibiaButton {
        id: acceptButton
        text: qsTrId("accept")
        tooltipText: qsTrId("player_trade_accept_tooltip")
        visible: tradeActive

        onClicked: {
          if (widgetController != null) {
            widgetController.acceptTrade();
          }

          visible = false;
          statusText.text = qsTrId("player_trade_wait_for_partner");
        } //onClicked
      } //TibiaButton

      TibiaText {
        id: statusText
        styleType: "Dialog"
        font: TibiaStyle.playerTradeSmallFont
        text: qsTrId("player_trade_wait_for_offer")
        Layout.fillWidth: true
        visible: !acceptButton.visible
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
      } //TibiaText

      TibiaButton {
        id: rejectButton
        text: tradeActive ? qsTrId("player_trade_reject") : qsTrId("cancel")
        tooltipText: tradeActive ? qsTrId("player_trade_reject_tooltip") : qsTrId("player_trade_cancel_tooltip")

        onClicked: {
          if (widgetController != null) {
            widgetController.rejectTrade();
          }
        } //onClicked
      } //TibiaButton
    } // RowLayout
  } // ColumnLayout

  Lenshelp {
    anchors.fill: parent
    triggerRect: mapFromItem(widgetRoot, 0, 0, widgetRoot.width, widgetRoot.height)
    caption: qsTrId("player_trade_lenshelp_caption")
    content: qsTrId("player_trade_lenshelp")
   } //Lenshelp
} //TibiaSidebarWidget
