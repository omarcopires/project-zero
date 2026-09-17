import QtQuick
import QtQuick.Layouts

import qmlcomponents

import "qrc:/qt/qml/qmlcomponents/qml"
import "outfitdialog.js" as Logic

TibiaScrollView {
  id: outfitsScrollView
  property var _model: null
  property var _helperModel: null
  property bool useOtherGender: false
  property var currentModelData: null
  property int selectedPresetIndex: -1
  property var selectedPreset: null

  property OutfitPreset _tempOutfitPreset: TibiaObjects.outfitPreset()

  signal presetSelected()

  function setModel(model, index) {
    if (model != _model) {
      _model = model;
      let oldContentY = outfitsMountsList.contentY;
      if (model) {
        _helperModel = AbstractItemModelHelper.wrapInHelperProxyModel(model);
      } else {
        _helperModel = null;
      }
      outfitsMountsList.contentY = oldContentY;
    }
    if (index != -1) {
      outfitsMountsList.currentIndex = index;
      selectedPresetIndex = index;
    } else {
      outfitsMountsList.currentIndex = -1;
      selectedPresetIndex = -1;
    }
  }

  function selectPreset(index) {
    selectedPresetIndex = index;
    outfitsMountsList.currentIndex = index;
    Qt.callLater(function() {
      if (_helperModel != null && outfitsMountsList.currentIndex != -1) {
        let preset = TibiaObjects.outfitPreset();
        preset.fromJsonObject(_helperModel.sourceItemDataByRowIndex(outfitsMountsList.currentIndex).jsondata);
        Logic.fixOutfitColors(preset.outfitColor);
        Logic.fixOutfitColors(preset.mountColor);
        selectedPreset = preset;
        selectedPresetIndex = outfitsMountsList.currentIndex;
      } else {
        selectedPreset = null;
        selectedPresetIndex = -1;
      }
      presetSelected();
    });
  }

  GridView {
    id: outfitsMountsList

    leftMargin: TibiaStyle.marginNarrow
    topMargin: TibiaStyle.marginNarrow
    rightMargin: TibiaStyle.marginNarrow
    bottomMargin: TibiaStyle.marginNarrow

    boundsBehavior: Flickable.StopAtBounds

    readonly property int elementWidth: 218
    readonly property int elementHeight: 100
    cellWidth: elementWidth + TibiaStyle.marginNarrow
    cellHeight: elementHeight + TibiaStyle.marginNarrow
    interactive: false
    highlightMoveDuration: 0
    snapMode: GridView.SnapToRow

    footer: Item {
      height: TibiaStyle.marginNarrow
      width: TibiaStyle.marginNarrow
    }

    model: _helperModel

    delegate: TibiaButton {
      id: outfitBorder
      property var jsonData: model.jsondata
      property var everythingOwned: model.everythingowned
      property bool isSelected: index == outfitsMountsList.currentIndex;

      color: everythingOwned ? "grey" : "darkgrey"
      width: outfitsMountsList.elementWidth
      height: outfitsMountsList.elementHeight

      onJsonDataChanged: {
        _tempOutfitPreset.fromJsonObject(jsonData);
        outfitPreviewPanel.outfitPreset.copyFrom(_tempOutfitPreset);
        Logic.fixOutfitColors(outfitPreviewPanel.outfitPreset.outfitColor);
        Logic.fixOutfitColors(outfitPreviewPanel.outfitPreset.mountColor);
        nameText.text = outfitPreviewPanel.outfitPreset.name;
      }

      Loader {
        Component {
          id: unavailableOutfitsComponent
          TibiaGuiHelp {
            text: qsTrId("outfit_preset_outfits_unavailable_tooltip")
          } // TibiaGuiHelp
        }
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: TibiaStyle.marginRelated
        anchors.rightMargin: TibiaStyle.marginRelated
        sourceComponent: everythingOwned ? undefined : unavailableOutfitsComponent
      }


      Loader {
        Component {
          id: selectionBorderComponent
          Rectangle {
            color: "transparent"
            border.color: "white"
          }
        }
        anchors.fill: parent
        sourceComponent: isSelected ? selectionBorderComponent : undefined
      }

      ColumnLayout {
        id: outfitColumnLayout
        anchors.fill: parent
        anchors.margins: TibiaStyle.marginRelated
        spacing: TibiaStyle.marginNarrow

        OutfitPreviewPanel {
          id: outfitPreviewPanel
          Layout.fillWidth: true
          Layout.preferredHeight: 64

          scaleFactor: 1.0
          floorTileID: 0
          moving: false
          socketID: 0
          movementSpeed: 0
          smoothTextureFiltering: false
        }

        Item {
          Layout.fillWidth: true
          Layout.fillHeight: true

          RowLayout {
            id: innerRowLayout
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            spacing: TibiaStyle.marginRelated
            TibiaText {
              id: nameText
              Layout.maximumWidth: outfitBorder.width - innerRowLayout.spacing - outfitColumnLayout.spacing*2
              text: outfitPreviewPanel.outfitPreset.name
              wrapMode: Text.Wrap
              maximumLineCount: 2
              horizontalAlignment: Text.AlignHCenter
            } // TibiaText
          } // RowLayout
        } // Item
      } // ColumnLayout

      onClicked: {
        selectPreset(index);
      } // onClicked

      onHoveredChanged: {
        if (hovered) {
          if(tibiaMouseCursorController != null) { tibiaMouseCursorController.setPointingHand(true); }
        } else {
          if(tibiaMouseCursorController != null) { tibiaMouseCursorController.setPointingHand(false); }
        }
      }

    } // TibiaButton
  } // GridView
} // TibiaScrollView
