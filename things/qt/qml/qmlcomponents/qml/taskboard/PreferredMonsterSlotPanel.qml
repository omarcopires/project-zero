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

  property var preferredSlotData: null
  required property var unlockPreferredMonsterSlot

  required property var clearPreferredMonster
  required property var clearAvoidedMonster

  required property var assignPreferredMonster
  required property var assignAvoidedMonster
  required property int bountyPointsBalance

  TibiaFrame2PixelUpFilled {
    anchors.fill: parent
    anchors.margins: TibiaStyle.marginRelated
    visible: preferredSlotData != null

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: TibiaStyle.marginRelated

      RowLayout {
        Layout.fillWidth: true
        spacing: 0

        Item {
          Layout.fillWidth: true
        }

        TibiaText {
          text: qsTrId("taskboard_preferred_label")
          horizontalAlignment: Text.AlignHCenter
        }

        TibiaGuiHelp {
          Layout.leftMargin: TibiaStyle.marginRelated
          text: qsTrId("taskboard_preferred_label_tooltip")
        }

        Item {
          Layout.fillWidth: true
        }

        TibiaText {
          text: qsTrId("taskboard_avoided_label")
          horizontalAlignment: Text.AlignHCenter
        }

        TibiaGuiHelp {
          Layout.leftMargin: TibiaStyle.marginRelated
          text: qsTrId("taskboard_avoided_label_tooltip")
        }

        Item {
          Layout.fillWidth: true
        }
      }

      TibiaHorizontalSeparator {
        Layout.fillWidth: true
      }

      Repeater {
        model: preferredSlotData

        PreferredMonsterSlot {
          Layout.fillWidth: true
          Layout.fillHeight: true

          slotIndex: model.slotIndex
          isUnlocked: model.isUnlocked
          preferredMonsterRaceId: model.preferredMonsterRaceId
          avoidedMonsterRaceId: model.avoidedMonsterRaceId
          clearCost: preferredSlotData.clearCost
          canBeUnlocked: model.canBeUnlocked
          unlockCost: model.unlockCost
          bountyPointsBalance: root.bountyPointsBalance
          preferredMonsterRaceName: model.preferredMonsterRaceName
          avoidedMonsterRaceName: model.avoidedMonsterRaceName

          assignableMonsterRaceId: preferredSlotData.assignableMonsterRaceId

          unlockPreferredMonsterSlot: root.unlockPreferredMonsterSlot

          clearPreferredMonster: root.clearPreferredMonster
          clearAvoidedMonster: root.clearAvoidedMonster

          assignPreferredMonster: root.assignPreferredMonster
          assignAvoidedMonster: root.assignAvoidedMonster
          isMonsterRaceAssignable: function (raceId) {

            return preferredSlotData.isMonsterRaceAssignable(raceId);
          }
        }
      }
    }
  }
}
