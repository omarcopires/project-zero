import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qmlcomponents
import qmlenumvalues

import "qrc:/qt/qml/qmlcomponents/qml"
import "outfitdialog.js" as Logic

TibiaDialog {
  id: root

  width: 756
  caption: root._dialogCaption

  property var controller: null

  property int selectedOutfitID: 0
  property int selectedMountID: 0
  property int selectedSummonID: 0
  property int selectedPresetIndex: -1
  property string selectedPresetName: qsTrId("outfit_no_preset")

  property bool firstAddOnShouldBeSelected: false
  property bool secondAddOnShouldBeSelected: false

  property var outfitsModel: controller != null ? controller.outfitsModel: null
  property var mountsModel: controller != null ? controller.mountsModel: null
  property var summonsModel: controller != null ? controller.summonsModel: null
  property var presetsModel: controller != null ? controller.presetsModel: null

  property bool showOnlyOwnOutfits: dialogSettings.filterOnlyOwnOutfits.value
  property bool showOnlyOwnMounts: dialogSettings.filterOnlyOwnMounts.value

  property var lookDirectionIndex: 0
  property var _LOOK_DIRECTIONS: [OutfitAppearanceInstance.SOUTH, OutfitAppearanceInstance.EAST, OutfitAppearanceInstance.NORTH, OutfitAppearanceInstance.WEST ]

  property var hsvColors: controller != null ? controller.hsvColors : []

  property bool clientSettingSmoothFiltering: false
  property bool isForHireling: controller != null &&
    (controller.dialogMode == OutfitDialogController.HirelingSelectOutfit ||
     controller.dialogMode == OutfitDialogController.HirelingTryOutfit)
  property bool isForShowSocketConfiguration: controller != null &&
     controller.dialogMode == OutfitDialogController.ConfigureShowOffSocket
  property bool isCharacterInfo: controller != null && controller.dialogMode == OutfitDialogController.CharacterInfoShowSelection

  property bool canConfirmCustomization: false

  property var  outfitCurrentModelData: null
  property var  mountCurrentModelData: null
  property var  summonCurrentModelData: null

  property int  outfitGender: OutfitDialogController.OutfitGenderUnknown

  property bool hasOwnOutfits: outfitsModel != null && outfitsModel.numberOfOwnedOutfits > 0
  property bool hasOwnMounts: mountsModel != null && mountsModel.numberOfOwnedOutfits > 0

  property string _dialogCaption: ""
  property string _upperCheckBoxesCaption: ""
  property string _lowerCheckBoxesCaption: ""
  property string _rightPanelUpperCaption: ""
  property var _upperCheckBoxesModel: []
  property var _lowerCheckBoxesModel: []

  property var outfitPreviewPanel: null
  property var outfitSelectionList: null
  property var presetSelectionList: null
  property var colorSelectionGrid: null
  property var selectionListLoader: null
  property var outfitFilterItem: null

  property var _outfitDialogLayout: null

  property var outfitOptionTypes: []
  property var currentOutfitTypeOption: OutfitDialog.OutfitOptionType.Outfits
  property var outfitOptionTypeExclusiveGroup: null

  enum OutfitOptionType {
    Outfits,
    Mounts,
    Summons,
    Presets
  }

  function selectOutfitOptionType(type) {
    outfitOptionTypeExclusiveGroup.buttons.forEach( (button) => {
      if (button.buttonOutfitOptionType == type) {
        outfitOptionTypeExclusiveGroup.checkedButton = button;
        return;
      }
    });
  }

  Component {
    id: dialogSetting
    QtObject {
      signal changed();

      default property bool value: false
      property bool enabled: true
      property bool visible: true

      onValueChanged: {
        changed();
      }
    }
  }

  Component {
    id: dialogSettingTibiaMenuOptionCheckBox
    TibiaMenuOptionCheckBox {
      property var dialogSetting: null
      enabled: dialogSetting != null ? dialogSetting.enabled : false
      visible: dialogSetting != null ? dialogSetting.visible : false
      onCheckedChanged: {
        if (dialogSetting && dialogSettings.value != checked) {
          dialogSetting.value = checked;
        }
      } //onCheckedChanged

      onDialogSettingChanged: {
        if (dialogSetting && checked != dialogSetting.value) {
          checked = dialogSetting.value;
        }
      }

      Component.onCompleted: {
        if (dialogSetting && checked != dialogSetting.value) {
          checked = dialogSetting.value;
        }
      }

      Connections {
        target: dialogSetting
        function onValueChanged() {
          checked = dialogSetting.value;
        }
      }
    } //TibiaMenuOptionCheckBox
  }

  Component {
    id: outfitSelectionComponent
    OutfitSelection {
      id: outfitSelectionList
      Component.onCompleted: {
        root.outfitSelectionList = outfitSelectionList;
      }
    }
  }

  Component {
    id: outfitPresetSelectionComponent
    OutfitPresetSelection {
      id: presetSelectionList
      Component.onCompleted: {
        root.presetSelectionList = presetSelectionList;
        root.outfitFilterItem = null;
      }
    }
  }

  Component {
    id: outfitFilterComponent
    RowLayout {
      spacing: TibiaStyle.marginUnrelated

      function resetFilter() {
        if (checkboxOnlyOwnOutfits.filterSetting && checkboxOnlyOwnOutfits.filterSetting.value == true) {
          checkboxOnlyOwnOutfits.filterSetting.value = false;
        }
        outfitSearchField.clearSearch();
        Logic.outfitFilterSearchOutfit("");
      }
      Component.onCompleted: {
        root.outfitFilterItem = this;
        root.initialFocusItem = outfitSearchField;
        outfitSearchField.forceActiveFocus();
      }

      TibiaCheckBox {
        id: checkboxOnlyOwnOutfits
        property var filterSetting: {
          if (root.currentOutfitTypeOption == OutfitDialog.OutfitOptionType.Outfits) {
            return dialogSettings.filterOnlyOwnOutfits;
          } else if (root.currentOutfitTypeOption == OutfitDialog.OutfitOptionType.Mounts) {
            return dialogSettings.filterOnlyOwnMounts;
          } else {
            return null;
          }
        }
        text: qsTrId("only_mine_caption")
        onFilterSettingChanged: filterSettingConnections.refreshFilterSettings();

        Connections {
          id: filterSettingConnections
          target: checkboxOnlyOwnOutfits.filterSetting
          function onChanged() {
            refreshFilterSettings();
          }
          function refreshFilterSettings() {
            Qt.callLater(function() {
              if (target == null) {
                checkboxOnlyOwnOutfits.enabled = false;
                checkboxOnlyOwnOutfits.visible = false;
                checkboxOnlyOwnOutfits.checked = false;
              } else {
                if (checkboxOnlyOwnOutfits.enabled != target.enabled) {
                  checkboxOnlyOwnOutfits.enabled = target.enabled;
                }
                if (checkboxOnlyOwnOutfits.visible != target.visible) {
                  checkboxOnlyOwnOutfits.visible = target.visible;
                }
                if (checkboxOnlyOwnOutfits.checked != (target.enabled && target.value)) {
                  checkboxOnlyOwnOutfits.checked = target.enabled && target.value;
                }
              }
            });
          }
        }

        onCheckedChanged: {
          Logic.outfitFilterOnlyMineChanged(checked);
        } //onCheckedChanged
      } //TibiaMenuOptionCheckBox

      TibiaTextSearchField {
        id: outfitSearchField
        Layout.fillWidth: true
        Layout.preferredHeight: TibiaStyle.optionLineFrameHeight
        //shouldBeText: dialogRoot.filterString

        onSearchTextChanged: {
          Logic.outfitFilterSearchOutfit(searchText);
        } //onSearchTextChanged
      }
    }
  }

  Component {
    id: presetButtonsComponent
    RowLayout {
      Item {
        Layout.fillWidth: true
      }
      TibiaButton {
        text: qsTrId("new");
        onClicked: Logic.outfitPresetsSaveIndex();
      }
      TibiaButton {
        text: qsTrId("rename");
        enabled: presetSelectionList.selectedPresetIndex != -1
        onClicked: Logic.outfitPresetsRenameIndex();
      }
      TibiaButton {
        text: qsTrId("save");
        enabled: presetSelectionList.selectedPresetIndex != -1
        onClicked: Logic.outfitPresetsOverwriteIndex();
      }
      TibiaButton {
        text: qsTrId("delete");
        enabled: presetSelectionList.selectedPresetIndex != -1
        onClicked: Logic.outfitPresetsDeleteIndex();
      }
      Item {
        Layout.fillWidth: true
      }
    }
  }


  QtObject {
    id: dialogSettings
    signal valueChanged();

    property var showFloor: dialogSetting.createObject()
    property var showMovement: dialogSetting.createObject()
    property var showSocket: dialogSetting.createObject()
    property var showOutfit: dialogSetting.createObject()
    property var showAddOn1: dialogSetting.createObject()
    property var showAddOn2: dialogSetting.createObject()
    property var showMount: dialogSetting.createObject()
    property var showSummon: dialogSetting.createObject()
    property var randomMount: dialogSetting.createObject()
    property var filterOnlyOwnOutfits: dialogSetting.createObject()
    property var filterOnlyOwnMounts: dialogSetting.createObject()

    property var checkboxShowFloor:    { "dialogSetting": showFloor, "caption":   qsTrId("show_floor_caption") }
    property var checkboxShowMovement: { "dialogSetting": showMovement, "caption": qsTrId("movement_caption") }
    property var checkboxShowSocket:   { "dialogSetting": showSocket, "caption":  qsTrId("show_socket_caption") }
    property var checkboxShowOutfit:   { "dialogSetting": showOutfit, "caption":  qsTrId("show_outfit_caption") }
    property var checkboxShowAddOn1:   { "dialogSetting": showAddOn1, "caption":  qsTrId("addon_number").arg(1) }
    property var checkboxShowAddOn2:   { "dialogSetting": showAddOn2, "caption":  qsTrId("addon_number").arg(2) }
    property var checkboxShowSummon:   { "dialogSetting": showSummon, "caption":  qsTrId("show_summon_caption") }
    property var checkboxShowMount:    { "dialogSetting": showMount, "caption":   qsTrId("mount_caption") }
    property var checkboxRandomMount:  { "dialogSetting": randomMount, "caption": qsTrId("random_mount_caption") }

    function emitValueChanged()
    {
      Qt.callLater(valueChanged);
    }

    Component.onCompleted: {
      showFloor.changed.connect(emitValueChanged);
      showMovement.changed.connect(emitValueChanged);
      showSocket.changed.connect(emitValueChanged);
      showOutfit.changed.connect(emitValueChanged);
      showAddOn1.changed.connect(emitValueChanged);
      showAddOn2.changed.connect(emitValueChanged);
      showMount.changed.connect(emitValueChanged);
      showSummon.changed.connect(emitValueChanged);
      randomMount.changed.connect(emitValueChanged);
      filterOnlyOwnOutfits.changed.connect(emitValueChanged);
      filterOnlyOwnMounts.changed.connect(emitValueChanged);
    }
  }



  onControllerChanged: {
    Qt.callLater(Logic.onControllerChanged);
  }

  onHasOwnOutfitsChanged: Logic.checkForOwnOutfits()
  onHasOwnMountsChanged: Logic.checkForOwnMounts()
  onFirstAddOnShouldBeSelectedChanged: Logic.checkForAddOnsAfterModelChange();
  onSecondAddOnShouldBeSelectedChanged: Logic.checkForAddOnsAfterModelChange();

  onOutfitCurrentModelDataChanged: {
    if (outfitCurrentModelData != null) {
      let newOutfitID = outfitCurrentModelData["outfitID"];
      if (root.outfitGender != outfitCurrentModelData["outfitGender"]) {
        newOutfitID = outfitCurrentModelData["otherGenderOutfitID"];
      }
      if (selectedOutfitID != newOutfitID) {
        selectedOutfitID = newOutfitID;
      }
    } else {
      selectedOutfitID = 0;
    }
    Logic.checkIfCustomizationCanBeConfirmed();
    Logic.checkIfCanBeColorizedAfterModelChange();
    Logic.checkForGenderAfterModelChange();
    Logic.checkForAddOnsAfterModelChange();
  }

  onMountCurrentModelDataChanged: {
    if (mountCurrentModelData != null) {
      if (selectedMountID != mountCurrentModelData["outfitID"]) {
        selectedMountID = mountCurrentModelData["outfitID"]
      }
    } else {
      selectedMountID = 0;
    }

    Logic.checkIfCustomizationCanBeConfirmed();
    Logic.checkIfCanBeColorizedAfterModelChange();
  }
  onSummonCurrentModelDataChanged: {
    if (summonCurrentModelData != null) {
      if (selectedSummonID != summonCurrentModelData["outfitID"]) {
        selectedSummonID = summonCurrentModelData["outfitID"]
      }
    } else {
      selectedSummonID = 0;
    }
  }

  onReturnPressedFunction: Logic.sendEnteredDataToController
  onCancelPressedFunction: function() { controller.onCancelClicked() }

  onCurrentOutfitTypeOptionChanged: {
    Logic.currentOutfitTypeOptionChanged();
    Logic.checkIfCanBeColorizedAfterModelChange();
  }

  //keep focus to the dialog itself, no tab navigation wanted
  initialFocusItem: root
  KeyNavigation.tab: root

  Component {
    id: outfitTypeComponent
    RowLayout {
      id: outerLayout
      property var outfitOptionType: OutfitDialog.OutfitOptionType.Outfits
      property alias exclusiveGroup: radioButton.exclusiveGroup
      property var modelData: {
        switch (outfitOptionType) {
          case OutfitDialog.OutfitOptionType.Outfits:
            return root.outfitCurrentModelData;
          case OutfitDialog.OutfitOptionType.Mounts:
            return root.mountCurrentModelData;
          case OutfitDialog.OutfitOptionType.Summons:
            return root.summonCurrentModelData;
        }
      }
      property int storeOfferID: {
        if (modelData != null) {
          return modelData["offerID"];
        } else {
          return 0;
        }
      }
      property var outfitType: {
        if (modelData != null) {
          return modelData["outfitType"];
        } else {
          return TibiaEnums.OutfitTypeOwned;
        }
      }

      property string optionCaption: {
        switch (outfitOptionType) {
          case OutfitDialog.OutfitOptionType.Outfits: return qsTrId("outfit_selection")
          case OutfitDialog.OutfitOptionType.Mounts:  return qsTrId("mount_selection")
          case OutfitDialog.OutfitOptionType.Summons: return qsTrId("summon_selection")
          case OutfitDialog.OutfitOptionType.Presets: return qsTrId("preset_selection")
        }
      }
      property string outfitName: {
        if (modelData != null) {
          return modelData["outfitName"];
        } else {
          switch (outfitOptionType) {
            case OutfitDialog.OutfitOptionType.Outfits:
            case OutfitDialog.OutfitOptionType.Summons:
              return qsTrId('dummy_unknown');
            case OutfitDialog.OutfitOptionType.Mounts:
              return qsTrId('outfit_no_mount');
            case OutfitDialog.OutfitOptionType.Presets:
              return selectedPresetName;
          }
        }
      }

      onExclusiveGroupChanged: {
        if (exclusiveGroup != null && exclusiveGroup.checkedButton == null) {
          exclusiveGroup.checkedButton = radioButton;
        }
      }
      TibiaRadioButton {
        id: radioButton
        property var buttonOutfitOptionType: outfitOptionType
        text: optionCaption
        property var exclusiveGroup
        ButtonGroup.group: exclusiveGroup
        onCheckedChanged: {
          if (checked && root.currentOutfitTypeOption != outfitOptionType) {
            root.currentOutfitTypeOption = outfitOptionType;
          }
        }
      }
      Item {
        Layout.fillWidth: true
      }

      Loader {
        Layout.preferredWidth: 230
        Layout.preferredHeight: TibiaStyle.iconButtonSize

        Component {
          id: storeButtonComponent

          TibiaButton {
            id: storeButtonOutfit
            color: "blue"
            RowLayout {
              anchors.verticalCenter: parent.verticalCenter
              anchors.horizontalCenter: parent.horizontalCenter
              spacing: TibiaStyle.marginRelated
              anchors.verticalCenterOffset: (storeButtonOutfit.pressed || storeButtonOutfit.checked ? 1 : 0)
              anchors.horizontalCenterOffset: (storeButtonOutfit.pressed || storeButtonOutfit.checked ? 1 : 0)
              Image {
                source: "/images/icon-tibiastore.png"
              } // Image
              TibiaText {
                text: outfitName
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
              } // TibiaText
            } // RowLayout

            onClicked: {
              if (controller != null) {
                controller.onClickedOpenStoreOffer(storeOfferID);
              }
            }
          } //TibiaIconButton

          // TibiaButton {
          //   imageSource: "/images/icon-tibiastore.png"
          //   color: "blue"
          // }
        }
        Component {
          id: outfitNameComponent

          TibiaFrame1PixelDown {
            Layout.fillWidth: true

            TibiaText {
              id: outfitNameText
              anchors.fill: parent
              anchors.margins: 1
              horizontalAlignment: Text.AlignHCenter
              verticalAlignment: Text.AlignVCenter
              text: outfitName
              elide: Text.ElideRight
              styleType: "Dialog"
              visible: outfitType != TibiaEnums.OutfitTypeStoreSold
            } //TibiaText
          }
        }

        sourceComponent: outfitType == TibiaEnums.OutfitTypeStoreSold ? storeButtonComponent : outfitNameComponent
      }
    }
  }

  ColumnLayout {
    anchors { left: parent.left; right: parent.right}
    visible: true

    OutfitDialogLayout {
      id: outfitDialogLayout

      Component.onCompleted: {
        root._outfitDialogLayout = this;
      }
      upperPanelCaption: _upperCheckBoxesCaption
      upperPanelLeftComponent: ColumnLayout {
        Repeater {
          model: root._upperCheckBoxesModel
          delegate: Loader {
            sourceComponent: dialogSettingTibiaMenuOptionCheckBox
            Layout.fillWidth: true
            onLoaded: {
              item.dialogSetting = modelData.dialogSetting;
              item.text = modelData.caption;
            }
          }
        }
        Item {
          Layout.fillHeight: true
        }
      }

      upperPanelRightComponent: ColumnLayout {
        Component.onCompleted: {
          root.outfitPreviewPanel = outfitPreviewPanel;
        }

        TibiaFrame1PixelDown { // outfit preview panel
          id: outfitSpriteViewerBorder
          Layout.preferredWidth: 32 * outfitPreviewPanel.scaleFactor * 5
          Layout.preferredHeight: 32 * outfitPreviewPanel.scaleFactor * 3
          Layout.alignment: Qt.AlignRight
          clip: true

          OutfitPreviewPanel {
            id: outfitPreviewPanel

            property OutfitPreset tempOutfitPreset

            width: parent.width-parent.borderWidth * 2
            height: parent.height-parent.borderWidth * 2
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            z: -1
            floorTileID: dialogSettings.showFloor.value ? 429 : 0
            moving: dialogSettings.showMovement.value
            socketID: dialogSettings.showSocket.value ? 35973 : 0
            movementSpeed: 600
            lookDirection: _LOOK_DIRECTIONS[lookDirectionIndex]
            smoothTextureFiltering: root.clientSettingSmoothFiltering

            Component.onCompleted: {
              tempOutfitPreset = Qt.binding(function() {
                let newOutfitPreset = TibiaObjects.outfitPreset();
                newOutfitPreset.outfitID = dialogSettings.showOutfit.value ? root.selectedOutfitID : 0;
                newOutfitPreset.outfitFirstAddOn = dialogSettings.showAddOn1.value && dialogSettings.showAddOn1.enabled;
                newOutfitPreset.outfitSecondAddOn = dialogSettings.showAddOn2.value && dialogSettings.showAddOn2.enabled;
                newOutfitPreset.mountID = dialogSettings.showMount.value ? root.selectedMountID : 0;
                newOutfitPreset.summonID = dialogSettings.showSummon.value ? root.selectedSummonID : 0;
                return newOutfitPreset;
              })
            }

            onTempOutfitPresetChanged: {
              Qt.callLater(function() {
                tempOutfitPreset.outfitColor.copyFrom(outfitPreviewPanel.outfitPreset.outfitColor);
                tempOutfitPreset.mountColor.copyFrom(outfitPreviewPanel.outfitPreset.mountColor);
                outfitPreset.copyFrom(tempOutfitPreset);
              });
            }
          }

          TibiaIconButton {
            id: buttonShowLeft
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: 2
            sourceUp: "/images/button-rotate-left-up.png"
            sourceDown: "/images/button-rotate-left-down.png"
            onClicked: {
              root.lookDirectionIndex = (root.lookDirectionIndex + (_LOOK_DIRECTIONS.length - 1)) % _LOOK_DIRECTIONS.length;
            }
          }

          TibiaIconButton {
            id: buttonShowRight
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 2
            sourceUp: "/images/button-rotate-right-up.png"
            sourceDown: "/images/button-rotate-right-down.png"
            onClicked: {
              root.lookDirectionIndex = (root.lookDirectionIndex + 1) % _LOOK_DIRECTIONS.length;
            }
          }
        }  // TibiaFrame1PixelDown
      }

      lowerLeftPanelCaption: _lowerCheckBoxesCaption
      lowerLeftPanelComponent: ColumnLayout {
        Repeater {
          model: root._lowerCheckBoxesModel
          delegate: Loader {
            sourceComponent: dialogSettingTibiaMenuOptionCheckBox
            Layout.fillWidth: true
            onLoaded: {
              item.dialogSetting = modelData.dialogSetting;
              item.text = modelData.caption;
            }
          }
        }
        Loader {
          Layout.fillWidth: true
          Layout.fillHeight: true
          Component {
            id: noConfigurationText
            TibiaText {
              text: qsTrId("outfit_no_configuration")
              wrapMode: Text.WordWrap
              horizontalAlignment: Text.AlignHCenter
            }
          }
          sourceComponent: root._lowerCheckBoxesModel.length == 0 ? noConfigurationText : undefined
        }
        Item {
          Layout.fillHeight: true
        }
      }
      lowerRightPanelCaption: qsTrId("change_appearance_caption")
      lowerRightPanelComponent: ColumnLayout {
        ColumnLayout { // outfit selections + gender buttons
          id: outfitSelection

          ColumnLayout {
            spacing: TibiaStyle.marginNarrow
            Layout.alignment: Qt.AlignTop
            ButtonGroup {
              id: outfitOptionTypeExclusiveGroup
              Component.onCompleted: {
                root.outfitOptionTypeExclusiveGroup = outfitOptionTypeExclusiveGroup;
              }
            }

            Repeater {
              id: outfitTypesRepeater
              model: outfitOptionTypes
              Loader {
                sourceComponent: outfitTypeComponent
                Layout.fillWidth: true
                onItemChanged: {
                  item.outfitOptionType = modelData;
                  item.exclusiveGroup = outfitOptionTypeExclusiveGroup;
                }
              }

            }
          }
          ColumnLayout { // Colorize
            Layout.alignment: Qt.AlignTop

            RowLayout {
              Item {
                id: colorPickerWrapper
                property alias currentOutfitColor: colorSelectionGrid.currentOutfitColor
                property bool canBeColorized: false

                Layout.alignment: Qt.AlignCenter
                implicitWidth: 254   // TabView seems to be unable to fit itself around its content's size
                implicitHeight: 114
                enabled: canBeColorized
                Component.onCompleted: {
                  root.colorSelectionGrid = colorPickerWrapper;
                }

                TibiaFrame2PixelUpFilled {
                  anchors.fill: parent
                  anchors.topMargin: colorPickerTabView.height - borderWidth
                } //TibiaFrame2PixelUpFilled

                TibiaTabBar {
                  id: colorPickerTabView
                  anchors { top: parent.top; left: parent.left; right: parent.right; }

                  onFocusChanged: {
                    if(focus) {
                      focus = false;
                      root.forceActiveFocus();
                    }
                  } //onFocusChanged

                  TibiaTabButton {
                    text: qsTrId("outfit_color_head_tab_caption")
                  }
                  TibiaTabButton {
                    text: qsTrId("outfit_color_primary_tab_caption")
                  }
                  TibiaTabButton {
                    text: qsTrId("outfit_color_secondary_tab_caption")
                  }
                  TibiaTabButton {
                    text: qsTrId("outfit_color_detail_tab_caption")
                  }
                }

                TibiaColorSelectionGrid {
                  id: colorSelectionGrid

                  property OutfitColor currentOutfitColor: null

                  colors: root.hsvColors
                  anchors { left: parent.left; right: parent.right;
                            top: colorPickerTabView.bottom; bottom: parent.bottom;
                            margins: 4; topMargin: 1 }

                  onSelectedColorChanged: {
                    Qt.callLater(function() {
                      var colorIndex = colorSelectionGrid.selectedColorIndex;
                      switch (colorPickerTabView.currentIndex) {
                        case 0: {
                          colorSelectionGrid.currentOutfitColor.headColorIndex = colorIndex;
                          break;
                        }
                        case 1: {
                          colorSelectionGrid.currentOutfitColor.torsoColorIndex = colorIndex;
                          break;
                        }
                        case 2: {
                          colorSelectionGrid.currentOutfitColor.legsColorIndex = colorIndex;
                          break;
                        }
                        case 3: {
                          colorSelectionGrid.currentOutfitColor.detailColorIndex = colorIndex;
                          break;
                        }
                      }
                    });
                  }

                  Connections {
                    target: colorPickerTabView
                    function onCurrentIndexChanged() {
                      colorSelectionGrid.selectCurrentColorIndex()
                    }
                  }
                  Connections {
                    id: outfitColorConnections
                    target: null
                    function onColorChanged() {
                      colorSelectionGrid.selectCurrentColorIndex()
                    }
                  }

                  onCurrentOutfitColorChanged: {
                    outfitColorConnections.target = currentOutfitColor;
                    selectCurrentColorIndex()
                  }

                  function selectCurrentColorIndex() {
                    let colorIndex = 0;
                    switch (colorPickerTabView.currentIndex) {
                      case 0: {
                        colorIndex = colorSelectionGrid.currentOutfitColor.headColorIndex;
                        break;
                      }
                      case 1: {
                        colorIndex= colorSelectionGrid.currentOutfitColor.torsoColorIndex;
                        break;
                      }
                      case 2: {
                        colorIndex = colorSelectionGrid.currentOutfitColor.legsColorIndex;
                        break;
                      }
                      case 3: {
                        colorIndex = colorSelectionGrid.currentOutfitColor.detailColorIndex;
                        break;
                      }
                    }
                    colorSelectionGrid.selectedColorIndex = colorIndex;
                  }
                }

                TibiaDisabledOverlay {
                  anchors.fill: parent
                  anchors.margins: 1
                  visible: !parent.enabled
                } //TibiaDisabledOverlay
              }
              ColumnLayout {

                spacing: TibiaStyle.marginNarrow
                Layout.preferredWidth: 54

                RowLayout {
                  id: genderSwitchWrapper
                  property var currentSelectedGender: root.outfitGender

                  visible: currentSelectedGender != OutfitDialogController.OutfitGenderUnknown
                  TibiaButton {
                    id: buttonShowMale
                    Layout.fillWidth: true
                    tooltipText: qsTrId("outfit_gender_male")
                    tooltipTextChecked: tooltipText
                    imageSource: "/images/icon-gender-male.png"
                    checkable: true
                    useButtonShouldBeChecked: true
                    enabled: !checked
                    buttonShouldBeChecked: genderSwitchWrapper.currentSelectedGender == OutfitDialogController.OutfitGenderMale
                    onClicked: {
                      Logic.switchGender(OutfitDialogController.OutfitGenderMale);
                    }
                  }

                  TibiaButton {
                    id: buttonShowFemale
                    Layout.fillWidth: true
                    tooltipText: qsTrId("outfit_gender_female")
                    tooltipTextChecked: tooltipText
                    imageSource: "/images/icon-gender-female.png"
                    checkable: true
                    useButtonShouldBeChecked: true
                    enabled: !checked
                    buttonShouldBeChecked: genderSwitchWrapper.currentSelectedGender == OutfitDialogController.OutfitGenderFemale
                    onClicked: {
                      Logic.switchGender(OutfitDialogController.OutfitGenderFemale);
                    }
                  }
                } // Gender selection

                Item {
                  Layout.fillHeight: true
                }

                TibiaButton {
                  Layout.fillWidth: true
                  Layout.minimumWidth: 50 // this is a workaround for a strange bug (TIBIA-27955)
                  Layout.preferredHeight: 28
                  wrapText: true
                  text: qsTrId("outfit_clipboard_copy_all")
                  onClicked: {
                    if (controller != null) {
                      let currentPreset = Logic.currentSettingsToOutfitPreset();
                      controller.copyToClipboard(currentPreset);
                    }
                  }
                }

                TibiaButton {
                  Layout.fillWidth: true
                  Layout.minimumWidth: 50 // this is a workaround for a strange bug (TIBIA-27955)
                  Layout.preferredHeight: 28
                  wrapText: true
                  text: qsTrId("outfit_clipboard_copy_colors")
                  enabled: colorSelectionGrid.enabled
                  onClicked: {
                    controller.copyToClipboard(colorSelectionGrid.currentOutfitColor)
                  }
                }

                TibiaButton {
                  id: pasteFromClipboardButton
                  Layout.fillWidth: true
                  Layout.minimumWidth: 50 // this is a workaround for a strange bug (TIBIA-27955)
                  Layout.preferredHeight: 28
                  wrapText: true
                  text: qsTrId("outfit_clipboard_paste")
                  onClicked: {
                    let data = Logic.createDataFromClipboard();
                    if (data == null) {
                      return;
                    } else if (data instanceof OutfitColor) {
                      colorSelectionGrid.currentOutfitColor.copyFrom(data);
                    } else if (data instanceof OutfitPreset) {
                      Logic.changeToOutfitPreset(data, false);
                    }
                  }

                  function checkClipboardData() {
                    let data = Logic.createDataFromClipboard();
                    if (data == null) {
                      pasteFromClipboardButton.text = "Paste";
                      pasteFromClipboardButton.enabled = false;
                    } else if (data instanceof OutfitColor) {
                      pasteFromClipboardButton.text = "Paste\n(colours)";
                      pasteFromClipboardButton.enabled = Qt.binding(function() { return colorSelectionGrid.enabled; });
                    } else if (data instanceof OutfitPreset) {
                      pasteFromClipboardButton.text = "Paste\n(all)";
                      pasteFromClipboardButton.enabled = true;
                    }
                  }

                  Component.onCompleted: checkClipboardData()
                }

                Connections {
                  target: ClipboardHelper
                  function onNewClipboardTextAvailable() {
                    pasteFromClipboardButton.checkClipboardData();
                  }
                }
              }
            }
          }
        } // ColumnLayout outfitSelection
      }
      rightPanelUpperCaption: _rightPanelUpperCaption
      rightPanelUpperComponent: outfitFilterComponent
      rightPanelLowerComponent: TibiaFrame1PixelDown {
        Loader {
          id: selectionListLoader
          Component.onCompleted: {
            root.selectionListLoader = selectionListLoader;
          }
          anchors.margins: 2
          anchors.fill: parent
        }
      }
    }

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
        enabled: root.canConfirmCustomization
        visible: controller != null && (controller.dialogMode == OutfitDialogController.SelectOutfit
          || controller.dialogMode == OutfitDialogController.HirelingSelectOutfit
          || controller.dialogMode == OutfitDialogController.ConfigureShowOffSocket)
        onClicked: { Logic.sendEnteredDataToController(); }
      } //TibiaButton

      TibiaButton {
        id: cancelButton
        text: controller == null ? qsTrId("cancel") : (controller.dialogMode == OutfitDialogController.SelectOutfit ? qsTrId("cancel") : qsTrId("close"))
        onClicked: controller!=null ?  controller.onCancelClicked() : undefined
      } //TibiaButton
    } //RowLayout
  } //ColumnLayout
} //TibiaDialog
