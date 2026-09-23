import QtQml
import QtQuick
import QtQuick.Layouts

import qmlcomponents



TibiaSidebarWidget {

  id: skillsSidebarWidget

  signal requestContextMenu();
  signal beforeTooltipShow();
  signal openStoreWithXpBoost();
  signal openMoreStatDetails();

  caption: qsTrId("skills_caption")
  picSource: "/images/skin/classic/icon-skills-widget.png"

  initialContentHeight: 200
  maxContentHeight: skillsFlickable.contentHeight

  customButtonContainerData: [
    TibiaButton {
      Layout.preferredWidth: TibiaStyle.widgetControllButtonSize
      Layout.preferredHeight: TibiaStyle.widgetControllButtonSize
      imageSource: "/images/skin/classic/icon-additionalwidget.png"
      color: "verydarkgrey"
      tooltipText: qsTrId("skills_show_more_stat_details_tooltip")
      tooltipMaxWidth: TibiaStyle.tooltipRestrictedWidth
      onClicked:  skillsSidebarWidget.openMoreStatDetails()
    }, //TibiaButton
    TibiaIconButton {
      sourceUp:   "/images/skin/classic/button-contextmenu-12x12-idle.png"
      sourceDown: "/images/skin/classic/button-contextmenu-12x12-pressed.png"
      tooltipText: qsTrId("skills_configure_tooltip")
      onClicked: skillsSidebarWidget.requestContextMenu()
    } //TibiaIconButton
  ]

  TibiaScrollView {
    id: skillsScrollView
    anchors.fill: parent

    Flickable {
      id: skillsFlickable
      boundsBehavior: Flickable.StopAtBounds
      interactive: false //prevent flick behavior on touch screens

      contentHeight: skillsContent.height + skillsContent.y + 5 // Creates 5px padding at the bottom
      contentWidth: skillsContent.width

      Item {
        id: skillsContent
        x: TibiaStyle.marginRelated // Padding to the left
        y: 8 // Padding to the top
        height: skillsLayout.height
          + 5 // Creates 5px padding at the bottom
        width: skillsScrollView.availableWidth - 2 * x // Padding to the right

        ColumnLayout {
          id: skillsLayout
          anchors { left: skillsContent.left; right: skillsContent.right; top: skillsContent.top }

          spacing: 1

          Repeater {
            id: skillDisplayRepeater
            model: widgetController != null ? widgetController.skillsModel : null;

            SkillWidgetEntry {
              Layout.preferredWidth: skillsContent.width

              Component.onCompleted: {
                skillModelData = modelData;
                beforeTooltipFunction = () => skillsSidebarWidget.beforeTooltipShow();
                openStoreXpBoostFunction = () => skillsSidebarWidget.openStoreWithXpBoost();
              }
            }
          } // Repeater

          OffensiveStatsComponent {
            visible: widgetController != null && widgetController.showOffenceStats && widgetController.offenceStats != null
            Layout.fillWidth: true
          }

          DefensiveStatsComponent {
            visible: widgetController != null && widgetController.showDefenceStats && widgetController.defenceStats != null
            Layout.fillWidth: true
          }

          MiscStatsComponent {
            visible: widgetController != null && widgetController.showMiscStats && widgetController.miscStats != null
            Layout.fillWidth: true
          }
        } // ColumnLayout
      } // Item

      component OffensiveStatsComponent : ColumnLayout {
        spacing: skillsLayout.spacing

        TibiaHorizontalSeparator {
          Layout.fillWidth: true
          Layout.topMargin: TibiaStyle.marginRelated
          Layout.bottomMargin: TibiaStyle.marginRelated
        }

        CharacterCombatStatBlock {
          statBlockData: widgetController != null && widgetController.offenceStats != null ? widgetController.offenceStats.flatDamageHealing : null
        }

        CharacterCombatStatBlock {
          statBlockData: widgetController != null && widgetController.offenceStats != null ? widgetController.offenceStats.attackValue : null
        }

        CharacterCombatStatBlock {
          statBlockData: widgetController != null && widgetController.offenceStats != null ? widgetController.offenceStats.specialAttackConversion : null
        }

        CharacterCombatStatBlock {
          statBlockData: widgetController != null && widgetController.offenceStats != null ? widgetController.offenceStats.lifeLeech : null
        }

        CharacterCombatStatBlock {
          statBlockData: widgetController != null && widgetController.offenceStats != null ? widgetController.offenceStats.manaLeech : null
        }

        TibiaText {
          text: qsTrId("critical_hit_caption") + ":"
          tooltipText: qsTrId("charinfo_critical_hit_tooltip")
          visible: widgetController != null && widgetController.offenceStats != null && widgetController.offenceStats.critChance.visible
        }

        CharacterCombatStatBlock {
          statBlockData: widgetController != null && widgetController.offenceStats != null ? widgetController.offenceStats.critChance : null
          Layout.leftMargin: TibiaStyle.marginUnrelated
        }

        CharacterCombatStatBlock {
          statBlockData: widgetController != null && widgetController.offenceStats != null ? widgetController.offenceStats.critExtraDamage : null
          Layout.leftMargin: TibiaStyle.marginUnrelated
        }

        CharacterCombatStatBlock {
          statBlockData: widgetController != null && widgetController.offenceStats != null ? widgetController.offenceStats.onslaught : null
        }
      } // Component

      component DefensiveStatsComponent : ColumnLayout {
        spacing: skillsLayout.spacing
        visible: widgetController != null && widgetController.showDefenceStats && widgetController.defenceStats != null

        TibiaHorizontalSeparator {
          Layout.fillWidth: true
          Layout.topMargin: TibiaStyle.marginRelated
          Layout.bottomMargin: TibiaStyle.marginRelated
        }

        Repeater {
          Layout.fillWidth: true
          model: widgetController != null && widgetController.defenceStats != null ? widgetController.defenceStats.damageReductions : []

          CharacterCombatStatBlock {
            statBlockData: modelData
          }
        } // Repeater

        CharacterCombatStatBlock {
          statBlockData: widgetController != null && widgetController.defenceStats != null ? widgetController.defenceStats.defence : null
        }

        CharacterCombatStatBlock {
          statBlockData: widgetController != null && widgetController.defenceStats != null ? widgetController.defenceStats.armorValue : null
        }

        CharacterCombatStatBlock {
          statBlockData: widgetController != null && widgetController.defenceStats != null ? widgetController.defenceStats.mantraValue : null
        }

        CharacterCombatStatBlock {
          statBlockData: widgetController != null && widgetController.defenceStats != null ? widgetController.defenceStats.mitigation : null
        }

        CharacterCombatStatBlock {
          statBlockData: widgetController != null && widgetController.defenceStats != null ? widgetController.defenceStats.dodge : null
        }

        CharacterCombatStatBlock {
          statBlockData: widgetController != null && widgetController.defenceStats != null ? widgetController.defenceStats.damageReflection : null
        }
      } // Component

      component MiscStatsComponent : ColumnLayout {
        spacing: skillsLayout.spacing
        visible: widgetController != null && widgetController.showMiscStats && widgetController.miscStats != null

        TibiaHorizontalSeparator {
          Layout.fillWidth: true
          Layout.topMargin: TibiaStyle.marginRelated
          Layout.bottomMargin: TibiaStyle.marginRelated
        }

        CharacterCombatStatBlock {
          statBlockData: widgetController != null && widgetController.defenceStats != null ? widgetController.miscStats.momentum : null
        }

        CharacterCombatStatBlock {
          statBlockData: widgetController != null && widgetController.defenceStats != null ? widgetController.miscStats.transcendence : null
        }

        CharacterCombatStatBlock {
          statBlockData: widgetController != null && widgetController.defenceStats != null ? widgetController.miscStats.amplification : null
        }
      } // Component
    } //Flickable
  } // TibiaScrollView

  MouseArea {
    width: skillsScrollView.availableWidth
    anchors.top: skillsScrollView.top
    anchors.bottom: skillsScrollView.bottom

    acceptedButtons: Qt.RightButton
    onClicked: {
      skillsSidebarWidget.requestContextMenu();
    }
  } //MouseArea

  Lenshelp {
    anchors.fill: parent
    triggerRect: mapFromItem(widgetRoot, 0, 0, widgetRoot.width, widgetRoot.height)
    caption: qsTrId("skills_caption")
    content: qsTrId("skills_lensehelp")
  } //Lenshelp
} // TibiaSidebarWidget
