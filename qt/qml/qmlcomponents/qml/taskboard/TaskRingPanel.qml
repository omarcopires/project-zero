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

  property double bonusDamagePerCent: 0
  property double nextBonusDamagePerCent: 0
  property var bonusDamageUpgradeAction: null
  property int bonusDamageUpgradeCost: 0
  property string disabledBonusDamageTooltip: ""
  property bool maximumReachedBonusDamage: false

  property double lifeLeechPerCent: 0
  property double nextLifeLeechPerCent: 0
  property var lifeLeechUpgradeAction: null
  property int lifeLeechUpgradeCost: 0
  property string disabledLifeLeechPercentTooltip: ""
  property bool maximumReachedBonusLifeLeech: false

  property double bonusLootPerCent: 0
  property double nextBonusLootPerCent: 0
  property var bonusLootUpgradeAction: null
  property int bonusLootUpgradeCost: 0
  property string disabledBonusLootTooltip: ""
  property bool maximumReachedBonusLoot: false

  property double doubleBestiaryChancePerCent: 0
  property double nextDoubleBestiaryChancePerCent: 0
  property var doubleBestiaryChanceUpgradeAction: null
  property int doubleBestiaryChanceUpgradeCost: 0
  property string disabledBonusBestiaryTooltip: ""
  property bool maximumReachedBonusBestiary: false

  width: content.width + root.innerMargin * 2
  caption: qsTrId("taskboard_task_ring")

  RowLayout {
    id: content
    anchors.fill: parent
    anchors.topMargin: root.captionHeight + TibiaStyle.marginRelated
    anchors.leftMargin: TibiaStyle.marginUnrelated
    anchors.rightMargin: TibiaStyle.marginUnrelated
    anchors.bottomMargin: TibiaStyle.marginRelated

    TibiaGuiHelp {
      Layout.alignment: Qt.AlignVCenter
      text: qsTrId("taskboard_taskring_tooltip")
    }
    
    TibiaVerticalSeparator {
      Layout.leftMargin: TibiaStyle.marginNarrow
      Layout.rightMargin: TibiaStyle.marginUnrelated
      Layout.topMargin: TibiaStyle.marginUnrelated
      Layout.bottomMargin: TibiaStyle.marginUnrelated
      
      Layout.fillHeight: true
    }

    TaskRingPanelSection {
      ringImageSource: "/images/taskboard/icon-bountyring-damageagainstmonster.png"
      bonusDescription: qsTrId("taskboard_bonus_damage_description")
      bonusValuePerCent: bonusDamagePerCent
      nextBonusValuePerCent: nextBonusDamagePerCent
      upgradeAction: bonusDamageUpgradeAction
      upgradeCost: bonusDamageUpgradeCost
      disabledTooltip: disabledBonusDamageTooltip
      maximumReached: maximumReachedBonusDamage
      Layout.preferredWidth: content.width / 4
    }

    TibiaVerticalSeparator {
      Layout.margins: TibiaStyle.marginUnrelated
      Layout.fillHeight: true
    }

    TaskRingPanelSection {
      ringImageSource: "/images/taskboard/icon-bountyring-lifeleech.png"
      bonusDescription: qsTrId("taskboard_lifeleech_description")
      bonusValuePerCent: lifeLeechPerCent
      nextBonusValuePerCent: nextLifeLeechPerCent
      upgradeAction: lifeLeechUpgradeAction
      upgradeCost: lifeLeechUpgradeCost
      disabledTooltip: disabledLifeLeechPercentTooltip
      maximumReached: maximumReachedBonusLifeLeech
      Layout.preferredWidth: content.width / 4
      additionalSpaceBetweenBonusAndButton: true
    }

    TibiaVerticalSeparator {
      Layout.margins: TibiaStyle.marginUnrelated
      Layout.fillHeight: true
    }

    TaskRingPanelSection {
      ringImageSource: "/images/taskboard/icon-bountyring-moreloot.png"
      bonusDescription: qsTrId("taskboard_bonus_loot_description")
      bonusValuePerCent: bonusLootPerCent
      nextBonusValuePerCent: nextBonusLootPerCent
      upgradeAction: bonusLootUpgradeAction
      upgradeCost: bonusLootUpgradeCost
      disabledTooltip: disabledBonusLootTooltip
      maximumReached: maximumReachedBonusLoot
      Layout.preferredWidth: content.width / 4
      additionalSpaceBetweenBonusAndButton: true
    }

    TibiaVerticalSeparator {
      Layout.margins: TibiaStyle.marginUnrelated
      Layout.fillHeight: true
    }

    TaskRingPanelSection {
      ringImageSource: "/images/taskboard/icon-bountyring-doublebestiarychance.png"
      bonusDescription: qsTrId("taskboard_double_bestiary_chance_description")
      bonusValuePerCent: doubleBestiaryChancePerCent
      nextBonusValuePerCent: nextDoubleBestiaryChancePerCent
      upgradeAction: doubleBestiaryChanceUpgradeAction
      upgradeCost: doubleBestiaryChanceUpgradeCost
      disabledTooltip: disabledBonusBestiaryTooltip
      maximumReached: maximumReachedBonusBestiary
      Layout.preferredWidth: content.width / 4
    }

  }
}
