import QtQuick
import QtQuick.Layouts

import qmlcomponents
import qmlenumvalues

TibiaDialog {
  id: dialogRoot
  caption: qsTrId("options")
  width: 685

  required property QtObject controller

  initialFocusItem: dialogRoot
  KeyNavigation.tab: dialogRoot

  onReturnPressedFunction: undefined
  onCancelPressedFunction: onCancelClicked

  function onCancelClicked() {
    if (controller != null) {
      controller.cancelButtonClicked();
    }
  } //function onCancelClicked

  function onApplyClicked() {
    if (controller != null) {
      controller.applyButtonClicked();
    }
  } //function onApplyClicked

  function onOkClicked() {
    if (controller != null) {
      controller.okButtonClicked();
    }
  } //function onOkClicked

  Component {
    id: menuListModel

    ListModel {
      function withButton(id, name, imageUrl = "") {
        this.append({
          "categoryId": id,
          "categoryName": name,
          "categoryImageUrl": imageUrl,
        });
        return this;
      }
    }
  }

  function createButtonModel() {
    return menuListModel.createObject(dialogRoot, { });
  }

  ColumnLayout {
    anchors { left: parent.left; top: parent.top; right: parent.right }
    spacing: TibiaStyle.marginUnrelated

    RowLayout {
      Layout.fillWidth: true
      spacing: TibiaStyle.marginRelated

      TibiaFrame2PixelUpFilled {
        Layout.preferredWidth: 115 + 2 * margin
        readonly property int margin: borderWidth + TibiaStyle.marginRelated
        dark: true

        Layout.fillHeight: true

        ColumnLayout {
          anchors { left: parent.left; top: parent.top; right: parent.right }
          anchors.margins: parent.margin
          spacing: TibiaStyle.marginUnrelated


          MenuWithSubMenu {
            Layout.fillWidth: true
            controller: dialogRoot.controller
            visible: !showAdvancedCheckBox.checked

            categories: createButtonModel()
                          .withButton(OptionsMenuDialogController.Basic,          qsTrId("optionsmenu_basic_options"), "/images/icon-options.png");
          } //MenuWithSubMenu

          MenuWithSubMenu {
            Layout.fillWidth: true
            controller: dialogRoot.controller
            visible: !showAdvancedCheckBox.checked

            categories: createButtonModel()
                          .withButton(OptionsMenuDialogController.DefaultHotkeys,   qsTrId("optionsmenu_default_hotkeys_basic_name"), "/images/icon-controls.png");
          } //MenuWithSubMenu

          MenuWithSubMenu {
            Layout.fillWidth: true
            controller: dialogRoot.controller
            visible: !showAdvancedCheckBox.checked

            categories: createButtonModel()
                          // we need some extra space on the button caption since it would touch the icon otherwise
                          .withButton(OptionsMenuDialogController.ButtonBar,      "   " + qsTrId("optionsmenu_button_bar"), "/images/icon-interface.png");
          } //MenuWithSubMenu

          MenuWithSubMenu {
            Layout.fillWidth: true
            controller: dialogRoot.controller
            visible: !showAdvancedCheckBox.checked

            categories: createButtonModel()
                          .withButton(OptionsMenuDialogController.Help,             qsTrId("optionsmenu_help"), "/images/icon-help.png");
          } //MenuWithSubMenu

          MenuWithSubMenu {
            Layout.fillWidth: true
            controller: dialogRoot.controller
            visible: showAdvancedCheckBox.checked

            categories: createButtonModel()
                          .withButton(OptionsMenuDialogController.Controls,             qsTrId("optionsmenu_controls"), "/images/icon-controls.png")
                          .withButton(OptionsMenuDialogController.DefaultHotkeys,       qsTrId("optionsmenu_default_hotkeys"))
                          .withButton(OptionsMenuDialogController.ActionButtonsHotkeys, qsTrId("optionsmenu_action_buttons_hotkeys"))
                          .withButton(OptionsMenuDialogController.CustomHotkeys,        qsTrId("optionsmenu_individual_hotkeys"))
          } //MenuWithSubMenu

          MenuWithSubMenu {
            Layout.fillWidth: true
            controller: dialogRoot.controller
            visible: showAdvancedCheckBox.checked

            categories: createButtonModel()
                          .withButton(OptionsMenuDialogController.Interface,        qsTrId("optionsmenu_interface"), "/images/icon-interface.png")
                          .withButton(OptionsMenuDialogController.HUD,              qsTrId("optionsmenu_hud"))
                          .withButton(OptionsMenuDialogController.Console,          qsTrId("optionsmenu_console"))
                          .withButton(OptionsMenuDialogController.GameWindow,       qsTrId("optionsmenu_game_window"))
                          .withButton(OptionsMenuDialogController.ActionBars,       qsTrId("optionsmenu_action_bars"))
                          .withButton(OptionsMenuDialogController.ButtonBar,        qsTrId("optionsmenu_button_bar"))
          } //MenuWithSubMenu

          MenuWithSubMenu {
            Layout.fillWidth: true
            controller: dialogRoot.controller
            visible: showAdvancedCheckBox.checked

            categories: createButtonModel()
                          .withButton(OptionsMenuDialogController.Graphics,        qsTrId("optionsmenu_graphics"), "/images/icon-graphics.png")
                          .withButton(OptionsMenuDialogController.Effects,         qsTrId("optionsmenu_effects"))
          } //MenuWithSubMenu

          MenuWithSubMenu {
            Layout.fillWidth: true
            controller: dialogRoot.controller
            visible: showAdvancedCheckBox.checked

            categories: createButtonModel()
                          .withButton(OptionsMenuDialogController.Sound,          qsTrId("optionsmenu_sound"), "/images/icon-sound.png")
                          .withButton(OptionsMenuDialogController.BattleSounds,   qsTrId("optionsmenu_battle_sounds"))
                          .withButton(OptionsMenuDialogController.UISounds,       qsTrId("optionsmenu_ui_sounds"))
          } //MenuWithSubMenu

          MenuWithSubMenu {
            Layout.fillWidth: true
            controller: dialogRoot.controller
            visible: showAdvancedCheckBox.checked

            categories: createButtonModel()
                          .withButton(OptionsMenuDialogController.Misc,           qsTrId("optionsmenu_misc"), "/images/icon-misc.png")
                          .withButton(OptionsMenuDialogController.Gameplay,       qsTrId("optionsmenu_gameplay"))
                          .withButton(OptionsMenuDialogController.Screenshots,    qsTrId("optionsmenu_screenshots"))
                          .withButton(OptionsMenuDialogController.Help,           qsTrId("optionsmenu_help"))
          } //MenuWithSubMenu
        } //ColumnLayout
      } //TibiaFrame2PixelUpFilled


      TibiaFrame2PixelUpFilled {
        Layout.fillWidth: true
        Layout.preferredHeight: 470

        Loader {
          id: contentLoader

          anchors.fill: parent
          anchors.margins: parent.borderWidth + TibiaStyle.marginRelated

          Component.onCompleted: {
            setSource(getQmlSourceForCategory(dialogRoot.controller.dialogCategory),
                      {"controller": dialogRoot.controller})
          }

          function getQmlSourceForCategory(category) {
            switch (category) {
              case OptionsMenuDialogController.DefaultHotkeys:
              case OptionsMenuDialogController.ActionButtonsHotkeys:
              case OptionsMenuDialogController.CustomHotkeys:
                return "OptionsPageHotkeys.qml";
              case OptionsMenuDialogController.Controls:
                return "OptionsPageControls.qml";
              case OptionsMenuDialogController.Basic:
                return "OptionsPageBasic.qml";
              case OptionsMenuDialogController.Help:
                return "OptionsPageHelp.qml";
              case OptionsMenuDialogController.ActionBars:
                return "OptionsPageActionBars.qml";
              case OptionsMenuDialogController.ButtonBar:
                return "OptionsPageButtonBar.qml";
              case OptionsMenuDialogController.Console:
                return "OptionsPageConsole.qml";
              case OptionsMenuDialogController.Interface:
                return "OptionsPageInterface.qml";
              case OptionsMenuDialogController.GameWindow:
                return "OptionsPageGameWindow.qml";
              case OptionsMenuDialogController.HUD:
                return "OptionsPageHud.qml";
              case OptionsMenuDialogController.Misc:
                return "OptionsPageMisc.qml";
              case OptionsMenuDialogController.Gameplay:
                return "OptionsPageGameplay.qml";
              case OptionsMenuDialogController.Graphics:
                return "OptionsPageGraphics.qml";
              case  OptionsMenuDialogController.Effects:
                return "OptionsPageEffects.qml";
              case OptionsMenuDialogController.Screenshots:
                return "OptionsPageScreenshots.qml";
              case OptionsMenuDialogController.Sound:
                return "OptionsPageSound.qml";
              case OptionsMenuDialogController.BattleSounds:
                return "OptionsPageBattleSounds.qml";
              case OptionsMenuDialogController.UISounds:
                return "OptionsPageUISounds.qml";
              default:
                return "";
            }
          }

          Connections {
            target: dialogRoot.controller

            function onDialogCategoryChanged() {
              contentLoader.setSource(contentLoader.getQmlSourceForCategory(dialogRoot.controller.dialogCategory),
                                      {"controller": dialogRoot.controller})
            }
          } // Connections

          onItemChanged: {
            if (item != null) {
              if (item.initialFocusItem) {
                item.initialFocusItem.forceActiveFocus();
              }
            }
          }
        } //Loader

      } //TibiaFrame2PixelUpFilled
    } //RowLayout


    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } //TibiaHorizontalSeparator

    RowLayout {
      Layout.alignment: Qt.AlignRight
      spacing: TibiaStyle.marginRelated

      TibiaMenuOptionCheckBox {
        id: showAdvancedCheckBox
        text: qsTrId("optionsmenu_show_advanced_options")
        checked: controller != null ? controller.showAdvancedOptions : false
        onCheckedChanged: {
          if (controller) {
            controller.setShowAdvancedOptions(checked);
          }
        } //onCheckedChanged
      } //TibiaMenuOptionCheckBox

      Item {Layout.fillWidth: true}

      TibiaButton{
        id: okButton
        text: qsTrId("ok")
        onClicked: dialogRoot.onOkClicked()
      } //TibiaButton

      TibiaButton{
        id: applyButton
        text: qsTrId("apply")
        onClicked: dialogRoot.onApplyClicked()
      } //TibiaButton

      TibiaButton {
        id: cancelButton
        text: qsTrId("cancel")
        onClicked: dialogRoot.onCancelClicked()
      } // TibiaButton
    } // RowLayout
  } // ColumnLayout

} // TibiaDialog
