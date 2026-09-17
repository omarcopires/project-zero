import QtQuick
import QtQuick.Layouts
import qmlcomponents
import QtQuick.LegacyControls

Item {
  id: root

  required property var controller

  property var initialFocusItem: root
  property var spellListModel: null

  property bool validSpellSelected: _currentModelData && (_currentModelData.enumId ?? -1) != -1

  property var _currentModelData: {}
  property bool runePageEnabled: false

  property int initialSpellID: controller != null ? controller.initialSpellID : -1

  property int _currentDetailTabId: 0

  property var _currentSpellPreview: {}

  property var _spellsPreviews: controller != null ? controller.spellsPreviewsJson : {}

  KeyNavigation.tab: root

  onControllerChanged: {
    if (controller) {
      root.spellListModel = controller.spellListModel;
      selectSpellID(controller.initialSpellID);
      //onInitialSpellIDChanged();
    }
  }

  onInitialSpellIDChanged: {
    if (controller) {
      Qt.callLater(selectSpellID, root.initialSpellID);
    }
  }

  on_SpellsPreviewsChanged: {
    if (controller) {
      selectSpellID(root.initialSpellID)
    }
  }

  function selectSpellID(spellID) {
    var newCurrentModelData = {}
    var newSpellListIndex = -1;
    var foundSpellPreview = {};
    if (root.spellListModel) {
      var _helperModel = AbstractItemModelHelper.wrapInHelperProxyModel(root.spellListModel);
      if (_helperModel.rowCount() > 0) {
        newSpellListIndex = 0;
      }
      for (var i = 0; i < _helperModel.rowCount(); i++) {
        var tempModelData = _helperModel.sourceItemDataByRowIndex(i);
        if (spellID == tempModelData.enumId) {
          newSpellListIndex = i;
          newCurrentModelData = tempModelData;
          break;
        }
      }
    }
    if (_currentModelData != newCurrentModelData) {
      _currentModelData = newCurrentModelData;
    }
    spellList.externalSelectedIndex = newSpellListIndex;

    if (root._spellsPreviews) {
      var newSpellPreviewData = root._spellsPreviews[spellID]
      if (!newSpellPreviewData) {
        newSpellPreviewData = {}
      }
      if (root._currentSpellPreview != newSpellPreviewData) {
        root._currentSpellPreview = newSpellPreviewData
      }
    }
  }


  on_CurrentModelDataChanged: {
    if (_currentModelData) {
      runePageEnabled = root._currentModelData.isRune ?? false;
      if (controller != null) {
        controller.selectedSpellID = _currentModelData.enumId ?? 0;
      }
    } else {
      _currentModelData = {}
    }
  }

  TapHandler {
    onTapped: {
      if (filterPanel.expanded) {
        filterPanel.expanded = false;
      }
    }
  }

  RowLayout {
    id: slotsLayout
    anchors.fill: parent
    anchors.bottomMargin: TibiaStyle.marginRelated
    spacing: TibiaStyle.marginRelated

    TibiaPanel2PixelUpFilledWithCaption {
      caption: qsTrId("magicalarchive_select_spell_caption")
      autoHeight: false
      Layout.preferredWidth: 170
      Layout.fillHeight: true

      ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: TibiaStyle.marginRelated

        ColumnLayout {
          TibiaPanelWithCaption {
            id: filterPanel
            caption: "Filter"
            Layout.fillWidth: true
            HoverHandler {
              onHoveredChanged: {
                if (hovered) {
                  delayedCloseTimer.stop();
                } else {
                  delayedCloseTimer.start();
                }
              }
            }
            Timer {
              id: delayedCloseTimer
              interval: 400
              repeat: false
              onTriggered: {
                if (filterPanel.expanded) {
                  filterPanel.expanded = false;
                }
              }
            }
            contentDelegate: ColumnLayout {
              id: filterColumnLayout
              component SpellFilterCheckBox: TibiaCheckBox {
                property var spellListModel: controller.spellListModel ? controller.spellListModel : undefined
                property bool filterInverted: false
                required property string filterProperty
                Layout.fillWidth: true
                onSpellListModelChanged: {
                  if (spellListModel) {
                    let currentValue = spellListModel[filterProperty];
                    if (filterInverted) {
                      shouldBeChecked = !currentValue;
                    } else {
                      shouldBeChecked = currentValue;
                    }
                  }
                }
                onCheckedChanged: {
                  if (spellListModel) {
                    let newValue = checked;
                    if (filterInverted) {
                      newValue = !checked;
                    }
                    spellListModel[filterProperty] = newValue;
                  }
                }
              }

              component SpellFilterGroupCheckbox: TibiaCheckBox {
                property var managedCheckboxes: []
                shouldBeChecked: {
                  let numberOfChecked = 0;
                  for (var i = 0; i < managedCheckboxes.length; i++) {
                    numberOfChecked += managedCheckboxes[i].checked ? 1 : 0;
                  }
                  return (numberOfChecked == managedCheckboxes.length);
                }

                nextCheckState: function() {
                  let newShouldBeChecked = true;
                  if (checked) {
                    newShouldBeChecked = false;
                  } else {
                    newShouldBeChecked = true;
                  }
                  for (var i = 0; i < managedCheckboxes.length; i++) {
                    managedCheckboxes[i].checked = newShouldBeChecked;
                  }
                  if (newShouldBeChecked) {
                    return Qt.Checked;
                  } else {
                    return Qt.Unchecked;
                  }
                }
              }


              SpellFilterCheckBox {
                text: qsTrId("spelllist_only_current_vocation")
                filterProperty: "showOnlyCurrentVocation"
              }
              SpellFilterCheckBox {
                text: qsTrId("spelllist_only_current_level")
                filterProperty: "showOnlyCurrentLevel"
              }
              SpellFilterCheckBox {
                text: qsTrId("spelllist_show_only_known_spells")
                filterProperty: "showUnkownSpells"
                filterInverted: true
              }
              TibiaHorizontalSeparator {}
              SpellFilterCheckBox {
                id: vocationDruidCheckBox
                text: qsTrId("druid")
                filterProperty: "showDruidSpells"
              }
              SpellFilterCheckBox {
                id: vocationKnightCheckBox
                text: qsTrId("knight")
                filterProperty: "showKnightSpells"
              }
              SpellFilterCheckBox {
                id: vocationPaladinCheckBox
                text: qsTrId("paladin")
                filterProperty: "showPaladinSpells"
              }
              SpellFilterCheckBox {
                id: vocationSorcererCheckBox
                text: qsTrId("sorcerer")
                filterProperty: "showSorcererSpells"
              }
              SpellFilterCheckBox {
                id: vocationMonkCheckBox
                text: qsTrId("monk")
                filterProperty: "showMonkSpells"
              }
              SpellFilterGroupCheckbox {
                managedCheckboxes: [vocationDruidCheckBox, vocationKnightCheckBox, vocationPaladinCheckBox, vocationSorcererCheckBox, vocationMonkCheckBox]
                text: qsTrId("spelllist_all_vocations")
              }
              TibiaHorizontalSeparator {}
              SpellFilterCheckBox {
                id: attackSpellGroupCheckBox
                text: qsTrId("spell_attack")
                filterProperty: "showAttackSpellGroup"
              }
              SpellFilterCheckBox {
                id: healingSpellGroupCheckBox
                text: qsTrId("spell_healing")
                filterProperty: "showHealingSpellGroup"
              }
              SpellFilterCheckBox {
                id: supportSpellGroupCheckBox
                text: qsTrId("spell_support")
                filterProperty: "showSupportSpellGroup"
              }
              SpellFilterGroupCheckbox {
                managedCheckboxes: [attackSpellGroupCheckBox, healingSpellGroupCheckBox, supportSpellGroupCheckBox]
                text: qsTrId("spelllist_all_spell_groups")
              }
              TibiaHorizontalSeparator {}
              SpellFilterCheckBox {
                text: qsTrId("spelllist_premium_only")
                filterProperty: "showPremiumOnlySpells"
              }
              SpellFilterCheckBox {
                text: qsTrId("spelllist_free_account")
                filterProperty: "showFreeSpells"
              }
              TibiaHorizontalSeparator {}
              SpellFilterCheckBox {
                text: qsTrId("spelllist_rune_spells")
                filterProperty: "showRuneSpells"
              }
              SpellFilterCheckBox {
                text: qsTrId("spelllist_instant_spells")
                filterProperty: "showInstantSpells"
              }
            }
          }
          Item {
            Layout.fillHeight: true
            visible: filterPanel.expanded
          }
        }

        ColumnLayout {
          visible: !filterPanel.expanded
          TibiaFrame1PixelDown {
            Layout.fillHeight: true
            Layout.fillWidth: true
            TibiaScrollView {
              anchors.fill: parent
              anchors.margins: 1
              SpellList {
                id: spellList
                model: root.spellListModel
                smallIcons: true

                externalSelectedIndex: controller != null ? 0 : -1
                patternedBackground: true
                allowDrag: false
                onSpellSelected: (spellEnumId) => {
                  selectSpellID(spellEnumId);
                }
              } //SpellList
            }
          }
          TibiaTextSearchField {
            id: searchField
            Layout.fillWidth: true

            KeyNavigation.tab: searchField
            KeyNavigation.backtab: searchField

            maximumLength: TibiaStyle.maxCharacterNameLength

            onSearchTextChanged: {
              if (controller && controller.spellListModel) {
                controller.spellListModel.filterText = searchText;
              }
            }

            shouldBeText: controller && controller.spellListModel ? controller.spellListModel.filterText : ""
          }
        }
      }
    }
    TibiaPanel2PixelUpFilledWithCaption {
      id: detailView
      caption: qsTrId("magicalarchive_spell_information_caption")
      autoHeight: false
      Layout.fillWidth: true
      Layout.fillHeight: true
      ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Loader {
          Layout.fillWidth: true
          Layout.fillHeight: true
          sourceComponent: root.validSpellSelected ? informationComponent : hintTextComponent
          Component {
            id: hintTextComponent
            Item {
              TibiaText {
                anchors.centerIn: parent
                text: qsTrId("magicalarchive_select_a_spell_hint")
              }
            }
          }

          Component {
            id: informationComponent
            ColumnLayout {
              TibiaFrame2PixelUpFilled {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                RowLayout {
                  anchors.fill: parent
                  anchors.margins: TibiaStyle.marginRelated;
                  TibiaFrame1PixelDown {
                    id: iconUrlBorder
                    Layout.preferredWidth: iconUrlImage.width + 2
                    Layout.preferredHeight: iconUrlImage.height + 2
                    Layout.alignment: Qt.AlignHCenter
                    Image {
                      id: iconUrlImage
                      x: 1
                      y: 1
                      source: _currentModelData.iconUrl ?? ""
                    }
                  }
                  ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.maximumHeight: iconUrlBorder.height
                    TibiaText {
                      text: _currentModelData.name ?? ""
                    }
                    TibiaText {
                      text: `${_currentModelData.formulaRaw}` + (_currentModelData.parameterHints ? ` ${_currentModelData.parameterHints}` : "")
                    }
                  }
                  Item {
                    Layout.fillWidth: true
                  }
                  ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillHeight: true
                    Layout.maximumHeight: iconUrlBorder.height
                    RowLayout {
                      Layout.alignment: Qt.AlignRight
                      Layout.minimumHeight: 12
                      spacing: TibiaStyle.marginRelated
                      Repeater {
                        model: _currentModelData.relevantUsageInfo.allowedVocationInfos
                        Image {
                          source: modelData.iconUrl
                          Tooltip {
                            anchors.fill: parent
                            text: modelData.tooltip
                          }
                        }
                      }
                      RowLayout {
                        Layout.maximumHeight: premiumIcon.height
                        visible: root._currentModelData.isPremium ?? false
                        TibiaVerticalSeparator {
                        }
                        Image {
                          id: premiumIcon
                          source: "/images/skin/classic/pic-premium.png"
                          Tooltip {
                            anchors.fill: parent
                            text: qsTrId("spelllist_label_spell_premium")
                          }
                        }
                      }
                    }
                    RowLayout {
                      spacing: TibiaStyle.marginRelated
                      TibiaText {
                        text: {
                          if (_currentModelData.isRune) {
                            return qsTrId("magicalarchive_magic_level_restriction").arg(_currentModelData.minimumMagicLevel);
                          } else if (_currentModelData.minimumCasterLevel > 0) {
                            return qsTrId("magicalarchive_level_restriction_template").arg(_currentModelData.minimumCasterLevel);
                          } else {
                            return qsTrId("magicalarchive_level_no_restriction");
                          }
                        }
                      }
                    }
                  }
                }
              }
              TibiaFrame2PixelUpFilled {
                visible: root.validSpellSelected
                Layout.fillWidth: true
                Layout.fillHeight: true
                ColumnLayout {
                  anchors.fill: parent
                  anchors.margins: parent.borderWidth

                  TibiaFrame1PixelDown {
                    id: simpleTabBar
                    property int activeTabId: 0
                    property int buttonImageXOffset: 0
                    property int buttonTextXOffset: 15
                    property int buttonWidth: width / 3
                    property bool runePageEnabled: root.runePageEnabled

                    onActiveTabIdChanged: {
                      root._currentDetailTabId = activeTabId;
                    }

                    onRunePageEnabledChanged: {
                      if (activeTabId == 2 && !runePageEnabled) {
                        activeTabId = 0;
                      }
                    }

                    property var tabModelArray: {
                      let newTabModelArray = [
                        {
                          "tabId": 0,
                          "caption": qsTrId("magicalarchive_tabbar_combat_stats"),
                          "icon": "/images/icon-magicalarchive-combatstats.png"
                        }
                        , {
                          "tabId": 1,
                          "caption": qsTrId("magicalarchive_tabbar_additional_information"),
                          "icon": "/images/icon-magicalarchive-additionalinfo.png"
                        }
                      ]; //tabModel
                      if (simpleTabBar.runePageEnabled) {
                        newTabModelArray.push({
                          "tabId": 2,
                          "caption": qsTrId("magicalarchive_tabbar_rune_information"),
                          "icon": "/images/icon-magicalarchive-runeinfo.png",
                        });
                      }
                      return newTabModelArray;
                    }

                    Layout.fillWidth: true
                    Layout.preferredHeight: 38

                    BorderImage {
                      source: "/images/background-dark.png"
                      anchors.fill: parent
                      anchors.margins: parent.borderWidth
                      horizontalTileMode: BorderImage.Repeat
                      verticalTileMode: BorderImage.Repeat
                    }

                    RowLayout {
                      anchors.fill: parent
                      anchors.margins: parent.borderWidth
                      spacing: 0
                      Repeater {
                        model: simpleTabBar.tabModelArray
                        TibiaButton {
                          Layout.fillHeight: true
                          Layout.preferredWidth: simpleTabBar.buttonWidth
                          Layout.alignment: Qt.AlignLeft
                          text: modelData.caption
                          textFont: TibiaStyle.defaultTextFont
                          imageSource: modelData.icon;
                          imageAnchor: "left"
                          imageXOffset: simpleTabBar.buttonImageXOffset
                          textXOffset: simpleTabBar.buttonTextXOffset

                          checkable: true
                          checked: simpleTabBar.buttonIndexChecked == modelData

                          useButtonShouldBeChecked: true
                          buttonShouldBeChecked: simpleTabBar.activeTabId == modelData.tabId

                          onClicked: {
                            simpleTabBar.activeTabId = modelData.tabId ?? 0;
                          }
                        }
                      }
                      Item {
                        Layout.fillWidth: true
                      }
                    }
                  }

                  Loader {
                    id: detailPageLoader
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: TibiaStyle.marginRelated
                    sourceComponent: {
                      if (!root.validSpellSelected) {
                        return undefined;
                      }
                      switch (root._currentDetailTabId) {
                        case 0:
                          return combatStatsComponent;
                        case 1:
                          return additionalComponent;
                        case 2:
                          return runeStatsComponent;
                      }
                    }
                  }

                  Component {
                    id: combatStatsComponent
                    Item {
                      property var currentModelData: root._currentModelData ? root._currentModelData.relevantUsageInfo : {}

                      ColumnLayout {
                        anchors.fill: parent
                        spacing: TibiaStyle.marginRelated

                        GridLayout {
                          id: gridLayout
                          property int detailRowHeight: 78
                          Layout.fillWidth: true
                          columns: 4
                          rows: 2
                          rowSpacing: 0
                          columnSpacing: 0

                          TibiaFrame1PixelDown {
                            Layout.fillWidth: true
                            Layout.preferredHeight: gridLayout.detailRowHeight
                            ColumnLayout {
                              anchors.top: parent.top
                              anchors.left: parent.left
                              anchors.right: parent.right
                              anchors.margins: TibiaStyle.marginRelated
                              TibiaText {
                                Layout.fillWidth: true
                                text: {
                                  if (currentModelData.soulPointsCost > 0) {
                                    return qsTrId("spelllist_label_spell_mana_soulpoints")
                                  } else {
                                    return qsTrId("spelllist_label_spell_mana")
                                  }
                                }
                              }
                              TibiaText {
                                Layout.fillWidth: true
                                text: qsTrId("magicalarchive_combat_stats_spell_group")
                              }
                              TibiaText {
                                Layout.fillWidth: true
                                text: qsTrId("magicalarchive_combat_stats_basepower")
                              }
                              TibiaText {
                                Layout.fillWidth: true
                                text: qsTrId("magicalarchive_combat_stats_damage_scaling")
                              }
                            }
                          }
                          TibiaFrame1PixelDown {
                            Layout.fillWidth: true
                            Layout.preferredHeight: gridLayout.detailRowHeight
                            ColumnLayout {
                              anchors.top: parent.top
                              anchors.left: parent.left
                              anchors.right: parent.right
                              anchors.margins: TibiaStyle.marginRelated
                              TibiaText {
                                Layout.fillWidth: true
                                text: {
                                  if (currentModelData.manaCost == 0 && currentModelData.soulPointsCost == 0) {
                                    return "-"
                                  } else {
                                    return `${currentModelData.manaCost ?? "-"}` + (currentModelData.soulPointsCost ? ` / ${currentModelData.soulPointsCost}` : "");
                                  }
                                }
                              }
                              TibiaText {
                                Layout.fillWidth: true
                                text: currentModelData.groups ?? "-"
                              }
                              // TibiaText {
                              //   text: root._currentModelData.type
                              // }
                              TibiaText {
                                property int meanValue: currentModelData.mean ?? "0"
                                Layout.fillWidth: true
                                text: meanValue != 0 ? meanValue : "-"
                              }
                              TibiaText {
                                property var scalingArray: root._currentModelData.scaling ?? []
                                Layout.fillWidth: true
                                text: scalingArray.length > 0 ? scalingArray.join(", ") : "-"
                              }
                            }
                          }
                          TibiaFrame1PixelDown {
                            Layout.fillWidth: true
                            Layout.preferredHeight: gridLayout.detailRowHeight
                            ColumnLayout {
                              anchors.top: parent.top
                              anchors.left: parent.left
                              anchors.right: parent.right
                              anchors.margins: TibiaStyle.marginRelated
                              TibiaText {
                                text: qsTrId("magicalarchive_combat_stats_cooldown")
                              }
                              TibiaText {
                                text: qsTrId("magicalarchive_combat_stats_group_cooldown")
                              }
                              TibiaText {
                                text: qsTrId("spelllist_label_damage_type")
                              }
                              TibiaText {
                                text: qsTrId("magicalarchive_combat_stats_range")
                              }
                            }
                          }
                          TibiaFrame1PixelDown {
                            Layout.fillWidth: true
                            Layout.preferredHeight: gridLayout.detailRowHeight
                            ColumnLayout {
                              anchors.top: parent.top
                              anchors.left: parent.left
                              anchors.right: parent.right
                              anchors.margins: TibiaStyle.marginRelated
                              TibiaText {
                                text: currentModelData.cooldown ?? "-"
                              }
                              TibiaText {
                                text: currentModelData.groupCooldowns ?? "-"
                              }
                              TibiaText {
                                text: currentModelData.damagetype ?? "-"
                              }
                              TibiaText {
                                text: (magicalArchiveSpellPreview.spellRange ?? "0") == 0 ? "-" : magicalArchiveSpellPreview.spellRange
                              }
                            }
                          }
                        }

                        Item {
                          Layout.fillWidth:  true
                          Layout.fillHeight: true
                          TibiaFrame1PixelDown {
                            anchors.fill: parent
                            visible: root._currentSpellPreview && (root._currentSpellPreview.timestamps ?? []).length > 0 ? true : false
                            MagicalArchiveSpellPreview {
                              id: magicalArchiveSpellPreview
                              spellPreviewData: root._currentSpellPreview
                              anchors.fill: parent
                              anchors.margins: parent.borderWidth * 2
                            }
                          }
                        }
                      }
                    }
                  }
                  Component {
                    id: additionalComponent
                    Item {
                      property int detailRowHeight: 40
                      property int detailRowHeightSmall: 24
                      property int leftColumnWidth: 80
                      property var currentModelData: root._currentModelData
                      GridLayout {
                        id: gridLayout

                        anchors.fill: parent
                        columns: 2
                        rowSpacing: 0
                        columnSpacing: 0
                        TibiaFrame1PixelDown {
                          Layout.preferredWidth: leftColumnWidth
                          Layout.preferredHeight: detailRowHeightSmall
                          ColumnLayout {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.margins: TibiaStyle.marginRelated
                            TibiaText {
                              text: qsTrId("magicalarchive_additional_spell_source")
                            }
                          }
                        }
                        TibiaFrame1PixelDown {
                          Layout.fillWidth: true
                          Layout.preferredHeight: detailRowHeightSmall
                          ColumnLayout {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.margins: TibiaStyle.marginRelated
                            TibiaText {
                              textFormat: Text.RichText
                              text: {
                                if (currentModelData.source == TibiaEnums.SpellSourceWheelOfDestiny) {
                                  return qsTrId("magicalarchive_additional_spell_source_wheelofdestiny");
                                } else if (currentModelData.source == TibiaEnums.SpellSourceThreeFoldPath) {
                                  return qsTrId("magicalarchive_additional_spell_source_threefoldpath")
                                } else  if (currentModelData.minimumCasterLevel <= 2) {
                                  return qsTrId("magicalarchive_additional_spell_source_initial");
                                } else {
                                  return qsTrId("magicalarchive_additional_spell_source_level_template").arg(TextHelper.formatNumberWithThousandSeparators(currentModelData.minimumCasterLevel))
                                }
                              }
                            }
                          }
                        }
                        //if new fields are needed check history for old layout
                        TibiaFrame1PixelDown {
                          id: descriptionFrame
                          Layout.fillWidth: true
                          Layout.fillHeight: true
                          Layout.columnSpan: 2
                          Layout.topMargin: TibiaStyle.marginRelated
                          TibiaScrollView {
                            id: descriptionTextScrollView
                            anchors.fill: parent
                            anchors.margins: parent.borderWidth
                            ColumnLayout {
                              width: descriptionTextScrollView.width - descriptionTextScrollView.effectiveScrollBarWidth
                              TibiaText {
                                id: descriptionText
                                onTextChanged: {
                                  descriptionTextScrollView.contentItem.contentY = 0;
                                }

                                Layout.fillWidth: true
                                Layout.margins: TibiaStyle.marginRelated
                                text: `<html><style>a { text-decoration: none; color: ${color} }</style>${currentModelData.description}<html>`
                                textFormat: TextEdit.RichText
                                wrapMode: Text.WordWrap
                              }
                            }
                          }
                        }
                      }

                    }
                  }
                  Component {
                    id: runeStatsComponent

                    Item {
                      property var currentModelData: root._currentModelData ? root._currentModelData.spellUsageInfo : {}

                      ColumnLayout {
                        anchors.fill: parent

                        GridLayout {
                          id: gridLayout
                          property int detailRowHeight: 78
                          Layout.fillWidth: true
                          columns: 4
                          rows: 2
                          rowSpacing: 0
                          columnSpacing: 0

                          TibiaFrame1PixelDown {
                            Layout.fillWidth: true
                            Layout.preferredHeight: gridLayout.detailRowHeight
                            ColumnLayout {
                              anchors.top: parent.top
                              anchors.left: parent.left
                              anchors.right: parent.right
                              anchors.margins: TibiaStyle.marginRelated
                              TibiaText {
                                Layout.fillWidth: true
                                text: qsTrId("spelllist_label_spell_mana_soulpoints")
                              }
                              TibiaText {
                                Layout.fillWidth: true
                                text: qsTrId("magicalarchive_combat_stats_spell_group")
                              }
                              TibiaText {
                                Layout.fillWidth: true
                                text: qsTrId("magicalarchive_level_restriction_caption")
                              }
                              TibiaText {
                                Layout.fillWidth: true
                                text: qsTrId("magicalarchive_rune_stats_amount")
                              }
                            }
                          }
                          TibiaFrame1PixelDown {
                            Layout.fillWidth: true
                            Layout.preferredHeight: gridLayout.detailRowHeight
                            ColumnLayout {
                              anchors.top: parent.top
                              anchors.left: parent.left
                              anchors.right: parent.right
                              anchors.margins: TibiaStyle.marginRelated
                              TibiaText {
                                Layout.fillWidth: true
                                text: `${currentModelData.manaCost ?? "-"}` + (currentModelData.soulPointsCost ? ` / ${currentModelData.soulPointsCost}` : "")
                              }
                              TibiaText {
                                Layout.fillWidth: true
                                text: currentModelData.groups ?? "-"
                              }
                              TibiaText {
                                Layout.fillWidth: true
                                text: qsTrId("magicalarchive_level_restriction_template").arg(root._currentModelData.minimumCasterLevel)
                              }
                              TibiaText {
                                Layout.fillWidth: true
                                text: root._currentModelData.runeAmount
                              }
                            }
                          }
                          TibiaFrame1PixelDown {
                            Layout.fillWidth: true
                            Layout.preferredHeight: gridLayout.detailRowHeight
                            ColumnLayout {
                              anchors.top: parent.top
                              anchors.left: parent.left
                              anchors.right: parent.right
                              anchors.margins: TibiaStyle.marginRelated
                              TibiaText {
                                text: qsTrId("magicalarchive_combat_stats_cooldown")
                              }
                              TibiaText {
                                text: qsTrId("magicalarchive_combat_stats_group_cooldown")
                              }
                              TibiaText {
                                text: qsTrId("magicalarchive_rune_stats_vocations")
                              }
                            }
                          }
                          TibiaFrame1PixelDown {
                            Layout.fillWidth: true
                            Layout.preferredHeight: gridLayout.detailRowHeight
                            ColumnLayout {
                              anchors.top: parent.top
                              anchors.left: parent.left
                              anchors.right: parent.right
                              anchors.margins: TibiaStyle.marginRelated
                              TibiaText {
                                text: currentModelData.cooldown ?? "-"
                              }
                              TibiaText {
                                text: currentModelData.groupCooldowns ?? "-"
                              }
                              RowLayout {
                                Layout.alignment: Qt.AlignLeft
                                spacing: TibiaStyle.marginRelated
                                Repeater {
                                  model: currentModelData.allowedVocationInfos
                                  Image {
                                    source: modelData.iconUrl
                                    Tooltip {
                                      anchors.fill: parent
                                      text: modelData.tooltip
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                        Item {
                          Layout.fillHeight: true
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
} // Item
