import QtQuick
import QtQuick.Layouts
import qmlcomponents



TibiaDialog {
  id: dialogRoot
  caption: controller != null
          ? (controller.showActionBarTarget ? qsTrId("actionbar_assign_spell_dialog_caption").arg(actionBarName) : qsTrId("actionbar_assign_spell_dialog_caption_short"))
          : qsTrId("dummy_unknown")
  width: 375

  property var controller: null
  property var currentModelData: null
  property bool spellSelected: currentModelData != null
  property string actionBarName: controller != null ? controller.buttonName : qsTrId("actionbar_button_identifier").arg(0).arg(0)
  property bool spellNeedsParameters: currentModelData ? currentModelData.parameterHints.length > 0 : false
  property bool spellIsCrossHairSpell: currentModelData ? currentModelData.isCrossHairSpell : false

  onReturnPressedFunction: okClicked
  onCancelPressedFunction: closeClicked
  initialFocusItem: searchField

  function okClicked() {
    if (controller != null) {
      controller.onOkClicked(parameterTextField.text, castType.spellTargetTypeEnumID);
    }
  } //function okClicked

  function assignSpell() {
    if (controller != null) {
      controller.onApplyClicked(parameterTextField.text, castType.spellTargetTypeEnumID);
    }
  } //function assignSpell

  function closeClicked() {
    if (controller != null) {
      controller.onCloseClicked();
    }
  } //function closeClicked

  function setParameters() {
    parameterTextField.text = controller != null ? controller.spellParameters : "";
  } //function setParameters()

  function setSpellCastType() { 
    if (controller) {
      castType.spellTargetTypeEnumID = controller.currentSpellCastType;
      if (spellIsCrossHairSpell && castType.spellTargetTypeEnumID == TibiaEnums.ESpellCastOptionalTargetType.None) {
        castType.spellTargetTypeEnumID = TibiaEnums.ESpellCastOptionalTargetType.Crosshair; // crosshair is default
      }
    }
  }

  ColumnLayout {
    anchors { left: parent.left; right: parent.right }
    spacing: TibiaStyle.marginUnrelated

    RowLayout {
      Layout.fillWidth: true
      spacing: TibiaStyle.marginRelated

      Image {
        Layout.preferredHeight: TibiaStyle.spellListIconSize
        source: currentModelData ? currentModelData.iconUrl : ""
        onSourceChanged: {
          dialogRoot.setParameters(); //neede to react on the change of the current spell
          dialogRoot.setSpellCastType();
        }
      } //Image

      ColumnLayout {
        spacing: 0
        Layout.fillWidth: true

        TibiaText {
          Layout.fillWidth: true
          text: currentModelData ? currentModelData.name : ""
          visible: dialogRoot.spellSelected
        } // TibiaText

        TibiaText {
          Layout.fillWidth: true
          visible: !dialogRoot.spellSelected
          text: qsTrId("actionbar_assign_spell_dialog_no_spell_selected")
        } //TibiaText

        TibiaText {
          Layout.fillWidth: true
          text: (currentModelData ? currentModelData.formulaRaw : "") + (parameterTextField.text != "" ? " " + parameterTextField.text : "")
        } // TibiaText
      } //ColumnLayout
    } //RowLayout

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } //TibiaHorizontalSeparator

    ColumnLayout {
      Layout.fillWidth: true
      spacing: TibiaStyle.marginRelated

      TibiaFrame1PixelDown {
        Layout.fillWidth: true
        Layout.preferredHeight: 420

        ColumnLayout {
          anchors.fill: parent
          anchors.margins: parent.borderWidth

          TibiaTextSearchField {
            id: searchField
            Layout.fillWidth: true
            onSearchTextChanged: {
              if (spellList.model != null) {
                spellList.model.filterText = searchText;
              }
            } //onSearchTextChanged
          } //TibiaTextSearchField

          TibiaScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: spellList.width

            SpellList {
              id: spellList

              KeyNavigation.tab: parameterTextField

              model: controller != null ? controller.spellListModel : null
              externalSelectedIndex: controller != null ? controller.spellListIndex : -1
              showOnlyKnownSpells: controller != null && controller.showOnlyKnownSpells
              showSpellgroup: true

              onSpellSelected: (spellEnumId) => {
                if (controller != null) {
                  controller.spellSelected(spellEnumId);
                  var _helperModel = AbstractItemModelHelper.wrapInHelperProxyModel(model);
                  var newModelData = null;
                  for (var i = 0; i < _helperModel.rowCount(); i++) {
                    var tempModelData = _helperModel.sourceItemDataByRowIndex(i);
                    if (spellEnumId == tempModelData.enumId) {
                      newModelData = tempModelData;
                      break;
                    }
                  }
                  currentModelData = newModelData;
                }
              } //onSpellSelected
            } //SpellList
          } //TibiaScrollView
        } //ColumnLayout
      } // TibiaFrame1PixelDown

      TibiaMenuOptionCheckBox {
        id: showOnlyKnownSpells
        text: qsTrId("actionbar_assign_spell_dialog_label_showonlyknownspells")
        Layout.fillWidth: true
        checked: controller != null && controller.showOnlyKnownSpells
        Binding {
          target: controller
          property: "showOnlyKnownSpells"
          value: showOnlyKnownSpells.checked
        } //Binding
      } //TibiaMenuOptionCheckBox

      RowLayout {
        Layout.fillWidth: true
        spacing: TibiaStyle.marginRelated
        enabled: spellNeedsParameters

        TibiaText {
          text: qsTrId("actionbar_assign_spell_dialog_label_parameters")
        } //TibiaText

        TibiaTextField {
          id: parameterTextField
          Layout.fillWidth: true
          KeyNavigation.tab: spellList
          text: controller != null ? controller.spellParameters : ""
          maximumLength: TibiaStyle.chatInputMaxLength - (currentModelData ? currentModelData.formulaRaw.length + 1 : 0)
          placeholderText: currentModelData ? currentModelData.parameterHints : ""
        } //TibiaTextField
      } //RowLayout

      ColumnLayout {
        Layout.fillWidth: true
        spacing: TibiaStyle.marginRelated
        visible: spellIsCrossHairSpell
        
        ButtonGroup {
          id: castType
          property int spellTargetTypeEnumID: TibiaEnums.ESpellCastOptionalTargetType.None

          checkedButton: {
            if (controller != null) {
              if (controller.currentSpellCastType == TibiaEnums.ESpellCastOptionalTargetType.Crosshair) {
                return castTypeCrossHair;
              } else if (controller.currentSpellCastType == TibiaEnums.ESpellCastOptionalTargetType.AtMousePosition) {
                return castTypeMouseCursor;
              } else if (controller.currentSpellCastType == TibiaEnums.ESpellCastOptionalTargetType.AtTargetOrSelf) {
                return castTypeAtTargetOrSelf;
              }
            }
            return castTypeCrossHair;
          }

          onCheckedButtonChanged: {
            if (checkedButton == castTypeCrossHair) {
              castType.spellTargetTypeEnumID = TibiaEnums.ESpellCastOptionalTargetType.Crosshair;
            } else if (checkedButton == castTypeMouseCursor) {
              castType.spellTargetTypeEnumID = TibiaEnums.ESpellCastOptionalTargetType.AtMousePosition;
            } else if (checkedButton == castTypeAtTargetOrSelf) {
              castType.spellTargetTypeEnumID = TibiaEnums.ESpellCastOptionalTargetType.AtTargetOrSelf;
            } else {
              castType.spellTargetTypeEnumID = TibiaEnums.ESpellCastOptionalTargetType.None;
            }
          } //onCurrentChanged
        } //ButtonGroup

        TibiaRadioButton {
          id: castTypeCrossHair
          text: qsTrId("actionbar_assign_spell_dialog_option_crosshair")
          ButtonGroup.group: castType
          enabled: spellIsCrossHairSpell
        } //TibiaRadioButton

        TibiaRadioButton {
          id: castTypeMouseCursor
          text: qsTrId("actionbar_assign_spell_dialog_option_mousecursor")
          ButtonGroup.group: castType
          enabled: spellIsCrossHairSpell
        } //TibiaRadioButton    
        
        TibiaRadioButton {
          id: castTypeAtTargetOrSelf
          text: qsTrId("actionbar_assign_spell_dialog_option_target")
          ButtonGroup.group: castType
          enabled: spellIsCrossHairSpell
        } //TibiaRadioButton 
      
      } // ColumnLayout

    } //ColumnLayout

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } //TibiaHorizontalSeparator

    RowLayout {
      Layout.alignment: Qt.AlignRight
      spacing: TibiaStyle.marginRelated

      Item {Layout.fillWidth: true}

      TibiaButton {
        text: qsTrId("ok")
        onClicked: dialogRoot.okClicked();
        enabled: dialogRoot.spellSelected
      } // TibiaButton

      TibiaButton {
        text: qsTrId("apply")
        onClicked: dialogRoot.assignSpell();
        enabled: dialogRoot.spellSelected
      } // TibiaButton

      TibiaButton {
        text: qsTrId("cancel")
        onClicked: dialogRoot.closeClicked();
      } // TibiaButton
    } // RowLayout
  } // ColumnLayout
} // TibiaDialog
