import QtQuick
import QtQuick.Layouts

import qmlcomponents



TibiaSidebarWidget {
  caption: qsTrId("partyhunt_caption")
  picSource: "/images/skin/classic/icon-partyhunt-widget.png"

  minContentHeight: TibiaStyle.widgetWithScrollBarMinContentHeight

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
      contentHeight: contentLayout.height

      interactive: false //prevent flick behavior on touch screens
      boundsBehavior: Flickable.StopAtBounds
      pixelAligned: true

      ColumnLayout {
        id: contentLayout
        anchors { left: parent.left; top: parent.top; right: parent.right; }
        anchors.margins: TibiaStyle.marginNarrow

        RowLayout {
          spacing: TibiaStyle.marginRelated

          TibiaText {
            text: qsTrId("huntinganalyser_sessionlength") + ":"
          } //TibiaText

          TibiaText {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
            text: widgetController != null ? widgetController.sessionLengthString : qsTrId("dummy_unknown")
          } //TibiaText
        } // RowLayout

        RowLayout {
          spacing: TibiaStyle.marginRelated

          TibiaText {
            text: qsTrId("partyhunt_loot_type_label") + ":"
          } //TibiaText

          TibiaText {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
            text: widgetController != null ? widgetController.lootTypeString : qsTrId("dummy_unknown")
          } //TibiaText
        } // RowLayout

        GridLayout {
          anchors.margins: TibiaStyle.marginNarrow
          columnSpacing: TibiaStyle.marginNarrow
          rowSpacing: TibiaStyle.marginRelated
          columns: 2

          TibiaText {
            text: qsTrId("huntinganalyser_gain") + ":"
          } //TibiaText

          RowLayout {
            spacing: TibiaStyle.marginNarrow
            TibiaText {
              Layout.fillWidth: true
              horizontalAlignment: Text.AlignRight
              text: TextHelper.formatNumberWithThousandSeparatorsAndThousandShortcutsAsMultiString(widgetController != null ? widgetController.totalGain : 0)
            } //TibiaText

            Image {
              source: "/images/icon-goldcoin.png"
              smooth: false
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
              text: TextHelper.formatNumberWithThousandSeparatorsAndThousandShortcutsAsMultiString(widgetController != null ? widgetController.totalWaste : 0)
            } //TibiaText

            Image {
              source: "/images/icon-goldcoin.png"
              smooth: false
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
              text: TextHelper.formatNumberWithThousandSeparatorsAndThousandShortcutsAsMultiString(widgetController != null ? widgetController.totalBalance : 0)
              styleType: widgetController != null && widgetController.totalBalance >= 0 ? "ModifierPositive" : "ModifierNegative"
            } //TibiaText

            Image {
              source: "/images/icon-goldcoin.png"
              smooth: false
            } //Image
          } //RowLayout
        } //GridLayout

        TibiaHorizontalSeparator {
          Layout.fillWidth: true
          Layout.leftMargin: TibiaStyle.marginRelated
          Layout.rightMargin: TibiaStyle.marginRelated
        } //TibiaHorizontalSeparator

        ListView {
          id: partyDataListView
          Layout.fillWidth: true

          Layout.preferredHeight: contentHeight

          model: widgetController != null ? widgetController.partyMemberModel : null

          boundsBehavior: Flickable.StopAtBounds
          interactive: false //prevent flick behavior on touch screens

          delegate: ColumnLayout {
            width: partyDataListView.width
            spacing: TibiaStyle.marginRelated

            RowLayout {
              Layout.fillWidth: true
              spacing: TibiaStyle.marginNarrow

              Image {
                visible: model.isLeader
                source: "image://creaturestateflags-party/3"
                smooth: false
              } //Image

              TibiaText {
                Layout.fillWidth: true
                styleType: !model.isInParty ? "Disabled" : model.isLeader ? "PartyLeader" : "Dialog"
                text: model.name

                Tooltip {
                  anchors.fill: parent
                  visible: model.characterID == 0 //entryID for members over limit
                  text: qsTrId("partyhunt_over_limit_tooltip")
                } //Tooltip
              } //TibiaText
            } //RowLayout

            RowLayout {
              Layout.fillWidth: true
              Layout.leftMargin: TibiaStyle.marginRelated
              spacing: TibiaStyle.marginNarrow

              Image {
                source: "/images/skin/classic/icon-balance.png"
                smooth: false
                Tooltip {
                  anchors.fill: parent
                  text: qsTrId("partyhunt_balance_tooltip")
                } //Tooltip
              } //Image

              TibiaText {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                text: TextHelper.formatNumberWithThousandSeparatorsAndThousandShortcutsAsMultiString(model.balance)
                styleType: !model.isInParty ? "Disabled" : model.balance >= 0 ? "ModifierPositive" : "ModifierNegative"
                Tooltip {
                  anchors.fill: parent
                  text: qsTrId("partyhunt_balance_details_tooltip").arg(TextHelper.formatNumberWithThousandSeparators(model.gain))
                                                                   .arg(TextHelper.formatNumberWithThousandSeparators(model.waste))
                                                                   .arg(TextHelper.formatNumberWithThousandSeparators(model.balance))
                } //Tooltip
              } //TibiaText

              Image {
                source: "/images/icon-goldcoin.png"
                smooth: false
              } //Image
            } //RowLayout

            RowLayout {
              Layout.fillWidth: true
              Layout.leftMargin: TibiaStyle.marginRelated
              spacing: TibiaStyle.marginNarrow

              Image {
                source: "/images/skin/classic/icon-damage.png"
                smooth: false
                Tooltip {
                  anchors.fill: parent
                  text: qsTrId("damage")
                } //Tooltip
              } //Image

              TibiaText {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                text: TextHelper.formatNumberWithThousandSeparatorsAndThousandShortcutsAsMultiString(model.damage)
                styleType: !model.isInParty ? "Disabled" : "Dialog"
              } //TibiaText
            } //RowLayout

            RowLayout {
              Layout.fillWidth: true
              Layout.leftMargin: TibiaStyle.marginRelated
              spacing: TibiaStyle.marginNarrow

              Image {
                source: "/images/skin/classic/icon-healing.png"
                smooth: false
                Tooltip {
                  anchors.fill: parent
                  text: qsTrId("healing")
                } //Tooltip
              } //Image

              TibiaText {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                text: TextHelper.formatNumberWithThousandSeparatorsAndThousandShortcutsAsMultiString(model.healing)
                styleType: !model.isInParty ? "Disabled" : "Dialog"
              } //TibiaText
            } //RowLayout
          } //delegate: ColumnLayout
        } //ListView
      } // ColumnLayout
    } // Flickable
  } // TibiaScrollView

  Lenshelp {
    anchors.fill: parent
    triggerRect: mapFromItem(widgetRoot, 0, 0, widgetRoot.width, widgetRoot.height)
    caption: qsTrId("partyhunt_lenshelp_caption")
    content: qsTrId("partyhunt_lenshelp")
  } //Lenshelp

} // TibiaSidebarWidget
