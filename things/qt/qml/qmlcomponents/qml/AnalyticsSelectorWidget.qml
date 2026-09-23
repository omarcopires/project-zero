import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qmlcomponents



TibiaSidebarWidget {
  id: vipSidebarWidget
  caption: qsTrId("cyclopedia_analytics_caption")
  picSource: "/images/skin/classic/icon-analyticsselector-widget.png"

  minContentHeight: TibiaStyle.buttonHeightDefault * 3
  initialContentHeight: buttonLayout.height + TibiaStyle.marginRelated * 2
  maxContentHeight: buttonLayout.height + TibiaStyle.marginRelated * 2

  TibiaScrollView {
    id: listView
    anchors.fill: parent
    clip: true  // Ensure items don't overflow

    Flickable {
      id: skillsFlickable
      boundsBehavior: Flickable.StopAtBounds
      interactive: false //prevent flick behavior on touch screens

      contentHeight: buttonLayout.height
      contentWidth: width

      ColumnLayout {
        id: buttonLayout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: TibiaStyle.marginRelated
        spacing: TibiaStyle.marginNarrow

        TibiaButton {
          text: widgetController != null && !widgetController.isPremium ? "" : qsTrId("cyclopedia_open_hunting_session_analyser")
          Layout.fillWidth: true
          Layout.topMargin: TibiaStyle.marginRelated
          checkable: true
          buttonShouldBeChecked: widgetController == null ? false : widgetController.huntingSessionAnalyserVisible
          useButtonShouldBeChecked: true
          color: widgetController != null && !widgetController.isPremium ? "blue" : "grey";
          tooltipText: widgetController != null && !widgetController.isPremium ? qsTrId("cyclopedia_hunting_analyser_premium_only") : ""
          tooltipTextChecked: tooltipText
          imageSource: widgetController != null && !widgetController.isPremium ? "/images/cyclopedia-hunting-session-premium.png" : ""

          onClicked: {
            if (widgetController != null) {
              widgetController.huntingSessionAnalyserButtonClicked();
            }
          } //onClicked
        } // TibiaButton

        TibiaButton {
          text: qsTrId("cyclopedia_open_loot_analyser")
          Layout.fillWidth: true
          checkable: true
          buttonShouldBeChecked: widgetController == null ? false : widgetController.lootAnalyserVisible
          useButtonShouldBeChecked: true

          onClicked: {
            if (widgetController != null) {
              widgetController.lootAnalyserButtonClicked();
            }
          } //onClicked
        } // TibiaButton

        TibiaButton {
          text: qsTrId("cyclopedia_open_waste_analyser")
          Layout.fillWidth: true
          checkable: true
          buttonShouldBeChecked: widgetController == null ? false : widgetController.wasteAnalyserVisible
          useButtonShouldBeChecked: true

          onClicked: {
            if (widgetController != null) {
              widgetController.wasteAnalyserButtonClicked();
            }
          } //onClicked
        } // TibiaButton

        TibiaButton {
          text: qsTrId("cyclopedia_open_impact_analyser")
          Layout.fillWidth: true
          checkable: true
          buttonShouldBeChecked: widgetController == null ? false : widgetController.impactAnalyserVisible
          useButtonShouldBeChecked: true

          onClicked: {
            if (widgetController != null) {
              widgetController.impactAnalyserButtonClicked();
            }
          } //onClicked
        } // TibiaButton

        TibiaButton {
          text: qsTrId("cyclopedia_open_damageinput_analyser")
          Layout.fillWidth: true
          checkable: true
          buttonShouldBeChecked: widgetController == null ? false : widgetController.damageInputAnalyserVisible
          useButtonShouldBeChecked: true

          onClicked: {
            if (widgetController != null) {
              widgetController.damageInputAnalyserButtonClicked();
            }
          } //onClicked
        } // TibiaButton

        TibiaButton {
          text: qsTrId("cyclopedia_open_progress_analyser")
          Layout.fillWidth: true
          checkable: true
          buttonShouldBeChecked: widgetController == null ? false : widgetController.progressAnalyserVisible
          useButtonShouldBeChecked: true

          onClicked: {
            if (widgetController != null) {
              widgetController.progressAnalyserButtonClicked();
            }
          } //onClicked
        } // TibiaButton

        TibiaButton {
          text: qsTrId("cyclopedia_open_loot_tracker")
          Layout.fillWidth: true
          checkable: true
          buttonShouldBeChecked: widgetController == null ? false : widgetController.lootTrackerVisible
          useButtonShouldBeChecked: true

          onClicked: {
            if (widgetController != null) {
              widgetController.lootTrackerButtonClicked();
            }
          } //onClicked
        } // TibiaButton

        TibiaButton {
          text: qsTrId("cyclopedia_open_party_hunt_analyser")
          Layout.fillWidth: true
          checkable: true
          buttonShouldBeChecked: widgetController == null ? false : widgetController.partyHuntAnalyserVisible
          useButtonShouldBeChecked: true

          onClicked: {
            if (widgetController != null) {
              widgetController.partyHuntAnalyserButtonClicked();
            }
          } //onClicked
        } // TibiaButton

        TibiaButton {
          text: qsTrId("cyclopedia_open_boss_tracker")
          Layout.fillWidth: true
          checkable: true
          buttonShouldBeChecked: widgetController == null ? false : widgetController.bossTrackerVisible
          useButtonShouldBeChecked: true

          onClicked: {
            if (widgetController != null) {
              widgetController.bossTrackerButtonClicked();
            }
          } //onClicked
        } // TibiaButton
      } // ColumnLayout
    } // Flickable
  } // TibiaScrollView

  Lenshelp {
    anchors.fill: parent
    triggerRect: mapFromItem(widgetRoot, 0, 0, widgetRoot.width, widgetRoot.height)
    caption: qsTrId("cyclopedia_analytics_lenshelp_caption")
    content: qsTrId("cyclopedia_analytics_lenshelp")
  } //Lenshelp
} // TibiaSidebarWidget
