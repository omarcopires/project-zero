import QtQuick
import QtQuick.Layouts

import qmlcomponents



TibiaPanel2PixelUpFilledWithCaption {

  property var controller: null
  property var selectionModel: null
  property int slotNumber: 0
  property int selectedBossRace: 0

  caption: qsTrId("bosstiary_caption_selection_slot").arg(slotNumber)

  ColumnLayout {

  Layout.fillWidth: true


  TibiaFrame1PixelDown {

    Layout.preferredHeight: 281
    Layout.fillWidth: true

    TibiaScrollView {
      id: bossScrollView

      anchors.fill: parent
      anchors.margins: parent.borderWidth

      GridView {
        id: bossList

        leftMargin: TibiaStyle.marginRelated
        topMargin: TibiaStyle.marginRelated
        rightMargin: TibiaStyle.marginRelated
        bottomMargin: TibiaStyle.marginRelated

        boundsBehavior: Flickable.StopAtBounds
        pixelAligned: true
        interactive: false //prevent flick behavior on touch screens

        readonly property int elementWidth: 90
        readonly property int elementHeight: 105
        cellWidth: elementWidth + TibiaStyle.marginNarrow
        cellHeight: elementHeight + TibiaStyle.marginNarrow
        highlightMoveDuration: 0

        footer: Item {
          height: TibiaStyle.marginNarrow
          width: TibiaStyle.marginNarrow
        }

        model: selectionModel

        delegate: MouseArea {
          height: bossList.elementHeight
          width: bossList.elementWidth
          property int bossRace: model != null? model.bossRaceId : 0

          Rectangle {
            color: "transparent"
            border.color: index != bossList.currentIndex ? "transparent" : "white"
            anchors.fill: parent


            TibiaFrame2PixelUpFilledWithCaption {
              id: outfitSelection

              anchors.fill: parent
              anchors.margins: 1

              Image {
                id: iconImage
                source: model != null ? model.bossRaritySource : ""

                anchors { left: parent.left; leftMargin: parent.marginsToContent;
                        top: parent.top; topMargin: parent.topMarginToContent }

                Tooltip {
                  anchors.fill: parent
                  text: model.bossRarityTooltip
                }
              } // Image


              caption: model != null ? model.name : ""
              width: bossList.elementWidth
              height: bossList.elementHeight + iconImage.height

              RaceAppearanceInstanceRenderer {
                width: 64
                height: 64
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: parent.topMarginToContent + TibiaStyle.marginUnrelated

                raceID: model != null? model.bossRaceId : 0
                isUnknown: false


              } // RaceAppearanceInstanceRenderer

            } // TibiaPanel2PixelUpFilledWithCaption

          } // Rectangle
            onClicked: {
              bossList.currentIndex = index;
              selectedBossRace = bossRace;
            } // onClicked

        } // MouseArea


        onCountChanged: {
          selectCurrentItem();
        }

        function selectCurrentItem() {
          if (bossList.model != null) {
            for (var i=0; i < bossList.count; i++) {
              var idx = bossList.model.index(i, 0);
              var value = bossList.model.data(idx, bossList.model.raceIDRoleEnumValue);
              if (value == selectedBossRace) {
                bossList.currentIndex = i;
                return;
              }
            }
          }
          bossList.currentIndex = -1;
          currentIndexChanged(); //make sure that onCurrentIndexChanged is triggered to select the first entry if needed
        }


      } // GridView
    } // TibiaScrollView

  } // TibiaFrame1PixelDown

  TibiaTextSearchField {
    id: outfitSearchField
    shouldBeText: selectionModel.nameFilter

    Layout.fillWidth: true

    onSearchTextChanged: {
      selectionModel.nameFilter = searchText;
      bossList.selectCurrentItem();
    } //onSearchTextChanged
  } // TibiaTextSearchField


  TibiaButton {
    id: selectButton
    text: qsTrId("bosstiary_caption_selection_button")
    enabled: bossList.currentIndex != -1
    visible: true
    Layout.alignment: Qt.AlignRight

    onClicked: {
      if (bossList.currentItem != null) {
        controller.onSelectClicked(slotNumber, bossList.currentItem.bossRace);
      }
    }
  } //TibiaButton

  } // ColumnLayout

} // TibiaPanel2PixelUpFilledWithCaption
