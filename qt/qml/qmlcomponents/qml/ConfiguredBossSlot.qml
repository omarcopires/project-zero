import QtQuick
import QtQuick.Effects
import QtQuick.Layouts

import qmlcomponents



TibiaFrame2PixelUpFilledWithCaption {
  id: borderPanel

  property int selectedRaceID: 0
  property int numberOfKills: 0
  property int numberOfKillsForProwess: 0
  property int numberOfKillsForExpertise: 0
  property int numberOfKillsForMastery: 0
  property int currentLootBonus: 0
  property string priceForReset: "0"
  property string bossRaritySource: ""
  property string bossRarityTooltip: ""
  property var controller: null
  property var bossName: ""
  property int slotNumber: 0
  property bool isInBoostedSlot: false
  property var playerGold: 0
  property int resetPriceNumber: 0


  caption: qsTrId("bosstiary_caption_configured_slot").arg(slotNumber).arg(bossName)

  ColumnLayout {
    spacing: TibiaStyle.marginRelated
    anchors { left: parent.left; leftMargin: parent.marginsToContent;
              right: parent.right; rightMargin: parent.marginsToContent;
              bottom: parent.bottom; bottomMargin: parent.marginsToContent;
              top: parent.top; topMargin: parent.topMarginToContent }

    Item {

      Layout.fillWidth: true
      Layout.preferredHeight: iconImage.height + monsterOutfit.height

      Image {
        id: iconImage
        source: bossRaritySource
        smooth: false
        anchors { right: monsterOutfit.left; rightMargin: TibiaStyle.marginUnrelated;
                      top: monsterOutfit.top; }

        Tooltip {
          anchors.fill: parent
          text: bossRarityTooltip
        }
      } // Image

      RaceAppearanceInstanceRenderer {
        id: monsterOutfit
        width: 64
        height: 64
        anchors.centerIn: parent
        raceID: selectedRaceID
        isUnknown: false
      } // RaceAppearanceInstanceRenderer

      MultiEffect {
        height: monsterOutfit.height
        width: height
        anchors.centerIn: parent
        brightness: isInBoostedSlot ? -0.5 : 0.0
        source: monsterOutfit
      } // MultiEffect
    } // Item

    Item {
      Layout.preferredHeight: 9
      Layout.fillWidth: true
    }

    BosstiaryUnlockProgress {
      kills: numberOfKills
      killsForProwess: numberOfKillsForProwess
      killsForExpertise: numberOfKillsForExpertise
      killsForMastery: numberOfKillsForMastery
      preferredProgressBarWidth: selectButton.width
      Layout.preferredWidth: borderPanel.width
    } // BosstiaryUnlockProgress

    Item {
      Layout.preferredHeight: 10
      Layout.fillWidth: true
    }

    TibiaText {
      text: isInBoostedSlot ? qsTrId("bosstiary_configured_slot_boosted") : qsTrId("bosstiary_configured_slot_lootbonus_text").arg(currentLootBonus)
      Layout.fillWidth: true
      horizontalAlignment: Text.AlignHCenter
      wrapMode: Text.Wrap
    } // TibiaText

     Item {
      Layout.fillHeight: true
      Layout.fillWidth: true
    }


    Item {

     Layout.alignment: Qt.AlignHCenter
     Layout.preferredWidth: selectButton.width
      Layout.preferredHeight: selectButton.height

      TibiaButton {
        id: selectButton
        text: qsTrId("bosstiary_configured_slot_clear_button")
        enabled: ((playerGold >= resetPriceNumber) ? true : false)
        visible: true
        width: TibiaStyle.buttonWidthWidest
        anchors.centerIn: parent
        onClicked: { controller.onClearClicked(slotNumber); }
      } //TibiaButton

      Tooltip {
        anchors.fill: parent
        text: qsTrId("bosstiary_configured_slot_clear_button_tooltip").arg(priceForReset)
      } // Tooltip
    } // Item

    TibiaCurrencyView {
      Layout.preferredWidth: selectButton.width
      implicitWidth: NaN
      price: priceForReset
      iconId: "GoldCoin"
      Layout.alignment: Qt.AlignHCenter
      tooLowBalance: playerGold < resetPriceNumber
    } //TibiaCurrencyView
  } // ColumnLayout
} // TibiaFrame2PixelUpFilledWithCaption
