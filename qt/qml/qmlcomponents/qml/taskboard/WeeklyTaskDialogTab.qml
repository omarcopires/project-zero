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

  property var progressNorm: (controller.finishedDeliverTasks + controller.finishedMonsterKillTasks) / 18

  ColumnLayout {

    anchors.fill: parent
    anchors.margins: TibiaStyle.marginUnrelated

    RowLayout {

      spacing: 0

      MonsterKillTaskPanel {
        Layout.preferredWidth: 465
        Layout.preferredHeight: 347
        monsterKillTasks: controller.monsterKillTasks
        showPermanentWeeklyTaskExpansionUnlockButton: controller.showPermanentWeeklyTaskExpansionUnlockButton
        unlockAction: function () {
          controller.openPermanentWeeklyTaskExpansionUnlockStore();
        }
      }

      Item {
        Layout.preferredWidth: 16
      }

      DeliveryTaskPanel {
        Layout.preferredWidth: 465
        Layout.preferredHeight: 347
        deliveryTasks: controller.deliveryTasks
        showPermanentWeeklyTaskExpansionUnlockButton: controller.showPermanentWeeklyTaskExpansionUnlockButton
        deliverTaskAction: function (taskIndex) {
          controller.deliverTask(taskIndex);
        }
        unlockAction: function () {
          controller.openPermanentWeeklyTaskExpansionUnlockStore();
        }

        clickedAction: function(TypeID, MouseButton, KeyboardModifiers) {
          controller.onDeliveryItemClicked(TypeID, MouseButton, KeyboardModifiers);
        }
      }
    }

    TibiaText {
      Layout.alignment: Qt.AlignHCenter
      text: {
        if (controller.rewardXPPerKillTask == controller.rewardXPPerDeliveryTask) {
          return qsTrId("taskboard_weekly_task_info_text").arg(TextHelper.formatNumberWithThousandSeparators(controller.rewardXPPerKillTask));
        } else {
          return qsTrId("taskboard_weekly_task_info_text_different_xp")
            .arg(TextHelper.formatNumberWithThousandSeparators(controller.rewardXPPerKillTask))
            .arg(TextHelper.formatNumberWithThousandSeparators(controller.rewardXPPerDeliveryTask));
        }
      }
    } // TibiaText

    RowLayout {

      spacing: 13
      WeeklyTasksProgressPanel {
        taskRewardFactors: controller.taskRewardFactors
        taskRewardCounts: controller.taskRewardCounts
        progressNorm: root.progressNorm
      }

      WeeklyTasksRewardsPanel {
        finishedMonsterKillTasks: controller.finishedMonsterKillTasks
        huntingTaskPointsPerMonsterKillTask: controller.huntingTaskPointsPerMonsterKillTask

        finishedDeliverTasks: controller.finishedDeliverTasks
        huntingTaskPointsPerDeliverTask: controller.huntingTaskPointsPerDeliverTask

        huntingTaskPointsMultiplicatorForFinishedTasks: controller.huntingTaskPointsMultiplicatorForFinishedTasks

        rewardHuntingTaskPoints: controller.rewardHuntingTaskPoints
        rewardSoulSeals: controller.rewardSoulSeals

        remainingTimeString: controller.remainingTimeString
        remainingTimeLessThanOneDayLeft: controller.remainingTimeLessThanOneDayLeft
      }
    }

    Item {
      Layout.fillHeight: true
    }
  }

  TibiaDisabledOverlay {
    visible: controller.displayResults

    anchors.fill: parent
    anchors.margins: TibiaStyle.marginUnrelated

    MouseArea {
      anchors.fill: parent
      onClicked: {}
    }

    WeeklyTasksResultsPanel {
      anchors.centerIn: parent

      showResults: controller.showResultsInResultsPanel
      monsterKillTasksCompleted: controller.monsterKillTasksCompleted
      monsterKillTasksCount: controller.monsterKillTasksCount

      deliveryTasksCompleted: controller.deliveryTasksCompleted
      deliveryTasksCount: controller.deliveryTasksCount

      rewardHuntingTaskPoints: controller.rewardHuntingTaskPoints
      rewardSoulSeals: controller.rewardSoulSeals

      maxDifficultyLevel: (controller.maxDifficultyLevel != null) ? controller.maxDifficultyLevel : 0
      selectDifficulty: function (difficulty) {
        controller.selectDifficulty(difficulty);
      }
      beginnerLevelRequirement: 0
      adeptLevelRequirement: controller.getRequiredLevelForDifficulty(1)
      expertLevelRequirement: controller.getRequiredLevelForDifficulty(2)
      masterLevelRequirement: controller.getRequiredLevelForDifficulty(3)
    }
  }
}
