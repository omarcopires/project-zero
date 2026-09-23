import QtQuick
import QtQuick.Layouts

import qmlcomponents


TibiaSidebarWidget {
  caption: qsTrId("impact_caption")
  picSource: "/images/skin/classic/icon-impactanalyser-widget.png"

  minContentHeight: 93
  initialContentHeight: 508

  customButtonContainerData: [
    TibiaIconButton {
      id: showListButton
      sourceUp:   "/images/skin/classic/button-contextmenu-12x12-idle.png"
      sourceDown: "/images/skin/classic/button-contextmenu-12x12-pressed.png"
      tooltipText: qsTrId("impact_options_tooltip")
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

        ImpactView {
          id: damgeView
          Layout.fillWidth: true

          abbreviation: "dps"
          caption: qsTrId("damage")

          gaugeVisible:                widgetController != null && widgetController.isDpsGaugeVisible
          impactSum:                   widgetController != null ? widgetController.damageSumString : "0"
          impactPerSecond:             widgetController != null ? widgetController.damagePerSecond : 0.0
          impactPerSecondString:       widgetController != null ? widgetController.dpsString : "0"
          maxImpactPerSecond:          widgetController != null ? widgetController.maxDpsString : "0"
          allTimeMaxImpact:            widgetController != null ? widgetController.damageAllTimeMaxString : "0"
          targetImpactPerSecond:       widgetController != null ? widgetController.dpsTargetValue : 100.0
          targetImpactPerSecondString: widgetController != null ? widgetController.dpsTargetValueString : "0"

          graphVisible: widgetController != null && widgetController.isDpsGraphVisible
          graphYMax:    widgetController != null ? widgetController.dpsGraphMaxY : 1.0
          graphValues:  widgetController != null ? widgetController.dpsGraphData :[]

          showSessionValues: widgetController != null && widgetController.showSessionValues

          onRequestGaugeContextMenu: widgetController != null ? widgetController.onShowDpsGaugeContextMenu() : undefinded
          onRequestGraphContextMenu: widgetController != null ? widgetController.onShowDpsGraphContextMenu() : undefinded
        } //ImpactView

        TibiaHorizontalSeparator {
          Layout.fillWidth: true
          visible: damageTypesLayout.visible
        } //TibiaHorizontalSeparator

        ColumnLayout {
          id: damageTypesLayout
          spacing: TibiaStyle.marginRelated
          visible: widgetController != null && widgetController.isDamageTypesVisible

          TibiaText {
            id: typedCaptionHeaderText
            text: qsTrId("impact_typed_damage_caption")
            styleType: "WhiteCaption"
          } // TibiaText

          ListView {
            id: typedDamageList
            model: widgetController != null ? widgetController.typedDamageModel : null
            visible: count > 0
            Layout.preferredHeight: count * typedCaptionHeaderText.implicitHeight
            Layout.fillWidth: true
            boundsBehavior: Flickable.StopAtBounds
            interactive: false //prevent flick behavior on touch screens

            delegate: RowLayout {
              width: typedDamageList.width

              Image {
                source: model.typeImage

                Tooltip {
                  anchors.fill: parent
                  text: model.typeName
                } // Tooltip
              } // Image

              TibiaText {
                text: qsTrId("impact_typed_damage").arg(model.valueString).arg(model.percentageFromTotalString)
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
              } // TibiaText
            } // delegate: RowLayout
          } // ListView

          TibiaText {
            text: qsTrId("impact_typed_no_data")
            Layout.fillWidth: true
            visible: typedDamageList.count == 0
          } // TibiaText
        } // ColumnLayout

        TibiaHorizontalSeparator {
          Layout.fillWidth: true
        } //TibiaHorizontalSeparator

        ImpactView {
          id: healingView
          Layout.fillWidth: true

          abbreviation: "hps"
          caption: qsTrId("healing")

          gaugeVisible:                widgetController != null && widgetController.isHpsGaugeVisible
          impactSum:                   widgetController != null ? widgetController.healingSumString : "0"
          impactPerSecond:             widgetController != null ? widgetController.healingPerSecond : 0.0
          impactPerSecondString:       widgetController != null ? widgetController.hpsString : "0"
          maxImpactPerSecond:          widgetController != null ? widgetController.maxHpsString : "0"
          allTimeMaxImpact:            widgetController != null ? widgetController.healingAllTimeMaxString : "0"
          targetImpactPerSecond:       widgetController != null ? widgetController.hpsTargetValue : 100.0
          targetImpactPerSecondString: widgetController != null ? widgetController.hpsTargetValueString : "0"

          graphVisible: widgetController != null && widgetController.isHpsGraphVisible
          graphYMax:    widgetController != null ? widgetController.hpsGraphMaxY : 1.0
          graphValues:  widgetController != null ? widgetController.hpsGraphData :[]

          showSessionValues: widgetController != null && widgetController.showSessionValues

          onRequestGaugeContextMenu: widgetController != null ? widgetController.onShowHpsGaugeContextMenu() : undefinded
          onRequestGraphContextMenu: widgetController != null ? widgetController.onShowHpsGraphContextMenu() : undefinded
        } //ImpactView

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
    caption: qsTrId("impact_caption")
    content: qsTrId("impact_lenshelp")
  } //Lenshelp
} // TibiaSidebarWidget
