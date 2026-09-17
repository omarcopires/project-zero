import QtQuick
import QtQuick.Layouts




TibiaOptionsPage {
  id: root
  implicitHeight: contentLayout.height

  optionsSet: controller != null ? controller.screenshotsOptions : null

  ColumnLayout {
    id: contentLayout
    anchors.fill: parent
    spacing: TibiaStyle.marginRelated

    TibiaMenuOptionCheckBox {
      id: onlyGameWindow
      text: qsTrId("optionsmenu_only_game_window")
      guiHelpText: qsTrId("optionsmenu_only_game_window_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet != null && optionsSet.onlyGameWindow
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.onlyGameWindow = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: useBacklog
      text: qsTrId("optionsmenu_use_backlog")
      guiHelpText: qsTrId("optionsmenu_use_backlog_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet != null && optionsSet.useBacklog
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.useBacklog = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaFrame1PixelDownWithGuiHelp {
      Layout.fillWidth: true
      Layout.preferredHeight: screenshotEventsLayout.height + 2 * marginsToContent
      guiHelpUseRichText: true
      guiHelpText: qsTrId("optionsmenu_auto_screenshots_help")
                   + qsTrId("optionsmenu_auto_screenshots_help_events")

      ColumnLayout {
        id: screenshotEventsLayout
        anchors { left: parent.left; top: parent.top; right: parent.right }
        anchors.margins: parent.marginsToContent
        spacing: TibiaStyle.marginRelated

        TibiaCheckBox {
          id: autoScreenshotsEnabled
          text: qsTrId("optionsmenu_auto_screenshots_enabled")
          Layout.fillWidth: true
          shouldBeChecked: optionsSet != null && optionsSet.autoScreenshotsEnabled
          onCheckedChanged: {
            if (optionsSet != null) {
              optionsSet.autoScreenshotsEnabled = checked;
            }
          } //onCheckedChanged
        } //TibiaCheckBox

        TibiaText {
          Layout.fillWidth: true
          Layout.leftMargin: TibiaStyle.paragraphIndentation
          text: qsTrId("optionsmenu_auto_screenshots_select_events_caption")
          enabled: autoScreenshotsEnabled.checked
        } //TibiaText

        RowLayout {
          property int calculatedWidth: parent.width - Layout.leftMargin
          property int columnWidth: Math.floor(calculatedWidth*0.5)

          id: autoScreenshotOptionsLayout
          enabled: autoScreenshotsEnabled.checked
          Layout.minimumWidth: calculatedWidth
          Layout.maximumWidth: calculatedWidth
          Layout.leftMargin: TibiaStyle.paragraphIndentation
          spacing : 0

          ColumnLayout {
            Layout.minimumWidth: autoScreenshotOptionsLayout.columnWidth
            Layout.maximumWidth: autoScreenshotOptionsLayout.columnWidth
            Layout.alignment: Qt.AlignTop
            spacing: TibiaStyle.marginRelated

            TibiaCheckBox {
              text: qsTrId("optionsmenu_auto_screenshots_level_up")
              shouldBeChecked: optionsSet != null && optionsSet.levelUpEnabled
              onCheckedChanged: {
                if (optionsSet != null) {
                  optionsSet.levelUpEnabled = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckBox

            TibiaCheckBox {
              text: qsTrId("optionsmenu_auto_screenshots_skill_up")
              shouldBeChecked: optionsSet != null && optionsSet.skillUpEnabled
              onCheckedChanged: {
                if (optionsSet != null) {
                  optionsSet.skillUpEnabled = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckBox

            TibiaCheckBox {
              text: qsTrId("optionsmenu_auto_screenshots_achievement")
              shouldBeChecked: optionsSet != null && optionsSet.achievementEnabled
              onCheckedChanged: {
                if (optionsSet != null) {
                  optionsSet.achievementEnabled = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckBox

            TibiaCheckBox {
              text: qsTrId("optionsmenu_auto_screenshots_bestiary_partly")
              shouldBeChecked: optionsSet != null && optionsSet.bestiaryPartlyEnabled
              onCheckedChanged: {
                if (optionsSet != null) {
                  optionsSet.bestiaryPartlyEnabled = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckBox

            TibiaCheckBox {
              text: qsTrId("optionsmenu_auto_screenshots_bestiary_full")
              shouldBeChecked: optionsSet != null && optionsSet.bestiaryFullEnabled
              onCheckedChanged: {
                if (optionsSet != null) {
                  optionsSet.bestiaryFullEnabled = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckBox

            TibiaCheckBox {
              text: qsTrId("optionsmenu_auto_screenshots_reward_chest")
              shouldBeChecked: optionsSet != null && optionsSet.rewardChestEnabled
              onCheckedChanged: {
                if (optionsSet != null) {
                  optionsSet.rewardChestEnabled = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckBox

            TibiaCheckBox {
              text: qsTrId("optionsmenu_auto_screenshots_tracked_loot")
              shouldBeChecked: optionsSet != null && optionsSet.trackedLootEnabled
              onCheckedChanged: {
                if (optionsSet != null) {
                  optionsSet.trackedLootEnabled = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckBox

            TibiaCheckBox {
              text: qsTrId("optionsmenu_auto_screenshots_boss_kill")
              shouldBeChecked: optionsSet != null && optionsSet.bossKillEnabled
              onCheckedChanged: {
                if (optionsSet != null) {
                  optionsSet.bossKillEnabled = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckBox
          } //ColumnLayout

          ColumnLayout {
            Layout.minimumWidth: autoScreenshotOptionsLayout.columnWidth
            Layout.maximumWidth: autoScreenshotOptionsLayout.columnWidth
            Layout.alignment: Qt.AlignTop
            spacing: TibiaStyle.marginRelated

            TibiaCheckBox {
              text: qsTrId("optionsmenu_auto_screenshots_death_pve")
              shouldBeChecked: optionsSet != null && optionsSet.deathPvEEnabled
              onCheckedChanged: {
                if (optionsSet != null) {
                  optionsSet.deathPvEEnabled = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckBox

            TibiaCheckBox {
              text: qsTrId("optionsmenu_auto_screenshots_death_pvp")
              shouldBeChecked: optionsSet != null && optionsSet.deathPvPEnabled
              onCheckedChanged: {
                if (optionsSet != null) {
                  optionsSet.deathPvPEnabled = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckBox

            TibiaCheckBox {
              text: qsTrId("optionsmenu_auto_screenshots_player_kill_full")
              shouldBeChecked: optionsSet != null && optionsSet.playerKillFullEnabled
              onCheckedChanged: {
                if (optionsSet != null) {
                  optionsSet.playerKillFullEnabled = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckBox

            TibiaCheckBox {
              text: qsTrId("optionsmenu_auto_screenshots_player_kill_assist")
              shouldBeChecked: optionsSet != null && optionsSet.playerKillAssistEnabled
              onCheckedChanged: {
                if (optionsSet != null) {
                  optionsSet.playerKillAssistEnabled = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckBox

            TibiaCheckBox {
              text: qsTrId("optionsmenu_auto_screenshots_pvp_attack")
              shouldBeChecked: optionsSet != null && optionsSet.pvPAttackEnabled
              onCheckedChanged: {
                if (optionsSet != null) {
                  optionsSet.pvPAttackEnabled = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckBox

            TibiaCheckBox {
              text: qsTrId("optionsmenu_auto_screenshots_new_max_damage")
              shouldBeChecked: optionsSet != null && optionsSet.newMaxDamageEnabled
              onCheckedChanged: {
                if (optionsSet != null) {
                  optionsSet.newMaxDamageEnabled = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckBox

            TibiaCheckBox {
              text: qsTrId("optionsmenu_auto_screenshots_new_max_healing")
              shouldBeChecked: optionsSet != null && optionsSet.newMaxHealingEnabled
              onCheckedChanged: {
                if (optionsSet != null) {
                  optionsSet.newMaxHealingEnabled = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckBox

            TibiaCheckBox {
              text: qsTrId("optionsmenu_auto_screenshots_low_hit_points")
              shouldBeChecked: optionsSet != null && optionsSet.lowHitPointsEnabled
              onCheckedChanged: {
                if (optionsSet != null) {
                  optionsSet.lowHitPointsEnabled = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckBox

            TibiaCheckBox {
              text: qsTrId("optionsmenu_auto_screenshots_gift_of_life")
              shouldBeChecked: optionsSet != null && optionsSet.giftOfLifeEnabled
              onCheckedChanged: {
                if (optionsSet != null) {
                  optionsSet.giftOfLifeEnabled = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckBox
          } //ColumnLayout
        } //RowLayout
      } //ColumnLayout
    } //TibiaFrame1PixelDownWithGuiHelp

    Item { Layout.fillHeight: true }

    TibiaButton {
      text: qsTrId("optionsmenu_open_screenshot_directory")
      Layout.preferredWidth: TibiaStyle.buttonWidthWidest
      onClicked: {
        if (controller != null) {
          controller.openScreenshotDirectory();
        }
      } //onClicked
    } //TibiaButton
  } //ColumnLayout
} //TibiaOptionsPage
