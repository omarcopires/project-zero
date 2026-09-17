import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qmlcomponents
import QtQuick.LegacyControls


Item {
  id: rootElement
  property var controller: null
  property var monsterBonusEffectsModel: controller != null ? controller.monsterBonusEffects : []
  property var monsterNamesModel: controller != null ? controller.monsterInfos : [];
  property int selectedIndex: -1
  property var oldSelectedIndex: -1
  property var __preventClearingOfSelection: false
  property var selectedBonusEffect: null
  property var singleMonsterNameModel: []
  property bool monsterSelectionIsPossible: selectedBonusEffect != null ? selectedBonusEffect.unlocked && selectedBonusEffect.assigned == false : false;
  property var selectedMonsterRaceID: null
  property var unassignedMonstersNameFilter: controller != null ? controller.unassignedMonstersNameFilter : "";
  property string storeButtonTooltip: controller != null ? controller.storeButtonTooltip : "";
  property bool showStoreButtonTooltip: controller != null ? controller.showStoreButtonTooltip : false;

  onSelectedMonsterRaceIDChanged: {
    if (controller) {
      controller.temporarySelectedMonsterRaceID = selectedMonsterRaceID;
    }
  }

  onMonsterBonusEffectsModelChanged: {
    var currentSelectedIndex = controller != null ? controller.selectedBonusEffectId : monsterBonusEffectsGrid.currentIndex;
    var currentContentY = monsterBonusEffectsGrid.contentY;
    monsterBonusEffectsGrid.__preventRefreshOfSelectedIndex = true;
    monsterBonusEffectsGrid.model = monsterBonusEffectsModel;
    monsterBonusEffectsGrid.contentY = currentContentY;
    if (currentSelectedIndex == -1 && monsterBonusEffectsModel.length > 0) {
      currentSelectedIndex = 0;
    }
    monsterBonusEffectsGrid.currentIndex = currentSelectedIndex;
    monsterBonusEffectsGrid.__preventRefreshOfSelectedIndex = false;
    selectedIndex = monsterBonusEffectsGrid.currentIndex;
    selectedIndexChanged();

    if (controller && controller.activeTab == 1) {
      monsterBonusEffectsGrid.positionViewAtBeginning();
    }
  }

  onSelectedIndexChanged: {
    if (oldSelectedIndex == selectedIndex) {
      __preventClearingOfSelection = true;
    }
    oldSelectedIndex = selectedIndex;
    var newSelectedItem = monsterBonusEffectsModel != null && selectedIndex < monsterBonusEffectsModel.length ? monsterBonusEffectsModel[selectedIndex] : null;
    if (newSelectedItem != null && newSelectedItem.assignedMonsterRaceID != 0) {
      var newSingleMonsterNameModel = []
      newSingleMonsterNameModel.push({"id": 0, "name": controller.findMonsterNameByRaceID(newSelectedItem.assignedMonsterRaceID)});
      singleMonsterNameModel = newSingleMonsterNameModel
    }
    selectedBonusEffect = newSelectedItem;
    __preventClearingOfSelection = false;
  }

  onSelectedBonusEffectChanged: {
    if (__preventClearingOfSelection == false && selectedBonusEffect != null) {
      monsterNamesView.selection.clear();
    }
  }

  signal filterMonster(string NameFilter)

  // Cell sizing carefully tuned so that 3x4 cells fit into the available space
  readonly property int gridCellWidth: 153
  readonly property int gridCellHeight: 99
  readonly property int selectionBorderWidth: 2

  function isMajorCharmsTabActive() {
    return controller && controller.activeTab == leftRoot.tabId;
  }

  component CharmWithBorder: Image {
    id: charmImageComponent
    property var charmName: null
    property var charmDescription: null
    property var charmImage: null
    property var unlockGrade: TibiaEnums.NOTUNLOCKED

    source: switch (unlockGrade) {
      case TibiaEnums.GRADE1: "/images/backdrop_charmgrade1.png"; break;
      case TibiaEnums.GRADE2: "/images/backdrop_charmgrade2.png"; break;
      case TibiaEnums.GRADE3: "/images/backdrop_charmgrade3.png"; break;
      default: ""; break;
    }


    Image {
      id: bonusEffectImage
      anchors.centerIn: parent
      source: charmImageComponent.charmImage != null ? charmImageComponent.charmImage : ""
    } // Image

    Tooltip {
      anchors.fill: parent
      text: qsTrId("monsters_bonus_effect_icon_tooltip").arg(charmImageComponent.charmName).arg(charmImageComponent.charmDescription)
      maxWidth: TibiaStyle.tooltipRestrictedWidth
    } // Tooltip
  } // Image




  component MonsterComponent:  Rectangle {

    property bool hasAppearanceInstance: false
    property int  assignedMonsterRaceID: 0
    property bool temporaryAssigned: assignedMonsterRaceID == 0 && hasAppearanceInstance

    property alias creatureOutfitId: monsterRaceIcon.outfitId
    property alias creatureHeadColor: monsterRaceIcon.headColor
    property alias creatureTorsoColor: monsterRaceIcon.torsoColor
    property alias creatureLegsColor: monsterRaceIcon.legsColor
    property alias creatureDetailColor: monsterRaceIcon.detailColor
    property alias creatureFirstAddOn: monsterRaceIcon.firstAddOn
    property alias creatureSecondAddOn: monsterRaceIcon.secondAddOn

    Layout.preferredHeight: 64 + 2
    Layout.preferredWidth: 64 + 2
    Layout.alignment: Qt.AlignTop

    color: TibiaStyle.slotBackground
    TibiaFrame1PixelDown {
      anchors.fill: parent

      OutfitAppearanceInstanceRenderer {
        id: monsterRaceIcon
        visible: hasAppearanceInstance
        anchors.fill: parent
        anchors.margins: 2
        scaleFactor: 1
        opacity: temporaryAssigned ? 0.3 : 1.0
        moving: true
        showNoOutfitImage: false
      } //OutfitAppearanceInstanceRenderer
    } // TibiaFrame1PixelDown
  } //Rectangle



  Component {
    id: bonusEffectAndMonsterComponent

    GridLayout {
      id: bonusEffectAndMonsterComponentRoot
      property var charmName: null
      property var charmDescription: null
      property var bonusEffectIconUrl: null
      property var resourceCostString: "0"
      property bool tooLowBalance: true
      property bool tooLowBalanceGold: true
      property bool tooLowBalanceForReset: true
      property bool resourceIsBonusPoints: true
      property bool isUnlocked: false
      property var unlockGrade: TibiaEnums.NOTUNLOCKED
      property bool forceShowIcon: false
      property int  assignedMonsterRaceID: 0
      property bool hasAppearanceInstance: false
      property bool temporaryAssigned: assignedMonsterRaceID == 0 && hasAppearanceInstance

      property alias creatureOutfitId: monsterIcon.creatureOutfitId
      property alias creatureHeadColor: monsterIcon.creatureHeadColor
      property alias creatureTorsoColor: monsterIcon.creatureTorsoColor
      property alias creatureLegsColor: monsterIcon.creatureLegsColor
      property alias creatureDetailColor: monsterIcon.creatureDetailColor
      property alias creatureFirstAddOn: monsterIcon.creatureFirstAddOn
      property alias creatureSecondAddOn: monsterIcon.creatureSecondAddOn

      columns: 2
      rows: 1
      rowSpacing: 0
      columnSpacing: 0

      Item {
        Layout.column: 0
        Layout.row: 0
        Layout.alignment: Qt.AlignCenter
        Layout.preferredWidth: 68
        Layout.preferredHeight: 66

        Rectangle {
          id: iconWrapper

          anchors.centerIn: parent

          color: TibiaStyle.slotBackground
          TibiaFrame1PixelDown {
            id: bonusEffectIcon
            width: 42
            height: 42
            anchors.centerIn: parent

            CharmWithBorder {
              anchors.horizontalCenter: parent.horizontalCenter
              anchors.verticalCenter: parent.verticalCenter

              charmName: bonusEffectAndMonsterComponentRoot.charmName
              charmDescription: bonusEffectAndMonsterComponentRoot.charmDescription
              charmImage: bonusEffectAndMonsterComponentRoot.bonusEffectIconUrl
              unlockGrade: bonusEffectAndMonsterComponentRoot.unlockGrade
            } // CharmWithBorder

          } // TibiaFrame1PixelDown
          TibiaDisabledOverlay {
            anchors.fill: bonusEffectIcon
            anchors.margins: 1
            visible: !(isUnlocked || forceShowIcon)
          }
        } // Rectangle
      } // Item

      ColumnLayout {
        Layout.fillHeight: true
        spacing: 0
        Layout.column: 1
        Layout.row: 0
        //Layout.rowSpan: 3
        Layout.alignment: Qt.AlignRight | Qt.AlignTop      

        MonsterComponent {
          id: monsterIcon

          Layout.preferredHeight: 64 + 2
          Layout.preferredWidth: 64 + 2
          Layout.alignment: Qt.AlignTop

          assignedMonsterRaceID: bonusEffectAndMonsterComponentRoot.assignedMonsterRaceID
          hasAppearanceInstance: bonusEffectAndMonsterComponentRoot.hasAppearanceInstance
          temporaryAssigned: bonusEffectAndMonsterComponentRoot.temporaryAssigned
        } //MonsterComponent

      } //ColumnLayout

    } // GridLayout
  } // Component

  Component {
    id: bonusEffectComponent
    Item {
      property var modelData: monsterBonusEffectsGrid.model != null && index < monsterBonusEffectsGrid.model.length
                            ? monsterBonusEffectsGrid.model[index] : null
      property var isSelected: index == monsterBonusEffectsGrid.currentIndex
      property var isUnlocked: modelData != null ? modelData.unlocked : false
      property var unlockGrade: modelData != null ? modelData.unlockGrade : TibiaEnums.NOTUNLOCKED
      width: monsterBonusEffectsGrid.cellWidth
      height: monsterBonusEffectsGrid.cellHeight
      Rectangle {
        color: "transparent"
        border.width: isSelected ? selectionBorderWidth : 0
        border.color: "white"

        width: gridCellWidth
        height: gridCellHeight
        anchors.centerIn: parent

        TibiaFrame2PixelUpFilledWithCaption {
          id: monsterCell
          anchors.fill: parent
          anchors.margins: selectionBorderWidth

          caption: modelData != null ? modelData.name : qsTrId("dummy_unknown")

          Loader {
            anchors { left: parent.left; leftMargin: parent.borderWidth + TibiaStyle.marginRelated;
                      right: parent.right; rightMargin: parent.borderWidth + TibiaStyle.marginRelated;
                      top: parent.top; topMargin: parent.captionHeight + TibiaStyle.marginRelated;
                      bottom: parent.bottom; bottomMargin: parent.borderWidth + TibiaStyle.marginRelated}
            sourceComponent: bonusEffectAndMonsterComponent

            Component.onCompleted: {

              item.charmName = modelData != null ? modelData.name : "";
              item.charmDescription = modelData != null ? modelData.description : "";
              item.bonusEffectIconUrl = modelData != null ? modelData.imageSource : "";
              item.resourceCostString = modelData != null ? modelData.resourceCostString : "0";
              item.tooLowBalance = modelData != null ? modelData.notEnoughResource : true;

              item.resourceIsBonusPoints = isUnlocked == false;
              item.isUnlocked = isUnlocked;
              item.unlockGrade = unlockGrade;
              item.assignedMonsterRaceID = modelData != null ? modelData.assignedMonsterRaceID : "";
              item.hasAppearanceInstance = Qt.binding(function() { return modelData != null ? modelData.hasAppearanceInstance : false; });
              item.creatureOutfitId = Qt.binding(function() { return modelData != null ? modelData.creatureOutfitId : 0 ; });
              item.creatureHeadColor = Qt.binding(function() { return modelData != null ? modelData.creatureHeadColor : "black" ; });
              item.creatureTorsoColor = Qt.binding(function() { return modelData != null ? modelData.creatureTorsoColor : "black" ; });
              item.creatureLegsColor = Qt.binding(function() { return modelData != null ? modelData.creatureLegsColor : "black" ; });
              item.creatureDetailColor = Qt.binding(function() { return modelData != null ? modelData.creatureDetailColor : "black" ; });
              item.creatureFirstAddOn = Qt.binding(function() { return modelData != null ? modelData.creatureFirstAddOn : false ; });
              item.creatureSecondAddOn = Qt.binding(function() { return modelData != null ? modelData.creatureSecondAddOn : false ; });
            } //Component.onCompleted
          } //Loader
        } //TibiaFrame2PixelUpFilledWithCaption
        MouseArea {
          anchors.fill: parent
          enabled: !isSelected

          onClicked: {
            monsterBonusEffectsGrid.currentIndex = index;
          } //onClicked
        } // MouseArea
      } //Rectangle
    }
  } // Component

  ColumnLayout {

    id: outerLayout
    anchors { left: parent.left;
              right: parent.right;
              top: parent.top;
              bottom: parent.bottom; bottomMargin: TibiaStyle.marginRelated;}

    property var tooLowBalance: true
    property var tooLowBalanceGold: true
    property var tooLowBalanceReset: controller != null ? controller.notEnoughGoldReset : true
    property var assignedMonsterRaceID: 0
    property var clearCostString: "0"
    property bool isMinor: false
    property var resourceCostString: "0"
    property var resetCostString: controller != null ? controller.resetCostString : "0"
    property var charmName: "Selected Charm"
    property var bonusEffectIconUrl: ""
    property var unlockGrade: TibiaEnums.NOTUNLOCKED

    property bool hasAppearanceInstance: false
    property var creatureOutfitId: 0
    property var creatureHeadColor: "black"
    property var creatureTorsoColor: "black"
    property var creatureLegsColor: "black"
    property var creatureDetailColor: "black"
    property bool creatureFirstAddOn: false
    property bool creatureSecondAddOn: false

    RowLayout {
      id: informationPanelWrapper
      Layout.preferredHeight: selectedCharmElement.height
      property alias selectedBonusEffect: rootElement.selectedBonusEffect

      onSelectedBonusEffectChanged: {
        var itemToView = informationPanelWrapper.selectedBonusEffect;
        nameFilterText.text = "";
        if (controller) {
          controller.unassignedMonstersNameFilter = "";
        }
        if (itemToView == null) {
          return;
        }
        var isUnlocked = false;
        var isAssigned = false;
        outerLayout.tooLowBalance = true;
        var canAssignMoreBonusEffects = controller != null ? controller.canAssignMoreBonusEffects : false;
        if (itemToView != null) {
          isUnlocked = itemToView.unlocked;
          isAssigned = itemToView.assigned;
          outerLayout.tooLowBalance = itemToView.notEnoughResource;
          outerLayout.tooLowBalanceGold = itemToView.notEnoughGold;
          outerLayout.resourceCostString = itemToView.resourceCostString;
          outerLayout.bonusEffectIconUrl = itemToView.imageSource;
          outerLayout.assignedMonsterRaceID = itemToView.assignedMonsterRaceID;
          outerLayout.unlockGrade = itemToView.unlockGrade;
          outerLayout.charmName = itemToView.name;
          outerLayout.clearCostString = itemToView.clearCostString;
          outerLayout.isMinor = itemToView.isMinor

          outerLayout.hasAppearanceInstance = itemToView.hasAppearanceInstance;
          outerLayout.creatureOutfitId = itemToView.creatureOutfitId;
          outerLayout.creatureHeadColor = itemToView.creatureHeadColor;
          outerLayout.creatureTorsoColor = itemToView.creatureTorsoColor;
          outerLayout.creatureLegsColor = itemToView.creatureLegsColor;
          outerLayout.creatureDetailColor = itemToView.creatureDetailColor;
          outerLayout.creatureFirstAddOn = itemToView.creatureFirstAddOn;
          outerLayout.creatureSecondAddOn = itemToView.creatureSecondAddOn;
        }

        if (isUnlocked) {
          if (isAssigned) {
            monsterNamesView.modelToUse = singleMonsterNameModel;
            monsterNamesView.isSingleMonsterModel = true;
            if (controller) {
              controller.temporarySelectedMonsterRaceID = outerLayout.assignedMonsterRaceID;
            }
          } else {
            monsterNamesView.modelToUse = Qt.binding(function() {return monsterNamesModel;});
            monsterNamesView.isSingleMonsterModel = false;
            if (controller) {
              controller.temporarySelectedMonsterRaceID = 0;
            }
          }
        } else {
          monsterNamesView.modelToUse = Qt.binding(function() {return [];});
          monsterNamesView.isSingleMonsterModel = false;
          if (controller) {
            controller.temporarySelectedMonsterRaceID = 0;
          }
        }


      } // onSelectedBonusEffectChanged



      function onActionButtonClicked() {
        var itemToView = informationPanelWrapper.selectedBonusEffect;
        var isUnlocked = false;
        var isAssigned = false;
        var bonusEffectID = 0;
        if (itemToView) {
          isUnlocked = itemToView.unlocked;
          isAssigned = itemToView.assigned;
          bonusEffectID = itemToView.id;
          outerLayout.assignedMonsterRaceID = itemToView.assignedMonsterRaceID;
        }
        if (isUnlocked) {
          if (isAssigned) {
            controller.clearBonusEffect(bonusEffectID);
          } else {
            controller.assignBonusEffectToMonster(bonusEffectID, selectedMonsterRaceID);
          }
        } else {
          controller.unlockBonusEffect(bonusEffectID);
        }
      } // onActionButtonClicked

      TibiaFrame2PixelUpFilledWithCaption {

        caption: outerLayout.charmName
        Layout.preferredHeight: 120
        Layout.fillWidth: true
        id: selectedCharmElement

        RowLayout {
          anchors { left: parent.left; leftMargin: parent.borderWidth + TibiaStyle.marginRelated;
            right: parent.right; rightMargin: parent.borderWidth + TibiaStyle.marginRelated;
            top: parent.top; topMargin: parent.topMarginToContent;
            bottom: parent.bottom; bottomMargin: parent.borderWidth + TibiaStyle.marginRelated; }

          TibiaText {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 164
            text: selectedBonusEffect != null ? selectedBonusEffect.description : ""
            wrapMode: Text.Wrap
          } // TibiaText

          TibiaFrame1PixelDown {
            id: charmFramedown
            Layout.preferredWidth: 42
            Layout.preferredHeight: Layout.preferredWidth

            CharmWithBorder {
              anchors.horizontalCenter: parent.horizontalCenter
              anchors.verticalCenter: parent.verticalCenter

              charmName: informationPanelWrapper.selectedBonusEffect != null ? informationPanelWrapper.selectedBonusEffect.name : ""
              charmDescription: informationPanelWrapper.selectedBonusEffect != null ? informationPanelWrapper.selectedBonusEffect.description : ""
              charmImage: outerLayout.bonusEffectIconUrl
              unlockGrade: outerLayout.unlockGrade
            } // CharmWithBorder

            TibiaDisabledOverlay {
              anchors.fill: charmFramedown
              anchors.margins: 1
              visible: outerLayout.unlockGrade == TibiaEnums.NOTUNLOCKED
            }
          } // TibiaFrame1PixelDown

          ColumnLayout {
            Layout.alignment: Qt.AlignVCenter
            spacing: 2*TibiaStyle.marginNarrow

            TibiaButton {
              id: bonusEffectUpgradeButton
              Layout.fillWidth: true
              Layout.alignment: Qt.AlignTop
              text: selectedBonusEffect != null ? selectedBonusEffect.upgradeButtonText : ""
              textLeftPadding: TibiaStyle.marginNarrow
              textRightPadding: TibiaStyle.marginNarrow
              // unless the bonus is fully unlocked, you can upgrade it
              enabled: !outerLayout.tooLowBalance && (selectedBonusEffect != null ? selectedBonusEffect.unlockGrade != TibiaEnums.GRADE3 : false)

              onClicked : {
                if (enabled && controller) {
                  controller.unlockBonusEffect(selectedBonusEffect.id);
                }
              }

              Tooltip {
                anchors.fill: parent
                visible: !bonusEffectUpgradeButton.enabled
                text: outerLayout.tooLowBalance ?
                  qsTrId(outerLayout.isMinor ? "monster_bonus_effects_tooltip_not_enough_charm_echoes"
                                             : "monster_bonus_effects_tooltip_not_enough_charmpoints")
                    : (informationPanelWrapper.selectedBonusEffect == null
                      ? qsTrId("monster_bonus_effects_tooltip_no_charm_selected")
                      : qsTrId("monster_bonus_effects_tooltip_fully_unlocked"))
                maxWidth: TibiaStyle.tooltipRestrictedWidth
              } // Tooltip
            } // TibiaButton

            TibiaCurrencyView {
              id: currencyView
              Layout.fillWidth: true

              balance: (selectedBonusEffect != null ? selectedBonusEffect.unlockGrade != TibiaEnums.GRADE3 : false) ? outerLayout.resourceCostString : "0"
              tooLowBalance: outerLayout.tooLowBalance
              iconId: isMajorCharmsTabActive() ? "MonsterBonusPoints" : "MinorCharmEchoes"
            } //TibiaCurrencyView

            TibiaButton {
              id: clearCharmButton
              Layout.fillWidth: true
              Layout.alignment: Qt.AlignTop
              text: qsTrId("monster_bonus_effects_clear_charm_button")
              enabled: outerLayout.assignedMonsterRaceID != 0 && !outerLayout.tooLowBalanceGold

              onClicked : {
                if (enabled && controller) {
                  controller.clearBonusEffect(selectedBonusEffect.id);
                }
              }

              Tooltip {
                anchors.fill: parent
                visible: !clearCharmButton.enabled
                text: outerLayout.tooLowBalanceGold ? qsTrId("monster_bonus_effects_tooltip_not_enough_clear_gold")
                        : qsTrId("monster_bonus_effects_tooltip_no_charm_assigned")
                maxWidth: TibiaStyle.tooltipRestrictedWidth
              } // Tooltip
            } // TibiaButton

            TibiaCurrencyView {
              id: currencyViewGold
              Layout.fillWidth: true

              balance: outerLayout.assignedMonsterRaceID != 0 ? outerLayout.clearCostString : "0"
              tooLowBalance: outerLayout.tooLowBalanceGold
              iconId: "GoldCoin"
            } //TibiaCurrencyView
          } // ColumnLayout

          GridLayout {
            id: creatureSelectLayout
            rows: 2
            columns: 2
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            readonly property int leftColumnSize: 140
            readonly property int rightColumnSize: 78

            TibiaTextSearchField {
              id: nameFilterText

              Layout.preferredWidth: creatureSelectLayout.leftColumnSize
              Layout.preferredHeight: 20
              Layout.column: 0
              Layout.row: 0

              maximumLength: TibiaStyle.maxCharacterNameLength
              enabled: rootElement.monsterSelectionIsPossible
              KeyNavigation.tab: nameFilterText
              KeyNavigation.backtab: nameFilterText
              shouldBeText: rootElement.unassignedMonstersNameFilter
              onTextChanged: {
                if (controller != null) {
                  monsterNamesView.selection.clear();
                  controller.unassignedMonstersNameFilter = text;
                }
              } //onTextChanged
            } // TibiaTextField

            Rectangle {
              Layout.preferredWidth: creatureSelectLayout.leftColumnSize
              Layout.preferredHeight: 67
              color: TibiaStyle.tableViewBackgroundColor
              Layout.column: 0
              Layout.row: 1

              TibiaTableView {
                id: monsterNamesView
                anchors.fill: parent
                property bool __preventInitialSelection: false
                property bool __preventSelectionChange: false

                property var modelToUse : []
                property bool isSingleMonsterModel: false
                onModelToUseChanged: {
                  var currentSelectedIndex = -1;
                  var currentPosition = 0;

                  selection.forEach(function(rowIndex) {
                    currentSelectedIndex = rowIndex;
                  });
                  currentPosition = flickableItem.contentY;
                  var clearSelection = false;
                  __preventInitialSelection = true;
                  this.model = Qt.binding(function() {return modelToUse;});
                  __preventInitialSelection = false;

                  if (this.model != null) {
                    if (currentSelectedIndex >= this.model.length) {
                      currentSelectedIndex = -1;
                    }
                  }
                  __preventSelectionChange = true;
                  selection.clear();
                  if (currentSelectedIndex > -1) {
                    selection.select(currentSelectedIndex, currentSelectedIndex);
                  }
                  __preventSelectionChange = false;
                  selection.selectionChanged();
                  flickableItem.contentY = currentPosition;
                }
                headerVisible: false
                Layout.fillWidth: true
                horizontalScrollBarPolicy: ScrollBar.AlwaysOff
                enabled: monsterSelectionIsPossible;
                model: modelToUse

                TableViewColumn { role: "name" }

                selection.onSelectionChanged: {
                  var selectedIndex = -1;
                  if (isSingleMonsterModel) {
                    selection.forEach(function(rowIndex) {
                      if (rowIndex >= 0 && rowIndex < model.length) {
                        selectedIndex = rowIndex;
                      }
                    });
                    return;
                  } else if (__preventSelectionChange) {
                    return;
                  } else if (selection.count == 0) {
                    selectedMonsterRaceID = 0;
                    selectedIndex = -1;
                  } else if (__preventInitialSelection && selection.count > 0) {
                    selection.clear();
                    __preventInitialSelection = false;
                    selectedIndex = -1;
                  } else {
                    selection.forEach(function(rowIndex) {
                      if (rowIndex >= 0 && rowIndex < model.length) {
                        selectedMonsterRaceID = model[rowIndex]["id"];
                      } else {
                        selectedMonsterRaceID = 0;
                      }
                      selectedIndex = rowIndex;
                    });
                  }

                  if (controller) {
                    controller.temporarySelectedMonsterIndex = selectedIndex;
                  }
                } //selection.onSelectionChanged

                property int shouldBeSelectedIndex: controller != null ? controller.temporarySelectedMonsterIndex : 0
                onShouldBeSelectedIndexChanged: {
                  setSelectedIndexAsync.start();
                } //onShouldBeSelectedIndexChanged

                Timer {
                  id: setSelectedIndexAsync
                  interval: 1
                  onTriggered: {
                    if (monsterNamesView.shouldBeSelectedIndex == -1) {
                      monsterNamesView.selection.clear();
                    } else if (0 <= monsterNamesView.shouldBeSelectedIndex && monsterNamesView.shouldBeSelectedIndex < monsterNamesView.model.length) {
                      monsterNamesView.selection.select(monsterNamesView.shouldBeSelectedIndex);
                    }
                  } //onTriggered
                } //Timer
              } // TibiaTableView
            } // Rectangle

            // select creature button
            TibiaButton {
              id: assignCharmButton
              Layout.preferredWidth: creatureSelectLayout.rightColumnSize
              Layout.alignment: Qt.AlignTop
              Layout.column: 1
              Layout.row: 0

              text: qsTrId("monster_bonus_effects_select_creature_button")
              enabled: outerLayout.assignedMonsterRaceID == 0 && outerLayout.unlockGrade != TibiaEnums.NOTUNLOCKED && rootElement.selectedMonsterRaceID != 0  && (controller && controller.remainingCharms > 0)// TO DO max number

              onClicked : {
                if (enabled && controller) {
                  controller.assignBonusEffectToMonster(selectedBonusEffect.id, selectedMonsterRaceID);
                }
              }

              Tooltip {
                anchors.fill: parent
                visible: !assignCharmButton.enabled
                text: outerLayout.assignedMonsterRaceID != 0 ? qsTrId("monster_bonus_effects_tooltip_charm_already_assigned")
                        : outerLayout.unlockGrade == TibiaEnums.NOTUNLOCKED ? qsTrId("monster_bonus_effects_tooltip_charm_not_unlocked")
                        : (controller && controller.remainingCharms == 0) ? qsTrId("monster_bonus_effects_tooltip_no_more_remaining_charms")
                        : qsTrId("monster_bonus_effects_tooltip_no_creature_selected")
                maxWidth: TibiaStyle.tooltipRestrictedWidth
              } // Tooltip
            } // TibiaButton

            // creature bild
            MonsterComponent {
              Layout.preferredHeight: 64 + 2
              Layout.preferredWidth: creatureSelectLayout.rightColumnSize
              Layout.alignment: Qt.AlignTop
              Layout.column: 1
              Layout.row: 1

              assignedMonsterRaceID: controller != null ? controller.temporarySelectedMonsterRaceID : 0
              hasAppearanceInstance: controller != null ? controller.hasTemporarySelectedMonsterAppearanceInstance : false
              creatureOutfitId: controller != null ? controller.temporarySelectedMonsterOutfitId : 0
              creatureHeadColor: controller != null ? controller.temporarySelectedMonsterHeadColor : "black"
              creatureTorsoColor: controller != null ? controller.temporarySelectedMonsterTorsoColor : "black"
              creatureLegsColor: controller != null ? controller.temporarySelectedMonsterLegsColor : "black"
              creatureDetailColor: controller != null ? controller.temporarySelectedMonsterDetailColor : "black"
              creatureFirstAddOn: controller != null ? controller.temporarySelectedMonsterFirstAddOn : false
              creatureSecondAddOn: controller != null ? controller.temporarySelectedMonsterSecondAddOn : false

            } //MonsterComponent
          } // GridLayout
        } // RowLayout
      } // TibiaFrame2PixelUpFilledWithCaption

      TibiaFrame2PixelUpFilled {

        id: storeAndResetPanel
        Layout.preferredHeight: 117
        Layout.preferredWidth: 113

        property bool tooLowBalanceReset: controller != null ? controller.notEnoughGoldReset : true

        ColumnLayout {

          anchors.centerIn: parent
          TibiaText {
            visible: showStoreButtonTooltip
            Layout.preferredWidth: 100
            Layout.fillHeight: true
            text: controller != null ?
                  (controller.remainingCharms > 0 ?  qsTrId("monster_bonus_effects_information_remaining_charms").arg(controller.remainingCharms) : qsTrId("monster_bonus_effects_information_remaining_charms_redcolor").arg(controller.remainingCharms))
                  : ""
            wrapMode: Text.Wrap
          }

          RowLayout { // i Button & Store Button

            visible: showStoreButtonTooltip
            Layout.preferredWidth: 100
            TibiaGuiHelp {
              text: storeButtonTooltip
            } //TibiaGuiHelp
            TibiaButton {
              id: buttonStore
              Layout.preferredWidth: 78
              color: "blue"
              imageSource: "/images/icon-store-16x10.png"
              onClicked: { if (controller != null) controller.onStoreButtonClicked(); }
            } //TibiaIconButton

          } // RowLayout

          TibiaButton {
            id: resetCharmsButton
            Layout.preferredWidth: 100
            //Layout.alignment: Qt.AlignTop


            text: qsTrId("monster_bonus_effects_reset_charms_button")

            enabled: !storeAndResetPanel.tooLowBalanceReset && (controller != null ? controller.enableResetButton : false)


            onClicked : {
              if (enabled && controller) {
                controller.onResetAllCharmsClicked();
              }
            }

            Tooltip {
              anchors.fill: parent
              visible: !resetCharmsButton.enabled
              text: (controller && controller.numberOfUnlockedCharms > 0) ? qsTrId("monster_bonus_effects_tooltip_no_reset_possible") : qsTrId("monster_bonus_effects_tooltip_no_reset_possible_no_charms")
              maxWidth: TibiaStyle.tooltipRestrictedWidth
            } // Tooltip
          } // TibiaButton

          TibiaCurrencyView {
            id: currencyViewReset
            Layout.preferredWidth: 100

            balance: controller != null ? controller.resetCostString : "0"
            tooLowBalance: storeAndResetPanel.tooLowBalanceReset
            iconId: "GoldCoin"
          } //TibiaCurrencyView



        } // ColumnLayout

      } // TibiaFrame2PixelUpFilledWithCaption

    } // RowLayout

    ColumnLayout {

      Layout.preferredWidth: 667
      Layout.preferredHeight: 294

      TibiaFrame2PixelUpFilled {

        Layout.preferredHeight: 294
        Layout.fillWidth: true

        ColumnLayout {

          anchors.centerIn: parent
          anchors.left: parent.left
          anchors.right: parent.right

          TibiaFrame1PixelDown {

            id: root
            Layout.fillWidth: true
            Layout.preferredHeight: 38
            property int buttonImageXOffset: 0
            property int buttonTextXOffset: 15

            RowLayout {
              id: tabLayout
              anchors.fill: parent
              anchors.margins: root.borderWidth
              spacing: 0

              // buttons einbauen

              Item {

                id: leftRoot
                property int tabId: 0
                property bool disabled: false
                Layout.preferredWidth: (root.width/2)
                Layout.fillHeight: true


                TibiaButton {
                  id: leftButton
                  anchors.fill: leftRoot

                  enabled: true
                  textFont: TibiaStyle.defaultTextFont
                  imageAnchor: "left"
                  imageXOffset: root.buttonImageXOffset
                  textXOffset: root.buttonTextXOffset

                  text: qsTrId("monster_bonus_effects_tab_major_charms")
                  imageSource: "/images/icon-charms-major.png"

                  checkable: true
                  useButtonShouldBeChecked: true
                  buttonShouldBeChecked: controller != null ? controller.activeTab == leftRoot.tabId : true

                  onClicked: {
                    if (controller != null && controller.activeTab != leftRoot.tabId) {
                      controller.onActiveTabChanged(leftRoot.tabId);
                      monsterNamesView.__preventInitialSelection = true;
                    }
                  } //onClicked

                } //TibiaButton

              } // Item

              Item {

                id: rightRoot
                property int tabId: 1
                property bool disabled: false
                Layout.preferredWidth: (root.width/2)
                Layout.fillHeight: true


                TibiaButton {
                  id: rightButton
                  anchors.fill: rightRoot

                  enabled: true
                  textFont: TibiaStyle.defaultTextFont
                  imageAnchor: "left"
                  imageXOffset: root.buttonImageXOffset
                  textXOffset: root.buttonTextXOffset

                  text: qsTrId("monster_bonus_effects_tab_minor_charms")
                  imageSource: "/images/icon-charms-minor.png"

                  checkable: true
                  useButtonShouldBeChecked: true
                  buttonShouldBeChecked: controller != null ? controller.activeTab == rightRoot.tabId : false

                  onClicked: {
                    if (controller != null && controller.activeTab != rightRoot.tabId) {
                      controller.onActiveTabChanged(rightRoot.tabId);
                      monsterNamesView.__preventInitialSelection = true;
                    }
                  } //onClicked


                } //TibiaButton


              } // Item

            } // RowLayout

          } // TibiaFrame1PixelDown


          TibiaFrame1PixelDown {

            Layout.preferredHeight: 243
            Layout.preferredWidth: 4 * (gridCellWidth + 4 + 6) + 2 * TibiaStyle.marginNarrow + 4

            TibiaScrollView {

              id: monsterbonusEffectsScrollView
              anchors.fill: parent
              anchors.margins: 1

              GridView {
                id: monsterBonusEffectsGrid
                property var __preventRefreshOfSelectedIndex : false
                onCurrentIndexChanged: {
                  if (!__preventRefreshOfSelectedIndex) {
                    selectedIndex = monsterBonusEffectsGrid.currentIndex;
                    if (controller != null) {
                      controller.selectedBonusEffectId = selectedIndex
                    }
                  }
                } // onCurrentIndexChanged

                interactive: false //prevent flick behavior on touch screens
                boundsBehavior: Flickable.StopAtBounds
                pixelAligned: true
                highlightFollowsCurrentItem: true
                highlightMoveDuration: 0

                cellWidth: gridCellWidth + 6 + 1
                cellHeight: gridCellHeight
                delegate: bonusEffectComponent
              } // GridView
            } // TibiaScrollView

          } // TibiaFrame1PixelDown

        } // ColumnLayout

      } // TibiaFrame2PixelUpFilled

    } // ColumnLayout

  } // ColumnLayout
} // Item
