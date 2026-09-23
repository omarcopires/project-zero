import QtQuick
import QtQuick.Layouts

import qmlcomponents



ColumnLayout {
  id: root
  implicitWidth: 180
  implicitHeight: TibiaStyle.selectionAreaInformationHeight
  spacing: TibiaStyle.marginRelated

  property bool hoverMode: false
  property var informationSet: null

  TibiaProgressBarOrangeToGreen {
    id: perkProgress
    Layout.fillWidth: true

    readonly property real currentSkillPoints: informationSet != null ? informationSet.currentSkillPoints : 0
    readonly property real nextSkillPointThreshold: informationSet != null ? informationSet.nextSkillPointThreshold : 9999

    fillPercentage: currentSkillPoints / nextSkillPointThreshold

    TibiaText {
      anchors.centerIn: parent

      text: qsTrId("count_slash_total")
        .arg(perkProgress.currentSkillPoints)
        .arg(perkProgress.nextSkillPointThreshold)
    } //TibiaText
  } //TibiaProgressBarOrangeToGreen

  ColumnLayout {
    Layout.fillWidth: true
    spacing: TibiaStyle.marginNarrow

    TibiaText {
      Layout.fillWidth: true
      horizontalAlignment: Text.AlignHCenter
      text: qsTrId("skill_wheel_dialog_large_perk")

      TibiaGuiHelp {
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        visible: !root.hoverMode
        useRichText: true

        text: informationSet != null ? informationSet.largePerkHover : ""
      } //TibiaGuiHelp
    } //TibiaText

    TibiaText {
      Layout.fillWidth: true
      enabled: informationSet != null && informationSet.currentLevel > 0
      text: informationSet != null ? informationSet.perkName : ""
    } //TibiaText

    TibiaText {
      Layout.fillWidth: true
      enabled: informationSet != null && informationSet.currentLevel > 0
      wrapMode: Text.Wrap

      text: informationSet != null ? informationSet.shortInformation : ""
    } //TibiaText
  } //ColumnLayout

  RowLayout {
    visible: !root.hoverMode

    TibiaText {
      text: qsTrId("skill_wheel_dialog_more_information")
    } //TibiaText

    TibiaGuiHelp {
      useRichText: true
      text: informationSet != null ? informationSet.detailedInformation : ""
    } //TibiaGuiHelp
  } //RowLayout

  TibiaText {
    Layout.fillWidth: true
    text: informationSet != null ? informationSet.currentLevelName : ""
  } //TibiaText

  Item {
    Layout.fillHeight: true
    Layout.fillWidth: true
  } //Item

} //ColumnLayout
