import QtQuick
import QtQuick.Layouts

import qmlcomponents


TibiaSidebarWidget {
  caption: widgetController != null ? qsTrId(widgetController.translationPrefix + "caption") : qsTrId("dummy_unknown")
  picSource: widgetController != null ? "/images/skin/classic/icon-" + widgetController.imagePrefix + "analyser-widget.png" : ""

  minContentHeight: TibiaStyle.widgetWithScrollBarMinContentHeight
  //maxContentHeight: Math.max(contentLayout.height + TibiaStyle.marginNarrow, TibiaStyle.widgetWithScrollBarMinContentHeight)
  //initialContentHeight: maxContentHeight

  customButtonContainerData: [
    TibiaIconButton {
      id: showListButton
      sourceUp:   "/images/skin/classic/button-contextmenu-12x12-idle.png"
      sourceDown: "/images/skin/classic/button-contextmenu-12x12-pressed.png"
      tooltipText: widgetController != null ? qsTrId(widgetController.translationPrefix + "options_tooltip") : qsTrId("dummy_unknown")
      onClicked:  widgetController != null ? widgetController.requestConfigurationContextMenu() : undefined
    } //TibiaIconButton
  ] //customButtonContainerData


  TibiaScrollView {
    id: scrollView
    anchors.fill: parent

    Flickable {
      contentHeight: contentLayout.height

      interactive: false //prevent flick behavior on touch screens
      boundsBehavior: Flickable.StopAtBounds
      pixelAligned: true

      ColumnLayout {
        id: contentLayout
        anchors { left: parent.left; leftMargin: TibiaStyle.marginNarrow; right: parent.right; rightMargin: TibiaStyle.marginNarrow; top: parent.top; topMargin: TibiaStyle.marginNarrow; }

        RowLayout {
          spacing: TibiaStyle.marginNarrow

          TibiaText {
            text: widgetController != null ? qsTrId(widgetController.translationPrefix + "gold_value") : qsTrId("dummy_unknown")
          }

          TibiaText {
            text: widgetController != null ? widgetController.gainWasteValueString : qsTrId("dummy_unknown")
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
          }

          Image {
            source: "/images/icon-goldcoin.png"
            smooth: false
          }
        } // RowLayout

        RowLayout {
          spacing: TibiaStyle.marginNarrow
          TibiaText {
            text: widgetController != null ? qsTrId(widgetController.translationPrefix + "per_hour") : qsTrId("dummy_unknown")
          }

          TibiaText {
            text: widgetController != null ? widgetController.gainWastePerHourString : qsTrId("dummy_unknown")
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
          }

          Image {
            source: "/images/icon-goldcoin.png"
            smooth: false
          }
        } // RowLayout

        TibiaHorizontalSeparator {
          Layout.fillWidth: true
          visible: itemsGridView.visible
        } // TibiaHorizontalSeparator

        GridView {
          id: itemsGridView
          visible: count > 0
          Layout.fillWidth: true
          property int expectedHeight: cellHeight * Math.ceil(count / 4.0)
          Layout.minimumHeight: expectedHeight
          cellWidth: 38
          cellHeight: 34

          interactive: false //prevent flick behavior on touch screens
          boundsBehavior: Flickable.StopAtBounds

          model: widgetController != null ? widgetController.displayedItems : null
          delegate: ContainerSlot {
            slotText: itemCountString
            slotTooltip: widgetController != null ? qsTrId(widgetController.translationPrefix + "item_name_and_value").arg(itemName).arg(itemValueString).arg(itemValueForCountString) : ""
            slotBackgroundVisible: false
            objectAppearanceInstanceTypeId: appearanceId
            objectAppearanceInstanceCumulativeCount: itemCount
            objectAppearanceInstanceLiquidType: ObjectAppearanceInstance.EMPTY
            objectAppearanceInstanceHookDirection: ObjectAppearanceInstance.NONE
            mouseAreaEnabled: false
            width: 32
            height: 32
          }
        } // GridView


        TibiaHorizontalSeparator {
          Layout.fillWidth: true
          visible: gauge.visible
        } // TibiaHorizontalSeparator

        RowLayout {
          spacing: TibiaStyle.marginNarrow
          visible: gauge.visible

          TibiaText {
            text: widgetController != null ? qsTrId(widgetController.translationPrefix + "target_value") : qsTrId("dummy_unknown")
          }

          TibiaText {
            text: widgetController != null ? widgetController.gaugeTargetValueString : qsTrId("dummy_unknown")
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
          }

          Image {
            source: "/images/icon-goldcoin.png"
            smooth: false
          }
        } // RowLayout


        TibiaGauge {
          id: gauge
          Layout.fillWidth: true
          currentValue: widgetController != null ? widgetController.gainWastePerHour : 0
          currentValueString: widgetController != null ? widgetController.gainWastePerHourString : ""
          targetValue: widgetController != null ? widgetController.gaugeTargetValue : 0
          targetValueString: widgetController != null ? widgetController.gaugeTargetValueString : ""
          visible: widgetController != null ? widgetController.isGaugeVisible : false
          mirror: widgetController != null && widgetController.isGaugeMirrored

          MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton

            onClicked: {
              if (widgetController != null) {
                widgetController.requestGaugeContextMenu();
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
          Layout.fillWidth: true
          visible: widgetController != null ? widgetController.isGraphVisible : false
          xLabel: qsTrId("minutes")
          yLabel: widgetController != null ? qsTrId(widgetController.translationPrefix + "graph_y") : qsTrId("dummy_unknown")
          xMin: -60
          xMax:   0
          yMin:   0
          yMax: widgetController != null ? widgetController.gainWasteGraphMaxY : 1
          labelCountYAxis: 3
          values: widgetController != null ? widgetController.gainWasteHistory : []

          MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton

            onClicked: {
              if (widgetController != null) {
                widgetController.requestGraphContextMenu();
              }
            } // onClicked
          } // MouseArea
        } // TibiaGraph
      } // ColumnLayout
    } // Flickable
  } //TibiaScrollView


  Lenshelp {
    anchors.fill: parent
    triggerRect: mapFromItem(widgetRoot, 0, 0, widgetRoot.width, widgetRoot.height)
    caption: widgetController != null ? qsTrId(widgetController.translationPrefix + "lenshelp_caption") : qsTrId("dummy_unknown")
    content: widgetController != null ? qsTrId(widgetController.translationPrefix + "lenshelp") : qsTrId("dummy_unknown")
  } //Lenshelp
} // TibiaSidebarWidget
