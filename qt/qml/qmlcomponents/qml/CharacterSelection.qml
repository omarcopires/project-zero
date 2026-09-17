import QtQuick
import QtQuick.Layouts

import qmlcomponents
import QtQuick.LegacyControls

TibiaDialog {
  id: root
  caption: qsTrId("characterselection_caption")
  width: 745

  required property QtObject controller

  property string accountStatusText: controller.accountPremiumStatus
  property alias charactersModel: characterList.model
  property alias selectedCharacterRowIndex: characterList.currentRow
  property bool allowMultiselection: false
  property bool showOutfit: controller.showOutfits
  property bool recoverySetupComplete: controller != null ? controller.recoverySetupComplete : true

  function confirmCharacterSelection() {
    var selectedCharacterRowIndices = []
    if (okButton.enabled) {
      characterList.selection.forEach( function(rowIndex) { selectedCharacterRowIndices.push(rowIndex); } )
      controller.onCharacterSelectionConfirmed(selectedCharacterRowIndices);
    }
  } //function selectCharacter


  onReturnPressedFunction: confirmCharacterSelection;
  onCancelPressedFunction: function() {
    controller.onCancelClicked()
  }
  initialFocusItem: characterList

  property string searchString: ""
  Keys.onPressed: (event) => {
    if (event.key >= Qt.Key_A && event.key <= Qt.Key_Z  || event.key == Qt.Key_Space) {
      var pressedCharacter = event.text.toUpperCase();

      searchString = searchString + event.text;
      resetSearchStringTimer.restart();

      var index = controller.getCharacterIndexForSearchString(searchString);
      if (index >= 0) {
        characterList.selection.clear();
        characterList.selectRow(index);
      }

      event.accepted = true;
    }
  } //Keys.onPressed

  Timer {
    id: resetSearchStringTimer
    interval: TibiaStyle.searchDelay
    repeat: false
    onTriggered: {
      root.searchString = "";
    } //onTriggered
  } //Timer

  Component {
    id: accountManagementComponent
    Item {
      implicitHeight: layoutWrapper.height
      RowLayout {
        id: layoutWrapper
        anchors.left: parent.left
        anchors.right: parent.right
        TibiaText {
          Layout.fillWidth: true
          styleType: "MessageWarning"
          text: qsTrId("recovery_setup_not_complete_message")
          visible: !recoverySetupComplete
        }
        Item {
          Layout.fillWidth: true
        }

        TibiaButton {
          text: qsTrId("create_character")
          Layout.preferredWidth: TibiaStyle.buttonWidthWider
          enabled: !disableTimer.running

          Timer {
            id: disableTimer
            interval: 1000
            running: false
            repeat: false
          }

          onClicked: {
            if (controller != null) {
              controller.createCharacterPressed();
              disableTimer.start();
            }
          } //onClicked
        }

        TibiaButton {
          text: qsTrId("manage_account")
          Layout.preferredWidth: TibiaStyle.buttonWidthWider

          onClicked: {
            if (controller != null) {
              controller.manageAccountPressed();
            }
          } //onClicked
        } // TibiaButton
      }
    }
  }

  ColumnLayout {
    id: columns
    anchors { left: parent.left; right: parent.right}
    spacing: TibiaStyle.marginUnrelated

    ColumnLayout {
      Layout.preferredHeight: 340
      spacing: TibiaStyle.marginUnrelated
      Layout.fillWidth: true

      Loader {
        id: recoverySetupNotCompleteLoader
        sourceComponent: accountManagementComponent
        onItemChanged: {
          if (item) {
            recoverySetupNotCompleteLoader.Layout.fillWidth = true;
          }
        }
      }

      TibiaTableView {
        id: characterList
        selectionMode: allowMultiselection ? SelectionMode.ExtendedSelection : SelectionMode.SingleSelection
        Layout.fillHeight: true
        Layout.fillWidth: true
        KeyNavigation.tab: characterList
        Keys.forwardTo: [root]
        model: controller.characterList
        onModelChanged: {
          applyLastSelectedIndex();
        } //onModleChanged

        focus: true

        headerVisible: true

        sortIndicatorVisible: true

        sortIndicatorColumn: controller.sortColumn
        sortIndicatorOrder: controller.sortOrder

        onSortIndicatorColumnChanged: refreshSortingTimer.restart()
        onSortIndicatorOrderChanged: refreshSortingTimer.restart()

        Timer {
          id: refreshSortingTimer
          interval: 0
          repeat: false
          onTriggered: {
            //prevent sorting by outfit
            if (characterList.sortIndicatorColumn == 0) { //0 = Outfit
              if (controller.sortColumn == 1)  { // 1 = Name
                characterList.sortIndicatorOrder = characterList.sortIndicatorOrder == Qt.AscendingOrder ? Qt.DescendingOrder : Qt.AscendingOrder;
              }
              characterList.sortIndicatorColumn = 1;
            }

            controller.setSortOrder(characterList.sortIndicatorColumn,
                                    characterList.sortIndicatorOrder);
          } //onTriggered
        } //Timer

        Component.onCompleted: {
          forceActiveFocus();
        } //Component.onCompleted

        rowHeight: root.showOutfit ? 66 : 29
        // dynamic height needs redraw, eg by toggling between 2 row delegates
        Component {
          id: outfitShownDelegate
          TibiaTableViewRowDelegate {
            rowHeight: characterList.rowHeight
            alternatingRowColors: characterList.alternatingRowColors
          }
        }

        Component {
          id: outfitHiddenDelegate
          TibiaTableViewRowDelegate {
            rowHeight: characterList.rowHeight
            alternatingRowColors: characterList.alternatingRowColors
          }
        }

        onRowHeightChanged: {
          rowDelegate = root.showOutfit ? outfitShownDelegate : outfitHiddenDelegate
          applyLastSelectedIndex();
        } //onRowHeightChanged

        TableViewColumn {
          id: columnOutfit
          role: "outfit"
          resizable: false
          movable: false
          width: 66
          visible: root.showOutfit
          delegate: OutfitAppearanceInstanceRenderer {
            width: columnOutfit.width
            height: width

            smoothTextureFiltering: controller.clientSettingSmoothFiltering

            outfitId: modelData != null ? modelData.outfit.id : 0
            headColor: modelData != null ? modelData.outfit.headColor : "black"
            torsoColor: modelData != null ? modelData.outfit.torsoColor : "black"
            legsColor: modelData != null ? modelData.outfit.legsColor : "black"
            detailColor: modelData != null ? modelData.outfit.detailColor : "black"
            firstAddOn: modelData != null ? modelData.outfit.firstAddOn : false
            secondAddOn: modelData != null ? modelData.outfit.secondAddOn : false
          } // delegate: OutfitAppearanceInstanceRenderer
        } //TableViewColumn

        TableViewColumn {
          id: columnCharacter
          title: qsTrId("character")
          role: "characterName"
          resizable: false
          movable: false
          width: characterList.contentItem.width - columnStatus.width
                                                 - columnLevel.width
                                                 - columnVocation.width
                                                 - columnWorld.width
                                                 - (columnOutfit.visible ? columnOutfit.width : 0)

         delegate: Item {
            id: delegateRoot
            anchors.fill: parent

            readonly property int availableWidth: width - (separator.visible ? separator.width : 0)

            TibiaButton {
              id: pinnButton
              width: 12
              height: width
              anchors.top: parent.top
              anchors.topMargin: 1
              anchors.right: parent.right
              anchors.rightMargin: separator.width + 1

              visible: modelData && modelData.isPinned || styleData.selected
              imageSource: "/images/icon-pin.png"
              tooltipText: qsTrId("characterselection_pin_character_tooltip")
              tooltipTextChecked: qsTrId("characterselection_unpin_character_tooltip")

              checkable: true
              useButtonShouldBeChecked: true
              buttonShouldBeChecked: modelData && modelData.isPinned

              onClicked: {
                controller.onPinnedChanged(styleData.value,
                                           !checked);
              } //onClicked
            } //TibiaButton

            ColumnLayout {
              anchors { left: parent.left; right:parent.right }
              anchors.leftMargin: TibiaStyle.marginNarrow
              anchors.rightMargin: TibiaStyle.marginRelated
              spacing: 0

              RowLayout {
                spacing: TibiaStyle.marginNarrow
                TibiaText {
                  Layout.maximumWidth: delegateRoot.availableWidth
                                    - (mainCharacterNotification.visible? (mainCharacterNotification.width + TibiaStyle.marginRelated) : 0)
                                    - (pinnButton.visible? (pinnButton.width + TibiaStyle.marginRelated) : 0)
                  text: styleData.value
                  color: styleData.selected ? TibiaStyle.textFieldSelectionTextColor
                                            : TibiaStyle.textFieldTextColor
                  elide: styleData.elideMode
                  horizontalAlignment: styleData.textAlignment
                  //see texthelper.cpp:15 and http://doc.qt.io/qt-5/qml-qtquick-text.html#elide-prop
                  textFormat: text.indexOf("\x9C") != -1 ? Text.PlainText
                                                         : Text.StyledText
                } //TibiaText

                Image {
                  id: mainCharacterNotification
                  visible: modelData && modelData.isMainCharacter
                  source: "/images/maincharacter.png"

                  Tooltip {
                    anchors.fill: parent
                    text: qsTrId("characterselection_maincharacter_tooltip")
                  }
                } // Image
              } // RowLayout

            } //ColumnLayout
            TibiaVerticalSeparator {
              id: separator
              visible: characterList.headerVisible && characterList.columnCount > 1
                       && styleData.column < characterList.columnCount-1
              anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
            } // TibiaVerticalSeparator
          } //delegate: Item
        } //TableViewColumn
        TableViewColumn {
          id: columnStatus
          title: qsTrId("status")
          role: "dailyRewardState"
          resizable: false
          movable: false
          width: 55

          delegate: Item {
            anchors.fill: parent

            RowLayout {
              anchors.left: parent.left
              anchors.right: separator.left
              anchors.top: parent.top
              anchors.leftMargin: TibiaStyle.marginNarrow
              anchors.rightMargin: TibiaStyle.marginNarrow
              anchors.topMargin: 1

              spacing: TibiaStyle.marginRelated

              TibiaDailyRewardStatus {
                Layout.alignment: Qt.AlignTop
                dailyRewardState: modelData ? modelData.dailyRewardState : TibiaEnums.DailyRewardStateNotAvailable
              } //TibiaDailyRewardStatus

              Image {
                source: "/images/icon-status-hidden.png"
                visible: modelData != null && modelData.isHidden
                Tooltip {
                  anchors.fill: parent
                  text: qsTrId("characterselection_hidden_tooltip")
                } //Tooltip
              } //Image

              Item {
                Layout.fillWidth: true
                Layout.leftMargin: -parent.spacing
              } //Item
            } //RowLayout

            TibiaVerticalSeparator {
              id: separator
              anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
            } // TibiaVerticalSeparator
          } //delegate: Item
        } //TableViewColumn
        TableViewColumn {
          id: columnLevel
          title: qsTrId("level")
          role: "level"
          resizable: false
          movable: false
          width: 50
        } //TableViewColumn
        TableViewColumn {
          id: columnVocation
          title: qsTrId("vocation")
          role: "vocation"
          resizable: false
          movable: false
          width: 115
        } //TableViewColumn
        TableViewColumn {
          id: columnWorld
          title: qsTrId("characterselection_column_world")
          role: "world"
          resizable: false
          movable: false
          width: 200
          delegate: Item {
            anchors.fill: parent

            ColumnLayout {
              anchors { left: parent.left; right:parent.right }
              anchors.leftMargin: TibiaStyle.marginNarrow
              anchors.rightMargin: TibiaStyle.marginRelated
              spacing: 0

              TibiaText {
                Layout.fillWidth: true
                text: styleData.value
                color: styleData.selected
                  ? TibiaStyle.textFieldSelectionTextColor
                  : TibiaStyle.textFieldTextColor
                elide: styleData.elideMode
                horizontalAlignment: styleData.textAlignment
                //see texthelper.cpp:15 and http://doc.qt.io/qt-5/qml-qtquick-text.html#elide-prop
                textFormat: text.indexOf("\x9C") != -1 ? Text.PlainText
                                                       : Text.StyledText
              } //TibiaText

              TibiaText {
                Layout.fillWidth: true
                text: modelData ? "(" + modelData.worldRules + ")" : qsTrId("dummy_unknown")
                color: styleData.selected
                  ? TibiaStyle.textFieldSelectionTextColor
                  : TibiaStyle.textFieldTextColor
                elide: styleData.elideMode
                horizontalAlignment: styleData.textAlignment
                //see texthelper.cpp:15 and http://doc.qt.io/qt-5/qml-qtquick-text.html#elide-prop
                textFormat: text.indexOf("\x9C") != -1 ? Text.PlainText
                                                       : Text.StyledText
              } //TibiaText
            } //ColumnLayout
            TibiaVerticalSeparator {
              visible: characterList.headerVisible && characterList.columnCount > 1
                       && styleData.column < characterList.columnCount-1
              anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
            } // TibiaVerticalSeparator
          } //delegate: Item
        } //TableViewColumn

        function selectRow(row) {
          if (rowCount > 0 && model != null && model.length > 0) {
            characterList.currentRow = row;
            characterList.selection.clear();
            characterList.selection.select(row);
          }
        } //function selectRow(row)

        function applyLastSelectedIndex() {
          selectDelay.restart();
        } //function applyLastSelectedIndex()

        Timer {
          id: selectDelay
          interval: 0
          onTriggered: {
            if (controller.lastSelectedIndex < characterList.rowCount) {
              characterList.selectRow(controller.lastSelectedIndex);
            }
          } //onTriggered
        } //Timer

        onVisibleChanged: {
          applyLastSelectedIndex();
        } //onVisibleChanged

        onDoubleClicked: {
          if (rowCount > 0) {
            confirmCharacterSelection();
          }
        }
      } //TibiaTableView

      RowLayout {
        Layout.fillWidth: true
        spacing: 0

        ColumnLayout {
          spacing: TibiaStyle.marginRelated

          TibiaText {
            text: qsTrId("characterselection_accountstatus_caption")
            textFormat: Text.RichText
          } //TibiaText

          RowLayout {
            Image {
              source: controller.isPremium ? "/images/premium/icon-premium.png"
                                           : "/images/premium/icon-nopremium.png"
      } //Image

            TibiaText {
              text: accountStatusText
              textFormat: Text.RichText
            } //TibiaText
          } //RowLayout
        } //ColumnLayout

        Item { Layout.fillWidth: true }

        TibiaButton {
          Layout.alignment: Qt.AlignBottom | Qt.AlignRight
          text: qsTrId("get_premium")
          Layout.preferredWidth: TibiaStyle.buttonWidthWide
          color: "green"

          visible: controller.showGetPremiumButton

          onClicked: {
            controller.onGetPremiumClicked();
          } //onClicked
        } //TibiaButton
      } //RowLayout

      ColumnLayout {
        Layout.fillWidth: true
        spacing: TibiaStyle.marginRelated

        visible: !controller.isPremium

        TibiaHorizontalSeparator {
          Layout.fillWidth: true
        } //TibiaHorizontalSeparator

        TibiaText {
          Layout.alignment: Qt.AlignHCenter
          text: qsTrId("characterselection_premium_benefits_caption")
        } //TibiaText


        GridLayout {
          id: premiumFeaturView
          Layout.fillWidth: true
          columns: 3
          columnSpacing: TibiaStyle.marginNarrow
          rowSpacing: TibiaStyle.marginRelated

          Repeater {
            model: controller.premiumFeaturesModel

            delegate: ColumnLayout {
              Layout.alignment: Qt.AlignTop
              spacing: TibiaStyle.marginRelated

              Image {
                Layout.alignment: Qt.AlignHCenter
                source: modelData.imageUrl
              } //Image

              TibiaText {
                Layout.maximumWidth: Math.floor((columns.width -2*premiumFeaturView.rowSpacing) / 3)
                Layout.minimumWidth: Layout.maximumWidth
                text: modelData.message
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
              } //TibiaText
            } //delegate: ColumnLayout
          } //Repeater
        } //GridLayout

        TibiaClickableLink {
          text: qsTrId("characterselection_premium_many_more")
          onLinkClicked: {
            controller.onMorePremiumFeaturesClicked();
          }
        } // TibiaClickableLink
      } //ColumnLayout
    } //ColumnLayout

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } // TibiaHorizontalSeparator


    RowLayout {
      spacing: TibiaStyle.marginUnrelated

      TibiaMenuOptionCheckBox {
        text: qsTrId("characterselection_show_hidden_characters")
        checked: controller.showHiddenCharacters
        onCheckedChanged: {
          controller.setShowHiddenCharacters(checked);
        } //onCheckedChanged
      } //TibiaMenuOptionCheckBox

      TibiaMenuOptionCheckBox {
        text: qsTrId("characterselection_show_outfits")
        checked: controller.showOutfits
        onCheckedChanged: {
          controller.setShowOutfits(checked);
        } //onCheckedChanged
      } //TibiaMenuOptionCheckBox

      Item {
        Layout.fillWidth: true
      } //Item

      TibiaButton {
        id: okButton
        text: qsTrId("ok")
        enabled: characterList.rowCount > 0 && characterList.selection.count > 0
        onClicked: { confirmCharacterSelection(); }
      } //TibiaButton

      TibiaButton {
        id: cancelButton
        text: qsTrId("cancel")
        onClicked: controller.onCancelClicked()
      } //TibiaButton
    } //RowLayout
  }//ColumnLayout
} //TibiaDialog
