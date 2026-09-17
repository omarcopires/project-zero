import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qmlcomponents

TibiaDialog {
  id: imbueDialog
  caption: qsTrId("imbuing_dialog_caption")
  width: 740

  property var imbuementIconSize: 66

  property var controller: null
  property var selectedImbuement: controller.selectedImbuement
  property var existingImbuement: controller.existingImbuement

  property bool editingExistingImbuement: existingImbuement != null
  property bool updateFromControllerInProgress: false
  property bool noActionAvailable: (existingImbuement == null) && (selectedImbuement == null)
  property bool clientSettingSmoothFiltering: controller.clientSettingSmoothFiltering

  onReturnPressedFunction: function () {}

  onCancelPressedFunction: function () {
    if (controller != null) {
      controller.requestClose();
    }
  }

  function imbuementSectionCaption() {
    if (controller.imbueModeScroll) {
      return qsTrId("imbuing_item_scroll_caption");
    }
    var selectedImbuement = controller.existingImbuement;
    if (selectedImbuement != null) {
      if (selectedImbuement.imbuementId != 0) {
        return qsTrId("imbuing_item_existing_slot_caption");
      }
    }
    return qsTrId("imbuing_item_empty_slot_caption");
  }

  function imbuementActionCaption() {
    if (controller.imbueModeScroll) {
      if ((selectedImbuement != null) && (selectedImbuement.imbuementId != 0)) {
        return qsTrId("imbuing_action_scroll_caption").arg(selectedImbuement.name);
      }
    }
    if (existingImbuement != null) {
      if (existingImbuement.imbuementId != 0) {
        return qsTrId("imbuing_item_clear_caption").arg(existingImbuement.name);
      }
    }
    if (selectedImbuement != null) {
      if ((selectedImbuement != null) && (selectedImbuement.imbuementId != 0)) {
        return qsTrId("imbuing_action_empty_slot_caption").arg(selectedImbuement.name);
      }
    }
    return "";
  }

  initialFocusItem: imbueDialog
  KeyNavigation.tab: imbueDialog

  ColumnLayout {
    anchors {
      left: parent.left
      top: parent.top
      right: parent.right
    }
    spacing: TibiaStyle.marginUnrelated

    // Item selection section
    TibiaFrame2PixelUpFilledWithCaption {
      caption: qsTrId("imbuing_item_information_caption")
      Layout.fillWidth: true
      Layout.preferredHeight: itemInfoAndSlotLayout.height + marginsToContent + topMarginToContent

      RowLayout {
        id: itemInfoAndSlotLayout

        anchors {
          left: parent.left
          right: parent.right
          top: parent.top
        }

        anchors.margins: parent.marginsToContent
        anchors.topMargin: parent.topMarginToContent

        RowLayout {
          id: itemSelectionButtons
          Layout.alignment: Qt.AlignLeft

          TibiaButton {
            id: pickItemButton
            Layout.preferredWidth: TibiaStyle.mapWindowPixelPerField * 3
            Layout.preferredHeight: TibiaStyle.mapWindowPixelPerField * 2

            imageSource: "/cursors/cursor-crosshair.png"
            imageAnchor: "center"
            imageXOffset: 4
            imageYOffset: -4

            text: qsTrId("imbuing_pick_item")
            textFont: TibiaStyle.defaultTextFont
            textVerticalAlignment: Text.AlignBottom
            textBottomPadding: 4

            onClicked: controller.handlePickItemToImbue()
          }

          TibiaButton {
            id: pickScrollButton

            // enabled: controller.scrollIsAvailable || !controller.isPremium

            Layout.preferredWidth: TibiaStyle.mapWindowPixelPerField * 3
            Layout.preferredHeight: TibiaStyle.mapWindowPixelPerField * 2

            text: qsTrId("imbuing_pick_scroll")
            textFont: TibiaStyle.defaultTextFont
            textVerticalAlignment: Text.AlignBottom
            textBottomPadding: 4

            color: controller.isPremium ? "grey" : "blue"

            onClicked: {
              if (!controller.isPremium) {
                controller.openPremiumStore();
              } else {
                controller.handleImbueScroll();
              }
            }

            ScalableObjectDisplay {
              anchors.centerIn: parent
              anchors.verticalCenterOffset: -8
              smoothTextureFiltering: imbueDialog.clientSettingSmoothFiltering
              showBackground: false
              animated: true
              typeid: 51442
            }
          }
        }

        RowLayout {
          id: imbuementSlotSection
          Layout.alignment: Qt.AlignCenter
          visible: controller.itemSelectionValid

          TibiaText {
            visible: (controller.selectedItemText != "")
            text: controller.selectedItemText
          }

          ScalableObjectDisplay {
            id: selectedItem
            visible: controller.itemSelectionValid
            Layout.preferredWidth: TibiaStyle.mapWindowPixelPerField * 3
            Layout.preferredHeight: TibiaStyle.mapWindowPixelPerField * 2
            scaleFactor: TibiaStyle.imbuingImbuedItemScaleFactor
            smoothTextureFiltering: imbueDialog.clientSettingSmoothFiltering
            showBackground: false

            animated: true
            typeid: controller.imbuedItemObjectID

            upgradeTier: controller != null ? controller.imbuedItemObjectUpgradeTier : 0
          }

          TibiaText {
            visible: controller.imbuementSlots.count > 0
            text: qsTrId("imbuing_select_slot")
            verticalAlignment: Text.AlignVCenter
          }

          Repeater {
            model: controller.imbuementSlots

            BorderImage {
              property bool isSelected: controller.selectedImbuementSlotIndex == model.slotIndex

              Layout.preferredWidth: imbuementIconSize
              Layout.preferredHeight: imbuementIconSize
              border {
                left: 1
                right: 1
                top: 1
                bottom: 1
              }
              source: isSelected ? "/images/1pixel-down-frame.png" : "/images/1pixel-up-frame.png"
              horizontalTileMode: BorderImage.Repeat
              verticalTileMode: BorderImage.Repeat

              Image {
                anchors.fill: parent
                anchors.margins: 1
                source: model.imageSource
              }

              MouseArea {
                anchors.fill: parent
                hoverEnabled: true

                onClicked: {
                  if (model.category == qsTrId("imbuing_category_basic")) {
                    basicFilterButton.checked = true;
                    controller.handlePickFilterBasic();
                  }
                  if (model.category == qsTrId("imbuing_category_intricate")) {
                    intricateFilterButton.checked = true;
                    controller.handlePickFilterIntricate();
                  }
                  if (model.category == qsTrId("imbuing_category_powerful")) {
                    powerfulFilterButton.checked = true;
                    controller.handlePickFilterPowerful();
                  }
                  if (model.slotIndex != controller.selectedImbuementSlotIndex) {
                    controller.handleSelectImbuementSlot(model.slotIndex);
                  }
                }

                onEntered: {}

                onExited: {
                  actionSectionHoverText.text = "";
                }
              }
            }
          }
        }
      }
    }

    // Imbuement section
    TibiaFrame2PixelUpFilledWithCaption {
      id: imbuementSelectionSection
      caption: imbuementSectionCaption()
      Layout.fillWidth: true
      Layout.preferredHeight: topMarginToContent + emptySlotImbuementLayout.height + marginsToContent

      ColumnLayout {
        id: emptySlotImbuementLayout
        visible: controller.itemSelectionValid

        anchors {
          left: parent.left
          right: parent.right
          top: parent.top
        }
        anchors.margins: parent.borderWidth + TibiaStyle.marginUnrelated
        anchors.topMargin: parent.topMarginToContent

        RowLayout {
          id: categoryFilterSelection
          visible: controller.imbueModeItem || controller.imbueModeScroll
          spacing: TibiaStyle.marginUnrelated

          Layout.alignment: Qt.AlignHCenter

          ButtonGroup {
            id: imbuementFilterGroup
            exclusive: true

            onClicked: function (button) {
              if (!controller.isPremium) {
                if (button.text == qsTrId("imbuing_category_intricate")) {
                  controller.openPremiumStore();
                  return;
                }
                if (button.text == qsTrId("imbuing_category_powerful")) {
                  controller.openPremiumStore();
                  return;
                }
              }
              if (controller.imbuementFilter != button.text) {
                controller.imbuementFilter = button.text;
              }
            }
          }

          TibiaButton {
            id: basicFilterButton
            imageSource: "/images/imbuing/icon-imbuementlevel-basic.png"
            imageAnchor: "left"
            text: qsTrId("imbuing_category_basic")
            textFont: TibiaStyle.defaultTextFont

            Layout.preferredWidth: TibiaStyle.premiumStateButtonWidth + 16
            Layout.preferredHeight: TibiaStyle.premiumStateButtonHeight

            ButtonGroup.group: imbuementFilterGroup
            checked: controller.imbuementFilter == qsTrId("imbuing_category_basic")
            checkable: true

            visible: existingImbuement == null && !controller.imbueModeScroll
            enabled: (existingImbuement == null)
          }

          TibiaButton {
            id: intricateFilterButton
            imageSource: "/images/imbuing/icon-imbuementlevel-intricate.png"
            imageAnchor: "left"

            text: qsTrId("imbuing_category_intricate")
            textFont: TibiaStyle.defaultTextFont

            Layout.preferredWidth: TibiaStyle.premiumStateButtonWidth + 16
            Layout.preferredHeight: TibiaStyle.premiumStateButtonHeight

            Image {
              anchors.verticalCenter: parent.verticalCenter
              anchors.verticalCenterOffset: (parent.pressed || parent.checked ? 1 : 0)
              anchors.horizontalCenter: parent.horizontalCenter
              anchors.horizontalCenterOffset: (parent.width / 2.6) + (parent.pressed || parent.checked ? 1 : 0)
              source: controller.isPremium ? "/images/imbuing/imbuing-icon-premium.png" : "/images/imbuing/imbuing-icon-nopremium.png"
              smooth: false
            }

            ButtonGroup.group: imbuementFilterGroup
            checked: controller.imbuementFilter == qsTrId("imbuing_category_intricate")
            checkable: true

            visible: existingImbuement == null
            enabled: existingImbuement == null
            color: controller.isPremium ? "grey" : "blue"
          }

          TibiaButton {
            id: powerfulFilterButton
            imageSource: "/images/imbuing/icon-imbuementlevel-powerful.png"
            imageAnchor: "left"

            text: qsTrId("imbuing_category_powerful")
            textFont: TibiaStyle.defaultTextFont

            Layout.preferredWidth: TibiaStyle.premiumStateButtonWidth + 16
            Layout.preferredHeight: TibiaStyle.premiumStateButtonHeight

            Image {
              anchors.verticalCenter: parent.verticalCenter
              anchors.verticalCenterOffset: (parent.pressed || parent.checked ? 1 : 0)
              anchors.horizontalCenter: parent.horizontalCenter
              anchors.horizontalCenterOffset: (parent.width / 2.6) + (parent.pressed || parent.checked ? 1 : 0)
              source: controller.isPremium ? "/images/imbuing/imbuing-icon-premium.png" : "/images/imbuing/imbuing-icon-nopremium.png"
              smooth: false
            }

            ButtonGroup.group: imbuementFilterGroup
            checked: controller.imbuementFilter == qsTrId("imbuing_category_powerful")
            checkable: true

            visible: existingImbuement == null
            enabled: existingImbuement == null
            color: controller.isPremium ? "grey" : "blue"
          }

          Item {
            Layout.preferredHeight: TibiaStyle.premiumStateButtonHeight
            visible: existingImbuement != null
          }
        }

        GridView {
          id: imbuementsGrid
          model: controller.availableImbuements

          Layout.alignment: Qt.AlignHCenter
          Layout.preferredWidth: (imbuementIconSize + 4) * Math.min(controller.availableImbuements.rowCount(), 9)
          Layout.preferredHeight: (imbuementIconSize + 4) * Math.ceil(controller.availableImbuements.rowCount() / 9)

          interactive: false

          cellWidth: imbuementIconSize + 4
          cellHeight: imbuementIconSize + 4

          delegate: BorderImage {
            id: item

            property bool checked: controller.selectedImbuementId == model.imbuementId
            property bool isDisabled: (existingImbuement != null) && (existingImbuement.imbuementID != model.imbuementId)

            width: imbuementIconSize
            height: imbuementIconSize

            border {
              left: 1
              right: 1
              top: 1
              bottom: 1
            }
            source: checked ? "/images/1pixel-down-frame.png" : "/images/1pixel-up-frame.png"

            Image {
              visible: model.imbuementId != 0
              anchors.fill: parent
              anchors.margins: 1
              source: model.imageSource
            }

            MouseArea {
              anchors.fill: parent
              hoverEnabled: true

              onClicked: {
                if (!isDisabled) {
                  imbuementsGrid.currentIndex = index;
                  controller.handleSelectImbuement(model.imbuementId);
                }
              }
            }

            TibiaDisabledOverlay {
              anchors.fill: parent
              anchors.margins: 1
              visible: isDisabled
            }

            Rectangle {
              anchors.fill: parent
              visible: !isDisabled && (controller.selectedImbuementId == model.imbuementId)
              color: "transparent"      // No fill, just the border
              border.width: 1           // 1 'logical' pixel in QML
              border.color: "white"
            }
          }
        }

        RowLayout {
          id: imbuementInformation
          spacing: TibiaStyle.marginUnrelated
          Layout.fillWidth: true

          TibiaText {
            id: imbuementInformationText
            Layout.fillWidth: true
            verticalAlignment: Text.AlignTop
            wrapMode: Text.Wrap
            text: controller.selectedImbuement != null ? controller.selectedImbuement.description : ""
          }
        }
      }

      TibiaDisabledOverlay {
        anchors.fill: parent
        anchors.margins: 1
        visible: !controller.itemSelectionValid
      }
    }

    // Action section
    TibiaFrame2PixelUpFilledWithCaption {
      id: actionArea
      caption: imbuementActionCaption()

      Layout.fillWidth: true
      Layout.preferredHeight: resourceInformation.height + actionSectionHoverTextLayout.height + TibiaStyle.marginUnrelated * 4

      ColumnLayout {

        anchors {
          left: parent.left
          right: parent.right
          top: parent.top
        }

        anchors.margins: parent.borderWidth + TibiaStyle.marginUnrelated
        anchors.topMargin: parent.captionHeight + TibiaStyle.marginUnrelated

        RowLayout {
          id: resourceInformation
          visible: selectedImbuement != null || existingImbuement != null

          Item {
            id: resourcesContainer
            Layout.preferredWidth: resourceLayout.width + TibiaStyle.marginRelated
            Layout.preferredHeight: resourceLayout.height
            visible: !editingExistingImbuement || controller.imbueModeScroll

            RowLayout {
              id: resourceLayout

              Repeater {
                model: selectedImbuement != null ? selectedImbuement.astralSources : []

                ColumnLayout {
                  spacing: TibiaStyle.marginNarrow

                  BorderImage {
                    id: resourceBackground
                    Layout.preferredWidth: TibiaStyle.mapWindowPixelPerField * 2 + 2
                    Layout.preferredHeight: TibiaStyle.mapWindowPixelPerField * 2 + 2
                    source: "/images/backdrop-dark-grey.png"
                    horizontalTileMode: BorderImage.Repeat
                    verticalTileMode: BorderImage.Repeat

                    TibiaFrame1PixelDown {
                      anchors.fill: parent

                      SingleObjectAppearanceInstanceRenderer {
                        anchors.centerIn: parent
                        width: TibiaStyle.mapWindowPixelPerField * 2
                        height: TibiaStyle.mapWindowPixelPerField * 2
                        scaleFactor: TibiaStyle.imbuingAstralSourcesScaleFactor
                        smoothTextureFiltering: imbueDialog.clientSettingSmoothFiltering

                        animated: true
                        typeid: modelData.objectID
                        cumulativeCount: modelData.objectCount
                        liquidType: modelData.liquidType
                        hookDirection: modelData.hookDirection
                        decoItemObjectID: 0
                      }
                    }

                    MouseArea {
                      anchors.fill: parent
                      hoverEnabled: true
                      onEntered: {
                        actionSectionHoverText.text = modelData != null && modelData.resourceString.length > 0 ? (modelData.hasEnoughToImbue ? qsTrId("imbuing_time_resource_available_tooltip").arg(modelData.name) : qsTrId("imbuing_time_resource_unavailable_tooltip").arg(modelData.name)) : "";
                      }
                      onExited: {
                        actionSectionHoverText.text = "";
                      }
                    }
                  }

                  TibiaCurrencyView {
                    balance: modelData.resourceString
                    rightAligned: false
                    iconId: ""
                    Layout.preferredWidth: resourceBackground.width
                    tooLowBalance: !modelData.hasEnoughToImbue
                  }
                }
              }
            }
          }

          Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            visible: editingExistingImbuement
          }

          TibiaProgressBar {
            id: timeLeftProgressBar
            Layout.preferredHeight: TibiaStyle.progressBarLargeHeight
            Layout.preferredWidth: Math.max(imbuementIconSize * 4 + TibiaStyle.marginRelated * 3 // Four 66x item slots plus padding in between
            , resourcesContainer.width)
            fillPercentage: existingImbuement != null ? existingImbuement.remainingDurationPercentage : 0
            visible: editingExistingImbuement

            frameSource: "/images/1pixel-down-frame.png"
            backgroundSource: "/images/backdrop-dark-grey.png"
            fillSource: "/images/progressbar-orange-large.png"

            frameBorder {
              left: 1
              right: 1
              top: 1
              bottom: 1
            }
            fillOffset {
              left: 1
              right: 1
              top: 1
              bottom: 1
            }

            TibiaText {
              anchors.centerIn: parent
              text: existingImbuement != null ? existingImbuement.remainingDuration : ""
            }

            MouseArea {
              anchors.fill: parent
              hoverEnabled: true
              onEntered: {
                actionSectionHoverText.text = qsTrId("imbuing_time_remaining_tooltip");
              }
              onExited: {
                actionSectionHoverText.text = "";
              }
            }
          }

          Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
          }

          Image {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            source: "/images/skin/classic/indicator-arrowright.png"
            visible: !editingExistingImbuement
          }

          Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
          }

          ColumnLayout {
            id: imbueButtonLayout
            spacing: TibiaStyle.marginNarrow
            Layout.alignment: Qt.AlignRight
            visible: !editingExistingImbuement

            Item {
              Layout.preferredWidth: 128
              Layout.preferredHeight: imbuementIconSize

              MouseArea {
                id: imbueButtonHoverArea
                property string text: qsTrId("imbuing_imbue_button_tooltip")
                anchors.fill: parent
                hoverEnabled: enabled
                enabled: !imbueButton.enabled && imbueButtonLayout.visible
                onEntered: {
                  actionSectionHoverText.text = text;
                }
                onExited: {
                  actionSectionHoverText.text = "";
                }
              }

              TibiaButton {
                id: imbueButton

                property bool canPayGoldCost: !imbuementPriceView.tooLowBalance
                property bool correctPremiumRequiredment: (selectedImbuement != null) && (controller.isPremium || !selectedImbuement.premiumOnly)
                property bool correctAstralSources: (selectedImbuement != null) && selectedImbuement.enoughAstralSourcesForImbuement

                anchors.fill: parent
                imageSource: "/images/imbuing/imbuing-icon-imbue-active.png"
                imageSourceDisabled: "/images/imbuing/imbuing-icon-imbue-disabled.png"
                enabled: canPayGoldCost && correctPremiumRequiredment && correctAstralSources

                onClicked: {
                  controller.requestImbue();
                }

                onHoveredChanged: {
                  actionSectionHoverText.text = hovered ? imbueButtonHoverArea.text : "";
                }
              }
            }

            TibiaCurrencyView {
              id: imbuementPriceView
              property int imbuementPrice: (selectedImbuement != null) ? selectedImbuement.goldCost : 0
              property string imbuementPriceString: (selectedImbuement != null) ? selectedImbuement.goldCostString : ""
              balance: imbuementPriceString
              rightAligned: false
              iconId: "GoldCoin"
              tooLowBalance: imbuementPrice > storeAndResourceBalanceHelper.totalGoldBalance
              Layout.preferredWidth: imbueButton.width
            }
          }

          ColumnLayout {
            id: clearButtonLayout
            spacing: TibiaStyle.marginNarrow
            Layout.alignment: Qt.AlignRight
            visible: editingExistingImbuement

            Item {
              Layout.preferredWidth: 128
              Layout.preferredHeight: imbuementIconSize

              MouseArea {
                id: clearButtonHoverArea
                property string text: qsTrId("imbuing_clear_button_tooltip")
                anchors.fill: parent
                hoverEnabled: enabled
                enabled: !clearButton.enabled && clearButtonLayout.visible
                onEntered: {
                  actionSectionHoverText.text = text;
                }
                onExited: {
                  actionSectionHoverText.text = "";
                }
              }

              TibiaButton {
                id: clearButton

                property bool canPayGoldCost: !clearPriceView.tooLowBalance

                anchors.fill: parent
                imageSource: "/images/imbuing/imbuing-icon-remove-active.png"
                imageSourceDisabled: "/images/imbuing/imbuing-icon-remove-disabled.png"
                enabled: canPayGoldCost

                onClicked: {
                  if (controller != null) {
                    controller.requestClearImbuement();
                  }
                }

                onHoveredChanged: {
                  actionSectionHoverText.text = hovered ? clearButtonHoverArea.text : "";
                }
              }
            }

            TibiaCurrencyView {
              id: clearPriceView
              property int clearPrice: existingImbuement != null ? existingImbuement.clearingGoldCost : 0
              property string clearPriceString: existingImbuement != null ? existingImbuement.clearingGoldCostString : ""
              balance: clearPriceString
              rightAligned: false
              iconId: "GoldCoin"
              tooLowBalance: clearPrice > storeAndResourceBalanceHelper.totalGoldBalance
              Layout.preferredWidth: clearButton.width
            }
          }
        }

        RowLayout {
          id: actionSectionHoverTextLayout
          spacing: TibiaStyle.marginUnrelated
          Layout.fillWidth: true

          TibiaText {
            id: actionSectionHoverText
            Layout.fillWidth: true
            text: ""
            wrapMode: Text.Wrap
          }
        }
      }

      TibiaDisabledOverlay {
        anchors.fill: parent
        anchors.margins: 1
        visible: selectedImbuement == null && existingImbuement == null
      }
    }

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    }

    RowLayout {
      spacing: TibiaStyle.marginRelated

      TibiaCurrentBalanceView {
        Layout.preferredWidth: TibiaStyle.currencyViewWidth
        balanceType: "GoldCoin"
      }

      Item {
        Layout.fillWidth: true
        height: 1
      }

      TibiaButton {
        text: qsTrId("close")
        onClicked: onCancelPressedFunction()
      }
    }
  }
}
