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

  // required properties result in "model is undefined"
  // in src/qmlcomponents/qml/taskboard/PreferredMonsterSlotPanel.qml:66 ff
  // no clue why this breaks? It works with a java script model. But the c++ model breaks.
  // In case you find out - let me (@jochen) know.

  /* required */ property int slotIndex
  /* required */ property bool isUnlocked
  /* required */ property bool canBeUnlocked
  /* required */ property int clearCost
  /* required */ property int unlockCost
  /* required */ property int preferredMonsterRaceId
  /* required */ property int avoidedMonsterRaceId
  /* required */ property int assignableMonsterRaceId
 
  /* required */ property var unlockPreferredMonsterSlot
  /* required */ property var clearPreferredMonster
  /* required */ property var clearAvoidedMonster
  /* required */ property var assignPreferredMonster
  /* required */ property var assignAvoidedMonster
  /* required */ property var isMonsterRaceAssignable
  property var preferredMonsterRaceName
  property var avoidedMonsterRaceName
  property int bountyPointsBalance

  TibiaFrame2PixelUpFilled {
    anchors.fill: parent
    anchors.margins: TibiaStyle.marginRelated

    visible: !isUnlocked

    ColumnLayout {
      anchors.fill: parent
      spacing: TibiaStyle.marginUnrelated

      Item {Layout.fillHeight: true}

      RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignHCenter

        TibiaText {
          text: qsTrId("taskboard_additional_slots_label")
          horizontalAlignment: Text.AlignHCenter
          Layout.preferredWidth: 120
        }

        Image {
          source: "/images/icon-locked.png"
        }
      }

      RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignHCenter

        TibiaButton {
          id: unlockButton
          Layout.preferredWidth: TibiaStyle.buttonWidthWide
          enabled: canBeUnlocked && (bountyPointsBalance >= unlockCost)

          text: qsTrId("taskboard_preferred_monster_slot_unlock")
          onClicked: {
            unlockPreferredMonsterSlot();
          }

          Tooltip {
            anchors.fill: parent
            enabled: !unlockButton.enabled
            text: !canBeUnlocked ? qsTrId("taskboard_tooltip_unlock_previous_slots_first") : qsTrId("taskboard_tooltip_no_bounty_points")
          }
        }

        TibiaCurrencyView {
          Layout.preferredWidth: unlockButton.width
          balance: unlockCost
          rightAligned: true
          iconId: "BountyPoints"
        }
      }

      Item {Layout.fillHeight: true}
    }
  }

  RowLayout {
    visible: isUnlocked

    anchors.fill: parent

    TibiaFrame1PixelDown {
      Layout.topMargin: TibiaStyle.marginUnrelated
      Layout.alignment: Qt.AlignHCenter
      Layout.preferredWidth: 64
      Layout.preferredHeight: 64

      RaceAppearanceInstanceRenderer {
        anchors.fill: parent
        center: true
        raceID: preferredMonsterRaceId

        Tooltip {
          anchors.fill: parent
          text: preferredMonsterRaceName
        }
      }
    }

    ColumnLayout {

      TibiaButton {
        id: preferredMonsterActionButton
        Layout.preferredWidth: TibiaStyle.buttonWidthDefault
        enabled : (preferredMonsterRaceId != 0) 
          ? (bountyPointsBalance >= clearCost)
          : isMonsterRaceAssignable(assignableMonsterRaceId)

        text: preferredMonsterRaceId == 0 ? qsTrId("taskboard_preferred_monster_assign_label") : qsTrId("taskboard_preferred_monster_clear_label")

        onClicked: {
          preferredMonsterRaceId != 0 
          ? clearPreferredMonster(root.slotIndex) 
          : assignPreferredMonster(root.slotIndex, assignableMonsterRaceId)
        }
      }

      TibiaCurrencyView {
        Layout.preferredWidth: preferredMonsterActionButton.width
        visible: preferredMonsterRaceId != 0
        balance: clearCost

        rightAligned: true
        iconId: "BountyPoints"
      }
    }

    TibiaFrame1PixelDown {
      Layout.topMargin: TibiaStyle.marginUnrelated
      Layout.alignment: Qt.AlignHCenter
      Layout.preferredWidth: 64
      Layout.preferredHeight: 64

      RaceAppearanceInstanceRenderer {
        anchors.fill: parent
        center: true
        raceID: avoidedMonsterRaceId

        Tooltip {
          anchors.fill: parent
          text: avoidedMonsterRaceName
        }
      }
    }

    ColumnLayout {
      spacing: 0

      TibiaButton {
        id: avoidedMonsterActionButton
        Layout.preferredWidth: TibiaStyle.buttonWidthDefault
        enabled: (avoidedMonsterRaceId != 0) 
          ? (bountyPointsBalance >= clearCost)
          : isMonsterRaceAssignable(assignableMonsterRaceId)

        text: avoidedMonsterRaceId == 0 ? qsTrId("taskboard_preferred_monster_assign_label") : qsTrId("taskboard_preferred_monster_clear_label")

        onClicked: {
          avoidedMonsterRaceId != 0 
          ? clearAvoidedMonster(root.slotIndex) 
          : assignAvoidedMonster(root.slotIndex, assignableMonsterRaceId)
        }
      }

      TibiaCurrencyView {
        Layout.preferredWidth: preferredMonsterActionButton.width
        visible: avoidedMonsterRaceId != 0
        balance: clearCost
        rightAligned: true
        iconId: "BountyPoints"
      }
    }
  }
}
