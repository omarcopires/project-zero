import QtQuick
import QtQuick.Layouts
import qmlcomponents
import qmlenumvalues


TibiaDialog {
  id: confirmationDialog
  caption: qsTrId("store_purchase_confirmation_caption")
  width: 380

  property var controller: null;
  property var dynamicallyLoadedImageManager: null;
  property var offer: controller != null ? controller.offerToPurchase : null
  property var quantity: {
    if (offer != null) {
      for (var i = 0; i < offer.quantities.length; ++i) {
        if (offer.quantities[i].offerID == controller.offerID) {
          return offer.quantities[i];
        }
      }
    }

    return null;
  }
  property var offerName: {
    if (offer != null && quantity != null) {
      if (offer.quantities.length > 1 || quantity.quantity > 1) {
        return qsTrId("store_offer_name_with_quantity").arg(quantity.quantity).arg(offer.name);
      } else {
        return offer.name;
      }
    } else {
      return qsTrId("dummy_unknown");
    }
  }

  onReturnPressedFunction: function() {
    if (controller != null) {
      controller.purchaseRequested(!dontAskAgainCheckbox.checked);
    }
  }

  onCancelPressedFunction: function() {
    if (controller != null) {
      controller.closeRequested();
    }
  }

  initialFocusItem: confirmationDialog
  KeyNavigation.tab: confirmationDialog

  ColumnLayout {
    spacing: TibiaStyle.marginUnrelated
    anchors { left: parent.left; right: parent.right; top: parent.top }

    TibiaText {
      text: qsTrId("store_purchase_confirmation").arg(offerName)
      Layout.fillWidth: true
      wrapMode: Text.Wrap
    } // TibiaText

    Item {
      Layout.fillWidth: true
      Layout.preferredHeight: 80

      TibiaSunkenRectangle {
        id: offerIcon
        anchors { top: parent.top; left: parent.left; bottom: parent.bottom; }
        width: height

        StoreOfferVisualisation {
          width: 64
          height: width
          anchors.centerIn: parent
          dynamicallyLoadedImageManager: confirmationDialog.dynamicallyLoadedImageManager
          visualisation: offer != null ? offer.visualisation : null
          smoothTextureFiltering: controller != null ? controller.smoothTextureFiltering : false
        }

        StoreHighlightImage {
          anchors { left: parent.left; bottom: parent.bottom }
          highlightState: quantity != null ? quantity.highlightState : TOffer.STATE_NONE

          Tooltip {
            anchors.fill: parent
            text: quantity != null && quantity.isOnSale ? quantity.saleStringShort : ""
            maxWidth: TibiaStyle.storeTooltipWidth
          } //Tooltip
        } // StoreHighlightImage
      } // TibiaSunkenRectangle

      TibiaSunkenRectangle {
        anchors { left: offerIcon.right; leftMargin: TibiaStyle.marginUnrelated;
                  top: parent.top; bottom: parent.bottom; right: parent.right }

        ColumnLayout {
          spacing: TibiaStyle.marginRelated
          anchors { left: parent.left; leftMargin: TibiaStyle.marginUnrelated;
                    right: parent.right; rightMargin: TibiaStyle.marginUnrelated;
                    verticalCenter: parent.verticalCenter; }

          StoreHighlightState {
            highlightState: quantity != null ? quantity.highlightState : TOffer.STATE_NONE;
          } // StoreHighlightState

          TibiaText {
            text: offerName
          } //TibiaText

          Item {
            Layout.preferredWidth: priceLayout.width
            Layout.preferredHeight: priceLayout.height

            RowLayout {
              id: priceLayout
              spacing: TibiaStyle.marginRelated

              TibiaText {
                text: qsTrId("store_offer_price")
              } //TibiaText

              TibiaText {
                text: quantity != null && quantity.isOnSale ? quantity.basePrice : ""
                visible: text != ""
                font: TibiaStyle.defaultTextFontStrikeout
                styleType: "Disabled"
              } //TibiaText

              TibiaText {
                text: quantity != null ?  quantity.priceString : "-"
              } //TibiaText

              Image {
                source: {
                  if (quantity != null) {
                    if (quantity.price == 0) {
                      return "";
                    }
                    if (quantity.currencyType == TOffer.TIBIA_COINS) {
                      return "/images/icon-tibiacoin.png";
                    }
                    if (quantity.currencyType == TOffer.TRUSTED_TIBIA_COINS) {
                      return "/images/icon-tibiacointransferable.png";
                    }
                  }
                  return "";
                } //source
                Tooltip {
                  anchors.fill: parent
                  text: {
                    if (quantity != null) {
                      if (quantity.currencyType == TOffer.TIBIA_COINS) {
                        return qsTrId("currency_view_tibiacoins_tooltip");
                      } else if (quantity.currencyType == TOffer.TRUSTED_TIBIA_COINS) {
                        return qsTrId("currency_view_tibiacoins_transferable_tooltip");
                      }
                    }
                    return "";
                  } //text
                } //Tooltip
              } //Image

              TibiaText {
                text: quantity != null && quantity.isOnSale ? ("(" + quantity.saleStringShort + ")") : ""
                visible: text != ""
                color: TibiaStyle.storeColorSale
              } //TibiaText
            } //RowLayout

            Tooltip {
              anchors.fill: parent
              text: quantity != null && quantity.isOnSale ? quantity.saleStringShort : ""
              maxWidth: TibiaStyle.storeTooltipWidth
              enabled: text != ""
            } //Tooltip
          } //Item
        } // ColumnLayout
      } // TibiaSunkenRectangle
    } // Item

    TibiaMenuOptionCheckBox {
      id: dontAskAgainCheckbox
      Layout.fillWidth: true
      text: qsTrId("confirmation_do_not_show_again")
      visible: controller != null && controller.showAskAgainCheckbox
    }

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    }

    RowLayout {
      Layout.alignment: Qt.AlignRight
      spacing: TibiaStyle.marginRelated

      TibiaButton {
        id: buyButton
        text: qsTrId("buy")
        color: "blue"

        onClicked: onReturnPressedFunction();
      } // TibiaButton

      TibiaButton {
        id: cancelButton
        text: qsTrId("cancel")

        onClicked: onCancelPressedFunction();
      } // TibiaButton
    } // RowLayout
  } // ColumnLayout
} // TibiaDialog
