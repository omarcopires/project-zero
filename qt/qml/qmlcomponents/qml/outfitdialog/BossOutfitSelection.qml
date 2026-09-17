import QtQuick
import QtQuick.Layouts

import qmlcomponents
import "qrc:/qt/qml/qmlcomponents/qml"

TibiaScrollView {
  id: outfitsScrollView
  property var _helperModel: null
  property var currentModelData: null
  property int currentOutfitID : currentModelData != null
        ? _useOtherGender
                ? currentModelData["otherGenderOutfitID"]
                : currentModelData["outfitID"]
        : 0

  property int currentRaceID: currentModelData != null ? currentModelData["race"] : 0
  property bool _useOtherGender: false

  property bool useDefinedColorsFromModel: false

  property int selectedIndex: -1
  property int gridMargin: TibiaStyle.marginNarrow

  signal outfitSelected()

  function setModel(model, outfitID) {
    if (model) {
      model.resetFilter();
      _helperModel = AbstractItemModelHelper.wrapInHelperProxyModel(model);
      var newCurrentIndex = 0;
      if (outfitID != 0) {
        for (var i = 0; i < _helperModel.rowCount(); i++) {
          var tempModelData = _helperModel.sourceItemDataByRowIndex(i);
          if (tempModelData.outfitID == outfitID) {
            newCurrentIndex = i;
            _useOtherGender = false;
            break;
          } else if (tempModelData.otherGenderOutfitID == outfitID) {
            newCurrentIndex = i;
            _useOtherGender = true;
            break;
          }
        }
      }
      selectOutfitWithIndex(newCurrentIndex);
      outfitsMountsList.currentIndex = newCurrentIndex;
    } else {
      _helperModel = null;
      outfitsMountsList.currentIndex = -1;
    }
  }

  function selectOutfitWithIndex(index) {
    if (_helperModel != null && index != -1) {
      currentModelData = _helperModel.sourceItemDataByRowIndex(index);
      outfitsMountsList.currentIndex = index;
    } else {
      currentModelData = null;
    }
    outfitSelected();
  }

  GridView {
    id: outfitsMountsList

    leftMargin: outfitsScrollView.gridMargin
    topMargin: outfitsScrollView.gridMargin
    rightMargin: outfitsScrollView.gridMargin
    bottomMargin: outfitsScrollView.gridMargin

    boundsBehavior: Flickable.StopAtBounds
    pixelAligned: true
    interactive: false //prevent flick behavior on touch screens

    readonly property int elementWidth: 108
    readonly property int elementHeight: 100
    cellWidth: elementWidth + TibiaStyle.marginNarrow
    cellHeight: elementHeight + TibiaStyle.marginNarrow
    highlightMoveDuration: 0

    footer: Item {
      height: TibiaStyle.marginNarrow
      width: TibiaStyle.marginNarrow
    }

    model: _helperModel

    delegate: TibiaButton {
      id: outfitBorder
      property int outfitID: model != null ? _useOtherGender ? model.otherGenderOutfitID : model.outfitID : 0
      property int raceID: model != null ? model.race : 0
      property bool firstAddOn: model != null ? model.firstAddOn : false
      property bool secondAddOn: model != null ? model.secondAddOn : false
      property var outfitType: model != null ? model.outfitType: TibiaEnums.OutfitTypeOwned
      property bool storeOutfit: outfitType == TibiaEnums.OutfitTypeStoreSold
      property bool unavailableGoldenOutfit: outfitType == TibiaEnums.OutfitTypeUnavailableGoldenOutfit
      property bool unavailableTokenOutfit: outfitType == TibiaEnums.OutfitTypeUnavailableTokenOutfit
      property bool isSelected: (outfitID == currentOutfitID && raceID == currentRaceID)



      width: outfitsMountsList.elementWidth
      height: outfitsMountsList.elementHeight
      color: storeOutfit ? "blue" : "grey"

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

      Loader {
        Component {
          id: unavailableGoldenOutfitComponent
          TibiaGuiHelp {
            text: qsTrId("outfit_golden_unavailable_tooltip")
          } // TibiaGuiHelp
        }
        Component {
          id: unavailableTokenOutfitComponent
          TibiaGuiHelp {
            text: qsTrId("outfit_token_unavailable_tooltip")
          } // TibiaGuiHelp
        }
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: TibiaStyle.marginRelated
        anchors.rightMargin: TibiaStyle.marginRelated
        sourceComponent: unavailableGoldenOutfit ? unavailableGoldenOutfitComponent : (unavailableTokenOutfit ? unavailableTokenOutfitComponent : undefined)
      }

      ColumnLayout {
        id: outfitColumnLayout
        anchors.fill: parent
        anchors.margins: TibiaStyle.marginRelated
        spacing: TibiaStyle.marginNarrow

        OutfitAppearanceInstanceRenderer {
          id: outftitMountRenderer
          Layout.alignment: Qt.AlignHCenter
          Layout.preferredWidth: 64
          Layout.preferredHeight: 64

          animated: true
          center: true
          scaleFactor: Layout.preferredWidth / 64

          outfitId:    outfitBorder.outfitID
          headColor:   useDefinedColorsFromModel ? model.headColor : colorSelectionGrid.currentOutfitColor.headColor
          torsoColor:  useDefinedColorsFromModel ? model.torsoColor : colorSelectionGrid.currentOutfitColor.torsoColor
          legsColor:   useDefinedColorsFromModel ? model.legsColor : colorSelectionGrid.currentOutfitColor.legsColor
          detailColor: useDefinedColorsFromModel ? model.detailColor : colorSelectionGrid.currentOutfitColor.detailColor
          firstAddOn:  outfitBorder.firstAddOn
          secondAddOn: outfitBorder.secondAddOn
          outfitIsObject: model.isObjectOutfit
        } // OutfitAppearanceInstanceRenderer

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
              text: model != null? model.outfitName : ""
              wrapMode: Text.Wrap
              maximumLineCount: 2
              horizontalAlignment: Text.AlignHCenter
            } // TibiaText
          } // RowLayout
        } // Item
      } // ColumnLayout

      onClicked: {
        selectOutfitWithIndex(index);
        selectedIndex = index;
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
