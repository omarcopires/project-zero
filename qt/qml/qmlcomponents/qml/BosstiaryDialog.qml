import QtQuick
import QtQuick.Layouts
import qmlcomponents



ColumnLayout {
  id: bosstiaryDialog
  property var controller: null

  property var initialFocusItem: bossNameSearch
  KeyNavigation.tab: bossNameSearch
  KeyNavigation.backtab: bossNameSearch

  property var onCancelPressedFunction: null
  property bool canTrackMoreBosses: controller != null && controller.canTrackMoreBosses

  RowLayout {
    Layout.fillWidth: true

    TibiaFrame2PixelUpFilled {
      id: unlockGradeExplanationBox
      Layout.preferredWidth: 164
      Layout.preferredHeight: 68

      GridLayout {
        anchors.fill: parent
        anchors.margins: parent.marginsToContent
        anchors.rightMargin: parent.marginsToContent + TibiaStyle.marginUnrelated
        anchors.leftMargin: parent.marginsToContent + TibiaStyle.marginUnrelated

        columns: 3

        // Prowess
        Image {
          Layout.alignment: Qt.AlignRight
          source: "/images/icon-star-bronze.png"
        }

        TibiaText {
          text: qsTrId("bosstiary_prowess")
        }

        TibiaGuiHelp {
          text:qsTrId("bosstiary_prowess_explanation_tooltip")
        }

        // Expertise
        RowLayout {
          Layout.alignment: Qt.AlignRight
          spacing: TibiaStyle.marginNarrow

          Image {
            source: "/images/icon-star-silver.png"
          }
          Image {
            source: "/images/icon-star-silver.png"
          }
        }

        TibiaText {
          text: qsTrId("bosstiary_expertise")
        }

        TibiaGuiHelp {
          text:qsTrId("bosstiary_expertise_explanation_tooltip")
        }

        // Mastery
        RowLayout {
          Layout.alignment: Qt.AlignRight
          spacing: TibiaStyle.marginNarrow

          Image {
            source: "/images/icon-star-gold.png"
          }
          Image {
            source: "/images/icon-star-gold.png"
          }
          Image {
            source: "/images/icon-star-gold.png"
          }
        }

        TibiaText {
          text: qsTrId("bosstiary_mastery")
        }

        TibiaGuiHelp {
          text:qsTrId("bosstiary_mastery_explanation_tooltip")
        }

      } // GridLayout
    } // TibiaFrame2PixelUpFilled

    TibiaFrame2PixelUpFilledWithCaption {
      caption: qsTrId("bosstiary_filter_header")
      Layout.fillWidth: true
      Layout.preferredHeight: unlockGradeExplanationBox.height

      GridLayout {
        anchors { left: parent.left; leftMargin: parent.marginsToContent
                  right: parent.right; rightMargin: parent.marginsToContent
                  top: parent.top; topMargin: parent.topMarginToContent;
                  bottom: parent.bottom; bottomMargin: parent.marginsToContent }

        columns: 5

        TibiaCheckBox {
          text: qsTrId("bosstiary_bane")
          labelMargin: TibiaStyle.labelMargin + baneIcon.width
          shouldBeChecked: controller != null && controller.showBaneBosses

          onCheckedChanged: {
            if (controller != null) {
              controller.showBaneBosses = checked;
            }
          }

          Image {
            id: baneIcon
            source: "/images/icon-bosstiary-bane.png"
            x: parent.checkboxWidth + TibiaStyle.marginNarrow
            y: 1

            Tooltip {
              anchors.fill: parent
              text: controller != null ? controller.baneTooltip : qsTrId("dummy_unknown")
            }
          }
        }

        TibiaCheckBox {
          text: qsTrId("bosstiary_archfoe")
          labelMargin: TibiaStyle.labelMargin + archfoeIcon.width
          shouldBeChecked: controller != null && controller.showArchfoeBosses

          onCheckedChanged: {
            if (controller != null) {
              controller.showArchfoeBosses = checked;
            }
          }

          Image {
            id: archfoeIcon
            source: "/images/icon-bosstiary-archfoe.png"
            x: parent.checkboxWidth + TibiaStyle.marginNarrow
            y: 1

            Tooltip {
              anchors.fill: parent
              text: controller != null ? controller.archfoeTooltip : qsTrId("dummy_unknown")
            }
          }
        }

        TibiaCheckBox {
          text: qsTrId("bosstiary_nemesis")
          labelMargin: TibiaStyle.labelMargin + nemesisIcon.width
          shouldBeChecked: controller != null && controller.showNemesisBosses

          onCheckedChanged: {
            if (controller != null) {
              controller.showNemesisBosses = checked;
            }
          }

          Image {
            id: nemesisIcon
            source: "/images/icon-bosstiary-nemesis.png"
            x: parent.checkboxWidth + TibiaStyle.marginNarrow
            y: 1

            Tooltip {
              anchors.fill: parent
              text: controller != null ? controller.nemesisTooltip : qsTrId("dummy_unknown")
            }
          }
        }

        Item {
          implicitHeight: 1
          implicitWidth: 1
        }

        Item {
          implicitHeight: 1
          implicitWidth: 1
        }

        TibiaCheckBox {
          text: qsTrId("bosstiary_no_kills")
          shouldBeChecked: controller != null && controller.showNoKillBosses

          onCheckedChanged: {
            if (controller != null) {
              controller.showNoKillBosses = checked;
            }
          }
        }

        TibiaCheckBox {
          text: qsTrId("bosstiary_few_kills")
          shouldBeChecked: controller != null && controller.showFewKillsBosses

          onCheckedChanged: {
            if (controller != null) {
              controller.showFewKillsBosses = checked;
            }
          }
        }

        TibiaCheckBox {
          text: qsTrId("bosstiary_prowess")
          shouldBeChecked: controller != null && controller.showProwessBosses

          onCheckedChanged: {
            if (controller != null) {
              controller.showProwessBosses = checked;
            }
          }
        }

        TibiaCheckBox {
          text: qsTrId("bosstiary_expertise")
          shouldBeChecked: controller != null && controller.showExpertiseBosses

          onCheckedChanged: {
            if (controller != null) {
              controller.showExpertiseBosses = checked;
            }
          }
        }

        TibiaCheckBox {
          text: qsTrId("bosstiary_mastery")
          shouldBeChecked: controller != null && controller.showMasteryBosses

          onCheckedChanged: {
            if (controller != null) {
              controller.showMasteryBosses = checked;
            }
          }
        }
      } // GridLayout
    } // TibiaFrame2PixelUpFilledWithCaption
  } // RowLayout

  TibiaFrame1PixelDown {
    Layout.fillWidth: true
    Layout.fillHeight: true

    GridView {
      id: bossesGrid
      anchors.fill: parent
      anchors.margins: parent.marginsToContent
      anchors.rightMargin: parent.borderWidth
      model: controller != null ? controller.bosses : null

      interactive: false //prevent flick behavior on touch screens
      boundsBehavior: Flickable.StopAtBounds
      pixelAligned: true

      readonly property int bossCellWidth: 159
      readonly property int bossCellHeight: 151

      cellWidth: bossCellWidth + TibiaStyle.marginRelated
      cellHeight: bossCellHeight + TibiaStyle.marginRelated

      delegate: TibiaFrame2PixelUpFilledWithCaption {
        width: bossesGrid.bossCellWidth
        height: bossesGrid.bossCellHeight
        caption: model.kills > 0 ? model.name : qsTrId("bosstiary_unknown_boss_name")

        Image {
          source: model.bossRaritySource
          anchors { left: parent.left; leftMargin: parent.marginsToContent;
                    top: parent.top; topMargin: parent.topMarginToContent }

          Tooltip {
            anchors.fill: parent
            text: model.bossRarityTooltip
          }
        } // Image

        ColumnLayout {
          anchors { left: parent.left; leftMargin: parent.marginsToContent
                    right: parent.right; rightMargin: parent.marginsToContent
                    top: parent.top; topMargin: parent.topMarginToContent;
                    bottom: parent.bottom; bottomMargin: parent.marginsToContent }
          spacing: TibiaStyle.marginNarrow

          RaceAppearanceInstanceRenderer {
            Layout.preferredWidth: 64
            Layout.preferredHeight: 64
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: TibiaStyle.marginUnrelated
            raceID: model.bossRaceId
            isUnknown: model.kills == 0
          }

          Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
          }

          RowLayout {
            Layout.bottomMargin: TibiaStyle.marginNarrow
            Layout.alignment: Qt.AlignHCenter
            spacing: TibiaStyle.marginRelated
            TibiaText {
              text: qsTrId("bosstiary_total_kills")
            } // TibiaText
            Item {
              Layout.fillWidth: true
            } // TibiaText
            TibiaCheckBox {
              enabled: checked || bosstiaryDialog.canTrackMoreBosses
              text: qsTrId("bosstiary_track_boss_checkbox")

              tooltipText: qsTrId("bosstiary_track_boss_tooltip")
              tooltipTextChecked: qsTrId("bosstiary_untrack_boss_tooltip")

              shouldBeChecked: model.tracked ?? false
              visible: model.kills > 0

              onToggled: {
                if (controller != null) {
                  controller.requestToggleBosstiaryTracking(model.bossRaceId, !model.tracked);
                  enabled = true
                  resetCanTrackBossesTimer.checkboxToReset = this
                  resetCanTrackBossesTimer.restart()
                }
              }
            } // TibiaCheckBox

            Timer {
              id: resetCanTrackBossesTimer
              property var checkboxToReset: null
              interval: 100

              onTriggered: {
                if (checkboxToReset != null) {
                  checkboxToReset.enabled = Qt.binding(function() { return checkboxToReset.checked || bosstiaryDialog.canTrackMoreBosses; })
                }
              }
            } // Timer
          }

          BosstiaryUnlockProgress {
            Layout.fillWidth: true
            kills: model.kills
            killsForProwess: model.killsForProwess
            killsForExpertise: model.killsForExpertise
            killsForMastery: model.killsForMastery
            showTotalKillsCaption: false
          } // BosstiaryUnlockProgress
        } // ColumnLayout
      } // delegate: TibiaFrame2PixelUpFilledWithCaption
    } // GridView
  } // TibiaFrame1PixelDown

  Item {
    Layout.fillWidth: true
    Layout.preferredHeight: bossNameSearch.height + TibiaStyle.marginRelated

    RowLayout {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: TibiaStyle.marginUnrelated

      TibiaButton {
        id: leftPageButton
        imageSource: "/images/icon-arrow.png"
        imageSourceDisabled: "/images/icon-arrow-disabled.png"
        Layout.preferredWidth: TibiaStyle.buttonHeightDefault
        enabled: controller != null && controller.currentPage > 1

        onClicked: {
          if (controller != null) {
            controller.requestPreviousPage();
          }
        }
      }

      TibiaText {
        text: qsTrId("count_slash_total")
          .arg(controller != null ? controller.currentPage : 1)
          .arg(controller != null ? controller.numberOfPages : 1);
      } // TibiaText

      TibiaButton {
        id: rightPageButton
        imageSource: "/images/icon-arrow.png"
        imageSourceDisabled: "/images/icon-arrow-disabled.png"
        Layout.preferredWidth: TibiaStyle.buttonHeightDefault
        imageMirrored: true
        enabled: controller != null && controller.currentPage < controller.numberOfPages

        onClicked: {
          if (controller != null) {
            controller.requestNextPage();
          }
        }
      }
    } // RowLayout

    TibiaTextSearchField {
      id: bossNameSearch
      width: 150
      anchors.right: parent.right
      maximumLength: TibiaStyle.maxCharacterNameLength
      KeyNavigation.tab: bossNameSearch
      KeyNavigation.backtab: bossNameSearch
      shouldBeText: controller != null ? controller.searchString : ""

      onSearchTextChanged: {
        if (controller != null) {
          controller.searchString = searchText;
        }
      }
    } // TibiaTextSearchField
  } // Item
} // ColumnLayout
