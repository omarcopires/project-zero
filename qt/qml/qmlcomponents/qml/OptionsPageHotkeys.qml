import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qmlcomponents
import qmlenumvalues
import QtQuick.LegacyControls


TibiaOptionsPage {
  id: root
  implicitHeight: contentLayout.height

  optionsSet: controller != null ? controller.hotkeyOptions : null

  Component {
    id: editKeyBindingComponent

    TibiaButton {
      imageSourceUp: "/images/icon-edit.png"
      property int currentRow: -1
      property int keyIndex: 0

      onClicked: {
        if (optionsSet != null) {
          optionsSet.requestEnterNewHotkeyForAction(currentRow, keyIndex);
        }
      }
    } // TibiaButton
  } // Component

  Component {
    id: editActionComponent

    TibiaButton {
      imageSourceUp: "/images/icon-edit.png"
      property int currentRow: -1

      onClicked: {
        if (optionsSet != null) {
          optionsSet.requestEditActionForHotkey(currentRow);
        }
      }
    } // TibiaButton
  } // Component

  Component {
    id: singleObjecAppearanceInstanceRendererComponent

    SingleObjectAppearanceInstanceRenderer {
      animated: true
    } //SingleObjectAppearanceInstanceRenderer
  } //Component

  ColumnLayout {
    id: contentLayout
    anchors { left: parent.left; top: parent.top; right: parent.right; bottom: parent.bottom; }
    spacing: TibiaStyle.marginRelated

    RowLayout {
      spacing: TibiaStyle.marginRelated

      TibiaComboBox {
        id: comboBoxHotkeyPresets
        Layout.fillWidth: true
        Layout.preferredHeight: addHotkeyPreset.height
        model: optionsSet != null ? optionsSet.hotkeySetNamesModel : null

        property int modelIndex: optionsSet != null ? optionsSet.hotkeySetNamesIndex : -1

        onModelChanged: {
          if (model != null && modelIndex < model.length) {
            currentIndex = modelIndex;
          }
        }

        onModelIndexChanged: {
          modelChanged();
        }

        onActivated: (index) => {
          if (currentIndex > -1 && optionsSet != null) {
            optionsSet.hotkeySetNamesIndex = index;
          }
        }
      } //TibiaComboBox

      TibiaButton {
        id: addHotkeyPreset
        text: qsTrId("hotkeyoptions_add_preset")
        Layout.preferredWidth: 30
        enabled: optionsSet != null
        onClicked: {
          optionsSet.requestAddPreset();
        } //onClicked
        Tooltip {
          text: qsTrId("hotkeyoptions_add_preset_tooltip")
          anchors.fill: parent
        } //Tooltip
      } //TibiaButton

      TibiaButton {
        id: cloneHotkeyPreset
        text: qsTrId("copy")
        Layout.preferredWidth: 35
        enabled: optionsSet != null
        onClicked: {
          optionsSet.requestCloneCurrentPreset();
        } //onClicked
        Tooltip {
          text: qsTrId("hotkeyoptions_copy_preset_tooltip")
          anchors.fill: parent
        } //Tooltip
      } //TibiaButton

      TibiaButton {
        id: renameHotkeyPreset
        text: qsTrId("rename")
        Layout.preferredWidth: 45
        enabled: optionsSet != null
        onClicked: {
          optionsSet.requestRenameCurrentPreset();
        } //onClicked
        Tooltip {
          text: qsTrId("hotkeyoptions_rename_preset_tooltip")
          anchors.fill: parent
        } //Tooltip
      } //TibiaButton

      TibiaButton {
        id: removeHotkeyPreset
        text: qsTrId("hotkeyoptions_remove_preset")
        Layout.preferredWidth: 45
        enabled: optionsSet != null && comboBoxHotkeyPresets.count > 1
        onClicked: {
          optionsSet.requestRemoveCurrentPreset();
        } //onClicked
        Tooltip {
          text: qsTrId("hotkeyoptions_remove_preset_tooltip")
          anchors.fill: parent
        } //Tooltip
      } //TibiaButton
    } //RowLayout

    TibiaMenuOptionCheckBox {
      id: radioButtonAutoSwitchHotkeyPreset
      text: qsTrId("hotkeysoptions_autoswitch_preset")
      guiHelpText: qsTrId("hotkeysoptions_autoswitch_preset_tooltip")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet != null && optionsSet.autoSwitchHotkeyPreset
      enabled: optionsSet != null

      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.autoSwitchHotkeyPreset = checked
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaFrame1PixelDownWithGuiHelp {
      Layout.fillWidth: true
      Layout.preferredHeight: marginsToContent * 2 + chatModeButtonLayout.height
      guiHelpUseRichText: true
      guiHelpText: qsTrId("hotkeyoptions_chat_mode_help")

      ButtonGroup {
        id: chatModeGroup
        property bool chatModeOn: optionsSet != null ? optionsSet.chatModeOn : true
        property bool __updateFromController: false

        onChatModeOnChanged: {
          __updateFromController = true;
          checkedButton = chatModeOn ? chatModeOnRadio : chatModeOffRadio
          __updateFromController = false;
        }

        onCheckedButtonChanged: {
          if (!__updateFromController && optionsSet != null) {
            optionsSet.chatModeOn = checkedButton == chatModeOnRadio;
          }
        }
      } // ButtonGroup

      RowLayout {
        id: chatModeButtonLayout
        anchors { left: parent.left; leftMargin: parent.marginsToContent;
                  right: parent.right; rightMargin: parent.marginsToContent;
                  top: parent.top; topMargin: parent.marginsToContent; }

        TibiaRadioButton {
          id: chatModeOnRadio
          text: qsTrId("hotkeyoptions_chat_mode_on")
          ButtonGroup.group: chatModeGroup
        } // TibiaRadioButton

        TibiaRadioButton {
          id: chatModeOffRadio
          text: qsTrId("hotkeyoptions_chat_mode_off")
          ButtonGroup.group: chatModeGroup
        } // TibiaRadioButton
      } // ColumnLayout
    } // TibiaFrame1PixelDownWithGuiHelp

    RowLayout {
      TibiaText {
        text: qsTrId("hotkeyoptions_search_hotkey_label")
      } // TibiaText

      TibiaTextField {
        id: hotkeySearch
        Layout.fillWidth: true
        KeyNavigation.tab: hotkeyTableView
        KeyNavigation.backtab: hotkeyTableView

        property string hotkeyFilter: optionsSet != null ? optionsSet.nameFilter : ""
        property bool __updateFromController: false

        onHotkeyFilterChanged: {
          __updateFromController = true;
          text = hotkeyFilter;
          __updateFromController = false;
        }

        onTextChanged: {
          if (!__updateFromController) {
            filterRefreshTimer.restart();
          }
        }

        Timer {
          id: filterRefreshTimer
          interval: TibiaStyle.searchDelay

          onTriggered: {
            if (optionsSet != null) {
              hotkeyTableView.disableRestoringScrollPositionForOneUpdate();
              optionsSet.nameFilter = hotkeySearch.text;
            }
          }
        }
      } // TibiaTextField

      TibiaIconButton {
        sourceUp: "/images/button-clear-20x20-up.png"
        sourceDown: "/images/button-clear-20x20-down.png"
        tooltipText: qsTrId("clear_search_tooltip")

        onClicked: {
          hotkeySearch.text = '';
        }
      } // TibiaIconButton
    } // RowLayout

    TibiaTableView {
      id: hotkeyTableView

      property var hotkeyModel: optionsSet != null ? optionsSet.hotkeyModel : null
      property bool restoreScrollPositionAndIndex: true

      Layout.fillWidth: true
      Layout.fillHeight: true
      KeyNavigation.tab: hotkeySearch
      KeyNavigation.backtab: hotkeySearch

      headerVisible: true
      focus: true

      onHotkeyModelChanged: {
        var oldListPosition = flickableItem.contentY;
        var oldSelectedIndex = currentRow;
        selection.forEach(function(Row) { oldSelectedIndex = Row; });

        model = hotkeyModel;

        if (restoreScrollPositionAndIndex) {
          flickableItem.contentY  = oldListPosition;
          if (oldSelectedIndex > -1 && oldSelectedIndex < rowCount) {
            currentRow = oldSelectedIndex;
            selectCurrentRow();
          }
        }
        restoreScrollPositionAndIndex = true;
      } //onHotkeyModelChanged

      Component.onCompleted: {
        if (rowCount > 0) {
          currentRow = 0;
          selectCurrentRow();
        }
        forceActiveFocus();
      } //Component.onCompleted

      Keys.onUpPressed: (event) => {
        decrementCurrentRow();
        event.accepted = true;
        focus = true; //set focus true so that the keyhandling of the TableView
                      // can take over if the "hotkeyText" is disabled
      } //Keys.onUpPressed

      Keys.onDownPressed: (event) => {
        incrementCurrentRow();
        event.accepted = true;
        focus = true;
      } //Keys.downPressed

      Keys.onPressed: (event) => {
        var i;
        if (event.key == Qt.Key_PageUp) {
          for (i = 0; i < 12; i++) {
            decrementCurrentRow();
          }
          event.accepted = true;
          focus = true; //set focus true so that the keyhandling of the TableView
                        // can take over if the "hotkeyText" is disabled

        } else if (event.key == Qt.Key_PageDown) {
          for (i = 0; i < 12; i++) {
            incrementCurrentRow();
          }
          event.accepted = true;
          focus = true;
        }
      } //Keys.onPressed

      function disableRestoringScrollPositionForOneUpdate() {
        restoreScrollPositionAndIndex = false;
      }

      function incrementCurrentRow() {
        if (rowCount > 0) {
          currentRow = Math.min(rowCount -1, currentRow +1);
          selectCurrentRow();
        }
      } //incrementCurrentRow

      function decrementCurrentRow() {
        if (currentRow > -1 && rowCount > 0) {
          currentRow = Math.max(0, currentRow -1);
          selectCurrentRow();
        }
      } //decrementCurrentRow

      function selectCurrentRow() {
        selection.clear();
        selection.select(currentRow)
      } //function selectRow(row)

      TableViewColumn {
        id: actionColumn
        role: "descriptionText"
        title: qsTrId("action_column_header")
        width: 290

        delegate: RowLayout {
          anchors.fill: parent
          spacing: TibiaStyle.marginNarrow

          property var textSplitIntoCategoryAndText: styleData.value.split(": ")

          Loader {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: Layout.preferredHeight
            visible: sourceComponent != undefined
            sourceComponent: modelData != null && modelData.isUseObject ? singleObjecAppearanceInstanceRendererComponent : undefined

            onLoaded: {
              item.typeid = Qt.binding(function() { return modelData != null ? modelData.objectID : 0; });
              item.cumulativeCount = Qt.binding(function() { return modelData != null ? modelData.objectCount : 0; });
              item.liquidType = Qt.binding(function() { return modelData != null ? modelData.liquidType : ObjectAppearanceInstance.EMPTY; });
              item.hookDirection = Qt.binding(function() { return modelData != null ? modelData.hookDirection : ObjectAppearanceInstance.NONE; });
            } //onLoaded
          } // Loader

          TibiaText {
            visible: modelData != null && !modelData.isChatText && parent.textSplitIntoCategoryAndText.length > 1
            text: parent.textSplitIntoCategoryAndText[0] + ": "
            styleType: "Dialog"

            color: TibiaStyle.white2
          } // TibiaText

          TibiaText {
            id: descriptionText
            Layout.fillWidth: true

            text: modelData != null && !modelData.isChatText && parent.textSplitIntoCategoryAndText.length > 1
                  ? parent.textSplitIntoCategoryAndText[1] : styleData.value
            styleType: "Dialog"
            elide: styleData.elideMode
            color: modelData != null ? modelData.descriptionColor : "white"
          } // TibiaText

          Loader {
            Layout.preferredHeight: descriptionText.height
            Layout.preferredWidth: sourceComponent != undefined ? descriptionText.height : 0
            sourceComponent: styleData.row == hotkeyTableView.currentRow && optionsSet != null &&
                             optionsSet.hotkeyMode == HotkeyOptions.CustomHotkeys ? editActionComponent : undefined

            onLoaded: {
              item.currentRow = Qt.binding(function() { return styleData.row; });
            }
          } // Loader

          TibiaVerticalSeparator {}
        } // RowLayout
      } //TableViewColumn

      TableViewColumn {
        id: firstKeyColumn
        role: "firstHotkeyText"
        title: qsTrId("hotkeys_table_columnheader_firstkey")
        width: 100
        delegate: RowLayout {
          anchors.fill: parent
          spacing: TibiaStyle.marginNarrow

          TibiaText {
            id: firstKeyText
            Layout.fillWidth: true
            Layout.leftMargin: TibiaStyle.marginNarrow
            text: styleData.value
            styleType: "Dialog"
            elide: styleData.elideMode
            color: modelData != null ? modelData.descriptionColor : "white"
          } // TibiaText

          Loader {
            Layout.preferredHeight: firstKeyText.height
            Layout.preferredWidth: sourceComponent != undefined ? firstKeyText.height : 0
            sourceComponent: styleData.row == hotkeyTableView.currentRow ? editKeyBindingComponent : undefined

            onLoaded: {
              item.currentRow = Qt.binding(function() { return styleData.row; });
              item.keyIndex = 0;
            }
          } // Loader

          TibiaVerticalSeparator {}
        } // RowLayout
      } //TableViewColumn

      TableViewColumn {
        id: secondKeyColumn
        role: "secondHotkeyText"
        title: qsTrId("hotkeys_table_columnheader_secondkey")
        width: firstKeyColumn.width
        delegate: RowLayout {
          anchors.fill: parent
          spacing: TibiaStyle.marginNarrow

          TibiaText {
            id: secondHotkeyText
            Layout.fillWidth: true
            Layout.leftMargin: TibiaStyle.marginNarrow
            text: styleData.value
            styleType: "Dialog"
            elide: styleData.elideMode
            color: modelData != null ? modelData.descriptionColor : "white"
          } // TibiaText

          Loader {
            Layout.preferredHeight: secondHotkeyText.height
            Layout.preferredWidth: sourceComponent != undefined ? secondHotkeyText.height : 0
            sourceComponent: styleData.row == hotkeyTableView.currentRow ? editKeyBindingComponent : undefined

            onLoaded: {
              item.currentRow = Qt.binding(function() { return styleData.row; });
              item.keyIndex = 1;
            }
          } // Loader
        } // RowLayout
      } //TableViewColumn
    } //TibiaTableView

    TibiaButton {
      text: qsTrId("hotkeyoptions_new_action")
      tooltipText: qsTrId("hotkeyoptions_new_action_tooltip")
      Layout.preferredWidth: TibiaStyle.buttonWidthWide
      opacity: optionsSet != null && optionsSet.hotkeyMode == HotkeyOptions.CustomHotkeys ? 1.0 : 0.0

      onClicked: {
        if (optionsSet != null) {
          optionsSet.requestAddNewCustomHotkey();
        }
      }
    } // TibiaButton
  } //ColumnLayout
} //TibiaOptionsPage
