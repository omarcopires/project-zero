import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import qmlcomponents
import qmlenumvalues


Item {
  id: monsterDialog
  property var controller: null
  property var dialogState: controller != null ? controller.dialogState : MonsterDialogController.MonsterClassification
  property bool canTrackMoreMonsters: controller != null && controller.canTrackMoreMonsters

  property var initialFocusItem: monsterNameSearch
  KeyNavigation.tab: monsterNameSearch

  // Cell sizing carefully tuned so that 3x5 cells fit into the available space
  readonly property int gridCellWidth: 132
  readonly property int gridCellHeight: 125

  Component {
    id: sensitivityBox

    RowLayout {
      spacing: TibiaStyle.marginNarrow

      property string element: "Physical"
      property double fillPercentage: 0.0
      property string sensitivity: "?"

      Image {
        source: "/images/monster-icon-" + element.toLowerCase() + "-resist.png"

        Tooltip {
          anchors.fill: parent
          text: element
        }
      } // Image

      Rectangle {
        Layout.preferredHeight: 5
        Layout.preferredWidth: 65
        color: "transparent"
        border.color: "black"
        border.width: 1

        Rectangle {
          x: 1
          y: 1
          width: (parent.width - 2) * fillPercentage
          height: parent.height - 2

          visible: fillPercentage > 0.0
          color: fillPercentage > 0.66666
            ? TibiaStyle.sensitivityWeak
            : fillPercentage <= 0.33333
              ? TibiaStyle.sensitivityImmune
              : fillPercentage < 0.66666
                ? TibiaStyle.sensitivityResist : TibiaStyle.sensitivityNeutral
          border.width: 0
        } // Rectangle

        Rectangle {
          x: 1 + ((parent.width - 2) * 0.33333) // Position at 1/3 of the filling's length
          y: -1
          width: 1
          height: parent.height + 2
          color: "black"
          border.width: 0
        }

        Rectangle {
          x: 1 + ((parent.width - 2) * 0.66666) // Position at 2/3 of the filling's length
          y: -1
          width: 1
          height: parent.height + 2
          color: "black"
          border.width: 0
        }

        Tooltip {
          anchors.fill: parent
          text: sensitivity
        } // Tooltip
      } // Rectangle
    } // RowLayout
  } // Component

  Component {
    id: classificationComponent

    TibiaFrame1PixelDown {
      GridView {
        id: classificationGrid
        interactive: false //prevent flick behavior on touch screens
        boundsBehavior: Flickable.StopAtBounds
        anchors { left: parent.left; leftMargin: TibiaStyle.marginRelated;
                  right: parent.right; rightMargin: TibiaStyle.marginNarrow;
                  top: parent.top; topMargin: TibiaStyle.marginNarrow;
                  bottom: parent.bottom; bottomMargin: TibiaStyle.marginNarrow; }


        cellWidth: monsterDialog.gridCellWidth
        cellHeight: monsterDialog.gridCellHeight

        model: controller != null ? controller.monsterClassificationSummary : null

        delegate: Item {
          property var modelData: classificationGrid.model != null && index < classificationGrid.model.length
                                ? classificationGrid.model[index] : null
          width: classificationGrid.cellWidth - TibiaStyle.marginNarrow
          height: classificationGrid.cellHeight - TibiaStyle.marginNarrow

          TibiaFrame2PixelUpFilledWithCaption {
            id: monsterFrame
            anchors.fill: parent
            anchors.margins: TibiaStyle.marginNarrow
            caption: modelData != null ? modelData.name : qsTrId("dummy_unknown")

            TibiaButton {
              id: classificationIcon
              width: 64
              height: 64
              imageSourceUp: modelData != null ? modelData.imageSource : ""
              anchors { horizontalCenter: parent.horizontalCenter;
                        top: parent.top; topMargin: TibiaStyle.marginNarrow + monsterFrame.captionHeight }

              onClicked: {
                if (controller != null) {
                  controller.requestClassificationSelection(modelData != null ? modelData.name : "");
                }
              }
            } // TibiaButton

            TibiaText {
              text: qsTrId("monsters_classification_count")
                   .arg(modelData != null ? modelData.totalMonsters : 0)
                   .arg(modelData != null ? modelData.knownMonsters : 0)
              anchors { horizontalCenter: parent.horizontalCenter;
                        top: classificationIcon.bottom; topMargin: TibiaStyle.marginRelated }
              horizontalAlignment: Text.AlignHCenter
            } // TibiaText
          } // TibiaFrame2PixelUpFilledWithCaption
        } // delegate Item
      } // GridLayout
    } // TibiaFrame1PixelDown
  } // Component

  Component {
    id: monstersSummaryComponent

    TibiaFrame1PixelDown {
      GridView {
        id: monstersGrid
        interactive: false //prevent flick behavior on touch screens
        boundsBehavior: Flickable.StopAtBounds
        anchors { left: parent.left; leftMargin: TibiaStyle.marginRelated;
                  right: parent.right; rightMargin: TibiaStyle.marginNarrow;
                  top: parent.top; topMargin: TibiaStyle.marginNarrow;
                  bottom: parent.bottom; bottomMargin: TibiaStyle.marginNarrow; }

        cellWidth: monsterDialog.gridCellWidth
        cellHeight: monsterDialog.gridCellHeight

        model: controller != null ? controller.monsterRaceSummary : null

        delegate: Item {
          property var modelData: monstersGrid.model != null && index < monstersGrid.model.length
                                ? monstersGrid.model[index] : null
          width: monstersGrid.cellWidth - TibiaStyle.marginNarrow
          height: monstersGrid.cellHeight - TibiaStyle.marginNarrow

          TibiaFrame2PixelUpFilledWithCaption {
            id: classificationFrame
            anchors.fill: parent
            anchors.margins: TibiaStyle.marginNarrow
            caption: modelData != null ? modelData.name : qsTrId("dummy_unknown")

            TibiaButton {
              id: monsterIconButton
              width: 66
              height: 66
              imageSourceDisabled: modelData != null && !modelData.graphicEffectsSupported
                ? "/images/icon-questionmark.png" : ""
              enabled: modelData != null && !modelData.isUnknown
              anchors { horizontalCenter: parent.horizontalCenter;
                        top: parent.top; topMargin: TibiaStyle.marginNarrow + classificationFrame.captionHeight }

              onClicked: {
                if (controller != null) {
                  controller.onMonsterRaceClicked(modelData.raceID);
                } //onClicked
              } //TibiaButton

              OutfitAppearanceInstanceRenderer {
                id: monsterRaceIcon
                // In case the shader is supported, it takes the place of this renderer
                visible: modelData != null && modelData.hasAppearanceInstance
                         && !modelData.graphicEffectsSupported && !modelData.isUnknown
                anchors.centerIn: parent
                height: TibiaStyle.mapWindowPixelPerField * 2
                width: height

                showNoOutfitImage: false
                moving: true

                outfitId: modelData != null ? modelData.creatureOutfitId : 0
                headColor: modelData != null ? modelData.creatureHeadColor : "black"
                torsoColor: modelData != null ? modelData.creatureTorsoColor : "black"
                legsColor: modelData != null ? modelData.creatureLegsColor : "black"
                detailColor: modelData != null ? modelData.creatureDetailColor : "black"
                firstAddOn: modelData != null ? modelData.creatureFirstAddOn : false
                secondAddOn: modelData != null ? modelData.creatureSecondAddOn : false
              } //OutfitAppearanceInstanceRenderer

              MultiEffect {
                height: monsterRaceIcon.height
                width: monsterRaceIcon.width
                anchors.centerIn: parent
                brightness: modelData != null && modelData.isUnknown ? -1.0 : 0.0
                source: monsterRaceIcon
              } // MultiEffect

              Image {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: 1
                visible: modelData.isAnimusMasteryUnlocked
                source: "/images/indicator_soulcore.png"

                Tooltip {
                  anchors.fill: parent
                  text: modelData.animusMasteryTooltip
                } //Tooltip
              } // Image

              Image {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 1
                visible: modelData.isLeaderKilled
                source: "/images/indicator_charmpoints.png"

                Tooltip {
                  anchors.fill: parent
                  text: modelData.leaderKilledTooltip
                } //Tooltip
              } // Image
            } // TibiaButton

            TibiaText {
              text: modelData != null ? modelData.unlockState : qsTrId("dummy_unknown")
              anchors { horizontalCenter: parent.horizontalCenter;
                        top: monsterIconButton.bottom; topMargin: TibiaStyle.marginRelated }
              horizontalAlignment: Text.AlignHCenter
              visible: !modelData.isFullyUnlocked
            } // TibiaText

            Image {
              anchors { horizontalCenter: parent.horizontalCenter;
                        top: monsterIconButton.bottom; topMargin: TibiaStyle.marginRelated }
              visible: modelData.isFullyUnlocked
              source: "/images/icon-yes.png"

              Tooltip {
                anchors.fill: parent
                text: qsTrId("monsters_unlocked_tooltip")
              }
            } //Image

            RowLayout {
              anchors { horizontalCenter: parent.horizontalCenter;
                        bottom: parent.bottom; bottomMargin: classificationFrame.borderWidth + TibiaStyle.marginNarrow }

              spacing: TibiaStyle.marginRelated

              visible: modelData.isVeryRare

              Image {
                visible: modelData.isVeryRare
                source: "/images/monster-icon-diamond-active.png"

                Tooltip {
                  anchors.fill: parent
                  text: modelData.monsterRarityString
                } //Tooltip
              } // Image
            } //RowLayout
          } // TibiaFrame2PixelUpFilledWithCaption
        } // delegate Item
      } // GridLayout
    } // TibiaFrame1PixelDown
  } // Component

  Component {
    id: singleMonsterComponent

    TibiaFrame2PixelUpFilledWithCaption {
      id: detailFrame
      property var modelData: dialogState == MonsterDialogController.SingleMonster ? controller.singleMonster : null
      caption: modelData != null ? modelData.name : qsTrId("dummy_unknown")

      Image {
        anchors.top: parent.top
        anchors.topMargin: parent.captionHeight
        anchors.left: parent.left
        anchors.leftMargin: parent.borderWidth
        visible: modelData != null && modelData.isAnimusMasteryUnlocked
        source: "/images/indicator_soulcore.png"

        Tooltip {
          anchors.fill: parent
          text: modelData != null ? modelData.animusMasteryTooltip : ""
        } //Tooltip
      } // Image

      Image {
        anchors.top: parent.top
        anchors.topMargin: parent.captionHeight
        anchors.right: monsterSprite.right
        anchors.leftMargin: parent.borderWidth
        visible: modelData != null && modelData.isLeaderKilled
        source: "/images/indicator_charmpoints.png"

        Tooltip {
          anchors.fill: parent
          text: modelData != null ? modelData.leaderKilledTooltip : ""
        } //Tooltip
      } // Image

      OutfitAppearanceInstanceRenderer {
        id: monsterSprite
        visible: modelData != null && modelData.hasAppearanceInstance
        anchors { left: parent.left; leftMargin: TibiaStyle.marginRelated;
                  top: parent.top; topMargin: TibiaStyle.marginRelated + detailFrame.captionHeight }
        height: TibiaStyle.preyMonsterImageSize
        width: height
        scaleFactor: TibiaStyle.preyMonsterScaleFactor
        smoothTextureFiltering: controller != null && controller.clientSettingSmoothFiltering
        showNoOutfitImage: false
        moving: true

        outfitId: modelData != null ? modelData.creatureOutfitId : 0
        headColor: modelData != null ? modelData.creatureHeadColor : "black"
        torsoColor: modelData != null ? modelData.creatureTorsoColor : "black"
        legsColor: modelData != null ? modelData.creatureLegsColor : "black"
        detailColor: modelData != null ? modelData.creatureDetailColor : "black"
        firstAddOn: modelData != null ? modelData.creatureFirstAddOn : false
        secondAddOn: modelData != null ? modelData.creatureSecondAddOn : false
      } //OutfitAppearanceInstanceRenderer

      TibiaCheckBox {
        id: trackMonsterCheckbox
        anchors { horizontalCenter: monsterSprite.horizontalCenter;
                  bottom: lootFrame.top; bottomMargin: TibiaStyle.marginUnrelated; }
        visible: modelData != null
        enabled: checked || monsterDialog.canTrackMoreMonsters

        text: qsTrId("monsters_track_monster")
        tooltipText: qsTrId("monsters_track_monster_tooltip")
        tooltipTextChecked: qsTrId("monsters_untrack_monster_tooltip")

        shouldBeChecked: controller != null && controller.isMonsterTracked

        onToggled: {
          if (controller != null) {
            controller.requestToggleBestiaryTracking()
            // Assume for a very short while that more monsters can be tracked, so that en enabled state of the checkbox doesn't go ping-pong
            monsterDialog.canTrackMoreMonsters = true
            recheckTrackingEnabledTimer.restart()
          }
        }
      } // TibiaCheckBox

      Timer {
        id: recheckTrackingEnabledTimer

        onTriggered: {
          monsterDialog.canTrackMoreMonsters = Qt.binding(function() { return controller != null && controller.canTrackMoreMonsters })
        }
      }

      TibiaGuiHelp {
        anchors { right: monsterSprite.right; bottom: lootFrame.top; bottomMargin: TibiaStyle.marginUnrelated; }
        text: qsTrId("monsters_maximum_tracked_monster")
        visible: !trackMonsterCheckbox.enabled
        color: "orange"
      } // TibiaGuiHelp

      ColumnLayout {
        id: middleColumn
        anchors { left: monsterSprite.right; leftMargin: TibiaStyle.marginUnrelated;
                  top: monsterSprite.top; bottom: lootFrame.top; bottomMargin: TibiaStyle.marginUnrelated }
        width: 190
        spacing: TibiaStyle.marginNarrow

        TibiaText {
          Layout.fillWidth: true
          text: qsTrId("monsters_total_kills")
          horizontalAlignment: Text.AlignHCenter
        } //TibiaText

        CreatureUnlockProgress {
          Layout.preferredHeight: TibiaStyle.progressBarLargeHeight

          currentKills: modelData != null ? modelData.totalKills : 0
          killsToUnlockDetails1: modelData != null ? modelData.details1Kills : 0
          killsToUnlockDetails2: modelData != null ? modelData.details2Kills : 0
          killsToFullUnlock: modelData != null ? modelData.details3Kills : 0
          isFullyUnlocked: modelData != null && modelData.isFullyUnlocked
        }

        RowLayout {
          Layout.fillHeight: false
          spacing: TibiaStyle.marginNarrow

          ColumnLayout {
            Layout.preferredWidth: 110
            Layout.alignment: Qt.AlignTop
            spacing: TibiaStyle.marginNarrow

            RowLayout {
              Layout.preferredHeight: textHeightReference.height
              spacing: TibiaStyle.marginNarrow

              Repeater {
                model: 5
                Image {
                  source: detailFrame.modelData != null && detailFrame.modelData.monsterDifficulty > index
                    ? "/images/icon-star-active.png" : "/images/icon-star-inactive.png"

                  Tooltip {
                    anchors.fill: parent
                    text: detailFrame.modelData != null
                      ? detailFrame.modelData.monsterDifficultyString : qsTrId("dummy_unknown")
                  } // Tooltip
                } // Image
              } // Repeater
            } // RowLayout

            RowLayout {
              Layout.preferredHeight: textHeightReference.height
              spacing: TibiaStyle.marginNarrow

              Repeater {
                model: 4
                Image {
                  source: detailFrame.modelData != null && detailFrame.modelData.monsterRarity >= index
                    ? "/images/monster-icon-diamond-active.png" : "/images/monster-icon-diamond-inactive.png"

                  Tooltip {
                    anchors.fill: parent
                    text: detailFrame.modelData != null
                      ? detailFrame.modelData.monsterRarityString : qsTrId("dummy_unknown")
                  } // Tooltip
                } // Image
              } // Repeater
            } // RowLayout

            RowLayout {
              Layout.preferredHeight: textHeightReference.height
              spacing: TibiaStyle.marginNarrow

              Image {
                id: meleeIcon
                source: "/images/monster-icon-melee.png"
                visible: modelData != null && modelData.isMeleeAttacker

                Tooltip {
                  anchors.fill: parent
                  text: qsTrId("monsters_melee_fighter")
                }
              } // Image

              Image {
                id: rangedIcon
                source: "/images/monster-icon-ranged.png"
                visible: modelData != null && modelData.isRangedAttacker

                Tooltip {
                  anchors.fill: parent
                  text: qsTrId("monsters_ranged_fighter")
                }
              } // Image

              Image {
                id: noAttackIcon
                source: "/images/monster-icon-noattack.png"
                visible: modelData != null && modelData.doesNotAttack

                Tooltip {
                  anchors.fill: parent
                  text: qsTrId("monsters_does_not_attack")
                }
              } // Image

              Image {
                id: casterIcon
                source: "/images/monster-icon-spellcaster.png"
                visible: modelData != null && modelData.isSpellcaster

                Tooltip {
                  anchors.fill: parent
                  text: qsTrId("monsters_spellcaster")
                }
              } // Image

              TibiaText {
                visible: modelData != null && !modelData.hasDetails1
                text: qsTrId("monsters_unknown_data")

                Tooltip {
                  anchors.fill: parent
                  text: qsTrId("monsters_unknown_range")
                }
              } // TibiaText
            } // RowLayout

            RowLayout {
              Layout.preferredHeight: textHeightReference.height
              spacing: TibiaStyle.marginRelated

              Image {
                source: "/images/monster-icon-bonuspoints.png"

                Tooltip {
                  anchors.fill: parent
                  text: qsTrId("monsters_bonus_points_on_unlock")
                }
              } // Image

              TibiaText {
                text: modelData != null ? modelData.bonusPointsOnUnlockString : qsTrId("dummy_unknown")
              }
            } // RowLayout
          } // ColumnLayout

          TibiaVerticalSeparator {
            Layout.preferredHeight: rightSideGrid.height
          }

          GridLayout {
            id: rightSideGrid
            Layout.preferredWidth: 70
            columns: 2
            rowSpacing: TibiaStyle.marginNarrow
            columnSpacing: TibiaStyle.marginRelated

            Image {
              source: "/images/monster-icon-hitpoints.png"

              Tooltip {
                anchors.fill: parent
                text: qsTrId("monsters_hitpoints")
              }
            } // Image

            TibiaText {
              id: textHeightReference
              text: modelData != null ? modelData.hitpointsString : qsTrId("dummy_unknown")
            } // TibiaText

            Image {
              source: "/images/monster-icon-experience.png"

              Tooltip {
                anchors.fill: parent
                text: qsTrId("monsters_experience")
              }
            } // Image

            TibiaText {
              text: modelData != null ? modelData.experienceString : qsTrId("dummy_unknown")
              Layout.fillWidth: true
            }

            Image {
              source: "/images/monster-icon-speed.png"

              Tooltip {
                anchors.fill: parent
                text: qsTrId("monsters_speed")
              }
            } // Image

            TibiaText {
              text: modelData != null ? modelData.speedString : qsTrId("dummy_unknown")
              Layout.fillWidth: true
            }

            Image {
              source: "/images/monster-icon-armor.png"

              Tooltip {
                anchors.fill: parent
                text: qsTrId("monsters_armor")
              }
            } // Image

            TibiaText {
              text: modelData != null ? modelData.armorString : qsTrId("dummy_unknown")
              Layout.fillWidth: true
            }

            Image {
              source: "/images/monster-icon-mitigation.png"

              Tooltip {
                anchors.fill: parent
                text: qsTrId("charinfo_mitigation_percent")
              }
            } // Image

            TibiaText {
              text: modelData != null ? modelData.mitigationString : qsTrId("dummy_unknown")
              Layout.fillWidth: true
            } //TibiaText
          } // GridLayout
        } // RowLayout

        RowLayout {
          id: charmRowLayout
          spacing: TibiaStyle.marginNarrow
          readonly property int charmSlotWidth: 46 + 2 // 2 for highlight border on both sides
          readonly property int charmSlotHeight: charmSlotWidth

          component CharmWithBorder: Item {
            id: charmImageComponent
            property var charmName: null
            property var charmDescription: null
            property var charmImage: null
            property var unlockGrade: TibiaEnums.NOTUNLOCKED

            Image {
              source: "/images/backdrop-dark-grey.png"
              width: 44
              height: 44
              anchors.centerIn: parent
            }

            Image {
              source: switch (unlockGrade) {
                case TibiaEnums.GRADE1: "/images/backdrop_charmgrade1.png"; break;
                case TibiaEnums.GRADE2: "/images/backdrop_charmgrade2.png"; break;
                case TibiaEnums.GRADE3: "/images/backdrop_charmgrade3.png"; break;
                default: ""; break;
              }
              visible: unlockGrade != TibiaEnums.NOTUNLOCKED
              //anchors.centerIn: parent
            }

            Image {
              id: bonusEffectImage
              anchors.centerIn: parent
              source: charmImageComponent.charmImage != null ? charmImageComponent.charmImage : ""
            } // Image
          } // component CharmWithBorder

          Component {
            id: charmWithBorder
            Image {
              property var charmData: null
              property int slotID: 0

              source: detailFrame.modelData != null && detailFrame.modelData.selectedCharmSlot == slotID ? "/images/border_charmgrades.png" : ""

              CharmWithBorder {
                anchors.fill: parent
                anchors.margins: 1

                charmName: charmData.name
                charmDescription: charmData.description
                unlockGrade: charmData.unlockGrade
                charmImage: charmData.icon

                Tooltip {
                  anchors.fill: parent
                  text: qsTrId("monsters_bonus_effect_icon_tooltip").arg(charmData.name).arg(charmData.description)
                  maxWidth: TibiaStyle.tooltipRestrictedWidth

                  onHoverEnter: {
                    if (tibiaMouseCursorController != null) {
                      tibiaMouseCursorController.setPointingHand(true)
                    }
                  } //onHoverEnter

                  onHoverLeave: {
                    if (tibiaMouseCursorController != null) {
                      tibiaMouseCursorController.setDefaultCursor()
                    }
                  } //onHoverLeave
                } // Tooltip

                MouseArea {
                  anchors.fill: parent
                  acceptedButtons: Qt.LeftButton | Qt.RightButton

                  onClicked: (mouse) => {
                    if (mouse.button == Qt.LeftButton) {
                      if (detailFrame.modelData.selectedCharmSlot != slotID) {
                        detailFrame.modelData.selectedCharmSlot = slotID;
                        detailFrame.modelData.selectedCharmID = charmData.charmID;
                      } else {
                        detailFrame.modelData.selectedCharmSlot = -1
                        detailFrame.modelData.selectedCharmID = -1
                      }
                    } else {
                      controller.viewSelectedCharm(charmData.charmID); // on right click
                    }
                  } //onClicked
                } //MouseArea
              } // CharmWithBorder
            } // Image
          } // Component (charmWithBorder)

          Component {
            id: emptySlot
            Rectangle {
              property var slotID: 0

              border.width: 1
              border.color: detailFrame.modelData != null && detailFrame.modelData.selectedCharmSlot == slotID ? "white" : "transparent"
              color: "transparent"

              Image {
                source: "/images/containerslot.png"
                anchors.fill: parent
                anchors.margins: 1
              }

              Tooltip {
                anchors.fill: parent
                text: slotID == 1 ? qsTrId("monsters_charm_slot_major") : qsTrId("monsters_charm_slot_minor")
                onHoverEnter: {
                  if (tibiaMouseCursorController != null) {
                    tibiaMouseCursorController.setPointingHand(true)
                  }
                } //onHoverEnter

                onHoverLeave: {
                  if (tibiaMouseCursorController != null) {
                    tibiaMouseCursorController.setDefaultCursor()
                  }
                } //onHoverLeave
              } // Tooltip

              MouseArea {
                anchors.fill: parent

                onClicked: {
                  if (detailFrame.modelData.selectedCharmSlot != slotID) {
                    detailFrame.modelData.selectedCharmSlot = slotID
                  } else {
                    detailFrame.modelData.selectedCharmSlot = -1
                  }
                  detailFrame.modelData.selectedCharmID = -1
                }
              } // MouseArea
            } // Image
          } // Component (emptySlot)

          Loader {
            id: majorCharm
            Layout.preferredWidth: charmRowLayout.charmSlotWidth
            Layout.preferredHeight: charmRowLayout.charmSlotHeight

            sourceComponent: detailFrame.modelData.majorCharm != null ? charmWithBorder : emptySlot

            onLoaded: {
              if (detailFrame.modelData.majorCharm != null) {
                item.charmData = Qt.binding(function() { return detailFrame.modelData.majorCharm; });
              }
              item.slotID = 1;
            } //onLoaded
          } // Loader

          Loader {
            id: minorCharm
            Layout.preferredWidth: charmRowLayout.charmSlotWidth
            Layout.preferredHeight: charmRowLayout.charmSlotHeight

            sourceComponent: detailFrame.modelData.minorCharm != null ? charmWithBorder : emptySlot
            onLoaded: {
              if (detailFrame.modelData.minorCharm != null) {
                item.charmData = Qt.binding(function() { return detailFrame.modelData.minorCharm; });
              }
              item.slotID = 2;
            } //onLoaded
          } // Loader

          ColumnLayout {
            spacing: TibiaStyle.marginRelated + 1
            Layout.preferredHeight: assignRemoveButton.height + currencyViewGold.height + TibiaStyle.marginNarrow

            Item {
              Layout.preferredWidth: 90
              Layout.preferredHeight: assignRemoveButton.implicitHeight

              TibiaButton {
                id: assignRemoveButton
                readonly property bool isClearCharmMode: modelData && modelData.selectedCharmID != -1

                text: isClearCharmMode ? qsTrId("monster_bonus_effects_clear_charm_button") : qsTrId("monster_bonus_effects_assign_charm_button")
                enabled: charmSelectionBox.count > 0 && (
                           (isClearCharmMode && modelData.canAffordCurrentlySelectedEffectUnassignment) ||
                           (!isClearCharmMode && charmSelectionBox.currentValue != -1)
                         )
                anchors.fill: parent

                onClicked: {
                  if (modelData) {
                    if (isClearCharmMode) {
                      controller.removeSelectedCharm();
                    } else {
                      controller.assignSelectedCharm(charmSelectionBox.currentValue);
                    }
                  }
                }
              } // TibiaButton

              Tooltip {
                anchors.fill: parent
                text: assignRemoveButton.isClearCharmMode && !modelData.canAffordCurrentlySelectedEffectUnassignment
                  ? qsTrId("monster_bonus_effects_clear_charm_button_not_enough_money_tooltip")
                  : ""
              } // Tooltip
            } // Item

            // currency view
            TibiaCurrencyView {
              id: currencyViewGold
              Layout.preferredWidth: assignRemoveButton.width
              visible:  assignRemoveButton.isClearCharmMode
              balance: modelData != null? modelData.unassignCostString : "0"
              tooLowBalance: modelData && !modelData.canAffordCurrentlySelectedEffectUnassignment
              iconId: "GoldCoin"
            } //TibiaCurrencyView
          } // ColumnyLayout
        } // RowLayout

        TibiaComboBox {
          id: charmSelectionBox
          Layout.preferredWidth: 190
          model: modelData != null ? modelData.charmsInCombobox : null
          enabled: count > 0 && modelData != null && modelData.selectedCharmID == -1 &&
            (modelData.selectedCharmSlot == 1 || modelData.selectedCharmSlot == 2)
          shouldBeCurrentIndex: modelData != null ? modelData.indexOfSelectedCharmInCombobox : 0

          textRole: "name"
          valueRole: "id"

          onActivated: (index) => {
            if (controller && modelData) {
              modelData.indexOfSelectedCharmInCombobox = index;
            }
          }
        } // TibiaComboBox
      } // ColumnLayout

      ColumnLayout {
        id: rightColumn
        spacing: 0

        anchors { left: middleColumn.right; leftMargin: TibiaStyle.marginUnrelated;
                  right: parent.right; rightMargin: TibiaStyle.marginRelated;
                  top: monsterSprite.top; topMargin: TibiaStyle.marginRelated;
                  bottom: lootFrame.top; bottomMargin: TibiaStyle.marginUnrelated }

        GridLayout {
          Layout.fillWidth: true
          Layout.preferredHeight: 36
          columns: 4

          Repeater {
            model: modelData != null ? modelData.monsterSensitivities : null

            Loader {
              sourceComponent: sensitivityBox

              onLoaded: {
                item.element = Qt.binding(function() { return modelData.elementName; });
                item.fillPercentage = Qt.binding(function() { return modelData.fillPercentage; });
                item.sensitivity = Qt.binding(function() { return modelData.readableSensitivity; });
              }
            }
          }
        } // GridLayout

        TibiaText {
          text: qsTrId("monsters_locations")
          Layout.topMargin: TibiaStyle.marginUnrelated
        }

        TibiaTextArea {
          Layout.topMargin: TibiaStyle.marginRelated
          Layout.fillWidth: true
          Layout.fillHeight: true
          text: modelData != null ? modelData.monsterLocations : qsTrId("dummy_unknown")
          readOnly: true
        }
      } // ColumnLayout

      TibiaFrame1PixelDown {
        id: lootFrame
        anchors { left: parent.left; leftMargin: TibiaStyle.marginRelated;
                  right: parent.right; rightMargin: TibiaStyle.marginRelated;
                  bottom: parent.bottom; bottomMargin: TibiaStyle.marginRelated; }
        height: 178

        TibiaScrollView {
          anchors.fill: parent
          anchors { leftMargin: TibiaStyle.marginRelated; rightMargin: 1; topMargin: 1; bottomMargin: 1}

          ListView {
            boundsBehavior: Flickable.StopAtBounds
            interactive: false //prevent flick behavior on touch screens
            rebound: Transition {}

            model: modelData != null ? modelData.monsterLoot : null

            delegate: RowLayout {
              // "modelData" now refers to the loot of each rarity
              readonly property int itemSize: TibiaStyle.containerSlotSize
              height: modelData.lootRows * itemSize + TibiaStyle.marginUnrelated
              spacing: 0

              TibiaText {
                id: rarityText
                text: modelData.rarityString
                Layout.preferredWidth: 100

                Tooltip {
                  anchors.fill: parent
                  text: modelData.rarityTooltip
                }
              }

              GridLayout {
                id: lootGrid
                columnSpacing: TibiaStyle.marginNarrow
                rowSpacing: TibiaStyle.marginNarrow
                columns: modelData.lootColumns
                Layout.fillWidth: true

                Repeater {
                  model: modelData.lootItems

                  BorderImage {
                    // "modelData" now refers to a single loot item
                    source: modelData.isEmpty
                      ? "/images/skin/classic/button-grey-up.png"
                      : "/images/skin/classic/button-grey-down.png"
                    border { left: 1; top: 1; right: 1; bottom: 1 }
                    Layout.preferredWidth: itemSize
                    Layout.preferredHeight: Layout.preferredWidth


                    Item {
                      anchors.fill: parent
                      anchors.margins: 1

                      Image {
                        source: !modelData.isEmpty && modelData.isSecretOrUnknown
                          ? "/images/icon-questionmark.png" : ""
                        anchors.centerIn: parent
                      } // Image

                      BorderImage {
                        source: !modelData.isEmpty && modelData.isSecretOrUnknown && modelData.isSpecialEventOnly
                          ? "/images/ditherpattern.png" : ""
                        anchors.fill: parent
                        horizontalTileMode: BorderImage.Repeat
                        verticalTileMode: BorderImage.Repeat
                      }

                      Tooltip {
                        anchors.fill: parent
                        text: !modelData.isEmpty && modelData.isSecretOrUnknown
                          ? (modelData.isSpecialEventOnly
                            ? qsTrId("monsters_item_secret_event_tooltip")
                            : qsTrId("monsters_item_secret_tooltip"))
                          : ""
                      } // Tooltip
                    } // Item

                    ContainerSlot {
                      id: itemSprite
                      visible: !modelData.isEmpty && !modelData.isSecretOrUnknown
                      anchors.fill: parent
                      anchors.margins: 1
                      objectAppearanceInstanceTypeId: modelData.appearanceTypeID
                      objectAppearanceInstanceCumulativeCount: 1
                      objectAppearanceInstanceLiquidType: modelData.liquidType
                      objectAppearanceInstanceHookDirection: modelData.hookDirection

                      slotBackgroundVisible: false
                      slotText: modelData.dropCountString
                      slotTooltip: modelData.isSpecialEventOnly ? qsTrId("monsters_item_special_event").arg(modelData.name)
                                                                : modelData.name
                      lootvalueImageSourceUnderItem: modelData.lootvalueImageSourceUnderItem
                      lootvalueImageSourceOverItem: modelData.lootvalueImageSourceOverItem

                      BorderImage {
                        source: itemSprite.visible && modelData.isSpecialEventOnly ? "/images/ditherpattern.png"
                                                                                   : ""
                        anchors.fill: parent
                        horizontalTileMode: BorderImage.Repeat
                        verticalTileMode: BorderImage.Repeat
                      } //BorderImage

                      MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onClicked: (mouse) => {
                          if (controller != null) {
                            if (mouse.button == Qt.LeftButton) {
                              controller.requestSwitchToItemInfo(modelData.appearanceTypeID);
                            } else if (mouse.button == Qt.RightButton) {
                              controller.requestContextMenuForItem(modelData.appearanceTypeID);
                            }
                          }
                        }
                      } // MouseArea
                    } // ContainerSlot
                  } // BorderImage
                } // Repeater
              } // GridLayout
            } // Item
          } // ListView
        } // TibiaScrollView
      } // TibiaFrame1PixelDown
    } // TibiaFrame2PixelUpFilledWithCaption
  } // Component

  Loader {
    anchors { top: parent.top; left: parent.left; right: parent.right;
              bottom: paginationButtons.top; bottomMargin: TibiaStyle.marginRelated }

    sourceComponent: dialogState == MonsterDialogController.MonsterClassification
      ? classificationComponent
      : dialogState == MonsterDialogController.MonsterRaces
        ? monstersSummaryComponent
        : singleMonsterComponent
  } // Loader

  RowLayout {
    id: paginationButtons
    anchors { horizontalCenter: parent.horizontalCenter;
              bottom: parent.bottom; bottomMargin: TibiaStyle.marginRelated }
    spacing: TibiaStyle.marginUnrelated

    property bool canGoBack: dialogState != MonsterDialogController.MonsterClassification
    property var goBackFunction: function() {
      if (controller != null) {
        if (dialogState == MonsterDialogController.MonsterRaces) {
          controller.requestSwitchBackToClassificationSummary();
        } else {
          controller.requestSwitchBackToRaceSummary();
        }
      }
    }
    property int currentPage: controller != null && dialogState == MonsterDialogController.MonsterClassification
      ? controller.monsterClassificationCurrentPage
      : controller != null && dialogState == MonsterDialogController.MonsterRaces
        ? controller.monsterRacesCurrentPage
        : 1;
    property int totalPages: controller != null && dialogState == MonsterDialogController.MonsterClassification
      ? controller.monsterClassificationTotalPages
      : controller != null && dialogState == MonsterDialogController.MonsterRaces
        ? controller.monsterRacesTotalPages
        : 1;
    property var switchPageFunction: function(page) {
      if (controller != null) {
        if (dialogState == MonsterDialogController.MonsterClassification) {
          controller.requestClassificationPageSwitch(page);
        } else if (dialogState == MonsterDialogController.MonsterRaces) {
          controller.requestMonsterPageSwitch(page);
        }
      }
    }

    TibiaIconButton {
      id: backButton
      enabled: paginationButtons.canGoBack
      sourceDown: "/images/skin/classic/button-back-down.png"
      sourceUp: enabled ? "/images/skin/classic/button-back-up.png" : "/images/skin/classic/button-back-inactive.png"

      onClicked: {
        if (controller != null) {
          paginationButtons.goBackFunction();
        }
      }
    } // TibiaIconButton

    TibiaButton {
      id: leftPageButton
      imageSource: "/images/icon-arrow.png"
      imageSourceDisabled: "/images/icon-arrow-disabled.png"
      Layout.preferredWidth: TibiaStyle.buttonHeightDefault
      enabled: paginationButtons.currentPage > 1

      onClicked: {
        paginationButtons.switchPageFunction(paginationButtons.currentPage - 1);
      }
    } // TibiaButton

    TibiaText {
      text: qsTrId("count_slash_total")
        .arg(paginationButtons.currentPage)
        .arg(paginationButtons.totalPages);
    } // TibiaText

    TibiaButton {
      id: rightPageButton
      imageSource: "/images/icon-arrow.png"
      imageSourceDisabled: "/images/icon-arrow-disabled.png"
      Layout.preferredWidth: TibiaStyle.buttonHeightDefault
      imageMirrored: true
      enabled: paginationButtons.currentPage < paginationButtons.totalPages

      onClicked: {
        paginationButtons.switchPageFunction(paginationButtons.currentPage + 1);
      }
    } // TibiaButton
  } // RowLayout

  RowLayout {
    anchors { right: parent.right; bottom: parent.bottom; bottomMargin: TibiaStyle.marginRelated }

    TibiaTextField {
      id: monsterNameSearch
      Layout.preferredWidth: 150
      maximumLength: TibiaStyle.maxCharacterNameLength
      KeyNavigation.tab: monsterNameSearch
      placeholderText: qsTrId("type_to_search_placeholder")

      onAccepted: {
        if (searchButton.enabled) {
          searchButton.clicked();
        }
      } //onAccepted
    } // TibiaTextField

    TibiaButton {
      id: searchButton
      text: qsTrId("search")
      enabled: monsterNameSearch.text.length > 0

      onClicked: {
        if (controller != null) {
          controller.requestMonsterSearch(monsterNameSearch.text);
          monsterNameSearch.text = "";
        }
      }
    }
  } // RowLayout
} // Item
