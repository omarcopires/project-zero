import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtWebChannel
import QtWebEngine

import qmlcomponents
import "qrc:/qt/qml/qmlcomponents/qml/"
import QtQuick.LegacyControls

ColumnLayout {
  id: root

  required property string ringImageSource
  required property string bonusDescription
  required property double bonusValuePerCent
  required property double nextBonusValuePerCent
  required property string disabledTooltip
  required property int upgradeCost
  required property bool maximumReached
  property var upgradeAction: null
  property bool additionalSpaceBetweenBonusAndButton: false

  spacing: TibiaStyle.marginUnrelated

  implicitWidth: 212

  RowLayout {
    id: bonusDescriptionArea
    spacing: TibiaStyle.marginRelated

    Layout.fillWidth: true

    Image {
      Layout.preferredWidth: 32
      Layout.preferredHeight: 32
      source: ringImageSource
      Layout.alignment: Qt.AlignTop
    }

    ColumnLayout {
      spacing: TibiaStyle.marginRelated
      TibiaText {
        Layout.fillWidth: true
        text: bonusDescription
        wrapMode: Text.Wrap
      }

      TibiaText {
        Layout.fillWidth: true
        text: qsTrId("taskboard_current_format").arg(bonusValuePerCent)
      }
    }
  }

  Item {
    Layout.fillWidth: true
    Layout.preferredHeight: TibiaStyle.marginNarrow
    visible: additionalSpaceBetweenBonusAndButton
  }

  RowLayout {

    TibiaButton {
      id: upgradeActionButton

      Layout.preferredWidth: TibiaStyle.buttonWidthWider

      text: maximumReached ? qsTrId("taskboard_fully_upgraded") : qsTrId("taskboard_level_up").arg(nextBonusValuePerCent)
      enabled: upgradeAction != null

      onClicked: {
        upgradeAction();
      }
      
      Tooltip {
        anchors.fill: parent
        enabled: !upgradeActionButton.enabled
        text: disabledTooltip
      }
    }

    TibiaCurrencyView {
      id: upgradeCostControl
      Layout.fillWidth: true
      
      visible: !maximumReached

      rightAligned: true
      iconId: "BountyPoints"
      balance: upgradeCost
    }
  }
}
