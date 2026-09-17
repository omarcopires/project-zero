import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qmlcomponents
import qmlenumvalues
import QtQuick.LegacyControls

import "qrc:/qt/qml/qmlcomponents/qml"


Item {
  id: preyView

  implicitHeight: rootLayout.height + rootFrame.borderWidth + TibiaStyle.marginRelated + rootFrame.captionHeight + TibiaStyle.marginRelated
  implicitWidth: TibiaStyle.preyMonsterViewSize + TibiaStyle.preyBonusViewWidth + 2 * TibiaStyle.marginRelated + 2*4 //(boarder margin)
  clip: true

  property bool clientSettingSmoothFiltering: false
  property bool allowHoverMouse: false

  //Data properties
  property var preyViewModel: null
  property bool isLocked: preyViewModel != null && preyViewModel.isLocked
  property bool isInactive: preyViewModel != null && preyViewModel.isInactive
  property bool isActive: preyViewModel != null && preyViewModel.isActive
  property bool isSelecting: preyViewModel != null && preyViewModel.isSelecting
  property bool isGridSelecting: preyViewModel != null && preyViewModel.isGridSelecting
  property bool isBestiarySelecting: preyViewModel != null && preyViewModel.isBestiarySelecting
  property bool freeListRerollAvailable: preyViewModel != null && preyViewModel.hasFreeListReroll

  property string listRerollPrice: ""
  property bool listRerollTooExpensive: false
  property string bonusRerollPrice: ""
  property bool bonusRerollTooExpensive: false
  property string choosePreyPrice: ""
  property bool choosePreyTooExpensive: false

  property bool listRerollButtonEnabled: preyView.freeListRerollAvailable || !preyView.listRerollTooExpensive
  property bool choosePreyButtonEnabled: !preyView.choosePreyTooExpensive

  property string monsterName: preyViewModel != null ? preyViewModel.monsterName : ""
  property string bonusValueText: preyViewModel != null ? preyViewModel.bonusValueText : ""
  property int bonusGrade: preyViewModel != null ? preyViewModel.bonusGrade : 0
  property int maximumBonusGrade: preyViewModel != null ? preyViewModel.maximumBonusGrade : 0
  property string bonusGradeText: preyViewModel != null ? preyViewModel.bonusGradeText : ""
  property string bonusTypeText: preyViewModel != null ? preyViewModel.bonusTypeText : ""
  property string preyDescription: preyViewModel != null ? preyViewModel.preyDescription : ""
  property string timeLeft: preyViewModel != null ? preyViewModel.timeLeft : ""
  property string timeToFreeListReroll: preyViewModel != null ? preyViewModel.timeToFreeListReroll : ""

  property string selectedPreymonsterName: ""

  function onRerollPreyBonusClicked() {
    if (preyViewModel != null) {
      preyViewModel.rerollPreyBonusClicked();
    }
  } //function onRerollPreyBonusClicked()

  function onListRerollClicked() {
    if (preyViewModel != null) {
      preyViewModel.listRerollClicked();
    }
  } //function onListRerollClicked()

  function onChoosePreyClicked() {
    if (preyViewModel != null) {
      preyViewModel.choosePreyClicked();
    }
  } //function onChoosePreyClicked()

  function onConfirmGridPreyCreatureClicked() {
    if (preyViewModel != null && preyView.isGridSelecting && preyMonsterGridSelection.currentIndex > -1) {
      preyViewModel.confirmGridPreyCreatureClicked(preyMonsterGridSelection.currentIndex);
    }
  } //function onConfirmGridPreyCreatureClicked()

  function onConfirmBestiaryPreyCreatureClicked() {
    if (preyViewModel != null && preyView.isBestiarySelecting && bestiaryMonsterList.selectedMonsterRaceID != 0) {
      preyViewModel.confirmBestiaryPreyCreatureClicked(bestiaryMonsterList.selectedMonsterRaceID);
    }
  } //function onConfirmBestiaryPreyCreatureClicked()

  function onUnlockClicked() {
    if (preyViewModel != null) {
      preyViewModel.unlockClicked();
    }
  } //function onUnlockClicked()

  function onUnlockPermanentlyClicked() {
    if (preyViewModel != null) {
      preyViewModel.unlockPermanentlyClicked();
    }
  } //function onUnlockPermanentlyClicked()

  function onUnlockWithPermiumClicked() {
    if (preyViewModel != null) {
      preyViewModel.unlockWithPermiumClicked();
    }
  } //function onUnlockWithPermiumClicked()

  function getCaptionText() {
    var Text = qsTrId("prey_locked")

    if (preyView.isInactive && !preyView.isSelecting) {
      Text = qsTrId("prey_inactive")
    } else if (preyView.isActive) {
      Text = preyView.monsterName
    } else if (preyView.isGridSelecting) {
      if(preyMonsterGridSelection.currentIndex == -1) {
        Text = qsTrId("prey_select_your_prey")
      } else {
        Text = qsTrId("prey_selected") + " " + preyView.selectedPreymonsterName
      }
    } else if (preyView.isBestiarySelecting) {
      if(bestiaryMonsterList.selectedMonsterRaceID == 0) {
        Text = qsTrId("prey_select_your_prey")
      } else {
        Text = qsTrId("prey_selected") + " " + preyView.selectedPreymonsterName
      }
    }
    //else "Locked"

    return Text;
  }

  TibiaFrame2PixelUpFilledWithCaption {
    id: rootFrame
    anchors.fill: parent
    caption: getCaptionText()
    captionHorizontalAlignment: preyMonsterGridSelection.currentIndex == -1 ? Text.AlignHCenter
                                                                            : Text.AlignLeft

    ColumnLayout {
      id: rootLayout
      anchors { left: parent.left; right: parent.right; top: parent.top }
      anchors.margins: parent.borderWidth + TibiaStyle.marginRelated
      anchors.topMargin: parent.captionHeight + TibiaStyle.marginRelated
      spacing: TibiaStyle.marginRelated

      Item { //current prey view
        id: currentPreyView
        Layout.preferredHeight: currentPreyViewLayout.height
        Layout.fillWidth:true
        enabled: !preyView.isSelecting
        visible: enabled


        ColumnLayout {
          id: currentPreyViewLayout
          anchors { left: parent.left; right: parent.right; top: parent.top }
          spacing: TibiaStyle.marginNarrow

          RowLayout {
            Layout.fillWidth: true
            spacing: TibiaStyle.marginRelated

            TibiaFrame1PixelDown {
              id: preyMonster
              Layout.preferredHeight: preyView.TibiaStyle.preyMonsterViewSize
              Layout.preferredWidth: preyView.TibiaStyle.preyMonsterViewSize

              OutfitAppearanceInstanceRenderer {
                id: preyMonsterDisplay
                visible: preyView.isActive
                anchors.centerIn: parent
                height: TibiaStyle.preyMonsterImageSize
                width: height
                scaleFactor: TibiaStyle.preyMonsterScaleFactor
                smoothTextureFiltering: preyView.clientSettingSmoothFiltering
                showNoOutfitImage: false

                outfitId: preyViewModel != null ? preyViewModel.monsterOutfitId : 0
                headColor: preyViewModel != null ? preyViewModel.monsterHeadColor : "black"
                torsoColor: preyViewModel != null ? preyViewModel.monsterTorsoColor : "black"
                legsColor: preyViewModel != null ? preyViewModel.monsterLegsColor : "black"
                detailColor: preyViewModel != null ? preyViewModel.monsterDetailColor : "black"
                firstAddOn: preyViewModel != null ? preyViewModel.monsterFirstAddOn : false
                secondAddOn: preyViewModel != null ? preyViewModel.monsterSecondAddOn : false
              } //OutfitAppearanceInstanceRendere

              Image {
                smooth: false
                visible: !preyMonsterDisplay.visible
                anchors.centerIn: parent
                source: "/images/prey-noprey.png"
              } //image
            } //TibiaFrame1PixelDown

            TibiaFrame1PixelDown {
              id: preyBounus
              Layout.preferredHeight: preyView.TibiaStyle.preyMonsterViewSize
              Layout.preferredWidth: preyView.TibiaStyle.preyBonusViewWidth

              ColumnLayout {
                anchors {left: parent.left; top: parent.top; right: parent.right }
                anchors.topMargin: TibiaStyle.marginRelated + preyBounus.borderWidth
                spacing: TibiaStyle.marginRelated - 1 // Slightly better distribution within the available space

                Item {
                  Layout.fillWidth: true
                  Layout.preferredHeight: bonusIcon.height

                  Image {
                    id: bonusIcon
                    smooth: false
                    anchors.centerIn: parent
                    source: preyViewModel != null ? preyViewModel.bonusIcon : "/images/prey-bonus-none.png"
                  } // Image
                } //Item

                RowLayout {
                  Item { Layout.preferredWidth: TibiaStyle.marginRelated }
                  TibiaHorizontalSeparator {
                    id: separator
                    Layout.fillWidth: true
                  } //TibiaHorizontalSeparator
                  Item { Layout.preferredWidth: TibiaStyle.marginRelated }
                } //RowLayout

                GridLayout {
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignHCenter
                  columns: maximumBonusGrade / 2
                  rowSpacing: TibiaStyle.marginNarrow
                  columnSpacing: TibiaStyle.marginNarrow

                  Repeater {
                    model: maximumBonusGrade
                    Image {
                      smooth: false
                      source: index < bonusGrade ? "/images/icon-star-active.png" : "/images/icon-star-inactive.png"
                    } // Image
                  } // Repeater
                } // GridLayout
              } //ColumnLayout
            } //TibiaFrame1PixelDown
          } //RowLayout

          TibiaProgressBar {
            id: timeLeftProgressBar
            Layout.preferredHeight: TibiaStyle.progressBarLargeHeight
            Layout.fillWidth: true
            fillPercentage: preyViewModel != null ? preyViewModel.timeLeftProgress : 0.0

            frameSource: "/images/1pixel-down-frame.png"
            backgroundSource: "/images/backdrop-dark-grey.png"
            fillSource: "/images/progressbar-orange-large.png"

            frameBorder { left: 1; right: 1; top:1; bottom: 1}
            fillOffset { left: 1; right: 1; top:1; bottom: 1}

            TibiaText {
              anchors.centerIn: parent
              text: preyView.timeLeft
            } //TibiaText
          } //TibiaProgressBar
        } //ColumnLayout

        MouseArea {
          id: currentPreyViewHoverArea
          anchors.fill: parent
          z: -1
          hoverEnabled: preyView.allowHoverMouse
        } //MouseArea
      } //Item current prey view

      Item { //grid selection view
        Layout.preferredHeight: currentPreyView.Layout.preferredHeight
                              + rootLayout.spacing
                              + rerollPreyView.Layout.preferredHeight
        Layout.fillWidth:true
        enabled: preyView.isGridSelecting
        visible: enabled

        ColumnLayout {
          id: listSelectionViewLayout
          anchors.fill: parent

          spacing: TibiaStyle.marginRelated

          TibiaFrame1PixelDown {
            Layout.preferredWidth: TibiaStyle.preyGridSelectionWidth
            Layout.preferredHeight: TibiaStyle.preyGridSelectionWidth

            GridView {
              id: preyMonsterGridSelection

              property QtObject currentHoverTooltip
              property bool delegateHovered: false

              anchors.fill: parent

              cellWidth: 64 + 2 * TibiaStyle.marginNarrow
              cellHeight: cellWidth
              boundsBehavior: Flickable.StopAtBounds
              rebound: Transition {}
              pixelAligned: true

              model: preyViewModel != null ? preyViewModel.listRerollData : null

              onModelChanged: { preyMonsterGridSelection.currentIndex = -1 }

              delegate: Rectangle {
                width: preyMonsterGridSelection.cellWidth
                height: preyMonsterGridSelection.cellHeight

                color: preyMonsterGridSelection.currentIndex == index ? TibiaStyle.comboBoxSelectionColor
                                                                      :  "transparent"
                border.width: preyMonsterGridSelection.currentIndex == index ? 1 : 0
                border.color: "white"

                OutfitAppearanceInstanceRenderer {
                  anchors.centerIn: parent
                  height: TibiaStyle.preySelectionImageSize
                  width: height
                  scaleFactor: TibiaStyle.preySelectionScaleFactor
                  smoothTextureFiltering: preyView.clientSettingSmoothFiltering
                  showNoOutfitImage: false

                  outfitId: modelData != null ? modelData.monsterOutfitId : 0
                  headColor: modelData != null ? modelData.monsterHeadColor : "black"
                  torsoColor: modelData != null ? modelData.monsterTorsoColor : "black"
                  legsColor: modelData != null ? modelData.monsterLegsColor : "black"
                  detailColor: modelData != null ? modelData.monsterDetailColor : "black"
                  firstAddOn: modelData != null ? modelData.monsterFirstAddOn : false
                  secondAddOn: modelData != null ? modelData.monsterSecondAddOn : false
                } //OutfitAppearanceInstanceRendere

                MouseArea {
                  anchors.fill: parent
                  z: -1

                  onClicked: {
                    preyMonsterGridSelection.currentIndex = index;
                    preyView.selectedPreymonsterName = modelData.monsterName
                  } //onClicked
                } //MouseArea

                Tooltip {
                  anchors.fill: parent
                  text: modelData.monsterName
                  delayInMs: 0
                  onHoverEnter: {
                    preyMonsterGridSelection.currentHoverTooltip = this;
                    preyMonsterGridSelection.delegateHovered = true;
                  }
                  onHoverLeave: {
                    // Make sure that hoverEnter of another tooltip that triggers before this
                    // tooltip's hoverLeave does not clear the hover variable
                    if (preyMonsterGridSelection.currentHoverTooltip === this) {
                      preyMonsterGridSelection.delegateHovered = false;
                    }
                  }
                } //Tooltip
              } //delegate: Rectangle
            } //GridView


            MouseArea {
              id: preyMonsterGridSelectionHoverArea
              anchors.fill: parent
              z: -1
              hoverEnabled: preyView.allowHoverMouse
            } //MouseArea
          } //TibiaFrame1PixelDown

          RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: TibiaStyle.marginRelated

            RowLayout {
              Layout.fillHeight: true
              Layout.preferredWidth: preyView.TibiaStyle.preyMonsterViewSize
              spacing: TibiaStyle.marginNarrow

              ColumnLayout { //list reroll
                spacing: TibiaStyle.marginNarrow
                Layout.fillWidth: true

                Item {
                  Layout.fillHeight: true
                  Layout.fillWidth: true

                  TibiaButton {
                    id: listRerollButtonSelection
                    anchors.fill: parent

                    imageYOffset: -9
                    imageSource: preyView.isInactive ? "/images/prey-list-reroll-reactivate.png"
                                                     : "/images/prey-list-reroll.png"
                    imageSourceDisabled: preyView.isInactive ? "/images/prey-list-reroll-reactivate-disabled.png"
                                                             : "/images/prey-list-reroll-disabled.png"

                    enabled: preyView.listRerollButtonEnabled

                    onClicked: preyView.onListRerollClicked()
                  } //TibiaButton

                  MouseArea {
                    id: listRerollButtonSelectionHoverArea
                    anchors.fill: listRerollButtonSelection
                    z: -1
                    hoverEnabled: preyView.allowHoverMouse
                    visible: !listRerollButtonSelection.enabled
                  } //MouseArea

                  TibiaProgressBar {
                    anchors { left: parent.left; bottom: parent.bottom; right: parent.right }
                    anchors.leftMargin: listRerollButtonSelection.pressed ? 3 : 2
                    anchors.bottomMargin: listRerollButtonSelection.pressed ? 1 : 2
                    anchors.rightMargin: listRerollButtonSelection.pressed ? 1 : 2
                    height: TibiaStyle.progressBarSmallHeight
                    fillPercentage: preyViewModel != null ? preyViewModel.timeToFreeListRerollProgress : 0.0

                    frameSource: "/images/1pixel-down-frame.png"
                    backgroundSource: "/images/backdrop-dark-grey.png"
                    fillSource: "/images/progressbar-orange-small.png"

                    frameBorder { left: 1; right: 1; top:1; bottom: 1}
                    fillOffset { left: 1; right: 1; top:1; bottom: 1}

                    TibiaText {
                      anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
                      horizontalAlignment: Text.AlignHCenter
                      text: preyView.timeToFreeListReroll
                    } //TibiaText

                    MouseArea {
                      id: freeListRerollProgressSelectionHoverArea
                      anchors.fill: parent
                      hoverEnabled: preyView.allowHoverMouse

                      propagateComposedEvents: true
                      onClicked: (mouse) => { mouse.accepted = false; }
                      onPressed: (mouse) => { mouse.accepted = false; }
                      onReleased: (mouse) => { mouse.accepted = false; }
                    } //MouseArea
                  } //TibiaProgressBar
                } //Item

                TibiaCurrencyView {
                  Layout.fillWidth: true
                  price: preyView.listRerollPrice
                  discountPrice: preyView.freeListRerollAvailable ? "0" : ""
                  iconId: "GoldCoin"
                  tooLowBalance: !preyView.listRerollButtonEnabled
                } //TibiaCurrencyView
              } //ColumnLayout

              ColumnLayout { //choose prey
                spacing: TibiaStyle.marginNarrow
                Layout.fillWidth: true

                Item {
                  Layout.fillHeight: true
                  Layout.fillWidth: true

                  TibiaButton {
                    id: choosePreyButtonSelection
                    anchors.fill: parent

                    imageSource: preyView.isInactive ? "/images/prey-choose-prey-reactivate.png"
                                                     : "/images/prey-choose-prey.png"
                    imageSourceDisabled: preyView.isInactive ? "/images/prey-choose-prey-reactivate-disabled.png"
                                                             : "/images/prey-choose-prey-disabled.png"

                    enabled: preyView.choosePreyButtonEnabled

                    onClicked: preyView.onChoosePreyClicked()
                  } //TibiaButton

                  MouseArea {
                    id: choosePreyButtonSelectionHoverArea
                    anchors.fill: choosePreyButtonSelection
                    z: -1
                    hoverEnabled: preyView.allowHoverMouse
                    visible: !choosePreyButtonSelection.enabled
                  } //MouseArea
                } //Item

                TibiaCurrencyView {
                  Layout.fillWidth: true
                  price: preyView.choosePreyPrice
                  iconId: "PreyWildcards"
                  tooLowBalance: preyView.choosePreyTooExpensive
                } //TibiaCurrencyView
              } //ColumnLayout
            } //RowLayout

            Item {
              Layout.preferredWidth: preyView.TibiaStyle.preyBonusViewWidth
              Layout.fillHeight: true

              TibiaButton {
                id: confirmSelection
                anchors.fill: parent
                imageSource: "/images/prey-confirm-monster-selection.png"
                imageSourceDisabled: "/images/prey-confirm-monster-selection-disabled.png"
                enabled: preyMonsterGridSelection.currentIndex != -1

                onClicked: preyView.onConfirmGridPreyCreatureClicked()
              } //TibiaButton

              MouseArea {
                id: confirmSelectionHoverArea
                anchors.fill: confirmSelection
                hoverEnabled: preyView.allowHoverMouse
                visible: !confirmSelection.enabled
              } //MouseArea
            } //Item
          } //RowLayout
        } //ColumnLayout
      } //Item grid selection view

      Item { //bestiary selection view
        id: bestiarySelectionView
        Layout.preferredHeight: currentPreyView.Layout.preferredHeight
                              + rootLayout.spacing
                              + rerollPreyView.Layout.preferredHeight
        Layout.fillWidth:true
        enabled: preyView.isBestiarySelecting
        visible: enabled

        property bool hovered: {
          return    (bestidarySelectionHoverArea.enabled && bestidarySelectionHoverArea.containsMouse)
                 || (bestiaryMonsterListHoverArea.enabled && bestiaryMonsterListHoverArea.containsMouse)
                 || (bestiaryListNameFilter.enabled && bestiaryListNameFilter.hovered);
        } //property bool hovered

        ColumnLayout {
          id: bestiarySelectionViewLayout
          anchors.fill: parent
          spacing: TibiaStyle.marginRelated

          ColumnLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: TibiaStyle.preyGridSelectionWidth
            spacing: TibiaStyle.marginRelated
            TibiaTableView {
              id: bestiaryMonsterList
              property var _helperModel: null

              Layout.fillHeight: true
              Layout.fillWidth: true
              property int selectedMonsterRaceID: 0

              KeyNavigation.tab: bestiaryListNameFilter
              KeyNavigation.backtab : bestiaryListNameFilter

              headerVisible: false
              horizontalScrollBarPolicy: ScrollBar.AlwaysOff
              model: preyViewModel != null ? preyViewModel.bestiarySelectionModel : null

              TableViewColumn {
                role: "name"
                movable: false

                delegate: RowLayout {
                  anchors.fill: parent
                  anchors.leftMargin: TibiaStyle.marginNarrow
                  anchors.rightMargin: TibiaStyle.marginNarrow
                  spacing: TibiaStyle.marginNarrow
                  TibiaText {
                    Layout.fillWidth: true
                    text: styleData.value
                    color: styleData.selected
                        ? TibiaStyle.textFieldSelectionTextColor
                        : TibiaStyle.textFieldTextColor
                    elide: styleData.elideMode
                    horizontalAlignment: styleData.textAlignment
                  } // TibiaText
                }
              } // TableViewColumn

              property bool __preventInitialSelection: false
              onModelChanged: {
                __preventInitialSelection = true;
                if (model != null) {
                  _helperModel = AbstractItemModelHelper.wrapInHelperProxyModel(model);
                } else {
                  _helperModel = null;
                }
              } //onModelChanged

              selection.onSelectionChanged: {
                if (__preventInitialSelection && selection.count > 0 && bestiaryListNameFilter.text.length == 0) {
                  selection.clear();
                  __preventInitialSelection = false;
                } else if (selection.count == 0) {
                  selectedMonsterRaceID = 0;
                  preyView.selectedPreymonsterName = "";
                } else {
                  selection.forEach(function(rowIndex) {
                    if (_helperModel) {
                      var modelData = _helperModel.sourceItemDataByRowIndex(rowIndex);
                      if (modelData) {
                        selectedMonsterRaceID = modelData.id;
                        preyView.selectedPreymonsterName = modelData.name;
                      } else {
                        selectedMonsterRaceID = 0;
                        preyView.selectedPreymonsterName = "";
                      }
                    } else {
                      selectedMonsterRaceID = 0;
                      preyView.selectedPreymonsterName = "";
                    }
                  });
                }
              } //selection.onSelectionChanged

              MouseArea {
                id: bestiaryMonsterListHoverArea
                anchors.fill: parent
                hoverEnabled: preyView.allowHoverMouse
                visible: parent.enabled

                propagateComposedEvents: true
                onClicked: (mouse) => { mouse.accepted = false; }
                onPressed: (mouse) => { mouse.accepted = false; }
                onReleased: (mouse) => { mouse.accepted = false; }
              } //MouseArea
            } //TibiaTableView

            TibiaTextField {
              id: bestiaryListNameFilter
              Layout.fillWidth: true
              Layout.preferredHeight: TibiaStyle.textFieldHeight + TibiaStyle.marginRelated
              KeyNavigation.tab: bestiaryMonsterList
              KeyNavigation.backtab : bestiaryMonsterList
              placeholderText: qsTrId("type_to_search_placeholder")
              maximumLength: TibiaStyle.maxCharacterNameLength
              onTextChanged: {
                if (preyViewModel != null) {
                  preyViewModel.setMonsterRacesFilter(text);
                }
              } //onTextChanged
            } // TibiaTextField
          } // ColumnLayout

          RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: TibiaStyle.preyBonusViewWidth
                                  + TibiaStyle.marginNarrow
                                  + TibiaStyle.currencyViewHeight
                                  + TibiaStyle.marginRelated
            spacing: TibiaStyle.marginRelated

            TibiaFrame1PixelDown {
              Layout.fillHeight: true
              Layout.preferredWidth: preyView.TibiaStyle.preyMonsterViewSize

              RaceAppearanceInstanceRenderer {
                anchors.centerIn: parent
                height: TibiaStyle.preyMonsterImageSize
                width: height

                raceID: bestiaryMonsterList.selectedMonsterRaceID
                smoothTextureFiltering: preyView.clientSettingSmoothFiltering
                moving: false
                autofit: false
              } //RaceAppearanceInstanceRenderer
            } //TibiaFrame1PixelDown

            Item {
              Layout.fillHeight: true
              Layout.alignment: Qt.AlignBottom
              Layout.preferredWidth: preyView.TibiaStyle.preyBonusViewWidth
              //Layout.preferredHeight: confirmSelection.height // does not work ... the calculation works for now

              TibiaButton {
                id: confirmBestiarySelection
                anchors.fill: parent
                imageSource: "/images/prey-confirm-monster-selection.png"
                imageSourceDisabled: "/images/prey-confirm-monster-selection-disabled.png"
                enabled: bestiaryMonsterList.selectedMonsterRaceID != 0

                onClicked: preyView.onConfirmBestiaryPreyCreatureClicked()
              } //TibiaButton

              MouseArea {
                id: confirmBestiarySelectionHoverArea
                anchors.fill: confirmBestiarySelection
                hoverEnabled: preyView.allowHoverMouse
                visible: !confirmBestiarySelection.enabled
              } //MouseArea
            } //Item
          } //RowLayout
        } //ColumnLayout

        MouseArea {
          id: bestidarySelectionHoverArea
          anchors.fill: parent
          hoverEnabled: preyView.allowHoverMouse
          visible: parent.enabled
          z: -1
        } //MouseArea
      } //Item bestiary selection view

      Item { //reroll prey view
        id: rerollPreyView
        Layout.preferredHeight: rerollPreyViewLayout.height
        Layout.fillWidth: true
        enabled: !preyView.isSelecting && !preyView.isLocked
        visible: enabled

        ColumnLayout {
          id: rerollPreyViewLayout
          anchors { left: parent.left; right: parent.right; top: parent.top }

          RowLayout {
            Layout.fillWidth: true
            spacing: TibiaStyle.marginRelated

            RowLayout {
              Layout.preferredWidth: preyView.TibiaStyle.preyMonsterViewSize
              spacing: TibiaStyle.marginNarrow

              ColumnLayout { //list reroll
                spacing: TibiaStyle.marginNarrow
                Layout.fillWidth: true

                Item {
                  Layout.preferredHeight: preyView.TibiaStyle.preyBonusViewWidth
                  Layout.fillWidth: true

                  TibiaButton {
                    id: listRerollButton
                    anchors.fill: parent

                    imageYOffset: -9
                    imageSource: preyView.isInactive ? "/images/prey-list-reroll-reactivate.png"
                                                     : "/images/prey-list-reroll.png"
                    imageSourceDisabled: preyView.isInactive ? "/images/prey-list-reroll-reactivate-disabled.png"
                                                             : "/images/prey-list-reroll-disabled.png"

                    enabled: preyView.listRerollButtonEnabled

                    onClicked: preyView.onListRerollClicked()
                  } //TibiaButton

                  MouseArea {
                    id: listRerollButtonHoverArea
                    anchors.fill: listRerollButton
                    hoverEnabled: preyView.allowHoverMouse
                    visible: !listRerollButton.enabled
                  } //MouseArea

                  TibiaProgressBar {
                    anchors { left: parent.left; bottom: parent.bottom; right: parent.right }
                    anchors.leftMargin: listRerollButton.pressed ? 3 : 2
                    anchors.bottomMargin: listRerollButton.pressed ? 1 : 2
                    anchors.rightMargin: listRerollButton.pressed ? 1 : 2
                    height: TibiaStyle.progressBarSmallHeight
                    fillPercentage: preyViewModel != null ? preyViewModel.timeToFreeListRerollProgress : 0.0

                    frameSource: "/images/1pixel-down-frame.png"
                    backgroundSource: "/images/backdrop-dark-grey.png"
                    fillSource: "/images/progressbar-orange-small.png"

                    frameBorder { left: 1; right: 1; top:1; bottom: 1}
                    fillOffset { left: 1; right: 1; top:1; bottom: 1}

                    TibiaText {
                      anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
                      horizontalAlignment: Text.AlignHCenter
                      text: preyView.timeToFreeListReroll
                    } //TibiaText

                    MouseArea {
                      id: freeListRerollProgressHoverArea
                      anchors.fill: parent
                      hoverEnabled: preyView.allowHoverMouse

                      propagateComposedEvents: true
                      onClicked: (mouse) => { mouse.accepted = false; }
                      onPressed: (mouse) => { mouse.accepted = false; }
                      onReleased: (mouse) => { mouse.accepted = false; }
                    } //MouseArea
                  } //TibiaProgressBar
                } //Item

                TibiaCurrencyView {
                  Layout.fillWidth: true
                  price: preyView.listRerollPrice
                  discountPrice: preyView.freeListRerollAvailable ? "0" : ""
                  iconId: "GoldCoin"
                  tooLowBalance: !preyView.listRerollButtonEnabled
                } //TibiaCurrencyView
              } //ColumnLayout

              ColumnLayout { //choose prey
                spacing: TibiaStyle.marginNarrow
                Layout.fillWidth: true

                Item {
                  Layout.fillHeight: true
                  Layout.fillWidth: true

                  TibiaButton {
                    id: choosePreyButton
                    anchors.fill: parent

                    imageSource: preyView.isInactive ? "/images/prey-choose-prey-reactivate.png"
                                                     : "/images/prey-choose-prey.png"
                    imageSourceDisabled: preyView.isInactive ? "/images/prey-choose-prey-reactivate-disabled.png"
                                                             : "/images/prey-choose-prey-disabled.png"

                    enabled: preyView.choosePreyButtonEnabled

                    onClicked: preyView.onChoosePreyClicked()
                  } //TibiaButton

                  MouseArea {
                    id: choosePreyButtonHoverArea
                    anchors.fill: choosePreyButton
                    z: -1
                    hoverEnabled: preyView.allowHoverMouse
                    visible: !choosePreyButton.enabled
                  } //MouseArea
                } //Item

                TibiaCurrencyView {
                  Layout.fillWidth: true
                  price: preyView.choosePreyPrice
                  iconId: "PreyWildcards"
                  tooLowBalance: preyView.choosePreyTooExpensive
                } //TibiaCurrencyView
              } //ColumnLayout
            } //RowLayout

            ColumnLayout {
              spacing: TibiaStyle.marginNarrow
              Layout.preferredWidth: preyView.TibiaStyle.preyBonusViewWidth

              Item {
                Layout.preferredHeight: preyView.TibiaStyle.preyBonusViewWidth
                Layout.preferredWidth: preyView.TibiaStyle.preyBonusViewWidth

                TibiaButton {
                  id: bonusRerollButton
                  anchors.fill: parent
                  imageSource: "/images/prey-bonus-reroll.png"
                  imageSourceDisabled: "/images/prey-bonus-reroll-disabled.png"
                  enabled: preyView.isActive && !preyView.bonusRerollTooExpensive

                  onClicked: preyView.onRerollPreyBonusClicked()
                } //TibiaButton

                MouseArea {
                  id: bonusRerollButtonHoverArea
                  anchors.fill: parent
                  hoverEnabled: preyView.allowHoverMouse
                  visible: !bonusRerollButton.enabled
                } //MouseArea
              } //Item

              TibiaCurrencyView {
                Layout.fillWidth: true
                price: preyView.bonusRerollPrice
                iconId: "PreyWildcards"
                tooLowBalance: preyView.bonusRerollTooExpensive
              } //TibiaCurrencyView
            } //ColumnLayout
          } //RowLayout

          ColumnLayout {
            spacing: TibiaStyle.marginNarrow

            RowLayout {
              spacing: TibiaStyle.marginNarrow

              TibiaMenuOptionCheckBox {
                Layout.fillWidth: true
                text: qsTrId("prey_auto_reroll")

                shouldBeChecked: preyViewModel != null && (preyViewModel.automaticPreyExtendType == TibiaEnums.BONUS_REROLL)
                onCheckedChanged: {
                  if (preyViewModel != null) {
                    //this is needed to allow canceling the change
                    //if the checkbox should change its checked value it is always confirmed by the server
                    var newChecked = checked;
                    checked = shouldBeChecked;

                    if(newChecked != shouldBeChecked) {
                      if(newChecked) {
                        preyViewModel.autoExtendPreydClicked(TibiaEnums.BONUS_REROLL);
                      } else {
                        preyViewModel.autoExtendPreydClicked(TibiaEnums.NOT_EXTENDING);
                      }
                    }
                  }
                } //onCheckedChanged

                MouseArea {
                  id: autoRerollCheckBoxHoverArea
                  anchors.fill: parent
                  hoverEnabled: preyView.allowHoverMouse

                  propagateComposedEvents: true
                  onClicked: (mouse) => { mouse.accepted = false; }
                  onPressed: (mouse) => { mouse.accepted = false; }
                  onReleased: (mouse) => { mouse.accepted = false; }
                } //MouseArea
              } //TibiaMenuOptionCheckBox

              TibiaCurrencyView {
                Layout.preferredWidth: TibiaStyle.preyShortCurrencyWidth
                Layout.fillHeight: true
                price: preyView.bonusRerollPrice
                iconId: "PreyWildcards"
                tooLowBalance: preyView.bonusRerollTooExpensive
              } //TibiaCurrencyView
            } //RowLayout

            RowLayout {
              spacing: TibiaStyle.marginNarrow

              TibiaMenuOptionCheckBox {
                Layout.fillWidth: true
                text: qsTrId("prey_lock_prey")

                shouldBeChecked: preyViewModel != null && (preyViewModel.automaticPreyExtendType == TibiaEnums.LOCK_PREY)
                onCheckedChanged: {
                  if (preyViewModel != null) {
                    //this is needed to allow canceling the change
                    //if the checkbox should change its checked value it is always confirmed by the server
                    var newChecked = checked;
                    checked = shouldBeChecked;

                    if(newChecked != shouldBeChecked) {
                      if(newChecked) {
                        preyViewModel.autoExtendPreydClicked(TibiaEnums.LOCK_PREY);
                      } else {
                        preyViewModel.autoExtendPreydClicked(TibiaEnums.NOT_EXTENDING);
                      }
                    }
                  }
                } //onCheckedChanged

                MouseArea {
                  id: preyLockCheckBoxHoverArea
                  anchors.fill: parent
                  hoverEnabled: preyView.allowHoverMouse

                  propagateComposedEvents: true
                  onClicked: (mouse) => { mouse.accepted = false; }
                  onPressed: (mouse) => { mouse.accepted = false; }
                  onReleased: (mouse) => { mouse.accepted = false; }
                } //MouseArea
              } //TibiaMenuOptionCheckBox

              TibiaCurrencyView {
                Layout.preferredWidth: TibiaStyle.preyShortCurrencyWidth
                Layout.fillHeight: true
                price: preyView.choosePreyPrice
                iconId: "PreyWildcards"
                tooLowBalance: preyView.choosePreyTooExpensive
              } //TibiaCurrencyView
            } //RowLayout

          } //ColumnLayout
        } //ColumnLayout
      } //Item reroll prey view

      Item { //unlock view
        id: unlockView
        Layout.preferredHeight: rerollPreyView.Layout.preferredHeight
        Layout.fillWidth: true
        enabled: preyView.isLocked
        visible: enabled

        ColumnLayout {
          id: unlockLayout
          anchors { left: parent.left; top: parent.top; right: parent.right }
          spacing: TibiaStyle.marginRelated

          TibiaButton {
            id: unlockPermanentlyButton
            Layout.fillWidth: true
            Layout.preferredHeight: Math.floor((unlockView.height - unlockLayout.spacing) / 2)
            color: "blue"

            visible: preyViewModel != null && (preyViewModel.unlockOption == TibiaEnums.UNLOCK_OPTION_PREMIUM_OR_STORE
                                               || preyViewModel.unlockOption == TibiaEnums.UNLOCK_OPTION_STORE)

            imageSource: "/images/prey-unlock-permanently.png"

            onClicked: preyView.onUnlockPermanentlyClicked()
          } //TibiaButton

          TibiaButton {
            id: unlockTemporarilyButton
            Layout.fillWidth: true
            Layout.preferredHeight: Math.floor((unlockView.height - unlockLayout.spacing) / 2)
            color: "blue"

            visible: preyViewModel != null && preyViewModel.unlockOption == TibiaEnums.UNLOCK_OPTION_PREMIUM_OR_STORE

            imageSource: "/images/prey-unlock-temporarily.png"

            onClicked: preyView.onUnlockWithPermiumClicked()
          } //TibiaButton
        } //ColumnLayout
      } //Item unlock view
    } //ColumnLayout
  } //TibiaFrame2PixelUpFilledWithCaption

  readonly property string hoverText: {
    if (currentPreyViewHoverArea.enabled && currentPreyViewHoverArea.containsMouse) {
      if (preyView.isLocked) {
        return qsTrId("prey_hover_prey_view_locked");
      } else if (preyView.isInactive) {
        return qsTrId("prey_hover_prey_view_inactive");
      } else if (preyView.isActive) {
        return qsTrId("prey_hover_prey_view_active").arg(preyView.monsterName)
                                                    .arg(preyView.timeLeft)
                                                    .arg(preyView.bonusGradeText)
                                                    .arg(preyView.bonusTypeText)
               + "<br>" + preyView.preyDescription;
      }
      return "";
    } else if (   (listRerollButton.enabled && listRerollButton.hovered && preyView.allowHoverMouse)
               || (listRerollButtonSelection.enabled && listRerollButtonSelection.hovered && preyView.allowHoverMouse)) {
      if (preyView.isInactive) {
        return qsTrId("prey_hover_list_reroll_reactivate")
             + "<br>"
             + qsTrId("prey_hover_reactivate");
      }

      return qsTrId("prey_hover_list_reroll_switch_creature")
           + "<br>"
           + qsTrId("prey_hover_refresh").arg(preyView.bonusValueText)
                                         .arg(preyView.bonusTypeText);
    } else if (   (listRerollButtonHoverArea.enabled && listRerollButtonHoverArea.containsMouse)
               || (listRerollButtonSelectionHoverArea.enabled && listRerollButtonSelectionHoverArea.containsMouse)) {
      if (preyView.listRerollTooExpensive) {
        return qsTrId("prey_hover_list_reroll_reactivate_too_expensive");
      } else if (preyView.isActive) {
        return qsTrId("prey_hover_list_reroll_switch_creature")
               + "<br>"
               + qsTrId("prey_hover_refresh").arg(preyView.bonusValueText)
                                             .arg(preyView.bonusTypeText);
      }
      return "";
    } else if (   (choosePreyButton.enabled && choosePreyButton.hovered && preyView.allowHoverMouse)
               || (choosePreyButtonSelection.enabled && choosePreyButtonSelection.hovered && preyView.allowHoverMouse)) {
      if (preyView.isInactive) {
        return qsTrId("prey_hover_choose_prey_reactivate")
             + "<br>"
             + qsTrId("prey_hover_reactivate");
      }

      return qsTrId("prey_hover_choose_prey_switch_creature")
           + "<br>"
           + qsTrId("prey_hover_refresh").arg(preyView.bonusValueText)
                                         .arg(preyView.bonusTypeText);
    } else if (   (choosePreyButtonHoverArea.enabled && choosePreyButtonHoverArea.containsMouse)
               || (choosePreyButtonSelectionHoverArea.enabled && choosePreyButtonSelectionHoverArea.containsMouse)) {
      if (preyView.choosePreyTooExpensive) {
        return qsTrId("prey_hover_bonus_reroll_get_more_in_store").arg(TibiaStyle.blue2)
             + "<br>"
             + qsTrId("prey_hover_choose_prey_reactivate_too_expensive").arg(qsTrId("currency_view_preywildcard_tooltip"));
      } else if (preyView.isActive) {
        return directToStore
             + qsTrId("prey_hover_choose_prey_switch_creature")
             + "<br>"
             + qsTrId("prey_hover_refresh").arg(preyView.bonusValueText)
                                           .arg(preyView.bonusTypeText);
      }
      return "";
    } else if (   (freeListRerollProgressHoverArea.enabled && freeListRerollProgressHoverArea.containsMouse)
               || (freeListRerollProgressSelectionHoverArea.enabled && freeListRerollProgressSelectionHoverArea.containsMouse)) {
      return (preyView.freeListRerollAvailable ? qsTrId("prey_hover_time_free_list_reroll_available")
                                               : qsTrId("prey_hover_time_free_list_reroll_wait").arg(preyView.timeToFreeListReroll))
             + "<br>" + qsTrId("prey_hover_time_free_list_reroll_recharge");
    } else if (bonusRerollButton.enabled && bonusRerollButton.hovered && preyView.allowHoverMouse) {
      return qsTrId("prey_hover_bonus_reroll");
    } else if (bonusRerollButtonHoverArea.enabled && bonusRerollButtonHoverArea.containsMouse) {
      if (preyView.isInactive) {
        return qsTrId("prey_hover_bonus_reroll_inactive");
      } else if (preyView.bonusRerollTooExpensive) {
        return qsTrId("prey_hover_bonus_reroll_get_more_in_store").arg(TibiaStyle.blue2)
               + "<br>" + qsTrId("prey_hover_bonus_reroll_shorter");
      }

      return "";
    } else if ((   (confirmSelection.enabled && confirmSelection.hovered )
                || (confirmBestiarySelection.enabled && confirmBestiarySelection.hovered))
               && preyView.allowHoverMouse) {
      if (preyView.isInactive) {
        return qsTrId("prey_hover_confirm_reactivate").arg(preyView.selectedPreymonsterName);
      }

      return qsTrId("prey_hover_confirm_switch_creature").arg(preyView.selectedPreymonsterName)
                                                         .arg(preyView.bonusValueText)
                                                         .arg(preyView.bonusTypeText);
    } else if (   confirmSelectionHoverArea.containsMouse
               || confirmBestiarySelectionHoverArea.containsMouse) {
      return qsTrId("prey_hover_confirm_disabled");
    } else if (   (preyMonsterGridSelectionHoverArea.enabled && preyMonsterGridSelectionHoverArea.containsMouse)
               || (preyMonsterGridSelection.enabled && preyMonsterGridSelection.delegateHovered)
               || bestiarySelectionView.hovered) {
      if (preyView.isInactive) {
        return qsTrId("prey_hover_creature_reactivate");
      }

      return qsTrId("prey_hover_creature_switch_creature").arg(preyView.bonusValueText)
                                                          .arg(preyView.bonusTypeText);
    } else if (unlockPermanentlyButton.enabled && unlockPermanentlyButton.hovered && preyView.allowHoverMouse) {
      return qsTrId("prey_hover_unlock_permanently");
    } else if (unlockTemporarilyButton.enabled && unlockTemporarilyButton.hovered && preyView.allowHoverMouse) {
      return qsTrId("prey_hover_unlock_temporarily");
    } else if (autoRerollCheckBoxHoverArea.containsMouse) {
      return qsTrId("prey_hover_auto_reroll")
             + "<br><br>"
             + qsTrId("prey_hover_currency_spend_warning").arg(TibiaStyle.red2)
                                                          .arg(preyView.bonusRerollPrice)
                                                          .arg(qsTrId("prey_auto_reroll"))
                                                          .arg(qsTrId("currency_view_preywildcard_tooltip"));
    } else if (preyLockCheckBoxHoverArea.containsMouse) {
      return qsTrId("prey_hover_lock_prey")
             + "<br><br>"
             + qsTrId("prey_hover_currency_spend_warning").arg(TibiaStyle.red2)
                                                          .arg(preyView.choosePreyPrice)
                                                          .arg(qsTrId("prey_lock_prey"))
                                                          .arg(qsTrId("currency_view_preywildcard_tooltip"));
    }

    return "";
  } //readonly property string hoverText
} //Item
