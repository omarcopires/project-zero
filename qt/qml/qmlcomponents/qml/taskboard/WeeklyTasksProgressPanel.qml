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
  implicitWidth: 771
  implicitHeight: 109

  required property var taskRewardFactors
  required property var taskRewardCounts

  property var progressNorm: 0.0

  property int progressBarSpacing: 32

  TibiaPanel2PixelUpFilledWithCaption {
    id: rootFrame
    anchors.fill: parent
    caption: qsTrId("taskboard_weekly_progress_caption")
  }

  RowLayout {

    anchors.fill: parent

    ColumnLayout {
      Layout.topMargin: rootFrame.captionHeight

      Item {
        Layout.fillHeight: true
      }

      TibiaText {
        Layout.leftMargin: TibiaStyle.marginUnrelated
        text: qsTrId("taskboard_reward_multiplier_label")
      }

      Item {
        Layout.fillHeight: true
      }

      TibiaText {
        id: completetTasksText
        Layout.leftMargin: TibiaStyle.marginUnrelated
        text: qsTrId("taskboard_completed_task_count_label")
      }

      Item {
        Layout.fillHeight: true
      }
    }

    ColumnLayout {
      Layout.topMargin: rootFrame.captionHeight
      Layout.fillWidth: true

      Item {
        Layout.fillHeight: true
      }

      RowLayout {
        id: factorsRow
        spacing: 0
        Layout.leftMargin: progressBarSpacing
        Layout.rightMargin: progressBarSpacing
        Layout.fillWidth: true
        Layout.preferredHeight: 24

        Repeater {
          model: root.taskRewardCounts.length - 1

          TibiaText {
            Layout.fillWidth: true
            Layout.preferredWidth: root.taskRewardCounts[index + 1] - root.taskRewardCounts[index]
            
            text: "x" + root.taskRewardFactors[index]
            horizontalAlignment: Text.AlignHCenter

            // Rectangle {
            //   anchors.fill: parent
            //   color: "red"
            //   opacity: 0.1 * (index + 1)
            //   z: 9999
            // }
          }
        }
      }

      TibiaProgressBar {
        Layout.leftMargin: progressBarSpacing
        Layout.rightMargin: progressBarSpacing
        Layout.fillWidth: true
        Layout.preferredHeight: 20

        z: 100

        fillPercentage: progressNorm

        frameSource: "/images/1pixel-down-frame.png"
        backgroundSource: "/images/backdrop-dark-grey.png"
        fillSource: "/images/progressbar-green-large.png"

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
      }

      RowLayout {
        id: taskCountRow
        Layout.leftMargin: progressBarSpacing
        Layout.rightMargin: progressBarSpacing
        Layout.fillWidth: true
        Layout.preferredHeight: 24
        spacing: 0

        Repeater {
          model: root.taskRewardCounts.length - 1

          TibiaText {
            Layout.fillWidth: true
            Layout.preferredWidth: root.taskRewardCounts[index + 1] - root.taskRewardCounts[index]

            text: root.taskRewardCounts[index + 1]
            horizontalAlignment: Text.AlignRight

            // Rectangle {
            //   anchors.fill: parent
            //   color: "blue"
            //   opacity: 0.1 * (index + 1)
            //   z: 9999
            // }

            TibiaVerticalSeparator {
              x: parent.width - width
              y: -52
              height: 50
              visible: index != (root.taskRewardCounts.length - 2)
            }
          }
        }
      }

      Item {
        Layout.fillHeight: true
      }
    }
  }

  TibiaText {
    x: factorsRow.parent.x + progressBarSpacing
    y: factorsRow.parent.height - TibiaStyle.marginUnrelated
    text: "0"
  }
}
