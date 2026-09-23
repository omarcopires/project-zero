import QtQuick
import QtQuick.Layouts
import qmlcomponents


GridLayout {
  id: comboPointsAndSereneState

  property int amountOfCombopoints: 0
  property bool isSerene: false
  property bool horizontalView: true

  rows: horizontalView ? 1 : 8
  columns: horizontalView ? 8 : 1

  rowSpacing: TibiaStyle.marginNarrow
  columnSpacing: TibiaStyle.marginNarrow

  component Combopoint: Image {
    property bool available: true

    source: available ? "/images/icon-combopoint-filled.png" : "/images/icon-combopoint-empty.png"

    Tooltip {
      anchors.fill: parent
      text: qsTrId("statusbar_combopoints_tooltip").arg(amountOfCombopoints)
    } //Tooltip
  } // Image

  Combopoint {
    id: firstImage
    Layout.row: horizontalView ? 0 : 7
    Layout.column: horizontalView ? 0 : 0
    available: amountOfCombopoints > 0
  } // Combopoint

  Combopoint {
    Layout.row: horizontalView ? 0 : 6
    Layout.column: horizontalView ? 1 : 0
    available: amountOfCombopoints > 1
  } // Combopoint

  Combopoint {
    Layout.row: horizontalView ? 0 : 5
    Layout.column: horizontalView ? 2 : 0
    available: amountOfCombopoints > 2
  } // Combopoint

  Combopoint {
    Layout.row: horizontalView ? 0 : 4
    Layout.column: horizontalView ? 3 : 0
    available: amountOfCombopoints > 3
  } // Combopoint

  Combopoint {
    Layout.row: horizontalView ? 0 : 3
    Layout.column: horizontalView ? 4 : 0
    available: amountOfCombopoints > 4
  } // Combopoint

  TibiaVerticalSeparator {
    Layout.row: horizontalView ? 0 : 2
    Layout.column: horizontalView ? 5 : 0
    Layout.maximumHeight: firstImage.height
    Layout.leftMargin: TibiaStyle.marginNarrow
    Layout.rightMargin: TibiaStyle.marginNarrow
    visible: horizontalView
  } //TibiaVerticalSeparator

  TibiaHorizontalSeparator {
    Layout.row: horizontalView ? 0 : 1
    Layout.column: horizontalView ? 6 : 0
    Layout.maximumWidth: firstImage.width
    Layout.topMargin: TibiaStyle.marginNarrow
    Layout.bottomMargin: TibiaStyle.marginNarrow
    visible: !horizontalView
  } //TibiaHorizontalSeparator

  Image {
    Layout.row: horizontalView ? 0 : 0
    Layout.column: horizontalView ? 7 : 0
    source: isSerene ? "/images/icon-serene-on.png" : "/images/icon-serene-off.png"
    Tooltip {
      anchors.fill: parent
      text: "%1

%2".arg(isSerene ? qsTrId("statusbar_serene_on_tooltip") : qsTrId("statusbar_serene_off_tooltip"))
   .arg(qsTrId("statusbar_serene_tooltip"))
    } //Tooltip
  } // Image
} // GridLayout

