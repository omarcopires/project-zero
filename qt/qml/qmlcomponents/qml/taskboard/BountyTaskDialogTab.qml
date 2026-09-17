import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtWebChannel
import QtWebEngine

import qmlcomponents
import "qrc:/qt/qml/qmlcomponents/qml/"
import QtQuick.LegacyControls

TibiaFrame2PixelUpFilled {
  id: root
  required property var controller

  property var bountyTasks: controller.bountyTasks
  property var monsterList: controller.monsterList
  property var preferredSlotData: controller.preferredSlotData

  function getTaskActionText(model) {
    if (model.canAccept) {
      return qsTrId("taskboard_get_task_label");
    }
    return qsTrId("taskboard_claim_reward_label");
  }

  function getTaskAction(model) {
    if (model.canAccept) {
      return function () {
        controller.acceptBountyTask(model.taskIndex);
      };
    }
    if (model.canClaim) {
      return function () {
        controller.claimReward();
      };
    }
    return null;
  }

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: TibiaStyle.marginUnrelated
    spacing: TibiaStyle.marginUnrelated

    BountyTaskSetupPanel {
      id: taskSetupPanel
      Layout.fillWidth: true
      Layout.preferredHeight: 58

      bountyTaskDifficulty: controller.bountyTaskDifficulty

      showPreferredList: function () {
        controller.showPreferredList = true;
      }

      selectBountyTaskDifficulty: function (newValue) {
        controller.setBountyTaskDifficulty(newValue);
      }

      canRerollTasks: controller.canRerollTasks
      rerollTasksAction: function () {
        controller.rerollTasksAction();
      }

      rerollTaskCost: controller != null ? controller.rerollTokenAmount : 0

      canClaimRerollToken: controller.canClaimRerollToken
      noClaimRerollTokenReason: controller.noClaimRerollTokenReason
      claimRerollTokenAction: function () {
        controller.claimRerollTokenAction();
      }
      limitOfRerollsReached: controller.limitOfRerollsReached
    }

    TibiaFrame1PixelDown {
      id: tasksInset
      Layout.fillWidth: true
      Layout.preferredHeight: tasks.height + (2 * TibiaStyle.marginUnrelated)

      BorderImage {
        source: "/images/background-dark.png"
        anchors.fill: parent
        anchors.margins: parent.borderWidth
        horizontalTileMode: BorderImage.Repeat
        verticalTileMode: BorderImage.Repeat
      }

      Row {
        id: tasks

        spacing: TibiaStyle.marginUnrelated

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        Repeater {
          model: bountyTasks

          BountyTaskPanel {
            id: panel
            taskIndex: model.taskIndex
            tooltipText: model.caption
            raceId: model.raceId
            killText: model.killText
            rewardXp: model.rewardXp
            rewardBountyPoints: model.rewardBountyPoints
            taskActionText: root.getTaskActionText(model)
            taskAction: root.getTaskAction(model)
            rerollLimitReached: controller.limitOfRerollsReached

            Image {
              source: model.taskTierImageSource
              anchors.top: parent.top
              anchors.horizontalCenter: parent.horizontalCenter
              anchors.topMargin: -TibiaStyle.marginRelated - 1

              TibiaText {
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: TibiaStyle.marginUnrelated + TibiaStyle.marginRelated
                text: model.caption
              }
            }
          }
        }
      }
    }

    TaskRingPanel {
      Layout.fillWidth: true
      Layout.preferredHeight: 122

      bonusDamagePerCent: controller.bonusDamagePerCent
      nextBonusDamagePerCent: controller.nextBonusDamagePerCent
      bonusDamageUpgradeAction: controller.canUpgradeBonusDamage ? function () {
        controller.upgradeBountyTalisman(0);
      } : null
      bonusDamageUpgradeCost: controller.bonusDamageUpgradeCost
      disabledBonusDamageTooltip: controller.disabledDamagePercentTooltip
      maximumReachedBonusDamage: controller.maximumReachedBonusDamage

      lifeLeechPerCent: controller.lifeLeechPerCent
      nextLifeLeechPerCent: controller.nextLifeLeechPerCent
      lifeLeechUpgradeAction: controller.canUpgradeLifeLeech ? function () {
        controller.upgradeBountyTalisman(1);
      } : null
      lifeLeechUpgradeCost: controller.lifeLeechUpgradeCost
      disabledLifeLeechPercentTooltip: controller.disabledLifeLeechPercentTooltip
      maximumReachedBonusLifeLeech: controller.maximumReachedBonusLifeLeech

      bonusLootPerCent: controller.bonusLootPerCent
      nextBonusLootPerCent: controller.nextBonusLootPerCent
      bonusLootUpgradeAction: controller.canUpgradeBonusLoot ? function () {
        controller.upgradeBountyTalisman(2);
      } : null
      bonusLootUpgradeCost: controller.bonusLootUpgradeCost
      disabledBonusLootTooltip: controller.disabledLootPercentTooltip
      maximumReachedBonusLoot: controller.maximumReachedBonusLoot

      doubleBestiaryChancePerCent: controller.doubleBestiaryChancePerCent
      nextDoubleBestiaryChancePerCent: controller.nextDoubleBestiaryChancePerCent
      doubleBestiaryChanceUpgradeAction: controller.canUpgradeDoubleBestiaryChance ? function () {
        controller.upgradeBountyTalisman(3);
      } : null
      doubleBestiaryChanceUpgradeCost: controller.doubleBestiaryChanceUpgradeCost
      disabledBonusBestiaryTooltip: controller.disabledBestiaryPercentTooltip
      maximumReachedBonusBestiary: controller.maximumReachedBonusBestiary
    }
  }

  TibiaDisabledOverlay {
    anchors.fill: parent
    anchors.margins: 1
    visible: controller.showPreferredList

    MouseArea {
      anchors.fill: parent
      onClicked: {}
    }

    PreferredList {
      anchors.centerIn: parent

      monsterList: root.monsterList
      preferredSlotData: root.preferredSlotData
      bountyPointsBalance: controller.bountyPointsBalance

      clearPreferredMonster: function (slotIndex) {
        controller.clearPreferredMonster(slotIndex);
      }

      clearAvoidedMonster: function (slotIndex) {
        controller.clearAvoidedMonster(slotIndex);
      }

      assignPreferredMonster: function (slotIndex, raceId) {
        controller.assignPreferredMonster(slotIndex, raceId);
      }

      assignAvoidedMonster: function (slotIndex, raceId) {
        controller.assignAvoidedMonster(slotIndex, raceId);
      }

      handleSelection: function (selectedRaceId) {
        controller.preferredSlotData.assignableMonsterRaceId = selectedRaceId;
      }

      unlockPreferredMonsterSlot: function () {
        controller.unlockPreferredMonsterSlot();
      }

      closeAction: function () {        
        controller.showPreferredList = false;
        controller.clearNameFilter();
      }
    }
  }
}
