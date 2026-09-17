import QtQuick
import QtQuick.Layouts

import qmlcomponents


ColumnLayout {
  id: root
  spacing: TibiaStyle.marginRelated

  property var controller: null
  property bool readOnlyMode: true
  property bool smoothTextureFiltering: false
  readonly property int availableExaltedCoreCount: storeAndResourceBalanceHelper.exaltedCoreCount
                                                 - (successChanceButton.checked ? 1 : 0)
                                                 - (tierLossButton.checked ? 1 : 0)

  function fusionObjectSelected(typeID, upgradeTier) {
    if (controller != null) {
      controller.fusionObjectSelected(typeID, upgradeTier);
    }
  }

  function resourceObjectSelected(typeID, upgradeTier) {
    if (controller != null) {
      controller.resourceObjectSelected(typeID);
    }
  } //function resourceObjectSelected

  function hideHoverText() {
    displayHoverText.text = "";
  } //function root.hideHoverText

  function readOnlyModeDependedHoverAreaTextExtension(addLineBreak) {
    var text = addLineBreak ? "<br>" : "";
    text += readOnlyMode ? qsTrId("exaltation_forge_readonly_mode_hover_area").arg(qsTrId("exaltation_forge_fusion")) : "";
    return text;
  } //function readOnlyModeDependedInteractiveHoverAreaText

  Component {
    id: noObjecSelectedComponent
    Image {
      source: "/images/icon-questionmark.png"
    } //Image
  } //Component

  TibiaFrame2PixelUpFilledWithCaption {
    caption: qsTrId("exaltation_forge_select_fusion_item_caption")
    Layout.fillWidth: true
    Layout.preferredHeight: itemSelectionLayout.height + marginsToContent + topMarginToContent

    RowLayout {
      id: itemSelectionLayout
      anchors { left: parent.left; top: parent.top; right: parent.right }
      anchors.margins: parent.marginsToContent
      anchors.topMargin: parent.topMarginToContent

      spacing: TibiaStyle.marginRelated

      TibiaItemSelectionGrid {
        id: itemSelectionGrid
        model: controller != null ? controller.fusionObjectsModel : null
        selectedTypeID: controller != null ? controller.fusionObjectTypeId : 0
        selectedUpgradeTier: controller != null ? controller.fusionObjectUpgradeTier : 0

        Component.onCompleted: {
          clicked.connect(root.fusionObjectSelected);
          slotEntered.connect(fusionObjectSelectionHoverArea.setHoverText);
          slotExited.connect(root.hideHoverText);
        } //Component.onCompleted
      } //TibiaItemSelectionGrid

      Item {
        Layout.fillWidth: true
      } //Item

      ColumnLayout {
        Layout.fillHeight: true

        Item {
          Layout.fillWidth: true
          Layout.fillHeight: true

          RowLayout {
            anchors.centerIn: parent

            Repeater {
              model: 3

              Image {
                Layout.alignment: Qt.AlignVCenter
                source: "/images/icon-arrow-rightlarge.png"
              } //Image
            } //Repeater
          } //RowLayout
        } //Item

        TibiaCheckBox {
          id: convergenceCheckbox
          text: qsTrId("exaltation_forge_convergence_activation_checkbox_caption")
          Layout.fillHeight: false
          Layout.alignment: Qt.AlignBottom
          shouldBeChecked: controller != null ? controller.convergenceFusionEnabled : false

          onCheckedChanged: {
            if (controller != null) {
              controller.convergenceFusionEnabled = checked;
            }
          }

          onHoveredChanged: {
            if (hovered) {
              var hoverText = "";
              if (!root.readOnlyMode) {
                hoverText = qsTrId("exaltation_forge_fusion_convergence_fusion_checkbox_info");
              }
              displayHoverText.text = hoverText + root.readOnlyModeDependedHoverAreaTextExtension(!root.readOnlyMode);
            } else {
              root.hideHoverText();
            }
          }
        } //TibiaCheckBox
      } //ColumnLayout

      Item {
        Layout.fillWidth: true
      } //Item

      Item {
        Layout.preferredWidth: itemSelectionGrid.width
        Layout.preferredHeight: itemSelectionGrid.height

        ScalableObjectDisplay {
          id: selectedFustionObjectDisplay
          anchors.centerIn: parent
          showBackground: false
          scaleFactor: TibiaStyle.exaltationForgeItemScaleFactor
          animated: true
          smoothTextureFiltering: root.smoothTextureFiltering
          typeid: controller != null ? controller.fusionObjectTypeId : 0
          upgradeTier: controller != null && typeid != 0 ? controller.fusionObjectUpgradeTier + 1 : 0
          mysteryObject: true

          Loader {
            anchors.centerIn: parent
            sourceComponent: parent.typeid == 0 ?  noObjecSelectedComponent  : null
          } //Loader
        } //ScalableObjectDisplay
      } //Item
    } //RowLayout

     MouseArea {
       id: fusionObjectSelectionHoverArea
       anchors.fill: parent
       z: -1
       hoverEnabled: true

       function setHoverText() {
         var hoverText = ""
         if (!root.readOnlyMode) {
           if (itemSelectionGrid.count == 0) {
             hoverText += qsTrId("exaltation_forge_fusion_not_item_to_select_hover_text");
           } else {
             hoverText += qsTrId("exaltation_forge_fusion_select_item_hover_text");
           }
         }
         displayHoverText.text = hoverText + root.readOnlyModeDependedHoverAreaTextExtension(!root.readOnlyMode);
       } //function setHoverText

       onEntered: setHoverText()
       onExited: root.hideHoverText()
     } // MouseArea
  } //TibiaFrame2PixelUpFilledWithCaption

  TibiaFrame2PixelUpFilledWithCaption {
    caption: qsTrId("exaltation_forge_fusion_requirements_caption")
    visible: !convergenceCheckbox.checked
    Layout.fillWidth: true
    Layout.preferredHeight: transferRequirementsLayout.height + marginsToContent + topMarginToContent

    RowLayout {
      id: transferRequirementsLayout
      anchors { left: parent.left; top: parent.top; right: parent.right }
      anchors.margins: parent.marginsToContent
      anchors.topMargin: parent.topMarginToContent

      spacing: TibiaStyle.marginRelated

      Item {
        Layout.preferredWidth: objectCostLayout.width
        Layout.preferredHeight: objectCostLayout.height

        ColumnLayout {
          id: objectCostLayout
          spacing: TibiaStyle.marginNarrow

          ScalableObjectDisplay {
            id: objectDisplay

            visible: !resourceSelectionGrid.visible

            showBackground: true
            scaleFactor: TibiaStyle.exaltationForgeItemScaleFactor
            animated: true
            smoothTextureFiltering: root.smoothTextureFiltering
            typeid: controller != null ? controller.resourceObjectTypeId : 0
            upgradeTier: controller != null ? controller.fusionObjectUpgradeTier : 0

            Loader {
              anchors.centerIn: parent
              sourceComponent: parent.typeid == 0 ?  noObjecSelectedComponent  : null
            } //Loader
          } //ScalableObjectDisplay

          TibiaItemSelectionGrid {
            id: resourceSelectionGrid
            Layout.preferredWidth: objectDisplay.width
            Layout.preferredHeight: objectDisplay.height

            model: controller != null ? controller.resourceObjectsModel : null
            selectedTypeID: controller != null ? controller.resourceObjectTypeId : 0
            selectedUpgradeTier: controller != null ? controller.fusionObjectUpgradeTier : 0

            visible: count > 1

            Component.onCompleted: {
              clicked.connect(root.resourceObjectSelected);
              slotEntered.connect(resourceItemHoverArea.setHoverText);
              slotExited.connect(root.hideHoverText);
            } //Component.onCompleted
          } //TibiaItemSelectionGrid



          TibiaCurrencyView {
            id: objectCostCurrencyView
            Layout.preferredWidth: objectDisplay.width
            rightAligned: false
            iconId: ""
            readonly property int objectCount: controller != null ? controller.resourceObjectCount : 0
            price: objectCount +"/1"
            tooLowBalance: objectCount < 1
          } //TibiaCurrencyView
        } //ColumnLayout

        MouseArea {
          id: resourceItemHoverArea
          anchors.fill: parent
          z: -1
          hoverEnabled: true

          function setHoverText() {
            var hoverText = "";
            if (!root.readOnlyMode) {
              if (objectDisplay.typeid != 0) {
                hoverText = qsTrId("exaltation_forge_fusion_resource_item_hover_text");
                if (objectDisplay.upgradeTier == 0) {
                   hoverText += qsTrId("exaltation_forge_fusion_resource_item_t0_destory_hover_text");
                } else {
                  hoverText += qsTrId("exaltation_forge_fusion_resource_item_tier_loss_hover_text");
                }
              } else {
                if (itemSelectionGrid.count == 0) {
                  hoverText += qsTrId("exaltation_forge_fusion_not_item_to_select_hover_text");
                } else {
                  hoverText += qsTrId("exaltation_forge_no_item_selected_hover_text");
                }
              }
            }
            displayHoverText.text = hoverText + root.readOnlyModeDependedHoverAreaTextExtension(!root.readOnlyMode);
          } //function setHoverText

          onEntered: setHoverText()
          onExited: root.hideHoverText()
        } // MouseArea
      } //Item

      Item {
        Layout.preferredWidth: dustCostLayout.width
        Layout.preferredHeight: dustCostLayout.height

        ColumnLayout {
          id: dustCostLayout
          spacing: TibiaStyle.marginNarrow

          ScalableObjectDisplay {
            id: dustDisplay
            showBackground: true
            scaleFactor: TibiaStyle.exaltationForgeItemScaleFactor
            animated: true
            smoothTextureFiltering: root.smoothTextureFiltering
            typeid: TibiaStyle.exaltedDustId
          } //ScalableObjectDisplay

          TibiaCurrencyView {
            id: dustCostCurrencyView
            Layout.preferredWidth: objectDisplay.width
            price: controller != null ? controller.dustCostForFusion : 100
            tooLowBalance: controller == null || (storeAndResourceBalanceHelper.exaltedDustBalance < controller.dustCostForFusion)
            iconId: "Dust"
          } //TibiaCurrencyView
        } //ColumnLayout

        MouseArea {
          anchors.fill: parent
          z: -1
          hoverEnabled: true

          function setHoverText() {
            var hoverText = "";
            if (dustCostCurrencyView.tooLowBalance) {
               hoverText += qsTrId("exaltation_forge_fusion_dust_cost_to_expensive_hover_text").arg(dustCostCurrencyView.price);
            } else {
              hoverText += qsTrId("exaltation_forge_fusion_dust_cost_hover_text").arg(dustCostCurrencyView.price);
            }
            displayHoverText.text = hoverText + root.readOnlyModeDependedHoverAreaTextExtension(true);
          } //function setHoverText

          onEntered: setHoverText()
          onExited: root.hideHoverText()
        } // MouseArea
      } //Item

      ColumnLayout {
        spacing: 0

        Item {
          Layout.preferredWidth: successRateLayout.width
          Layout.preferredHeight: successRateLayout.height

          ColumnLayout {
            id: successRateLayout
            spacing: TibiaStyle.marginNarrow

            RowLayout {
              spacing: 0

              TibiaText {
                Layout.fillWidth: true
                text: qsTrId("exaltation_forge_fusion_success_chance")
              } //TibiaText

              TibiaText {
                styleType: successChanceButton.checked ? "ModifierPositive" : "WarningText"
                text: (controller != null ? controller.sucessChance + (successChanceButton.checked ? controller.sucessChanceBonus : 0)
                                          : 50) + "%"
              } //TibiaText
            } //RowLayout

            RowLayout {
              spacing: TibiaStyle.marginNarrow

              TibiaButton {
                id: successChanceButton
                Layout.preferredWidth: TibiaStyle.buttonWidthWider
                enabled: !succesRateIncreasCostsCurrencyView.tooLowBalance && !root.readOnlyMode
                checkable: true
                onCheckedChanged: successImproveHoverArae.setHoverText()
                text: qsTrId("exaltation_forge_fusion_success_chance_improvement").arg(controller != null ? controller.sucessChance + controller.sucessChanceBonus : 65)
              } //TibiaButton

              TibiaCurrencyView {
                id: succesRateIncreasCostsCurrencyView
                Layout.preferredWidth: TibiaStyle.currencyViewWidthNarrow
                price: "1"
                tooLowBalance: (storeAndResourceBalanceHelper.exaltedCoreCount - (tierLossButton.checked ? 1 : 0)) < 1
                iconId: "ExaltedCore"
              } //TibiaCurrencyView
            } //RowLayout
          } //ColumnLayout

          MouseArea {
            id: successImproveHoverArae
            anchors.fill: parent
            hoverEnabled: true

            function setHoverText() {
              var hoverText = "";
              if (controller != null) {
                if (successChanceButton.checked) {
                   hoverText += qsTrId("exaltation_forge_fusion_reduce_to_normal_success_chance_hover_text").arg(controller.sucessChance + controller.sucessChanceBonus)
                                                                                                            .arg(controller.sucessChance);
                } else {
                  hoverText += qsTrId("exaltation_forge_fusion_improve_success_chance_hover_text").arg(controller.sucessChance)
                                                                                                  .arg(controller.sucessChance + controller.sucessChanceBonus);
                }
              }
              displayHoverText.text = hoverText + root.readOnlyModeDependedHoverAreaTextExtension(true);
            } //function setHoverText

            onEntered: setHoverText()
            onExited: root.hideHoverText()

            propagateComposedEvents: true
            onClicked: (mouse) => mouse.accepted = false;
            onPressed: (mouse) => mouse.accepted = false;
            onReleased: (mouse) => mouse.accepted = false;
            onDoubleClicked: (mouse) => mouse.accepted = false;
            onPositionChanged: (mouse) => mouse.accepted = false;
            onPressAndHold: (mouse) => mouse.accepted = false;
          } // MouseArea
        } //Item

        Item {
          Layout.fillHeight: true
        } //Item

        Item {
          Layout.preferredWidth: tierLossLayout.width
          Layout.preferredHeight: tierLossLayout.height

          ColumnLayout {
            id: tierLossLayout
            spacing: TibiaStyle.marginNarrow

            RowLayout {
              spacing: 0

              TibiaText {
                Layout.fillWidth: true
                text: qsTrId("exaltation_forge_fusion_tier_loss")
              } //TibiaText

              TibiaText {
                styleType: tierLossButton.checked ? "ModifierPositive" : "WarningText"
                text: (controller != null ? (tierLossButton.checked ? controller.improvedTierLoss : controller.baseTierLoss)
                                          : 50) + "%"
              } //TibiaText
            } //RowLayout

            RowLayout {
              spacing: TibiaStyle.marginNarrow

              TibiaButton {
                id: tierLossButton
                Layout.preferredWidth: TibiaStyle.buttonWidthWider
                enabled: !tierLossReductionCostsCurrencyView.tooLowBalance && !root.readOnlyMode
                checkable: true
                onCheckedChanged: lossReductionHoverArea.setHoverText()
                text: qsTrId("exaltation_forge_fusion_improved_tier_loss").arg(controller != null ? controller.improvedTierLoss : 50)
              } //TibiaButton

              TibiaCurrencyView {
                id: tierLossReductionCostsCurrencyView
                Layout.preferredWidth: TibiaStyle.currencyViewWidthNarrow
                price: "1"
                tooLowBalance: (storeAndResourceBalanceHelper.exaltedCoreCount - (successChanceButton.checked ? 1 : 0)) < 1
                iconId: "ExaltedCore"
              } //TibiaCurrencyView
            } //RowLayout
          } //ColumnLayout

          MouseArea {
            id: lossReductionHoverArea
            anchors.fill: parent
            hoverEnabled: true

            function setHoverText() {
              var hoverText = "";
              if (controller != null) {
                if (tierLossButton.checked) {
                   hoverText += qsTrId("exaltation_forge_fusion_reduce_to_normal_loss_chance_chance_hover_text");
                } else {
                  hoverText += qsTrId("exaltation_forge_fusion_improve_loss_chance_hover_text").arg(controller.improvedTierLoss);
                }
              }
              displayHoverText.text = hoverText + root.readOnlyModeDependedHoverAreaTextExtension(true);
            } //function setHoverText

            onEntered: setHoverText()
            onExited: root.hideHoverText()

            propagateComposedEvents: true
            onClicked: (mouse) => mouse.accepted = false;
            onPressed: (mouse) => mouse.accepted = false;
            onReleased: (mouse) => mouse.accepted = false;
            onDoubleClicked: (mouse) => mouse.accepted = false;
            onPositionChanged: (mouse) => mouse.accepted = false;
            onPressAndHold: (mouse) => mouse.accepted = false;
          } // MouseArea
        } //Item
      } ///ColumnLayout

      Item {
        Layout.fillWidth: true
      } //Item

      RowLayout {
        Layout.fillHeight: true
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter | Qt.AlignRight

        Image {
          Layout.alignment: Qt.AlignVCenter
          Layout.rightMargin: TibiaStyle.marginUnrelated
          source: "/images/icon-arrow-rightlarge.png"
        }
      }

      Item {
        Layout.preferredWidth: transferButtonLayout.width
        Layout.preferredHeight: transferButtonLayout.height

        ColumnLayout {
          id: transferButtonLayout
          spacing: TibiaStyle.marginNarrow

          TibiaButton {
            id: transferButton
            Layout.preferredWidth: TibiaStyle.buttonWidthWidest
            Layout.preferredHeight: dustDisplay.height
            enabled:   !objectCostCurrencyView.tooLowBalance
                    && !dustCostCurrencyView.tooLowBalance
                    && !goldCostCurrencyView.tooLowBalance
                    && !root.readOnlyMode
                    && sourceItemObjectDisplay.typeid != 0
                    && (controller != null && controller.resourceObjectTypeId != 0)

            onClicked: {
              if (controller != null) {
                controller.requestFusion(successChanceButton.checked,
                                         tierLossButton.checked);
                successChanceButton.checked = false;
                tierLossButton.checked = false;
              }
            } //onClicked

            Item {
              width: 100
              height: TibiaStyle.mapWindowPixelPerField

              anchors.centerIn: parent
              anchors.verticalCenterOffset: (transferButton.pressed || transferButton.checked ? 1 : 0)
              anchors.horizontalCenterOffset: (transferButton.pressed || transferButton.checked ? 1 : 0)

              ScalableObjectDisplay {
                id: sourceItemObjectDisplay
                anchors.left: parent.left
                showBackground: false
                animated: true
                typeid: controller != null ? controller.fusionObjectTypeId : 0
                upgradeTier: controller != null ? controller.fusionObjectUpgradeTier : 0
                Loader {
                  anchors.centerIn: parent
                  sourceComponent: parent.typeid == 0 ?  noObjecSelectedComponent  : null
                } //Loader
              } //ScalableObjectDisplay

              Image {
                 anchors.centerIn: parent
                 source: "/images/icon_3arrows.png"
               } //Image

              ScalableObjectDisplay {
                id: targetItemObjectDisplay
                anchors.right: parent.right
                showBackground: false
                animated: true
                typeid: sourceItemObjectDisplay.typeid
                upgradeTier: typeid != 0 ? sourceItemObjectDisplay.upgradeTier + 1 : 0
                Loader {
                  anchors.centerIn: parent
                  sourceComponent: parent.typeid == 0 ?  noObjecSelectedComponent  : null
                } //Loader
              } //ScalableObjectDisplay
            } //Item

            TibiaDisabledOverlay {
              anchors.fill: parent
              anchors.margins: 1
              visible: !transferButton.enabled
            } //TibiaDisabledOverlay
          } //TibiaButton

          TibiaCurrencyView {
            id: goldCostCurrencyView
            Layout.preferredWidth: transferButton.width
            readonly property var fusionGoldCost: controller != null ? controller.fusionGoldCost : 0
            price: fusionGoldCost != 0 ? TextHelper.formatNumberWithThousandSeparatorsAndThousandShortcutsAsMultiString(fusionGoldCost)
                                         : "???"
            tooLowBalance: controller == null
                        || (storeAndResourceBalanceHelper.totalGoldBalance < fusionGoldCost)
                        || fusionGoldCost == 0
            iconId: "GoldCoin"
          } //TibiaCurrencyView
        } //ColumnLayout

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true

          function setHoverText() {
            var hoverText = "";
            if (controller != null) {
              if (root.readOnlyMode) {
                 hoverText += qsTrId("exaltation_forge_readonly_mode_hover_button");
              } else if (   controller.fusionObjectTypeId == 0
                         || controller.resourceObjectTypeId == 0) {
                 hoverText += qsTrId("exaltation_forge_fusion_need_to_select_items_hover_text");
              } else if (   objectCostCurrencyView.tooLowBalance
                         || dustCostCurrencyView.tooLowBalance
                         || goldCostCurrencyView.tooLowBalance) {
                 hoverText += qsTrId("exaltation_forge_fusion_not_enough_resources_hover_text");
              } else {
                hoverText += qsTrId("exaltation_forge_fusion_perform_fusion_hover_text");
              }
            }
            displayHoverText.text = hoverText;
          } //function setHoverText

          onEntered: setHoverText()
          onExited: root.hideHoverText()

          propagateComposedEvents: true
          onClicked: (mouse) => mouse.accepted = false;
          onPressed: (mouse) => mouse.accepted = false;
          onReleased: (mouse) => mouse.accepted = false;
          onDoubleClicked: (mouse) => mouse.accepted = false;
          onPositionChanged: (mouse) => mouse.accepted = false;
          onPressAndHold: (mouse) => mouse.accepted = false;
        } // MouseArea
      } //Item
    } //RowLayout
  } //TibiaFrame2PixelUpFilledWithCaption

  TibiaFrame2PixelUpFilledWithCaption {
    caption: qsTrId("exaltation_forge_convergence_fusion_requirements_caption")
    visible: convergenceCheckbox.checked
    Layout.fillWidth: true
    Layout.preferredHeight: transferRequirementsLayout.height + marginsToContent + topMarginToContent

    RowLayout {
      id: convergenceFusionRequirementsLayout
      anchors {
        left: parent.left; top: parent.top; right: parent.right
      }
      anchors.margins: parent.marginsToContent
      anchors.topMargin: parent.topMarginToContent

      spacing: TibiaStyle.marginRelated

      TibiaItemSelectionGrid {
        id: convergenceFusionItemSelectionGrid
        model: controller != null ? controller.resourceObjectsModel : null
        selectedTypeID: controller != null ? controller.resourceObjectTypeId : 0
        selectedUpgradeTier: controller != null ? controller.fusionObjectUpgradeTier : 0
        Layout.fillHeight: true

        Component.onCompleted: {
          clicked.connect(root.resourceObjectSelected);
          slotEntered.connect(fusionObjectSelectionHoverArea.setHoverText);
          slotExited.connect(root.hideHoverText);
        } //Component.onCompleted
      } //TibiaItemSelectionGrid

      Item {
        Layout.preferredWidth: dustCostLayout.width
        Layout.preferredHeight: dustCostLayout.height

        ColumnLayout {
          id: convergenceFusionDustCostLayout
          spacing: TibiaStyle.marginNarrow

          ScalableObjectDisplay {
            id: convergenceFusionDustDisplay
            showBackground: true
            scaleFactor: TibiaStyle.exaltationForgeItemScaleFactor
            animated: true
            smoothTextureFiltering: root.smoothTextureFiltering
            typeid: TibiaStyle.exaltedDustId
          } //ScalableObjectDisplay

          TibiaCurrencyView {
            id: convergenceFusionDustCostCurrencyView
            Layout.preferredWidth: objectDisplay.width
            price: controller != null ? controller.dustCostForFusion : 100
            tooLowBalance: controller == null || (storeAndResourceBalanceHelper.exaltedDustBalance < controller.dustCostForFusion)
            iconId: "Dust"
          } //TibiaCurrencyView
        } //ColumnLayout

        MouseArea {
          anchors.fill: parent
          z: -1
          hoverEnabled: true

          function setHoverText() {
            var hoverText = "";
            if (convergenceFusionDustCostCurrencyView.tooLowBalance) {
              hoverText += qsTrId("exaltation_forge_fusion_dust_cost_to_expensive_hover_text").arg(dustCostCurrencyView.price);
            } else {
              hoverText += qsTrId("exaltation_forge_fusion_dust_cost_hover_text").arg(dustCostCurrencyView.price);
            }
            displayHoverText.text = hoverText + root.readOnlyModeDependedHoverAreaTextExtension(true);
          } //function setHoverText

          onEntered: setHoverText()
          onExited: root.hideHoverText()
        } // MouseArea
      } //Item

      Item {
        Layout.fillWidth: true
      } //Item

      RowLayout {
        Layout.fillHeight: true
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter | Qt.AlignRight

        Image {
          Layout.alignment: Qt.AlignVCenter
          Layout.rightMargin: TibiaStyle.marginUnrelated
          source: "/images/icon-arrow-rightlarge.png"
        }
      }

      Item {
        Layout.preferredWidth: convergenceFusionButtonLayout.width
        Layout.preferredHeight: convergenceFusionButtonLayout.height

        ColumnLayout {
          id: convergenceFusionButtonLayout
          spacing: TibiaStyle.marginNarrow

          TibiaButton {
            id: convergenceFusionTransferButton
            Layout.preferredWidth: TibiaStyle.buttonWidthWidest
            Layout.preferredHeight: dustDisplay.height
            enabled: !objectCostCurrencyView.tooLowBalance
              && !dustCostCurrencyView.tooLowBalance
              && !goldCostCurrencyView.tooLowBalance
              && !root.readOnlyMode
              && sourceItemObjectDisplay.typeid != 0
              && (controller != null && controller.resourceObjectTypeId != 0)

            onClicked: {
              if (controller != null) {
                controller.requestConvergenceFusion();
              }
            } //onClicked

            Item {
              width: 100
              height: TibiaStyle.mapWindowPixelPerField

              anchors.centerIn: parent
              anchors.verticalCenterOffset: (transferButton.pressed || transferButton.checked ? 1 : 0)
              anchors.horizontalCenterOffset: (transferButton.pressed || transferButton.checked ? 1 : 0)

              ScalableObjectDisplay {
                id: convergenceFusionSourceItemObjectDisplay
                anchors.left: parent.left
                showBackground: false
                animated: true
                typeid: controller != null ? controller.fusionObjectTypeId : 0
                upgradeTier: controller != null ? controller.fusionObjectUpgradeTier : 0
                Loader {
                  anchors.centerIn: parent
                  sourceComponent: parent.typeid == 0 ? noObjecSelectedComponent : null
                } //Loader
              } //ScalableObjectDisplay

              Image {
                anchors.centerIn: parent
                source: "/images/icon_3arrows.png"
              } //Image

              ScalableObjectDisplay {
                id: convergenceFusionTargetItemObjectDisplay
                anchors.right: parent.right
                showBackground: false
                animated: true
                typeid: convergenceFusionSourceItemObjectDisplay.typeid
                upgradeTier: typeid != 0 ? convergenceFusionSourceItemObjectDisplay.upgradeTier + 1 : 0
                Loader {
                  anchors.centerIn: parent
                  sourceComponent: parent.typeid == 0 ? noObjecSelectedComponent : null
                } //Loader
              } //ScalableObjectDisplay
            } //Item

            TibiaDisabledOverlay {
              anchors.fill: parent
              anchors.margins: 1
              visible: !transferButton.enabled
            } //TibiaDisabledOverlay
          } //TibiaButton

          TibiaCurrencyView {
            id: convergenceFusionGoldCostCurrencyView
            Layout.preferredWidth: transferButton.width
            readonly property var fusionGoldCost: controller != null ? controller.fusionGoldCost : 0
            price: fusionGoldCost != 0 ? TextHelper.formatNumberWithThousandSeparatorsAndThousandShortcutsAsMultiString(fusionGoldCost)
              : "???"
            tooLowBalance: controller == null
              || (storeAndResourceBalanceHelper.totalGoldBalance < fusionGoldCost)
              || fusionGoldCost == 0
            iconId: "GoldCoin"
          } //TibiaCurrencyView
        } //ColumnLayout

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true

          function setHoverText() {
            var hoverText = "";
            if (controller != null) {
              if (root.readOnlyMode) {
                 hoverText += qsTrId("exaltation_forge_readonly_mode_hover_button");
              } else if (   controller.fusionObjectTypeId == 0
                         || controller.resourceObjectTypeId == 0) {
                 hoverText += qsTrId("exaltation_forge_fusion_need_to_select_items_hover_text");
              } else if (   objectCostCurrencyView.tooLowBalance
                         || dustCostCurrencyView.tooLowBalance
                         || goldCostCurrencyView.tooLowBalance) {
                 hoverText += qsTrId("exaltation_forge_fusion_not_enough_resources_hover_text");
              } else {
                hoverText += qsTrId("exaltation_forge_fusion_perform_fusion_hover_text");
              }
            }
            displayHoverText.text = hoverText;
          } //function setHoverText

          onEntered: setHoverText()
          onExited: root.hideHoverText()

          propagateComposedEvents: true
          onClicked: mouse.accepted = false;
          onPressed: mouse.accepted = false;
          onReleased: mouse.accepted = false;
          onDoubleClicked: mouse.accepted = false;
          onPositionChanged: mouse.accepted = false;
          onPressAndHold: mouse.accepted = false;
        } // MouseArea
      } //Item
    } //RowLayout
  } //TibiaFrame2PixelUpFilledWithCaption

  TibiaFrame2PixelUpFilled {
    Layout.fillWidth: true
    Layout.fillHeight: true

    TibiaText {
      id: displayHoverText
      anchors { left: parent.left; top: parent.top; right: parent.right }
      anchors.margins: TibiaStyle.marginRelated + parent.borderWidth
      wrapMode: Text.Wrap
      textFormat: Text.RichText
      text: ""
    } //TibiaText

    ColumnLayout {
      anchors { left: parent.left; top: parent.top; right: parent.right }
      anchors.margins: TibiaStyle.marginRelated + parent.borderWidth
      visible: displayHoverText.text == ""
      spacing: TibiaStyle.marginNarrow+1

      RowLayout {
        spacing: TibiaStyle.marginRelated

        TibiaText {
          text: convergenceCheckbox.checked
            ? qsTrId("exaltation_forge_fusion_what_is_convergence_fusion")
            : qsTrId("exaltation_forge_fusion_what_is_fusion")
        } //TibiaText

        TibiaGuiHelp {
          text: convergenceCheckbox.checked
            ? qsTrId("exaltation_forge_fusion_what_is_convergence_fusion_additional")
            : qsTrId("exaltation_forge_fusion_what_is_fusion_additional")
        } //TibiaGuiHelp
      } //RowLayout

      RowLayout {
        // show for convergence fusion only
        visible: convergenceCheckbox.checked
        spacing: TibiaStyle.marginRelated

        TibiaText {
          text: qsTrId("exaltation_forge_fusion_convergence_success_rate")
        } //TibiaText
      } //RowLayout

      RowLayout {
        // show for convergence fusion only
        visible: convergenceCheckbox.checked
        spacing: TibiaStyle.marginRelated

        TibiaText {
          text: qsTrId("exaltation_forge_fusion_convergence_no_bonus_effects")
        } //TibiaText
      } //RowLayout

      RowLayout {
        // show for convergence fusion only
        visible: convergenceCheckbox.checked
        spacing: TibiaStyle.marginRelated

        TibiaText {
          text: qsTrId("exaltation_forge_fusion_convergence_restriction_classification")
        } //TibiaText
      } //RowLayout

      RowLayout {
        // show for regular fusion only
        visible: !convergenceCheckbox.checked
        spacing: TibiaStyle.marginRelated

        TibiaText {
          text: qsTrId("exaltation_forge_what_are_upgrade_categories_for")
        } //TibiaText

        TibiaGuiHelp {
          useRichText: true
          text: qsTrId("exaltation_forge_what_are_upgrade_categories_for_additional")
        } //TibiaGuiHelp
      } //RowLayout

      RowLayout {
        // show for regular fusion only
        visible: !convergenceCheckbox.checked
        spacing: TibiaStyle.marginRelated

        TibiaText {
          text: qsTrId("exaltation_forge_fusion_why_use_cores")
        } //TibiaText

        TibiaGuiHelp {
          text: qsTrId("exaltation_forge_fusion_why_use_cores_additional")
        } //TibiaGuiHelp
      } //RowLayout

      RowLayout {
        // show for regular fusion only
        visible: !convergenceCheckbox.checked
        spacing: TibiaStyle.marginRelated

        TibiaText {
          text: qsTrId("exaltation_forge_what_are_tiers_for")
        } //TibiaText

        TibiaGuiHelp {
          text: qsTrId("exaltation_forge_what_are_tiers_for_additional")
        } //TibiaGuiHelp
      } //RowLayout
    } //ColumnLayout
  } //TibiaFrame2PixelUpFilled
} //ColumnLayout
