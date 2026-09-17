import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.LegacyControls
import QtQml


TibiaOptionsPage {
  id: root
  implicitHeight: contentLayout.height

  optionsSet: controller != null ? controller.hudOptions : null

  ColumnLayout {
    id: contentLayout
    anchors { left: parent.left; top: parent.top; right: parent.right }
    spacing: TibiaStyle.marginRelated

    TibiaFrame1PixelDownWithGuiHelp {
      Layout.fillWidth: true
      Layout.preferredHeight: contentHudOptionsLayout.height + 2 * TibiaStyle.marginRelated

      RowLayout {
        id: contentHudOptionsLayout
        anchors { left: parent.left; top: parent.top; right: parent.right }
        anchors.margins: parent.marginsToContent
        spacing: TibiaStyle.marginRelated

        Item {
          Layout.preferredWidth: contentHudOptionsLayout.width * 0.5 - TibiaStyle.marginRelated * 2
          Layout.preferredHeight: playerHudOptions.height
          Layout.alignment: Qt.AlignLeft | Qt.AlignVTop

          ColumnLayout {
            id: playerHudOptions
            anchors { left: parent.left; top: parent.top; right: parent.right }
            spacing: TibiaStyle.marginRelated
            Layout.alignment: Qt.AlignLeft | Qt.AlignVTop

            RowLayout {
              Layout.fillWidth: true

              TibiaCheckBox {
                id: playerHudEnabled
                text: qsTrId("optionsmenu_player_hud_enabled")
                Layout.fillWidth: true
                Layout.topMargin: -1 //checkbox text height is one higher than the checbox icon
                shouldBeChecked: optionsSet != null && optionsSet.playerHudEnabled
                onCheckedChanged: {
                  if (optionsSet != null) {
                    optionsSet.playerHudEnabled = checked;
                  }
                } //onCheckedChanged
              } //TibiaCheckBox

              TibiaGuiHelp {
                Layout.alignment: Qt.AlignRight
                useRichText: true
                text: qsTrId("optionsmenu_player_hud_help")
              } //TibiaGuiHelp
            }

            RowLayout {
              id: hudOptionsSplitLayout
              spacing: 0
              Layout.fillWidth: true
              enabled: playerHudEnabled.checked

              ColumnLayout {
                id: leftCheckboxesLayout
                Layout.fillWidth: true
                Layout.leftMargin: TibiaStyle.paragraphIndentation

                TibiaCheckBox {
                  id: playerShowBars
                  text: qsTrId("optionsmenu_show_bars")
                  Layout.fillWidth: true
                  shouldBeChecked: optionsSet != null && optionsSet.playerHudShowBars
                  onCheckedChanged: {
                    if (optionsSet != null) {
                      optionsSet.playerHudShowBars = checked;
                    }
                  } //onCheckedChanged
                } //TibiaCheckBox

                TibiaCheckBox {
                  id: playerShowName
                  text: qsTrId("optionsmenu_show_name")
                  shouldBeChecked: optionsSet != null && optionsSet.playerShowName
                  onCheckedChanged: {
                    if (optionsSet != null) {
                      optionsSet.playerShowName = checked;
                    }
                  } //onCheckedChanged
                } //TibiaCheckBox

                TibiaCheckBox {
                  id: playerShowHealth
                  text: qsTrId("optionsmenu_show_health")
                  shouldBeChecked: optionsSet != null && optionsSet.playerShowHealth
                  onCheckedChanged: {
                    if (optionsSet != null) {
                      optionsSet.playerShowHealth = checked;
                    }
                  } //onCheckedChanged
                } //TibiaCheckBox

                TibiaCheckBox {
                  id: playerShowMana
                  text: qsTrId("optionsmenu_show_mana")
                  shouldBeChecked: optionsSet != null && optionsSet.playerShowMana
                  onCheckedChanged: {
                    if (optionsSet != null) {
                      optionsSet.playerShowMana = checked;
                    }
                  } //onCheckedChanged
                } //TibiaCheckBox

                TibiaCheckBox {
                  id: playerShowHarmony
                  text: qsTrId("optionsmenu_show_harmoy")
                  shouldBeChecked: optionsSet != null && optionsSet.playerShowHarmony
                  onCheckedChanged: {
                    if (optionsSet != null) {
                      optionsSet.playerShowHarmony = checked;
                    }
                  } //onCheckedChanged
                } //TibiaCheckBox

                Item {

                  id: harmonyArcFilters
                  Layout.preferredHeight: harmonyArcGroupLayout.height
                  Layout.preferredWidth: harmonyArcGroupLayout.width
                  Layout.alignment: Qt.AlignHCenter

                  ColumnLayout {

                    id: harmonyArcGroupLayout
                    spacing: TibiaStyle.marginRelated
                    anchors.centerIn: parent

                    ButtonGroup {
                      id: harmonyArcGroup

                      checkedButton: {
                        if (optionsSet) {
                          if (optionsSet.playerHudShowHarmonyLeft) {
                            return healthArc;
                          } else {
                            return manaArc;
                          }
                        }
                      }

                      onCheckedButtonChanged: {
                        if (checkedButton == healthArc) {
                          if (optionsSet) {
                            optionsSet.playerHudShowHarmonyLeft = true;
                          }
                        } else if (checkedButton == manaArc) {
                          if (optionsSet) {
                            optionsSet.playerHudShowHarmonyLeft = false;
                          }
                        }
                      } //onCheckedButtonChanged
                    } //ButtonGroup

                    TibiaRadioButton {
                      id: healthArc
                      text: qsTrId("optionsmenu_show_harmony_health")
                      ButtonGroup.group: harmonyArcGroup
                    } //TibiaRadioButton

                    TibiaRadioButton {
                      id: manaArc
                      text: qsTrId("optionsmenu_show_harmony_mana")
                      ButtonGroup.group: harmonyArcGroup
                    } //TibiaRadioButton

                  } // ColumnLayout

                } // Item


                TibiaCheckBox {
                  id: playerShowMarks
                  text: qsTrId("optionsmenu_show_marks")
                  shouldBeChecked: optionsSet != null && optionsSet.playerShowMarks
                  onCheckedChanged: {
                    if (optionsSet != null) {
                      optionsSet.playerShowMarks = checked;
                    }
                  } //onCheckedChanged
                } //TibiaCheckBox
              } //ColumnLayout

            } //RowLayout
          } //ColumnLayout

        } //Item

        TibiaVerticalSeparator {
          Layout.fillHeight: true
        }

        Item {
          Layout.preferredWidth: contentHudOptionsLayout.width * 0.5 - TibiaStyle.marginRelated
          Layout.fillHeight: true

          ColumnLayout {
            id: creatureHudOptions
            anchors { left: parent.left; top: parent.top; right: parent.right }
            spacing: TibiaStyle.marginRelated

            RowLayout {
              Layout.fillWidth: true

              TibiaCheckBox {
                id: creatureHudEnabled
                text: qsTrId("optionsmenu_creatures_hud_enabled")
                Layout.fillWidth: true
                shouldBeChecked: optionsSet != null && optionsSet.creatureHudEnabled
                onCheckedChanged: {
                  if (optionsSet != null) {
                    optionsSet.creatureHudEnabled = checked;
                  }
                } //onCheckedChanged
              } //TibiaCheckBox

              TibiaGuiHelp {
                Layout.alignment: Qt.AlignRight
                useRichText: true
                text: qsTrId("optionsmenu_creatures_hud_help")
              } //TibiaGuiHelp
            }

            ColumnLayout {
              spacing: TibiaStyle.marginRelated
              Layout.fillWidth: true
              Layout.leftMargin: TibiaStyle.paragraphIndentation
              Layout.alignment: Qt.AlignLeft | Qt.AlignVTop
              enabled: creatureHudEnabled.checked

              TibiaCheckBox {
                id: creatureShowName
                text: qsTrId("optionsmenu_show_name")
                Layout.fillWidth: true
                shouldBeChecked: optionsSet != null && optionsSet.creatureShowName
                onCheckedChanged: {
                  if (optionsSet != null) {
                    optionsSet.creatureShowName = checked;
                  }
                } //onCheckedChanged
              } //TibiaCheckBox

              TibiaCheckBox {
                id: creatureShowHealth
                text: qsTrId("optionsmenu_show_health")
                Layout.fillWidth: true
                shouldBeChecked: optionsSet != null && optionsSet.creatureShowHealth
                onCheckedChanged: {
                  if (optionsSet != null) {
                    optionsSet.creatureShowHealth = checked;
                  }
                } //onCheckedChanged
              } //TibiaCheckBox

              TibiaCheckBox {
                id: creatureShowMarks
                text: qsTrId("optionsmenu_show_marks")
                Layout.fillWidth: true
                shouldBeChecked: optionsSet != null && optionsSet.creatureShowMarks
                onCheckedChanged: {
                  if (optionsSet != null) {
                    optionsSet.creatureShowMarks = checked;
                  }
                } //onCheckedChanged
              } //TibiaCheckBox

              TibiaCheckBox {
                id: creatureNpcShowIcon
                text: qsTrId("optionsmenu_npc_show_icon")
                Layout.fillWidth: true
                shouldBeChecked: optionsSet != null && optionsSet.creatureNpcShowIcon
                onCheckedChanged: {
                  if (optionsSet != null) {
                    optionsSet.creatureNpcShowIcon = checked;
                  }
                } //onCheckedChanged
              } //TibiaCheckBox
            } //ColumnLayout
          } //ColumnLayout
        } //Item
      } //RowLayout
    } //TibiaFrame1PixelDownWithGuiHelp

    TibiaFrame1PixelDownWithGuiHelp {
      Layout.fillWidth: true
      Layout.preferredHeight: arcsAndSpecialConditionsLayout.height + 2 * TibiaStyle.marginRelated

      //guiHelpUseRichText: true
      //guiHelpText: "XXX gui help text" // qsTrId("optionsmenu_creatures_hud_help")

      ColumnLayout {
        id: arcsAndSpecialConditionsLayout
        anchors { left: parent.left; top: parent.top; right: parent.right }
        anchors.margins: parent.marginsToContent
        spacing: TibiaStyle.marginRelated

        RowLayout {
          Layout.fillWidth: true

          ColumnLayout {
            Layout.preferredWidth: arcsAndSpecialConditionsLayout.width * 0.5

            TibiaCheckBox {
              id: playerShowArcs
              Layout.leftMargin: TibiaStyle.paragraphIndentation
              text: qsTrId("optionsmenu_show_arcs")
              shouldBeChecked: optionsSet != null && optionsSet.playerHudShowArcs
              onCheckedChanged: {
                if (optionsSet != null) {
                  optionsSet.playerHudShowArcs = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckBox

            TibiaComboBox {
              id: playerHudArcSize
              readonly property real _BASE_HEIGHT: 0.35

              Layout.preferredWidth: TibiaStyle.buttonWidthWidest
              Layout.alignment: Qt.AlignLeft
              Layout.leftMargin: TibiaStyle.paragraphIndentation + TibiaStyle.scrollBarWidth + TibiaStyle.marginRelated
              model: ListModel {
                ListElement {
                  text: qsTrId("optionsmenu_hud_arc_size_small")
                }
                ListElement {
                  text: qsTrId("optionsmenu_hud_arc_size_default")
                }
                ListElement {
                  text: qsTrId("optionsmenu_hud_arc_size_large")
                }
              } //model

              Binding on shouldBeCurrentIndex {
                value: {
                  if (optionsSet != null) {
                    if (optionsSet.playerHudArcWidth == 6) {
                      return 0;
                    } else if (optionsSet.playerHudArcWidth == 10) {
                      return 1;
                    } else if (optionsSet.playerHudArcWidth == 16) {
                      return 2;
                    }
                  }
                  return 0;
                }
                delayed: true
              } //Binding on shouldBeCurrentIndex

              onCurrentIndexChanged: {
                if (optionsSet != null) {
                  switch (currentIndex) {
                    case 0:
                      optionsSet.playerHudArcWidth = 6;
                      optionsSet.playerHudArcHeight = _BASE_HEIGHT * 0.6;
                      break;
                    case 1:
                      optionsSet.playerHudArcWidth = 10;
                      optionsSet.playerHudArcHeight = _BASE_HEIGHT;
                      break;
                    case 2:
                      optionsSet.playerHudArcWidth = 16;
                      optionsSet.playerHudArcHeight = _BASE_HEIGHT * 1.6;
                      break;
                    default:
                      break;
                  }
                }
              } //onCurrentIndexChanged
            } //TibiaComboBox
          } //ColumnLayout

          GridLayout {
            id: playerHudArcSettingsLayout
            // anchors { left: parent.left; top: parent.top; right: parent.right }
            Layout.preferredWidth: arcsAndSpecialConditionsLayout.width * 0.5
            enabled: playerShowArcs.checked || (optionsSet && optionsSet.specialConditionsShowInHUDEnabled)

            columns: 2
            rowSpacing: TibiaStyle.marginRelated
            columnSpacing: TibiaStyle.marginRelated

            TibiaText {
              Layout.preferredWidth: 110
              text: qsTrId("optionsmenu_hud_arc_distance") + " " + arcDistanceSlider.value + " %"
            } //TibiaText

            TibiaSlider {
              id: arcDistanceSlider
              Layout.fillWidth: true
              minimumValue: 0
              maximumValue: 100
              stepSize: 1
              Binding on shouldBeValue {
                value: optionsSet != null ? Math.round(optionsSet.playerHudArcDistance * 100.0) : 30
                delayed: true
              } //Binding on shouldBeValue

              onValueChanged: {
                if (optionsSet != null) {
                  optionsSet.playerHudArcDistance = value / 100.0;
                }
              } //onValueChanged
            } //TibiaSlider

            TibiaText {
              text: qsTrId("optionsmenu_hud_arc_opacity") + " " + arcOpacitySlider.value + " %"
            } //TibiaText

            TibiaSlider {
              id: arcOpacitySlider
              Layout.fillWidth: true
              minimumValue: 20
              maximumValue: 100
              stepSize: 1
              Binding on shouldBeValue {
                value: optionsSet != null ? Math.round(optionsSet.playerHudArcOpacity * 100.0) : 30
                delayed: true
              } //Binding on shouldBeValue
              onValueChanged: {
                if (optionsSet != null) {
                  let newValue = value / 100.0;
                  if (optionsSet.playerHudArcOpacity != newValue) {
                    optionsSet.playerHudArcOpacity = newValue;
                  }
                }
              } //onValueChanged
            } //TibiaSlider
          }
        }

        TibiaHorizontalSeparator {
          Layout.fillWidth: true
        }

        RowLayout {
          Layout.maximumWidth: specialConditionsTableView.width
          Layout.preferredWidth: specialConditionsTableView.width
          spacing: 0

          TibiaText {
            Layout.alignment: Qt.AlignLeft | Qt.AlignVBottom
            Layout.fillWidth: true
            text: qsTrId("special_condition_column_header")
          } //TibiaText

          RowLayout {
            spacing: TibiaStyle.marginRelated
            Layout.preferredWidth: showInHUDColumn.width
            Layout.alignment: Qt.AlignRight | Qt.AlignVBottom

            TibiaText {
              Layout.alignment: Qt.AlignRight | Qt.AlignVBottom
              text: qsTrId("special_condition_showinhud_column_header")
            } //TibiaText

            TibiaCheckBox {
              Layout.alignment: Qt.AlignRight
              shouldBeChecked: optionsSet.specialConditionsShowInHUDEnabled
              onCheckedChanged: {
                if (optionsSet != null) {
                  optionsSet.specialConditionsShowInHUDEnabled = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckBox
          } //RowLayout

          RowLayout {
            spacing: TibiaStyle.marginRelated
            Layout.preferredWidth: showInBarColumn.width
            Layout.alignment: Qt.AlignRight | Qt.AlignVBottom
            Layout.rightMargin: 15

            TibiaText {
              Layout.alignment: Qt.AlignRight
              text: qsTrId("special_condition_showinbar_column_header")
            } //TibiaText

            TibiaCheckBox {
              Layout.alignment: Qt.AlignRight | Qt.AlignVBottom
              shouldBeChecked: optionsSet.specialConditionsShowInBarEnabled
              onCheckedChanged: {
                if (optionsSet != null) {
                  optionsSet.specialConditionsShowInBarEnabled = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckBox
          } //RowLayout
        } //RowLayout

        RowLayout {
          Layout.fillWidth: true
          Layout.preferredHeight: 100
          spacing: TibiaStyle.marginRelated

          TibiaTableView {
            id: specialConditionsTableView

            // NOTE: intentional use of custom property for model update so that we can restore the scroll position after a model update
            property var specialConditionsModel: optionsSet ? optionsSet.specialConditionsModel : null
            property bool restoreScrollPositionAndIndex: true
            property int selectedConditionListEntryID: -1

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.bottomMargin: 0

            rowHeight: TibiaStyle.tableViewRowHeight

            headerVisible: false
            focus: true

            onSpecialConditionsModelChanged: {
              // store current scroll position and selection
              var oldListPosition = flickableItem.contentY;

              // update the table model
              model = specialConditionsModel;

              // restore the scroll position
              if (restoreScrollPositionAndIndex) {
                flickableItem.contentY = oldListPosition;
                selectByConditionListEntryID(selectedConditionListEntryID);
              }
              restoreScrollPositionAndIndex = true;
            }

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

            function findRowIndexForConditionListEntryID(expectedEntryID) {
              for (var i = 0; i < specialConditionsTableView.model.length; ++i) {
                var item = specialConditionsTableView.model[i];
                if (item.conditionListEntryID === expectedEntryID) {
                  return i;
                }
              }
              return -1;
            }

            function disableRestoringScrollPositionForOneUpdate() {
              restoreScrollPositionAndIndex = false;
            }

            function incrementCurrentRow() {
              if (rowCount > 0) {
                currentRow = Math.min(rowCount - 1, currentRow + 1);
                selectCurrentRow();
              }
            }

            function decrementCurrentRow() {
              if (currentRow > -1 && rowCount > 0) {
                currentRow = Math.max(0, currentRow - 1);
                selectCurrentRow();
              }
            }

            function selectByConditionListEntryID(conditionListEntryID) {
              let rowIndex = findRowIndexForConditionListEntryID(conditionListEntryID);
              if (rowIndex > -1) {
                currentRow = rowIndex;
                selectCurrentRow();
              }
            }

            function selectCurrentRow() {
              selection.clear();
              selection.select(currentRow);
              ensureCurrentRowIsVisible();
            }

            function ensureCurrentRowIsVisible() {
              // Get key metrics
              const viewHeight = height;
              const scrollY = flickableItem.contentY;

              const rowTop = currentRow * rowHeight;
              const rowBottom = rowTop + rowHeight;

              // If row is above visible area
              if (rowTop < scrollY) {
                flickableItem.contentY = rowTop;
              }
              // If row is below visible area
              else if (rowBottom > (scrollY + viewHeight)) {
                flickableItem.contentY = rowBottom - viewHeight;
              }
            }

            TableViewColumn {
              id: specialConditionColumn
              width: specialConditionsTableView.width - (TibiaStyle.scrollBarWidth + 4) - (showInHUDColumn.width + showInBarColumn.width)
              movable: false

              delegate: RowLayout {
                anchors.fill: parent
                Layout.margins: TibiaStyle.marginRelated
                spacing: TibiaStyle.marginRelated

                Image {
                  Layout.leftMargin: TibiaStyle.marginRelated
                  Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                  source: modelData ? modelData.iconSource : ""

                  Tooltip {
                    anchors.fill: parent
                    useRichText: true
                    maxWidth: TibiaStyle.tooltipRestrictedWidth
                    text: modelData ? modelData.iconTooltip : null
                  }
                }

                TibiaText {
                  Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                  Layout.fillWidth: true
                  text: modelData ? modelData.specialConditionInfo : null

                  elide: Text.ElideRight
                  clip: true

                  Tooltip {
                    anchors.fill: parent
                    useRichText: true
                    maxWidth: TibiaStyle.tooltipRestrictedWidth
                    text: modelData ? modelData.iconTooltip : null
                  }
                }
              } // RowLayout
            } //TableViewColumn

            TableViewColumn {
              id: showInHUDColumn
              width: 110
              movable: false

              delegate: RowLayout {
                anchors.fill: parent

                TibiaCheckBox {
                  Layout.alignment: Qt.AlignRight
                  enabled: optionsSet.specialConditionsShowInHUDEnabled
                  checked: modelData && modelData.showInHUD
                  onCheckedChanged: {
                    if (optionsSet && modelData && modelData.showInHUD !== checked) {
                      specialConditionsTableView.selectedConditionListEntryID = modelData.conditionListEntryID;
                      optionsSet.setSpecialConditionShowInHUDEnabled(modelData.conditionListIndex, checked);
                    }
                  } //onCheckedChanged
                } //TibiaCheckBox
              } // RowLayout
            } //TableViewColumn

            TableViewColumn {
              id: showInBarColumn
              width: 110
              movable: false

              delegate: RowLayout {
                anchors.fill: parent

                TibiaCheckBox {
                  Layout.alignment: Qt.AlignRight
                  enabled: optionsSet.specialConditionsShowInBarEnabled
                  checked: modelData && modelData.showInBar
                  onCheckedChanged: {
                    if (optionsSet && modelData && modelData.showInBar !== checked) {
                      specialConditionsTableView.selectedConditionListEntryID = modelData.conditionListEntryID;
                      optionsSet.setSpecialConditionShowInBarEnabled(modelData.conditionListIndex, checked);
                    }
                  } //onCheckedChanged
                } //TibiaCheckBox
              } // RowLayout
            } //TableViewColumn
          } //TibiaTableView

          Item {
            Layout.fillHeight: true
            Layout.preferredWidth: 20
            Layout.alignment: Qt.AlignLeft | Qt.AlignVTop

            TibiaIconButton {
              id: specialConditionMoveUpButton
              anchors { top: parent.top; topMargin: 0;
                right: parent.right; rightMargin: parent.marginsToContent }
              sourceDown: "/images/automap-button-moveup-down.png"
              sourceUp: "/images/automap-button-moveup-up.png"
              enabled: specialConditionsTableView.currentRow > -1 && specialConditionsTableView.currentRow > 0
              tooltipText: qsTrId("special_condition_buttonbar_move_condition_up_tooltip")
              tooltipMaxWidth: TibiaStyle.tooltipRestrictedWidth

              onClicked: {
                if (optionsSet != null) {
                  if (specialConditionsTableView.currentRow > -1) {
                    // store last moved condition ID for re-selection after model update
                    let row = specialConditionsTableView.model[specialConditionsTableView.currentRow];
                    specialConditionsTableView.selectedConditionListEntryID = row.conditionListEntryID;
                    // move it
                    optionsSet.moveSpecialConditionUp(specialConditionsTableView.currentRow);
                  }
                }
              }

              TibiaDisabledOverlay {
                anchors.fill: parent
                anchors.margins: 1
                visible: !parent.enabled
              }
            } // TibiaIconButton

            TibiaIconButton {
              id: specialConditionMoveDownButton
              anchors { top: specialConditionMoveUpButton.bottom; topMargin: TibiaStyle.marginRelated;
                right: parent.right; rightMargin: parent.marginsToContent }
              sourceDown: "/images/automap-button-movedown-down.png"
              sourceUp: "/images/automap-button-movedown-up.png"
              enabled: specialConditionsTableView.currentRow > -1 && specialConditionsTableView.currentRow < (specialConditionsTableView.rowCount - 1)
              tooltipText: qsTrId("special_condition_buttonbar_move_condition_down_tooltip")
              tooltipMaxWidth: TibiaStyle.tooltipRestrictedWidth

              onClicked: {
                if (optionsSet != null) {
                  if (specialConditionsTableView.currentRow > -1) {
                    // store last moved condition ID for re-selection after model update
                    let row = specialConditionsTableView.model[specialConditionsTableView.currentRow];
                    specialConditionsTableView.selectedConditionListEntryID = row.conditionListEntryID;
                    // move it
                    optionsSet.moveSpecialConditionDown(specialConditionsTableView.currentRow);
                  }
                }
              }

              TibiaDisabledOverlay {
                anchors.fill: parent
                anchors.margins: 1
                visible: !parent.enabled
              }
            } // TibiaIconButton
          }
        }
      }
    }

    TibiaMenuOptionCheckBox {
      id: statusBarEnabled
      text: qsTrId("optionsmenu_statusbar_enabled")
      guiHelpUseRichText: true
      guiHelpText: qsTrId("optionsmenu_statusbar_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet != null && optionsSet.statusBarEnabled
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.statusBarEnabled = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: statusPanelEnabled
      text: qsTrId("optionsmenu_statuspanel_enabled")
      guiHelpText: qsTrId("optionsmenu_statuspanel_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet != null && optionsSet.statusPanelEnabled
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.statusPanelEnabled = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox
  } //ColumnLayout
} //TibiaOptionsPage
