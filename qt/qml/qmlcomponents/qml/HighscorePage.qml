import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qmlcomponents
import qmlenumvalues
import QtQuick.LegacyControls


TibiaDialog {

  id: root
  caption: qsTrId("highscores_dialog_caption")
  width: 700

  property var controller: null
  property var initialFocusItem: null

  property bool showLoadingComponent: controller ? controller.showLoadingComponent : false
  property bool dataAvailable: controller ? controller.dataAvailable : false

  property var availableWorlds: controller != null ? controller.availableWorlds : null
  property int indexOfSelectedWorld: controller != null ? controller.indexOfSelectedWorld : -1

  property var availableBattlEyeTypes: controller != null ? controller.availableBattlEyeTypes : null
  property var indexOfSelectedBattlEyeType: controller != null ? controller.indexOfSelectedBattlEyeType : -1

  property var availableVocations: controller != null ? controller.availableVocations : null
  property int indexOfSelectedVocation: controller != null ? controller.indexOfSelectedVocation : -1

  property var availableCategories: controller != null ? controller.availableCategories : null
  property int indexOfSelectedCategory: controller != null ? controller.indexOfSelectedCategory : -1

  property var highscoreData: controller != null ? controller.highscoreData : null
  property var highscoreEntryModel: highscoreData != null ? highscoreData.highscoreEntryModel : null

  property int selectedPage: controller != null? controller.selectedPage : 0
  property int totalPages: controller != null? controller.totalPages : 0

  property bool showLoyaltyTitle: controller != null ? controller.showLoyaltyTitle : true
  property int selectedIndex: controller != null ? controller.selectedIndex : 0

  property var valueType : controller != null ? controller.valueType : HighscoresDialogController.Points

  property string dataActualisationText: controller != null ? controller.dataActualisationText : ""

  onReturnPressedFunction: function() {
  }

  onCancelPressedFunction: function() {
    if (controller != null) {
      controller.requestClose();
    }
  }

  ColumnLayout {
    anchors { left: parent.left; right: parent.right;}
    spacing: TibiaStyle.marginCooldownBar
    TibiaPanel2PixelUpFilledWithCaption {
      id: characterFrame
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignTop
      visible: dataAvailable

      caption: qsTrId("highscores_page_caption")

      ColumnLayout {
        GridLayout {
          columns: 4
          columnSpacing: 10
          Layout.alignment: Qt.AlignLeft

          TibiaText {
            Layout.leftMargin: TibiaStyle.marginCooldownBar
            text: qsTrId("highscores_selectworld_caption")
          }
          TibiaComboBox {
            id: highscoreWorldSelectionBox
            Layout.preferredWidth: 235
            model: availableWorlds
            enabled: !showLoadingComponent
            shouldBeCurrentIndex: indexOfSelectedWorld

            onModelChanged: {
              currentIndex = indexOfSelectedWorld;
            }

            onActivated: {
              if (controller) {
                controller.indexOfSelectedWorld = currentIndex;
              }
            }
          } // TibiaComboBox

          TibiaText {
            Layout.leftMargin: TibiaStyle.marginCooldownBar
            text: qsTrId("highscores_selectbattleye_caption")
          }

          TibiaComboBox {
            id: highscoreBattlEyeSelectionBox
            Layout.preferredWidth: 235
            model: availableBattlEyeTypes
            enabled: !showLoadingComponent
            shouldBeCurrentIndex: indexOfSelectedBattlEyeType

            onModelChanged: {
              currentIndex = indexOfSelectedBattlEyeType;
            }

            onActivated: {
              if (controller) {
                controller.indexOfSelectedBattlEyeType = currentIndex;
              }
            }
          }

          TibiaText {
            Layout.leftMargin: TibiaStyle.marginCooldownBar
            text: qsTrId("highscores_selectvocation_caption")
          }

          TibiaComboBox {
            id: highscoreVocationSelectionBox
            Layout.preferredWidth: 235
            model: availableVocations
            enabled: !showLoadingComponent
            shouldBeCurrentIndex: indexOfSelectedVocation

            onModelChanged: {
              currentIndex = indexOfSelectedVocation;
            }

            onActivated: {
              if (controller) {
                controller.indexOfSelectedVocation = currentIndex;
              }
            }
          } // TibiaComboBox

          TibiaText {
            Layout.leftMargin: TibiaStyle.marginCooldownBar
            text: qsTrId("highscores_selectcategory_caption")
          }

          TibiaComboBox {
            id: highscoreCategorySelectionBox
            Layout.preferredWidth: 235
            model: availableCategories
            enabled: !showLoadingComponent
            shouldBeCurrentIndex: indexOfSelectedCategory

            onModelChanged: {
              currentIndex = indexOfSelectedCategory;
            }

            onActivated: (index) => {
              if (controller) {
                controller.indexOfSelectedCategory = index;
              }
            }
          } // TibiaComboBox

          TibiaText {
            Layout.alignment: Qt.AlignTop
            Layout.topMargin: TibiaStyle.marginRelated
            Layout.leftMargin: TibiaStyle.marginCooldownBar
            text: qsTrId("highscores_selectworldtype_caption")
          }

          GridView {
            Layout.topMargin: TibiaStyle.marginRelated
            Layout.columnSpan: 3
            Layout.fillWidth: true
            Layout.preferredHeight: cellHeight * 2

            cellWidth: (width - TibiaStyle.buttonWidthWide) / 3 // Leave some space on the right side for the submit button
            cellHeight: 17
            model: controller != null ? controller.worldTypeModel : null

            delegate: TibiaCheckBox {
              text: model.name
              shouldBeChecked: model.checked
              enabled: !showLoadingComponent

              onClicked: {
                if (controller) {
                  controller.toggleSelectedWorldType(model.worldType);
                }
              }
            }

            TibiaButton {
              id: submitButton
              anchors { right: parent.right; bottom: parent.bottom; }

              text: qsTrId("highscores_submit_button")
              enabled: !showLoadingComponent
              onClicked: {
                if (controller) {
                  controller.applyFilters();
                }
              }
            } // TibiaButton
          } //GridView
        } // GridLayout
      } // ColumnLayout
    } // TibiaPanel2PixelUpFilledWithCaption

    Item {

      Layout.fillWidth: true
      Layout.preferredHeight: 342

      Loader {

        anchors.fill: parent
        anchors.topMargin: TibiaStyle.marginNarrow
        anchors.bottomMargin: TibiaStyle.marginNarrow

        Component {
          id: highScoreTable

          TibiaTableView {
            id: highScoreTable
            flickableItem.interactive: false
            flickableItem.boundsBehavior: Flickable.StopAtBounds
            verticalScrollBarPolicy: ScrollBar.AlwaysOff
            horizontalScrollBarPolicy: ScrollBar.AlwaysOff
            headerVisible: true
            selectionMode: SelectionMode.NoSelection;
            model: highscoreEntryModel

            property bool _preventSelectionChangedHandler: false

            selection.onSelectionChanged: {
              if (!_preventSelectionChangedHandler) {
                selectRowTimer.start();
              }
            }

            onModelChanged: {
              selectRowTimer.start();
            }

            Timer {
              id: selectRowTimer
              interval: 0
              repeat: false
              running: false
              onTriggered: {
                if (highScoreTable.rowCount > 0) {
                  highScoreTable._preventSelectionChangedHandler = true;
                  highScoreTable.selection.clear();
                  if (selectedIndex != -1) {
                    highScoreTable.selection.select(selectedIndex);
                  }
                  highScoreTable._preventSelectionChangedHandler = false;
                }
              }
            } // Timer


            TableViewColumn {
              id: rankColumn
              role: "rank"
              title: qsTrId("highscores_rank_column_title")
              width: 42
              movable: false
              resizable: false
              delegate: HighscoreColumnContent {
                displayText: model != null ? model.rank : ""
                ownCharacter: model != null? model.isOwnCharacter : false
              }

            } // TableViewColumn

            TableViewColumn {
              id: characterColumn

              role: "character"
              title: qsTrId("character")
              width: showLoyaltyTitle ? 152 : 227
              movable: false
              resizable: false
              delegate: HighscoreColumnContent {
                displayText: model != null ? model.character : ""
                ownCharacter: model != null? model.isOwnCharacter : false
              }
            } // TableViewColumn

            TableViewColumn {
              id: vocationColumn

              role: "vocation"
              title: qsTrId("highscores_vocation_column_title")
              width: 118
              movable: false
              resizable: false
              delegate: HighscoreColumnContent {
                displayText: model != null ? model.vocation : ""
                ownCharacter: model != null? model.isOwnCharacter : false
              }

              horizontalAlignment: Text.AlignHCenter
            } // TableViewColumn

            TableViewColumn {
              id: worldColumn

              role: "world"
              title: qsTrId("highscores_world_column_title")
              width: 86
              movable: false
              resizable: false
              delegate: HighscoreColumnContent {
                displayText: model != null ? model.world : ""
                ownCharacter: model != null? model.isOwnCharacter : false
              }

              horizontalAlignment: Text.AlignHCenter
            } // TableViewColumn

            TableViewColumn {
              id: levelColumn

              role: "level"
              title: qsTrId("highscores_level_column_title")
              width: 42
              movable: false
              resizable: false
              delegate: HighscoreColumnContent {
                displayText: model != null ? model.level : ""
                ownCharacter: model != null? model.isOwnCharacter : false
              }

              horizontalAlignment: Text.AlignHCenter
            } // TableViewColumn


            TableViewColumn {
              id: loyaltyColumn

              role: "loyaltyTitle"
              title: qsTrId("highscores_loyaltytitle_column_title")
              visible: showLoyaltyTitle
              width: showLoyaltyTitle ? 142 : 0
              horizontalAlignment: Text.AlignHCenter
              movable: false
              resizable: false
              delegate: HighscoreColumnContent {
                displayText: model != null ? model.loyaltyTitle : ""
                ownCharacter: model != null? model.isOwnCharacter : false
              }
            } // TableViewColumn


            TableViewColumn {
              id: scoreColumn

              role: "score"
              title: (valueType == HighscoresDialogController.Points) ? qsTrId("highscores_score_column_title_points") : (valueType == HighscoresDialogController.Skill ? qsTrId("highscores_score_column_title_level") : qsTrId("highscores_score_column_title_score"))
              width: highScoreTable.width - (rankColumn.width + characterColumn.width + vocationColumn.width + worldColumn.width + levelColumn.width + loyaltyColumn.width)
              horizontalAlignment: Text.AlignRight
              movable: false
              resizable: false
              delegate: HighscoreColumnContent {
                displayText: model != null ? model.score : ""
                ownCharacter: model != null? model.isOwnCharacter : false
              }
            } // TableViewColumn
          } // TibiaTableView
        } // Component

        Component {
          id: loadingComponent

          ColumnLayout {
            anchors.centerIn: parent
            Image {
              source: "/images/dynamic/dynamic-image-loading.png"
              Layout.alignment: Qt.AlignHCenter
            } // Image


          } // ColumnLayout

        } // Component

        Component {
          id: noDataComponent

          ColumnLayout {
            anchors.centerIn: parent
            TibiaText {
              text: qsTrId("highscores_no_data")
              Layout.alignment: Qt.AlignHCenter
            } // TibiaText


          } // ColumnLayout

        } // Component

        sourceComponent: controller != null
                       ? (dataAvailable ? (showLoadingComponent ? loadingComponent : highScoreTable) : noDataComponent)
                       : null

      } // Loader

    } // Item

    RowLayout {

      Layout.alignment: Qt.AlignHCenter
      visible: dataAvailable
      TibiaButton {
        id: showMyPlaceButton
        text: qsTrId("highscores_showme_button_title")
        Layout.preferredWidth: 100
        enabled: !showLoadingComponent
        onClicked: {
          if (controller) {
            controller.onClickedShowMyPlaceButton();
          }
        }
      } //TibiaButton

      TibiaButton {
        id: firstPageButton
        imageSource: "/images/icon-arrowskip.png"
        imageSourceDisabled: "/images/icon-arrowskip-disabled.png"
        Layout.preferredWidth: 20
        enabled: selectedPage > 1 && !showLoadingComponent

        onClicked: {
          if (controller) {
            controller.onClickedFirstPage();
          }
        } // onClicked

      } //TibiaButton

      TibiaButton {
        id: previousPageButton
        imageSource: "/images/icon-arrow.png"
        imageSourceDisabled: "/images/icon-arrow-disabled.png"
        Layout.preferredWidth: 20
        enabled: selectedPage > 1 && !showLoadingComponent

        onClicked: {
          if (controller) {
            controller.onClickedPreviousPage();
          }
        } // onClicked

      } //TibiaButton

      TibiaText {
        id: pagingText
        Layout.preferredWidth: 80
        horizontalAlignment: Text.AlignHCenter
        text: controller != null ? qsTrId("count_slash_total").arg(selectedPage).arg(totalPages) : ""
      } // TibiaText

      TibiaButton {
        id: nextPageButton
        imageSource: "/images/icon-arrow.png"
        imageSourceDisabled: "/images/icon-arrow-disabled.png"
        imageMirrored: true
        Layout.preferredWidth: 20
        enabled: selectedPage < totalPages && !showLoadingComponent

        onClicked: {
          if (controller) {
            controller.onClickedNextPage();
          }
        } // onClicked

      } //TibiaButton

      TibiaButton {
        id: lastPageButton
        imageSource: "/images/icon-arrowskip.png"
        imageSourceDisabled: "/images/icon-arrowskip-disabled.png"
        imageMirrored: true
        Layout.preferredWidth: 20
        enabled: selectedPage < totalPages && !showLoadingComponent

        onClicked: {
          if (controller) {
            controller.onClickedLastPage();
          }
        } // onClicked

      } //TibiaButton

      TibiaText {
        id: refreshText
        Layout.preferredWidth: 200
        color: TibiaStyle.textColors['Caption']
        text: dataActualisationText
      } // TibiaText


    } // RowLayout

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } // TibiaHorizontalSeparator

    Item {
      // Padding
      Layout.fillWidth: true
      height: TibiaStyle.marginNarrow * 2
    }

    RowLayout {
      id: buttonBar
      Layout.fillWidth: true
      spacing: TibiaStyle.marginRelated

      Item {
        // Padding
        Layout.fillWidth: true
        height: 1
      }

      TibiaButton {
        text: qsTrId("close")
        onClicked: onCancelPressedFunction()
      }
    } // RowLayout

  } // ColumnLayout
} // TibiaDialog
