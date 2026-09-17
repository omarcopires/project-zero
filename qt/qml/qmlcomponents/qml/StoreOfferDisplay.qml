import QtQuick
import QtQuick.Layouts
import qmlcomponents
import qmlenumvalues


MouseArea {
  id: offerDisplayRoot

  property var dynamicallyLoadedImageManager: null
  property int currentIndex: -1
  property bool highlightOnHover: false
  property bool smoothTextureFiltering: false

  property var firstHighlightQuantity: {
    // Finds the first non-standard highlight quantity, fall back to the first quantity otherwise
    for (var i = 0; i < modelData.quantities.length; ++i) {
      if (modelData.quantities[i].highlightState != TOffer.STATE_NONE) {
        return modelData.quantities[i];
      }
    }
    return modelData.quantities[0];
  }

  implicitHeight: offerVisualisationBorder.height + TibiaStyle.marginNarrow * 4 + offerView.borderWidth * 2
  implicitWidth: 246
  hoverEnabled: true

  onEntered: {
    if (tibiaMouseCursorController != null) { tibiaMouseCursorController.setPointingHand(true); }
  }

  onExited: {
    if (tibiaMouseCursorController != null) { tibiaMouseCursorController.setPointingHand(false); }
  }

  Rectangle {
    anchors.fill: parent
    anchors.leftMargin: TibiaStyle.marginRelated - TibiaStyle.marginNarrow;
    anchors.rightMargin: TibiaStyle.marginRelated - TibiaStyle.marginNarrow;
    border.width: TibiaStyle.marginNarrow
    border.color: "white"
    color: "transparent"
    visible: (parent.highlightOnHover && parent.containsMouse) ||
             (!parent.highlightOnHover && index == currentIndex)
  } // Rectangle

  TibiaFrame2PixelUpFilled {
    id: offerView
    anchors.fill: parent
    anchors.margins: TibiaStyle.marginNarrow
    anchors.leftMargin: TibiaStyle.marginRelated
    anchors.rightMargin: TibiaStyle.marginRelated
    opacity: modelData != null && !modelData.canBeBought ? 0.5 : 1.0

    TibiaFrame1PixelDown {
      id: offerVisualisationBorder
      anchors { left: parent.left; top: parent.top; }
      anchors.margins: TibiaStyle.marginNarrow + parent.borderWidth
      height: 70 // Slightly larger than needed to allow for two lines of offer name text
      width: 70

      StoreOfferVisualisation {
        width: 64
        height: 64
        anchors.centerIn: parent
        visualisation: modelData != null ? modelData.visualisation : null
        dynamicallyLoadedImageManager: offerDisplayRoot.dynamicallyLoadedImageManager
        smoothTextureFiltering: offerDisplayRoot.smoothTextureFiltering
      } // StoreOfferVisualisation
    } // TibiaFrame1PixelDown

    StoreHighlightImage {
      highlightState: offerDisplayRoot.firstHighlightQuantity != null ? offerDisplayRoot.firstHighlightQuantity.highlightState : TOffer.STATE_NONE
      anchors { left: parent.left; bottom: parent.bottom }

      Tooltip {
        anchors.fill: parent
        text: offerDisplayRoot.firstHighlightQuantity != null && offerDisplayRoot.firstHighlightQuantity.isOnSale ? offerDisplayRoot.firstHighlightQuantity.saleStringShort : ""
        maxWidth: TibiaStyle.storeTooltipWidth
      } //Tooltip
    } //StoreHighlightImage

    TibiaText {
      anchors { left: offerVisualisationBorder.right; leftMargin: TibiaStyle.marginRelated;
                right: parent.right; rightMargin: TibiaStyle.marginNarrow + parent.borderWidth;
                top: parent.top; topMargin: TibiaStyle.marginNarrow + parent.borderWidth }
      text: modelData.name
      wrapMode: Text.Wrap

      styleType: {
        if (offerDisplayRoot.firstHighlightQuantity != null) {
          if (offerDisplayRoot.firstHighlightQuantity.highlightState == TOffer.STATE_NEW) {
            return "StoreColorNew";
          } else if (offerDisplayRoot.firstHighlightQuantity.highlightState == TOffer.STATE_SALE) {
            return "StoreColorSale";
          } else if (offerDisplayRoot.firstHighlightQuantity.highlightState == TOffer.STATE_TIMED) {
            return "StoreColorTimed";
          }
        }
        return "Dialog";
      }

    } // TibiaText

    ColumnLayout {
      anchors { right: parent.right; bottom: parent.bottom; }
      anchors.margins: TibiaStyle.marginNarrow + parent.borderWidth
      spacing: TibiaStyle.marginNarrow

      Repeater {
        id: quantityRepeater
        model: modelData.quantities

        RowLayout {
          id: quantityPriceLayout

          TibiaText {
            text: quantityRepeater.count > 1 || modelData.quantity > 1 ? modelData.quantity + "x" : ""
            Layout.fillWidth: true
            horizontalAlignment: Qt.AlignRight

            styleType: {
              if (modelData.highlightState == TOffer.STATE_NEW) {
                return "StoreColorNew";
              } else if (modelData.highlightState == TOffer.STATE_SALE) {
                return "StoreColorSale";
              } else if (modelData.highlightState == TOffer.STATE_TIMED) {
                return "StoreColorTimed";
              }
              return "Dialog";
            }
          } //TibiaText

          TibiaCurrencyView {
            Layout.preferredWidth: 100
            rightAligned: true
            iconId: {
              if (controller != null) {
                if (modelData.price == 0) {
                  return "";
                }
                if (modelData.currencyType == TOffer.TIBIA_COINS) {
                  return "TibiaCoin";
                }
                if (modelData.currencyType == TOffer.TRUSTED_TIBIA_COINS) {
                  return "TibiaCoinTransferable";
                }
              }
              return "";
            } //iconId
            price: {
              if (modelData.isOnSale) {
                return modelData.basePriceString;
              } else if (modelData.price == 0) {
                return qsTrId("store_offer_price_free");
              } else {
                return modelData.priceString;
              }
            } // price
            discountPrice: modelData.priceString
            tooltipText: modelData.isOnSale ? modelData.saleStringShort : ""
            tooLowBalance: {
              var storeBalance = storeAndResourceBalanceHelper.storeBalance;
              if (modelData.currencyType == TOffer.TIBIA_COINS) {
                return storeBalance.totalBalance < modelData.price;
              } else if (modelData.currencyType == TOffer.TRUSTED_TIBIA_COINS) {
                return storeBalance.confirmedBalance < modelData.price;
              }
              return false;
            } //tooLowBalance
          } //TibiaCurrencyView
        } //RowLayout
      } // Repeater
    } // ColumnLayout

    Rectangle {
      anchors.fill: parent
      color: "black"
      opacity: TibiaStyle.opacityOfCooldownBarIconOverlay
      visible: modelData != null && !modelData.canBeBought
    } //Rectangle
  } // TibiaFrame2PixelUpFilled
} // delegate: MouseArea
