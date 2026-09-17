import QtQuick
import QtQuick.Layouts

import qmlcomponents
import qmlenumvalues

TibiaSidebarPanel {
  id: buttonBarPanel

  readonly property string lenshelpCaption: qsTrId("buttonbar_lenshelp_caption")
  readonly property string lenshelpDropDownButton: qsTrId("buttonbar_lenshelp_drop_down_button")

  property bool newsButtonHighlight: panelController != null &&
                                     panelController.newsButtonController.highlighted
  property bool friendsButtonHighlight: panelController != null &&
                                        panelController.socialButtonController != null &&
                                        panelController.socialButtonController.highlighted
  property bool rewardWallButtonHighlight: panelController != null &&
                                           panelController.highlightRewardWallButton
  property bool cyclopediaButtonHighlight: panelController != null &&
                                           panelController.cyclopediaButtonController != null &&
                                           panelController.cyclopediaButtonController.highlighted
  property bool bosstiaryButtonHighlight:  panelController != null &&
                                           panelController.bosstiaryButtonController != null &&
                                           panelController.bosstiaryButtonController.highlighted

  extraContentPixel: 1 //TIBIA-29062

  ColumnLayout {
    anchors { left: parent.left; top: parent.top; right: parent.right }
    anchors.margins: buttonBarPanel.extraContentPixel
    spacing: 0 //Needed to add Layout.topMargin: TibiaStyle.marginRelated to embeded Layouts to avoid extra height if buttons become invisible

    RowLayout {
      Layout.fillWidth: true
      spacing: 0

      StoreButton {
        Layout.preferredWidth: TibiaStyle.minimapViewportWidth
        buttonController: panelController != null ? panelController.storeButtonController : null
      } //StoreButton

      Item {
        Layout.fillWidth: true
      } //Item

      TibiaButton {
        id: dropDownButton
        Layout.preferredWidth: TibiaStyle.sideBarPanelRightSideWith
        imageSource: "/images/icon-menu.png"
        tooltipText: qsTrId("buttonbar_shortcuts_show_tooltip")
        tooltipTextChecked: qsTrId("buttonbar_shortcuts_hide_tooltip")
        checkable: true

        buttonShouldBeChecked: panelController == null ? false : panelController.shortcutsVisible
        useButtonShouldBeChecked: true

        onClicked: {
          if (panelController != null) {
            panelController.onDropdownButtonClicked();
          }
        } //onClicked

        TibiaRectangleHighlight {
          visible: !dropDownButton.checked
                && (   buttonBarPanel.newsButtonHighlight
                    || buttonBarPanel.friendsButtonHighlight
                    || buttonBarPanel.rewardWallButtonHighlight
                    || buttonBarPanel.cyclopediaButtonHighlight
                    || panelController != null
                        && (panelController.highlightRewardWallButton
                        || panelController.highlightSkillWheelButton
                        || panelController.highlightExaltationForgeDialogButton
                        || panelController.highlightWeaponProficiencyButton
                        || panelController.taskboardButtonHighlight)
                   )

        } //TibiaRectangleHighlight

        Lenshelp {
          anchors.fill: parent
          caption: buttonBarPanel.lenshelpCaption
          content: buttonBarPanel.lenshelpDropDownButton
        } //Lenshelp
      } //TibiaIconButton
    } //RowLayout

    RowLayout {
      id: buttonBar
      Layout.fillWidth: true
      Layout.topMargin: TibiaStyle.marginRelated
      spacing: TibiaStyle.marginNarrow
      visible: dropDownButton.pressed || (panelController != null && panelController.shortcutsVisible)

      Component {
        id: skillsButtonComponent

        TibiaIconButton {
          sourceUp: "/images/button-skills-up.png"
          sourceDown: "/images/button-skills-down.png"
          tooltipText: qsTrId("buttonbar_skillswidget_open_tooltip")
          tooltipTextChecked: qsTrId("buttonbar_skillswidget_close_tooltip")
          checkable: true
          useButtonShouldBeChecked: true

          buttonShouldBeChecked: panelController == null ? false : panelController.skillWidgetVisible

          onClicked: {
            if (panelController != null) {
              panelController.onSkillButtonClicked();
            }
          } //onClicked

          Lenshelp {
            anchors.fill: parent
            anchors.margins: -1
            caption: buttonBarPanel.lenshelpCaption
            content: qsTrId("buttonbar_lenshelp_skills")
          } //Lenshelp
        } // TibiaIconButton
      } // skillsButtonComponent

      Component {
        id: battleListComponent

        TibiaIconButton {
          sourceUp: "/images/button-battlelist-up.png"
          sourceDown: "/images/button-battlelist-down.png"
          tooltipText: qsTrId("buttonbar_battlewidget_open_tooltip");
          tooltipTextChecked: qsTrId("buttonbar_battlewidget_close_tooltip")
          checkable: true
          useButtonShouldBeChecked: true

          buttonShouldBeChecked: panelController != null && panelController.battleListVisible

          onClicked: {
            if (panelController != null) {
              panelController.onBattleListButtonClicked();
            }
          } //onClicked

          Lenshelp {
            anchors.fill: parent
            anchors.margins: -1
            caption: buttonBarPanel.lenshelpCaption
            content: qsTrId("buttonbar_lenshelp_battle")
          } //Lenshelp
        } // TibiaIconButton
      } // battleListComponent

      Component {
        id: partyListComponent

        TibiaButton {
          width: TibiaStyle.iconButtonSize
          height: TibiaStyle.iconButtonSize

          imageSource: "/images/icon-battlelist-party-button.png"
          tooltipText: qsTrId("buttonbar_partylist_open_tooltip")
          tooltipTextChecked: qsTrId("buttonbar_partylist_close_tooltip")
          checkable: true
          useButtonShouldBeChecked: true

          buttonShouldBeChecked: panelController != null && panelController.partyListVisible

          onClicked: {
            if (panelController != null) {
              panelController.onPartyListButtonClicked();
            }
          } //onClicked

          Lenshelp {
            anchors.fill: parent
            anchors.margins: -1
            caption: buttonBarPanel.lenshelpCaption
            content: qsTrId("buttonbar_lenshelp_party")
          } //Lenshelp
        } //TibiaButton
      } // partyListComponent

      Component {
        id: vipComponent

        TibiaIconButton {
          sourceUp: "/images/button-viplist-up.png"
          sourceDown: "/images/button-viplist-down.png"
          tooltipText: qsTrId("buttonbar_vipwidget_open_tooltip");
          tooltipTextChecked: qsTrId("buttonbar_vipwidget_close_tooltip");
          checkable: true
          useButtonShouldBeChecked: true

          buttonShouldBeChecked: panelController == null ? false : panelController.vipWidgetVisible

          onClicked: {
            if (panelController != null) {
              panelController.onVipWidgetButtonClicked();
            }
          } //onClicked

          Lenshelp {
            anchors.fill: parent
            caption: buttonBarPanel.lenshelpCaption
            content: qsTrId("buttonbar_lenshelp_vip")
          } //Lenshelp
        } // TibiaIconButton
      } // vipComponent

      Component {
        id: questlogComponent

        TibiaIconButton {
          sourceUp: "/images/button-questlog-up.png"
          sourceDown: "/images/button-questlog-down.png"
          tooltipText: qsTrId("buttonbar_questdialog_open_tooltip")

          onClicked: {
            if (panelController != null) {
              panelController.onQuestLogButtonClicked();
            }
          } //onClicked

          Lenshelp {
            anchors.fill: parent
            anchors.margins: -1
            caption: buttonBarPanel.lenshelpCaption
            content: qsTrId("buttonbar_lenshelp_quests")
          } //Lenshelp
        } // TibiaIconButton
      } // questlogComponent

      Component {
        id: spellsComponent

        TibiaIconButton {
          sourceUp: "/images/button-spelllistwidget-up.png"
          sourceDown: "/images/button-spelllistwidget-down.png"
          tooltipText: qsTrId("buttonbar_spelllistwidget_open_tooltip")
          tooltipTextChecked: qsTrId("buttonbar_spelllistwidget_close_tooltip")
          checkable: true
          useButtonShouldBeChecked: true

          buttonShouldBeChecked: panelController == null ? false : panelController.spellListWidgetVisible

          onClicked: {
            if (panelController != null) {
              panelController.onSpellListWidgetButtonClicked();
            }
          } //onClicked

          Lenshelp {
            anchors.fill: parent
            anchors.margins: -1
            caption: buttonBarPanel.lenshelpCaption
            content: qsTrId("buttonbar_lenshelp_spells")
          } //Lenshelp
        } // TibiaIconButton
      } // spellsComponent

      Component {
        id: unjustComponent

        TibiaIconButton {
          sourceUp: "/images/button-unjustpoints-up.png"
          sourceDown: "/images/button-unjustpoints-down.png"
          tooltipText: qsTrId("buttonbar_unjustwidget_open_tooltip")
          tooltipTextChecked: qsTrId("buttonbar_unjustwidget_close_tooltip")
          checkable: true
          useButtonShouldBeChecked: true

          buttonShouldBeChecked: panelController == null ? false : panelController.unjustifiedWidgetVisible

          onClicked: {
            if (panelController != null) {
              panelController.onUnjustifiedPointsButtonClicked();
            }
          } //onClicked

          Lenshelp {
            anchors.fill: parent
            anchors.margins: -1
            caption: buttonBarPanel.lenshelpCaption
            content: qsTrId("buttonbar_lenshelp_unjustified")
          } //Lenshelp
        } // TibiaIconButton
      } // unjustComponent

      Component {
        id: questTrackerComponent

        TibiaButton {
          imageSource: "/images/skin/classic/icon-questtracker.png"
          tooltipText: qsTrId("buttonbar_questtracker_open_tooltip")
          tooltipTextChecked: qsTrId("buttonbar_questtracker_close_tooltip")
          checkable: true
          useButtonShouldBeChecked: true

          buttonShouldBeChecked: panelController == null ? false : panelController.questTrackerVisible

          onClicked: {
            if (panelController != null) {
              panelController.onQuestTrackerButtonClicked();
            }
          } //onClicked

          Lenshelp {
            anchors.fill: parent
            anchors.margins: -1
            caption: buttonBarPanel.lenshelpCaption
            content: qsTrId("buttonbar_lenshelp_questtracker")
          } //Lenshelp
        } // TibiaIconButton
      } // questTrackerComponent

      Component {
        id: bestiaryTrackerComponent

        TibiaButton {
          imageSource: "/images/skin/classic/icon-bestiarytracker.png"
          tooltipText: qsTrId("buttonbar_bestiarytracker_open_tooltip")
          tooltipTextChecked: qsTrId("buttonbar_bestiarytracker_close_tooltip")
          checkable: true
          useButtonShouldBeChecked: true

          buttonShouldBeChecked: panelController == null ? false : panelController.bestiaryTrackerVisible

          onClicked: {
            if (panelController != null) {
              panelController.onBestiaryTrackerButtonClicked();
            }
          } //onClicked

          Lenshelp {
            anchors.fill: parent
            anchors.margins: -1
            caption: buttonBarPanel.lenshelpCaption
            content: qsTrId("buttonbar_lenshelp_bestiarytracker")
          } //Lenshelp
        } // TibiaIconButton
      } // bestiaryTrackerComponent

      Component {
        id: bosstiaryTrackerComponent

        TibiaButton {
          imageSource: "/images/skin/classic/icon-bosstiarytracker.png"
          tooltipText: qsTrId("buttonbar_bosstiarytracker_open_tooltip")
          tooltipTextChecked: qsTrId("buttonbar_bosstiarytracker_close_tooltip")
          checkable: true
          useButtonShouldBeChecked: true

          buttonShouldBeChecked: panelController == null ? false : panelController.bosstiaryTrackerVisible

          onClicked: {
            if (panelController != null) {
              panelController.onBosstiaryTrackerButtonClicked();
            }
          } //onClicked

          Lenshelp {
            anchors.fill: parent
            anchors.margins: -1
            caption: buttonBarPanel.lenshelpCaption
            content: qsTrId("buttonbar_lenshelp_bosstiarytracker")
          } //Lenshelp
        } // TibiaIconButton
      } // bestiaryTrackerComponent

      Component {
        id: killTrackerComponent

        TibiaIconButton {
          sourceUp: "/images/button-killtracker-up.png"
          sourceDown: "/images/button-killtracker-down.png"
          tooltipText: qsTrId("buttonbar_killtracker_open_tooltip")
          tooltipTextChecked: qsTrId("buttonbar_killtracker_close_tooltip")
          checkable: true
          useButtonShouldBeChecked: true

          buttonShouldBeChecked: panelController == null ? false : panelController.killTrackerWidgetVisible

          onClicked: {
            if (panelController != null) {
              panelController.onKillTrackerWidgetButtonClicked();
            }
          } //onClicked

          Lenshelp {
            anchors.fill: parent
            anchors.margins: -1
            caption: buttonBarPanel.lenshelpCaption
            content: qsTrId("buttonbar_lenshelp_killtracker")
          } //Lenshelp
        } // TibiaIconButton
      } // killTrackerComponent

      Component {
        id: analyticsComponent

        TibiaIconButton {
          id: cyclopediaAnalyticsButton
          sourceUp: "/images/button-analyticsselector-up.png"
          sourceDown: "/images/button-analyticsselector-down.png"
          tooltipText: qsTrId("buttonbar_analyticsselector_open_tooltip")
          tooltipTextChecked: qsTrId("buttonbar_analyticsselector_close_tooltip")
          checkable: true
          useButtonShouldBeChecked: true

          buttonShouldBeChecked: panelController == null ? false : panelController.analyticsSelectorWidgetVisible

          onClicked: {
            if (panelController != null) {
              panelController.onAnalyticsSelectorWidgetButtonClicked();
            }
          } //onClicked

          Lenshelp {
            anchors.fill: parent
            anchors.margins: -1
            caption: buttonBarPanel.lenshelpCaption
            content: qsTrId("buttonbar_lenshelp_analytics")
          } //Lenshelp
        } // TibiaIconButton
      } // analyticsComponent

      Component {
        id: dailyRewardComponent

        TibiaIconButton {
          sourceUp: "/images/button-rewardwall-up.png"
          sourceDown: "/images/button-rewardwall-down.png"
          tooltipText: qsTrId("buttonbar_rewardwall_open_tooltip")

          onClicked: {
            if (panelController != null) {
              panelController.onRewardWallButtonClicked();
            }
          } //onClicked

          TibiaRectangleHighlight {
            visible: buttonBarPanel.rewardWallButtonHighlight
          } //TibiaRectangleHighlight

          Lenshelp {
            anchors.fill: parent
            anchors.margins: -1
            caption: buttonBarPanel.lenshelpCaption
            content: qsTrId("buttonbar_lenshelp_dailyreward")
          } //Lenshelp
        } // TibiaIconButton
      } // dailyRewardComponent

      Component {
        id: compendiumComponent

        NewsButton {
          id: newsButton
          buttonController: panelController != null ? panelController.newsButtonController : null

          Lenshelp {
            anchors.fill: parent
            anchors.margins: -1
            caption: buttonBarPanel.lenshelpCaption
            content: qsTrId("buttonbar_lenshelp_compendium")
          } //Lenshelp
        } //NewsButton
      } // compendiumComponent

      Component {
        id: cyclopediaComponent

        TibiaIconButton {
          sourceUp: "/images/button-cyclopedia-up.png"
          sourceDown: "/images/button-cyclopedia-down.png"
          tooltipText: qsTrId("buttonbar_cyclopedia_tooltip")

          onClicked: {
            if (panelController != null && panelController.cyclopediaButtonController != null) {
              panelController.cyclopediaButtonController.onCyclopediaButtonClicked();
            }
          } //onClicked

          TibiaRectangleHighlight {
            visible: buttonBarPanel.cyclopediaButtonHighlight
          } //TibiaRectangleHighlight

          Lenshelp {
            anchors.fill: parent
            anchors.margins: -1
            caption: buttonBarPanel.lenshelpCaption
            content: qsTrId("buttonbar_lenshelp_cyclopedia")
          } //Lenshelp
        } // TibiaIconButton
      } // cyclopediaComponent

      Component {
        id: preyDialogComponent

        TibiaButton {
          imageSource: "/images/skin/classic/icon-preydialogue.png"
          tooltipText: qsTrId("buttonbar_preydialog_tooltip")

          onClicked: {
            if (panelController != null) {
              panelController.onPreyDialogButtonClicked();
            }
          } //onClicked

          Lenshelp {
            anchors.fill: parent
            anchors.margins: -1
            caption: buttonBarPanel.lenshelpCaption
            content: qsTrId("buttonbar_lenshelp_prey_window")
          } //Lenshelp
        } // TibiaIconButton
      } // preyDialogComponent

      Component {
        id: lenshelpComponent

        TibiaButton {
          imageSource: "/images/skin/classic/icon-lenshelp.png"
          tooltipText: qsTrId("buttonbar_lenshelp_tooltip")

          onClicked: {
            if (panelController != null) {
              panelController.onLenshelpButtonClicked();
            }
          } //onClicked

          Lenshelp {
            anchors.fill: parent
            anchors.margins: -1
            caption: buttonBarPanel.lenshelpCaption
            content: qsTrId("buttonbar_lenshelp_lenshelp")
          } //Lenshelp
        } // TibiaIconButton
      } // lenshelpComponent

      Component {
        id: friendsComponent

        TibiaButton {
          id: friendsButton
          width: TibiaStyle.iconButtonSize
          height: TibiaStyle.iconButtonSize

          sourceUp: "/images/button-social-up.png"
          sourceDown: "/images/button-social-down.png"
          tooltipText: qsTrId("buttonbar_social_open_tooltip")

          onClicked: {
            if (panelController != null && panelController.socialButtonController != null) {
              panelController.socialButtonController.onSocialButtonClicked();
            }
          } //onClicked

          TibiaRectangleHighlight {
            visible: buttonBarPanel.friendsButtonHighlight
          } //TibiaRectangleHighlight

          Lenshelp {
            anchors.fill: parent
            anchors.margins: -1
            caption: buttonBarPanel.lenshelpCaption
            content: qsTrId("buttonbar_lenshelp_social")
          } //Lenshelp
        } // TibiaIconButton
      } // friendsComponent

      Component {
        id: highscoresComponent

        TibiaButton {
          id: highscoresButton
          width: TibiaStyle.iconButtonSize
          height: TibiaStyle.iconButtonSize

          sourceUp: "/images/button-highscores-up.png"
          sourceDown: "/images/button-highscores-down.png"
          tooltipText: qsTrId("buttonbar_highscores_open_tooltip")

          onClicked: {
            if (panelController != null) {
              panelController.onHighscoresDialogButtonClicked();
            }
          } //onClicked

          Lenshelp {
            anchors.fill: parent
            anchors.margins: -1
            caption: buttonBarPanel.lenshelpCaption
            content: qsTrId("buttonbar_lenshelp_highscores")
          } //Lenshelp
        } // TibiaIconButton
      } // highscoresComponent

      Component {
        id: exaltationForgeComponent

        TibiaButton {
          id: exaltationForge
          width: TibiaStyle.iconButtonSize
          height: TibiaStyle.iconButtonSize

          sourceUp: "/images/button-exaltation-forge-up.png"
          sourceDown: "/images/button-exaltation-forge-down.png"
          tooltipText: qsTrId("buttonbar_exaltation_forge_open_tooltip")

          onClicked: {
            if (panelController != null) {
              panelController.onExaltationForgeDialogButtonClicked();
            }
          } //onClicked

          TibiaRectangleHighlight {
            visible: panelController && panelController.highlightExaltationForgeDialogButton
          } //TibiaRectangleHighlight

          Lenshelp {
            anchors.fill: parent
            anchors.margins: -1
            caption: buttonBarPanel.lenshelpCaption
            content: qsTrId("buttonbar_lenshelp_exaltation_forge")
          } //Lenshelp
        } // TibiaIconButton
      } // exaltationForgeComponent

      Component {
        id: bosstiaryComponent

        TibiaButton {
          id: bosstiaryButton
          width: TibiaStyle.iconButtonSize
          height: TibiaStyle.iconButtonSize

          sourceUp: "/images/button-bosstiary-up.png"
          sourceDown: "/images/button-bosstiary-down.png"
          tooltipText: qsTrId("buttonbar_bosstiary_open_tooltip")

          onClicked: {
            if (panelController != null && panelController.bosstiaryButtonController != null) {
              panelController.bosstiaryButtonController.onOpenBosstiaryButtonClicked();
            }
          } //onClicked

          TibiaRectangleHighlight {
            visible: buttonBarPanel.bosstiaryButtonHighlight
          } //TibiaRectangleHighlight

          Lenshelp {
            anchors.fill: parent
            anchors.margins: -1
            caption: buttonBarPanel.lenshelpCaption
            content: qsTrId("buttonbar_lenshelp_bosstiary")
          } //Lenshelp
        } // TibiaIconButton
      } // bosstiaryComponent

      Component {
        id: bossSlotsComponent

        TibiaButton {
          id: bossSlotsButton
          width: TibiaStyle.iconButtonSize
          height: TibiaStyle.iconButtonSize

          sourceUp: "/images/button-bossslots-up.png"
          sourceDown: "/images/button-bossslots-down.png"
          tooltipText: qsTrId("buttonbar_bossslots_open_tooltip")

          onClicked: {
            if (panelController != null) {
              panelController.onBossSlotsDialogButtonClicked();
            }
          } //onClicked

          Lenshelp {
            anchors.fill: parent
            anchors.margins: -1
            caption: buttonBarPanel.lenshelpCaption
            content: qsTrId("buttonbar_lenshelp_bossslots")
          } //Lenshelp
        } // TibiaIconButton
      } // bossSlotsComponent

      Component {
        id: skillWheelComponent

        TibiaButton {
          id: skillWheelButton
          width: TibiaStyle.iconButtonSize
          height: TibiaStyle.iconButtonSize

          imageSource: "/images/skin/classic/icon-skillwheeldialog.png"
          tooltipText: qsTrId("buttonbar_skill_wheel_open_tooltip")

          onClicked: {
            if (panelController != null) {
              panelController.onSkillWheelDialogButtonClicked();
            }
          } //onClicked

          TibiaRectangleHighlight {
            visible: panelController && panelController.highlightSkillWheelButton
          } //TibiaRectangleHighlight

          Lenshelp {
            anchors.fill: parent
            anchors.margins: -1
            caption: buttonBarPanel.lenshelpCaption
            content: qsTrId("buttonbar_lenshelp_skill_wheel")
          } //Lenshelp
        } //TibiaIconButton
      } // skillWheelComponent

      Component {
        id: imbuementTrackerComponent

        TibiaButton {
          id: imbuementTrackerButton
          width: TibiaStyle.iconButtonSize
          height: TibiaStyle.iconButtonSize

          imageSource: "/images/skin/classic/icon-imbuementtracker-button.png"
          tooltipText: qsTrId("buttonbar_imbuementtrackerwidget_open_tooltip")
          tooltipTextChecked: qsTrId("buttonbar_imbuementtrackerwidget_close_tooltip")
          checkable: true
          useButtonShouldBeChecked: true

          buttonShouldBeChecked: panelController == null ? false : panelController.imbuementTrackerVisible

          onClicked: {
            if (panelController != null) {
              panelController.onImbuementTrackerWidgetClicked();
            }
          } //onClicked

          Lenshelp {
            anchors.fill: parent
            anchors.margins: -1
            caption: buttonBarPanel.lenshelpCaption
            content: qsTrId("buttonbar_lenshelp_imbuementtrackerwidget")
          } //Lenshelp
        } //TibiaButton
      } // imbuementTrackerComponent

      Component {
        id: weaponProficiencyComponent

        TibiaButton {
          id: weaponProficiencyButton
          width: TibiaStyle.iconButtonSize
          height: TibiaStyle.iconButtonSize

          imageSource: "/images/icon-proficiencytree-open-button.png"
          tooltipText: qsTrId("buttonbar_weapon_proficiency_open_tooltip")

          onClicked: {
            if (panelController != null) {
              panelController.onWeaponProficiencyDialogButtonClicked();
            }
          } //onClicked

          TibiaRectangleHighlight {
            visible: panelController && panelController.highlightWeaponProficiencyButton
          } //TibiaRectangleHighlight

          Lenshelp {
            anchors.fill: parent
            anchors.margins: -1
            caption: buttonBarPanel.lenshelpCaption
            content: qsTrId("buttonbar_lenshelp_weapon_proficiency")
          } //Lenshelp
        } //TibiaButton
      } // weaponProficiencyComponent

      Component {
        id: manageShortcutsComponent

        TibiaButton {
          id: plusButton
          width: TibiaStyle.iconButtonSize
          height: TibiaStyle.iconButtonSize

          imageSource: "/images/skin/classic/icon-add.png"
          tooltipText: qsTrId("buttonbar_manage_shortcuts_tooltip")

          onClicked: {
            if (panelController != null) {
              panelController.onManageShortcutsClicked();
            }
          } //onClicked

          Lenshelp {
            anchors.fill: parent
            anchors.margins: -1
            caption: buttonBarPanel.lenshelpCaption
            content: qsTrId("buttonbar_lenshelp_manage_shortcuts")
          } //Lenshelp
        } //TibiaIconButton
      } // manageShortcutsComponent

      Component {
        id: playerGuideButtonsComponent

        TibiaButton {
          id: plusButton
          width: TibiaStyle.iconButtonSize
          height: TibiaStyle.iconButtonSize

          imageSource: "/images/skin/classic/icon-playerguidewidget-button.png"
          tooltipText: qsTrId("buttonbar_playerguidewidget_open_tooltip")
          tooltipTextChecked: qsTrId("buttonbar_playerguidewidget_close_tooltip")
          checkable: true
          useButtonShouldBeChecked: true

          buttonShouldBeChecked: panelController == null ? false : panelController.playerGuideWidgetVisible

          onClicked: {
            if (panelController != null) {
              panelController.onPlayerGuideWidgetClicked();
            }
          } //onClicked

          Lenshelp {
            anchors.fill: parent
            anchors.margins: -1
            caption: buttonBarPanel.lenshelpCaption
            content: qsTrId("buttonbar_lenshelp_playerguidewidget")
          } //Lenshelp
        } //TibiaIconButton
      } // playerGuideButtonsComponent

      Component {
        id: taskboardComponent

        TibiaButton {
          id: taskBoardButton
          width: TibiaStyle.iconButtonSize
          height: TibiaStyle.iconButtonSize

          imageSource: "/images/skin/classic/icon-taskboard-button.png"
          tooltipText: qsTrId("buttonbar_taskboard_open_tooltip")

          onClicked: {
            if (panelController != null) {
              panelController.onTaskboardDialogButtonClicked();
            }
          } //onClicked

           TibiaRectangleHighlight {
            visible: panelController && panelController.taskboardButtonHighlight
          } 

          Lenshelp {
            anchors.fill: parent
            anchors.margins: -1
            caption: buttonBarPanel.lenshelpCaption
            content: qsTrId("buttonbar_lenshelp_taskboard")
          } //Lenshelp
        } //TibiaButton
      } // taskboardComponent



      Item {
        id: gridViewWrapper
        Layout.preferredWidth: buttonGrid.columns * buttonGrid.cellWidth
        Layout.preferredHeight: Math.max(buttonGrid.cellHeight, Math.ceil(buttonGrid.count / buttonGrid.columns) * buttonGrid.cellHeight)
        Layout.maximumHeight: Layout.preferredHeight
        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
        Layout.rightMargin: -TibiaStyle.marginNarrow
        Layout.bottomMargin: -TibiaStyle.marginNarrow

        GridView {
          id: buttonGrid
          readonly property int columns: 5

          cellWidth: TibiaStyle.iconButtonSize + TibiaStyle.marginNarrow
          cellHeight: cellWidth
          anchors.fill: parent

          boundsBehavior: Flickable.StopAtBounds
          interactive: false //prevent flick behavior on touch screens
          pixelAligned : true

          model: panelController != null ? panelController.buttonsModel : null

          delegate: Loader {
            width: TibiaStyle.iconButtonSize
            height: TibiaStyle.iconButtonSize

            sourceComponent: {
              if (model.buttonId == ButtonBar.SKILLS_WIDGET) {
                return skillsButtonComponent;
              } else if (model.buttonId == ButtonBar.BATTLE_WIDGET) {
                return battleListComponent;
              } else if (model.buttonId == ButtonBar.PARTY_WIDGET) {
                return partyListComponent;
              } else if (model.buttonId == ButtonBar.VIP_WIDGET) {
                return vipComponent;
              } else if (model.buttonId == ButtonBar.SPELLS_WIDGET) {
                return spellsComponent;
              } else if (model.buttonId == ButtonBar.QUEST_DIALOG) {
                return questlogComponent;
              } else if (model.buttonId == ButtonBar.QUEST_TRACKER_WIDGET) {
                return questTrackerComponent;
              } else if (model.buttonId == ButtonBar.UNJUSTIFIED_WIDGET) {
                return unjustComponent;
              } else if (model.buttonId == ButtonBar.PREY_DIALOG) {
                return preyDialogComponent;
              } else if (model.buttonId == ButtonBar.KILL_TRACKER_WIDGET) {
                return killTrackerComponent;
              } else if (model.buttonId == ButtonBar.DAILY_REWARD_DIALOG) {
                return dailyRewardComponent;
              } else if (model.buttonId == ButtonBar.ANALYTICS_WIDGET) {
                return analyticsComponent;
              } else if (model.buttonId == ButtonBar.COMPENDIUM_DIALOG) {
                return compendiumComponent;
              } else if (model.buttonId == ButtonBar.CYCLOPEDIA_DIALOG) {
                return cyclopediaComponent;
              } else if (model.buttonId == ButtonBar.BESTIARY_TRACKER_WIDGET) {
                return bestiaryTrackerComponent;
              } else if (model.buttonId == ButtonBar.BOSSTIARY_TRACKER_WIDGET) {
                return bosstiaryTrackerComponent;
              } else if (model.buttonId == ButtonBar.SOCIAL_DIALOG) {
                return friendsComponent;
              } else if (model.buttonId == ButtonBar.LENSHELP) {
                return lenshelpComponent;
              } else if (model.buttonId == ButtonBar.HIGHSCORES_DIALOG) {
                return highscoresComponent;
              } else if (model.buttonId == ButtonBar.EXALTATION_FORGE_DIALOG) {
                return exaltationForgeComponent;
              } else if (model.buttonId == ButtonBar.BOSSTIARY_DIALOG) {
                return bosstiaryComponent;
              } else if (model.buttonId == ButtonBar.BOSSSLOTS_DIALOG) {
                return bossSlotsComponent;
              } else if (model.buttonId == ButtonBar.SKILL_WHEEL_DIALOG) {
                return skillWheelComponent;
              } else if (model.buttonId == ButtonBar.IMBUEMENT_TRACKER_WIDGET) {
                return imbuementTrackerComponent;
              } else if (model.buttonId == ButtonBar.WEAPON_PROFICIENCY_WIDGET) {
                return weaponProficiencyComponent;
              } else if (model.buttonId == ButtonBar.MANAGE_SHORTCUTS) {
                return manageShortcutsComponent;
              } else if (model.buttonId == ButtonBar.PLAYER_GUIDE) {
                return playerGuideButtonsComponent;
              } else if (model.buttonId == ButtonBar.TASKBOARD_DIALOG) {
                return taskboardComponent;
              } else {
                return null;
              }
            } // sourceComponent
          } // delegate: Loader
        } // GridView
        MouseArea {
          anchors.fill: parent
          acceptedButtons: Qt.RightButton
          onClicked: () => {
            if (panelController) {
              panelController.onShowContextMenu();
            }
          }
        }
      }


      Item {
        Layout.fillWidth: true
        Layout.preferredHeight: buttonGrid.height - TibiaStyle.marginNarrow
        Layout.maximumHeight: Layout.preferredHeight
        Layout.alignment: Qt.AlignTop

        TibiaVerticalSeparator {
          id: separator
          anchors.top: parent.top
          anchors.bottom: parent.bottom
          anchors.horizontalCenter: parent.horizontalCenter
        } // TibiaVerticalSeparator
      } //Item

      ColumnLayout {
        spacing: TibiaStyle.marginNarrow
        Layout.alignment: Qt.AlignTop

        RowLayout {
          spacing: TibiaStyle.marginNarrow

          TibiaIconButton {
            id: optionsButton
            sourceUp: "/images/button-options-up.png"
            sourceDown: "/images/button-options-down.png"
            tooltipText: qsTrId("buttonbar_options_open_tooltip")

            onClicked: {
              if (panelController != null) {
                panelController.onOptionsButtonClicked();
              }
            } //onClicked

            Lenshelp {
              anchors.fill: parent
              anchors.margins: -1
              caption: buttonBarPanel.lenshelpCaption
              content: qsTrId("buttonbar_lenshelp_options")
            } //Lenshelp
          } // TibiaIconButton

          TibiaIconButton {
            sourceUp: "/images/button-logout-up.png"
            sourceDown: "/images/button-logout-down.png"
            tooltipText: qsTrId("buttonbar_leave_game_tooltip")

            onClicked: {
              if (panelController != null) {
                panelController.onLogoutButtonClicked();
              }
            } //onClicked

            Lenshelp {
              anchors.fill: parent
              anchors.margins: -1
              caption: buttonBarPanel.lenshelpCaption
              content: qsTrId("buttonbar_lenshelp_logout")
            } //Lenshelp
          } // TibiaIconButton
        } //RowLayout
      } //ColumnLayout
    } // RowLayout
  } //ColumnLayout
} // TibiaSidebarPanel
