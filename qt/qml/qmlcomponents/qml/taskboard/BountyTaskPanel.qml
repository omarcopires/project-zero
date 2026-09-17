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

  property var taskIndex: 0
  property string tooltipText: "<tooltipText>"
  property string killText: "<killText>"
  property int raceId: 0
  property int rewardXp: 0
  property int rewardBountyPoints: 0
  property string taskActionText: "<taskActionText>"
  property var taskAction: null
  property bool rerollLimitReached: false

  width : 296
  height: 251

  ColumnLayout {
    anchors.fill: parent
    spacing: TibiaStyle.marginNarrow
    anchors.topMargin: TibiaStyle.marginUnrelated * 3
    
    TibiaFrame1PixelDown {
      Layout.topMargin: TibiaStyle.marginUnrelated
      Layout.alignment: Qt.AlignHCenter
      Layout.preferredWidth: 64 + 2
      Layout.preferredHeight: 64 + 2
      
      BorderImage {
        smooth: false
        anchors.fill: parent
        anchors.margins: 1
        source: "/images/backdrop-dark-grey.png"
        horizontalTileMode: BorderImage.Repeat
        verticalTileMode: BorderImage.Repeat
        visible: true
        cache: false

        RaceAppearanceInstanceRenderer {
          anchors.fill: parent
          center: true
          raceID: raceId
        
           Tooltip {
            anchors.fill: parent
            text : tooltipText
          }
        }
      }
    }

    TibiaText {
      Layout.alignment: Qt.AlignHCenter
      text: killText
    }

    TibiaHorizontalSeparator {
      Layout.margins: TibiaStyle.marginUnrelated
      Layout.fillWidth: true
    }

    TibiaText {
      Layout.leftMargin: TibiaStyle.marginUnrelated
      text: qsTrId("taskboard_reward_label")
    }

    TibiaText {
      Layout.leftMargin: TibiaStyle.marginUnrelated
      text: "• %1 XP".arg(TextHelper.formatNumberWithThousandSeparators(rewardXp))
    }

    RowLayout {
      spacing: TibiaStyle.marginNarrow

      TibiaText {
        id: rewardBountyPointsValue
        Layout.leftMargin: TibiaStyle.marginUnrelated
        text: "• %1".arg(TextHelper.formatNumberWithThousandSeparators(rewardBountyPoints))
      }
      
      Image {
        source: "/images/taskboard/icon-currency-bountypoints.png"
        
        Tooltip {
          text: qsTrId("currency_view_bountypoints_tooltip")
          anchors.fill: parent
          enabled: text.length > 0
        }
      }
    }

    RowLayout {
      spacing: TibiaStyle.marginNarrow

      TibiaText {
        Layout.leftMargin: TibiaStyle.marginUnrelated
        text: "• %1".arg(1) // Reroll Token Reward
      }
      
      Image {
        source: "/images/taskboard/icon-currency-taskreroll.png"
      
        Tooltip {
          text: qsTrId("currency_view_taskreroll_tooltip")
          anchors.fill: parent
          enabled: text.length > 0
        }
      }

      TibiaText {
        Layout.leftMargin: TibiaStyle.marginNarrow
        text: qsTrId("taskboard_reward_reroll_token_limit_reached")
        visible: rerollLimitReached
      }
    }

    TibiaButton {
      id: taskActionButton
      Layout.margins: TibiaStyle.marginUnrelated
      Layout.fillWidth: true
      text: taskActionText
      enabled: taskAction != null

      onClicked: taskAction(taskIndex)
      Tooltip {
        anchors.fill: parent
        enabled: !taskActionButton.enabled
        text: qsTrId("taskboard_tooltip_finish_task_first")
      }
    }
  }
}
