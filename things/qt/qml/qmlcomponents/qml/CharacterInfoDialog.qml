import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qmlcomponents
import qmlenumvalues

import QtQuick.LegacyControls

Item {
  id: characterInfoDialog
  required property var controller
  property var achievementController: controller.achievementsController
  property bool dataIsLoading: controller.dataIsLoading

  property var initialFocusItem: characterInfoDialog
  KeyNavigation.tab: characterInfoDialog

  property var itemSummary: controller.itemSummary

  function computeTotalBasedOnSelection(model) {
   var totalOfSelection = 0;
   if (itemSummary != null && model != null) {
     if (itemSummary.showInventory) {
       totalOfSelection += model.inventoryAmount;
     }
     if (itemSummary.showStash) {
       totalOfSelection += model.stashAmount;
     }
     if (itemSummary.showDepot) {
       totalOfSelection += model.depotAmount;
     }
     if (itemSummary.showInbox) {
       totalOfSelection += model.inboxAmount;
     }
     if (itemSummary.showStoreInbox) {
       totalOfSelection += model.storeInboxAmount;
     }
   }
   return totalOfSelection;
  }

  TibiaFrame2PixelUpFilledWithCaption {
    id: characterBox

    property var baseInfo: controller != null ? controller.characterBaseInfo : null

    caption: baseInfo != null ? baseInfo.name : qsTrId("charinfo_character_loading")
    width: charInfoMenu.width
    height: topMarginToContent + characterBoxLayout.height + marginsToContent

    ColumnLayout {
      id: characterBoxLayout
      anchors { left: parent.left; top: parent.top; right: parent.right;
                leftMargin: parent.marginsToContent; topMargin: parent.topMarginToContent; rightMargin: parent.marginsToContent; }
      spacing: 0 //TibiaStyle.marginNarrow is to high to fit all menu entries

      TibiaText {
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        text: characterBox.baseInfo != null ? characterBox.baseInfo.title : ""
        maximumLineCount: 2
        wrapMode: Text.Wrap
        visible: text.length > 0
      } //TibiaText

      Item {
        Layout.preferredHeight: 2 * TibiaStyle.mapWindowPixelPerField
        Layout.preferredWidth: 2 * Layout.preferredHeight
        Layout.alignment: Qt.AlignHCenter

        OutfitAppearanceInstanceRenderer {
          id: appearanceInstanceRenderer
          anchors.fill: parent

          outfitId: characterBox.baseInfo != null ? characterBox.baseInfo.outfitID : 0
          headColor: characterBox.baseInfo != null ? characterBox.baseInfo.headColor : "black"
          torsoColor: characterBox.baseInfo != null ? characterBox.baseInfo.torsoColor : "black"
          legsColor: characterBox.baseInfo != null ? characterBox.baseInfo.legsColor : "black"
          detailColor: characterBox.baseInfo != null ? characterBox.baseInfo.detailColor : "black"
          firstAddOn: characterBox.baseInfo != null ? characterBox.baseInfo.firstAddon : false
          secondAddOn: characterBox.baseInfo != null ? characterBox.baseInfo.secondAddon : false
        } //OutfitAppearanceInstanceRendere

        Image {
          anchors.centerIn: parent
          anchors.verticalCenterOffset: parent.captionHeight / 2
          source: "/images/unknownoutfit.png"
          visible: characterBox.baseInfo == null || characterBox.baseInfo.outfitID == 0
        } //Image
      } //Item

      TibiaText {
        Layout.alignment: Qt.AlignHCenter
        text: characterBox.baseInfo != null ?  qsTrId("charinfo_level").arg(characterBox.baseInfo.level) : ""
      } //TibiaText

      TibiaText {
        Layout.alignment: Qt.AlignHCenter
        text: characterBox.baseInfo != null ? characterBox.baseInfo.vocation : ""
      } //TibiaText
    } //ColumnLayout

    MouseArea {
      anchors.fill: parent
      z: -1
      hoverEnabled: true

      onClicked: {
        if (controller != null) {
          controller.setDialogCategory(CharacterInfoDialogController.InspectCharacter);
        }
      } //onClicked

      onEntered: {
        if (tibiaMouseCursorController != null) {
          tibiaMouseCursorController.setPointingHand(true)
        }
      } //onEntered

      onExited: {
        if (tibiaMouseCursorController != null) {
          tibiaMouseCursorController.setDefaultCursor()
        }
      } //onExited

    } //MouseArea

  } //TibiaFrame2PixelUpFilledWithCaption

  TibiaFrame2PixelUpFilled {
    id: charInfoMenu
    width: 150 + 2 * margin
    readonly property int margin: borderWidth + TibiaStyle.marginRelated
    dark: true
    anchors { left: parent.left; top: characterBox.bottom; topMargin: TibiaStyle.marginRelated;
              bottom: parent.bottom; bottomMargin: TibiaStyle.marginRelated }

    Layout.fillHeight: true

    ColumnLayout {
      anchors { left: parent.left; top: parent.top; right: parent.right }
      anchors.margins: parent.margin
      spacing: 3

      MenuWithSubMenu {
        Layout.fillWidth: true
        controller: characterInfoDialog.controller
        textHorizontalAlignment: Text.AlignLeft
        textXOffset: TibiaStyle.marginUnrelated * 2 + TibiaStyle.marginNarrow

        categories: ListModel {
          ListElement { categoryName: qsTrId("charinfo_generalstats")
                        categoryId: CharacterInfoDialogController.StatsMainMenu
                        categoryImageUrl: "/images/icon-character-generalstats.png" }
          ListElement { categoryName: qsTrId("charinfo_overview")
                        categoryId: CharacterInfoDialogController.GeneralStats
                        categoryImageUrl: "/images/icon-character-generalstats-overview.png" }
          ListElement { categoryName: qsTrId("charinfo_offencestats")
                        categoryId: CharacterInfoDialogController.OffenceStats
                        categoryImageUrl: "/images/icon-character-generalstats-offence.png" }
          ListElement { categoryName: qsTrId("charinfo_defencestats")
                      categoryId: CharacterInfoDialogController.DefenceStats
                      categoryImageUrl: "/images/icon-character-generalstats-defence.png" }
          ListElement { categoryName: qsTrId("charinfo_miscstats")
                      categoryId: CharacterInfoDialogController.MiscStats
                      categoryImageUrl: "/images/icon-character-generalstats-misc.png" }
        } //categories: ListModel
      } //MenuWithSubMenu

      MenuWithSubMenu {
        Layout.fillWidth: true
        controller: characterInfoDialog.controller
        textHorizontalAlignment: Text.AlignLeft
        textXOffset: TibiaStyle.marginUnrelated * 2 + TibiaStyle.marginNarrow


        categories: ListModel {
          ListElement { categoryName: qsTrId("charinfo_battleresults")
                        categoryId: CharacterInfoDialogController.BattleMainMenu
                        categoryImageUrl: "/images/icon-character-battleresults.png" }
          ListElement { categoryName: qsTrId("charinfo_recentdeaths")
                        categoryId: CharacterInfoDialogController.Deaths
                        categoryImageUrl: "/images/icon-character-battleresults-recentdeaths.png" }
          ListElement { categoryName: qsTrId("charinfo_recentkills")
                        categoryId: CharacterInfoDialogController.Kills
                        categoryImageUrl: "/images/icon-character-battleresults-recentpvpkills.png" }
        } //categories: ListModel
      } //MenuWithSubMenu

      MenuWithSubMenu {
        Layout.fillWidth: true
        controller: characterInfoDialog.controller
        textHorizontalAlignment: Text.AlignLeft
        textXOffset: TibiaStyle.marginUnrelated * 2 + TibiaStyle.marginNarrow


        categories: ListModel {
          ListElement { categoryName: qsTrId("charinfo_achievements")
                        categoryId: CharacterInfoDialogController.Achievements
                        categoryImageUrl: "/images/icon-character-achievement.png" }
        } //categories: ListModel
      } //MenuWithSubMenu

      MenuWithSubMenu {
        Layout.fillWidth: true
        controller: characterInfoDialog.controller
        textHorizontalAlignment: Text.AlignLeft
        textXOffset: TibiaStyle.marginUnrelated * 2 + TibiaStyle.marginNarrow


        categories: ListModel {
          ListElement { categoryName: qsTrId("charinfo_itemsummary")
                        categoryId: CharacterInfoDialogController.Items
                        categoryImageUrl: "/images/icon-character-items.png" }
        } //categories: ListModel
      } //MenuWithSubMenu

      MenuWithSubMenu {
        Layout.fillWidth: true
        controller: characterInfoDialog.controller
        textHorizontalAlignment: Text.AlignLeft
        textXOffset: TibiaStyle.marginUnrelated * 2 + TibiaStyle.marginNarrow


        categories: ListModel {
          ListElement { categoryName: qsTrId("charinfo_outfitmountsummonskinssummary")
                        categoryId: CharacterInfoDialogController.OutfitsMountsSummonSkins
                        categoryImageUrl: "/images/icon-character-outfitsmounts.png" }
        } //categories: ListModel
      } //MenuWithSubMenu

      MenuWithSubMenu {
        Layout.fillWidth: true
        controller: characterInfoDialog.controller
        textHorizontalAlignment: Text.AlignLeft
        textXOffset: TibiaStyle.marginUnrelated * 2 + TibiaStyle.marginNarrow

        visible: controller != null && controller.characterBaseInfo != null && controller.characterBaseInfo.isOwnCharacter

        categories: ListModel {
          ListElement { categoryName: qsTrId("charinfo_storesummary")
                        categoryId: CharacterInfoDialogController.StorePurchases
                        categoryImageUrl: "/images/icon-character-store.png" }
        } //categories: ListModel
      } //MenuWithSubMenu

      MenuWithSubMenu {
        Layout.fillWidth: true
        controller: characterInfoDialog.controller
        textHorizontalAlignment: Text.AlignLeft
        textXOffset: TibiaStyle.marginUnrelated * 2 + TibiaStyle.marginNarrow

        visible: controller != null && controller.characterBaseInfo != null && controller.characterBaseInfo.isOwnCharacter

        categories: ListModel {
          ListElement { categoryName: qsTrId("charinfo_titels")
                        categoryId: CharacterInfoDialogController.Titles
                        categoryImageUrl: "/images/icon-character-titles.png" }
        } //categories: ListModel
      } //MenuWithSubMenu
    } //ColumnLayout
  } //TibiaFrame2PixelUpFilled

  Component {
    id: generalStatsComponent

    TibiaFrame1PixelDown {
      property var accountInfos: controller != null && controller.accountInfos != null ? controller.accountInfos : null

      ColumnLayout {
        id: firstStatBlock
        width: parent.width / 2 - TibiaStyle.marginRelated * 2
        anchors { left: parent.left; top: parent.top }
        anchors.margins: TibiaStyle.marginRelated

        Repeater {
          model: controller != null ? controller.characterStatsFirstBlock : null;

          SkillWidgetEntry {
            Layout.fillWidth: true

            Component.onCompleted: {
              skillModelData = modelData;
              openStoreXpBoostFunction = function() {
                if (controller != null) {
                  controller.openStoreWithXpBoostCategory();
                }
              }
            }
          }
        } // Repeater
      } // ColumnLayout

      ColumnLayout {
        width: parent.width / 2 - TibiaStyle.marginRelated * 2
        anchors { left: parent.left; top: firstStatBlock.bottom }
        anchors.margins: TibiaStyle.marginRelated
        visible: accountInfos != null && accountInfos.canShowAccountInfos

        TibiaHorizontalSeparator {
          Layout.topMargin: TibiaStyle.marginRelated
          Layout.bottomMargin: TibiaStyle.marginRelated
          Layout.fillWidth: true
        } //TibiaHorizontalSeparator

        RowLayout {
          TibiaText {
            text: qsTrId("charinfo_account_status")
            Layout.fillWidth: true
          }

          TibiaText {
            text: accountInfos != null && accountInfos.isPremium ? qsTrId("charinfo_account_status_premium") : qsTrId("charinfo_account_status_free")
            color: accountInfos != null && accountInfos.isPremium ? TibiaStyle.textColors["Positive"] : TibiaStyle.textColors["Dialog"]
          }
        } // RowLayout

        RowLayout {
          TibiaText {
            text: qsTrId("charinfo_account_onlinestatus")
            Layout.fillWidth: true
          }

          TibiaText {
            text: accountInfos != null && accountInfos.isOnline ? qsTrId("charinfo_account_online") : qsTrId("charinfo_account_offline")
            color: accountInfos != null && accountInfos.isOnline ? TibiaStyle.textColors["VipOnline"] : TibiaStyle.textColors["Dialog"]
          }
        } // RowLayout

        RowLayout {
          TibiaText {
            text: qsTrId("charinfo_loyaltytitle")
            Layout.fillWidth: true
          }

          TibiaText {
            text: accountInfos != null && accountInfos.loyaltyTitle.length > 0 ? accountInfos.loyaltyTitle : qsTrId("charinfo_no_loyaltytitle")
          }
        } // RowLayout
      } // ColumnLayout

      TibiaVerticalSeparator {
        anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; bottom: parent.bottom }
        anchors.margins: TibiaStyle.marginRelated
        width: TibiaStyle.marginNarrow
      }

      ColumnLayout {
        id: secondStatBlock
        width: parent.width / 2 - TibiaStyle.marginRelated * 2
        anchors { right: parent.right; top: parent.top; }
        anchors.margins: TibiaStyle.marginRelated

        TibiaText {
          Layout.alignment: Qt.AlignHCenter
          text: qsTrId("charinfo_skills_header")
        }

        Repeater {
          model: controller != null ? controller.characterStatsSecondBlock : null;

          SkillWidgetEntry {
            Layout.fillWidth: true

            Component.onCompleted: {
              skillModelData = modelData;
            }
          }
        } // Repeater
      } // ColumnLayout

      ColumnLayout {
        width: parent.width / 2 - TibiaStyle.marginRelated * 2
        anchors { right: parent.right; top: secondStatBlock.bottom; bottom: parent.bottom; }
        anchors.margins: TibiaStyle.marginRelated
        visible: accountInfos != null && accountInfos.canShowAccountInfos && badgesGridView.count > 0

        TibiaText {
          Layout.alignment: Qt.AlignHCenter
          Layout.topMargin: -1
          text: qsTrId("charinfo_badges_header")
        }

        TibiaFrame1PixelDown {
          Layout.fillWidth: true
          Layout.fillHeight: true

          TibiaScrollView {
            anchors.fill: parent
            anchors.margins: 1

            GridView {
              id: badgesGridView
              cellWidth: width / 3
              cellHeight: 64  + TibiaStyle.marginNarrow * 2
              pixelAligned: true

              boundsBehavior: Flickable.StopAtBounds
              interactive: false //prevent flick behavior on touch screens

              model: controller != null && controller.accountInfos != null ? controller.accountInfos.accountBadges : null

              delegate: Item {
                width: badgesGridView.cellWidth
                height: badgesGridView.cellHeight
                Image {
                  x: (parent.width - 64) / 2
                  y: TibiaStyle.marginNarrow
                  source: model != null ? model.badgeIcon : ""
                  smooth: false

                  Tooltip {
                    anchors.fill: parent
                    text: model != null ? model.badgeName : ""
                    useRichText: true
                  } //Tooltip
                } //Image
              } // delegate: Item
            } // GridView
          } // TibiaScrollView
        } // TibiaFrame1PixelDown
      } // ColumnLayout
    } // TibiaFrame1PixelDown
  } // Component generalStatsComponent

  component TwoPaneFrame: TibiaFrame1PixelDown {
    property Component leftPane
    property Component rightPane

    TibiaScrollView {
      anchors.fill: parent
      anchors.margins: parent.borderWidth
      verticalScrollBarPolicy: ScrollBar.AsNeeded

      Flickable {
        contentHeight: Math.max(leftLoader.status == Loader.Ready ? leftLoader.item.height + TibiaStyle.marginUnrelated : 0,
                                rightLoader.status == Loader.Ready ? rightLoader.item.height + TibiaStyle.marginUnrelated : 0,
                                parent.height)
        boundsBehavior: Flickable.StopAtBounds
        interactive: false //prevent flick behavior on touch screens

        Loader {
          id: leftLoader
          width: parent.width / 2 - TibiaStyle.marginRelated * 2
          anchors { left: parent.left; top: parent.top }
          anchors.margins: TibiaStyle.marginRelated

          sourceComponent: leftPane
        }

        TibiaVerticalSeparator {
          anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; bottom: parent.bottom }
          anchors.margins: TibiaStyle.marginRelated
          width: TibiaStyle.marginNarrow
        }

        Loader {
          id: rightLoader
          width: parent.width / 2 - TibiaStyle.marginRelated * 2
          anchors { right: parent.right; top: parent.top; }
          anchors.margins: TibiaStyle.marginRelated

          sourceComponent: rightPane
        }
      } // Flickable
    } // TibiaScrollView
  } // component TwoPaneFrame

  Component {
    id: offenceStatsComponent

    TwoPaneFrame {
      leftPane: ColumnLayout {
        spacing: TibiaStyle.marginUnrelated

        CharacterCombatStatBlock {
          statBlockData: controller.offenceStats.flatDamageHealing
        }

        CharacterCombatStatBlock {
          statBlockData: controller.offenceStats.attackValue
        }

        CharacterCombatStatBlock {
          statBlockData: controller.offenceStats.specialAttackConversion
        }

        CharacterCombatStatBlock {
          statBlockData: controller.offenceStats.lifeLeech
        }

        CharacterCombatStatBlock {
          statBlockData: controller.offenceStats.lifeOnHit
        }

        CharacterCombatStatBlock {
          statBlockData: controller.offenceStats.lifeOnKill
        }

        CharacterCombatStatBlock {
          statBlockData: controller.offenceStats.manaLeech
        }

        CharacterCombatStatBlock {
          statBlockData: controller.offenceStats.manaOnHit
        }

        CharacterCombatStatBlock {
          statBlockData: controller.offenceStats.manaOnKill
        }

        CharacterCombatStatBlock {
          statBlockData: controller.offenceStats.onslaught
        }

        CharacterCombatStatBlock {
          statBlockData: controller.offenceStats.specificTargetAttackBonus
          type: CharacterCombatStatBlock.EType.Against
          alwaysShowSources: true
        }

        CharacterCombatStatBlock {
          statBlockData: controller.offenceStats.autoAttackBonusFromSkills
          alwaysShowSources: true
        }

        CharacterCombatStatBlock {
          statBlockData: controller.offenceStats.spellBonusDamageFromSkills
          alwaysShowSources: true
        }

        CharacterCombatStatBlock {
          statBlockData: controller.offenceStats.spellBonusHealingFromSkills
          alwaysShowSources: true
        }

        // No more space here when all stats above display all available sources
      } // ColumnLayout (leftPane)

      rightPane: ColumnLayout {
        spacing: TibiaStyle.marginUnrelated

        TibiaText {
          text: qsTrId("critical_hit_caption") + ":"
          tooltipText: qsTrId("charinfo_critical_hit_tooltip")
          tooltipMaxWidth: TibiaStyle.tooltipRestrictedWidth
          visible: controller.offenceStats.critChance.visible
        }

        CharacterCombatStatBlock {
          statBlockData: controller.offenceStats.critChance
          Layout.leftMargin: TibiaStyle.marginUnrelated
        }

        CharacterCombatStatBlock {
          statBlockData: controller.offenceStats.specialCritChances
          Layout.leftMargin: TibiaStyle.marginUnrelated
          type: CharacterCombatStatBlock.EType.For
          alwaysShowSources: true
        }

        CharacterCombatStatBlock {
          statBlockData: controller.offenceStats.critExtraDamage
          Layout.leftMargin: TibiaStyle.marginUnrelated
        }

        CharacterCombatStatBlock {
          statBlockData: controller.offenceStats.specialCritDamages
          Layout.leftMargin: TibiaStyle.marginUnrelated
          type: CharacterCombatStatBlock.EType.For
          alwaysShowSources: true
       }

        CharacterCombatStatBlock {
          statBlockData: controller.offenceStats.cleave
        }

        CharacterCombatStatBlock {
          statBlockData: controller.offenceStats.distanceFightingAccuracy
        }

        CharacterCombatStatBlock {
          statBlockData: controller.offenceStats.perfectShot
          alwaysShowSources: true
        }

        CharacterCombatStatBlock {
          statBlockData: controller.offenceStats.alphaStrike
        }

        CharacterCombatStatBlock {
          statBlockData: controller.offenceStats.omegaStrike
        }

        CharacterCombatStatBlock {
          statBlockData: controller.offenceStats.armorPenetration
        }

        CharacterCombatStatBlock {
          statBlockData: controller.offenceStats.elementalPierce
          alwaysShowSources: true
        }

      } // ColumnLayout (rightPane)
    } // TwoPaneFrame
  } // Component offenceStatsComponent

  Component {
    id: defenceStatsComponent

    TwoPaneFrame {
      leftPane: ColumnLayout {
        spacing: TibiaStyle.marginUnrelated

        CharacterCombatStatBlock {
          statBlockData: controller.defenceStats.defence
        }

        CharacterCombatStatBlock {
          statBlockData: controller.defenceStats.armorValue
        }

        CharacterCombatStatBlock {
          statBlockData: controller.defenceStats.mantraValue
        }

        CharacterCombatStatBlock {
          statBlockData: controller.defenceStats.mitigation
        }

        CharacterCombatStatBlock {
          statBlockData: controller.defenceStats.magicShield
        }

        CharacterCombatStatBlock {
          statBlockData: controller.defenceStats.dodge
        }

        CharacterCombatStatBlock {
          statBlockData: controller.defenceStats.damageReflection
        }
      } // ColumnLayout (leftPane)

      rightPane: ColumnLayout {
        spacing: TibiaStyle.marginRelated

        TibiaText {
          text: qsTrId("charinfo_damage_reduction")
          tooltipText: qsTrId("charinfo_damage_reduction_header_tooltip")
          tooltipMaxWidth: TibiaStyle.tooltipRestrictedWidth
        }

        Repeater {
          Layout.fillWidth: true
          model: controller.defenceStats.damageReductions

          CharacterCombatStatBlock {
            statBlockData: modelData
            Layout.leftMargin: TibiaStyle.marginUnrelated
            spacing: TibiaStyle.marginNarrow
          }
        } // Repeater
      } // ColumnLayout (rightPane)
    } // TwoPaneFrame
  } // Component defenceStatsComponent

  Component {
    id: miscStatsComponent

    TwoPaneFrame {
      leftPane: ColumnLayout {
        spacing: TibiaStyle.marginUnrelated

        CharacterCombatStatBlock {
          statBlockData: controller.miscStats.momentum
        }

        CharacterCombatStatBlock {
          statBlockData: controller.miscStats.transcendence
        }

        CharacterCombatStatBlock {
          statBlockData: controller.miscStats.amplification
        }

        RowLayout {
          id: blessingsLine
          TibiaText {
            text: qsTrId("charinfo_blessings")
            Layout.fillWidth: true
            tooltipText: blessingsText.tooltipText
          }

          TibiaText {
            id: blessingsText
            text: qsTrId("charinfo_blessings_number").arg(controller.miscStats.currentBlessings).arg(controller.miscStats.maxBlessings)
            tooltipText: qsTrId("charinfo_blessings_tooltip").arg(controller.miscStats.currentBlessings).arg(controller.miscStats.maxBlessings)
          }

          TibiaIconButton {
            readonly property string color: controller.miscStats.blessingButtonColor
            sourceUp: "/images/blessings/button-blessings-" + color + "-idle.png"
            sourceDown: "/images/blessings/button-blessings-" + color + "-pressed.png"

            onClicked: {
              controller.openBlessingsDialog();
            }
          } // TibiaIconButton
        } // RowLayout

        ColumnLayout {
          Layout.fillWidth: true
          spacing: TibiaStyle.marginRelated
          visible: spellAugmentsList.count > 0

          TibiaText {
            text: qsTrId("charinfo_spell_augments");
            tooltipText: qsTrId("charinfo_spell_augments_tooltip")
            Layout.fillWidth: true
          } //TibiaText

          ListView {
            id: spellAugmentsList
            model: controller.miscStats.spellAugments
            Layout.preferredHeight: contentHeight
            Layout.leftMargin: TibiaStyle.marginUnrelated
            Layout.fillWidth: true
            spacing: TibiaStyle.marginNarrow
            interactive: false //prevent flick behavior on touch screens
            boundsBehavior: Flickable.StopAtBounds

            delegate: CharacterCombatStatBlock {
              anchors.left: parent.left
              anchors.right: parent.right
              statBlockData: modelData
              alwaysShowSources: true
              type: CharacterCombatStatBlock.EType.Nothing
              sourcesMarginLeft: TibiaStyle.marginRelated
            } // delegate: TibiaText

          } // ListView

        } // ColumnLayout

        ColumnLayout {
          Layout.fillWidth: true
          spacing: TibiaStyle.marginRelated
          visible: skillwheelSpellAugmentsList.count > 0
          TibiaText {
            text: qsTrId("charinfo_skillwheel_spell_augments");
            tooltipText: qsTrId("charinfo_skillwheel_spell_augments_tooltip")
            Layout.fillWidth: true
          } //TibiaText

          ListView {
            id: skillwheelSpellAugmentsList
            model: controller.miscStats.skillwheelSpellAugments
            Layout.preferredHeight: contentHeight
            Layout.leftMargin: TibiaStyle.marginUnrelated
            Layout.fillWidth: true
            spacing: TibiaStyle.marginNarrow
            interactive: false //prevent flick behavior on touch screens
            boundsBehavior: Flickable.StopAtBounds

            delegate: CharacterCombatStatBlock {
              anchors.left: parent.left
              anchors.right: parent.right
              statBlockData: modelData
              alwaysShowSources: true
              type: CharacterCombatStatBlock.EType.Nothing
              sourcesMarginLeft: TibiaStyle.marginRelated
            } // delegate: TibiaText

          } // ListView

        } // ColumnLayout

        ColumnLayout {
          Layout.fillWidth: true
          spacing: TibiaStyle.marginRelated
          visible: equipmentSpellAugmentsList.count > 0
          TibiaText {
            text: qsTrId("charinfo_equipment_spell_augments");
            tooltipText: qsTrId("charinfo_equipment_spell_augments_tooltip")
            Layout.fillWidth: true
          } //TibiaText

          ListView {
            id: equipmentSpellAugmentsList
            model: controller.miscStats.equipmentSpellAugments
            Layout.preferredHeight: contentHeight
            Layout.leftMargin: TibiaStyle.marginUnrelated
            Layout.fillWidth: true
            spacing: TibiaStyle.marginNarrow
            interactive: false //prevent flick behavior on touch screens
            boundsBehavior: Flickable.StopAtBounds

            delegate: CharacterCombatStatBlock {
              anchors.left: parent.left
              anchors.right: parent.right
              statBlockData: modelData
              alwaysShowSources: true
              type: CharacterCombatStatBlock.EType.Nothing
              sourcesMarginLeft: TibiaStyle.marginRelated
            } // delegate: TibiaText

          } // ListView

        } // ColumnLayout
      } // ColumnLayout

      rightPane: ColumnLayout {
        spacing: TibiaStyle.marginUnrelated

        ColumnLayout {
          Layout.fillWidth: true
          spacing: TibiaStyle.marginRelated
          visible: activeConcoctionsList.count > 0

          TibiaText {
            text: qsTrId("charinfo_active_concoctions_header");
          } //TibiaText

          GridView {
            id: activeConcoctionsList
            Layout.fillWidth: true
            Layout.preferredHeight: contentHeight

            interactive: false //prevent flick behavior on touch screens
            boundsBehavior: Flickable.StopAtBounds

            readonly property int elementWidth: TibiaStyle.containerSlotSize
            readonly property int elmentHeight: TibiaStyle.containerSlotSize
            cellWidth: elementWidth + TibiaStyle.marginRelated
            cellHeight: elmentHeight + TibiaStyle.marginRelated

            model: controller.miscStats.activeConcoctions

            delegate: Item {
              width: activeConcoctionsList.elementWidth
              height: activeConcoctionsList.elmentHeight

              ContainerSlot {
                objectAppearanceInstanceTypeId: modelData.appearanceTypeID
                slotText: TextHelper.formatSecondsToUltraShortDaysOrHoursOrMinsOrSecondsTimeString(modelData.secondsRemaining)
                slotTooltip: qsTrId("%1: %2")
                  .arg(modelData.name)
                  .arg(TextHelper.formatSecondsToShortDaysHoursMinOrHoursMinOrMinSecondsOrSecondsTimeString(modelData.secondsRemaining))
              } // ContainerSlot
            } // delegate: Item
          } // GridView
        } // ColumnLayout

        ColumnLayout {
          Layout.fillWidth: true
          spacing: TibiaStyle.marginRelated
          visible: consumableCooldowns.count > 0

          TibiaText {
            text: qsTrId("charinfo_consumable_cooldown_header");
          } //TibiaText

          GridView {
            id: consumableCooldowns
            Layout.fillWidth: true
            Layout.preferredHeight: contentHeight

            interactive: false //prevent flick behavior on touch screens
            boundsBehavior: Flickable.StopAtBounds

            readonly property int elementWidth: TibiaStyle.containerSlotSize
            readonly property int elmentHeight: TibiaStyle.containerSlotSize
            cellWidth: elementWidth + TibiaStyle.marginRelated
            cellHeight: elmentHeight + TibiaStyle.marginRelated

            model: controller.miscStats.consumableCooldowns

            delegate: Item {
              width: consumableCooldowns.elementWidth
              height: consumableCooldowns.elmentHeight

              ContainerSlot {
                objectAppearanceInstanceTypeId: modelData.appearanceTypeID
                slotText: TextHelper.formatSecondsToUltraShortDaysOrHoursOrMinsOrSecondsTimeString(modelData.secondsRemaining)
                slotTooltip: qsTrId("%1: %2")
                  .arg(modelData.name)
                  .arg(TextHelper.formatSecondsToShortDaysHoursMinOrHoursMinOrMinSecondsOrSecondsTimeString(modelData.secondsRemaining))
              } // ContainerSlot
            } // delegate: Item
          } // GridView
        } // ColumnLayout
      } // ColumnLayout
    } // TibiaFrame1PixelDown
  } // Component miscStatsComponent


  Component {
    id: combatStatsComponent

    TibiaFrame1PixelDown {
      property var combatStats: controller != null ? controller.combatStats : null

      ColumnLayout {
        width: parent.width / 2 - TibiaStyle.marginRelated * 2
        anchors { left: parent.left; top: parent.top }
        anchors.margins: TibiaStyle.marginRelated

        RowLayout {
          id: attackValueLine
          TibiaText {
            text: qsTrId("charinfo_attack_value")
            tooltipText: attackValueText.tooltipText
            tooltipMaxWidth: attackValueText.tooltipMaxWidth
            Layout.fillWidth: true
          }

          TibiaText {
            id: attackValueText
            text: combatStats != null ? combatStats.attackValueString : qsTrId("dummy_unknown")
            tooltipText: qsTrId("charinfo_attack_value_tooltip")
            tooltipMaxWidth: TibiaStyle.tooltipRestrictedWidth
          }

          Image {
            source: combatStats != null ? combatStats.attackTypeImageSource : ""

            Tooltip {
              anchors.fill: parent
              text: combatStats != null ? combatStats.attackTypeName : qsTrId("dummy_unknown")
            }
          }
        } // RowLayout

        RowLayout {
          id: specialDamageLine

          TibiaText {
            text: qsTrId("charinfo_special_attack")
            tooltipText: specialAttackText.visible ? specialAttackText.tooltipText : noSpecialAttackText.tooltipText
            Layout.fillWidth: true
          }

          TibiaText {
            id: specialAttackText
            visible: combatStats != null && combatStats.hasSpecialAttackConversion
            text: combatStats != null ? combatStats.specialAttackConversionString : qsTrId("dummy_unknown")
            tooltipText: combatStats != null ? qsTrId("charinfo_special_attack_tooltip")
              .arg(combatStats.specialAttackConversionString)
              .arg(combatStats.specialAttackTypeName) : qsTrId("dummy_unknown")
          }

          Image {
            source: combatStats != null ? combatStats.specialAttackTypeImageSource : ""
            visible: specialAttackText.visible

            Tooltip {
              anchors.fill: parent
              text: combatStats != null ? combatStats.specialAttackTypeName : qsTrId("dummy_unknown")
            }
          }

          TibiaText {
            id: noSpecialAttackText
            visible: !specialAttackText.visible
            text: qsTrId("charinfo_none")
            tooltipText: qsTrId("charinfo_special_attack_none_tooltip")
          }
        } // RowLayout

        TibiaText {
          text: qsTrId("charinfo_damage_reduction")
          tooltipText: qsTrId("charinfo_damage_reduction_header_tooltip")
          tooltipMaxWidth: TibiaStyle.tooltipRestrictedWidth
        }

        Repeater {
          id: damageReductionRepeater
          model: combatStats != null ? combatStats.damageReductions : null

          RowLayout {
            TibiaText {
              text: "  " + modelData.damageTypeName
              Layout.fillWidth: true
              tooltipText: damageReductionText.tooltipText
              tooltipMaxWidth: TibiaStyle.tooltipRestrictedWidth
            }

            TibiaText {
              id: damageReductionText
              text: modelData.reductionPercentString
              color: modelData.reductionPercent < 0 ? TibiaStyle.textColors['ModifierNegative'] : TibiaStyle.textColors['ModifierPositive']
              tooltipText: qsTrId(modelData.reductionPercent < 0 ? "charinfo_damage_increase_tooltip" : "charinfo_damage_reduction_tooltip")
                .arg(modelData.damageTypeName)
                .arg(Math.abs(modelData.reductionPercent))
                .arg(qsTrId("charinfo_damage_reduction_header_tooltip"))
              tooltipMaxWidth: TibiaStyle.tooltipRestrictedWidth
            }

            Image {
              source: modelData.iconSource

              Tooltip {
                anchors.fill: parent
                text: modelData.damageTypeName
              }
            }
          } // RowLayout
        } // Repeater

        TibiaText {
          text: "  " + qsTrId("charinfo_none")
          tooltipText: qsTrId("charinfo_damage_reduction_none_tooltip")
          visible: damageReductionRepeater.count == 0
        }
      } // ColumnLayout

      TibiaVerticalSeparator {
        anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; bottom: parent.bottom }
        anchors.margins: TibiaStyle.marginRelated
        width: TibiaStyle.marginNarrow
      }

      ColumnLayout {
        width: parent.width / 2 - TibiaStyle.marginRelated * 2
        anchors { right: parent.right; top: parent.top; }
        anchors.margins: TibiaStyle.marginRelated

        spacing: TibiaStyle.marginUnrelated

        ColumnLayout {
          Layout.fillWidth: true
          spacing: TibiaStyle.marginRelated

          Repeater {
            model: controller != null ? controller.characterStatsSecondBlock : null;

            SkillWidgetEntry {
              Layout.fillWidth: true

              Component.onCompleted: {
                skillModelData = modelData;
              }
            } //SkillWidgetEntry
          } // Repeater
        } //ColumnLayout
      } // ColumnLayout
    } // TibiaFrame1PixelDown
  } // Component combatStatsComponent

  Component {
    id: deathsComponent

    ColumnLayout {
      TibiaTableView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        model: controller != null ? controller.characterDeaths : null
        headerVisible: true

        onModelChanged: {
          deathsPrevPageButton.enabled = Qt.binding(function() {
            return controller != null ? controller.currentPage > 1 : false; });
          deathsNextPageButton.enabled = Qt.binding(function() {
            return controller != null ? controller.currentPage < controller.numberOfPages : false; });
        }

        TableViewColumn { role: "timestamp"; title: qsTrId("charinfo_datetime_header"); movable: false; resizable: false; width: 155 }
        TableViewColumn { role: "description"; title: qsTrId("charinfo_deathdescription_header"); movable: false; resizable: false; width: 325 }
      } // TibiaTableView

      RowLayout {
        Layout.bottomMargin: TibiaStyle.marginUnrelated

        TibiaButton {
          id: deathsPrevPageButton
          text: qsTrId("charinfo_pagination_previous")
          Layout.preferredWidth: TibiaStyle.buttonWidthWide

          onClicked: {
            if (controller != null) {
              controller.previousPaginatedPage();
              deathsNextPageButton.enabled = false;
              deathsPrevPageButton.enabled = false;
            }
          } //onClicked
        } //TibiaButton

        TibiaText {
          text: qsTrId("charinfo_pagination_text")
              .arg(controller != null ? controller.currentPage: 1)
              .arg(controller != null ? controller.numberOfPages : 1)
          horizontalAlignment: Text.AlignHCenter
          Layout.fillWidth: true
        } //TibiaText

        TibiaButton {
          id: deathsNextPageButton
          text: qsTrId("charinfo_pagination_next")
          Layout.preferredWidth: TibiaStyle.buttonWidthWide

          onClicked: {
            if (controller != null) {
              controller.nextPaginatedPage();
              deathsNextPageButton.enabled = false;
              deathsPrevPageButton.enabled = false;
            }
          } //onClicked
        } //TibiaButton
      } // RowLayout
    } // ColumnLayout
  } // Component deathsComponent

  Component {
    id: killsComponent

    ColumnLayout {
      TibiaTableView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        model: controller != null ? controller.characterKills : null
        headerVisible: true

        onModelChanged: {
          killsPrevPageButton.enabled = Qt.binding(function() {
            return controller != null ? controller.currentPage > 1 : false; });
          killsNextPageButton.enabled = Qt.binding(function() {
            return controller != null ? controller.currentPage < controller.numberOfPages : false; });
        }

        TableViewColumn { role: "timestamp"; title: qsTrId("charinfo_datetime_header"); movable: false; resizable: false; width: 155 }
        TableViewColumn { role: "description"; title: qsTrId("charinfo_killdescription_header"); movable: false; resizable: false; width: 245 }

        TableViewColumn {
          role: "unjustified"
          title: qsTrId("status")
          movable: false
          resizable: false
          width: 80

          delegate: TibiaText {
            x: TibiaStyle.marginNarrow
            text: styleData.value
            color: {
              if (modelData != null) {
                if (modelData.unjustifiedCode == 0) { // justified
                  return TibiaStyle.textColors['Positive'];
                } else if (modelData.unjustifiedCode == 1) { // unjustified
                  return TibiaStyle.textColors['Negative'];
                } else if (modelData.unjustifiedCode == 2) { // guild war
                  return TibiaStyle.orange1;
                }
              }
              return styleData.textColor;
            }
          } // delegate TibiaText
        } // TableViewColumn
      } // TibiaTableView

      RowLayout {
        Layout.bottomMargin: TibiaStyle.marginUnrelated

        TibiaButton {
          id: killsPrevPageButton
          text: qsTrId("charinfo_pagination_previous")
          Layout.preferredWidth: TibiaStyle.buttonWidthWide

          onClicked: {
            if (controller != null) {
              controller.previousPaginatedPage();
              killsNextPageButton.enabled = false;
              killsPrevPageButton.enabled = false;
            }
          } //onClicked
        } //TibiaButton

        TibiaText {
          text: qsTrId("charinfo_pagination_text")
              .arg(controller != null ? controller.currentPage: 1)
              .arg(controller != null ? controller.numberOfPages : 1)
          horizontalAlignment: Text.AlignHCenter
          Layout.fillWidth: true
        } //TibiaText

        TibiaButton {
          id: killsNextPageButton
          text: qsTrId("charinfo_pagination_next")
          Layout.preferredWidth: TibiaStyle.buttonWidthWide

          onClicked: {
            if (controller != null) {
              controller.nextPaginatedPage();
              killsNextPageButton.enabled = false;
              killsPrevPageButton.enabled = false;
            }
          } //onClicked
        } //TibiaButton
      } // RowLayout
    } /// ColumnLayout
  } // Component killsComponent

  Component {
    id: achievementsComponent

    ColumnLayout {
      spacing: TibiaStyle.marginRelated

      RowLayout {
        Layout.alignment: Qt.AlignTop | Qt.AlignLeft

        ColumnLayout {
          id: achievementPoints
          Layout.fillHeight: true
          Layout.fillWidth: true
          spacing: 0

          RowLayout {
            Layout.alignment: Qt.AlignRight

            TibiaText {
              text: qsTrId("charinfo_achievement_points")
              tooltipText: achievementPointsText.tooltipText
            } // TibiaText

            TibiaText {
              id: achievementPointsText
              Layout.preferredWidth: 32
              Layout.preferredHeight: 13
              horizontalAlignment: Text.AlignLeft
              Layout.alignment: Qt.AlignVCenter
              elide: Text.ElideRight
              text: (achievementController != null ? achievementController.achievementPointsSum : 0)
              tooltipText: qsTrId("charinfo_achievement_points_tooltip")
            } // TibiaText

          } // RowLayout

          RowLayout {
            Layout.alignment: Qt.AlignRight

            Repeater {
              model: 1
              delegate: Image {
                source: "/images/icon-achievement.png"
              } // Image
            } //Repeater

            TibiaText {
              text: qsTrId("charinfo_achievement_points_grade1")
            } // TibiaText

            TibiaText {
              Layout.preferredWidth: 32
              Layout.preferredHeight: 13
              horizontalAlignment: Text.AlignLeft
              Layout.alignment: Qt.AlignVCenter
              elide: Text.ElideRight
              text: (achievementController != null ? achievementController.unlockedGrade1Achievements : 0)
            } // TibiaText

          } // RowLayout

          RowLayout {
            Layout.alignment: Qt.AlignRight

            RowLayout {
              spacing: 0
              Repeater {
                model: 2
                delegate: Image {
                  source: "/images/icon-achievement.png"
                } // Image
              } //Repeater
            } // RowLayout

            TibiaText {
              text: qsTrId("charinfo_achievement_points_grade2")
            } // TibiaText

            TibiaText {
              Layout.preferredWidth: 32
              Layout.preferredHeight: 13
              horizontalAlignment: Text.AlignLeft
              Layout.alignment: Qt.AlignVCenter
              elide: Text.ElideRight
              text: (achievementController != null ? achievementController.unlockedGrade2Achievements : 0)
            } // TibiaText

          } // RowLayout

          RowLayout {
            Layout.alignment: Qt.AlignRight

            RowLayout {
              spacing: 0
              Repeater {
                model: 3

                delegate: Image {
                  source: "/images/icon-achievement.png"
                } // Image
              } //Repeater
            } // RowLayout

            TibiaText {
              text: qsTrId("charinfo_achievement_points_grade3")
            } // TibiaText

            TibiaText {
              Layout.preferredWidth: 32
              Layout.preferredHeight: 13
              horizontalAlignment: Text.AlignLeft
              Layout.alignment: Qt.AlignVCenter
              elide: Text.ElideRight
              text: (achievementController != null ? achievementController.unlockedGrade3Achievements : 0)
            } // TibiaText
          } // RowLayout

          RowLayout {
            Layout.alignment: Qt.AlignRight

            RowLayout {
              spacing: 0
              Repeater {
                model: 4

                delegate: Image {
                  source: "/images/icon-achievement.png"
                } // Image
              } //Repeater
            } // RowLayout

            TibiaText {
              text: qsTrId("charinfo_achievement_points_grade4")
            } // TibiaText

            TibiaText {
              Layout.preferredWidth: 32
              Layout.preferredHeight: 13
              horizontalAlignment: Text.AlignLeft
              Layout.alignment: Qt.AlignVCenter
              elide: Text.ElideRight
              text: (achievementController != null ? achievementController.unlockedGrade4Achievements : 0)
            } // TibiaText
          } // RowLayout
        }// ColumnLayout


        TibiaFrame1PixelDown {

          id: achievementFilters
          height: filterOptions.height + 20
          width: filterOptions.width + 8
          Layout.alignment: Qt.AlignHCenter
          ColumnLayout {
            id: filterOptions
            spacing: TibiaStyle.marginRelated
            anchors.centerIn: parent

            ButtonGroup {
              id: filterType

              checkedButton: {
                if (achievementController != null) {
                  if (achievementController.filterCriterion == AchievementController.All) {
                    return filterTypeAll;
                  } else if (achievementController.filterCriterion == AchievementController.Locked) {
                    return filterTypeLocked;
                  } else if (achievementController.filterCriterion == AchievementController.Discovered) {
                    return filterTypeDiscovered;
                  }
                }
                return filterTypeAll;
              }

              onCheckedButtonChanged: {
                if (checkedButton == filterTypeAll) {
                  if (achievementController) {
                    achievementController.filterCriterion = AchievementController.All;
                  }
                } else if (checkedButton == filterTypeLocked) {
                  if (achievementController) {
                    achievementController.filterCriterion = AchievementController.Locked;
                  }
                } else if (checkedButton == filterTypeDiscovered) {
                  if (achievementController) {
                    achievementController.filterCriterion = AchievementController.Discovered;
                  }
                }
              } //onCheckedButtonChanged
            } //ButtonGroup

            TibiaRadioButton {
              id: filterTypeAll
              text: qsTrId("charinfo_achievement_filter_all")
              ButtonGroup.group: filterType
              enabled: achievementController != null
            } //TibiaRadioButton

            TibiaRadioButton {
              id: filterTypeLocked
              text: qsTrId("charinfo_achievement_filter_locked")
              ButtonGroup.group: filterType
              enabled: achievementController != null
            } //TibiaRadioButton

            TibiaRadioButton {
              id: filterTypeDiscovered
              text: qsTrId("charinfo_achievement_filter_discovered")
              ButtonGroup.group: filterType
              enabled: achievementController != null
            } //TibiaRadioButton

          } // ColumnLayout
        } // TibiaFrame1PixelDown

        ColumnLayout {
          id: achievementFilterAndProgress
          Layout.fillWidth: true

          RowLayout {
            Layout.alignment: Qt.AlignRight

            TibiaText {
              text: qsTrId("charinfo_achievement_sorting")
            } // TibiaText

            TibiaComboBox {
              id: sortingComboBox
              property var listModelComplete : ListModel {
                    ListElement { text: qsTrId("charinfo_achievement_sorting_alphabetically") }
                    ListElement { text: qsTrId("charinfo_achievement_sorting_grade") }
                    ListElement { text: qsTrId("charinfo_achievement_sorting_unlockdate")}
                }
              property var listModelWithoutUnlockDate: ListModel {
                    ListElement { text: qsTrId("charinfo_achievement_sorting_alphabetically") }
                    ListElement { text: qsTrId("charinfo_achievement_sorting_grade") }
                }
              Layout.preferredWidth: 145
              model: (achievementController && achievementController.filterCriterion == AchievementController.Locked) ? listModelWithoutUnlockDate : listModelComplete
              shouldBeCurrentIndex: (achievementController != null ? (achievementController.sortingCriterion == AchievementController.Name ? 0 : (achievementController.sortingCriterion == AchievementController.Grade ? 1 : 2)) : 0)
              onCurrentIndexChanged: {
                if (achievementController != null) {
                  if (currentIndex == 0) {
                    achievementController.sortingCriterion = AchievementController.Name;
                  } else if (currentIndex == 1) {
                    achievementController.sortingCriterion = AchievementController.Grade;
                  } else {
                    achievementController.sortingCriterion = AchievementController.UnlockDate;
                  }
                }
              } //onCurrentIndexChanged
            } //TibiaComboBox
          } // RowLayout

          RowLayout {
            Layout.alignment: Qt.AlignRight
            TibiaText {
              text: qsTrId("charinfo_achievement_regular")
            } // TibiaText

            TibiaProgressBar {
              Layout.preferredHeight: TibiaStyle.progressBarLargeHeight
              Layout.preferredWidth: sortingComboBox.width
              fillPercentage: (achievementController != null && achievementController.totalRegularAchievements != 0 ? (achievementController.unlockedRegularAchievements / achievementController.totalRegularAchievements) : 0)

              frameSource: "/images/1pixel-down-frame.png"
              backgroundSource: "/images/backdrop-dark-grey.png"
              fillSource: "/images/progressbar-orange-large.png"

              frameBorder { left: 1; right: 1; top:1; bottom: 1}
              fillOffset { left: 1; right: 1; top:1; bottom: 1}


              TibiaText {
                anchors.centerIn: parent
                text: qsTrId("charinfo_achievement_progressbar_text").arg((achievementController != null ? achievementController.unlockedRegularAchievements : 0)).arg((achievementController != null ? achievementController.totalRegularAchievements : 0))
              } //TibiaText
            } //TibiaProgressBar
          } // RowLayout

          RowLayout {
            Layout.alignment: Qt.AlignRight
            TibiaText {
              text: qsTrId("charinfo_achievement_secret")
            } // TibiaText

            TibiaProgressBar {
              Layout.preferredHeight: TibiaStyle.progressBarLargeHeight
              Layout.preferredWidth: sortingComboBox.width
              fillPercentage: (achievementController != null && achievementController.totalSecretAchievements != 0 ? (achievementController.unlockedSecretAchievements / achievementController.totalSecretAchievements) : 0)

              frameSource: "/images/1pixel-down-frame.png"
              backgroundSource: "/images/backdrop-dark-grey.png"
              fillSource: "/images/progressbar-orange-large.png"

              frameBorder { left: 1; right: 1; top:1; bottom: 1}
              fillOffset { left: 1; right: 1; top:1; bottom: 1}


              TibiaText {
                anchors.centerIn: parent
                text: qsTrId("charinfo_achievement_progressbar_text").arg((achievementController != null ? achievementController.unlockedSecretAchievements : 0)).arg((achievementController != null ? achievementController.totalSecretAchievements : 0))
              } //TibiaText
            } //TibiaProgressBar
          } // RowLayout
        } // ColumnLayout
      } // RowLayout

      TibiaFrame1PixelDown {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignTop
        Layout.bottomMargin: TibiaStyle.marginRelated

        TibiaScrollView {
          id: containerScrollView
          anchors.fill: parent
          anchors.topMargin: parent.borderWidth
          anchors.bottomMargin: parent.borderWidth
          anchors.rightMargin: parent.borderWidth
          // leftMargin is already covered by the ListView's margins

          ListView {
            id: achievmentList
            model: achievementController != null ? achievementController.achievementList : null
            spacing: TibiaStyle.marginRelated
            topMargin: TibiaStyle.marginRelated
            leftMargin: TibiaStyle.marginRelated
            rightMargin: TibiaStyle.marginRelated
            bottomMargin: TibiaStyle.marginNarrow

            boundsBehavior: Flickable.StopAtBounds
            interactive: false //prevent flick behavior on touch screens
            footer: Item {
              height: TibiaStyle.marginRelated * 2
              width: TibiaStyle.marginRelated * 2
            }

            delegate: Item {
              width: achievmentList.width - achievmentList.leftMargin - achievmentList.rightMargin
              height: achievementCaptionPanel.height
              TibiaPanelWithCaption {
                id: achievementCaptionPanel
                caption: modelData.secret ?
                  qsTrId("charinfo_achievement_name_secret").arg(modelData.name) :
                  modelData.name
                shouldBeExpanded: true
                mouseAreaEnabled: false
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                collapsible: false

                contentDelegate:
                  Item {
                    height: achievementDescription.height + TibiaStyle.marginRelated
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.right: parent.right
                    TibiaText {
                      anchors.left: parent.left
                      anchors.top: parent.top
                      anchors.right: parent.right
                      anchors.leftMargin: TibiaStyle.marginRelated
                      anchors.bottomMargin: TibiaStyle.marginRelated
                      id: achievementDescription
                      text: modelData.description
                      wrapMode: Text.Wrap
                    } // TibiaText
                  } // Item

              } // TibiaPanelWithCaption

              RowLayout {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: 3
                anchors.leftMargin: TibiaStyle.marginNarrow
                spacing: 0
                Repeater {
                  model: modelData.grade

                  delegate: Image {
                    source: "/images/icon-achievement.png"
                  } // Image
                } //Repeater
              } // RowLayout

              TibiaText {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: TibiaStyle.marginNarrow
                anchors.rightMargin: 2*TibiaStyle.marginNarrow
                text: modelData.unlockDateString
                visible: modelData.unlockDateString.length > 0
                styleType: "Caption"
              } // TibiaText

            } // Item
          } // ListView
        }  //TibiaScrollView
      } // TibiaFrame1PixelDown
    } // ColumnLayout
  } // achievementsComponent

  Component {
    id: itemGridViewComponent

    TibiaScrollView {
      Layout.fillWidth: true
      Layout.fillHeight: true

      function filterSettingsChanged() {
        itemsGridView.positionViewAtBeginning()
      } //function filterSettingsChanged

      GridView {
        id: itemsGridView
        topMargin: TibiaStyle.containerSlotsMargin
        bottomMargin: TibiaStyle.containerSlotsMargin

        cellWidth: TibiaStyle.containerSlotSize + TibiaStyle.containerSlotsMargin
        cellHeight: cellWidth

        interactive: false //prevent flick behavior on touch screens
        boundsBehavior: Flickable.StopAtBounds

        footer: Item {
          height: TibiaStyle.containerSlotsMargin
        } //header: Item

        model: itemSummary

        delegate: ContainerSlot {
          objectAppearanceInstanceTypeId: model != null? model.appearanceTypeID : 0
          objectAppearanceInstanceCumulativeCount: model != null ? computeTotalBasedOnSelection(model) : 1
          objectAppearanceInstanceUpgradeTier: model != null ? model.upgradeTier : 0
          lootvalueImageSourceUnderItem: model != null ? model.lootValueSourceUnder : ""
          lootvalueImageSourceOverItem: model != null ? model.lootValueSourceOver : ""
          showPointingHandCursor: true
          Layout.preferredWidth: 34
          Layout.preferredHeight: 34
          Layout.leftMargin: TibiaStyle.marginNarrow
          slotText: TextHelper.formatNumberWithThousandShortcutsAsMultiString(computeTotalBasedOnSelection(model))
          slotTooltip: (model != null ? qsTrId("charinfo_items_amount_origin_tooltip")
          .arg(model.name)
          .arg(model.inventoryAmount).arg(model.stashAmount)
          .arg(model.depotAmount).arg(model.inboxAmount)
          .arg(model.storeInboxAmount) : "")


          MouseArea {
            anchors.fill: parent

            onClicked: {
              if (tibiaMouseCursorController != null) {
                tibiaMouseCursorController.setPointingHand(false);
              }
              if (controller != null && model != null) {
                controller.openItemInformation(model.appearanceTypeID);
              }
            }
          } // MouseArea
        } //delegate: ContainerSlot
      } // GridView
    } //TibiaScrollView
  } // Component


  Component {
    id: itemTableViewComponent

    TibiaTableView {
        id: itemTable
        Layout.fillWidth: true
        Layout.fillHeight: true
        model: itemSummary
        rowHeight: 36 // Must be uneven in order to correctly display the centered item name (otherwise, its X coordinate falls on a subpixel value)
        headerVisible: true
        selectionMode: SelectionMode.NoSelection;

        selection.onSelectionChanged: {
          if (selection.count > 0) {
            selection.clear();
          }
        }

        function filterSettingsChanged() {
          if (rowCount > 0) {
            positionViewAtRow(0, ListView.Beginning);
          }
        }

        TableViewColumn {
          role: "appearanceTypeID"
          title: qsTrId("name")
          movable: false
          resizable: false
          width: 350

          delegate: RowLayout {
            property int appearanceTypeID: model != null ? model.appearanceTypeID : 0
            ContainerSlot {
              objectAppearanceInstanceTypeId: appearanceTypeID
              objectAppearanceInstanceCumulativeCount: model != null ? computeTotalBasedOnSelection(model) : 1
              objectAppearanceInstanceUpgradeTier: model != null ? model.upgradeTier : 0
              lootvalueImageSourceUnderItem: model != null ? model.lootValueSourceUnder : ""
              lootvalueImageSourceOverItem: model != null ? model.lootValueSourceOver : ""
              showPointingHandCursor: true
              Layout.preferredWidth: 34
              Layout.preferredHeight: 34
              Layout.leftMargin: TibiaStyle.marginNarrow

              MouseArea {
                anchors.fill: parent

                onClicked: {
                  if (tibiaMouseCursorController != null) {
                    tibiaMouseCursorController.setPointingHand(false);
                  }
                  if (controller != null) {
                    controller.openItemInformation(appearanceTypeID);
                  }
                }
              } // MouseArea
            } // ContainerSlot

            TibiaText {
              text: model != null && model.name.length > 0 ? model.name : qsTrId("dummy_unknown")
              verticalAlignment: Text.AlignVCenter
              Layout.fillWidth: true
              Layout.fillHeight: true
            } // TibiaText

            TibiaVerticalSeparator {
              Layout.fillHeight: true
            } //TibiaVerticalSeparator
          } // RowLayout
        } // TableViewColumn

        TableViewColumn {
          role: "totalAmount"
          title: qsTrId("charinfo_items_amount_caption")
          movable: false
          resizable: false
          width: 100

          delegate: TibiaText {
            text: model != null ?
              TextHelper.formatNumberWithThousandSeparators(computeTotalBasedOnSelection(model)) :
              qsTrId("dummy_unknown")
            tooltipText: model != null ? qsTrId("charinfo_items_amount_origin_tooltip_without_name")
              .arg(model.inventoryAmount).arg(model.stashAmount)
              .arg(model.depotAmount).arg(model.inboxAmount)
              .arg(model.storeInboxAmount) : ""

            anchors.leftMargin: TibiaStyle.marginNarrow
            anchors.left: parent != null ? parent.left : undefined
            anchors.right: parent != null ? parent.right : undefined
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: styleData.textAlignment
          }
        } // TableViewColumn
    } // TibiaTableView


  } // Component

  Component {
    id: itemsComponent

    ColumnLayout {

      spacing: TibiaStyle.marginRelated

      TibiaFrame2PixelUpFilled {
        Layout.fillWidth: true
        Layout.preferredHeight: filterBox.height + borderWidth * 2 + TibiaStyle.marginRelated * 2

        GridLayout {
          id: filterBox
          anchors { left: parent.left; top: parent.top; right: parent.right; }
          anchors.margins: parent.borderWidth + TibiaStyle.marginRelated
          columns: 4
          columnSpacing: TibiaStyle.marginUnrelated

          TibiaCheckBox {
            text: qsTrId("charinfo_items_inventory")
            shouldBeChecked: itemSummary != null && itemSummary.showInventory

            onCheckedChanged: {
              if (itemSummary != null) {
                itemViewLoader.filterSettingsChanged()
                itemSummary.showInventory = checked
              }
            }
          } // TibiaCheckBox

          TibiaCheckBox {
            text: qsTrId("charinfo_items_depot")
            shouldBeChecked: itemSummary != null && itemSummary.showDepot

            onCheckedChanged: {
              if (itemSummary != null) {
                itemViewLoader.filterSettingsChanged()
                itemSummary.showDepot = checked
              }
            }
          } // TibiaCheckBox

          TibiaCheckBox {
            text: qsTrId("charinfo_items_inbox")
            shouldBeChecked: itemSummary != null && itemSummary.showInbox

            onCheckedChanged: {
              if (itemSummary != null) {
                itemViewLoader.filterSettingsChanged()
                itemSummary.showInbox = checked
              }
            }
          } // TibiaCheckBox

          TibiaTextField {
            id: nameFilterText
            maximumLength: 50
            placeholderText: qsTrId("type_to_search_placeholder")
            Layout.rowSpan: 2
            Layout.alignment: Qt.AlignRight
            Layout.preferredWidth: 120

            onTextChanged: {
              if (itemSummary != null) {
                itemViewLoader.filterSettingsChanged()
                itemSummary.updateNameFilter(text);
              }
            }
          } // TibiaTextField

          Item {
            Layout.preferredWidth: 1
            // Filler item to keep this cell empty
          }

          TibiaCheckBox {
            text: qsTrId("charinfo_items_stash")
            shouldBeChecked: itemSummary != null && itemSummary.showStash

            onCheckedChanged: {
              if (itemSummary != null) {
                itemViewLoader.filterSettingsChanged()
                itemSummary.showStash = checked
              }
            }
          } // TibiaCheckBox

          TibiaCheckBox {
            text: qsTrId("charinfo_items_storeinbox")
            shouldBeChecked: itemSummary != null && itemSummary.showStoreInbox

            onCheckedChanged: {
              if (itemSummary != null) {
                itemViewLoader.filterSettingsChanged()
                itemSummary.showStoreInbox = checked
              }
            }
          } // TibiaCheckBox
        } // GridLayout
      } // TibiaFrame2PixelUpFilled

      TibiaFrame2PixelUpFilled {
        Layout.fillWidth: true
        Layout.preferredHeight: 20

        RowLayout {
          spacing: 4 * TibiaStyle.marginRelated
          anchors.centerIn: parent

          ButtonGroup {
            id: layoutExclusiveGroup
            checkedButton: listStyleButton
          } //ButtonGroup

          TibiaRadioButton {
            id: listStyleButton
            text: qsTrId("charinfo_items_layout_list")
            ButtonGroup.group: layoutExclusiveGroup
          } //TibiaRadioButton

          TibiaRadioButton {
            id: gridStyleButton
            text: qsTrId("charinfo_items_layout_grid")
            ButtonGroup.group: layoutExclusiveGroup
          } //TibiaRadioButton
        } // RowLayout
      } // TibiaFrame2PixelUpFilled

      Loader {
        id: itemViewLoader

        Layout.fillWidth: true
        Layout.fillHeight: true

        function filterSettingsChanged() {
          if (status == Loader.Ready) {
            item.filterSettingsChanged();
          }
        }

        sourceComponent: {
          if (layoutExclusiveGroup.checkedButton == listStyleButton) {
            return itemTableViewComponent;
          } else {
            return itemGridViewComponent;
          }
        }
      } // Loader

    } // ColumnLayout
  } // itemsComponent

  Component {
    id: outfitsMountsSummonSkinsComponent

      ColumnLayout {
        anchors.fill: parent
        spacing: TibiaStyle.marginRelated

        TibiaFrame2PixelUpFilled {
          Layout.fillWidth: true
          Layout.preferredHeight: sourceFilterComboBox.height + marginsToContent * 2

          RowLayout {
            spacing: 4 * TibiaStyle.marginRelated
            anchors { left: parent.left; top: parent.top; right: parent.right }
            anchors.margins: parent.marginsToContent

            ButtonGroup {
              id: showOutfitsMountsExclusiveGroup
              property bool outfitsSelected: (controller != null && controller.outfitMountModel != null) ?
                                              (controller.outfitMountModel.typeFilter == OutfitMountSummonSkinsListDataModelSortFilterProxy.Outfits)
                                             : true
              onOutfitsSelected: {
                if (outfitsSelected) {
                  checkedButton = outfitsRadioButton;
                } else {
                  checkedButton = mountsRadioButton;
                }
              } //onAllowEveryoneSelectedChanged

              checkedButton: outfitsRadioButton
              onCheckedButtonChanged: {
                if (controller != null && controller.outfitMountModel != null) {
                  if (checkedButton == outfitsRadioButton) {
                    controller.outfitMountModel.typeFilter = OutfitMountSummonSkinsListDataModelSortFilterProxy.Outfits;
                  } else if (checkedButton == mountsRadioButton) {
                    controller.outfitMountModel.typeFilter = OutfitMountSummonSkinsListDataModelSortFilterProxy.Mounts;
                  } else {
                    controller.outfitMountModel.typeFilter = OutfitMountSummonSkinsListDataModelSortFilterProxy.SummonSkins;
                  }
                }
              } //onCheckedButtonChanged

            } //ButtonGroup


            TibiaRadioButton {
              id: outfitsRadioButton
              text: qsTrId("charinfo_outfitsmounts_typefilter_outfits")
              ButtonGroup.group: showOutfitsMountsExclusiveGroup
            } //TibiaRadioButton

            TibiaRadioButton {
              id: mountsRadioButton
              text: qsTrId("charinfo_outfitsmounts_typefilter_mounts")
              ButtonGroup.group: showOutfitsMountsExclusiveGroup
            } //TibiaRadioButton

            TibiaRadioButton {
              id: summonSkinsRadioButton
              text: qsTrId("charinfo_outfitsmounts_typefilter_summonskins")
              ButtonGroup.group: showOutfitsMountsExclusiveGroup
            } //TibiaRadioButt

            TibiaComboBox {
              id: sourceFilterComboBox
              Layout.fillWidth: true
              property var listModelOutfits : ListModel {
                ListElement { text: qsTrId("charinfo_outfits_sourcefilter_all") }
                ListElement { text: qsTrId("charinfo_outfits_sourcefilter_standard") }
                ListElement { text: qsTrId("charinfo_outfits_sourcefilter_quest") }
                ListElement { text: qsTrId("charinfo_outfits_sourcefilter_store") }
              }
              property var listModelMounts: ListModel {
                ListElement { text: qsTrId("charinfo_mounts_sourcefilter_all") }
                ListElement { text: qsTrId("charinfo_mounts_sourcefilter_quest") }
                ListElement { text: qsTrId("charinfo_mounts_sourcefilter_store") }
              }
              property var listModelSummonSkins : ListModel {
                ListElement { text: qsTrId("charinfo_summonskins_sourcefilter_all") }
                ListElement { text: qsTrId("charinfo_summonskins_sourcefilter_standard") }
                ListElement { text: qsTrId("charinfo_summonskins_sourcefilter_quest") }
                //ListElement { text: qsTrId("charinfo_summonskins_sourcefilter_store") }
              }

              model: {
                if(controller != null && controller.outfitMountModel != null) {
                  if (controller.outfitMountModel.typeFilter == OutfitMountSummonSkinsListDataModelSortFilterProxy.Outfits) {
                    return listModelOutfits;
                  } else if (controller.outfitMountModel.typeFilter == OutfitMountSummonSkinsListDataModelSortFilterProxy.Mounts) {
                    return listModelMounts;
                  } else if (controller.outfitMountModel.typeFilter == OutfitMountSummonSkinsListDataModelSortFilterProxy.SummonSkins) {
                    return listModelSummonSkins;
                  }
                }
                return null;
              }

              shouldBeCurrentIndex: {
                if (   controller != null
                    && controller.outfitMountModel != null
                    && controller.outfitMountModel.sourceFilter) {
                  //prevent invalid combinations
                  if (   controller.outfitMountModel.typeFilter == OutfitMountSummonSkinsListDataModelSortFilterProxy.Mounts
                      && controller.outfitMountModel.sourceFilter != OutfitMountSummonSkinsListDataModelSortFilterProxy.All) {
                    return controller.outfitMountModel.sourceFilter -1;
                  }
                  if (   controller.outfitMountModel.typeFilter == OutfitMountSummonSkinsListDataModelSortFilterProxy.SummonSkins
                      && controller.outfitMountModel.sourceFilter == OutfitMountSummonSkinsListDataModelSortFilterProxy.Store) {
                    return 0;
                  }
                }
                return 0;
              }

              onCurrentIndexChanged: {
                if (controller != null && controller.outfitMountModel != null && model != null) {
                  //fix off by one
                  if (   controller.outfitMountModel.typeFilter == OutfitMountSummonSkinsListDataModelSortFilterProxy.Mounts
                      && currentIndex != 0) {
                      controller.outfitMountModel.sourceFilter = currentIndex + 1;
                  } else {
                    controller.outfitMountModel.sourceFilter = currentIndex;
                  }
                }
              } //onCurrentIndexChanged
            } //TibiaComboBox

          } // RowLayout

        } // TibiaFrame2PixelUpFilled


        TibiaFrame1PixelDown {
          Layout.fillWidth: true
          Layout.fillHeight: true
          Layout.alignment: Qt.AlignHCenter


          TibiaScrollView {
            id: outfitsScrollView
            anchors.fill: parent
            anchors.topMargin: parent.borderWidth
            anchors.bottomMargin: parent.borderWidth
            anchors.rightMargin: parent.borderWidth

            GridView {
              id: outfitsMountsList
              leftMargin: TibiaStyle.marginRelated
              topMargin: TibiaStyle.marginRelated
              rightMargin:TibiaStyle.marginRelated
              bottomMargin: TibiaStyle.marginRelated

              boundsBehavior: Flickable.StopAtBounds

              readonly property int elementWidth: 152
              readonly property int elmentHeight: 110
              cellWidth: elementWidth + TibiaStyle.marginRelated
              cellHeight: elmentHeight + TibiaStyle.marginRelated


              footer: Item {
                height: TibiaStyle.marginRelated
                width: TibiaStyle.marginRelated
              }

              model: controller != null ? controller.outfitMountModel : null

              delegate: TibiaButton {
                id: outfitBorder
                width: outfitsMountsList.elementWidth
                height: outfitsMountsList.elmentHeight

                ColumnLayout {
                  id: outfitColumnLayout
                  anchors.fill: parent
                  anchors.margins: TibiaStyle.marginRelated
                  spacing: TibiaStyle.marginRelated

                  OutfitAppearanceInstanceRenderer {
                    id: outftitMountRenderer
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 64
                    Layout.preferredHeight: 64

                    animated: true
                    center: true
                    scaleFactor: Layout.preferredWidth / 64

                    outfitId:    model != null ? model.outfitID : 0
                    headColor:   controller != null ? controller.outfitMountModel.headColor : "black"
                    torsoColor:  controller != null ? controller.outfitMountModel.torsoColor : "black"
                    legsColor:   controller != null ? controller.outfitMountModel.legsColor : "black"
                    detailColor: controller != null ? controller.outfitMountModel.detailColor : "black"
                    firstAddOn:  model != null ? model.hasFirstAddon : false
                    secondAddOn: model != null ? model.hasSecondAddon : false
                  } // OutfitAppearanceInstanceRenderer

                  Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    RowLayout {
                      id: innerRowLayout
                      anchors.horizontalCenter: parent.horizontalCenter
                      anchors.top: parent.top
                      anchors.topMargin: TibiaStyle.marginRelated
                      spacing: TibiaStyle.marginRelated
                      TibiaText {
                        id: nameText
                        Layout.maximumWidth: outfitBorder.width - innerRowLayout.spacing - outfitColumnLayout.spacing*2
                        text: model != null? model.name : ""
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        horizontalAlignment: Text.AlignHCenter
                      } // TibiaText

                    } // RowLayout


                  } // Item
                } // ColumnLayout


                Image {
                  id: iconStore
                  anchors.top: parent.top
                  anchors.right: parent.right
                  anchors.topMargin: TibiaStyle.marginRelated
                  anchors.rightMargin: TibiaStyle.marginRelated
                  visible: model != null ? (model.source == OutfitsMountsSummonSkinsModel.Store) : false
                  source: "/images/icon-tibiastore.png"
                  Tooltip {
                    anchors.fill: parent
                    text: model != null ? (controller.outfitMountModel.typeFilter == OutfitMountSummonSkinsListDataModelSortFilterProxy.Outfits ? qsTrId("charinfo_outfitsmounts_tooltip_storeoutfits") : qsTrId("charinfo_outfitsmounts_tooltip_storemounts")) : ""
                  } // Tooltip
                } // Image

                onClicked: {
                  if (controller && model) {
                    controller.openOutfitDialog(model.outfitID,
                                                model.isOutfit,
                                                model.isMount,
                                                model.isSummonSkin);
                  }
                } // onClicked

                onHoveredChanged: {
                  if (hovered) {
                    if(tibiaMouseCursorController != null) { tibiaMouseCursorController.setPointingHand(true); }
                  } else {
                    if(tibiaMouseCursorController != null) { tibiaMouseCursorController.setPointingHand(false); }
                  }
                }
              } // TibiaButton
            } // GridView
          } // TibiaScrollView
        } // TibiaFrame1PixelDown
      } // ColumnLayout
  } // outfitsMountsSummonSkinsComponent

  Component {
    id: storePurchasesComponent

    TibiaFrame1PixelDown {
      property var storePurchases: controller != null ? controller.storePurchases : null

      TibiaScrollView {
        anchors.fill: parent
        anchors.margins: parent.borderWidth

        Flickable {
          contentHeight: storePurchasesLayout.height + TibiaStyle.marginRelated * 2

          interactive: false //prevent flick behavior on touch screens
          boundsBehavior: Flickable.StopAtBounds
          pixelAligned: true

          ColumnLayout {
            id: storePurchasesLayout
            spacing: TibiaStyle.marginUnrelated
            anchors { top: parent.top; left: parent.left; right: parent.right;
                      topMargin: TibiaStyle.marginRelated;
                      leftMargin: TibiaStyle.marginRelated;
                      rightMargin: TibiaStyle.marginUnrelated; }

            TibiaFrame2PixelUpFilledWithCaption {
              caption: qsTrId("charinfo_store_xpboosts")
              Layout.preferredHeight: xpBoostsLayout.height + topMarginToContent + marginsToContent
              Layout.fillWidth: true

              GridLayout {
                id: xpBoostsLayout
                anchors { left: parent.left; right: parent.right; top: parent.top;
                          topMargin: parent.topMarginToContent; leftMargin: parent.marginsToContent;
                          rightMargin: parent.marginsToContent; }
                columns: 2

                TibiaText {
                  text: qsTrId("charinfo_store_storexpboost_time")
                  Layout.fillWidth: true
                }

                TibiaText {
                  text: storePurchases != null ? storePurchases.remainingStoreXpBoost : qsTrId("dummy_unknown")
                }

                TibiaText {
                  text: qsTrId("charinfo_store_dailyrewardxpboost_time")
                  Layout.fillWidth: true
                }

                TibiaText {
                  text: storePurchases != null ? storePurchases.remainingDailyRewardXpBoost : qsTrId("dummy_unknown")
                }
              } // GridLayout
            } // TibiaFrame2PixelUpFilledWithCaption

            TibiaFrame2PixelUpFilledWithCaption {
              caption: qsTrId("charinfo_store_blessings")
              Layout.preferredHeight: blessingsLayout.height + topMarginToContent + marginsToContent
              Layout.fillWidth: true

              ColumnLayout {
                id: blessingsLayout
                anchors { left: parent.left; right: parent.right; top: parent.top;
                          topMargin: parent.topMarginToContent; leftMargin: parent.marginsToContent;
                          rightMargin: parent.marginsToContent; }

                TibiaText {
                  text: qsTrId("charinfo_store_available_blessings")
                }

                GridView {
                  id: storeBlessingsList
                  model: storePurchases != null ? storePurchases.storeBlessings : null
                  Layout.preferredHeight: contentHeight
                  Layout.leftMargin: TibiaStyle.marginUnrelated
                  Layout.rightMargin: TibiaStyle.marginRelated
                  Layout.fillWidth: true
                  visible: count > 0
                  cellHeight: 15
                  cellWidth: width / 2

                  interactive: false //prevent flick behavior on touch screens
                  boundsBehavior: Flickable.StopAtBounds
                  pixelAligned: true

                  delegate: RowLayout {
                    TibiaText {
                      id: blessingCount
                      text: qsTrId("charinfo_store_count_display").arg(model.count)
                    }

                    TibiaText {
                      id: blessingName
                      text: model.name
                      Layout.fillWidth: true
                    }
                  } // RowLayout
                } // ListView

                TibiaText {
                  text: qsTrId("none")
                  visible: storeBlessingsList.count == 0
                  Layout.leftMargin: TibiaStyle.marginUnrelated
                } // TibiaText
              } // ColumnLayout
            } // TibiaFrame2PixelUpFilledWithCaption

            TibiaFrame2PixelUpFilledWithCaption {
              caption: qsTrId("charinfo_store_prey")
              Layout.preferredHeight: preyLayout.height + topMarginToContent + marginsToContent
              Layout.fillWidth: true

              GridLayout {
                id: preyLayout
                anchors { left: parent.left; right: parent.right; top: parent.top;
                          topMargin: parent.topMarginToContent; leftMargin: parent.marginsToContent;
                          rightMargin: parent.marginsToContent; }
                columns: 2

                TibiaText {
                  text: qsTrId("charinfo_store_preyslots")
                  Layout.fillWidth: true
                }

                TibiaText {
                  text: storePurchases != null ? qsTrId("charinfo_store_count_display").arg(storePurchases.preySlots) : qsTrId("dummy_unknown")
                }

                TibiaText {
                  text: qsTrId("charinfo_store_preywildcards")
                  Layout.fillWidth: true
                }

                TibiaText {
                  text: storePurchases != null ? qsTrId("charinfo_store_count_display").arg(storePurchases.preyWildcards) : qsTrId("dummy_unknown")
                }

              } // GridLayout
            } // TibiaFrame2PixelUpFilledWithCaption

            TibiaFrame2PixelUpFilledWithCaption {
              caption: qsTrId("charinfo_store_task")
              Layout.preferredHeight: taskLayout.height + topMarginToContent + marginsToContent
              Layout.fillWidth: true

              GridLayout {
                id: taskLayout
                anchors { left: parent.left; right: parent.right; top: parent.top;
                          topMargin: parent.topMarginToContent; leftMargin: parent.marginsToContent;
                          rightMargin: parent.marginsToContent; }
                columns: 2

                TibiaText {
                  text: qsTrId("charinfo_store_permanent_weekly_task_expansion")
                  Layout.fillWidth: true
                }

                TibiaText {
                  text: storePurchases != null && storePurchases.purchasedPermanentWeeklyTaskExpansion ?  qsTrId("yes") : qsTrId("no")
                }

              } // GridLayout
            } // TibiaFrame2PixelUpFilledWithCaption

            TibiaFrame2PixelUpFilledWithCaption {
              caption: qsTrId("charinfo_store_dailyreward")
              Layout.preferredHeight: dailyRewardLayout.height + topMarginToContent + marginsToContent
              Layout.fillWidth: true

              RowLayout {
                id: dailyRewardLayout
                anchors { left: parent.left; right: parent.right; top: parent.top;
                          topMargin: parent.topMarginToContent; leftMargin: parent.marginsToContent;
                          rightMargin: parent.marginsToContent; }

                TibiaText {
                  text: qsTrId("charinfo_store_collectiontokens")
                  Layout.fillWidth: true
                }

                TibiaText {
                  text: storePurchases != null ? qsTrId("charinfo_store_count_display").arg(storePurchases.collectionTokens) : qsTrId("dummy_unknown")
                }
              } // RowLayout
            } // TibiaFrame2PixelUpFilledWithCaption

            TibiaFrame2PixelUpFilledWithCaption {
              caption: qsTrId("charinfo_store_charms")
              Layout.preferredHeight: charmsLayout.height + topMarginToContent + marginsToContent
              Layout.fillWidth: true

              RowLayout {
                id: charmsLayout
                anchors { left: parent.left; right: parent.right; top: parent.top;
                          topMargin: parent.topMarginToContent; leftMargin: parent.marginsToContent;
                          rightMargin: parent.marginsToContent; }

                TibiaText {
                  text: qsTrId("charinfo_store_charmexpansion")
                  Layout.fillWidth: true
                }

                TibiaText {
                  text: storePurchases != null && storePurchases.hasCharmExpansion ?  qsTrId("yes") : qsTrId("no")
                }
              } // RowLayout
            } // TibiaFrame2PixelUpFilledWithCaption

            TibiaFrame2PixelUpFilledWithCaption {
              caption: qsTrId("charinfo_store_hirelings")
              Layout.preferredHeight: hirelingsLayout.height + topMarginToContent + marginsToContent
              Layout.fillWidth: true

              ColumnLayout {
                id: hirelingsLayout
                anchors { left: parent.left; right: parent.right; top: parent.top;
                          topMargin: parent.topMarginToContent; leftMargin: parent.marginsToContent;
                          rightMargin: parent.marginsToContent; }

                RowLayout {
                  TibiaText {
                    text: qsTrId("charinfo_store_hireling_count")
                    Layout.fillWidth: true
                  }

                  TibiaText {
                    text: storePurchases != null ? qsTrId("charinfo_store_count_display").arg(storePurchases.hirelings) : qsTrId("dummy_unknown")
                  }
                } // RowLayout

                TibiaText {
                  text: qsTrId("charinfo_store_hireling_jobs")
                }

                GridView {
                  id: hirelingJobsList
                  model: storePurchases != null ? storePurchases.hirelingJobs : null
                  Layout.preferredHeight: contentHeight
                  Layout.leftMargin: TibiaStyle.marginUnrelated
                  Layout.fillWidth: true
                  cellHeight: 15
                  cellWidth: width / 2
                  visible: count > 0

                  interactive: false //prevent flick behavior on touch screens
                  boundsBehavior: Flickable.StopAtBounds
                  pixelAligned: true

                  delegate: TibiaText {
                    Layout.leftMargin: TibiaStyle.marginUnrelated
                    text: modelData
                  }
                } // ListView

                TibiaText {
                  text: qsTrId("none")
                  visible: hirelingJobsList.count == 0
                  Layout.leftMargin: TibiaStyle.marginUnrelated
                }

                TibiaText {
                  text: qsTrId("charinfo_store_hireling_outfits")
                }

                ListView {
                  id: hirelingOutfitsList
                  model: storePurchases != null ? storePurchases.hirelingOutfits : null
                  Layout.preferredHeight: contentHeight
                  Layout.leftMargin: TibiaStyle.marginUnrelated
                  spacing: TibiaStyle.marginNarrow
                  visible: count > 0

                  delegate: RowLayout {
                    TibiaText {
                      text: qsTrId("charinfo_store_count_display").arg(model.count)
                    }

                    TibiaText {
                      text: model.name
                    }
                  } // RowLayout
                } // ListView

                TibiaText {
                  text: qsTrId("none")
                  visible: hirelingOutfitsList.count == 0
                  Layout.leftMargin: TibiaStyle.marginUnrelated
                }
              } // ColumnLayout
            } // TibiaFrame2PixelUpFilledWithCaption

            TibiaFrame2PixelUpFilledWithCaption {
              caption: qsTrId("charinfo_store_available_house_items")
              Layout.preferredHeight: houseItemsLayout.height + topMarginToContent + marginsToContent
              Layout.fillWidth: true

              ColumnLayout {
                id: houseItemsLayout
                anchors { left: parent.left; right: parent.right; top: parent.top;
                          topMargin: parent.topMarginToContent; leftMargin: parent.marginsToContent;
                          rightMargin: parent.marginsToContent; }

                GridView {
                  id: houseItemsList
                  model: storePurchases != null ? storePurchases.houseItems : null
                  Layout.preferredHeight: contentHeight
                  Layout.fillWidth: true
                  visible: count > 0
                  cellWidth: width / 2
                  cellHeight: 78 // Manually fitted height to 64px renderer + margins on top and bottom

                  interactive: false //prevent flick behavior on touch screens
                  boundsBehavior: Flickable.StopAtBounds
                  pixelAligned: true

                  delegate: TibiaFrame2PixelUpFilled {
                    width: houseItemsList.cellWidth - TibiaStyle.marginNarrow * 2
                    height: houseItemsList.cellHeight - TibiaStyle.marginNarrow * 2
                    x: TibiaStyle.marginNarrow
                    y: TibiaStyle.marginNarrow

                    TibiaFrame1PixelDown {
                      id: houseItemBorder
                      anchors { left: parent.left; top: parent.top; }
                      anchors.margins: parent.borderWidth + TibiaStyle.marginNarrow
                      width: 64 + borderWidth
                      height: width

                      AppearanceInstanceRenderer {
                        id: houseItemRenderer
                        anchors.fill: parent
                        anchors.margins: parent.borderWidth

                        smoothTextureFiltering: false
                        center: true
                        animated: true

                        Component {
                          id: objectComponent

                          ObjectAppearanceInstance {
                            position: Qt.point(0, 0)
                          }
                        } // Component

                        Component.onCompleted: {
                          var newApperanceInstance = objectComponent.createObject(houseItemRenderer);
                          newApperanceInstance.typeid = model.appearanceTypeID;
                          newApperanceInstance.hookDirection = ObjectAppearanceInstance.SOUTH;
                          houseItemRenderer.appearanceInstances = [newApperanceInstance];
                        }
                      } // AppearanceInstanceRenderer
                    } // TibiaFrame1PixelDown

                    TibiaText {
                      anchors { left: houseItemBorder.right; leftMargin: TibiaStyle.marginRelated;
                                top: parent.top; topMargin: parent.borderWidth + TibiaStyle.marginNarrow;
                                right: parent.right; rightMargin: parent.borderWidth + TibiaStyle.marginNarrow }
                      text: qsTrId("charinfo_store_house_item_and_count").arg(model.name).arg(model.count)
                      wrapMode: Text.Wrap
                    }
                  } // TibiaFrame2PixelUpFilled
                } // ListView

                TibiaText {
                  text: qsTrId("none")
                  visible: houseItemsList.count == 0
                  Layout.leftMargin: TibiaStyle.marginUnrelated
                }
              } // ColumnLayout
            } // TibiaFrame2PixelUpFilledWithCaption
          } // ColumnLayout
        } // Flickable
      } // TibiaScrollView
    } // TibiaFrame1PixelDown
  } // storePurchasesComponent

  Component {
    id: inspectCharacterComponent

    TibiaFrame1PixelDown {
      id: border
      property bool applyDualWielding: false
      property int dualWieldingObjectID: 0

      InspectPlayerLayout {
        id: inspectLayout
        anchors.fill: parent
        anchors.margins: parent.marginsToContent

        inspectObjectList: controller != null ? controller.inspectPlayerList : null
        applyDualWielding: border.applyDualWielding
        dualWieldingObjectID: border.dualWieldingObjectID

        clientSettingSmoothFiltering: controller != null && controller.clientSettingSmoothFiltering
      } //InspectPlayerLayout

      TibiaButton {
        text: qsTrId("inspect_open_weapon_proficiency_dialog")
        tooltipText: qsTrId("inspect_open_weapon_proficiency_dialog_tooltip")
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: TibiaStyle.marginUnrelated
        visible: inspectLayout.currentSelectedObject != null && inspectLayout.currentSelectedObject.hasProficiency
          && controller != null && controller.characterBaseInfo != null && controller.characterBaseInfo.isOwnCharacter
        width: TibiaStyle.buttonWidthBroad * 2

        onClicked: {
          controller.openWeaponProficiencyDialog(inspectLayout.currentSelectedObject.appearanceID);
        }
      } // TibiaButton

    } //TibiaFrame1PixelDown
  } //Component inspectCharacterComponent

  Component {
    id: titlesComponent

    ColumnLayout {
      id: titlesLayout
      anchors.fill: parent
      spacing: TibiaStyle.marginRelated

      property var titleInfo: controller != null ? controller.titlesInfo : null

      TibiaFrame2PixelUpFilledWithCaption {
        id: currentTitleBox
        Layout.fillWidth: true
        Layout.preferredHeight: topMarginToContent + Math.max(currentTitleText.height, titleActionsLayout.height) + marginsToContent

        caption: qsTrId("charinfo_character_title_current_caption")


        TibiaText {
          id: currentTitleText
          anchors { left: parent.left; right: titleActionsLayout.left;
                    verticalCenter: titleActionsLayout.verticalCenter;
                    leftMargin: parent.marginsToContent + titleActionsLayout.width;
                    rightMargin: parent.marginsToContent; }
          horizontalAlignment: Text.AlignHCenter
          text: titleInfo != null ? titleInfo.currentTitle : ""
          styleType: titleInfo && !titleInfo.isCurrentTitleActive ? "Caption" : "Default"
        } //TibiaText

        RowLayout {
          id: titleActionsLayout
          anchors { right: parent.right; top: parent.top;
                    topMargin: parent.topMarginToContent;
                    rightMargin: parent.marginsToContent }

          TibiaGuiHelp {
            text: qsTrId("charinfo_character_title_temporarily_disabled")
            visible: titleInfo && !titleInfo.isCurrentTitleActive
            color: "orange"
          } //TibiaGuiHelp

          TibiaButton {
            Layout.preferredWidth: TibiaStyle.iconButtonSize
            Layout.preferredHeight: TibiaStyle.iconButtonSize
            imageSourceUp: "/images/icon-delete.png"

            tooltipText: qsTrId("charinfo_character_title_clear_tooltip")
            enabled: titleInfo && titleInfo.hasCurrentTitle
            opacity: enabled ? 1 : 0

            onClicked: {
              if (controller != null) {
                controller.resetCharacterTitle();
              }
            } //onClicked
          } //TibiaIconButton
        } // RowLayout
      } //TibiaFrame2PixelUpFilledWithCaption

      TibiaFrame2PixelUpFilledWithCaption {
        Layout.fillWidth: true
        Layout.fillHeight :true

        caption: qsTrId("charinfo_character_title_available_caption")

        ColumnLayout {
          id: filterRow
          property var titlesModel : titleInfo != null ? titleInfo.titlesModel : null

          anchors.fill: parent
          anchors.margins: parent.marginsToContent
          anchors.topMargin: parent.topMarginToContent
          spacing: TibiaStyle.marginRelated

          GridLayout {
            id: filterBoxTitles
            Layout.fillWidth: true
            columns: 4
            rows: 2
            columnSpacing: TibiaStyle.marginUnrelated
            flow: GridLayout.TopToBottom


            ButtonGroup {
              id: showFilterGroup

              checkedButton: {
                if (filterRow.titlesModel != null) {
                  if (filterRow.titlesModel.titleFilter == TitlesModel.ShowAllTitles) {
                    return showAllTitlesButton;
                  } else if (filterRow.titlesModel.titleFilter == TitlesModel.ShowPermanentTitles) {
                    return showPermanentTitlesButton;
                  } else if (filterRow.titlesModel.titleFilter == TitlesModel.ShowTemporaryTitles) {
                    return showTemporaryTitlesButton;
                  } else if (filterRow.titlesModel.titleFilter == TitlesModel.ShowUnlockedTitles) {
                    return showUnlockedTitlesButton;
                  } else if (filterRow.titlesModel.titleFilter == TitlesModel.ShowLockedTitles) {
                    return showLockedTitlesButton;
                  }
                }
                return null;
              }
            }

            TibiaRadioButton {
              id: showAllTitlesButton
              ButtonGroup.group: showFilterGroup
              text: qsTrId("charinfo_character_title_all")

              onClicked: {
                if (filterRow.titlesModel != null) {
                  filterRow.titlesModel.titleFilter = TitlesModel.ShowAllTitles;
                }
              }
            }
            TibiaRadioButton {
              id: showPermanentTitlesButton
              Layout.row: 0
              Layout.column: 1
              ButtonGroup.group: showFilterGroup
              text: qsTrId("charinfo_character_title_permanent")

              onClicked: {
                if (filterRow.titlesModel != null) {
                  filterRow.titlesModel.titleFilter = TitlesModel.ShowPermanentTitles;
                }
              }
            }
            TibiaRadioButton {
              id: showTemporaryTitlesButton
              ButtonGroup.group: showFilterGroup
              text: qsTrId("charinfo_character_title_temporary")

              onClicked: {
                if (filterRow.titlesModel != null) {
                  filterRow.titlesModel.titleFilter = TitlesModel.ShowTemporaryTitles;
                }
              }
            }
            TibiaRadioButton {
              id: showUnlockedTitlesButton
              ButtonGroup.group: showFilterGroup
              text: qsTrId("charinfo_character_title_unlocked")

              onClicked: {
                if (filterRow.titlesModel != null) {
                  filterRow.titlesModel.titleFilter = TitlesModel.ShowUnlockedTitles;
                }
              }
            }
            TibiaRadioButton {
              id: showLockedTitlesButton
              ButtonGroup.group: showFilterGroup
              text: qsTrId("charinfo_character_title_locked")

              onClicked: {
                if (filterRow.titlesModel != null) {
                  filterRow.titlesModel.titleFilter = TitlesModel.ShowLockedTitles;
                }
              }
            }

            RowLayout {
              Layout.rowSpan: 2
              Layout.alignment: Qt.AlignVCenter
              TibiaFrame1PixelDown {
                id: nameFilterFrame
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Layout.preferredHeight: TibiaStyle.textFieldHeight

                RowLayout {
                  anchors.fill: parent
                  spacing: 0

                  TibiaTextField {
                    property string nameFilter: filterRow.titlesModel != null ? filterRow.titlesModel.nameFilter : ""
                    onNameFilterChanged: {
                      if (this.text != nameFilter) {
                        this.text = nameFilter;
                        filterRefreshTimer.stop();
                      }
                    } //onNameFilterChanged

                    id: nameFilterText
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    maximumLength: TibiaStyle.maxCharacterNameLength
                    KeyNavigation.tab: nameFilterText
                    KeyNavigation.backtab: nameFilterText

                    placeholderText: qsTrId("type_to_search_placeholder")
                    text: nameFilter

                    onTextChanged: filterRefreshTimer.restart()

                    Timer {
                      id: filterRefreshTimer
                      interval: TibiaStyle.searchDelay

                      onTriggered: {
                        if (controller != null) {
                          titleTibiaTableView.filterSettingsChanged();
                          filterRow.titlesModel.nameFilter = nameFilterText.text;
                        }
                      } //onTriggered
                    } //Timer
                  } // TibiaTextField

                  TibiaButton {
                    Layout.topMargin: nameFilterFrame.borderWidth
                    Layout.bottomMargin: nameFilterFrame.borderWidth
                    Layout.rightMargin: nameFilterFrame.borderWidth
                    Layout.leftMargin: -nameFilterFrame.borderWidth
                    Layout.fillHeight: true
                    Layout.preferredWidth: height
                    imageSource: "/images/icon-erase-small.png"
                    tooltipText: qsTrId("clear_search_tooltip")

                    onClicked: {
                      nameFilterText.text = '';
                    } //onClicked
                  } //TibiaButton
                }
              } //RowLayout
            } //TibiaFrame1PixelDown
          }

          TibiaTableView {
            id: titleTibiaTableView
            Layout.fillHeight: true
            Layout.fillWidth: true

            model: titleInfo != null ? titleInfo.titlesModel : null

            function filterSettingsChanged() {
              if (rowCount > 0) {
                positionViewAtRow(0, ListView.Beginning);
              }
            }

            headerVisible: true

            TableViewColumn {
              role: "name"
              title: qsTrId("name")
              movable: false
              resizable: false
              width: titleTibiaTableView.contentItem.width
                     - isPermanentColumn.width
                     - isUnlockedColumn.width
              delegate: RowLayout {
                spacing: TibiaStyle.marginNarrow

                TibiaText {
                  Layout.fillWidth: true
                  Layout.leftMargin: TibiaStyle.marginNarrow

                  styleType: model != null && model.titleId == (titleInfo != null ? titleInfo.currentTitleId : 0)
                             ? "tableViewHighlight"
                             : styleData.selected ? "Default"
                                                  : "Dialog"

                  text: styleData.value
                }//TibiaText

                TibiaButton {
                  Layout.fillHeight: true
                  Layout.preferredWidth: height
                  Layout.topMargin: 1
                  Layout.bottomMargin: 1
                  imageSourceUp: "/images/icon-edit.png"
                  visible: styleData.selected && model != null && model.canBeChosen

                  onClicked: {
                    if (controller != null) {
                      controller.showContextMenuForCharacterTitleID(model.titleId)
                    }
                  } //onClicked
                } // TibiaButton


                TibiaVerticalSeparator {
                  Layout.fillHeight: true
                } //TibiaVerticalSeparator
              } //itemDelegate: RowLayout
            } //TableViewColumn

            TableViewColumn {
              id: isPermanentColumn
              role: "isPermanent"
              title: qsTrId("charinfo_character_title_table_permanent_header")
              movable: false
              resizable: false
              width: 80

              delegate: Item {
                Image {
                  anchors.centerIn: parent
                  source: model != null && model.isPermanent ? "/images/icon-yes.png" : "/images/icon-no.png"
                } //Image

                TibiaVerticalSeparator {
                  anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
                } // TibiaVerticalSeparator
              } //delegate: Item
            } // TableViewColumn

            TableViewColumn {
              id: isUnlockedColumn
              role: "isUnlocked"
              title: qsTrId("charinfo_character_title_table_unlocked_header")
              movable: false
              resizable: false
              width: 80

              delegate: Item {
                Image {
                  anchors.centerIn: parent
                  source: model != null && model.isUnlocked ? "/images/icon-yes.png" : "/images/icon-no.png"
                } //Image

                TibiaGuiHelp {
                  anchors.right: parent.right
                  anchors.rightMargin: TibiaStyle.marginNarrow
                  anchors.verticalCenter: parent.verticalCenter
                  visible: styleData.selected
                  text: model != null ? model.description : ""
                } //TibiaGuiHelp
              } //delegate: Item
            } // TableViewColumn
          } //TibiaTableView
        } //ColumnLayout
      } //TibiaFrame2PixelUpFilledWithCaption
    } //ColumnLayout
  } //Component titlesComponent

  Item {
    id: contentArea
    anchors { left: charInfoMenu.right; leftMargin: TibiaStyle.marginUnrelated;
              right: parent.right; top: parent.top; bottom: parent.bottom;
              bottomMargin: TibiaStyle.marginRelated }

    Loader {
      anchors.fill: parent
      visible: !characterInfoDialog.dataIsLoading
      sourceComponent: {
        if (controller.dialogCategory == CharacterInfoDialogController.GeneralStats) {
          return generalStatsComponent;
        } else if (controller.dialogCategory == CharacterInfoDialogController.OffenceStats && controller.offenceStats != null) {
          return offenceStatsComponent;
        } else if (controller.dialogCategory == CharacterInfoDialogController.DefenceStats && controller.defenceStats != null) {
          return defenceStatsComponent;
        } else if (controller.dialogCategory == CharacterInfoDialogController.MiscStats && controller.miscStats != null) {
          return miscStatsComponent;
        } else if (controller.dialogCategory == CharacterInfoDialogController.Deaths) {
          return deathsComponent;
        } else if (controller.dialogCategory == CharacterInfoDialogController.Kills) {
          return killsComponent;
        } else if (controller.dialogCategory == CharacterInfoDialogController.Achievements) {
          return achievementsComponent;
        } else if (controller.dialogCategory == CharacterInfoDialogController.Items) {
          return itemsComponent;
        } else if (controller.dialogCategory == CharacterInfoDialogController.OutfitsMountsSummonSkins) {
          return outfitsMountsSummonSkinsComponent;
        } else if (controller.dialogCategory == CharacterInfoDialogController.StorePurchases) {
          return storePurchasesComponent;
        } else if (controller.dialogCategory == CharacterInfoDialogController.InspectCharacter) {
          return inspectCharacterComponent;
        } else if (controller.dialogCategory == CharacterInfoDialogController.Titles) {
          return titlesComponent;
        }

        return null;
      } //sourceComponent

      onLoaded: {
        if (controller.dialogCategory == CharacterInfoDialogController.InspectCharacter) {
          item.applyDualWielding = Qt.binding(function() { return controller != null ? controller.hasDualWielding : null});
          item.dualWieldingObjectID = Qt.binding(function() { return controller != null ? controller.dualWieldingObjectID : null});
        }
      }
    } // Loader

    ColumnLayout {
      anchors.centerIn: parent
      visible: characterInfoDialog.dataIsLoading

      TibiaText {
        text: qsTrId("charinfo_data_loading")
      }

      Image {
        source: visible ? "/images/dynamic/dynamic-image-loading.png" : ""
        Layout.alignment: Qt.AlignHCenter
      }
    } // ColumnLayout
  } // Item
} // Item
