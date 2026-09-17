import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtWebChannel
import QtWebEngine

import qmlcomponents
import "qrc:/qt/qml/qmlcomponents/qml/"
import QtQuick.LegacyControls

Item {
  id: root
  implicitWidth: 320
  implicitHeight: 345

  required property bool showResults

  required property int monsterKillTasksCompleted
  required property int monsterKillTasksCount

  required property int deliveryTasksCompleted
  required property int deliveryTasksCount

  required property int rewardHuntingTaskPoints
  required property int rewardSoulSeals

  required property int maxDifficultyLevel
  required property var selectDifficulty
  required property int beginnerLevelRequirement
  required property int adeptLevelRequirement
  required property int expertLevelRequirement
  required property int masterLevelRequirement

  TibiaFrame2PixelUpFilledWithCaption {
    anchors.fill: parent
    caption: qsTrId("taskboard_weekly_progress_caption")

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: TibiaStyle.marginUnrelated

      Item {
        Layout.fillHeight: true
      }

      ColumnLayout {
        Layout.fillWidth: true

        Item {
          Layout.fillHeight: true
          Layout.alignment: Qt.AlignHCenter
        }

        RowLayout {
          Item {
            Layout.fillWidth: true
          }

          Image {
            Layout.alignment: Qt.AlignHCenter
            source: "/images/taskboard/backdrop_weeklyresults.png"
          }

          Item {
            Layout.fillWidth: true
          }
        }

        Item {
          Layout.fillHeight: true
        }

        TibiaText {
          visible: showResults
          Layout.fillWidth: true
          horizontalAlignment: Text.AlignHCenter
          text: qsTrId("taskboard_result_monster_kill_task_format").arg(monsterKillTasksCompleted).arg(monsterKillTasksCount)
        }

        TibiaText {
          visible: showResults
          Layout.fillWidth: true
          horizontalAlignment: Text.AlignHCenter
          text: qsTrId("taskboard_result_delivery_task_format").arg(deliveryTasksCompleted).arg(deliveryTasksCount)
        }

        TibiaText {
          visible: showResults
          Layout.fillWidth: true
          horizontalAlignment: Text.AlignHCenter
          text: qsTrId("taskboard_result_reward_format").arg(rewardHuntingTaskPoints).arg(rewardSoulSeals)
        }

        Item {
          Layout.fillHeight: true
        }
      }

      TibiaText {
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        text: qsTrId("taskboard_difficulty_text")
      }

      TibiaButton {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: TibiaStyle.buttonWidthWider
        text: qsTrId("taskboard_difficulty_beginner")
        onClicked: selectDifficulty(0)

        Tooltip {
          text: qsTrId("taskboard_difficulty_beginner_tooltip")
          anchors.fill: parent
        }
      }

      TibiaButton {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: TibiaStyle.buttonWidthWider
        text: qsTrId("taskboard_difficulty_adept")
        onClicked: selectDifficulty(1)
        enabled: maxDifficultyLevel >= 1

        Tooltip {
          text: qsTrId("taskboard_difficulty_adept_tooltip").arg(TextHelper.formatNumberWithThousandSeparators(adeptLevelRequirement))
          anchors.fill: parent
        }
      }

      TibiaButton {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: TibiaStyle.buttonWidthWider
        text: qsTrId("taskboard_difficulty_expert")
        onClicked: selectDifficulty(2)
        enabled: maxDifficultyLevel >= 2

        Tooltip {
          text: qsTrId("taskboard_difficulty_expert_tooltip").arg(TextHelper.formatNumberWithThousandSeparators(expertLevelRequirement))
          anchors.fill: parent
        }
      }

      TibiaButton {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: TibiaStyle.buttonWidthWider
        text: qsTrId("taskboard_difficulty_master")
        onClicked: selectDifficulty(3)
        enabled: maxDifficultyLevel >= 3

        Tooltip {
          text: qsTrId("taskboard_difficulty_master_tooltip").arg(TextHelper.formatNumberWithThousandSeparators(masterLevelRequirement))
          anchors.fill: parent
        }
      }

      Item {
        Layout.fillHeight: true
      }
    }
  }
}
