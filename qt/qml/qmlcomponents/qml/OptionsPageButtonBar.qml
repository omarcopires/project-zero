import QtQuick
import QtQuick.Layouts
import QtQuick.LegacyControls



TibiaOptionsPage {
  id: root
  implicitHeight: contentLayout.height

  optionsSet: controller != null ? controller.buttonBarOptions : null

  ColumnLayout {
    id: contentLayout
    anchors { left: parent.left; top: parent.top; right: parent.right }
    spacing: TibiaStyle.marginRelated

    TibiaFrame1PixelDownWithGuiHelp {
      Layout.fillWidth: true
      Layout.preferredHeight: 250

      TibiaText {
        id: enabledButtonsText
        styleType: "Caption"
        text: qsTrId("optionsmenu_buttonbar_enabled_buttons")
        anchors { top: parent.top; left: parent.left;
                  topMargin: parent.marginsToContent; leftMargin: parent.marginsToContent }
      }

      TibiaIconButton {
        id: disableButtonbarButton
        anchors { top: enabledButtonsTable.top; right: parent.right;
                  rightMargin: parent.marginsToContent }
        sourceDown: "/images/button-clear-20x20-down.png"
        sourceUp: "/images/button-clear-20x20-up.png"
        enabled: enabledButtonsTable.selection.count > 0
        tooltipText: qsTrId("optionsmenu_buttonbar_disable_button_tooltip")
        tooltipMaxWidth: TibiaStyle.tooltipRestrictedWidth

        onClicked: {
          if (optionsSet != null) {
            enabledButtonsTable.selection.forEach(function(rowIndex) {
              optionsSet.disableButton(enabledButtonsTable.model[rowIndex]);
            });
          }
        }

        TibiaDisabledOverlay {
          anchors.fill: parent
          anchors.margins: 1
          visible: !parent.enabled
        }
      } // TibiaButton

      TibiaIconButton {
        id: moveUpButton
        anchors { top: disableButtonbarButton.bottom; topMargin: TibiaStyle.marginRelated;
                  right: parent.right; rightMargin: parent.marginsToContent }
        sourceDown: "/images/automap-button-moveup-down.png"
        sourceUp: "/images/automap-button-moveup-up.png"
        enabled: enabledButtonsTable.selection.count > 0 && enabledButtonsTable.rowCount > 1
        tooltipText: qsTrId("optionsmenu_buttonbar_move_button_up_tooltip")
        tooltipMaxWidth: TibiaStyle.tooltipRestrictedWidth

        onClicked: {
          if (optionsSet != null) {
            var selectedIndex = -1;
            enabledButtonsTable.selection.forEach(function(rowIndex) {
              selectedIndex = rowIndex;
            });

            if (selectedIndex != -1) {
              optionsSet.moveEnabledButtonUp(enabledButtonsTable.model[selectedIndex]);
            }
          }
        }

        TibiaDisabledOverlay {
          anchors.fill: parent
          anchors.margins: 1
          visible: !parent.enabled
        }
      } // TibiaButton

      TibiaIconButton {
        id: moveDownButton
        anchors { top: moveUpButton.bottom; topMargin: TibiaStyle.marginRelated;
                  right: parent.right; rightMargin: parent.marginsToContent }
        sourceDown: "/images/automap-button-movedown-down.png"
        sourceUp: "/images/automap-button-movedown-up.png"
        enabled: enabledButtonsTable.selection.count > 0 && enabledButtonsTable.rowCount > 1
        tooltipText: qsTrId("optionsmenu_buttonbar_move_button_down_tooltip")
        tooltipMaxWidth: TibiaStyle.tooltipRestrictedWidth

        onClicked: {
          if (optionsSet != null) {
            var selectedIndex = -1;
            enabledButtonsTable.selection.forEach(function(rowIndex) {
              selectedIndex = rowIndex;
            });

            if (selectedIndex != -1) {
              optionsSet.moveEnabledButtonDown(enabledButtonsTable.model[selectedIndex]);
            }
          }
        }

        TibiaDisabledOverlay {
          anchors.fill: parent
          anchors.margins: 1
          visible: !parent.enabled
        }
      } // TibiaButton

      TibiaTableView {
        id: enabledButtonsTable
        anchors { left: parent.left; top: enabledButtonsText.bottom;
                  right: disableButtonbarButton.left; bottom: parent.bottom;
                  leftMargin: parent.marginsToContent; topMargin: TibiaStyle.marginRelated;
                  rightMargin: TibiaStyle.marginRelated; bottomMargin: parent.marginsToContent }
        model: optionsSet != null ? optionsSet.enabledButtons : null

        property string previouslySelectedButtonText: ""
        property bool ignoreSelectionChanges: false

        TableViewColumn {
        } // TableViewColumn

        onActivated: (row) => {
          if (optionsSet != null) {
            optionsSet.disableButton(enabledButtonsTable.model[row]);
          }
        } // onActivated

        selection.onSelectionChanged: {
          if (!ignoreSelectionChanges) {
            if (selection.count > 0) {
              selection.forEach(function(rowIndex) {
                enabledButtonsTable.previouslySelectedButtonText = enabledButtonsTable.model[rowIndex];
              });
            }
          }
        } // onSelectionChanged

        onModelChanged: {
          if (rowCount > 0 && previouslySelectedButtonText.length > 0) {
            for (var i = 0; i < rowCount; ++i) {
              if (enabledButtonsTable.model[i] == previouslySelectedButtonText) {
                ignoreSelectionChanges = true;
                selection.clear();
                selection.select(i);
                positionTimer.restart();
                ignoreSelectionChanges = false;
                break;
              }
            }
          }
        } // onModelChanged

        Timer {
          id: positionTimer
          interval: 1

          onTriggered: {
            enabledButtonsTable.selection.forEach(function(rowIndex) {
              enabledButtonsTable.positionViewAtRow(rowIndex, ListView.Contain);
            });
          }
        } // Timer
      } // TibiaTableView
    } // TibiaFrame1PixelDown

    TibiaFrame1PixelDownWithGuiHelp {
      Layout.fillWidth: true
      Layout.preferredHeight: 100

      TibiaText {
        id: disabledButtonsText
        styleType: "Caption"
        text: qsTrId("optionsmenu_buttonbar_disabled_buttons")
        anchors { top: parent.top; left: parent.left;
                  topMargin: parent.marginsToContent; leftMargin: parent.marginsToContent }
      }

      TibiaButton {
        id: enableButtonbarButton
        anchors { top: disabledButtonsTable.top; right: parent.right;
                  rightMargin: parent.marginsToContent }
        imageSource: "/images/skin/classic/icon-add.png"
        width: TibiaStyle.iconButtonSize
        height: TibiaStyle.iconButtonSize
        enabled: disabledButtonsTable.selection.count > 0
        tooltipText: qsTrId("optionsmenu_buttonbar_enable_button_tooltip")
        tooltipMaxWidth: TibiaStyle.tooltipRestrictedWidth

        onClicked: {
          if (optionsSet != null) {
            disabledButtonsTable.selection.forEach(function(rowIndex) {
              optionsSet.enableButton(disabledButtonsTable.model[rowIndex]);
            });
          }
        }

        TibiaDisabledOverlay {
          anchors.fill: parent
          anchors.margins: 1
          visible: !parent.enabled
        }
      } // TibiaButton

      TibiaTableView {
        id: disabledButtonsTable
        anchors { left: parent.left; top: disabledButtonsText.bottom;
                  right: enableButtonbarButton.left; bottom: parent.bottom;
                  leftMargin: parent.marginsToContent; topMargin: TibiaStyle.marginRelated;
                  rightMargin: TibiaStyle.marginRelated; bottomMargin: parent.marginsToContent }
        model: optionsSet != null ? optionsSet.disabledButtons : null

        TableViewColumn {
        }

        onActivated: (row) => {
          if (optionsSet != null) {
            optionsSet.enableButton(disabledButtonsTable.model[row]);
          }
        }
      } // TibiaTableView
    } // TibiaFrame1PixelDown
  } //ColumnLayout
} //TibiaOptionsPage
