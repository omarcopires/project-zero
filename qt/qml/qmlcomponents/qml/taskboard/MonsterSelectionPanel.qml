import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtWebChannel
import QtWebEngine

import qmlcomponents
import "qrc:/qt/qml/qmlcomponents/qml/"
import QtQuick.LegacyControls

Item {
  id: root

  required property var monsterList

  property var monstersNameFilter: ""
  property var updateNameFilter: function (searchText) {
    if (monsterList) {
      monsterList.setNameFilter( searchText );
      monstersNameFilter = searchText;
    }
  }

  required property var handleSelection

  TibiaFrame2PixelUpFilled {
    anchors.fill: parent
    anchors.margins: TibiaStyle.marginRelated

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: TibiaStyle.marginUnrelated
      spacing: TibiaStyle.marginUnrelated
      
      TibiaTextSearchField {
        id: nameFilterText

        Layout.preferredHeight: 24
        Layout.fillWidth: true

        maximumLength: TibiaStyle.maxCharacterNameLength
        KeyNavigation.tab: nameFilterText
        KeyNavigation.backtab: nameFilterText
        shouldBeText: monstersNameFilter
        onSearchTextChanged: {
          updateNameFilter(searchText);
        }
      }

      TibiaTableView {
        id: monsterTable
        Layout.fillWidth: true
        Layout.fillHeight: true
        
        model: monsterList
        rowHeight: 36 // TO DO
        selectionMode: SelectionMode.SingleSelection

        property var selectedForFirstTime : true

        selection.onSelectionChanged: {
          if (selectedForFirstTime && selection.count > 0) {
            selection.clear();
          } else {
            selection.forEach(function(rowIndex) {
              handleSelection(model.getRaceIDAtIndex(rowIndex));
            });
          }
          selectedForFirstTime = false;
        } //selection.onSelectionChanged

        function filterSettingsChanged() {
          if (rowCount > 0) {
            positionViewAtRow(0, ListView.Beginning);
          }
        }

        TableViewColumn {
          role: "raceID"
          movable: false
          resizable: false
          width: 197

          delegate: RowLayout {
            property int monsterRaceID: model != null ? model.raceId : 0

            RaceAppearanceInstanceRenderer {
              id: monsterOutfit
              width: 32
              height: 32
              Layout.leftMargin: TibiaStyle.marginNarrow
              raceID: monsterRaceID
              isUnknown: false
            }

            TibiaText {
              text: model != null && model.name.length > 0 ? model.name : qsTrId("dummy_unknown")
              verticalAlignment: Text.AlignVCenter
              Layout.fillWidth: true
              Layout.fillHeight: true
            }
          }
        }
      }
    }
  }
}
