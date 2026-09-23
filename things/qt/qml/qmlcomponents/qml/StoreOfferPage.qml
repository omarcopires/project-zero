import QtQuick
import QtQuick.Layouts

import qmlcomponents
import qmlenumvalues

Item {
  id: root
  property var controller: null
  property var initialFocusItem: offerList
  property var parentFocusItem: null
  property var currentOffer: controller != null && controller.selectedOfferIndex > -1
                            ? controller.availableOffers[controller.selectedOfferIndex] : null


  TibiaFrame1PixelDown {
    id: topBox
    readonly property int margin: borderWidth + TibiaStyle.marginNarrow
    width: parent.width
    height: sortFilterBoxes.height + margin * 2

    BorderImage {
      source: "/images/background-dark.png"
      anchors.fill: parent
      anchors.margins: parent.borderWidth
      horizontalTileMode: BorderImage.Repeat
      verticalTileMode: BorderImage.Repeat
    }

    RowLayout {
      id: sortFilterBoxes
      anchors { left: parent.left; top: parent.top; right: parent.right }
      anchors.margins: parent.margin
      spacing: TibiaStyle.marginUnrelated

      TibiaComboBox {
        id: filterBox
        property int modelIndex: controller != null ? controller.selectedFilterTagIndex : -1;
        property bool __updateFromController: false;
        model: controller != null ? controller.filterTagsModel : null
        Layout.preferredWidth: 257 // Just as wide as the ListView below it
        enabled: count > 1

        onModelIndexChanged: {
          __updateFromController = true;
          currentIndex = modelIndex;
          __updateFromController = false;
        }

        onActivated: (index) => {
          if (!__updateFromController && controller != null) {
            controller.selectedFilterTagIndex = index;
          }
        }
      } // TibiaComboBox

      TibiaComboBox {
        id: sortOrderBox
        property int modelIndex: controller != null ? controller.selectedSortOrderIndex : -1;
        property bool __updateFromController: false
        model: controller != null ? controller.sortOrderModel : null
        Layout.fillWidth: true

        onModelIndexChanged: {
          __updateFromController = true;
          currentIndex = modelIndex;
          __updateFromController = false;
        }

        onCurrentIndexChanged: {
          if (!__updateFromController && controller != null) {
            controller.selectedSortOrderIndex = currentIndex;
          }
        }
      } // TibiaComboBox
    } // RowLayout
  } // TibiaFrame2PixelUpFilled

  TibiaFrame1PixelDown {
    id: offerFrame
    anchors { top: topBox.bottom; topMargin: TibiaStyle.marginRelated; bottom: parent.bottom; }
    width: 260

    TibiaScrollView {
      anchors.fill: parent
      anchors.margins: parent.borderWidth
      contentWidth: offerList.width

      ListView {
        id: offerList
        model: controller != null ? controller.availableOffers : null

        property int modelIndex: controller != null ? controller.selectedOfferIndex : -1
        property bool __updateFromController: false

        spacing: 1

        KeyNavigation.tab: parentFocusItem
        KeyNavigation.backtab: parentFocusItem
        interactive: false //prevent flick behavior on touch screens
        boundsBehavior: Flickable.StopAtBounds
        pixelAligned: true
        highlightFollowsCurrentItem: false

        delegate: StoreOfferDisplay {
          width: offerList.width
          currentIndex: offerList.currentIndex
          dynamicallyLoadedImageManager: controller != null ? controller.dynamicallyLoadedImageManager : null
          smoothTextureFiltering: controller != null ? controller.smoothTextureFiltering : false

          onClicked: {
            offerList.currentIndex = index;
            if (controller != null) {
              controller.selectedOfferIndex = offerList.currentIndex;
            }
            offerList.forceActiveFocus();
          }
        }

        Keys.onDownPressed: {
          incrementCurrentIndex();
          if (controller != null) {
            controller.selectedOfferIndex = offerList.currentIndex;
          }
        }

        Keys.onUpPressed: {
          decrementCurrentIndex();
          if (controller != null) {
            controller.selectedOfferIndex = offerList.currentIndex;
          }
        }

        onModelIndexChanged: {
          __updateFromController = true;
          var IndexValuesDiffer = currentIndex != modelIndex
          currentIndex = modelIndex;
          if (IndexValuesDiffer) {
            positionViewAtIndex(currentIndex, ListView.Beginning);
          } else {
            positionViewAtIndex(currentIndex, ListView.Visible);
          }
          __updateFromController = false;
        }
      } // ListView
    } // TibiaScrollView
  } // TibiaFrame1PixelDown

  ColumnLayout {
    anchors { left: offerFrame.right; leftMargin: TibiaStyle.marginUnrelated;
              top: offerFrame.top; bottom: parent.bottom; right: parent.right; }
    spacing: TibiaStyle.marginUnrelated

    /*
    StoreHighlightState {
      property var firstHighlightState: {
        // Finds the first non-standard highlight in selected offer, fall back to default otherwise
        if (currentOffer != null) {
          for (var i = 0; i < currentOffer.quantities.length; ++i) {
            if (currentOffer.quantities[i].highlightState != TOffer.STATE_NONE) {
              return currentOffer.quantities[i].highlightState;
            }
          }
        }
        return TOffer.STATE_NONE;
      }

      Layout.alignment: Qt.AlignHCenter
      Layout.bottomMargin: -TibiaStyle.marginRelated
      highlightState: firstHighlightState
    }
    */

    TibiaText {
      Layout.fillWidth: true
      horizontalAlignment: Text.AlignHCenter
      text: currentOffer != null ? currentOffer.name : qsTrId("dummy_unknown")
    } // TibiaText

    Item {
      Layout.preferredHeight: detailVisualisationBorder.height
      Layout.fillWidth: true

      TibiaFrame1PixelDown {
        id: detailVisualisationBorder
        width: 130
        height: width

        StoreOfferVisualisation {
          anchors.centerIn: parent
          width: 128
          height: width
          visualisation: currentOffer != null ? currentOffer.visualisation : null
          dynamicallyLoadedImageManager: controller != null ? controller.dynamicallyLoadedImageManager : null
          smoothTextureFiltering: controller != null ? controller.smoothTextureFiltering : false
          sourceImageSize: 64 // Store images only exist for up to 64x64 sizes
          scaleUp: true
        } // StoreOfferVisualisation


        TibiaIconButton {
          id: buttonShowMale
          anchors.left: parent.left
          anchors.bottom: parent.bottom
          anchors.margins: TibiaStyle.marginRelated
          sourceUp: "/images/button-gendermale-up.png"
          sourceDown: "/images/button-gendermale-down.png"
          visible: currentOffer != null ? (currentOffer.visualisation.visualisationType == TOfferVisualisation.VISUALISATION_BOTH_GENDER_OUTFITS) : false
          checked: currentOffer != null ? (currentOffer.visualisation.genderToShow == TOfferVisualisation.MALE) : false
          onClicked: {
            if (currentOffer != null && currentOffer.visualisation.genderToShow != TOfferVisualisation.MALE) {
              currentOffer.visualisation.setGenderToShow(TOfferVisualisation.MALE);
              currentOffer.visualisationChanged();
            }
          }
        }

        TibiaIconButton {
          id: buttonShowFemale
          anchors.right: parent.right
          anchors.bottom: parent.bottom
          anchors.margins:TibiaStyle.marginRelated
          sourceUp: "/images/button-genderfemale-up.png"
          sourceDown: "/images/button-genderfemale-down.png"
          visible: currentOffer != null ? (currentOffer.visualisation.visualisationType == TOfferVisualisation.VISUALISATION_BOTH_GENDER_OUTFITS) : false
          checked: currentOffer != null ? (currentOffer.visualisation.genderToShow == TOfferVisualisation.FEMALE) : false
          onClicked: {
            if (currentOffer != null && currentOffer.visualisation.genderToShow != TOfferVisualisation.FEMALE) {
              currentOffer.visualisation.setGenderToShow(TOfferVisualisation.FEMALE);
              currentOffer.visualisationChanged();
            }
          }
        }

      } // TibiaFrame1PixelDown

      ListView {
        id: buyButtonsList
        anchors { left: detailVisualisationBorder.right; leftMargin: TibiaStyle.marginRelated;
                  right: parent.right; top: detailVisualisationBorder.top;
                  bottom: tryButton.top; bottomMargin: TibiaStyle.marginUnrelated; }
        model: currentOffer != null ? currentOffer.quantities : null
        spacing: TibiaStyle.marginRelated

        interactive: false //prevent flick behavior on touch screens
        boundsBehavior: Flickable.StopAtBounds
        pixelAligned: true

        delegate: Item {
          width: parent.width
          height: buyButton.height + TibiaStyle.marginNarrow + buyPrice.height

          TibiaButton {
            id: buyButton
            text: currentOffer != null && currentOffer.needsUserConfiguration
                  ? qsTrId("configure")
                  : (buyButtonsList.count > 1 || modelData.quantity > 1
                    ? qsTrId("store_buy_quantity").arg(modelData.quantity)
                    : qsTrId("buy"))
            enabled: {
              if (modelData.canBeBought) {
                var storeBalance = storeAndResourceBalanceHelper.storeBalance;
                if (modelData.currencyType == TOffer.TIBIA_COINS) {
                  return storeBalance.totalBalance >= modelData.price;
                } else if (modelData.currencyType == TOffer.TRUSTED_TIBIA_COINS) {
                  return storeBalance.confirmedBalance >= modelData.price;
                }
              }
              return false;
            } //enabled
            color: enabled ? "blue" : "grey"
            width: parent.width

            onClicked: {
              if (controller != null) {
                controller.buyOffer(modelData.offerID);
              }
            }
          } // TibiaButton

          Tooltip {
            width: parent.width
            height: buyButton.height
            maxWidth: TibiaStyle.storeTooltipWidth
            text: {
              var storeBalance = storeAndResourceBalanceHelper.storeBalance;
              if (!modelData.canBeBought) {
                var DisabledReasons = "";
                for (var i = 0; i < modelData.disabledReasons.length; ++i) {
                  DisabledReasons += qsTrId("store_offer_disabled_reason")
                    .arg(modelData.disabledReasons[i]);
                }
                return qsTrId("store_offer_quantity_disabled").arg(DisabledReasons);
              } else if (modelData.currencyType == TOffer.TIBIA_COINS && storeBalance.totalBalance < modelData.price) {
                return qsTrId("store_offer_quantity_disabled")
                  .arg(qsTrId("store_offer_disabled_reason_not_enough_coins"));
              } else if (modelData.currencyType == TOffer.TRUSTED_TIBIA_COINS && storeBalance.confirmedBalance < modelData.price) {
                return qsTrId("store_offer_quantity_disabled")
                  .arg(qsTrId("store_offer_disabled_reason_not_enough_transferable_coins"));
              } else {
                return "";
              }
            }
            useRichText: true
            delayInMs: 0
          } // Tooltip

          TibiaCurrencyView {
            id: buyPrice
            width: parent.width
            anchors { top: buyButton.bottom; topMargin: TibiaStyle.marginNarrow; }
            rightAligned: false
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
            price: modelData.isOnSale ? modelData.basePriceString : modelData.priceString
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
        } // delegate: Item
      } // ListView

      TibiaButton {
        id: tryButton
        anchors { left: detailVisualisationBorder.right; leftMargin: TibiaStyle.marginRelated;
                  right: parent.right; bottom: detailVisualisationBorder.bottom; }

        visible: currentOffer != null && currentOffer.canTryOn
        text: qsTrId("store_try_outfit")

        onClicked: {
          if (controller != null) {
            controller.tryOutfitForCurrentOffer();
          }
        }
      } // TibiaButton
    } // Item

    TibiaSunkenRectangle {
      Layout.fillHeight: true
      Layout.fillWidth: true

      TibiaScrollView {
        anchors.fill: parent
        anchors.margins: parent.borderWidth

        Flickable {
          contentHeight: detailsLayout.height + TibiaStyle.marginNarrow * 2
          contentWidth: parent.availableWidth

          interactive: false //prevent flick behavior on touch screens
          boundsBehavior: Flickable.StopAtBounds

          ColumnLayout {
            id: detailsLayout
            spacing: TibiaStyle.marginRelated
            anchors { left: parent.left; top: parent.top; right: parent.right }
            anchors.margins: TibiaStyle.marginNarrow

            TibiaTextEdit {
              Layout.maximumWidth: parent.width
              Layout.preferredWidth: Layout.maximumWidth
              readOnly: true
              text: {
                if (currentOffer != null) {
                  var Description =  currentOffer.description;
                  if (!currentOffer.canBeBought) {
                    if (currentOffer.needsUserConfiguration) {
                      return qsTrId("store_offer_disabled_with_configure_description")
                        .arg(Description);
                    } else {
                      return qsTrId("store_offer_disabled_description")
                        .arg(Description);
                    }
                  } else if (currentOffer.oneOrMoreQuantitiesDisabled) {
                    if (currentOffer.needsUserConfiguration) {
                      return qsTrId("store_offer_parts_disabled_with_configure_description")
                        .arg(Description);
                    } else {
                      return qsTrId("store_offer_parts_disabled_description")
                        .arg(Description);
                    }
                  } else {
                    return Description;
                  }
                } else {
                  return "";
                }
              }

              textFormat: TextEdit.RichText // Must replace newline characters with br tag to properly format
              wrapMode: TextEdit.WordWrap
              selectByMouse: true

              onActiveFocusChanged: {
                offerList.focus = true;
              }
            } //TibiaTextEdit

            TibiaText {
              text: qsTrId("store_offer_bundle_contents")
              Layout.topMargin: TibiaStyle.marginRelated
              visible: bundleView.visible
              styleType: "Default"
            } // TibiaText

            Repeater {
              id: bundleView
              model: currentOffer != null ? currentOffer.products : null
              visible: count > 0

              delegate: RowLayout {
                spacing: TibiaStyle.marginRelated
                Layout.fillWidth: true
                Layout.bottomMargin: -TibiaStyle.marginRelated //reduce height

                StoreOfferVisualisation {
                  Layout.preferredWidth: 64
                  Layout.preferredHeight: 64
                  visualisation: modelData.visualisation
                  dynamicallyLoadedImageManager: controller != null ? controller.dynamicallyLoadedImageManager : null
                  smoothTextureFiltering: controller != null ? controller.smoothTextureFiltering : false
                } // StoreOfferVisualisation

                TibiaText {
                  Layout.leftMargin: TibiaStyle.marginRelated
                  Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                  text: modelData.name
                  styleType: "Default"
                } //TibiaText
              } // RowLayout
            } // Repeater

            Item {
              //margins at the bottom
              Layout.fillWidth: true
              Layout.preferredHeight: TibiaStyle.marginNarrow
            } //Item
          } //ColumnLayout
        } // Flickable
      } // TibiaScrollView
    } // TibiaSunkenRectangle
  } // ColumnLayout
} // Item
