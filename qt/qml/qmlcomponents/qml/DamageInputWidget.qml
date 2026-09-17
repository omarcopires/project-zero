import QtQuick
import QtQuick.Layouts

import qmlcomponents


TibiaSidebarWidget {
  caption: qsTrId("damageinput_caption_short")
  picSource: "/images/skin/classic/icon-defensiveanalyser-widget.png"

  minContentHeight: 50
  initialContentHeight: 220

  customButtonContainerData: [
    TibiaIconButton {
      id: showListButton
      sourceUp:   "/images/skin/classic/button-contextmenu-12x12-idle.png"
      sourceDown: "/images/skin/classic/button-contextmenu-12x12-pressed.png"
      tooltipText: qsTrId("damageinput_options_tooltip")
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
      pixelAligned: true

      ColumnLayout {
        id: contentLayout
        anchors { left: parent.left; right: parent.right }
        anchors.rightMargin: TibiaStyle.marginNarrow
        spacing: TibiaStyle.marginUnrelated

        ColumnLayout {
          Layout.fillWidth: true
          spacing: TibiaStyle.marginRelated

          TibiaText {
            text: qsTrId("damageinput_summary_caption")
            styleType: "WhiteCaption"
          } // TibiaText

          RowLayout {
            spacing: TibiaStyle.marginNarrow
            Layout.fillWidth: true

            TibiaText {
              text: qsTrId("damageinput_total")
            } // TibiaText

            TibiaText {
              text: widgetController != null ? widgetController.totalDamageString : qsTrId("dummy_unknown")
              Layout.fillWidth: true
              horizontalAlignment: Text.AlignRight
            } // TibiaText
          } // RowLayout

          RowLayout {
            spacing: TibiaStyle.marginNarrow
            Layout.fillWidth: true

            TibiaText {
              text: qsTrId("damageinput_maximum")
            } // TibiaText

            TibiaText {
              text: widgetController != null ? widgetController.maxDpsTakenString : qsTrId("dummy_unknown")
              Layout.fillWidth: true
              horizontalAlignment: Text.AlignRight
            } // TibiaText
          } // RowLayout
        } // ColumnLayout

        TibiaHorizontalSeparator {
          Layout.fillWidth: true
          visible: widgetController != null && widgetController.showDamageGraph
        } // TibiaHorizontalSeparator

        TibiaGraph {
          visible: widgetController != null && widgetController.showDamageGraph
          Layout.fillWidth: true
          xLabel: qsTrId("minutes")
          yLabel: qsTrId("damageinput_graph_damage_label")
          xMin: widgetController != null && widgetController.showSessionValues ? -60 : -4
          xMax:   0
          yMin:   0
          yMax:   widgetController != null ? widgetController.damageTakenGraphMaxY : 1
          values: widgetController != null ? widgetController.damageGraphModel : []
        } // TibiaGraph

        TibiaHorizontalSeparator {
          Layout.fillWidth: true
          visible: widgetController != null && widgetController.showDamageTypeList
        } // TibiaHorizontalSeparator

        ColumnLayout {
          Layout.fillWidth: true
          spacing: TibiaStyle.marginRelated
          visible: widgetController != null && widgetController.showDamageTypeList

          TibiaText {
            id: damageTypesHeader
            text: qsTrId("damageinput_damagetype_caption")
            styleType: "WhiteCaption"
          } // TibiaText

          ListView {
            id: damageTypesList
            model: widgetController != null ? widgetController.damageTypesModel : null
            visible: count > 0
            Layout.preferredHeight: count * damageTypesHeader.implicitHeight
            Layout.fillWidth: true
            boundsBehavior: Flickable.StopAtBounds
            interactive: false //prevent flick behavior on touch screens

            delegate: RowLayout {
              spacing: TibiaStyle.marginNarrow
              width: damageTypesList.width

              Image {
                source: model.typeImage

                Tooltip {
                  text: model.typeName
                  anchors.fill: parent
                } // Tooltip
              } // Image

              TibiaText {
                text: qsTrId("damageinput_damage_with_percentage")
                  .arg(model.damageValueString)
                  .arg(model.percentageFromTotalString)
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
              } // TibiaText
            } // delegate: RowLayout
          } // ListView

          TibiaText {
            text: qsTrId("damageinput_nodata")
            Layout.fillWidth: true
            visible: damageTypesList.count == 0
          } // TibiaText
        } // ColumnLayout

        TibiaHorizontalSeparator {
          Layout.fillWidth: true
          visible: widgetController != null && widgetController.showDamageSourceList
        } // TibiaHorizontalSeparator

        ColumnLayout {
          Layout.fillWidth: true
          spacing: TibiaStyle.marginRelated
          visible: widgetController != null && widgetController.showDamageSourceList

          TibiaText {
            id: damageSourceHeader
            text: qsTrId("damageinput_damagesource_caption")
            styleType: "WhiteCaption"
          } // TibiaText

          ListView {
            id: damageSourceList
            model: widgetController != null ? widgetController.damageSourcesModel : null
            visible: count > 0
            Layout.preferredHeight: count * damageSourceHeader.implicitHeight
            Layout.fillWidth: true
            boundsBehavior: Flickable.StopAtBounds
            interactive: false //prevent flick behavior on touch screens

            delegate: RowLayout {
              spacing: TibiaStyle.marginNarrow
              width: damageSourceList.width

              TibiaText {
                text: model.sourceName
                Layout.fillWidth: true

                MouseArea {
                  anchors.fill: parent
                  acceptedButtons: Qt.LeftButton
                  hoverEnabled: true

                  onEntered: {
                    if (tibiaMouseCursorController != null) {
                      tibiaMouseCursorController.setPointingHand(true);
                    }
                  } // onEntered

                  onExited: {
                    if (tibiaMouseCursorController != null) {
                      tibiaMouseCursorController.setPointingHand(false);
                    }
                  } // onExited

                  onClicked: {
                    if (widgetController) {
                      widgetController.onDamageSourceDetailsRequested(model.sourceName);
                    }
                  } // onClicked
                } // MouseArea
              } // TibiaText

              TibiaText {
                text: qsTrId("damageinput_damage_percentage_only")
                  .arg(model.percentageFromTotalString)
                tooltipText: qsTrId("damageinput_damage_absolute").arg(model.damageValueString)
              } // TibiaText
            } // delegate: RowLayout
          } // ListView

          TibiaText {
            text: qsTrId("damageinput_nodata")
            Layout.fillWidth: true
            visible: damageSourceList.count == 0
          } // TibiaText
        } // ColumnLayout

        TibiaHorizontalSeparator {
          Layout.fillWidth: true
          visible: widgetController != null && widgetController.showDamageSourceList && detailedSourceDamageTypes.count > 0
        } // TibiaHorizontalSeparator

        ColumnLayout {
          Layout.fillWidth: true
          spacing: TibiaStyle.marginRelated
          visible: widgetController != null && widgetController.showDamageSourceList && detailedSourceDamageTypes.count > 0

          TibiaText {
            id: detailedSourceDamageTypesHeader
            text: widgetController != null ? widgetController.detailedDamageSource : qsTrId("dummy_unknown")
            styleType: "WhiteCaption"
            Layout.fillWidth: true

            MouseArea {
              anchors.fill: parent
              acceptedButtons: Qt.LeftButton
              hoverEnabled: true

              onEntered: {
                if (tibiaMouseCursorController != null) {
                  tibiaMouseCursorController.setPointingHand(true);
                }
              } // onEntered

              onExited: {
                if (tibiaMouseCursorController != null) {
                  tibiaMouseCursorController.setPointingHand(false);
                }
              } // onExited

              onClicked: {
                if (widgetController) {
                  widgetController.onDamageSourceDetailsRequested("");
                }
              } // onClicked
            } // MouseArea
          } // TibiaText

          ListView {
            id: detailedSourceDamageTypes
            model: widgetController != null ? widgetController.damageTypesFromSourceModel : null
            visible: count > 0
            Layout.preferredHeight: count * detailedSourceDamageTypesHeader.implicitHeight
            Layout.fillWidth: true
            boundsBehavior: Flickable.StopAtBounds
            interactive: false //prevent flick behavior on touch screens

            delegate: RowLayout {
              spacing: TibiaStyle.marginNarrow
              width: detailedSourceDamageTypes.width

              Image {
                source: model.typeImage

                Tooltip {
                  text: model.typeName
                  anchors.fill: parent
                } // Tooltip
              } // Image

              TibiaText {
                text: qsTrId("damageinput_damage_with_percentage")
                  .arg(model.damageValueString)
                  .arg(model.percentageFromTotalString)
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
              } // TibiaText
            } // delegate: RowLayout
          } // ListView
        } // ColumnLayout

        Item {
          id: footer
          Layout.fillWidth: true
        } //Item

      } //ColumnLayout
    } //Flickable
  } //TibiaScrollView


  Lenshelp {
    anchors.fill: parent
    triggerRect: mapFromItem(widgetRoot, 0, 0, widgetRoot.width, widgetRoot.height)
    caption: qsTrId("damageinput_caption")
    content: qsTrId("damageinput_lenshelp")
  } //Lenshelp
} // TibiaSidebarWidget
