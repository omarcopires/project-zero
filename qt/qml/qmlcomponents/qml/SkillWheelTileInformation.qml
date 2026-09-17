import QtQuick
import QtQuick.Layouts

import qmlcomponents



ColumnLayout {
  id: root
  implicitWidth: 180
  implicitHeight: TibiaStyle.selectionAreaInformationHeight
  spacing: 0

  property var informationSet: null
  property bool hoverMode: false
  property bool isLocalPlayer: true
  property bool isPremium: true
  property bool canBeDecreased: true
  property bool canBeIncreased: true
  property int spentSkillPoints: 0
  property int totalSkillPoints: 0

  signal clearSkillClicked()
  signal removeFromSkillClicked(int keyboardModifiers)
  signal addToSkillClicked(int keyboardModifiers)
  signal fillSkillClicked()


  TibiaProgressBarOrangeToGreen {
    Layout.fillWidth: true
    Layout.bottomMargin: TibiaStyle.marginRelated

    fillPercentage: skillButtonsLayout.currentSkillPoints / skillButtonsLayout.maximumSkillPoints

    TibiaText {
      anchors.centerIn: parent

      text: qsTrId("count_slash_total")
        .arg(skillButtonsLayout.currentSkillPoints)
        .arg(skillButtonsLayout.maximumSkillPoints)
    } //TibiaText
  } //TibiaProgressBarOrangeToGreen

  ColumnLayout {
    Layout.fillWidth: true
    Layout.bottomMargin: TibiaStyle.marginRelated
    spacing: TibiaStyle.marginNarrow

    TibiaText {
      Layout.fillWidth: true
      horizontalAlignment: Text.AlignHCenter
      text: qsTrId("skill_wheel_dialog_small_perk")

      TibiaGuiHelp {
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        visible: !root.hoverMode
        useRichText: true

        text: informationSet != null ? informationSet.smallPerkHover : ""
      } //TibiaGuiHelp
    } //TibiaText

    TibiaText {
      Layout.fillWidth: true
      Layout.preferredHeight: 2 * TibiaStyle.defaultTextLineHeight
      enabled: skillButtonsLayout.currentSkillPoints > 0
      text: informationSet != null ? informationSet.smallPerkSumInfo : ""
    } //TibiaText
  } //ColumnLayout

  ColumnLayout {
    Layout.fillWidth: true
    Layout.bottomMargin: TibiaStyle.marginRelated
    spacing: TibiaStyle.marginNarrow

    TibiaText {
      Layout.fillWidth: true
      horizontalAlignment: Text.AlignHCenter
      text: qsTrId("skill_wheel_dialog_medium_perk")

      TibiaGuiHelp {
        visible: !root.hoverMode
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        useRichText: true

        text: informationSet != null ? informationSet.mediumPerkHover : ""
      } //TibiaGuiHelp
    } //TibiaText

    TibiaText {
      Layout.fillWidth: true
      enabled: informationSet != null && informationSet.mediumPerkUnlocked
      text: informationSet != null ? informationSet.mediumPerkInfo : ""
    } //TibiaText

    TibiaText {
      id: additionalInfoText
      Layout.fillWidth: true
      Layout.fillHeight: true
      visible: !aug1Layout.visible
            && !aug2Layout.visible
            && text.length > 0
      //maximumLineCount: aug1Text.maximumLineCount + aug2Text.maximumLineCount
      wrapMode: Text.Wrap
      tooltipMaxWidth: TibiaStyle.guiHelpTooltipWidth
      active:  informationSet != null && informationSet.mediumPerkUnlocked
      text: informationSet != null ? informationSet.mediumPerkAdditional : ""
    } //TibiaText

    RowLayout {
      id: aug1Layout
      visible: aug1Text.text.length > 0
      spacing: 0

      Image {
        Layout.alignment: Qt.AlignTop
        Layout.topMargin: 3
        source: informationSet != null && informationSet.mediumPerkCount > 0
          ? "/images/skillwheel/icon-augmentation1-active.png"
          : "/images/skillwheel/icon-augmentation1-inactive.png"
      } //Image

      TibiaText {
        Layout.alignment: Qt.AlignTop
        text: ": "
      } //TibiaText

      TibiaText {
        id: aug1Text
        Layout.fillWidth: true
        styleType: informationSet != null && informationSet.mediumPerkCount > 0 ? "Dialog" : "Disabled"
        tooltipUseRichText: true
        maximumLineCount: 2
        wrapMode: Text.Wrap

        text: informationSet != null ? informationSet.aug1Info : ""
        tooltipText: informationSet != null ? informationSet.aug1InfoHover : ""
      } //TibiaText
    } //RowLayout

    RowLayout {
      id: aug2Layout
      visible: aug2Text.text.length > 0
      spacing: 0

      Image {
        Layout.alignment: Qt.AlignTop
        Layout.topMargin: 3
        source: informationSet != null && informationSet.mediumPerkCount > 1
          ? "/images/skillwheel/icon-augmentation2-active.png"
          : "/images/skillwheel/icon-augmentation2-inactive.png"
      } //Image

      TibiaText {
        Layout.alignment: Qt.AlignTop
        text: ": "
      } //TibiaText

      TibiaText {
        id: aug2Text
        Layout.fillWidth: true
        styleType: informationSet != null && informationSet.mediumPerkCount > 1 ? "Dialog" : "Disabled"
        tooltipUseRichText: true
        maximumLineCount: 2
        wrapMode: Text.Wrap

        text: informationSet != null ? informationSet.aug2Info : ""
        tooltipText: informationSet != null ? informationSet.aug2InfoHover : ""
      } //TibiaText
    } //RowLayout
  } //ColumnLayout

  Item {
    Layout.fillHeight: true
    Layout.fillWidth: true
    visible: !additionalInfoText.visible
  } //Item

  RowLayout {
    id: skillButtonsLayout
    Layout.fillWidth: true
    visible: isLocalPlayer
         && !root.hoverMode
    spacing: TibiaStyle.marginNarrow

    readonly property real currentSkillPoints: informationSet != null ? informationSet.currentSkillPoints : 0
    readonly property real maximumSkillPoints: informationSet != null ? informationSet.maximumSkillPoints : 9999
    readonly property bool allowDecrease: root.canBeDecreased
                                      && informationSet != null && informationSet.canBeDecreased
    readonly property bool allowIncrease: root.canBeIncreased
                                      && (root.spentSkillPoints < root.totalSkillPoints)
                                      && informationSet != null && informationSet.canBeIncreased
    readonly property bool noPremiumNoDecrease: !root.canBeDecreased
                                             && root.isLocalPlayer
                                             && !root.isPremium
    readonly property bool noPremiumNoIncrease: !root.canBeIncreased
                                             && root.isLocalPlayer
                                             && !root.isPremium

    Item {
      Layout.preferredWidth: clearButton.width
      Layout.preferredHeight: clearButton.height

      TibiaButton {
        id: clearButton
        width: TibiaStyle.buttonWidthSmall
        enabled: skillButtonsLayout.allowDecrease

        text: qsTrId("skill_wheel_dialog_button_decreas_max")
        onClicked: root.clearSkillClicked()
      } //TibiaButton

      Tooltip {
        id: whyNoReduceTooltip
        anchors.fill: parent
        maxWidth: TibiaStyle.guiHelpTooltipWidth

        enabled: !clearButton.enabled
        text: {
          if (skillButtonsLayout.noPremiumNoDecrease) {
            return qsTrId("skill_wheel_dialog_no_change_because_no_premium");
          } else if (informationSet != null && !informationSet.canBeDecreased) {
            if (skillButtonsLayout.currentSkillPoints > 0) {
              return qsTrId("skill_wheel_dialog_no_reduction_because_dependent");
            } else {
              return qsTrId("skill_wheel_dialog_no_reduction_because_zero");
            }
          }
          return qsTrId("skill_wheel_dialog_why_no_reduction");
        } //text
      } //Tooltip
    } //Item

    Item {
      Layout.preferredWidth: decreaseButton.width
      Layout.preferredHeight: decreaseButton.height

      TibiaAutorepeatIconButton {
        id: decreaseButton
        enabled: skillButtonsLayout.allowDecrease
        sourceUp: "/images/skillwheel/change-skillpoints-button-up.png"
        sourceDown: "/images/skillwheel/change-skillpoints-button-down.png"

        TibiaText {
          anchors.centerIn: parent
          anchors.verticalCenterOffset: parent.pressed ? 1 : 0
          anchors.horizontalCenterOffset: parent.pressed ? 1 : 0

          font: TibiaStyle.buttonFont

          text: qsTrId("skill_wheel_dialog_button_decreas")
        } //TibiaText

        tooltipText: qsTrId("skill_wheel_dialog_button_increase_decrease_tooltip")
        triggerFunction: (function(mouse) { root.removeFromSkillClicked(mouse != null ? mouse.modifiers : 0); })
      } //TibiaAutorepeatIconButton

      Tooltip {
        anchors.fill: parent
        maxWidth: TibiaStyle.guiHelpTooltipWidth

        enabled: !decreaseButton.enabled
        text: whyNoReduceTooltip.text
      } //Tooltip
    } //Item

    Item { Layout.fillWidth: true }

    Item {
      Layout.preferredWidth: increaseButton.width
      Layout.preferredHeight: increaseButton.height

      TibiaAutorepeatIconButton {
        id: increaseButton
        enabled: skillButtonsLayout.allowIncrease
        sourceUp: "/images/skillwheel/change-skillpoints-button-up.png"
        sourceDown: "/images/skillwheel/change-skillpoints-button-down.png"

        TibiaText {
          anchors.centerIn: parent
          anchors.verticalCenterOffset: parent.pressed ? 1 : 0
          anchors.horizontalCenterOffset: parent.pressed ? 1 : 0

          font: TibiaStyle.buttonFont

          text: qsTrId("skill_wheel_dialog_button_increase")
        } //TibiaText

        tooltipText: qsTrId("skill_wheel_dialog_button_increase_decrease_tooltip")
        triggerFunction: (function(mouse) { root.addToSkillClicked(mouse != null ? mouse.modifiers : 0); })
      } //TibiaAutorepeatIconButton

      Tooltip {
        anchors.fill: parent
        maxWidth: TibiaStyle.guiHelpTooltipWidth

        enabled: !increaseButton.enabled
        text: whyNoIncreaseTooltip.text
      } //Tooltip
    } //Item

    Item {
      Layout.preferredWidth: fillButton.width
      Layout.preferredHeight: fillButton.height

      TibiaButton {
        id: fillButton
        width: TibiaStyle.buttonWidthSmall
        enabled: skillButtonsLayout.allowIncrease

        text: qsTrId("skill_wheel_dialog_button_increase_max")
        onClicked: root.fillSkillClicked()
      } //TibiaButton

      Tooltip {
        id: whyNoIncreaseTooltip
        anchors.fill: parent
        maxWidth: TibiaStyle.guiHelpTooltipWidth

        enabled: !fillButton.enabled
        text: {
          if (skillButtonsLayout.noPremiumNoIncrease) {
            return qsTrId("skill_wheel_dialog_no_change_because_no_premium");
          } else if (informationSet != null && !informationSet.canBeIncreased) {
            if (skillButtonsLayout.currentSkillPoints == skillButtonsLayout.maximumSkillPoints) {
              return qsTrId("skill_wheel_dialog_no_increase_because_max");
            }
          } else if (root.spentSkillPoints == root.totalSkillPoints){
            return qsTrId("skill_wheel_dialog_no_increase_because_no_skill_points");
          }

          return qsTrId("skill_wheel_dialog_why_no_increase");
        } //text
      } //Tooltip
    } //Item
  } //RowLayout

  TibiaText {
    Layout.fillWidth: true
    wrapMode: Text.Wrap
    visible: root.hoverMode && root.canBeDecreased
    text: qsTrId("skill_wheel_dialog_right_click_fillorreset_hint")
  } //TibiaText

  TibiaText {
    Layout.fillWidth: true
    wrapMode: Text.Wrap
    visible: root.hoverMode && !root.canBeDecreased
    text: qsTrId("skill_wheel_dialog_right_click_fill_hint")
  } //TibiaText
} //ColumnLayout
