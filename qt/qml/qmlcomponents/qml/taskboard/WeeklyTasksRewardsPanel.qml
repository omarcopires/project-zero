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

  implicitWidth: 162
  implicitHeight: 109

  property int finishedMonsterKillTasks: 0
  property int huntingTaskPointsPerMonsterKillTask: 0

  property int finishedDeliverTasks: 0
  property int huntingTaskPointsPerDeliverTask: 0

  property double huntingTaskPointsMultiplicatorForFinishedTasks: 0

  property int rewardHuntingTaskPoints: 123456
  property int rewardSoulSeals: 123

  property string remainingTimeString: ""
  property bool remainingTimeLessThanOneDayLeft: false

  TibiaFrame2PixelUpFilledWithCaption {
    id: frame
    caption: qsTrId("taskboard_weekly_rewards_caption")

    anchors.fill: parent

    ColumnLayout {
      anchors.fill: frame
      anchors.topMargin: frame.captionHeight
      anchors.leftMargin: TibiaStyle.marginUnrelated
      anchors.rightMargin: TibiaStyle.marginUnrelated
      anchors.bottomMargin: TibiaStyle.marginUnrelated
      spacing: 0
    
      RowLayout {
    
        TibiaCurrencyView {
          Layout.fillWidth: true
          rightAligned: true
    
          balance: rewardHuntingTaskPoints
          iconId: "PreyHuntingTaskTokens"
        }
    
        TibiaGuiHelp {
          Layout.margins: TibiaStyle.marginUnrelated
          useRichText: true
          text: qsTrId("taskboard_hunting_task_token_reward_tooltip")
            .arg(String(finishedMonsterKillTasks).padStart(2, "\u2007"))
            .arg(String(huntingTaskPointsPerMonsterKillTask).padStart(2, "\u2007"))
            .arg(String(finishedDeliverTasks).padStart(2, "\u2007"))
            .arg(String(huntingTaskPointsPerDeliverTask).padStart(2, "\u2007"))
            .arg(huntingTaskPointsMultiplicatorForFinishedTasks)
            .arg(rewardHuntingTaskPoints)
        }
      }
    
      RowLayout {
    
        TibiaCurrencyView {
          Layout.fillWidth: true
          rightAligned: true
    
          balance: rewardSoulSeals
          iconId: "SoulSeals"
        }
    
        TibiaGuiHelp {
          Layout.margins: TibiaStyle.marginUnrelated
          text: qsTrId("taskboard_soul_seal_reward_tooltip")
        }
      }
    
      TibiaText {
        Layout.alignment: Qt.AlignLeft
        text: remainingTimeString
        color: remainingTimeLessThanOneDayLeft ? TibiaStyle.red2 : TibiaStyle.white1
      } // TibiaText
    
    }

  } // TibiaFrame2PixelUpFilledWithCaption

  Component.onCompleted: {
    // console.log("=== Properties of root ===");
    // for (var key in root) {
    //   try {
    //     console.log(key, ":", root[key]);
    //   } catch (e) {
    //     console.log(key, ": <unreadable>");
    //   }
    // }
  }
}
