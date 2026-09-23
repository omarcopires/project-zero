import QtQuick
import QtQuick.Layouts

import qmlcomponents



ColumnLayout {
  id: root
  spacing: TibiaStyle.marginRelated

  signal requestGaugeContextMenu()
  signal requestGraphContextMenu()

  property string abbreviation: "dps"
  property alias caption: captionText.text

  property alias gaugeVisible: gaugeView.visible
  property alias impactSum: sumText.text
  property real impactPerSecond: 0.0
  property alias impactPerSecondString: impactPerSecondText.text
  property alias maxImpactPerSecond: maxImpactPerSecondText.text
  property alias allTimeMaxImpact: allTimeMaxImpactText.text
  property real targetImpactPerSecond: 0.0
  property alias targetImpactPerSecondString: targetImpactPerSecondText.text

  property alias graphVisible: graphView.visible
  property alias graphYMax: graph.yMax
  property alias graphValues: graph.values

  property bool showSessionValues: false;

  ColumnLayout {
    id: defaultView
    Layout.fillWidth: true
    spacing: TibiaStyle.marginRelated

    TibiaText {
      id: captionText
      Layout.fillWidth: true
      styleType: "WhiteCaption"
      wrapMode: Text.Wrap
    } //TibiaText

    RowLayout {
      spacing: TibiaStyle.marginNarrow

      TibiaText {
        text: qsTrId("impact_total_label")
      } //TibiaText

      TibiaText {
        id: sumText
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignRight
      } //TibiaText
    } //RowLayout

    RowLayout {
      spacing: TibiaStyle.marginNarrow

      TibiaText {
        text: qsTrId("impact_" + root.abbreviation.toLowerCase() + "_abbreviation_label")  + ":"
      } //TibiaText

      TibiaText {
        id: impactPerSecondText
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignRight
      } //TibiaText

      visible: !gaugeView.visible
    } //RowLayout

    RowLayout {
      spacing: TibiaStyle.marginNarrow

      TibiaText {
        text: qsTrId("impact_max_label") + qsTrId("impact_" + root.abbreviation.toLowerCase() + "_abbreviation_label") + ":"
      } //TibiaText

      TibiaText {
        id: maxImpactPerSecondText
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignRight
      } //TibiaText
    } //RowLayout

    RowLayout {
      spacing: TibiaStyle.marginNarrow

      TibiaText {
        text: qsTrId("impact_all_time_max") + ":"
      } //TibiaText

      TibiaText {
        id: allTimeMaxImpactText
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignRight
      } //TibiaText
    } //RowLayout
  } //ColumnLayout

  Item {
    id: gaugeView
    Layout.preferredHeight: gaugeLayout.height
    Layout.fillWidth: true

    ColumnLayout {
      id: gaugeLayout
      anchors { left: parent.left; right: parent.right }
      spacing: TibiaStyle.marginRelated

      TibiaHorizontalSeparator {
        Layout.fillWidth: true
        //Layout.bottomMargin: TibiaStyle.marginNarrow - parent.spacing
      } //TibiaHorizontalSeparator

      RowLayout {
        spacing: TibiaStyle.marginNarrow

        TibiaText {
          text: qsTrId("impact_target_label") + qsTrId("impact_" + root.abbreviation.toLowerCase() + "_abbreviation_label") + ":"
        } //TibiaText

        TibiaText {
          id: targetImpactPerSecondText
          Layout.fillWidth: true
          horizontalAlignment: Text.AlignRight
        } //TibiaText
      } //RowLayout

      TibiaGauge {
        id: gauge
        Layout.fillWidth: true
        targetValue: root.targetImpactPerSecond
        targetValueString: root.targetImpactPerSecondString
        currentValue: root.impactPerSecond
        currentValueString: root.impactPerSecondString
      } //TibiaGauge

      RowLayout {
        spacing: TibiaStyle.marginNarrow

        TibiaText {
          text: qsTrId("impact_" + root.abbreviation.toLowerCase() + "_abbreviation_label") + ":"
        } //TibiaText

        TibiaText {
          Layout.fillWidth: true
          horizontalAlignment: Text.AlignRight
          text: root.impactPerSecondString
        } //TibiaText
      } //RowLayout
    } //ColumnLayout

    MouseArea {
      anchors.fill: parent

      acceptedButtons: Qt.RightButton
      onClicked: root.requestGaugeContextMenu()
    } //MouseArea
  } //Item

  Item {
    id: graphView
    Layout.preferredHeight: graphLayout.height
    Layout.fillWidth: true

    ColumnLayout {
      id: graphLayout
      anchors { left: parent.left; right: parent.right }
      spacing: TibiaStyle.marginRelated

      TibiaHorizontalSeparator {
        Layout.fillWidth: true
        Layout.bottomMargin: TibiaStyle.marginNarrow - parent.spacing
      } //TibiaHorizontalSeparator

      TibiaGraph {
        id: graph
        Layout.fillWidth: true
        xLabel: qsTrId("minutes")
        yLabel: qsTrId("impact_" + root.abbreviation.toLowerCase() + "_abbreviation_label")
        xMin: showSessionValues ? -60 : -4
        xMax:   0
        yMin:   0
        yMax:   1
        values: []
      } // TibiaGraph
    } //ColumnLayout

    MouseArea {
      anchors.fill: parent

      acceptedButtons: Qt.RightButton
      onClicked: root.requestGraphContextMenu()
    } //MouseArea
  } //Item

} //ColumnLayout

