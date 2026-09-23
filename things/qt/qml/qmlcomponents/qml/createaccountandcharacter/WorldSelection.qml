import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtWebChannel
import QtWebEngine

import qmlcomponents
import "qrc:/qt/qml/qmlcomponents/qml/"
import QtQuick.LegacyControls


TibiaPanel2PixelUpFilledWithCaption {
  id: root

  property var worldsModel: null
  
  property var selectedWorldIndex : null
  property string selectedWorldName :
    (worldsModel != null) && (selectedWorldIndex != null) ? worldsModel.worldName(selectedWorldIndex) : ""
  property var selectedWorldPlayersOnline :
    (worldsModel != null) && (selectedWorldIndex != null) ? worldsModel.playersOnline(selectedWorldIndex) : 0    
  property var selectedWorldPvPType :
    (worldsModel != null) && (selectedWorldIndex != null) ? worldsModel.worldPvPType(selectedWorldIndex) : ""
  property var selectedWorldRegion :
    (worldsModel != null) && (selectedWorldIndex != null) ? worldsModel.worldRegion(selectedWorldIndex) : ""
  property var selectedWorldCreationDate :
    (worldsModel != null) && (selectedWorldIndex != null) ? worldsModel.worldCreationDate(selectedWorldIndex) : ""
  property var selectedWorldBattleEyeStatus :
    (worldsModel != null) && (selectedWorldIndex != null) ? worldsModel.worldBattleEyeStatus(selectedWorldIndex) : ""
  property var selectedWorldPremiumOnly :
    (worldsModel != null) && (selectedWorldIndex != null) ? worldsModel.worldPremiumOnly(selectedWorldIndex) : false
  property var selectedWorldTransferType :
  (worldsModel != null) && (selectedWorldIndex != null) ? worldsModel.worldTransferType(selectedWorldIndex) : ""

  caption: qsTrId("create_account_dialog_select_a_game_world")
  Layout.fillWidth: true
  Layout.fillHeight: true

  function getPvPTypeHelp( PvPType )
  {
    if (PvPType == "Optional PvP" ) return qsTrId("create_account_dialog_optional_pvp_help");
    if (PvPType == "Open PvP") return qsTrId("create_account_dialog_open_pvp_help");
    if (PvPType == "Hardcore PvP") return qsTrId("create_account_dialog_hardcore_pvp_help");
    if (PvPType == "Retro Open PvP") return qsTrId("create_account_dialog_retro_open_pvp_help");
    if (PvPType == "Retro Hardcore PvP") return qsTrId("create_account_dialog_retro_hardcore_pvp_help");

    return "unknown pvptype: " + PvPType;
  }

  ColumnLayout {
    spacing: TibiaStyle.marginUnrelated
    Layout.fillHeight: true

    RowLayout {
      spacing: TibiaStyle.marginRelated

      TibiaText {
        text: qsTrId("create_account_dialog_world_region_label")
      }

      TibiaComboBox {
        id: regionFilterComboBox
        textRole: "text"
        valueRole: "value"
        Layout.fillWidth: true
        model: worldsModel.worldRegionFilterModel

        onActivated: (index) => {
          worldsModel.worldRegionFilter = currentValue 
        }
      }

      Item {
        Layout.fillWidth: true
      }

      TibiaText {
        text: qsTrId("create_account_dialog_pvp_type_label")
      }

      TibiaComboBox {
        textRole: "text"
        valueRole: "value"
        id: worldTypeFilterComboBox
        Layout.fillWidth: true
        model: worldsModel.worldPvPTypeFilterModel

        onActivated: (index) => {
          worldsModel.worldPvPTypeFilter = currentValue
        }
      } //TibiaComboBox
    } //RowLayout

    RowLayout {
      spacing: TibiaStyle.marginRelated

    TibiaTableView {
      id: worldSelectionView
      Layout.fillHeight: true
      Layout.preferredWidth: 140
      model: worldsModel
      selectionMode: SelectionMode.SingleSelection
      
      Connections {
        target: worldsModel
        function onFilterChanged() {

          let lastSelectedWorldName = selectedWorldName          
          selectedWorldIndex = null
          worldSelectionView.selection.clear()
          worldSelectionView.currentRow = -1
        }
      } 

      onModelChanged: {
        if (model.rowCount() > 0) {
          currentRow = 0;
        }
      }

      selection.onSelectionChanged: {
        selection.forEach(function(rowIndex) {
          selectedWorldIndex = model.index(rowIndex, 0)
          currentRow = rowIndex
        });
      }

      TableViewColumn {
        id: worldname
        movable: false
        resizable: false
        role: "WorldName"
      } //TableViewColumn
    } //TibiaTableView

      TibiaPanel2PixelUpFilledWithCaption {
        id: worldInformationPanel
        Layout.fillWidth: true
        Layout.fillHeight: true
        caption: (selectedWorldIndex != null)
          ? ((selectedWorldName == worldsModel.recommendedWorld) ?
              selectedWorldName + " " + qsTrId("world_selection_recommended_suffix") 
              : selectedWorldName)
          : "No world selected."

        TibiaText {
          id: selectAWorldHintText
          Layout.fillWidth: true
          Layout.preferredHeight: 48
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          visible: selectedWorldIndex == null
          text: qsTrId("create_account_dialog_select_a_world_text")
        } //TibiaText

        GridLayout {
          Layout.fillWidth: true
          Layout.fillHeight: true
          columns: 3
          columnSpacing: TibiaStyle.marginRelated
          rowSpacing: TibiaStyle.marginRelated

          visible: selectedWorldIndex != null

          TibiaText { text: qsTrId("create_account_dialog_players_online_label") }
          TibiaText { text: selectedWorldPlayersOnline }
          Item { Layout.fillWidth: true }

          TibiaText { text: qsTrId("create_account_dialog_pvp_type_label") }
          TibiaText { text: selectedWorldPvPType }

          RowLayout {
            spacing: 0

            Item {
              Layout.fillWidth: true
            }
            TibiaGuiHelp {
              id: pvptypehelp
              text: getPvPTypeHelp(selectedWorldPvPType)
            }
          } //RowLayout

          TibiaText { text: qsTrId("create_account_dialog_world_region_label") }
          TibiaText { text: selectedWorldRegion }
          Item { Layout.fillWidth: true }

          TibiaText { text: qsTrId("create_account_dialog_creation_date_label") }
          TibiaText { text: selectedWorldCreationDate }
          Item { Layout.fillWidth: true }

          TibiaText { text: qsTrId("create_account_dialog_battle_eye_status_label") }
          TibiaText { text: selectedWorldBattleEyeStatus }

          RowLayout {
            spacing: 0

            Item {
              Layout.fillWidth: true
            }
            TibiaGuiHelp { text: qsTrId("create_account_dialog_battle_eye_status_help") }
          }

          TibiaText { text: qsTrId("create_account_dialog_premium_only_label") }
          TibiaText { text: selectedWorldPremiumOnly }

          RowLayout {
            spacing: 0

            Item {
              Layout.fillWidth: true
            }

            TibiaGuiHelp {
              visible: selectedWorldPremiumOnly
              text: qsTrId("create_account_dialog_premium_only_help")
            }
          }

          TibiaText { text: qsTrId("create_account_dialog_transfer_type_label") }
          TibiaText { text: selectedWorldTransferType}

          RowLayout {
            spacing: 0

            Item {
              Layout.fillWidth: true
            }

            TibiaGuiHelp {
              text: qsTrId("create_account_dialog_transfer_types_help")
            } //TibiaGuiHelp
          } //RowLayout
        } //GridLayout
      } //TibiaPanel2PixelUpFilledWithCaption
    } //RowLayout
  } //ColumnLayout
} //TibiaPanel2PixelUpFilledWithCaption

