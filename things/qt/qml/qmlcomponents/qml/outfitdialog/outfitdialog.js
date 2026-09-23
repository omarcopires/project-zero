function checkThatEitherOutfitOrMountAreSet() {
  if (dialogSettings.showOutfit.value && !dialogSettings.showMount.value) {
    dialogSettings.showOutfit.enabled = false;
  } else if (!dialogSettings.showOutfit.value && !dialogSettings.showMount.value) {
    dialogSettings.showOutfit.value = true;
  } else {
    dialogSettings.showOutfit.enabled = true;
  };
}

function checkThatEitherOutfitOrMountOrSocketAreSet() {
  if (!dialogSettings.showOutfit.value && !dialogSettings.showMount.value) {
    dialogSettings.showSocket.value = true;
    dialogSettings.showSocket.enabled = false;
  } else {
    dialogSettings.showSocket.enabled = true;
  };
}

function writeBackConfirmedAddOn1Settings()
{
  if (dialogSettings.showAddOn1.enabled == true) {
    root.firstAddOnShouldBeSelected = dialogSettings.showAddOn1.value;
  }
}

function writeBackConfirmedAddOn2Settings()
{
  if (dialogSettings.showAddOn2.enabled == true) {
    root.secondAddOnShouldBeSelected = dialogSettings.showAddOn2.value;
  }
}

function writeBackSettingsToController()
{
  if (controller) {
    controller.showMovement = dialogSettings.showMovement.value;
    controller.showSummon = dialogSettings.showSummon.value;
    controller.showFloor = dialogSettings.showFloor.value;
    controller.randomMount = dialogSettings.randomMount.value;
  }
}


function checkForOwnOutfits() {
  Qt.callLater(function() {
    if (!root.hasOwnOutfits) {
      dialogSettings.filterOnlyOwnOutfits.enabled = false;
      dialogSettings.filterOnlyOwnOutfits.value = false;
    } else {
      dialogSettings.filterOnlyOwnOutfits.enabled = true;
    }
  });
}

function checkForOwnMounts() {
  Qt.callLater(function() {
    if (!root.hasOwnMounts) {
      dialogSettings.filterOnlyOwnMounts.enabled = false;
      dialogSettings.filterOnlyOwnMounts.value = false;
    } else {
      dialogSettings.filterOnlyOwnMounts.enabled = true;
    }
  });
}

function getOtherGender(gender)
{
  if (gender == OutfitDialogController.OutfitGenderMale) {
    return OutfitDialogController.OutfitGenderFemale;
  } else if (gender == OutfitDialogController.OutfitGenderFemale) {
    return OutfitDialogController.OutfitGenderMale;
  } else {
    return OutfitDialogController.OutfitGenderUnknown;
  }
}

function checkForGenderAfterModelChange() {
  if (outfitCurrentModelData != null && outfitCurrentModelData.outfitGender != OutfitDialogController.OutfitGenderUnknown) {
    if (root.outfitGender != outfitCurrentModelData.outfitGender) {
      outfitGender = getOtherGender(outfitCurrentModelData.outfitGender);
    } else {
      outfitGender = outfitCurrentModelData.outfitGender;
    }
  } else {
    outfitGender = OutfitDialogController.OutfitGenderUnknown;
  }
}

function retrieveCurrentModelData() {
  switch (currentOutfitTypeOption) {
    case OutfitDialog.OutfitOptionType.Outfits:
      root.outfitCurrentModelData = outfitSelectionList.currentModelData;
      break;
    case OutfitDialog.OutfitOptionType.Mounts:
      root.mountCurrentModelData = outfitSelectionList.currentModelData;
      break;
    case OutfitDialog.OutfitOptionType.Summons:
      root.summonCurrentModelData = outfitSelectionList.currentModelData;
      break;
    case OutfitDialog.OutfitOptionType.Presets:
      let preset = presetSelectionList.selectedPreset;
      if (preset != null) {
        root.selectedPresetIndex = presetSelectionList.selectedPresetIndex;
        root.selectedPresetName = presetSelectionList.selectedPreset.name;
          changeToOutfitPreset(preset, false);
      }
      break;
  }
}

function checkIfCustomizationCanBeConfirmed()
{
  var customizationCanBeConfirmed = true;
  if (root.outfitCurrentModelData != null) {
    if (root.outfitCurrentModelData.outfitType != TibiaEnums.OutfitTypeOwned)  {
      if (dialogSettings.showOutfit.value) {
        customizationCanBeConfirmed = false;
      } else {
        customizationCanBeConfirmed = root.isForShowSocketConfiguration;
      }
    }
  } else {
    customizationCanBeConfirmed = false;
  }
  if (dialogSettings.showMount.value && root.mountCurrentModelData != null && root.mountCurrentModelData.outfitType != TibiaEnums.OutfitTypeOwned) {
    customizationCanBeConfirmed = false;
  }
  root.canConfirmCustomization = customizationCanBeConfirmed;
}

function checkIfCanBeColorizedAfterModelChange() {
  if (colorSelectionGrid) {
    var canBeColorized = false;
    if (root.currentOutfitTypeOption == OutfitDialog.OutfitOptionType.Outfits && root.outfitCurrentModelData != null) {
      canBeColorized = root.outfitCurrentModelData.canBeColorized;
    } else if (root.currentOutfitTypeOption == OutfitDialog.OutfitOptionType.Mounts && root.mountCurrentModelData != null) {
      canBeColorized = root.mountCurrentModelData.canBeColorized;
    }
    colorSelectionGrid.canBeColorized = canBeColorized;
  }
}

function removeInvalidMountFromOutfitPreset(outfitPreset) {
  let outfitData = findModelDataForOutfitID(root.mountsModel, outfitPreset.mountID, false);
  if (!outfitData || outfitData.outfitType != TibiaEnums.OutfitTypeOwned) {
    outfitPreset.mountID = 0;
  }
}

function sendEnteredDataToController() {
  if(okButton.enabled && controller != null) {
    let outfitPreset = currentSettingsToOutfitPreset();
    removeInvalidMountFromOutfitPreset(outfitPreset);
    controller.setCharacterConfiguration(outfitPreset, root._LOOK_DIRECTIONS[root.lookDirectionIndex], outfitPreviewPanel.socketID != 0, dialogSettings.showMount.value);
  }
} //function sendEnteredDataToController

function configureDialogByDialogMode(dialogMode) {
    _upperCheckBoxesCaption = qsTrId("preview_caption");
    _lowerCheckBoxesCaption = qsTrId("configure_caption");

    let newOutfitOptionTypes = [];

    switch (dialogMode) {
      case OutfitDialogController.SelectOutfit:
        root._dialogCaption = qsTrId("select_outfit_caption");
        _upperCheckBoxesModel = [
            dialogSettings.checkboxShowMovement
          , dialogSettings.checkboxShowOutfit
          , dialogSettings.checkboxShowSummon
          , dialogSettings.checkboxShowFloor
        ];
        _lowerCheckBoxesModel = [
            dialogSettings.checkboxShowAddOn1
          , dialogSettings.checkboxShowAddOn2
          , dialogSettings.checkboxShowMount
          , dialogSettings.checkboxRandomMount
        ];
        dialogSettings.valueChanged.connect(checkThatEitherOutfitOrMountAreSet);
        newOutfitOptionTypes = [OutfitDialog.OutfitOptionType.Outfits,
                              OutfitDialog.OutfitOptionType.Mounts,
                              OutfitDialog.OutfitOptionType.Summons,
                              OutfitDialog.OutfitOptionType.Presets]
        break;
      case OutfitDialogController.TryOutfit:
        root._dialogCaption = qsTrId("try_outfit_caption");
        _upperCheckBoxesModel = [
            dialogSettings.checkboxShowMovement
          , dialogSettings.checkboxShowOutfit
          , dialogSettings.checkboxShowFloor
        ];
        _lowerCheckBoxesModel = [
            dialogSettings.checkboxShowAddOn1
          , dialogSettings.checkboxShowAddOn2
          , dialogSettings.checkboxShowMount
        ];
        dialogSettings.showOutfit.value = true;
        dialogSettings.showOutfit.enabled = false;
        dialogSettings.filterOnlyOwnOutfits.enabled = false;
        dialogSettings.filterOnlyOwnOutfits.value = false;
        newOutfitOptionTypes = [OutfitDialog.OutfitOptionType.Outfits,
          OutfitDialog.OutfitOptionType.Mounts,
          OutfitDialog.OutfitOptionType.Summons]
        break;
      case OutfitDialogController.TryMount:
        root._dialogCaption = qsTrId("try_mount_caption")
        _upperCheckBoxesModel = [
            dialogSettings.checkboxShowMovement
          , dialogSettings.checkboxShowOutfit
          , dialogSettings.checkboxShowFloor
        ];
        _lowerCheckBoxesModel = [
            dialogSettings.checkboxShowAddOn1
          , dialogSettings.checkboxShowAddOn2
          , dialogSettings.checkboxShowMount
        ];
        dialogSettings.showMount.value = true;
        dialogSettings.showMount.enabled = false;
        dialogSettings.filterOnlyOwnMounts.enabled = false;
        dialogSettings.filterOnlyOwnMounts.value = false;
        newOutfitOptionTypes = [OutfitDialog.OutfitOptionType.Outfits,
          OutfitDialog.OutfitOptionType.Mounts]
        break;
      case OutfitDialogController.HirelingSelectOutfit:
        root._dialogCaption = qsTrId("hireling_select_outfit_caption");
        _upperCheckBoxesModel = [
            dialogSettings.checkboxShowFloor
        ];
        _lowerCheckBoxesModel = [ ];
        dialogSettings.filterOnlyOwnMounts.visible = false;
        dialogSettings.showMovement.value = false;
        dialogSettings.showMovement.enabled = false;
        newOutfitOptionTypes = [OutfitDialog.OutfitOptionType.Outfits]
        break;
      case OutfitDialogController.HirelingTryOutfit:
        root._dialogCaption = qsTrId("hireling_try_outfit_caption");
        _upperCheckBoxesModel = [
            dialogSettings.checkboxShowFloor
        ];
        _lowerCheckBoxesModel = [ ];
        dialogSettings.filterOnlyOwnMounts.visible = false;
        dialogSettings.showMovement.value = false;
        dialogSettings.showMovement.enabled = false;
        newOutfitOptionTypes = [OutfitDialog.OutfitOptionType.Outfits]
        break;
      case OutfitDialogController.CharacterInfoShowSelection:
        root._dialogCaption = qsTrId("character_info_caption");
        _upperCheckBoxesModel = [
            dialogSettings.checkboxShowMovement
          , dialogSettings.checkboxShowOutfit
          , dialogSettings.checkboxShowSummon
          , dialogSettings.checkboxShowFloor
        ];
        _lowerCheckBoxesModel = [
            dialogSettings.checkboxShowAddOn1
          , dialogSettings.checkboxShowAddOn2
          , dialogSettings.checkboxShowMount
        ];
        dialogSettings.valueChanged.connect(checkThatEitherOutfitOrMountAreSet);
        newOutfitOptionTypes = [OutfitDialog.OutfitOptionType.Outfits,
          OutfitDialog.OutfitOptionType.Mounts,
          OutfitDialog.OutfitOptionType.Summons]
        break;
      case OutfitDialogController.ConfigureShowOffSocket:
        root._dialogCaption = qsTrId("configure_show_off_socket_caption");
        _upperCheckBoxesModel = [
            dialogSettings.checkboxShowFloor
        ];
        _lowerCheckBoxesModel = [
            { "dialogSetting": dialogSettings.showOutfit, "caption":  qsTrId("outfit_caption") }
          , dialogSettings.checkboxShowAddOn1
          , dialogSettings.checkboxShowAddOn2
          , dialogSettings.checkboxShowMount
          , dialogSettings.checkboxShowSocket
        ];
        summonCurrentModelData = null;
        dialogSettings.showMovement.value = false;
        dialogSettings.showMovement.enabled = false;
        dialogSettings.valueChanged.connect(checkThatEitherOutfitOrMountOrSocketAreSet);
        newOutfitOptionTypes = [OutfitDialog.OutfitOptionType.Outfits,
          OutfitDialog.OutfitOptionType.Mounts,
          OutfitDialog.OutfitOptionType.Presets]
        break;
    }
    let hasSummons = root.summonsModel && root.summonsModel.rowCount() > 0;
    if (!hasSummons) {
      newOutfitOptionTypes = newOutfitOptionTypes.filter(item => item !== OutfitDialog.OutfitOptionType.Summons);
    }
    let hasMounts = root.mountsModel && root.mountsModel.rowCount() > 0;
    if (!hasMounts) {
      newOutfitOptionTypes = newOutfitOptionTypes.filter(item => item !== OutfitDialog.OutfitOptionType.Mounts);
    }

    root.outfitOptionTypes = newOutfitOptionTypes;
}

function switchGender(newGender)
{
  if (root.outfitCurrentModelData != null) {
    if (root.outfitGender != newGender) {
      root.outfitGender = newGender;
      let useOtherGender = root.outfitCurrentModelData.outfitGender != root.outfitGender;
      let newSelectedOutfitID = root.outfitCurrentModelData.outfitGender == newGender ? root.outfitCurrentModelData.outfitID : root.outfitCurrentModelData.otherGenderOutfitID;
      root.outfitCurrentModelData = root.outfitCurrentModelData;
      checkForListSelectionAfterModelChange();
      root.selectedOutfitID = newSelectedOutfitID;
    }
  } else {
    outfitGender = OutfitDialogController.OutfitGenderUnknown;
  }
}

function checkForAddOnsAfterModelChange() {
  Qt.callLater(function() {
    if (outfitCurrentModelData != null) {
      dialogSettings.showAddOn1.enabled = dialogSettings.showOutfit.value && outfitCurrentModelData.firstAddOn;
      dialogSettings.showAddOn2.enabled = dialogSettings.showOutfit.value && outfitCurrentModelData.secondAddOn;
    } else {
      dialogSettings.showAddOn1.enabled = false;
      dialogSettings.showAddOn2.enabled = false;
    }
    if (dialogSettings.showAddOn1.enabled == false) {
      dialogSettings.showAddOn1.value = false;
    } else {
      dialogSettings.showAddOn1.value = root.firstAddOnShouldBeSelected;
    }
    if (dialogSettings.showAddOn2.enabled == false) {
      dialogSettings.showAddOn2.value = false;
    } else {
      dialogSettings.showAddOn2.value = root.secondAddOnShouldBeSelected;
    }
  });
}

function checkForListSelectionAfterModelChange() {
  if (outfitSelectionList) {
    if (currentOutfitTypeOption == OutfitDialog.OutfitOptionType.Outfits) {
      outfitSelectionList.setModel(root.outfitsModel, root.selectedOutfitID);
    } else if (currentOutfitTypeOption == OutfitDialog.OutfitOptionType.Mounts) {
      outfitSelectionList.setModel(root.mountsModel, root.selectedMountID);
    } else if (currentOutfitTypeOption == OutfitDialog.OutfitOptionType.Summons) {
      outfitSelectionList.setModel(root.summonsModel, root.selectedSummonID);
    } else if (currentOutfitTypeOption == OutfitDialog.OutfitOptionType.Presets) {
      selectionListLoader.item.setModel(root.presetsModel, root.selectedPresetIndex);
    }
  }
}

function fixOutfitColors(outfitColors) {
  function fixColorIndex(fieldName) {
    const HSV_COLORS = 19 * 7; // 18 values for hue (plus 1 for shades of grey); 7 values for combined saturation and value
    let colorIndex = outfitColors[fieldName];
    let newColorIndex = colorIndex > HSV_COLORS - 1 ? 0 : colorIndex;
    if (newColorIndex != colorIndex) {
      outfitColors[fieldName] = newColorIndex;
    }
  }
  fixColorIndex("headColorIndex");
  fixColorIndex("torsoColorIndex");
  fixColorIndex("legsColorIndex");
  fixColorIndex("detailColorIndex");
}

function changeToOutfitPreset(outfitPreset, isControllerChange) {
  if (outfitPreset.outfitID != 0) {
    let newOutfitData = findModelDataForOutfitID(root.outfitsModel, outfitPreset.outfitID, true);
    if (newOutfitData != null) {
      if (newOutfitData.outfitID != outfitPreset.outfitID) {
        root.outfitGender = getOtherGender(newOutfitData["outfitGender"]);
      } else {
        root.outfitGender = newOutfitData["outfitGender"];
      }
      root.outfitCurrentModelData = newOutfitData;
    } else {
      root.outfitGender = OutfitDialogController.OutfitGenderUnknown;
    }
    outfitPreviewPanel.outfitPreset.outfitColor.copyFrom(outfitPreset.outfitColor);
    root.firstAddOnShouldBeSelected = outfitPreset.outfitFirstAddOn;
    root.secondAddOnShouldBeSelected = outfitPreset.outfitSecondAddOn;
  }

  if (outfitPreset.mountID != 0) {
    root.mountCurrentModelData = findModelDataForOutfitID(root.mountsModel, outfitPreset.mountID, true);
    outfitPreviewPanel.outfitPreset.mountColor.copyFrom(outfitPreset.mountColor);
  } else {
    if (!isControllerChange) {
      dialogSettings.showMount.value = outfitPreset.mountID != 0 ? 1 : 0;
        //TIBIA-34315:  even if no mount is configured, take the colors from the server
    }
    outfitPreviewPanel.outfitPreset.mountColor.copyFrom(outfitPreset.mountColor);
  }

  if (outfitPreset.summonID != 0) {
    root.summonCurrentModelData = findModelDataForOutfitID(root.summonsModel, outfitPreset.summonID, true);
  }

  if (controller.dialogMode == OutfitDialogController.ConfigureShowOffSocket) {
    if (!isControllerChange) {
      dialogSettings.showOutfit.value = outfitPreset.outfitID != 0;
    }
  }
  checkForListSelectionAfterModelChange();
  checkForGenderAfterModelChange();
  checkIfCanBeColorizedAfterModelChange();
}

function onControllerChanged() {
  dialogSettings.showFloor.value = controller.showFloor;
  dialogSettings.showSummon.enabled = summonsModel != null && summonsModel.rowCount() > 0
  dialogSettings.showSummon.value = dialogSettings.showSummon.enabled && summonsModel != null && summonsModel.rowCount() > 0 && controller.showSummon;
  dialogSettings.showMount.enabled = mountsModel != null && mountsModel.rowCount() > 0
  dialogSettings.showMount.value = dialogSettings.showMount.enabled && controller.isMounted;
  dialogSettings.randomMount.value = controller.randomMount;
  dialogSettings.showSocket.value = isForShowSocketConfiguration ? controller.showSocket : false;
  dialogSettings.showOutfit.value = controller.showOutfit;
  dialogSettings.showMovement.value = !isForShowSocketConfiguration ? controller.showMovement : false;

  let currentOutfitPreset = controller.selectedOutfitPreset;

  configureDialogByDialogMode(controller.dialogMode);

  dialogSettings.filterOnlyOwnOutfits.valueChanged.connect(function() {
    root.outfitsModel.showOnlyOwnOutfits = dialogSettings.filterOnlyOwnOutfits.value;
  });
  dialogSettings.filterOnlyOwnMounts.valueChanged.connect(function() {
    root.mountsModel.showOnlyOwnOutfits = dialogSettings.filterOnlyOwnMounts.value;
  });

  // preselect mount if no mount is selected yet and mounts are available
  if (currentOutfitPreset.mountID == 0 && mountsModel.rowCount() > 0) {
    let _helperModel = AbstractItemModelHelper.wrapInHelperProxyModel(mountsModel);
    root.mountCurrentModelData = _helperModel.sourceItemDataByRowIndex(0);
  }

  changeToOutfitPreset(currentOutfitPreset, true);

  for (var i = 0; i < _LOOK_DIRECTIONS.length; i++) {
    if (_LOOK_DIRECTIONS[i] == controller.direction) {
      lookDirectionIndex = i;
      break;
    }
  }

  checkForOwnOutfits();
  checkForOwnMounts();

  dialogSettings.valueChanged.connect(checkIfCustomizationCanBeConfirmed);
  dialogSettings.valueChanged.connect(checkForAddOnsAfterModelChange);
  dialogSettings.valueChanged.connect(writeBackSettingsToController);
  dialogSettings.showAddOn1.valueChanged.connect(writeBackConfirmedAddOn1Settings);
  dialogSettings.showAddOn2.valueChanged.connect(writeBackConfirmedAddOn2Settings);

  currentOutfitTypeOptionChanged();
}

function currentOutfitTypeOptionChanged() {
  if (controller == null || selectionListLoader == null) {
    return;
  }
  switch (currentOutfitTypeOption) {
    case OutfitDialog.OutfitOptionType.Outfits:
      selectionListLoader.sourceComponent = outfitSelectionComponent;
      selectionListLoader.item.outfitSelected.connect(retrieveCurrentModelData);
      root._rightPanelUpperCaption = qsTrId("filter_outfits_caption");
      colorSelectionGrid.currentOutfitColor = outfitPreviewPanel.outfitPreset.outfitColor;
      outfitDialogLayout.rightPanelUpperComponent = outfitFilterComponent;
      break;
    case OutfitDialog.OutfitOptionType.Mounts:
      selectionListLoader.sourceComponent = outfitSelectionComponent;
      selectionListLoader.item.outfitSelected.connect(retrieveCurrentModelData);
      root._rightPanelUpperCaption = qsTrId("filter_outfits_caption");
      outfitDialogLayout.rightPanelUpperComponent = outfitFilterComponent;
      colorSelectionGrid.currentOutfitColor = outfitPreviewPanel.outfitPreset.mountColor;
      break;
    case OutfitDialog.OutfitOptionType.Summons:
      selectionListLoader.sourceComponent = outfitSelectionComponent;
      selectionListLoader.item.outfitSelected.connect(retrieveCurrentModelData);
      root._rightPanelUpperCaption = qsTrId("filter_outfits_caption");
      outfitDialogLayout.rightPanelUpperComponent = outfitFilterComponent;
      colorSelectionGrid.currentOutfitColor = TibiaObjects.createOutfitColor();
      break;
    case OutfitDialog.OutfitOptionType.Presets:
      selectionListLoader.sourceComponent = outfitPresetSelectionComponent;
      selectionListLoader.item.presetSelected.connect(retrieveCurrentModelData);
      root._rightPanelUpperCaption = qsTrId("manage_presets_caption");
      outfitDialogLayout.rightPanelUpperComponent = presetButtonsComponent;
      colorSelectionGrid.currentOutfitColor = TibiaObjects.createOutfitColor();
      break;
  }
  checkForListSelectionAfterModelChange();

  if (root.outfitFilterItem) {
    root.outfitFilterItem.resetFilter();
  }
}

function findModelDataForOutfitID(model, outfitID, selectFirstItemIfNotFound = false) {
  var modelData = null;
  if (model && model.rowCount() > 0) {
    if (root.outfitFilterItem) {
      root.outfitFilterItem.resetFilter();
    }
    model.resetFilter();
    let _helperModel = AbstractItemModelHelper.wrapInHelperProxyModel(model);
    if (outfitID != 0) {
      for (var i = 0; i < _helperModel.rowCount(); i++) {
        var tempModelData = _helperModel.sourceItemDataByRowIndex(i);
        if (selectFirstItemIfNotFound && modelData == null) {
          modelData = tempModelData;
        }
        if (tempModelData.outfitID == outfitID || tempModelData.otherGenderOutfitID == outfitID) {
          modelData = tempModelData;
          break;
        }
      }
    }
  }
  return modelData;
}

function currentSettingsToOutfitPreset(presetName = "") {
  let newPreset = TibiaObjects.outfitPreset();
  newPreset.name = presetName;

  //TIBIA-33123, TIBIA-32144 always save everything independent of view settings
  let storeOutfitData = true;
  //... except for the socket configuration
  if (controller.dialogMode == OutfitDialogController.ConfigureShowOffSocket) {
    storeOutfitData = dialogSettings.showOutfit.value;
  }

  newPreset.mountID = selectedMountID;
  newPreset.mountColor.copyFrom(outfitPreviewPanel.outfitPreset.mountColor);

  if (storeOutfitData) {
    newPreset.outfitID = selectedOutfitID;
    newPreset.outfitColor.copyFrom(outfitPreviewPanel.outfitPreset.outfitColor);
    newPreset.outfitFirstAddOn = outfitPreviewPanel.outfitPreset.outfitFirstAddOn;
    newPreset.outfitSecondAddOn = outfitPreviewPanel.outfitPreset.outfitSecondAddOn;
  }

  newPreset.summonID = selectedSummonID;

  return newPreset;
}

function outfitPresetsSaveIndex() {
  let newPreset = currentSettingsToOutfitPreset("Preset");
  controller.outfitPresetsSaveIndex(newPreset.toJsonObject(), -1);
}

function outfitPresetsOverwriteIndex() {

  let _helperModel = AbstractItemModelHelper.wrapInHelperProxyModel(controller.presetsModel);
  if (presetSelectionList.selectedPresetIndex != -1 && presetSelectionList.selectedPresetIndex < _helperModel.rowCount()) {
    var tempModelData = _helperModel.sourceItemDataByRowIndex(presetSelectionList.selectedPresetIndex);
    let newPreset = currentSettingsToOutfitPreset(tempModelData.jsondata.name);
    controller.outfitPresetsSaveIndex(newPreset.toJsonObject(), presetSelectionList.selectedPresetIndex);
  }
}

function outfitPresetsDeleteIndex() {
  controller.outfitPresetsDeleteIndex(presetSelectionList.selectedPresetIndex);
  presetSelectionList.selectPreset(-1);
  root.selectedPresetIndex = -1;
}

function outfitPresetsRenameIndex() {
  controller.outfitPresetsRenameIndex(presetSelectionList.selectedPresetIndex);
}

function outfitFilterOnlyMineChanged(checked) {
  if (root.currentOutfitTypeOption == OutfitDialog.OutfitOptionType.Outfits) {
    if (dialogSettings.filterOnlyOwnOutfits.value != checked) {
      dialogSettings.filterOnlyOwnOutfits.value = checked;
    }
  } else if (root.currentOutfitTypeOption == OutfitDialog.OutfitOptionType.Mounts) {
    if (dialogSettings.filterOnlyOwnMounts.value != checked) {
      dialogSettings.filterOnlyOwnMounts.value = checked;
    }
  }
}

function outfitFilterSearchOutfit(searchString) {
  if (root.currentOutfitTypeOption == OutfitDialog.OutfitOptionType.Outfits) {
    root.outfitsModel.outfitNameFilter = searchString;
  } else if (root.currentOutfitTypeOption == OutfitDialog.OutfitOptionType.Mounts) {
    root.mountsModel.outfitNameFilter = searchString;
  } else if (root.currentOutfitTypeOption == OutfitDialog.OutfitOptionType.Summons) {
    root.summonsModel.outfitNameFilter = searchString;
  }
}

function createDataFromClipboard() {
  let jsonObject = ClipboardHelper.getBase64StringAsJsonObject();
  if (jsonObject == null) {
    return null;
  }
  let newPreset = TibiaObjects.outfitPreset();
  if (newPreset.canBeFilledFromJsonObject(jsonObject)) {
    newPreset.fromJsonObject(jsonObject);
    fixOutfitColors(newPreset.outfitColor);
    fixOutfitColors(newPreset.mountColor);
    return newPreset;
  }
  let newColor = TibiaObjects.createOutfitColor(0,0,0,0);
  if (newColor.canBeFilledFromJsonObject(jsonObject)) {
    newColor.fromJsonObject(jsonObject);
    fixOutfitColors(newColor);
    return newColor;
  }
  return null;
}
