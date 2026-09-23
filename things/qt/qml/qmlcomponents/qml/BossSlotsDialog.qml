import QtQuick
import QtQuick.Layouts
import qmlcomponents



Item {
  id: bossSlotsDialog
  property var controller: null

  property var initialFocusItem: bossSlotsDialog
  KeyNavigation.tab: bossSlotsDialog

  property int maximumBosspoints: controller != null? controller.maximumBosspoints : 0
  property int currentBosspoints: controller != null? controller.currentBosspoints : 0
  property int currentLootBonus : controller != null? controller.currentLootBonus : 0
  property int nextLootBonus : controller != null? controller.nextLootBonus : 0

  property var firstSlot: controller != null? controller.firstSlot : null
  property var secondSlot: controller != null? controller.secondSlot : null
  property var boostedSlot: controller != null? controller.boostedSlot : null

  property var playerGoldBalance: controller != null? controller.playerGold : 0




  function calculateFillPercentage(Maximum, Current)
  {
    var MaximumValue = Math.max(Maximum, 1.0);
    var CurrentValue = Math.min(Math.max(Current, 0.0), MaximumValue);
    return CurrentValue / MaximumValue;
  }

  Component {
    id: firstSlotNotActive
    BossSlotNotActive {
      slotNumber: 1
      unlockBosspoints: firstSlot != null? firstSlot.unlockBosspoints : 0
    } // BossSlotNotActive
  } // Component

  Component {
    id: secondSlotNotActive
    BossSlotNotActive {
      slotNumber: 2
      unlockBosspoints: secondSlot != null? secondSlot.unlockBosspoints : 0
    } // BossSlotNotActive
  } // Component


  Component {
    id: bossFirstSlotSelection

    SelectBossView {

      controller: bossSlotsDialog.controller
      selectionModel: controller != null ? controller.firstSlotBossList : null
      slotNumber: 1
    } // SelectBossView

  } // Component

  Component {
    id: bossSecondSlotSelection

    SelectBossView {

      controller: bossSlotsDialog.controller
      selectionModel: controller != null ? controller.secondSlotBossList : null
      slotNumber: 2
    } // SelectBossView

  } // Component

  Component {
    id: bossSlotConfiguredFirstSlot

    ConfiguredBossSlot {

      selectedRaceID: firstSlot != null? firstSlot.raceID : 0
      numberOfKills: firstSlot != null? firstSlot.numberOfKills : 0
      numberOfKillsForProwess: firstSlot != null? firstSlot.killsForProwess : 0
      numberOfKillsForExpertise: firstSlot != null? firstSlot.killsForExpertise : 0
      numberOfKillsForMastery: firstSlot != null? firstSlot.killsForMastery : 0
      currentLootBonus: firstSlot!= null? firstSlot.currentLootBonus : 0
      priceForReset: firstSlot != null? firstSlot.priceForReset : "0"
      resetPriceNumber: firstSlot != null? firstSlot.resetPriceNumber : 0
      bossRaritySource: firstSlot != null? firstSlot.bossRaritySource : ""
      bossRarityTooltip: firstSlot != null ? firstSlot.bossRarityTooltip : ""
      bossName: firstSlot != null? firstSlot.name : ""
      slotNumber: 1
      isInBoostedSlot: firstSlot != null && firstSlot.isInBoostedSlot
      playerGold: playerGoldBalance

      controller: bossSlotsDialog.controller
    } // Configured Boss Slot

  } // Component

  Component {
    id: bossSlotConfiguredSecondSlot

    ConfiguredBossSlot {

      selectedRaceID: secondSlot!= null? secondSlot.raceID : 0
      numberOfKills: secondSlot != null? secondSlot.numberOfKills : 0
      numberOfKillsForProwess: secondSlot != null? secondSlot.killsForProwess : 0
      numberOfKillsForExpertise: secondSlot != null? secondSlot.killsForExpertise : 0
      numberOfKillsForMastery: secondSlot != null? secondSlot.killsForMastery : 0
      currentLootBonus: secondSlot != null? secondSlot.currentLootBonus : 0
      priceForReset: secondSlot != null? secondSlot.priceForReset : "0"
      resetPriceNumber: secondSlot != null? secondSlot.resetPriceNumber : 0
      bossRaritySource: secondSlot != null? secondSlot.bossRaritySource : ""
      bossRarityTooltip: secondSlot != null ? secondSlot.bossRarityTooltip : ""
      bossName: secondSlot != null? secondSlot.name: ""
      slotNumber: 2
      isInBoostedSlot: secondSlot != null && secondSlot.isInBoostedSlot
      playerGold: playerGoldBalance

      controller: bossSlotsDialog.controller
    } // Configured Boss Slot

  } // Component

  ColumnLayout {
    anchors.fill: parent

    TibiaPanel2PixelUpFilledWithCaption {
      caption: qsTrId("bosstiary_bosspoints_progress_caption")
      Layout.fillWidth: true
      Layout.preferredHeight: 48

      RowLayout {
        id: percentageRow
        Layout.fillWidth: true
        spacing: TibiaStyle.marginUnrelated
        Layout.alignment: Qt.AlignHCenter
        Layout.leftMargin: TibiaStyle.marginRelated
        Layout.rightMargin: TibiaStyle.marginRelated

        TibiaText {
          text: qsTrId("bosstiary_bosspoints_text")
        } // TibiaText

        TibiaProgressBar {
          Layout.preferredHeight: 20
          Layout.fillWidth: true
          fillPercentage: calculateFillPercentage(maximumBosspoints, currentBosspoints)

          frameSource: "/images/1pixel-down-frame.png"
          backgroundSource: "/images/backdrop-dark-grey.png"
          fillSource: "/images/progressbar-" + "orange" + "-large.png"

          frameBorder { left: 1; right: 1; top:1; bottom: 1}
          fillOffset { left: 1; right: 1; top:1; bottom: 1}

          TibiaText {
            anchors.centerIn: parent
            styleType: "White"
            text: currentBosspoints + "/" + maximumBosspoints
          } //TibiaText

        } //TibiaProgressBar

        TibiaText {
          text: qsTrId("bosstiary_bosspoints_unlock_lootbonus_text").arg(currentLootBonus).arg(nextLootBonus)
        } // TibiaText

        TibiaGuiHelp {
          text:qsTrId("bosstiary_bosspoints_unlock_lootbonus_tooltip")
        }

      } // RowLayout

    } // TibiaPanel2PixelUpFilledWithCaption

    RowLayout {
      id: slotsLayout
      Layout.fillWidth: true
      Layout.fillHeight: true
      spacing: 0

      Loader {
        Layout.preferredHeight: 360
        Layout.preferredWidth: parent.width / 3

        sourceComponent: firstSlot == null || !firstSlot.unlocked ? firstSlotNotActive : (firstSlot.raceID != 0 ? bossSlotConfiguredFirstSlot : bossFirstSlotSelection)

      } // Loader

      Item {
        id: boostedBossSlot

        Layout.preferredHeight: 360
        Layout.preferredWidth: parent.width / 3

        TibiaText {
          id: boostedBossText
          text: qsTrId("bosstiary_bosspoints_boosted_boss_text").arg(boostedSlot != null? boostedSlot.name : "")
          anchors.top: parent.top
          anchors.topMargin: TibiaStyle.marginNarrow
          anchors.right: parent.right
          anchors.left: parent.left
          anchors.leftMargin: TibiaStyle.marginNarrow
          anchors.rightMargin: TibiaStyle.marginNarrow
          horizontalAlignment: Text.AlignHCenter
        }

        Image {
          id: podestalImage
          source: '/images/boostedbosspodestal.png'
          anchors.top: boostedBossText.bottom
          anchors.topMargin: 2*TibiaStyle.marginUnrelated
          anchors.horizontalCenter: parent.horizontalCenter

          RaceAppearanceInstanceRenderer {
            id: monsterOutfit
            width: 64
            height: 64
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: 15
            anchors.bottomMargin: 19
            raceID: boostedSlot != null? boostedSlot.raceID : 0
            isUnknown: false
          } // RaceAppearanceInstanceRenderer

          Image {
            id: iconImage
            source: boostedSlot != null? boostedSlot.bossRaritySource : ""
            anchors { left: parent.left; leftMargin: -40;
                      top: parent.top; }

            Tooltip {
              anchors.fill: parent
              text: boostedSlot != null ? boostedSlot.bossRarityTooltip : ""
            }
          } // Image
        } // Image

        BosstiaryUnlockProgress {
          id: unlockProgress
          kills: boostedSlot != null? boostedSlot.numberOfKills : 0
          killsForProwess: boostedSlot != null? boostedSlot.killsForProwess : 0
          killsForExpertise: boostedSlot != null? boostedSlot.killsForExpertise : 0
          killsForMastery: boostedSlot != null? boostedSlot.killsForMastery : 0
          preferredProgressBarWidth: 128
          width: 230
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.top: podestalImage.bottom
          anchors.topMargin: TibiaStyle.marginUnrelated
        } // BosstiaryUnlockProgress


        TibiaText {
          id: lootBonusText
          text: qsTrId("bosstiary_bosspoints_current_lootbonus_text").arg(boostedSlot != null? boostedSlot.currentLootBonus : 0)
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.top: unlockProgress.bottom
          anchors.topMargin: TibiaStyle.marginUnrelated * 2 + 1
        } // TibiaText

        TibiaText {
          text: qsTrId("bosstiary_bosspoints_current_killbonus_text").arg(boostedSlot != null? boostedSlot.killBonus : 0)
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.top: lootBonusText.bottom
        } // TibiaText

      } // Item


      Loader {
        Layout.fillWidth: true
        Layout.preferredHeight: 360

        sourceComponent: secondSlot == null || !secondSlot.unlocked ? secondSlotNotActive : (secondSlot.raceID != 0 ? bossSlotConfiguredSecondSlot : bossSecondSlotSelection)

      } // Loader

    } // RowLayout

  } // ColumnLayout

} // Item
