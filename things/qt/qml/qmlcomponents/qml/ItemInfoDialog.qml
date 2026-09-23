import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QtQuick.LegacyControls


Item {
  id: root
  property var controller: null
  property bool itemSelected: controller != null && controller.hasItemSelected
  property var initialFocusItem: itemSelection.nameFilterField
  property var onCancelPressedFunction: null
  KeyNavigation.tab: itemSelection.nameFilterField
  KeyNavigation.backtab: itemSelection.nameFilterField

  Connections {
    target: controller

    function onCategoryListSelectionRequest(Index) {
      if (Index > -1) {
        itemSelection.selectCategoryIndex(Index);
      }
    } // onCategoryListSelectionRequest

    function onItemListSelectionRequest(Index) {
      if (Index > -1) {
        itemSelection.selectItemIndex(Index);
      }
    } // onItemListSelectionRequest

    function onFilterOptionsUpdateRequest(levelFilterButtonShouldBeChecked,
                                      vocationFilterButtonShouldBeChecked,
                                      oneHandFilterButtonShouldBeChecked,
                                      twoHandFilterButtonShouldBeChecked) {
      itemSelection.levelFilterButtonShouldBeChecked = levelFilterButtonShouldBeChecked;
      itemSelection.vocationFilterButtonShouldBeChecked = vocationFilterButtonShouldBeChecked;
      itemSelection.oneHandFilterButtonShouldBeChecked = oneHandFilterButtonShouldBeChecked;
      itemSelection.twoHandFilterButtonShouldBeChecked = twoHandFilterButtonShouldBeChecked;
    } //function onFilterOptionsUpdateRequest(...)

    function onSetNameFilterRequest(NameFilter) {
      itemSelection.setNameFilter(NameFilter);
    } //function onSetNameFilterRequest(NameFilter)
  }

  MarketCategorySelection {
    id: itemSelection
    anchors { left: parent.left; top: parent.top; }
    height: 350
    useObjectCount: false
    categoryViewHeight: TibiaStyle.cyclopediaObjectCategoryViewHeight

    categoryModel: controller != null ? controller.categories : null
    categoryItemModel: controller != null ? controller.appearanceTypeListModel : null

    enableTierAndClassificationSelection : controller != null ? controller.enableTierAndClassificationSelection : false
    enableTierSelection : false
    availableTiers: null
    indexOfSelectedTier: -1
    showTierFilter: false
    availableClassifications: controller != null ? controller.availableClassifications : null
    indexOfSelectedClassification: controller != null ? controller.indexOfSelectedClassification : -1

    Connections {
      function onCategorySelected(CategoryIdentifier, FilterByLevel, FilterByVocation, OnlyOneHandWeapons, OnlyTwoHandWeapons) {
        controller != null ? controller.requestCategorySelect(CategoryIdentifier, FilterByLevel, FilterByVocation, OnlyOneHandWeapons, OnlyTwoHandWeapons) : null
      }
      function onFilterSelected(NameFilter, FilterByLevel, FilterByVocation, OnlyOneHandWeapons, OnlyTwoHandWeapons, ShowLockerOnly) {
        controller != null ? controller.requestNameSelect(NameFilter, FilterByLevel, FilterByVocation, OnlyOneHandWeapons, OnlyTwoHandWeapons) : null
      }
      function onItemSelected(AppearanceId, UpgradeTier) {
        controller != null ? controller.requestItemSelect(AppearanceId) : null
      }
      function onEscPressedInSearchTextField() {
        root.onCancelPressedFunction != null ? root.onCancelPressedFunction() : null
      }
      function onClassificationFilterWasSelected(CurrentIndex, NameFilter, FilterByLevel, FilterByVocation, OnlyOneHandWeapons, OnlyTwoHandWeapons, ShowLockerOnly) {
        controller != null ? controller.onClassificationFilterWasSelected(CurrentIndex, NameFilter, FilterByLevel, FilterByVocation, OnlyOneHandWeapons, OnlyTwoHandWeapons, ShowLockerOnly) : null
      }
    } //Connections
  } // MarketCategorySelection

  ColumnLayout {
    id: pricingLayout
    anchors { horizontalCenter: itemSelection.horizontalCenter; top: itemSelection.bottom; topMargin: TibiaStyle.marginUnrelated; }
    opacity: itemSelected ? 1 : 0;

    TibiaText {
      text: qsTrId("iteminfo_pricing_caption")
    } // TibiaText

    ButtonGroup {
      id: priceGroup
      onCheckedButtonChanged: {
        if (controller != null && checkedButton != null) {
          controller.requestPrimaryLootValueSelect(checkedButton == npcPriceValueSelect ? 0 : 1);
        }
      }
    } // ButtonGroup

    TibiaRadioButton {
      id: npcPriceValueSelect
      property bool controllerChecked: controller != null && controller.primaryLootValueSource == 0
      text: qsTrId("iteminfo_pricing_npc")
      ButtonGroup.group: priceGroup

      onControllerCheckedChanged: {
        if (controllerChecked != checked) {
          checked = controllerChecked;
        }
      }
    } // TibiaRadioButton

    TibiaRadioButton {
      id: marketPriceValueSelect
      property bool controllerChecked: controller != null && controller.primaryLootValueSource == 1
      text: qsTrId("iteminfo_pricing_market")
      ButtonGroup.group: priceGroup

      onControllerCheckedChanged: {
        if (controllerChecked != checked) {
          checked = controllerChecked;
        }
      }
    } // TibiaRadioButton
  } // ColumnLayout

  TibiaVerticalSeparator {
    id: verticalSeparator
    anchors { top: parent.top; left: itemSelection.right; leftMargin: TibiaStyle.marginUnrelated; bottom: parent.bottom; }
  }

  ColumnLayout {
    id: mainContentLayout
    anchors { top: parent.top; left: verticalSeparator.right; leftMargin: TibiaStyle.marginUnrelated; right: parent.right; }
    spacing: TibiaStyle.marginRelated

    TibiaText {
      text: itemSelected ? qsTrId("iteminfo_inspect_caption") : qsTrId("iteminfo_no_item_selected")
      Layout.fillWidth: true
      wrapMode: Text.Wrap
    } //TibiaText

    TibiaTextArea {
      Layout.fillWidth: true
      Layout.preferredHeight: 150
      readOnly: true
      wrapMode: TextEdit.Wrap
      textFormat: TextEdit.RichText
      text: controller != null && controller.inspectData != null ? controller.inspectData.objectInformation : ""
      visible: itemSelected
    } // TibiaTextArea

    Item {
      // Padding
      Layout.preferredHeight: 0
      Layout.fillWidth: true
      visible: itemSelected

      TibiaButton {
        anchors.top: parent.top
        anchors.topMargin: TibiaStyle.marginNarrow - mainContentLayout.spacing
        anchors.right: parent.right
        width: TibiaStyle.iconButtonSize
        height: TibiaStyle.iconButtonSize

        imageSource: "/images/icon-proficiencytree-open.png"
        tooltipText: qsTrId("buttonbar_weapon_proficiency_open_tooltip")

        visible: controller?.hasWeaponProficiency

        onClicked: {
          if (controller != null) {
            controller.onWeaponProficiencyDialogButtonClicked();
          }
        } //onClicked
      } //TibiaButton
    } //Item

    GridLayout {
      columns: 2
      visible: itemSelected

      TibiaText {
        text: qsTrId("iteminfo_npc_buy_header")
      }

      TibiaText {
        text: qsTrId("iteminfo_npc_sell_header")
      }

      TibiaTableView {
        Layout.fillWidth: true
        Layout.preferredHeight: 100
        alternatingRowColors: true

        model: controller != null ? controller.npcBuyData : null
        TableViewColumn {}

        rowDelegate: Rectangle {
          height: 28
          color: styleData.selected ? TibiaStyle.tableViewSelectionColor : (styleData.alternate ? TibiaStyle.tableViewAlternateBackgroundColor : TibiaStyle.tableViewItemBackgroundColor)
        } // rowDelegate
      } // TibiaTableView

      TibiaTableView {
        Layout.fillWidth: true
        Layout.preferredHeight: 100
        alternatingRowColors: true

        model: controller != null ? controller.npcSellData : null
        TableViewColumn {}

        rowDelegate: Rectangle {
          height: 28
          color: styleData.selected ? TibiaStyle.tableViewSelectionColor : (styleData.alternate ? TibiaStyle.tableViewAlternateBackgroundColor : TibiaStyle.tableViewItemBackgroundColor)
        } // rowDelegate
      } // TibiaTableView
    } // GridLayout

    Item {
      Layout.preferredHeight: TibiaStyle.marginUnrelated
      visible: itemSelected
    }

    ColumnLayout {
      spacing: 0
      RowLayout {
        visible: itemSelected

        TibiaText {
          text: qsTrId("iteminfo_market_average")
        }

        Item {
          Layout.fillWidth: true
        }

        TibiaCurrencyView {
          Layout.preferredWidth: TibiaStyle.currencyViewWidth
          balance: controller != null ? controller.marketValueString : qsTrId("dummy_unknown")
          rightAligned: true
          iconId: "GoldCoin"
        } //TibiaCurrencyView
      } // RowLayout

      RowLayout {
        visible: itemSelected

        TibiaText {
          text: qsTrId("iteminfo_custom_loot_value")
        }

        Item {
          Layout.fillWidth: true
        }

        TibiaButton {
          Layout.preferredHeight: customValueText.height
          Layout.preferredWidth: TibiaStyle.buttonWidthStoreSmall
          color: "blue"
          imageSource: "/images/icon-store-16x10.png"
          onClicked: { if (controller != null) controller.requestOpenStoreWithPremiumTime(); }
          tooltipText: qsTrId("iteminfo_custom_value_needs_premium")
          visible: controller != null && !controller.isPremium
        } //TibiaIconButton

        TibiaTextField {
          id: customValueText
          property string userDefinedValueFromController: controller != null
                            ? controller.userDefinedValueString != "0" ? controller.userDefinedValueString : ""
                            : qsTrId("dummy_unknown")

          implicitHeight: TibiaStyle.currencyViewHeight
          implicitWidth: TibiaStyle.currencyViewWidth
          validator: RegularExpressionValidator { regularExpression: /[0-9]*/; }
          maximumLength: 9
          horizontalAlignment: TextInput.AlignRight
          text: ""
          enabled: controller != null && controller.isPremium
          rightPadding: 12
          placeholderText: qsTrId("insert_own_lootvalue_placeholder")

          onTextChanged: {
            if (controller != null) {
              controller.requestCustomSaleValue(text);
            }
          } //onTextChanged

          onEditingFinished: {
            if (controller != null) {
              controller.requestCustomSaleValue(text);
            }
          }

          onUserDefinedValueFromControllerChanged: {
            // This "indirect" binding works around a bug that magically prevents direct bindings on the 'text' property
            text = userDefinedValueFromController;
          }
        } // TibiaTextField
      } // RowLayout

      RowLayout {
        visible: itemSelected

        TibiaText {
          text: qsTrId("iteminfo_loot_value")
        }

        Item {
          Layout.fillWidth: true
        }

        TibiaCurrencyView {
          Layout.preferredWidth: TibiaStyle.currencyViewWidth
          balance: controller != null ? controller.lootValueString : qsTrId("dummy_unknown")
          rightAligned: true
          iconId: "GoldCoin"

          Loader {
            Component {
              id: lootvalueImageUnderItemComponent
              BorderImage {
                id: glowingborders
                source: controller != null ? controller.lootValueBackgroundUrlSource : ""
                border {left: 7; right: 7; top: 7; bottom: 7}
              }
            }
            anchors.fill: parent
            anchors.margins: 1
            sourceComponent: controller != null && controller.lootValueBackgroundUrlSource != "" ? lootvalueImageUnderItemComponent : undefined
          }
        } //TibiaCurrencyView
      } // RowLayout
    }

    Item {
      visible: itemSelected
      Layout.preferredHeight: TibiaStyle.marginUnrelated
    }

    RowLayout {
      visible: itemSelected

      TibiaCheckBox {
        id: trackingCheckbox
        property bool checkedFromController: controller != null ? controller.isTracked : false
        property bool preventControllerUpdate: false
        text: qsTrId("iteminfo_notify_on_drop")
        enabled: controller != null && (controller.canTrackAdditionalItems || checked)

        onCheckedChanged: {
          if (controller && !preventControllerUpdate) {
            controller.requestItemTracking(checked);
          }
        }

        onCheckedFromControllerChanged: {
          if (checkedFromController != checked) {
            preventControllerUpdate = true;
            checked = checkedFromController;
            preventControllerUpdate = false;
          }
        }
      } // TibiaCheckBox

      TibiaGuiHelp {
        visible: !trackingCheckbox.enabled
        text: qsTrId("iteminfo_maximum_number_of_tracked_items")
        color: "red"
      } //TibiaGuiHelp

      Item {
        Layout.fillWidth: true
      }

      TibiaCheckBox {
        id: lootBlackWhitelistCheckbox
        property bool checkedFromController: controller != null ? controller.isLootBlackWhitelisted : false
        property bool preventControllerUpdate: false
        text: controller != null && controller.blackWhiteListType == 1 ?
          qsTrId("iteminfo_whitelist_item") : qsTrId("iteminfo_blacklist_item")
        enabled: controller != null && (controller.canBlackWhitelistAdditionalItems || checked)

        onCheckedChanged: {
          if (controller && !preventControllerUpdate) {
            controller.requestItemBlackWhitelisting(checked);
          }
        }

        onCheckedFromControllerChanged: {
          if (checkedFromController != checked) {
            preventControllerUpdate = true;
            checked = checkedFromController;
            preventControllerUpdate = false;
          }
        }
      } // TibiaCheckBox

      TibiaGuiHelp {
        visible: !lootBlackWhitelistCheckbox.enabled
        text: qsTrId("iteminfo_maximum_number_of_blacklisted_items")
        color: "red"
      } //TibiaGuiHelp
    } // RowLayout
  } // ColumnLayout
} // TibiaDialog
