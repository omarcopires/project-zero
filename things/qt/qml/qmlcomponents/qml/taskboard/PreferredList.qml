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

  implicitWidth: 600
  implicitHeight: 505

  required property var monsterList
  required property var preferredSlotData
  required property var unlockPreferredMonsterSlot
  required property var handleSelection
  required property var closeAction
  required property var bountyPointsBalance

  required property var clearPreferredMonster
  required property var clearAvoidedMonster
  required property var assignPreferredMonster
  required property var assignAvoidedMonster

  TibiaFrame2PixelUpFilled {
    anchors.fill: parent

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: TibiaStyle.marginUnrelated

      TibiaText {
        Layout.alignment: Qt.AlignHCenter
        text: qsTrId("taskboard_preferred_list_caption")
      }

      RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true

        MonsterSelectionPanel {
          id: monsterSelection
          monsterList: root.monsterList
          handleSelection: root.handleSelection

          Layout.fillWidth: true
          Layout.fillHeight: true
        }

        PreferredMonsterSlotPanel {
          preferredSlotData: root.preferredSlotData
          unlockPreferredMonsterSlot: root.unlockPreferredMonsterSlot
          clearPreferredMonster: root.clearPreferredMonster
          clearAvoidedMonster: root.clearAvoidedMonster
          assignPreferredMonster: root.assignPreferredMonster
          assignAvoidedMonster: root.assignAvoidedMonster
          bountyPointsBalance: root.bountyPointsBalance

          Layout.fillWidth: true
          Layout.fillHeight: true
        }
      }

      TibiaHorizontalSeparator {
        Layout.fillWidth: true
      }

      RowLayout {
        id: buttonBar
        Layout.fillWidth: true
        spacing: TibiaStyle.marginRelated

        Item {
          Layout.fillWidth: true
        }

        TibiaButton {
          text: qsTrId("close")
          onClicked: {
            preferredSlotData.clearAssignableMonster();
            monsterSelection.updateNameFilter("");
            closeAction();
          }
        }
      }
    }
  }
  onVisibleChanged: {
    monsterSelection.updateNameFilter("");
  }
}
