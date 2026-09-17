import QtQuick
import QtQuick.Layouts

import qmlcomponents
import qmlenumvalues


TibiaSidebarWidget {
  id: root

  property var widgetMode: widgetController != null ? widgetController.widgetMode : CreatureTrackerWidgetController.Bestiary

  customButtonContainerData: [
    TibiaButton {
      id: addEntryButton
      Layout.preferredWidth: TibiaStyle.widgetControllButtonSize
      Layout.preferredHeight: TibiaStyle.widgetControllButtonSize
      imageSource: "/images/skin/classic/icon-additionalwidget.png"
      color: "verydarkgrey"
      tooltipText: root.widgetMode == CreatureTrackerWidgetController.Bestiary ? qsTrId("bestiary_tracker_add_creature_tooltip") : qsTrId("bosstiary_tracker_add_creature_tooltip")
      onClicked:  widgetController != null ? widgetController.requestOpenBestiary() : undefined
    }, //TibiaIconButton

    TibiaIconButton {
      id: showConfigButton
      sourceUp:   "/images/skin/classic/button-contextmenu-12x12-idle.png"
      sourceDown: "/images/skin/classic/button-contextmenu-12x12-pressed.png"
      tooltipText: widgetController != null ? qsTrId("bestiary_tracker_options_tooltip") : qsTrId("dummy_unknown")
      onClicked:  widgetController != null ? widgetController.requestWidgetConfigurationMenu() : undefined
    } //TibiaIconButton
  ] //customButtonContainerData


  caption:  root.widgetMode == CreatureTrackerWidgetController.Bestiary ? qsTrId("bestiary_tracker_caption") : qsTrId("bosstiary_tracker_caption") 
  picSource: root.widgetMode == CreatureTrackerWidgetController.Bestiary ? "/images/skin/classic/icon-bestiarytracker-widget.png" : "/images/skin/classic/icon-bosstiarytracker-widget.png"

  TibiaScrollView {
    anchors.fill: parent

    ListView {
      id: creatureList
      model: widgetController != null ? widgetController.trackedCreatures : null

      boundsBehavior: Flickable.StopAtBounds
      interactive: false //prevent flick behavior on touch screens
      rebound: Transition {}

      delegate: Item {
        width: creatureList.width
        height: contentColumnLayout.height + TibiaStyle.marginRelated

        MouseArea {
          anchors { left: parent.left; right: parent.right }
          height: raceRenderer.height

          acceptedButtons: Qt.LeftButton | Qt.RightButton
          hoverEnabled: true

          onEntered: {
            if (tibiaMouseCursorController != null) {
              tibiaMouseCursorController.setPointingHand(true);
            }
          } //onEntered

          onExited: {
            if (tibiaMouseCursorController != null) {
              tibiaMouseCursorController.setPointingHand(false);
            }
          } //onExited

          onClicked: (mouse) => {
            if (tibiaMouseCursorController != null) {
              tibiaMouseCursorController.setPointingHand(false);
            }

            if (mouse.button == Qt.RightButton) {
              widgetController.requestContextMenu(model.raceID, model.name);
            } else {
              widgetController.requestOpenBestiaryEntry(model.raceID);
            }
          } // onClicked
        } //MouseArea

        ColumnLayout {
          id: contentColumnLayout
          spacing: TibiaStyle.marginNarrow
          anchors.left: parent.left
          anchors.right: parent.right
          RowLayout {
            Layout.rightMargin: TibiaStyle.marginRelated
            spacing: TibiaStyle.marginRelated
            RaceAppearanceInstanceRenderer {
              id: raceRenderer
              width: 16
              height: 16
              raceID: model.raceID
              moving: true
            } //RaceAppearanceInstanceRenderer

            TibiaText {
              Layout.fillWidth: true
              text: model.name
            } //TibiaText
            Loader {
              id: cooldownLoader
              property bool creatureHasCooldown: model.creatureHasCooldown
              property bool cooldownIsExpired: model.cooldownIsExpired
              property string cooldownEndText: model.cooldownEndText
              Component {
                id: cooldownTextComponent
                Image {
                  source: cooldownLoader.cooldownIsExpired ? "/images/icon-cooldown-finished.png" : "/images/icon-cooldown-running.png"
                  Tooltip {
                    anchors.fill: parent
                    delayInMs: 0
                    text: cooldownLoader.cooldownEndText
                  }
                }
              }
              sourceComponent: cooldownLoader.creatureHasCooldown ? cooldownTextComponent : undefined
            }
          }

          CreatureUnlockProgress {
            id: unlockProgress
            Layout.fillWidth: true
            Layout.preferredHeight: TibiaStyle.progressBarSmallHeight

            currentKills: model.currentKills
            killsToUnlockDetails1: model.killsForDetails1
            killsToUnlockDetails2: model.killsForDetails2
            killsToFullUnlock: model.killsForDetails3
            isFullyUnlocked: model.isFullyUnlocked
          } // CreatureUnlockProgress
        }
      } //delegate: Item
    } //ListView
  } //TibiaScrollView

  Lenshelp {
    anchors.fill: parent
    triggerRect: mapFromItem(widgetRoot, 0, 0, widgetRoot.width, widgetRoot.height)
    caption: qsTrId("bestiary_tracker_widget_lenshelp_caption")
    content: qsTrId("bestiary_tracker_widget_lenshelp")
  } //Lenshelp

} // TibiaSidebarWidget
