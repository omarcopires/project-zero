import QtQuick
import QtQuick.Layouts

import qmlcomponents


ColumnLayout {
  id: root
  spacing: TibiaStyle.marginRelated

  property var controller: null
  property bool readOnlyMode: true
  property bool smoothTextureFiltering: false

  function sourceSelected(typeID, upgradeTier) {
    if (controller != null) {
      controller.sourceSelected(typeID,
                                upgradeTier);
    }
  } //function sourceSelected

  function targetSelected(typeID) {
    if (controller != null) {
      controller.targetSelected(typeID);
    }
  } //function sourceSelected

  function hideHoverText() {
    displayHoverText.text = "";
  } //function root.hideHoverText

  function readOnlyModeDependedHoverAreaTextExtension(addLineBreak) {
    var text = addLineBreak ? "<br>" : "";
    text += readOnlyMode ? qsTrId("exaltation_forge_readonly_mode_hover_area").arg(qsTrId("exaltation_forge_transfer")) : "";
    return text;
  } //function readOnlyModeDependedInteractiveHoverAreaText

  Component {
    id: noObjecSelectedComponent
    Image {
      source: "/images/icon-questionmark.png"
    } //Image
  } //Component

  TibiaFrame2PixelUpFilledWithCaption {
    caption: qsTrId("exaltation_forge_select_transfer_items_caption")
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
        model: controller != null ? controller.sourceObjectsModel : null
        selectedTypeID: controller != null ? controller.sourceObjectTypeId : 0
        selectedUpgradeTier: controller != null ? controller.sourceObjectUpgradeTier : 0

        Component.onCompleted: {
          clicked.connect(root.sourceSelected);
          slotEntered.connect(sourceItemSelectionHoverArea.setHoverText);
          slotExited.connect(root.hideHoverText);
        } //Component.onCompleted

        MouseArea {
          id: sourceItemSelectionHoverArea
          anchors.fill: parent
          z: -1
          hoverEnabled: true

          function setHoverText() {
            var hoverText = "";
            if (!root.readOnlyMode) {
              if (itemSelectionGrid.count == 0) {
                hoverText += qsTrId("exaltation_forge_select_transfer_no_source_item_to_select_hover_area");
              } else {
                hoverText += qsTrId("exaltation_forge_select_transfer_source_item_hover_area");
              }
            }
            displayHoverText.text = hoverText + root.readOnlyModeDependedHoverAreaTextExtension(!root.readOnlyMode);
          } //function setHoverText

          onEntered: setHoverText()
          onExited: root.hideHoverText()
        } // MouseArea
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
          shouldBeChecked: controller != null ? controller.convergenceTransferEnabled : false

          onCheckedChanged: {
            if (controller != null) {
              controller.convergenceTransferEnabled = checked;
            }

          }
          onHoveredChanged: {
            if (hovered) {
              var hoverText = "";
              if (!root.readOnlyMode) {
                hoverText = qsTrId("exaltation_forge_transfer_convergence_transfer_checkbox_info");
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

      TibiaItemSelectionGrid {
        model: controller != null ? controller.targetObjectsModel : null
        selectedTypeID: controller != null ? controller.targetObjectTypeId : 0
        //electedUpgradeTier always 0

        Component.onCompleted: {
          clicked.connect(root.targetSelected);
          slotEntered.connect(targetItemSelectionHoverArea.setHoverText);
          slotExited.connect(root.hideHoverText);
        } //Component.onCompleted

        MouseArea {
          id: targetItemSelectionHoverArea
          anchors.fill: parent
          z: -1
          hoverEnabled: true

          function setHoverText() {
            var hoverText = "";
            if (!root.readOnlyMode) {
              if (controller != null && controller.sourceObjectTypeId == 0) {
                hoverText += qsTrId("exaltation_forge_select_transfer_not_source_item_select_hover_area");
              } else if (parent.count == 0) {
                hoverText += qsTrId("exaltation_forge_select_transfer_not_target_item_to_select_hover_area");
              } else {
                hoverText += qsTrId("exaltation_forge_select_transfer_target_item_hover_area");
              }
            }
            displayHoverText.text = hoverText + root.readOnlyModeDependedHoverAreaTextExtension(!root.readOnlyMode);
          } //function setHoverText

          onEntered: setHoverText()
          onExited: root.hideHoverText()
        } // MouseArea
      } //TibiaItemSelectionGrid
    } //RowLayout
  } //TibiaFrame2PixelUpFilledWithCaption

  TibiaFrame2PixelUpFilledWithCaption {
    caption: convergenceCheckbox.checked
      ? qsTrId("exaltation_forge_convergence_transfer_requirements_caption")
      : qsTrId("exaltation_forge_transfer_requirements_caption")
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
            showBackground: true
            scaleFactor: TibiaStyle.exaltationForgeItemScaleFactor
            animated: true
            smoothTextureFiltering: root.smoothTextureFiltering
            typeid: controller != null ? controller.sourceObjectTypeId : 0
            upgradeTier: controller != null ? controller.sourceObjectUpgradeTier : 0

            Loader {
              anchors.centerIn: parent
              sourceComponent: parent.typeid == 0 ?  noObjecSelectedComponent  : null
            } //Loader
          } //ScalableObjectDisplay

          TibiaCurrencyView {
            id: objectCostCurrencyView
            Layout.preferredWidth: objectDisplay.width
            rightAligned: false
            iconId: ""
            readonly property int objectCount: controller != null ? controller.sourceObjectCount : 0
            price: objectCount +"/1"
            tooLowBalance: objectCount < 1
          } //TibiaCurrencyView
        } //ColumnLayout

        MouseArea {
          anchors.fill: parent
          z: -1
          hoverEnabled: true
          onEntered: {
            var hoverText = "";
            if (!root.readOnlyMode) {
              if (objectDisplay.typeid != 0) {
                hoverText = qsTrId("exaltation_forge_selected_source_transfer_object_hover_area").arg(controller != null ? controller.sourceObjectName : qsTrId("dummy_unknown"))
                                                                                                 .arg(objectDisplay.upgradeTier);
              } else {
                if (itemSelectionGrid.count == 0) {
                  hoverText += qsTrId("exaltation_forge_select_transfer_no_source_item_to_select_hover_area");
                } else {
                  hoverText += qsTrId("exaltation_forge_no_item_selected_hover_text");
                }
              }
            }
            displayHoverText.text = hoverText + root.readOnlyModeDependedHoverAreaTextExtension(!root.readOnlyMode);
          } //onEntered
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
            price: controller != null ? controller.dustCostForTransfer : 100
            tooLowBalance: controller == null || (storeAndResourceBalanceHelper.exaltedDustBalance < controller.dustCostForTransfer)
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
               hoverText += qsTrId("exaltation_forge_transfe_dust_cost_to_expensive_hover_text").arg(dustCostCurrencyView.price);
            } else {
              hoverText += qsTrId("exaltation_forge_transfer_dust_costs_hover_area").arg(dustCostCurrencyView.price);
            }
            displayHoverText.text = hoverText + root.readOnlyModeDependedHoverAreaTextExtension(true);
          } //function setHoverText

          onEntered: setHoverText()
          onExited: root.hideHoverText()
        } // MouseArea
      } //Item

      Item {
        Layout.preferredWidth: exaltedCoreCostLayout.width
        Layout.preferredHeight: exaltedCoreCostLayout.height

        ColumnLayout {
          id: exaltedCoreCostLayout
          spacing: TibiaStyle.marginNarrow

          ScalableObjectDisplay {
            id: exaltedCoreDisplay
            showBackground: true
            scaleFactor: TibiaStyle.exaltationForgeItemScaleFactor
            animated: true
            smoothTextureFiltering: root.smoothTextureFiltering
            typeid: TibiaStyle.exaltedCoreId
          } //ScalableObjectDisplay

          TibiaCurrencyView {
            id: exaltedCoreCostCurrencyView
            Layout.preferredWidth: exaltedCoreDisplay.width
            readonly property var transferCoreCost: controller != null ? controller.transferCoreCost : 0
            price: transferCoreCost != 0 ? TextHelper.formatNumberWithThousandSeparatorsAndThousandShortcutsAsMultiString(transferCoreCost)
                                         : "???"
            tooLowBalance: controller == null
                        || (storeAndResourceBalanceHelper.exaltedCoreCount < transferCoreCost)
                        || transferCoreCost == 0

            iconId: "ExaltedCore"
          } //TibiaCurrencyView
        } //ColumnLayout

        MouseArea {
          anchors.fill: parent
          z: -1
          hoverEnabled: true

          function setHoverText() {
            var hoverText = "";
            if (!root.readOnlyMode) {
              if (objectDisplay.typeid != 0) {
                if (exaltedCoreCostCurrencyView.transferCoreCost > 1) {
                  if (exaltedCoreCostCurrencyView.tooLowBalance) {
                    hoverText += qsTrId("exaltation_forge_transfe_exalted_core_cost_to_expensive_hover_text_plural").arg(exaltedCoreCostCurrencyView.price);
                  } else {
                    hoverText += qsTrId("exaltation_forge_transfer_exalted_core_costs_hover_area_plural").arg(exaltedCoreCostCurrencyView.price);
                  }
                } else {
                  if (exaltedCoreCostCurrencyView.tooLowBalance) {
                    hoverText += qsTrId("exaltation_forge_transfe_exalted_core_cost_to_expensive_hover_text");
                  } else {
                    hoverText += qsTrId("exaltation_forge_transfer_exalted_core_costs_hover_area");
                  }
                }
              } else {
                if (itemSelectionGrid.count == 0) {
                  hoverText += qsTrId("exaltation_forge_select_transfer_no_source_item_to_select_hover_area");
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
        Layout.fillWidth: true
      } //Item

      Image {
        Layout.alignment: Qt.AlignVCenter
        source: "/images/icon-arrow-rightlarge.png"
      } //Image

      Item {
        Layout.fillWidth: true
      } //Item

      Item {
        Layout.preferredWidth: transferButtonLayout.width
        Layout.preferredHeight: transferButtonLayout.height

        ColumnLayout {
          id: transferButtonLayout
          spacing: TibiaStyle.marginNarrow

          TibiaButton {
            id: transferButton
            Layout.preferredWidth: TibiaStyle.buttonWidthWidest
            Layout.preferredHeight: exaltedCoreDisplay.height
            enabled:   !objectCostCurrencyView.tooLowBalance
                    && !dustCostCurrencyView.tooLowBalance
                    && !exaltedCoreCostCurrencyView.tooLowBalance
                    && !goldCostCurrencyView.tooLowBalance
                    && !root.readOnlyMode
                    && sourceItemObjectDisplay.typeid != 0
                    && targetItemObjectDisplay.typeid != 0

            onClicked: {
              if (controller != null) {
                controller.requestTransfer();
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
                typeid: controller != null ? controller.sourceObjectTypeId : 0
                upgradeTier: controller != null ? controller.sourceObjectUpgradeTier : 0
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
                typeid: controller != null ? controller.targetObjectTypeId : 0
                upgradeTier: controller != null ? controller.targetObjectUpgradeTier : 0
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
            readonly property var transferGoldCost: controller != null ? controller.transferGoldCost : 0
            price: transferGoldCost != 0 ? TextHelper.formatNumberWithThousandSeparatorsAndThousandShortcutsAsMultiString(transferGoldCost)
                                         : "???"
            tooLowBalance: controller == null
                        || (storeAndResourceBalanceHelper.totalGoldBalance < transferGoldCost)
                        || transferGoldCost == 0
            iconId: "GoldCoin"
          } //TibiaCurrencyView
        } //ColumnLayout

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          onEntered: {
            if (root.readOnlyMode) {
              displayHoverText.text = qsTrId("exaltation_forge_readonly_mode_hover_button")
            } else if (   sourceItemObjectDisplay.typeid == 0
                       || targetItemObjectDisplay.typeid == 0) {
              displayHoverText.text = qsTrId("exaltation_forge_select_source_and_target_transfer_objects_hover_area")
            } else if (   dustCostCurrencyView.tooLowBalance
                       || exaltedCoreCostCurrencyView.tooLowBalance
                       || goldCostCurrencyView.tooLowBalance) {
              displayHoverText.text = qsTrId("exaltation_forge_transfer_resources_need_objects_hover_area")
            } else {
              displayHoverText.text = qsTrId("exaltation_forge_request_transfer_hover_area")
            }
          } //onEntered
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

    TibiaText {
      anchors { left: parent.left; top: parent.top; right: parent.right }
      anchors.margins: TibiaStyle.marginRelated + parent.borderWidth
      wrapMode: Text.Wrap
      textFormat: Text.RichText
      visible: displayHoverText.text == ""
      text: convergenceCheckbox.checked
        ? qsTrId("exaltation_forge_transfer_what_is_convergence_transfer")
        : qsTrId("exaltation_forge_transfer_what_is_transfer")
    } //TibiaText
  } //TibiaFrame2PixelUpFilled
} //ColumnLayout
