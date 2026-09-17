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

  required property var monsterKillTasks
  required property bool showPermanentWeeklyTaskExpansionUnlockButton
  required property var unlockAction
  caption: qsTrId("taskboard_monster_kill_task_panel_caption")
  
  width : 465
  height: 347

  GridLayout {
    id: tasks

    anchors.left: parent.left
    anchors.top: parent.top
    anchors.right: parent.right
    anchors.leftMargin: TibiaStyle.marginUnrelated
    anchors.topMargin: TibiaStyle.marginUnrelated + root.captionHeight
    anchors.rightMargin: TibiaStyle.marginUnrelated
    
    columnSpacing: TibiaStyle.marginNarrow
    rowSpacing: TibiaStyle.marginNarrow * 2
    
    columns: 3

    Repeater {
      model: monsterKillTasks

      MonsterKillTask {
        Layout.preferredWidth: 144
        Layout.preferredHeight: 100
        raceId: model.raceId
        captionText: model.caption 
        currentKillAmount: model.currentKillAmount
        requiredAmount: model.requiredAmount
      }
    }


    TibiaButton {
      id: unlockPermanentlyButton
      Layout.preferredHeight: 100
      Layout.preferredWidth: 3 * 144 + TibiaStyle.marginNarrow * 5
      Layout.columnSpan: 3
      color: "blue"

      visible: showPermanentWeeklyTaskExpansionUnlockButton

      imageSource: "/images/prey-unlock-permanently.png"

      onClicked: unlockAction()
    }
  }
}
