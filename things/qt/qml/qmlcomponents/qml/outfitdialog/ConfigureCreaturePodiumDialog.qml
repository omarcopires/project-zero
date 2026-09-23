import QtQuick
import QtQuick.Layouts

import qmlcomponents
import "qrc:/qt/qml/qmlcomponents/qml"

TibiaDialog {
  id: root

  width: 754
  caption: qsTrId("configure_boss_podium_dialog_caption")

  property var controller: null
  property var lookDirectionIndex: 0
  property var _LOOK_DIRECTIONS: [OutfitAppearanceInstance.SOUTH, OutfitAppearanceInstance.EAST, OutfitAppearanceInstance.NORTH, OutfitAppearanceInstance.WEST ]

  property bool clientSettingSmoothFiltering: false

  property int modelIndex: controller != null? controller.selectedIndex : -1

  onCancelPressedFunction: function() {
    if (controller != null) {
      controller.onCancelClicked();
    }
  }

  function randomOutfitColor() {
    return TibiaObjects.createOutfitColor(0, 0, 0, 0);
  }

  onControllerChanged : {
    if (controller) {
      outfitSelectionList.setModel(controller.bossSkinsModel, controller.chosenOutfit);
    }
  } // onControllerChanged


  ColumnLayout {
    anchors { left: parent.left; right: parent.right }
    spacing: TibiaStyle.marginRelated


    RowLayout {

      spacing: TibiaStyle.marginRelated

      TibiaPanel2PixelUpFilledWithCaption {
        id: checkboxPanel
        caption: qsTrId("configure_boss_podium_checkboxes_caption")

        Layout.preferredWidth: 135
        Layout.preferredHeight: 246

        spacing: TibiaStyle.marginRelated

        TibiaFrame1PixelDown {
          Layout.preferredWidth: 122
          Layout.preferredHeight: 22
          TibiaCheckBox {
            id: checkboxShowOutfit
            text: qsTrId("configure_boss_podium_checkbox_showboss")
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: TibiaStyle.marginRelated
            checked: controller && controller.showOutfit
            onCheckedChanged: {
              controller.showOutfit = checked;
            }
          } // TibiaCheckBox
        } // TibiaFrame1PixelDown

        TibiaFrame1PixelDown {
          Layout.preferredWidth: 122
          Layout.preferredHeight: 22
          TibiaCheckBox {
            id: checkboxShowPodium
            text: qsTrId("configure_boss_podium_checkbox_showpodium")
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: TibiaStyle.marginRelated
            checked: controller && controller.showSocket
            onCheckedChanged: {
              controller.showSocket = checked;
            }
          } // TibiaCheckBox
        } // TibiaFrame1PixelDown


      } // TibiaPanel2PixelUpFilledWithCaption

      TibiaPanel2PixelUpFilledWithCaption {
        id: outfitPanel
        caption: qsTrId("configure_boss_podium_preview_caption")

        Layout.preferredWidth: 332
        Layout.preferredHeight: 246

        ColumnLayout {
          spacing: TibiaStyle.marginRelated

          TibiaFrame1PixelDown {
            id: outfitSpriteViewerBorder
            Layout.preferredWidth: 32 * outfitPreviewPanel.scaleFactor * 5
            Layout.preferredHeight: 32 * outfitPreviewPanel.scaleFactor * 3
            clip: true

            OutfitPreviewPanel {
              id: outfitPreviewPanel



              outfitPreset: {
                if (checkboxShowOutfit.checked && controller != null && controller.outfitPreset != null) {
                  return controller.outfitPreset;
                } else {
                  let newPreset = TibiaObjects.outfitPreset();
                    newPreset.name = "";
                    newPreset.outfitID = 0;
                    newPreset.mountID = 0;
                    newPreset.summonID = 0;
                    newPreset.outfitColor.copyFrom(randomOutfitColor());
                    newPreset.mountColor.copyFrom(randomOutfitColor());
                    newPreset.outfitFirstAddOn = false;
                  return newPreset;
                }

              }
              width: parent.width-parent.borderWidth * 2
              height: parent.height-parent.borderWidth * 2
              anchors.verticalCenter: parent.verticalCenter
              anchors.horizontalCenter: parent.horizontalCenter
              z: -1
              floorTileID: checkboxShowFloor.checked ? 429 : 0
              socketID: checkboxShowPodium.checked ? controller.socketTypeID : 0
              lookDirection: _LOOK_DIRECTIONS[lookDirectionIndex]
              smoothTextureFiltering: root.clientSettingSmoothFiltering


            } // outfitpreviewpanel

            TibiaIconButton {
              id: buttonShowLeft
              anchors.left: parent.left
              anchors.bottom: parent.bottom
              anchors.margins: 2
              sourceUp: "/images/button-rotate-left-up.png"
              sourceDown: "/images/button-rotate-left-down.png"
              onClicked: {
                root.lookDirectionIndex = (root.lookDirectionIndex + (_LOOK_DIRECTIONS.length - 1)) % _LOOK_DIRECTIONS.length;
                controller.direction = _LOOK_DIRECTIONS[lookDirectionIndex];
              } // onClicked
            } // TibiaIconButton

            TibiaIconButton {
              id: buttonShowRight
              anchors.right: parent.right
              anchors.bottom: parent.bottom
              anchors.margins: 2
              sourceUp: "/images/button-rotate-right-up.png"
              sourceDown: "/images/button-rotate-right-down.png"
              onClicked: {
                root.lookDirectionIndex = (root.lookDirectionIndex + 1) % _LOOK_DIRECTIONS.length;
                controller.direction = _LOOK_DIRECTIONS[lookDirectionIndex];
              } // onClicked
            } // TibiaIconButton
          }  // TibiaFrame1PixelDown


          TibiaFrame1PixelDown {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 118
            Layout.preferredHeight: 22

            TibiaCheckBox {
              id: checkboxShowFloor
              text: qsTrId("configure_boss_podium_checkbox_showfloor")
              shouldBeChecked: controller && controller.showFloor
              anchors.verticalCenter: parent.verticalCenter
              anchors.left: parent.left
              anchors.leftMargin: TibiaStyle.marginRelated

              onCheckedChanged: {
                if (controller) {
                  controller.showFloor = checked
                }
              }              
            } // TibiaCheckBox


          } // TibiaFrame1PixelDown



        } // ColumnLayout
      } // TibiaPanel2PixelUpFilledWithCaption

      ColumnLayout {
        spacing: TibiaStyle.marginRelated
        Layout.alignment: Qt.AlignTop

        TibiaPanel2PixelUpFilledWithCaption {
          id: searchPanel
          caption: qsTrId("configure_boss_podium_filter_caption")
          Layout.fillWidth: true
          Layout.preferredHeight: 50

          TibiaTextSearchField {
            id: outfitSearchField

            Layout.fillWidth: true
            Layout.leftMargin: TibiaStyle.marginRelated
            Layout.rightMargin: TibiaStyle.marginRelated

            onSearchTextChanged: {
              controller.bossSkinsModel.outfitNameFilter = searchText;
            } //onSearchTextChanged
          } // TibiaTextSearchField

        } // TibiaPanel2PixelUpFilledWithCaption

        TibiaFrame1PixelDown {

          id: borderForSelection
          Layout.alignment: Qt.AlignRight
          Layout.preferredHeight: 190
          Layout.preferredWidth: 244


          BossOutfitSelection {
            id: outfitSelectionList
            anchors.fill: parent
            anchors.margins: borderForSelection.borderWidth
            gridMargin: TibiaStyle.marginRelated
            currentOutfitID: controller != null ? controller.outfitPreset.outfitID : 0
            currentRaceID: controller != null ? controller.chosenRace : 0

            useDefinedColorsFromModel: true
            onSelectedIndexChanged: {
              controller.onIndexChanged(selectedIndex, currentModelData.race);
            }

          } // BossOutfitSelection

        } // TibiaFrame1PixelDown


      } // ColumnLayout

    } // RowLayout


    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } //TibiaHorizontalSeparator


    RowLayout {
      Layout.fillWidth: true
      spacing: TibiaStyle.marginUnrelated

      Item {
        Layout.fillWidth: true
      } //Item

      TibiaButton {
        id: okButton
        text: qsTrId("ok")
        enabled: (!checkboxShowPodium.checked && (outfitPreviewPanel.outfitPreset.outfitID == 0 || !checkboxShowOutfit.checked)) ? false : true
        visible: true
        onClicked: {
          controller.onOkClicked(); }
      } //TibiaButton

      TibiaButton {
        id: cancelButton
        text: qsTrId("cancel")
        onClicked: {
          onCancelPressedFunction();
        }
      } //TibiaButton
    } //RowLayout

  } // ColumnLayout


} //TibiaDialog
