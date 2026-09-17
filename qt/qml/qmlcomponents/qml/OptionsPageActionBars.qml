import QtQuick
import QtQuick.Layouts




TibiaOptionsPage {
  id: root
  implicitHeight: contentLayout.height

  optionsSet: controller != null ? controller.actionBarsOptions : null

  ColumnLayout {
    id: contentLayout
    anchors { left: parent.left; top: parent.top; right: parent.right }
    spacing: TibiaStyle.marginRelated

    OptionsPageActionBarsShowHideSection {
      Layout.fillWidth: true
      optionsSetActionBars: root.optionsSet
    } //OptionsPageActionBarsShowHideSection

    TibiaMenuOptionCheckBox {
      id: showHotkey
      text: qsTrId("optionsmenu_show_hotkey")
      guiHelpText: qsTrId("optionsmenu_show_hotkey_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet!=null && optionsSet.showHotkey
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.showHotkey = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: showAmount
      text: qsTrId("optionsmenu_show_amount")
      guiHelpText: qsTrId("optionsmenu_show_amount_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet!=null && optionsSet.showAmount
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.showAmount = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: showSpellParameters
      text: qsTrId("optionsmenu_show_spell_parameters")
      guiHelpText: qsTrId("optionsmenu_show_spell_parameters_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet!=null && optionsSet.showSpellParameters
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.showSpellParameters = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: showCooldown
      text: qsTrId("optionsmenu_show_coldown")
      guiHelpText: qsTrId("optionsmenu_show_coldown_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet!=null && optionsSet.showCooldown
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.showCooldown = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: showCooldownNumber
      text: qsTrId("optionsmenu_show_cooldown_number")
      guiHelpText: qsTrId("optionsmenu_show_cooldown_number_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet!=null && optionsSet.showCooldownNumber
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.showCooldownNumber = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: allowTooltip
      text: qsTrId("optionsmenu_allow_tooltip")
      guiHelpText: qsTrId("optionsmenu_allow_tooltip_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet!=null && optionsSet.allowTooltip
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.allowTooltip = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: autoInsertSpells
      text: qsTrId("optionsmenu_auto_insert_spells")
      guiHelpText: qsTrId("optionsmenu_auto_insert_spells_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet!=null && optionsSet.autoInsertSpells
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.autoInsertSpells = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaFrame1PixelDownWithGuiHelp {
      Layout.fillWidth: true
      Layout.preferredHeight: clearBottomActionBarsLayout.height + 2 * marginsToContent
      guiHelpText: qsTrId("optionsmenu_clear_actionbar_help")

      GridLayout {
        id: clearBottomActionBarsLayout
        anchors { left: parent.left; top: parent.top; right: parent.right }
        anchors.margins: parent.marginsToContent

        rowSpacing: TibiaStyle.marginRelated
        columnSpacing: TibiaStyle.marginUnrelated
        columns: 5

        /////////////////////////////////////////////////////
        //BOTTOM ACTION BARS

        TibiaText {
          text: qsTrId("optionsmenu_clear_action_bar").arg(qsTrId("bottom"))
        } //TibiaText

        TibiaButton {
          text: qsTrId("optionsmenu_bar").arg(1)
          checkable: true
          useButtonShouldBeChecked: true

          buttonShouldBeChecked: optionsSet != null && optionsSet.clearBottomActionBar1
          onClicked: {
            if (optionsSet != null) {
              optionsSet.onClearBottomActionBar1Clicked();
            }
          } //onClicked
        } //TibiaButton

        TibiaButton {
          text: qsTrId("optionsmenu_bar").arg(2)
          checkable: true
          useButtonShouldBeChecked: true

          buttonShouldBeChecked: optionsSet != null && optionsSet.clearBottomActionBar2
          onClicked: {
            if (optionsSet != null) {
              optionsSet.onClearBottomActionBar2Clicked();
            }
          } //onClicked
        } //TibiaButton

        TibiaButton {
          text: qsTrId("optionsmenu_bar").arg(3)
          checkable: true
          useButtonShouldBeChecked: true

          buttonShouldBeChecked: optionsSet != null && optionsSet.clearBottomActionBar3
          onClicked: {
            if (optionsSet != null) {
              optionsSet.onClearBottomActionBar3Clicked();
            }
          } //onClicked
        } //TibiaButton

        Item {
          Layout.fillWidth: true
        } //Item

        //BOTTOM ACTION BARS
        /////////////////////////////////////////////////////
        //LEFT ACTION BARS

        TibiaText {
          text: qsTrId("optionsmenu_clear_action_bar").arg(qsTrId("left"))
        } //TibiaText

        TibiaButton {
          text: qsTrId("optionsmenu_bar").arg(1)
          checkable: true
          useButtonShouldBeChecked: true

          buttonShouldBeChecked: optionsSet != null && optionsSet.clearLeftActionBar1
          onClicked: {
            if (optionsSet != null) {
              optionsSet.onClearLeftActionBar1Clicked();
            }
          } //onClicked
        } //TibiaButton

        TibiaButton {
          text: qsTrId("optionsmenu_bar").arg(2)
          checkable: true
          useButtonShouldBeChecked: true

          buttonShouldBeChecked: optionsSet != null && optionsSet.clearLeftActionBar2
          onClicked: {
            if (optionsSet != null) {
              optionsSet.onClearLeftActionBar2Clicked();
            }
          } //onClicked
        } //TibiaButton

        TibiaButton {
          text: qsTrId("optionsmenu_bar").arg(3)
          checkable: true
          useButtonShouldBeChecked: true

          buttonShouldBeChecked: optionsSet != null && optionsSet.clearLeftActionBar3
          onClicked: {
            if (optionsSet != null) {
              optionsSet.onClearLeftActionBar3Clicked();
            }
          } //onClicked
        } //TibiaButton

        Item {
          Layout.fillWidth: true
        } //Item

        //LEFT ACTION BARS
        /////////////////////////////////////////////////////
        //RIGHT ACTION BARS

        TibiaText {
          text: qsTrId("optionsmenu_clear_action_bar").arg(qsTrId("right"))
        } //TibiaText

        TibiaButton {
          text: qsTrId("optionsmenu_bar").arg(1)
          checkable: true
          useButtonShouldBeChecked: true

          buttonShouldBeChecked: optionsSet != null && optionsSet.clearRightActionBar1
          onClicked: {
            if (optionsSet != null) {
              optionsSet.onClearRightActionBar1Clicked();
            }
          } //onClicked
        } //TibiaButton

        TibiaButton {
          text: qsTrId("optionsmenu_bar").arg(2)
          checkable: true
          useButtonShouldBeChecked: true

          buttonShouldBeChecked: optionsSet != null && optionsSet.clearRightActionBar2
          onClicked: {
            if (optionsSet != null) {
              optionsSet.onClearRightActionBar2Clicked();
            }
          } //onClicked
        } //TibiaButton

        TibiaButton {
          text: qsTrId("optionsmenu_bar").arg(3)
          checkable: true
          useButtonShouldBeChecked: true

          buttonShouldBeChecked: optionsSet != null && optionsSet.clearRightActionBar3
          onClicked: {
            if (optionsSet != null) {
              optionsSet.onClearRightActionBar3Clicked();
            }
          } //onClicked
        } //TibiaButton

        Item {
          Layout.fillWidth: true
        } //Item

        //RIGHT ACTION BARS
        /////////////////////////////////////////////////////
      } //GridLayout
    } //TibiaFrame1PixelDownWithGuiHelp
  } //ColumnLayout
} //TibiaOptionsPage
