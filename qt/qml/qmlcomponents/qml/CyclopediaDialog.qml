import QtQuick
import QtQuick.Layouts
import qmlcomponents
import qmlenumvalues



TibiaDialog {
  id: root
  caption: qsTrId("cyclopedia_dialog_caption")
  width: 700

  required property var controller
  property var itemInfoController: controller.itemInfoDialogController
  property var monstersController: controller.monstersDialogController
  property var characterInfoController: controller.characterInfoDialogController
  property var bonusEffectsController: controller.bonusEffectsDialogController
  property var mapController: controller.mapDialogController
  property var housesInfoController: controller.housesDialogController
  property var bosstiaryController: controller.bosstiaryDialogController
  property var bossSlotsController: controller.bossSlotsDialogController
  property var magicalArchiveController: controller.magicalArchiveDialogController
  property var activeTab: controller.dialogTab

  initialFocusItem: topButtonBar
  KeyNavigation.tab: topButtonBar
  KeyNavigation.backtab: topButtonBar

  onReturnPressedFunction: function() {
  }

  onCancelPressedFunction: function() {
    if (controller != null) {
      controller.requestClose();
    }
  }

  function onBackPressedFunction() {
    if (controller != null) {
      controller.requestBack();
    }
  }

  function onManageQuickLootClickedFunction() {
    if (controller != null) {
      controller.requestOpenManageQuickLootDialog();
    }
  } //onManageQuickLootClickedFunction

  onActiveTabChanged: {
    if (activeTab == CyclopediaDialogController.ItemInfo) {
      contentLoader.setSource("ItemInfoDialog.qml",
        {"controller": root.itemInfoController})
    } else if (activeTab == CyclopediaDialogController.Monsters) {
      contentLoader.setSource("MonstersDialog.qml",
        {"controller": root.monstersController})
    } else if (activeTab == CyclopediaDialogController.BonusEffects) {
      contentLoader.setSource("MonsterBonusEffectsDialog.qml",
        {"controller": root.bonusEffectsController})
    } else if (activeTab == CyclopediaDialogController.Map) {
      contentLoader.setSource("CyclopediaMapDialog.qml",
        {"controller": root.mapController})
    } else if (activeTab == CyclopediaDialogController.CharacterInfo) {
      contentLoader.setSource("CharacterInfoDialog.qml",
        {"controller": root.characterInfoController})
    } else if (activeTab == CyclopediaDialogController.Houses) {
      contentLoader.setSource("HousesInfoDialog.qml",
        {"controller": root.housesInfoController})
    } else if (activeTab == CyclopediaDialogController.Bosstiary) {
      contentLoader.setSource("BosstiaryDialog.qml",
        {"controller": root.bosstiaryController})
    } else if (activeTab == CyclopediaDialogController.BossSlots) {
      contentLoader.setSource("BossSlotsDialog.qml",
        {"controller": root.bossSlotsController})
    } else if (activeTab == CyclopediaDialogController.MagicalArchive) {
      contentLoader.setSource("MagicalArchiveDialog.qml",
        {"controller": root.magicalArchiveController})
    } else {
      contentLoader.source = "";
    }
  } //onActiveTabChanged

  TibiaDialogTabBar {
    id: topButtonBar
    anchors { left: parent.left; top: parent.top; right: parent.right; }

    activeTabId: activeTab
    buttonImageXOffset: 5
    compactStyle: true
    activeTabWidth: TibiaStyle.dialogTabBarWiderWidth

    onRequestedTabIdChanged: {
      if (controller != null) {
        controller.requestTabSwitch(requestedTabId);
      }
    } //onRequestedTabIdChanged

    tabModel: [
      {
        "tabId": CyclopediaDialogController.ItemInfo,
        "caption": qsTrId("cyclopedia_items_function"),
        "tooltip": qsTrId("cyclopedia_items_function"),
        "icon": "/images/icon-cyclopedia-iteminfo.png"
      }
      , {
        "tabId": CyclopediaDialogController.Monsters,
        "caption": qsTrId("cyclopedia_monsters_function"),
        "tooltip": qsTrId("cyclopedia_monsters_function"),
        "icon": "/images/icon-cyclopedia-monsterinfo.png"
      }
      , {
        "tabId": CyclopediaDialogController.BonusEffects,
        "caption":qsTrId("cyclopedia_bonuseffects_function"),
        "tooltip": qsTrId("cyclopedia_bonuseffects_function"),
        "icon": "/images/icon-cyclopedia-monsterbonusinfo.png"
      }
      , {
        "tabId": CyclopediaDialogController.Map,
        "caption": qsTrId("cyclopedia_map_function"),
        "tooltip": qsTrId("cyclopedia_map_function"),
        "icon": "/images/icon-cyclopedia-map.png"
      }
      , {
        "tabId": CyclopediaDialogController.Houses,
        "caption": qsTrId("cyclopedia_houses_function"),
        "tooltip": qsTrId("cyclopedia_houses_function"),
        "icon": "/images/icon-cyclopedia-houses.png"
      }
      , {
        "tabId": CyclopediaDialogController.CharacterInfo,
        "caption": qsTrId("character"),
        "tooltip": qsTrId("character"),
        "icon": "/images/icon-cyclopedia-characterinfo.png"
      }
      , {
        "tabId": CyclopediaDialogController.Bosstiary,
        "caption": qsTrId("cyclopedia_bosstiary_function"),
        "tooltip": qsTrId("cyclopedia_bosstiary_function"),
        "icon": "/images/icon-cyclopedia-bosstiary.png"
      }
      , {
        "tabId": CyclopediaDialogController.BossSlots,
        "caption": qsTrId("cyclopedia_bossslots_function"),
        "tooltip": qsTrId("cyclopedia_bossslots_function"),
        "icon": "/images/icon-cyclopedia-bossslots.png"
      }
      , {
        "tabId": CyclopediaDialogController.MagicalArchive,
        "caption": qsTrId("cyclopedia_magicalarchive_function"),
        "tooltip": qsTrId("cyclopedia_magicalarchive_function"),
        "icon": "/images/icon-cyclopedia-magicalarchive.png"
      }
    ] //tabModel
  } //TibiaDialogTabBar

  Item {
    id: contentArea
    height: 420
    anchors { top: topButtonBar.bottom; topMargin: TibiaStyle.marginRelated;
              left: parent.left; right: parent.right; }

    Loader {
      id: contentLoader
      anchors.fill: parent

      onLoaded: {
        if (item.initialFocusItem) {
          item.initialFocusItem.forceActiveFocus();
        }
        if (item.hasOwnProperty("onCancelPressedFunction")) {
          item.onCancelPressedFunction = root.onCancelPressedFunction;
        }
        if (item.hasOwnProperty("needsTabNavigation")) {
          topButtonBar.tabShortcutsActive = Qt.binding(function() { return !(item != null && item.needsTabNavigation); });
        } else {
          topButtonBar.tabShortcutsActive = true;
        }
      }
    } // Loader
  } // Item

  ColumnLayout {
    id: buttonLayout
    spacing: TibiaStyle.marginUnrelated
    anchors { left: parent.left; right: parent.right; top: contentArea.bottom; }

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } // TibiaHorizontalSeparator

    RowLayout {
      id: buttonBar
      Layout.fillWidth: true
      spacing: TibiaStyle.marginRelated

      TibiaCurrentBalanceView {
        Layout.preferredWidth: TibiaStyle.currencyViewWidthLong
        visible: activeTab == CyclopediaDialogController.Monsters
              || activeTab == CyclopediaDialogController.BonusEffects
              || activeTab == CyclopediaDialogController.Map
              || activeTab == CyclopediaDialogController.CharacterInfo
              || activeTab == CyclopediaDialogController.BossSlots
        balanceType: "GoldCoin"
      } //TibiaCurrentBalanceView

      TibiaCurrencyView {
        Layout.preferredWidth: TibiaStyle.currencyViewWidthLong
        visible: activeTab == CyclopediaDialogController.Monsters
              || activeTab == CyclopediaDialogController.BonusEffects
              || activeTab == CyclopediaDialogController.CharacterInfo
        balance: controller != null
            ? controller.availableCharmPointsString + " / " + controller.unlockedCharmPointsString
            : "-"
        rightAligned: true
        iconId: "MonsterBonusPoints"
      } //TibiaCurrencyView

      TibiaCurrencyView {
        Layout.preferredWidth: TibiaStyle.currencyViewWidthLong
        visible: activeTab == CyclopediaDialogController.Monsters
              || activeTab == CyclopediaDialogController.BonusEffects
              || activeTab == CyclopediaDialogController.CharacterInfo
        balance: controller != null
            ? controller.availableMinorCharmEchoesString + " / " + controller.unlockedMinorCharmEchoesString
            : "-"
        rightAligned: true
        iconId: "MinorCharmEchoes"
      } //TibiaCurrencyView

      TibiaButton {
        Layout.preferredWidth: TibiaStyle.buttonWidthWidest
        visible: activeTab == CyclopediaDialogController.ItemInfo
        text: qsTrId("managecontainer_caption")
        onClicked: onManageQuickLootClickedFunction()
      } //TibiaButton

      TibiaCurrentBalanceView {
        Layout.preferredWidth: TibiaStyle.currencyViewWidthLong
        visible: activeTab == CyclopediaDialogController.Houses
        balanceType: "BankGoldCoin"
      } //TibiaCurrentBalanceView

      TibiaCurrentBalanceView {
        Layout.preferredWidth: TibiaStyle.currencyViewWidthLong
        visible: storeAndResourceBalanceHelper.hasGuildBankGoldBalance
              && activeTab == CyclopediaDialogController.Houses
        balanceType: "GuildBankGoldCoin"
      } //TibiaCurrentBalanceView

      TibiaButton {
        id: bestiaryTrackerButton
        Layout.preferredWidth: TibiaStyle.buttonWidthWide
        visible: activeTab == CyclopediaDialogController.Monsters
        text: qsTrId("monsters_open_tracker")

        onClicked: {
          if (monstersController != null) {
            monstersController.requestOpenBestiaryTrackerWidget();
          }
        }
      } // TibiaButton

      TibiaButton {
        id: assignSpellToActionBarButton
        Layout.preferredWidth: 169 // manual width so that the button has the same width as the magical archive spelllist
        visible: activeTab == CyclopediaDialogController.MagicalArchive
        text: qsTrId("magicalarchive_assign_spell")
        enabled: magicalArchiveController != null && magicalArchiveController.isValidSpellSelected

        onClicked: {
          if (magicalArchiveController != null) {
            magicalArchiveController.requestAssignSpellToActionButton();
          }
        }
      } // TibiaButton

      TibiaCheckBox {
        text: qsTrId("magicalarchive_check_aimt_at_target")
        visible: activeTab == CyclopediaDialogController.MagicalArchive && magicalArchiveController && magicalArchiveController.isAimAtTargetSpellSelected
        shouldBeChecked: controller && magicalArchiveController.isAimAtTargetSpellSelectedAndActivated

        onCheckedChanged: {
          if (magicalArchiveController != null) {
            magicalArchiveController.requestAimAtTargetOptionChange(checked);
          }
        }
      } // TibiaCheckBox

      Item {
        // Padding
        Layout.fillWidth: true
        height: 1
      } //Item

      TibiaButton {
        visible: activeTab == CyclopediaDialogController.Houses
        text: qsTrId("refresh")
        onClicked: root.housesInfoController != null ? root.housesInfoController.refresh() : undefined
      } //TibiaButton

      TibiaButton {
        enabled: controller != null && controller.backPossible
        text: qsTrId("back")
        onClicked: onBackPressedFunction()
      } //TibiaButton

      TibiaButton {
        text: qsTrId("close")
        onClicked: onCancelPressedFunction()
      } //TibiaButton
    } // RowLayout
  } // ColumnLayout
} // TibiaDialog
