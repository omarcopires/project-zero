import QtQuick
import QtQuick.Layouts

import qmlcomponents


ColumnLayout {
  id: root
  property int kills: 0
  property int killsForProwess: 0
  property int killsForExpertise: 0
  property int killsForMastery: 0
  property int preferredProgressBarWidth: 0
  property bool showTotalKillsCaption: true
  spacing: TibiaStyle.marginNarrow

  TibiaText {
    visible: root.showTotalKillsCaption
    Layout.alignment: Qt.AlignHCenter
    Layout.bottomMargin: TibiaStyle.marginNarrow
    text: qsTrId("bosstiary_total_kills")
  } // TibiaText

  CreatureUnlockProgress {
    Layout.fillWidth: (preferredProgressBarWidth > 0 ? false : true)
    Layout.preferredWidth: (preferredProgressBarWidth > 0 ? preferredProgressBarWidth : -1)
    Layout.alignment: Qt.AlignHCenter
    Layout.preferredHeight: TibiaStyle.progressBarSmallHeight
    currentKills: kills
    killsToUnlockDetails1: killsForProwess
    killsToUnlockDetails2: killsForExpertise
    killsToFullUnlock: killsForMastery
  } // CreatureUnlockProgress

  RowLayout {
    Layout.fillWidth: (preferredProgressBarWidth > 0 ? false : true)
    Layout.preferredWidth: (preferredProgressBarWidth > 0 ? preferredProgressBarWidth : -1)
    Layout.alignment: Qt.AlignHCenter
    spacing: 0

    Item {
      Layout.preferredWidth: parent.width / 3
      Layout.preferredHeight: childrenRect.height
      readonly property string prowessUnlockImageSource: kills >= killsForProwess ? "/images/icon-star-bronze.png" : "/images/icon-star-dark.png"

      Image {
        anchors.horizontalCenter: parent.horizontalCenter
        source: parent.prowessUnlockImageSource
      } // Image
    } // Item

    RowLayout {
      Layout.preferredWidth: parent.width / 3
      spacing: TibiaStyle.marginNarrow
      readonly property string expertiseUnlockImageSource: kills >= killsForExpertise ? "/images/icon-star-silver.png" : "/images/icon-star-dark.png"

      Item {
        Layout.fillWidth: true
      } // Item
      Image {
        source: parent.expertiseUnlockImageSource
      } // Image
      Image {
        source: parent.expertiseUnlockImageSource
      } // Image
      Item {
        Layout.fillWidth: true
      } // Item
    } // RowLayout

    RowLayout {
      Layout.preferredWidth: parent.width / 3
      spacing: TibiaStyle.marginNarrow
      readonly property string masteryUnlockImageSource: kills >= killsForMastery ? "/images/icon-star-gold.png" : "/images/icon-star-dark.png"

      Item {
        Layout.fillWidth: true
      } // Item
      Image {
        source: parent.masteryUnlockImageSource
      } // Image
      Image {
        source: parent.masteryUnlockImageSource
      } // Image
      Image {
        source: parent.masteryUnlockImageSource
      } // Image
      Item {
        Layout.fillWidth: true
      } // Item
    } // RowLayout
  } // RowLayout
} // ColumnLayout
