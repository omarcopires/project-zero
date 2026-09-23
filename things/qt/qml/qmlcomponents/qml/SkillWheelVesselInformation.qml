import QtQuick
import QtQuick.Layouts

import qmlcomponents


ColumnLayout {
  id: root
  implicitWidth: 180
  implicitHeight: TibiaStyle.selectionAreaInformationHeight
  spacing: TibiaStyle.marginRelated

  property bool hoverMode: false
  property bool isLocalPlayer: true
  property var informationSet: null

  signal changeGemClicked()

  ColumnLayout {
    id: gemLayout
    Layout.fillWidth: true
    spacing: TibiaStyle.marginNarrow

    RowLayout {
      spacing: 0

      TibiaText {
        id: gemText
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        visible: text.length > 0
        text: informationSet != null ? informationSet.gemName : qsTrId("dummy_unknown")
      } //TibiaText

      TibiaText {
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        visible: !gemText.visible
        text: qsTrId("skill_wheel_dialog_no_gem")
      } //TibiaText

      Image {
        source: informationSet != null ? informationSet.mod1GradeImage : ""
      }

      Image {
        source: informationSet != null ? informationSet.mod2GradeImage : ""
      }

      Image {
        source: informationSet != null ? informationSet.mod3GradeImage : ""
      }

      TibiaGuiHelp {
        visible: !root.hoverMode
        useRichText: true
        Layout.leftMargin: TibiaStyle.marginNarrow

        text: informationSet != null ? informationSet.gemInfo : ""
      } //TibiaGuiHelp
    } //RowLayout

    ColumnLayout {
      id: modLayout
      Layout.fillWidth: true
      Layout.minimumHeight: 10
      spacing: TibiaStyle.marginRelated
      visible: informationSet != null
        && (   informationSet.mod1Info.length > 0
            || informationSet.mod2Info.length > 0
            || informationSet.mod3Name.length > 0
            || informationSet.mod3Info.length > 0)

      TibiaText {
        id: mod1Text
        Layout.fillWidth: true
        styleType: informationSet != null && informationSet.numberOfActiveMods >= 1 ? "Dialog" : "Disabled"
        wrapMode: Text.Wrap
        visible: text.length > 0

        text: informationSet != null ? informationSet.mod1Info : ""
      } //TibiaText

      TibiaText {
        id: mod2Text
        Layout.fillWidth: true
        styleType: informationSet != null && informationSet.numberOfActiveMods >= 2 ? "Dialog" : "Disabled"
        wrapMode: Text.Wrap
        visible: text.length > 0

        text: informationSet != null ? informationSet.mod2Info : ""
      } //TibiaText

      TibiaText {
        id: mod3NameText
        Layout.fillWidth: true
        Layout.bottomMargin: -parent.spacing
        styleType: informationSet != null && informationSet.numberOfActiveMods >= 3 ? "Dialog" : "Disabled"
        visible: text.length > 0

        text: informationSet != null ? informationSet.mod3Name : ""
      } //TibiaText

      TibiaText {
        id: mod3Text
        Layout.fillWidth: true
        styleType: informationSet != null && informationSet.numberOfActiveMods >= 3 ? "Dialog" : "Disabled"
        wrapMode: Text.Wrap
        maximumLineCount: 2
        visible: text.length > 0

        text: informationSet != null ? informationSet.mod3Info : ""
      } //TibiaText
    } //ColumnLayout
  } //ColumnLayout

  Item {
    Layout.fillHeight: true
    Layout.fillWidth: true
    Layout.topMargin: -parent.spacing
  } //Item

  ColumnLayout {
    Layout.fillWidth: true
    spacing: TibiaStyle.marginNarrow

    TibiaText {
      Layout.fillWidth: true
      horizontalAlignment: Text.AlignHCenter
      text: informationSet != null ? informationSet.vesselActivation : qsTrId("dummy_unknown")

      TibiaGuiHelp {
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        visible: !root.hoverMode
        useRichText: true

        text: informationSet != null ? informationSet.vesselBonusInfo : ""
      } //TibiaGuiHelp
    } //TibiaText

    TibiaText {
      enabled: informationSet != null && informationSet.hasVesselBonus
      text: informationSet != null ? informationSet.vesselBonus : qsTrId("dummy_unknown")
    } //TibiaText
  } //ColumnLayout

  TibiaButton {
    Layout.alignment: Qt.AlignHCenter
    Layout.preferredWidth: TibiaStyle.buttonWidthWide
    visible: root.isLocalPlayer
      && !root.hoverMode
    text: qsTrId("skill_wheel_dialog_change_gem")
    onClicked: root.changeGemClicked()
  } //TibiaButton
} //ColumnLayout
