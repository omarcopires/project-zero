import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtWebChannel
import QtWebEngine

import qmlcomponents
import "qrc:/qt/qml/qmlcomponents/qml/"
import QtQuick.LegacyControls

TibiaFrame2PixelUpFilledWithCaption {
  id: root

  property int rerollTaskCost: 1
  required property int bountyTaskDifficulty
  required property var showPreferredList
  required property var selectBountyTaskDifficulty

  required property bool canRerollTasks
  required property var rerollTasksAction

  required property bool canClaimRerollToken
  required property var claimRerollTokenAction
  required property var noClaimRerollTokenReason
  
  required property bool limitOfRerollsReached

  
  width: content.width + root.innerMargin * 2
  caption: qsTrId("taskboard_setup_and_reroll")

  RowLayout {
    id: content
    anchors.top: parent.top
    anchors.topMargin: root.captionHeight
    anchors.left: parent.left
    anchors.leftMargin: TibiaStyle.marginUnrelated
    
    TibiaGuiHelp {
      Layout.margins: TibiaStyle.marginUnrelated
      text: qsTrId("taskboard_task_difficulty_tooltip")
    }

    TibiaVerticalSeparator {
      Layout.margins: TibiaStyle.marginUnrelated
      Layout.preferredHeight: 20
    }

    TibiaText {
      text: qsTrId("taskboard_task_difficulty")
      Layout.margins: TibiaStyle.marginUnrelated
    }

    TibiaComboBox {
      id: bountyTaskDifficultyDropdown
      Layout.margins: TibiaStyle.marginUnrelated
      Layout.preferredWidth: TibiaStyle.buttonWidthWider

      model: [
        qsTrId("taskboard_difficulty_beginner"),
        qsTrId("taskboard_difficulty_adept"),
        qsTrId("taskboard_difficulty_expert"),
        qsTrId("taskboard_difficulty_master")
      ]
      
      currentIndex: bountyTaskDifficulty
 
      onCurrentValueChanged: selectBountyTaskDifficulty(currentIndex)      
    }

    TibiaButton {
      text: qsTrId("taskboard_preferred_list")
      Layout.preferredWidth: TibiaStyle.buttonWidthWider
      Layout.margins: TibiaStyle.marginUnrelated

      onClicked: {
        showPreferredList()
      }
    }

    TibiaVerticalSeparator {
      Layout.margins: TibiaStyle.marginUnrelated
      Layout.preferredHeight: 20
    }

    TibiaButton {
      id: rerollButton
      text: qsTrId("taskboard_reroll_tasks")
      Layout.preferredWidth: TibiaStyle.buttonWidthWider
      Layout.margins: TibiaStyle.marginUnrelated

      enabled: canRerollTasks
      onClicked: rerollTasksAction()
      
      Tooltip {
        anchors.fill: parent
        enabled: !rerollButton.enabled
        text: qsTrId("taskboard_tooltip_no_rerolls_left")
      }
    }

    TibiaCurrencyView {
      id: upgradeCostControl
      Layout.preferredWidth: 40

      rightAligned: true
      iconId: "TaskReroll"
      balance: rerollTaskCost
    }

    Image {
      source: "/images/icon-inline-warning.png"
      visible: limitOfRerollsReached
      Tooltip {
        anchors.fill: parent
        text: qsTrId("no_claim_reroll_token_reason_tooltip_maximum_reached")
      }
    } // Image

    TibiaButton {
      id: claimRerollButton
      text: qsTrId("taskboard_claim_rerolltoken")
      Layout.preferredWidth: TibiaStyle.buttonWidthWider
      Layout.margins: TibiaStyle.marginUnrelated
      enabled: canClaimRerollToken
      onClicked: claimRerollTokenAction()
      Tooltip {
        anchors.fill: parent
        enabled: !claimRerollButton.enabled
        text: noClaimRerollTokenReason
      }
    }

    Item {
      Layout.fillWidth : true
    }
  }
}
