import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QtQuick.LegacyControls


TibiaDialog {
  id: mccDialog
  caption: qsTrId("maincharacterchange_caption")
  width: 650

  property var controller: null
  property int currentPage: 1

  onReturnPressedFunction: function() {
    if (okButton.enabled) {
      if (controller && mainCharactersTable.selectedCharacter != "") {
        controller.requestMainCharChange(mainCharactersTable.selectedCharacter);
      }
    }
  }

  onCancelPressedFunction: function() {
    if (controller != null) {
      controller.requestClose();
    }
  }

  initialFocusItem: mccDialog
  KeyNavigation.tab: mccDialog

  ColumnLayout {
    anchors { left: parent.left; right: parent.right}
    spacing: TibiaStyle.marginUnrelated

    TibiaTableView {

        id: mainCharactersTable
        Layout.fillWidth: true
        Layout.preferredHeight: 200
        property bool selectedForFirstTime: true
        onModelChanged: {
          selectedForFirstTime = true;
        } //onModelChanged
        property string selectedCharacter: ""

        model: controller != null ? controller.mainCharInfos : null
        visible: rowCount > 0

        headerVisible: true
        verticalScrollBarPolicy: ScrollBar.AlwaysOn
        horizontalScrollBarPolicy: ScrollBar.AsNeeded
        selectionMode: SelectionMode.SingleSelection

        TableViewColumn {
          role: "characterName"
          title: qsTrId("character")
          movable: false
          resizable: false
          width: mainCharactersTable.contentItem.width - columnLevel.width
                                           - columnVocation.width
                                           - columnWorld.width

        } // TableViewColumn

        TableViewColumn {
          id: columnWorld
          role: "worldName"
          title: qsTrId("maincharacterchange_column_world")
          movable: false
          resizable: false
          width: 150
        } // TableViewColumn

        TableViewColumn {
          id: columnVocation
          role: "vocation"
          title: qsTrId("vocation")
          movable: false
          resizable: false
          width: 115
        } // TableViewColumn

        TableViewColumn {
          id: columnLevel
          role: "level"
          title: qsTrId("level")
          movable: false
          resizable: false
          width: 45
        } // TableViewColumn

        selection.onSelectionChanged: {
          if (selectedForFirstTime && selection.count > 0) {
            selection.clear();
          } else {
            selectedCharacter = "";
            selection.forEach(function(rowIndex) {
              selectedCharacter = model[rowIndex].characterName;
            });
          }
          selectedForFirstTime = false;
        } //selection.onSelectionChanged

      } // TibiaTableView


      TibiaText {
        Layout.alignment: Qt.AlignCenter
        visible: !mainCharactersTable.visible
        text: qsTrId("maincharacterchange_message_nocharacteravailable")
      }

      TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } // TibiaHorizontalSeparator


    RowLayout {
      spacing: TibiaStyle.marginUnrelated

      Item {
        Layout.fillWidth: true
      } // Item


      TibiaButton {
        id: okButton
        text: qsTrId("store_buy_now")
        color: enabled ? "blue" : "grey"
        textStyle: "Default"
        enabled: controller != null && mainCharactersTable.selectedCharacter != ""
        Layout.preferredWidth: TibiaStyle.buttonWidthBroad
        visible: mainCharactersTable.visible

        onClicked: {
          onReturnPressedFunction();
        }
      } // TibiaButton

      TibiaButton {
        id: cancelButton
        text: qsTrId("cancel")
        Layout.preferredWidth: TibiaStyle.buttonWidthBroad

        onClicked: {
          onCancelPressedFunction();
        }
      } // TibiaButton
    } // RowLayout

  }// ColumnLayout
} // TibiaDialog
