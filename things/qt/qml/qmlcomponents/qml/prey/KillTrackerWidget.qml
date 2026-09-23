import QtQuick
import QtQuick.Layouts

import qmlcomponents
import qmlenumvalues

import "qrc:/qt/qml/qmlcomponents/qml"

TibiaSidebarWidget {
  caption: qsTrId("kill_tracker_widget_caption")
  picSource: "/images/skin/classic/icon-killtracker-widget.png"

  minContentHeight: 52 // approx 1.5 prey crature entries
  maxContentHeight: wrapperColumnLayout.height + TibiaStyle.marginUnrelated

  property var preyListModel: widgetController != null ? widgetController.preyList : null
  property var cleanedPreyListModel: {
    var newModel = [];
      if (preyListModel != null) {
      for (var i = 0; i < preyListModel.length; i++) {
        var isLocked = preyListModel[i].isLocked;
        if (isLocked == false) {
          newModel.push(preyListModel[i]);
        }
      }
    }
    return newModel;
  }

  TibiaScrollView {
    id: scrollView
    anchors.fill: parent
    anchors.leftMargin: TibiaStyle.marginNarrow
    anchors.topMargin: TibiaStyle.marginNarrow

    ColumnLayout {
      id: wrapperColumnLayout
      width: scrollView.width - TibiaStyle.scrollBarWidth - TibiaStyle.marginRelated

      spacing: TibiaStyle.marginNarrow
      ColumnLayout {
        id: preyCreaturesCaptionWrapper
        Layout.fillWidth: true
        spacing: TibiaStyle.marginNarrow
        TibiaText {
          text: qsTrId('kill_tracker_prey_caption');
        } //TibiaText
        TibiaHorizontalSeparator {
        }
      } //ColumnLayout

      ListView {
        id: preyList
        Layout.fillWidth: true
        Layout.minimumHeight: (model != null ? model.length : 0) * 22

        boundsBehavior: Flickable.StopAtBounds
        interactive: false //prevent flick behavior on touch screens
        rebound: Transition {}

        model: cleanedPreyListModel

        delegate: Item {
          id: preyDelegate
          width: preyList.width - 2
          height: visible ? 22 : 0
          visible: modelData != null && !modelData.isLocked

          RowLayout {
            anchors.fill: parent
            spacing: TibiaStyle.marginNarrow

            Item {
              Layout.fillHeight: true
              Layout.preferredWidth: height

              OutfitAppearanceInstanceRenderer {
                id: preyMonsterDisplay
                height: TibiaStyle.battleListMonsterSize
                width: TibiaStyle.battleListMonsterSize
                anchors.centerIn: parent

                visible: modelData != null && modelData.isActive
                shrinkToFit: true
                showNoOutfitImage: false

                outfitId: modelData != null ? modelData.monsterOutfitId : 0
                headColor: modelData != null ? modelData.monsterHeadColor : "black"
                torsoColor: modelData != null ? modelData.monsterTorsoColor : "black"
                legsColor: modelData != null ? modelData.monsterLegsColor : "black"
                detailColor: modelData != null ? modelData.monsterDetailColor : "black"
                firstAddOn: modelData != null ? modelData.monsterFirstAddOn : false
                secondAddOn: modelData != null ? modelData.monsterSecondAddOn : false
              } //OutfitAppearanceInstanceRenderer

              Image {
                smooth: false
                visible: !preyMonsterDisplay.visible
                anchors.centerIn: parent
                source: "/images/prey-noprey-small.png"
              } //image
            } //Item

            Image {
              id: bonusIcon2
              smooth: false
              source: modelData != null ? modelData.bonusIconSmall : "/images/prey-bonus-none-small.png"
            } // Image

            ColumnLayout {
              Layout.fillWidth: true
              Layout.fillHeight: true
              spacing: TibiaStyle.marginNarrow

              TibiaText {
                Layout.fillWidth: true
                elide: Text.ElideRight
                text: {
                  if (modelData != null && modelData.isActive) {
                    return modelData.monsterName;
                  }
                  return qsTrId("prey_inactive");
                }
              } // TibiaText

              RowLayout {
                SlimProgressbar {
                  height: TibiaStyle.progressBarSlimHeight
                  progressbarPercent: (modelData != null && modelData.isActive) ? modelData.timeLeftProgress : 0.0
                  Layout.fillWidth: true
                  progressbarColor: TibiaStyle.preyProgressBarColor
                  progressbarBackgroundColor: "transparent"
                } //SlimProgressbar

                Image {
                  smooth: false
                  Layout.alignment: Qt.AlignVCenter
                  source: {
                    if(modelData != null && widgetController != null) {
                      if (modelData.automaticPreyExtendType == TibiaEnums.BONUS_REROLL) {
                        if (widgetController.bonusRerollpossible) {
                          return "/images/prey-auto-reroll-enabled.png"
                        } else {
                          return "/images/prey-auto-reroll-enabled-failing.png"
                        }
                      } else if (modelData.automaticPreyExtendType == TibiaEnums.LOCK_PREY) {
                        if (widgetController.lockPreyPossible) {
                          return "/images/prey-lock-prey-enabled.png"
                        } else {
                          return "/images/prey-lock-prey-enabled-failing.png"
                        }
                      }
                    }

                    return "/images/prey-auto-extend-disabled.png"
                  } //source
                } //Image
              } //RowLayout
            } //ColumnLayout
          } //RowLayout

          Tooltip {
            anchors.fill: parent
            text: {
              var text = "";
              if (modelData != null) {
                if (modelData.isActive) {
                  text = qsTrId("prey_hover_prey_view_active").arg(modelData.monsterName)
                                                              .arg(modelData.timeLeft)
                                                              .arg(modelData.bonusGradeText)
                                                              .arg(modelData.bonusTypeText)
                        + "<br>" + modelData.automaticExtendTypeText
                        + "<br>" + modelData.preyDescription
                        + "<br><br>" + qsTrId("killtracker_tooltip_click_widget");
                } else {
                  text = qsTrId("killtracker_tooltip_inactive");
                }
              }

              return text;
            }
          } //Tooltip
        } //delegate: Item

        footer: Item {
          height: TibiaStyle.marginRelated
        } //footer: Item

        MouseArea {
          anchors.fill: parent
          onClicked: {
            if (widgetController != null) {
              widgetController.requestOpenPreyDialog();
            }
          }
        } //MouseArea
      } //ListView
      Item {
        id: spacer
        Layout.preferredHeight: TibiaStyle.marginUnrelated
      } //Item

      ColumnLayout {
        id: bountyTasksCaptionWrapper
        Layout.fillWidth: true
        spacing: TibiaStyle.marginNarrow
        TibiaText {
          text: qsTrId('kill_tracker_bounty_tasks_caption');
        } //TibiaText
        TibiaHorizontalSeparator {
        }
      } //ColumnLayout

      ListView {
        
        Layout.fillWidth: true
        Layout.minimumHeight: count * 22

        boundsBehavior: Flickable.StopAtBounds
        interactive: false //prevent flick behavior on touch screens
        rebound: Transition {}

        model: widgetController != null ? widgetController.bountyTasksModel : null

        delegate: Item {

          property int selectedRaceID: raceID
          property var selectedRaceName: raceName
          property var huntProgress: amountToHunt > 0 ? amountHunted / amountToHunt : 0
          property bool isProgressFinished: amountHunted == amountToHunt

          width: ListView.view.width - 2
          height: visible ? 22 : 0
          visible: true

          RowLayout {
            anchors.fill: parent
            spacing: TibiaStyle.marginNarrow

            Item {
              Layout.fillHeight: true
              Layout.preferredWidth: height

              RaceAppearanceInstanceRenderer {
                id: raceRenderer
                anchors.centerIn: parent
                height: TibiaStyle.battleListMonsterSize
                width: TibiaStyle.battleListMonsterSize

                raceID: selectedRaceID
                autofit: true
                smoothTextureFiltering: true
                moving: false
                visible: isActive
              } //RaceAppearanceInstanceRenderer

              Image {
                smooth: false
                visible: !raceRenderer.visible
                anchors.centerIn: parent
                source: "/images/prey-noprey-small.png"
              } //image
            } //Item

            Item {
              width: 15
              height: 15
              Image {
                id: bonusIcon
                smooth: false
                anchors.centerIn: parent
                source: "/images/taskboard/icon-currency-bountypoints.png"
              } //Image
            } //Item

            ColumnLayout {
              Layout.fillWidth: true
              Layout.fillHeight: true
              spacing: TibiaStyle.marginNarrow

              TibiaText {
                Layout.fillWidth: true
                elide: Text.ElideRight
                text: isActive ? selectedRaceName : qsTrId("kill_tracker_finished_monster_name")            
              } //TibiaText

              RowLayout {
                SlimProgressbar {
                  height: TibiaStyle.progressBarSlimHeight
                  progressbarPercent: huntProgress
                  Layout.fillWidth: true
                  progressbarColor: isProgressFinished ? TibiaStyle.preyHuntingTaskFinishedProgressBarColor : TibiaStyle.preyProgressBarColor
                  progressbarBackgroundColor: "transparent"
                } //SlimProgressbar

                Image {
                  smooth: false
                  source: "/images/prey-auto-extend-disabled.png"
                  opacity: 0.0
                }
              } //RowLayout
            } //ColumnLayout
          } //RowLayout

          Tooltip {
            anchors.fill: parent
            text: {
              var text = "";
              if (isActive) {
                text = qsTrId("kill_tracker_active_bounty_task_tooltip")
                  .arg(selectedRaceName)
                  .arg(amountHunted)
                  .arg(amountToHunt);                
              } else {
                text = qsTrId("kill_tracker_finished_bounty_task_tooltip");
              }

              return text;
            }
          } //Tooltip
        } //delegate: Item

        footer: Item {
          height: TibiaStyle.marginRelated
        } //footer: Item

        MouseArea {
          anchors.fill: parent
          onClicked: {
            if (widgetController != null) {
              widgetController.requestOpenBountyTasksDialog();
            }
          }
        } //MouseArea
      } //ListView

      Item {
        id: spacer3
        Layout.preferredHeight: TibiaStyle.marginUnrelated
      } //Item

      ColumnLayout {
        id: weeklyTasksCaptionWrapper
        Layout.fillWidth: true
        spacing: TibiaStyle.marginNarrow
        TibiaText {
          text: qsTrId('kill_tracker_weekly_tasks_caption');
        } //TibiaText
        TibiaHorizontalSeparator {
        }
      } //ColumnLayout

      ListView {
        Layout.fillWidth: true
        Layout.minimumHeight: count * 22

        boundsBehavior: Flickable.StopAtBounds
        interactive: false //prevent flick behavior on touch screens
        rebound: Transition {}

        model: widgetController != null ? widgetController.weeklyTasksModel : null

        delegate: Item {

          property int selectedRaceID: raceID
          property var selectedRaceName: raceName
          property var huntProgress: amountToHunt > 0 ? amountHunted / amountToHunt : 0
          property bool isFinished: amountHunted == amountToHunt
          property bool isArbitraryMonster: raceID == 0
          property bool isExpired: !isActive

          width: ListView.view.width - 2
          height: visible ? 22 : 0
          visible: true

          RowLayout {
            anchors.fill: parent
            spacing: TibiaStyle.marginNarrow

            Item {
              Layout.fillHeight: true
              Layout.preferredWidth: height

              RaceAppearanceInstanceRenderer {
                id: raceRenderer
                anchors.centerIn: parent
                height: TibiaStyle.battleListMonsterSize
                width: TibiaStyle.battleListMonsterSize

                raceID: selectedRaceID
                autofit: true
                smoothTextureFiltering: true
                moving: false
                visible: !isArbitraryMonster
              } //RaceAppearanceInstanceRenderer

              Image {
                smooth: false
                visible: !raceRenderer.visible
                anchors.centerIn: parent
                source: "/images/taskboard/icon-arbitrarymonster.png"
              } //image
            } //Item

            Item {
              width: 15
              height: 15
              Image {
                id: bonusIcon
                smooth: false
                anchors.centerIn: parent
                source: "/images/preyhuntingtask-tokens.png"
              } //Image
            } //Item

            ColumnLayout {
              Layout.fillWidth: true
              Layout.fillHeight: true
              spacing: TibiaStyle.marginNarrow

              TibiaText {
                Layout.fillWidth: true
                elide: Text.ElideRight
                text: isExpired ? qsTrId("kill_tracker_expired_monster_name") : (isArbitraryMonster ? qsTrId("kill_tracker_arbitrary_monster_name") : selectedRaceName)
              } //TibiaText

              RowLayout {
                SlimProgressbar {
                  height: TibiaStyle.progressBarSlimHeight
                  progressbarPercent: huntProgress
                  Layout.fillWidth: true
                  progressbarColor: isFinished ? TibiaStyle.preyHuntingTaskFinishedProgressBarColor : (isExpired ? TibiaStyle.preyHuntingTaskExpiredProgressBarColor : TibiaStyle.preyProgressBarColor)
                  progressbarBackgroundColor: "transparent"
                } //SlimProgressbar

                Image {
                  smooth: false
                  source: "/images/prey-auto-extend-disabled.png"
                  opacity: 0.0
                }
              } //RowLayout
            } //ColumnLayout
          } //RowLayout

          Tooltip {
            anchors.fill: parent
            text: {
              var text = "";
              if (isExpired) {
                text = qsTrId("kill_tracker_expired_weekly_task_tooltip");
              } else {
                text = qsTrId("kill_tracker_running_weekly_task_tooltip")
                  .arg(isArbitraryMonster ? qsTrId("kill_tracker_arbitrary_monster_name") : selectedRaceName)
                  .arg(amountHunted)
                  .arg(amountToHunt);
              }
              return text;
            }
          } //Tooltip
        } //delegate: Item

        footer: Item {
          height: TibiaStyle.marginRelated
        } //footer: Item

        MouseArea {
          anchors.fill: parent
          onClicked: {
            if (widgetController != null) {
              widgetController.requestOpenWeeklyTasksDialog();
            }
          }
        } //MouseArea
      } //ListView

    } //ColumnLayout
  } //TibiaScrollView

  Lenshelp {
    anchors.fill: parent
    triggerRect: mapFromItem(widgetRoot, 0, 0, widgetRoot.width, widgetRoot.height)
    caption: qsTrId("killtrackerwidget_lenshelp_caption")
    content: qsTrId("killtrackerwidget_lenshelp")
  } //Lenshelp

} // TibiaSidebarWidget
