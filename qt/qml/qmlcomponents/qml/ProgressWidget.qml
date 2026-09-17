import QtQuick
import QtQuick.Layouts

import qmlcomponents


TibiaSidebarWidget {
  caption: qsTrId("progress_caption")
  picSource: "/images/skin/classic/icon-progressanalyser-widget.png"

  property bool showBaseXpData: widgetController != null && widgetController.showBaseXp

  minContentHeight: 63
  initialContentHeight: 199
  maxContentHeight: showBaseXpData ? 235 : 199

  customButtonContainerData: [
    TibiaIconButton {
      id: showListButton
      sourceUp:   "/images/skin/classic/button-contextmenu-12x12-idle.png"
      sourceDown: "/images/skin/classic/button-contextmenu-12x12-pressed.png"
      tooltipText: qsTrId("progress_options_tooltip")
      onClicked:  widgetController != null ? widgetController.onShowContextMenu() : undefined
    } //TibiaIconButton
  ] //customButtonContainerData


  TibiaScrollView {
    id: scrollView
    anchors { left: parent.left; leftMargin: TibiaStyle.marginNarrow;
              right: parent.right;
              top: parent.top; bottom: parent.bottom }

    Flickable {
      contentHeight: contentLayout.height

      interactive: false //prevent flick behavior on touch screens
      boundsBehavior: Flickable.StopAtBounds

      ColumnLayout {
        id: contentLayout
        anchors { left: parent.left; leftMargin: TibiaStyle.marginNarrow; right: parent.right; rightMargin: TibiaStyle.marginRelated; topMargin: TibiaStyle.marginRelated; }
        spacing: TibiaStyle.marginRelated

        RowLayout {
          visible: showBaseXpData

          TibiaText {
            text: qsTrId("progress_base_xp_gain")
          } //TibiaText

          TibiaText {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
            text: widgetController != null ? widgetController.baseAccumulatedXpString : "0"
          } //TibiaText
        } //RowLayout

        RowLayout {
          TibiaText {
            text: qsTrId("progress_xp_gain")
          } //TibiaText

          TibiaText {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
            text: widgetController != null ? widgetController.accumulatedXpString : "0"
          } //TibiaText
        } //RowLayout

        RowLayout {
          visible: showBaseXpData

          TibiaText {
            text: qsTrId("progress_base_xp_per_hour_short")
          } //TibiaText

          TibiaText {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
            text: widgetController != null ? widgetController.baseXpPerHourString : "0"
          } //TibiaText
        } //RowLayout

        RowLayout {
          TibiaText {
            text: qsTrId("progress_xp_per_hour_short")
          } //TibiaText

          TibiaText {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
            text: widgetController != null ? widgetController.xpPerHourString : "0"
          } //TibiaText
        } //RowLayout

        RowLayout {
          TibiaText {
            text: qsTrId("progress_time_to_next_level")
          } //TibiaText

          TibiaText {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
            text: widgetController != null ? widgetController.timeToNextLevel : ""
          } //TibiaText
        } //RowLayout

        SlimProgressbar {
          height: TibiaStyle.progressBarSlimHeight
          Layout.preferredWidth: contentLayout.width
          progressbarColor: "green"
          progressbarPercent: widgetController != null ? widgetController.playerLevelProgress : 0
          progressbarBackgroundColor: "transparent"
        } //SlimProgressbar

        TibiaHorizontalSeparator {
          Layout.fillWidth: true
          visible: gauge.visible
        } // TibiaHorizontalSeparator

        TibiaGauge {
          id: gauge
          Layout.preferredWidth: contentLayout.width
          currentValue: widgetController != null ? Math.floor(widgetController.xpGaugeValue) : 0
          targetValue: widgetController != null ? widgetController.xpGaugeTargetValue : 0
          visible: widgetController != null ? widgetController.isGaugeVisible : false

          MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton

            onClicked: {
              if (widgetController != null) {
                widgetController.onShowXPGaugeContextMenu();
              }
            } // onClicked
          } // MouseArea
        } // TibiaGauge

        TibiaHorizontalSeparator {
          Layout.fillWidth: true
          visible: graph.visible
        } // TibiaHorizontalSeparator

        TibiaGraph {
          id: graph
          visible: widgetController != null ? widgetController.isGraphVisible : false
          xLabel: widgetController != null ? qsTrId("progress_xp_graph_x") : qsTrId("dummy_unknown")
          yLabel: widgetController != null ? qsTrId("progress_xp_graph_y") : qsTrId("dummy_unknown")
          labelCountYAxis: 3
          xMin: -60
          xMax:   0
          yMin:   0
          yMax: widgetController != null ? widgetController.xpGraphMaxY : 1
          values: widgetController != null ? widgetController.xpHistory : []

          MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton

            onClicked: {
              if (widgetController != null) {
                widgetController.onShowXPGraphContextMenu();
              }
            } // onClicked
          } // MouseArea
        } // TibiaGraph
      } //ColumnLayout

      Tooltip {
        anchors.fill: parent
        text: widgetController != null ?
        (
          showBaseXpData ?
          qsTrId("progress_base_xp_gain") + " " + widgetController.baseAccumulatedXpString.split("\x9C")[0] + "\n"
          : ""
        ) +
        qsTrId("progress_xp_gain") + " " + widgetController.accumulatedXpString.split("\x9C")[0] + "\n" + //see texthelper.cpp:15 and http://doc.qt.io/qt-5/qml-qtquick-text.html#elide-prop
        (
          showBaseXpData ?
          qsTrId("progress_base_xp_per_hour_current") + " " + widgetController.baseXpPerHourString.split("\x9C")[0] + "\n"
          : ""
        ) +
        qsTrId("progress_xp_per_hour_current") + " " + widgetController.xpPerHourString.split("\x9C")[0] + "\n" + //see texthelper.cpp:15 and http://doc.qt.io/qt-5/qml-qtquick-text.html#elide-prop
        (
          widgetController.isGaugeVisible ?
          qsTrId("progress_xp_per_hour_target") + " " + widgetController.xpGaugeTargetValueString + "\n"
          : ""
        ) +
        qsTrId("progress_xp_needed_for_next_level").arg(widgetController.experiencePointsNeededForNextLevel) + "\n" +
        qsTrId("progress_percent_to_next_level").arg((1.0 - widgetController.playerLevelProgress) * 100)
        : ""
      }
    } //Flickable
  } //TibiaScrollView

  Lenshelp {
    anchors.fill: parent
    triggerRect: mapFromItem(widgetRoot, 0, 0, widgetRoot.width, widgetRoot.height)
    caption: qsTrId("progress_lenshelp_caption")
    content: qsTrId("progress_lenshelp")
  } //Lenshelp
} // TibiaSidebarWidget
