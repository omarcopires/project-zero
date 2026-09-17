import QtQuick
import QtQuick.Layouts

import qmlcomponents



TibiaSidebarWidget {
  caption: qsTrId("huntinganalyser_caption")
  picSource: "/images/skin/classic/icon-huntingsessionanalyser-widget.png"

  minContentHeight: TibiaStyle.widgetWithScrollBarMinContentHeight

  property bool showBaseXpData: widgetController != null && widgetController.showBaseXp

  customButtonContainerData: [
    TibiaIconButton {
      id: showListButton
      sourceUp:   "/images/skin/classic/button-contextmenu-12x12-idle.png"
      sourceDown: "/images/skin/classic/button-contextmenu-12x12-pressed.png"
      tooltipText: widgetController != null ? qsTrId("huntinganalyser_options_tooltip") : qsTrId("dummy_unknown")
      onClicked:  widgetController != null ? widgetController.requestConfigurationContextMenu() : undefined
    } //TibiaIconButton
  ] //customButtonContainerData

  TibiaScrollView {
    id: scrollView
    anchors.fill: parent

    Flickable {
      contentHeight: upperListLayout.height + killedMonsters.contentHeight + lootedItemsHeader.contentHeight + lootedItems.contentHeight + TibiaStyle.marginRelated * 3

      interactive: false //prevent flick behavior on touch screens
      boundsBehavior: Flickable.StopAtBounds
      pixelAligned: true

      GridLayout {
        id: upperListLayout
        anchors { left: parent.left; top: parent.top; right: parent.right; }
        anchors.margins: TibiaStyle.marginNarrow
        columnSpacing: TibiaStyle.marginNarrow
        rowSpacing: TibiaStyle.marginRelated
        columns: 2

        TibiaText {
          text: qsTrId("huntinganalyser_sessionlength") + ":"
        } //TibiaText

        TibiaText {
          Layout.fillWidth: true
          horizontalAlignment: Text.AlignRight
          text: widgetController != null ? widgetController.sessionLengthString : qsTrId("dummy_unknown")
        } //TibiaText

        TibiaText {
          text: qsTrId("huntinganalyser_base_xpgain") + ":"
          visible: showBaseXpData
        } //TibiaText

        TibiaText {
          Layout.fillWidth: true
          horizontalAlignment: Text.AlignRight
          text: widgetController != null ? widgetController.baseAccumulatedXpString : qsTrId("dummy_unknown")
          visible: showBaseXpData
        } //TibiaText

        TibiaText {
          text: qsTrId("huntinganalyser_xpgain") + ":"
        } //TibiaText

        TibiaText {
          Layout.fillWidth: true
          horizontalAlignment: Text.AlignRight
          text: widgetController != null ? widgetController.accumulatedXpString : qsTrId("dummy_unknown")
        } //TibiaText

        TibiaText {
          text: qsTrId("huntinganalyser_base_xp_per_hour") + ":"
          visible: showBaseXpData
        } //TibiaText

        TibiaText {
          Layout.fillWidth: true
          horizontalAlignment: Text.AlignRight
          text: widgetController != null ? widgetController.baseXpPerHourString : qsTrId("dummy_unknown")
          visible: showBaseXpData
        } //TibiaText

        TibiaText {
          text: qsTrId("huntinganalyser_xp_per_hour") + ":"
        } //TibiaText

        TibiaText {
          Layout.fillWidth: true
          horizontalAlignment: Text.AlignRight
          text: widgetController != null ? widgetController.xpPerHourString : qsTrId("dummy_unknown")
        } //TibiaText

        TibiaText {
          text: qsTrId("huntinganalyser_gain") + ":"
        } //TibiaText

        RowLayout {
          spacing: TibiaStyle.marginNarrow
          TibiaText {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
            text: widgetController != null ? widgetController.gainString : qsTrId("dummy_unknown")
          } //TibiaText

          Image {
            source: "/images/icon-goldcoin.png"
          } //Image
        } //RowLayout

        TibiaText {
          text: qsTrId("huntinganalyser_waste") + ":"
        } //TibiaText

        RowLayout {
          spacing: TibiaStyle.marginNarrow
          TibiaText {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
            text: widgetController != null ? widgetController.wasteString : qsTrId("dummy_unknown")
          } //TibiaText

          Image {
            source: "/images/icon-goldcoin.png"
          } //Image
        } //RowLayout

        TibiaText {
          text: qsTrId("huntinganalyser_gain_waste_sum") + ":"
        } //TibiaText

        RowLayout {
          spacing: TibiaStyle.marginNarrow
          TibiaText {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
            text: widgetController != null ? widgetController.gainWasteSumString : qsTrId("dummy_unknown")
            color: widgetController != null && widgetController.gainWasteSum >= 0 ? TibiaStyle.textColors["ModifierPositive"] : TibiaStyle.textColors["ModifierNegative"]
          } //TibiaText

          Image {
            source: "/images/icon-goldcoin.png"
          } //Image
        } //RowLayout

        TibiaText {
          text: qsTrId("damage") + ":"
        } //TibiaText

        TibiaText {
          Layout.fillWidth: true
          horizontalAlignment: Text.AlignRight
          text: widgetController != null ? widgetController.damageString : qsTrId("dummy_unknown")
        } //TibiaText

        TibiaText {
          text: qsTrId("huntinganalyser_dph") + ":"
        } //TibiaText

        TibiaText {
          Layout.fillWidth: true
          horizontalAlignment: Text.AlignRight
          text: widgetController != null ? widgetController.damagePerHourString : qsTrId("dummy_unknown")
        } //TibiaText

        TibiaText {
          text: qsTrId("healing") + ":"
        } //TibiaText

        TibiaText {
          Layout.fillWidth: true
          horizontalAlignment: Text.AlignRight
          text: widgetController != null ? widgetController.healingString : qsTrId("dummy_unknown")
        } //TibiaText

        TibiaText {
          text: qsTrId("huntinganalyser_hph") + ":"
        } //TibiaText

        TibiaText {
          Layout.fillWidth: true
          horizontalAlignment: Text.AlignRight
          text: widgetController != null ? widgetController.healingPerHourString : qsTrId("dummy_unknown")
        } //TibiaText

        TibiaText {
          Layout.columnSpan: 2
          text: qsTrId("huntinganalyser_killed_monsters") + ":"
        } //TibiaText
      } //GridLayout

      ListView {
        id: killedMonsters
        model: widgetController != null && widgetController.killedMonsters.length > 0
          ? widgetController.killedMonsters : [ qsTrId("subentry_prefix").arg(qsTrId("huntinganalyser_no_kills")) ]
        anchors { left: parent.left; leftMargin: TibiaStyle.marginNarrow; right: parent.right; rightMargin: TibiaStyle.marginNarrow;
                  top: upperListLayout.bottom; topMargin: TibiaStyle.marginRelated; }
        height: contentItem.height

        interactive: false //prevent flick behavior on touch screens
        boundsBehavior: Flickable.StopAtBounds

        delegate: TibiaText {
          text: modelData
          height: implicitHeight
          anchors { left: parent.left; right: parent.right }
        }
      } // ListView

      TibiaText {
        id: lootedItemsHeader
        text: qsTrId("huntinganalyser_looted_items") + ":"
        anchors { left: parent.left; leftMargin: TibiaStyle.marginNarrow; right: parent.right; rightMargin: TibiaStyle.marginNarrow;
                  top: killedMonsters.bottom; topMargin: TibiaStyle.marginRelated; }
      }

      ListView {
        id: lootedItems
        model: widgetController != null && widgetController.lootedItems.length > 0
          ? widgetController.lootedItems : [ qsTrId("subentry_prefix").arg(qsTrId("huntinganalyser_no_loot")) ]
        anchors { left: parent.left; leftMargin: TibiaStyle.marginNarrow; right: parent.right; rightMargin: TibiaStyle.marginNarrow;
                  top: lootedItemsHeader.bottom; topMargin: TibiaStyle.marginRelated; }
        height: contentItem.height

        interactive: false //prevent flick behavior on touch screens
        boundsBehavior: Flickable.StopAtBounds

        delegate: TibiaText {
          text: modelData
          height: implicitHeight
          anchors { left: parent.left; right: parent.right }
        }
      } // ListView
    } // Flickable
  } // TibiaScrollView

  Lenshelp {
    anchors.fill: parent
    triggerRect: mapFromItem(widgetRoot, 0, 0, widgetRoot.width, widgetRoot.height)
    caption: qsTrId("huntinganalyser_lenshelp_caption")
    content: qsTrId("huntinganalyser_lenshelp")
  } //Lenshelp

} // TibiaSidebarWidget
