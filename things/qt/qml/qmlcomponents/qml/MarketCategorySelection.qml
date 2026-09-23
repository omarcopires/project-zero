import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qmlcomponents

import QtQuick.LegacyControls


ColumnLayout {
  id: root
  property alias categoryModel: categoryView.model
  property alias nameFilterField: nameFilterText
  property var categoryItemModel: null
  property bool weaponCategorySelected: false
  property bool useObjectCount: false

  property alias levelFilterButtonShouldBeChecked: levelFilterButton.checked
  property alias vocationFilterButtonShouldBeChecked: vocationFilterButton.checked
  property alias oneHandFilterButtonShouldBeChecked: oneHandFilterButton.checked
  property alias twoHandFilterButtonShouldBeChecked: twoHandFilterButton.checked
  property alias showLockerOnlyShouldBeChecked: showLockerOnlyCheckBox.shouldBeChecked

  property bool enableTierAndClassificationSelection : false
  property bool enableTierSelection : false
  property var availableTiers: null
  property int indexOfSelectedTier: -1
  property var availableClassifications: null
  property int indexOfSelectedClassification: -1
  property bool showTierFilter: true
  property int indexOfSelectedNPC: -1
  property var availableNPCs: null
  property bool npcFilterVisible: false
  /// If the control is embedded in a side bar widget, this property must be set to false
  /// Otherwise, the comboboxes will steal the focus on click, causing the chat to steal
  /// focus back immediately. Afterwards, the combobox is automatically closed by Qt
  /// because it lost focus.
  property bool focusOnComboboxes: true

  property int categoryViewHeight: TibiaStyle.marketCategoryViewHeight

  property bool widgetLayout: false
  readonly property int sideMargin: widgetLayout ? TibiaStyle.marginNarrow : 0
  readonly property int buttonMargin: widgetLayout ? TibiaStyle.marginNarrow : TibiaStyle.marginRelated
  readonly property real buttonWidth: (width - 2 * sideMargin - 3 * buttonMargin) * 0.25

  readonly property bool hasSelectedItem: itemView.objectAppearanceInstanceTypeId != 0 && itemView.currentIndex >= 0
  property alias searchTextFieldHasFocus: nameFilterText.focus

  signal categorySelected(int CategoryIdentifier, bool FilterByLevel, bool FilterByVocation,
                          bool OnlyOneHandWeapons, bool OnlyTwoHandWeapons, bool ShowLockerOnly)

  signal filterSelected(string NameFilter, bool FilterByLevel, bool FilterByVocation,
                        bool OnlyOneHandWeapons, bool OnlyTwoHandWeapons, bool ShowLockerOnly)

  signal itemSelected(int AppearanceId, int UpgradeTier)
  signal itemChosen(int AppearanceId, int UpgradeTier)
  signal itemRightClicked(int AppearanceId)
  signal itemClicked(int AppearanceId, int UpgradeTier, int MouseButton, int KeyboardModifiers)
  signal focusEnteredTextInput()
  signal acceptedTextInput()
  signal escPressedInSearchTextField()
  signal classificationFilterWasSelected(int CurrentIndex, string NameFilter, bool FilterByLevel, bool FilterByVocation,
                                         bool OnlyOneHandWeapons, bool OnlyTwoHandWeapons, bool ShowLockerOnly)
  signal tierFilterWasSelected(int CurrentIndex, string NameFilter, bool FilterByLevel, bool FilterByVocation,
                               bool OnlyOneHandWeapons, bool OnlyTwoHandWeapons, bool ShowLockerOnly)
  signal npcFilterWasSelected(int CurrentIndex, string NameFilter, bool FilterByLevel, bool FilterByVocation,
                                         bool OnlyOneHandWeapons, bool OnlyTwoHandWeapons, bool ShowLockerOnly)

  property bool __ignoreItemIndexChanged: false

  Layout.preferredWidth: TibiaStyle.marketCategoryViewWidth
  spacing: TibiaStyle.marginRelated

  //forward focus to search filter
  onFocusChanged: {
    if(focus) {
      nameFilterText.forceActiveFocus();
    }
  } //onFocusChanged

  onCategoryItemModelChanged: {
    __ignoreItemIndexChanged = true;
    itemView.model = categoryItemModel;
    __ignoreItemIndexChanged = false;
  } //onCategoryItemModelChanged

  function selectCategoryIndex(Index) {
    categoryView.selection.select(Index);
    categoryView.positionViewAtRow(Index, ListView.Visible);
  } //selectCategoryIndex(Index)

  function selectItemIndex(Index) {
    itemView.currentIndex = Index;
  } //function selectItemIndex(Index)

  function setNameFilter(NameFilter) {
    nameFilterText.text = NameFilter;
  } //function setNameFilter(NameFilter)

  function triggerItemListUpdate() {
    selectedItemView.resetView();
    __ignoreItemIndexChanged = true;
    itemView.currentIndex = -1;
    __ignoreItemIndexChanged = false;

    if (categoryView.selection.count > 0) {
      categoryView.selection.forEach(function(rowIndex) {
        // Only one selection is possible at any time, so this loop only runs once
        categorySelected(categoryView.model[rowIndex].categoryIdentifier,
                         levelFilterButton.checked,
                         vocationFilterButton.checked,
                         oneHandFilterButton.checked,
                         twoHandFilterButton.checked,
                         showLockerOnlyCheckBox.checked);
      });
    } else {
      filterSelected(nameFilterText.text,
                     levelFilterButton.checked,
                     vocationFilterButton.checked,
                     oneHandFilterButton.checked,
                     twoHandFilterButton.checked,
                     showLockerOnlyCheckBox.checked);
    }
  } //function triggerItemListUpdate()

  function setFocusToSearchTextField() {
    nameFilterText.forceActiveFocus();
  } //function setFocusToSearchTextField()

  TibiaText {
    Layout.leftMargin: root.sideMargin
    Layout.rightMargin: root.sideMargin
    text: qsTrId("market_categories")
    visible: !root.useObjectCount
  } // TibiaText

  TibiaTableView {
    id: categoryView
    headerVisible: false
    Layout.preferredHeight: root.categoryViewHeight
    Layout.fillWidth: true
    horizontalScrollBarPolicy: ScrollBar.AlwaysOff

    TableViewColumn { role: "text" }

    property bool __preventInitialSelection: false
    onModelChanged: {
      __preventInitialSelection = true;
    } //onModelChanged

    selection.onSelectionChanged: {
      if (__preventInitialSelection && selection.count > 0) {
        selection.clear();
        __preventInitialSelection = false;
      } else {
        selection.forEach(function(rowIndex) {
          nameFilterText.text = "";

          weaponCategorySelected = model[rowIndex].isHandWeaponCategory();
          triggerItemListUpdate();
        });
      }
    } //selection.onSelectionChanged
  } // TibiaTableView

  Item {
    Layout.leftMargin: root.sideMargin
    Layout.rightMargin: root.sideMargin
    Layout.fillWidth: true
    Layout.preferredHeight: npcSelectionBox.height + buttonLayout.height + comboBoxLayout.height + (root.buttonMargin * 2)


    TibiaComboBox {
      id: npcSelectionBox
      anchors { left: parent.left; right: parent.right }
      model: availableNPCs
      visible: npcFilterVisible
      shouldBeCurrentIndex: indexOfSelectedNPC
      focusPolicy: root.focusOnComboboxes ? Qt.StrongFocus : Qt.NoFocus

      onModelChanged: {
        //currentIndex = indexOfSelectedNPC;
      }

      onActivated: {
        npcFilterWasSelected(currentIndex,
                             nameFilterText.text,
                             levelFilterButton.checked,
                             vocationFilterButton.checked,
                             oneHandFilterButton.checked,
                             twoHandFilterButton.checked,
                             showLockerOnlyCheckBox.checked);
      } //onActivated
    } // TibiaComboBox


    RowLayout {
      id: buttonLayout
      anchors { left: parent.left; right: parent.right; top: npcSelectionBox.bottom; topMargin: root.buttonMargin;}
      spacing: root.buttonMargin

      TibiaButton {
        id: levelFilterButton
        text: qsTrId("level")
        tooltipText:qsTrId("market_level_filter_tooltip")
        checkable: true
        Layout.preferredWidth: Math.ceil(root.buttonWidth)
        onClicked: { root.triggerItemListUpdate();}
      } // TibiaButton

      TibiaButton {
        id: vocationFilterButton
        text: qsTrId("market_vocation_filter_button")
        tooltipText: qsTrId("market_vocation_filter_tooltip")
        checkable: true
        Layout.preferredWidth: Math.ceil(root.buttonWidth)
        onClicked: { root.triggerItemListUpdate(); }
      } // TibiaButton

      TibiaButton {
        id: oneHandFilterButton
        text: qsTrId("market_onehand_filter_button")
        tooltipText: qsTrId("market_onehand_filter_tooltip")
        checkable: true
        enabled: weaponCategorySelected
        Layout.preferredWidth: Math.floor(root.buttonWidth)
        onClicked: { twoHandFilterButton.checked = false; root.triggerItemListUpdate(); }
        onEnabledChanged: { if (!enabled) checked = false; }
      } // TibiaButton

      TibiaButton {
        id: twoHandFilterButton
        text: qsTrId("market_twohand_filter_button")
        tooltipText: qsTrId("market_twohand_filter_tooltip")
        checkable: true
        enabled: weaponCategorySelected
        Layout.preferredWidth: Math.floor(root.buttonWidth)
        onClicked: { oneHandFilterButton.checked = false; root.triggerItemListUpdate(); }
        onEnabledChanged: { if (!enabled) checked = false; }
      } // TibiaButton
    } // RowLayout

    RowLayout {
      id: comboBoxLayout
      anchors { left: parent.left; right: parent.right; top: buttonLayout.bottom; topMargin: root.buttonMargin;}
      spacing: root.buttonMargin


      TibiaComboBox {
        id: categorySelectionBox
        Layout.preferredWidth: 77
        model: availableClassifications
        enabled: enableTierAndClassificationSelection
        shouldBeCurrentIndex: indexOfSelectedClassification
        focusPolicy: root.focusOnComboboxes ? Qt.StrongFocus : Qt.NoFocus

        onModelChanged: {
          //currentIndex = indexOfSelectedClassification;
        }

        onActivated: {
          classificationFilterWasSelected(currentIndex,
                                          nameFilterText.text,
                                          levelFilterButton.checked,
                                          vocationFilterButton.checked,
                                          oneHandFilterButton.checked,
                                          twoHandFilterButton.checked,
                                          showLockerOnlyCheckBox.checked);
          root.triggerItemListUpdate();
        } //onActivated
      } // TibiaComboBox

      TibiaComboBox {
        id: tierSelectionBox
        Layout.preferredWidth: 79
        model: availableTiers
        enabled: enableTierAndClassificationSelection && enableTierSelection
        shouldBeCurrentIndex: indexOfSelectedTier
        visible: showTierFilter
        focusPolicy: root.focusOnComboboxes ? Qt.StrongFocus : Qt.NoFocus

        onModelChanged: {
          // currentIndex = indexOfSelectedTier;
        }

        onActivated: {
          tierFilterWasSelected(currentIndex,
                                nameFilterText.text,
                                levelFilterButton.checked,
                                vocationFilterButton.checked,
                                oneHandFilterButton.checked,
                                twoHandFilterButton.checked,
                                showLockerOnlyCheckBox.checked);
          root.triggerItemListUpdate();
        }
      } // TibiaComboBox


    } // RowLayout
  } //Item

  TibiaCheckBox {
    id: showLockerOnlyCheckBox
    Layout.leftMargin: root.sideMargin
    Layout.rightMargin: root.sideMargin
    Layout.topMargin: TibiaStyle.marginRelated
    Layout.fillWidth: true

    text: qsTrId("market_show_locker_only")

    visible: root.useObjectCount

    onCheckedChanged: { root.triggerItemListUpdate(); }
  } //TibiaCheckBox

  TibiaText {
    id: itemViewCaptionText
    Layout.topMargin: TibiaStyle.marginRelated - 2 // subtract 2 pixel to align the top of the list to the buy offers list
    Layout.leftMargin: root.sideMargin
    Layout.rightMargin: root.sideMargin
    text: qsTrId("market_object_types")
  } // TibiaText

  Rectangle {
    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.minimumHeight: TibiaStyle.widgetWithScrollBarMinContentHeight + 2*itemViewFrame.borderWidth
    color: TibiaStyle.tableViewBackgroundColor

    TibiaFrame1PixelDown {
      id: itemViewFrame
      anchors.fill: parent
    }  // TibiaFrame1PixelDown

    TibiaScrollView {
      anchors.fill: parent
      anchors.margins: itemViewFrame.borderWidth
      contentHeight: itemView.height
      contentWidth: itemView.width

      ListView {
        id: itemView
        clip: true

        boundsBehavior: Flickable.StopAtBounds
        interactive: false //prevent flick behavior on touch screens
        highlightMoveDuration: 0

        onCountChanged: {
          __ignoreItemIndexChanged = true;
          itemView.currentIndex = -1;
          __ignoreItemIndexChanged = false;
        } //onCountChanged

        onCurrentIndexChanged: {
          if (!__ignoreItemIndexChanged && itemView.currentItem != null) {
            itemSelected(itemView.currentItem.slotID, itemView.currentItem.objectAppearanceInstanceUpgradeTier);
          }
        } //onCurrentIndexChanged

        Keys.onUpPressed: (event) => {
          var oldIndex = itemView.currentIndex;
          itemView.decrementCurrentIndex();
          if (oldIndex === itemView.currentIndex) {
            event.accepted = false;
          }
        } //Keys.onUpPressed

        Keys.onDownPressed: (event) => {
          var oldIndex = itemView.currentIndex;
          itemView.incrementCurrentIndex();
          if (oldIndex === itemView.currentIndex) {
            event.accepted = false;
          }
        } //Keys.onDownPressed

        Keys.onEnterPressed: {
          nameFilterText.accepted();
        } //Keys.onEnterPressed

        Keys.onReturnPressed: {
          nameFilterText.accepted();
        } //Keys.onReturnPressed

        onCurrentItemChanged: {
          if (currentItem != null) {
            currentItem.updateSelectedItemView();
          }
        } //onCurrentItemChanged

        delegate: Rectangle {
          width: itemView.width
          height: 36
          color: ListView.isCurrentItem ? TibiaStyle.tableViewSelectionColor : "transparent"
          property bool zeroCountHighlight: root.useObjectCount && model.typeCount == 0
          property alias slotID: itemListIcon.slotID
          property alias objectAppearanceInstanceUpgradeTier: itemListIcon.objectAppearanceInstanceUpgradeTier

          function updateSelectedItemView() {
            selectedItemView.slotText = Qt.binding(function() { return itemListIcon.slotText; })
            selectedItemView.slotTooltip = Qt.binding(function() { return itemListIcon.slotTooltip; })
            selectedItemView.objectAppearanceInstanceTypeId = Qt.binding(function() { return itemListIcon.objectAppearanceInstanceTypeId; })
            selectedItemView.objectAppearanceInstanceCumulativeCount = Qt.binding(function() { return itemListIcon.objectAppearanceInstanceCumulativeCount; })
            selectedItemView.lootvalueImageSourceUnderItem = Qt.binding(function() { return itemListIcon.lootvalueImageSourceUnderItem; })
            selectedItemView.lootvalueImageSourceOverItem = Qt.binding(function() { return itemListIcon.lootvalueImageSourceOverItem; })
            selectedItemView.objectAppearanceInstanceUpgradeTier = Qt.binding(function() { return itemListIcon.objectAppearanceInstanceUpgradeTier; });
          } //updateSelectedItemView

          ContainerSlot {
            id: itemListIcon
            anchors { left: parent.left; leftMargin: 1; top: parent.top; topMargin: 1; }
            slotID: model.typeID
            slotText: root.useObjectCount ? model.countString : ""
            slotTooltip: model.countAndNameTooltip
            objectAppearanceInstanceTypeId: model.displayTypeID
            objectAppearanceInstanceCumulativeCount: 1 //model.cumulativeCount
            lootvalueImageSourceUnderItem: model.lootvalueImageSourceUnderItem
            lootvalueImageSourceOverItem: model.lootvalueImageSourceOverItem
            objectAppearanceInstanceUpgradeTier: model.upgradeTier

            showPointingHandCursor: false
            mouseAreaEnabled: false

            opacity: zeroCountHighlight ? 0.5 : 1
          } // ContainerSlot

          TibiaText {
            anchors { left: itemListIcon.right; leftMargin: 3; top: parent.top; bottom: parent.bottom; right: parent.right; rightMargin: 2; }
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WordWrap
            text: model.typeName
            color: model.highlightText ? TibiaStyle.orange1
                                       : (zeroCountHighlight
                                          ? TibiaStyle.textFieldDisabledTextColor
                                          : TibiaStyle.textFieldTextColor)
          } // TibiaText

          MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onClicked: (mouse) => {
              if (mouse.button == Qt.LeftButton ) {
                itemView.forceActiveFocus();
                itemView.currentIndex = index;
              }

              itemClicked(model.typeID, model.upgradeTier, mouse.button, mouse.modifiers);
            } //onClicked

            onDoubleClicked: {
              itemView.forceActiveFocus();
              itemView.currentIndex = index;
              itemChosen(model.displayTypeID, model.upgradeTier);
            } //onDoubleClicked
          } // MouseArea
        } // delegate: Rectangle
      } // ListView
    } // ScrollView

  } // Rectangle

  RowLayout {
    Layout.fillWidth: true
    Layout.leftMargin: root.sideMargin
    Layout.rightMargin: root.sideMargin
    spacing: TibiaStyle.marginRelated

   ContainerSlot {
      id: selectedItemView

      function resetView() {
        slotText = ""
        objectAppearanceInstanceTypeId = 0
        objectAppearanceInstanceCumulativeCount = 0
        lootvalueImageSourceUnderItem = ""
        lootvalueImageSourceOverItem = ""
        objectAppearanceInstanceUpgradeTier = 0
      } //function resetView()
    } // ContainerSlot

    ColumnLayout {
      spacing: TibiaStyle.marginRelated

      TibiaText {
        Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
        text: qsTrId("search") + ":"
        verticalAlignment: Text.AlignVCenter
        font: TibiaStyle.defaultTightFont
      } // TibiaText

      TibiaFrame1PixelDown {
        id: serachFieldFrame
        Layout.fillWidth: true
        Layout.preferredHeight: TibiaStyle.textFieldHeight

        RowLayout {
          anchors.fill: parent
          spacing: 0

          TibiaTextField {
            id: nameFilterText
            Layout.fillWidth: true
            Layout.fillHeight: true
            maximumLength: TibiaStyle.maxCharacterNameLength
            KeyNavigation.tab: nameFilterText
            KeyNavigation.backtab: nameFilterText

            placeholderText: qsTrId("type_to_search_placeholder")

            onTextChanged: {
              if (text.length > 0) {
                weaponCategorySelected = true;
                categoryView.selection.clear()
              } else {
                weaponCategorySelected = false;
              }

              triggerItemListUpdate();
            } //onTextChanged

            onFocusChanged: {
              if (focus) {
                root.focusEnteredTextInput();
              }
            } //onFocusChanged

            onAccepted: {
              if (root.hasSelectedItem) {
                root.acceptedTextInput();
              }
            } //onAccepted

            Keys.onEscapePressed: {
              root.escPressedInSearchTextField();
            } //Keys.onEscapePressed

            Keys.onUpPressed: (event) => {
              var oldIndex = itemView.currentIndex;
              itemView.decrementCurrentIndex();
              if (oldIndex === itemView.currentIndex) {
                event.accepted = false;
              }
            } //Keys.onUpPressed

            Keys.onDownPressed: (event) => {
              var oldIndex = itemView.currentIndex;
              itemView.incrementCurrentIndex();
              if (oldIndex === itemView.currentIndex) {
                event.accepted = false;
              }
            } //Keys.onDownPressed
          } // TibiaTextField

          TibiaButton {
            Layout.topMargin: serachFieldFrame.borderWidth
            Layout.bottomMargin: serachFieldFrame.borderWidth
            Layout.rightMargin: serachFieldFrame.borderWidth
            Layout.leftMargin: -serachFieldFrame.borderWidth
            Layout.fillHeight: true
            Layout.preferredWidth: height
            imageSource: "/images/icon-erase-small.png"
            tooltipText: qsTrId("clear_search_tooltip")

            onClicked: {
              nameFilterText.text = '';
            } //onClicked
          } //TibiaButton
        } //RowLayout
      } //TibiaFrame1PixelDown
    } // ColumnLayout
  } // RowLayout
} //ColumnLayout
