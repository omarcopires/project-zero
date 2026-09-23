import QtQuick
import QtQuick.Layouts
import QtQuick.LegacyControls
import qmlcomponents

TibiaDialog {
  id: root
  caption: qsTrId("quest_log_caption")
  width: 785

  property var controller: null;

  onReturnPressedFunction: function() {}

  onCancelPressedFunction: function() {
    controller.closeButtonPressed();
  } //onCancelPressedFunction

  initialFocusItem: questLineNameSearchField

  readonly property int smallIconButtonwidth: 12

  RowLayout {
    id: contentLayout
    anchors { left: parent.left; right: parent.right; top: parent.top;}
    spacing: TibiaStyle.marginUnrelated

    height: 550

    TibiaFrame2PixelUpFilledWithCaption {
      id: questLinesFrame
      Layout.fillWidth: true
      Layout.fillHeight: true

      caption: qsTrId("quest_log_quest_lines_caption")

      ColumnLayout {
        id: questLinesLayout
        anchors.fill: parent
        anchors.margins: parent.marginsToContent
        anchors.topMargin: parent.topMarginToContent
        spacing: TibiaStyle.marginRelated

        TibiaTableView {
          id: questLinesTableView
          Layout.fillWidth: true
          Layout.fillHeight: true

          model: controller.questLinesModel

          headerVisible: false
          selectionMode: SelectionMode.NoSelection

          // Capture and ignore key presses for Up and Down arrow keys
          Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Up || event.key === Qt.Key_Down) {
              event.accepted = true; // Prevent the default action (selection)
            }
          } //Keys.onPressed

          onClicked: (row) => {
            if (rowCount > row) {
              questLinesTableView.selectQuestLinesRow(row);
            }
          } //onClicked

          readonly property var _shouldBeSelectedId: controller.selectedQuestLineId
          on_ShouldBeSelectedIdChanged: { questLinesTableViewSelectRowForIdTimer.start(); }
          onRowCountChanged: { questLinesTableViewSelectRowForIdTimer.start(); }
          Timer{
            id: questLinesTableViewSelectRowForIdTimer
            interval: 0

            onTriggered:{
              let newCurrentIndex = -1;

              if (questLinesTableView.model != null) {
                for (var i=0; i < questLinesTableView.rowCount; i++) {
                  let idx = questLinesTableView.model.index(i, 0);
                  let id = questLinesTableView.model.data(idx, questLinesTableView.model.questLineIdEnumValue);

                  if (id == questLinesTableView._shouldBeSelectedId) {
                    newCurrentIndex = i;
                    break;
                  }
                }
              }

              questLinesTableView.selectQuestLinesRow(newCurrentIndex);
            } //function onTriggered
          } //Timer

          function selectQuestLinesRow(rowIndex) {
            if (rowIndex != -1) {
              if (!questLinesTableView.selection.contains(rowIndex)) {
                questLinesTableView.selection.clear();
                questLinesTableView.selection.select(rowIndex);
                questLinesTableView.currentRow = rowIndex;

                questLinesTableView.positionViewAtRow(rowIndex, ListView.Contain);

                let id = questLinesTableView.getDataForRow(
                  rowIndex,
                  questLinesTableView.model.questLineIdEnumValue);
                if (id != null) {
                  controller.requestQuestLineDetails(id);
                }
              }
            } else {
              questLinesTableView.selection.clear();
              questLinesTableView.currentRow = -1;
              controller.requestQuestLineDetailsFirstInList();
            }
            questLinesTableView.currentRowChanged(); //send signal even if nothing changed
          } //function selectQuestLinesRow

          function getDataForRow(tableRowIndex, rollIndex) {
            if (0 <= tableRowIndex && tableRowIndex < questLinesTableView.rowCount) {
              let idx = questLinesTableView.model.index(tableRowIndex, 0);
              return questLinesTableView.model.data(idx, rollIndex);
            }
            return null;
          } //function getDataForRow

          function getDataForId(questLineId, rollIndex) {
            for (let i=0; i < questLinesTableView.rowCount; i++) {
              let idx = questLinesTableView.model.index(i, 0);
              let id = questLinesTableView.model.data(idx, questLinesTableView.model.questLineIdEnumValue);
              let data = questLinesTableView.model.data(idx, rollIndex);

              if (id == questLineId) {
                return data;
              }
            }

            return null;
          } //function getDataForId


          TableViewColumn {
            id: completedColumn
            role: "isCompleted"
            width: 14
            delegate: Item {
              Image {
                anchors.centerIn: parent
                source: model != null && model.isCompleted ? "/images/icon-yes.png" : ""

                Tooltip {
                  anchors.fill: parent
                  text: qsTrId("quest_log_completed")
                } //Tooltip
              } //Image
            } //delegate: Item
          } //TableViewColumn

          TableViewColumn {
            id: nameColumn
            role: "name"
            width: questLinesTableView.contentItem.width
              - completedColumn.width
              - hiddenColumn.width
              - pinnedColumn.width
          } //TableViewColumn

          TableViewColumn {
            id: hiddenColumn
            role: "id"
            width: root.smallIconButtonwidth + TibiaStyle.marginNarrow

            delegate: Item {
              TibiaButton {
                id: hiddenButton
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                width: root.smallIconButtonwidth
                height: width

                readonly property bool isHidden: model && model.isHidden

                visible: isHidden || styleData.selected
                imageSource: isHidden ? "/images/icon-show-small-off" : "/images/icon-show-small-on"
                tooltipText: qsTrId("quest_log_hide_quest_line_tooltip")
                tooltipTextChecked: qsTrId("quest_log_unhide_quest_line_tooltip")

                checkable: true
                useButtonShouldBeChecked: true
                buttonShouldBeChecked: isHidden

                onClicked: {
                  questLinesTableView.selectQuestLinesRow(styleData.row);
                  controller.setHidden(
                    styleData.value,
                    !checked);
                } //onClicked
              } //TibiaButton
            } //delegate: Item
          } //TableViewColumn

          TableViewColumn {
            id: pinnedColumn
            role: "id"
            width: root.smallIconButtonwidth + TibiaStyle.marginNarrow

            delegate: Item {
              TibiaButton {
                id: pinnButton
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                width: root.smallIconButtonwidth
                height: width

                readonly property bool isPinned: model && model.isPinned

                visible: isPinned || styleData.selected
                imageSource: "/images/icon-pin.png"
                tooltipText: qsTrId("quest_log_pin_quest_line_tooltip")
                tooltipTextChecked: qsTrId("quest_log_unpin_quest_line_tooltip")

                checkable: true
                useButtonShouldBeChecked: true
                buttonShouldBeChecked: isPinned

                onClicked: {
                  questLinesTableView.selectQuestLinesRow(styleData.row);
                  controller.setPinned(
                    styleData.value,
                    !checked);
                } //onClicked
              } //TibiaButton
            } //delegate: RowLayout
          } //TableViewColumn
        } //TableView

        TibiaComboBox {
          id: sortDirectionComboBox

          readonly property var _shouldBeValue: controller.questLinesModel.sortOrder
          shouldBeCurrentIndex: {
            for (let i = 0; i < sortModel.count; ++i) {
              if (sortModel.get(i).value == _shouldBeValue) {
                return i;
              }
            }
            return 0;
          }
          textRole: "text"
          valueRole: "value"
          model: ListModel {
            id: sortModel
            ListElement { text: qsTrId("sort_az");
                          value: TibiaEnums.ESortOrder.AtoZ }
            ListElement { text: qsTrId("sort_za");
                          value: TibiaEnums.ESortOrder.ZtoA }
            ListElement { text: qsTrId("quest_log_sort_completed_on_top");
                          value: TibiaEnums.ESortOrder.FinisheddOnTop }
            ListElement { text: qsTrId("quest_log_sort_completed_on_bottom");
                          value: TibiaEnums.ESortOrder.FinisheddOnBottom }
          } //model: ListModel

          onActivated: (index) => {
            controller.questLinesModel.sortOrder = sortModel.get(index).value
          } //onActivated
        } //TibiaComboBox

        TibiaTextSearchField {
          id: questLineNameSearchField
          Layout.fillWidth: true

          shouldBeText: controller.questLinesModel.nameFilter

          onSearchTextChanged: {
            controller.questLinesModel.nameFilter = searchText;
          } //onSearchTextChanged
        } //TibiaTextSearchField

        GridLayout {
          Layout.fillWidth: true
          columns: 3
          columnSpacing: 0
          rowSpacing: TibiaStyle.marginRelated

          TibiaCheckBox {
            text: qsTrId("quest_log_show_completed")

            shouldBeChecked: controller.showCompleted

            onClicked: {
              controller.setShowCompleted(checked);
            } //onClicked
          } //TibiaCheckBox

          TibiaText {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
            text: qsTrId("quest_log_quests_completed")
          } //TibiaText

          TibiaText {
            Layout.preferredWidth: 40
            horizontalAlignment: Text.AlignRight
            text: TextHelper.formatNumberWithThousandSeparators(controller.completedQuestLinesCount)
          } //TibiaText

          TibiaCheckBox {
            text: qsTrId("quest_log_show_hidden")

            shouldBeChecked: controller.showHidden

            onClicked: {
              controller.setShowHidden(checked);
            } //onClicked
          } //TibiaCheckBox

          TibiaText {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
            text: qsTrId("quest_log_quests_hidden")
          } //TibiaText

          TibiaText {
            Layout.preferredWidth: 40
            horizontalAlignment: Text.AlignRight
            text: TextHelper.formatNumberWithThousandSeparators(controller.hiddenQuestLinesCount)
          } //TibiaText
        } //GridLayout
      } //ColumnLayout
    } //TibiaFrame2PixelUpFilledWithCaption

    TibiaFrame2PixelUpFilledWithCaption {
      id: selectedQuestLineFrame
      Layout.fillWidth: true
      Layout.fillHeight: true

      caption: {
        let name = questLinesTableView.getDataForId(
          controller.selectedQuestLineId,
          questLinesTableView.model.questLineNameEnumValue);

        if (name != null) {
          return name;
        }
        return qsTrId("quest_log_no_quest_line_selected")
      } //caption

      ColumnLayout {
        id: selectedQuestLineLayout
        anchors.fill: parent
        anchors.margins: parent.marginsToContent
        anchors.topMargin: parent.topMarginToContent
        spacing: TibiaStyle.marginRelated

        TibiaTableView {
          id: questPartsTableView
          Layout.fillWidth: true
          Layout.preferredHeight: Math.floor(12.5 * TibiaStyle.tableViewRowHeight)

          model: controller.questPartsModel

          readonly property var _shouldBeSelectedId: controller.selectedQuestFlagId
          on_ShouldBeSelectedIdChanged: { questPartsTableViewSelectRowForIdTimer.start() }
          onRowCountChanged: { questPartsTableViewSelectRowForIdTimer.start() }

          Timer{
            id: questPartsTableViewSelectRowForIdTimer
            interval: 0

            onTriggered: {
              let newCurrentIndex = -1;

              if (questPartsTableView.model != null) {
                for (let i=0; i < questPartsTableView.rowCount; i++) {
                  let idx = questPartsTableView.model.index(i, 0);
                  let id = questPartsTableView.model.data(idx, questPartsTableView.model.questPartIdEnumValue);

                  if (id == questPartsTableView._shouldBeSelectedId) {
                    newCurrentIndex = i;
                    break;
                  }
                }
              }

              questPartsTableView.selection.clear();
              if (newCurrentIndex != -1) {
                questPartsTableView.selection.select(newCurrentIndex);
                questPartsTableView.currentRow = newCurrentIndex;
                questPartsTableView.currentRowChanged(); //send signal even if nothing changed
              }
            } //onTriggered
          } //Timer

          selection.onSelectionChanged: {
            questPartsTableView.selection.forEach(function(rowIndex) {
              let questFlagID = questPartsTableView.getDataForRow(
                rowIndex,
                questPartsTableView.model.questPartIdEnumValue);

              if (questFlagID != null) {
                controller.selectedQuestFlag(questFlagID);
              }
            });
          } //selection.onSelectionChanged

          function getDataForRow(tableRowIndex, rollIndex) {
            if (0 <= tableRowIndex && tableRowIndex < questPartsTableView.rowCount) {
              let idx = questPartsTableView.model.index(tableRowIndex, 0);
              return questPartsTableView.model.data(idx, rollIndex);
            }
            return null;
          } //function getDataForRow

          TableViewColumn {
            id: partCompletedColumn
            role: "isCompleted"
            width: 14
            delegate: Item {
              Image {
                anchors.centerIn: parent
                source: model != null && model.isCompleted ? "/images/icon-yes.png" : ""

                Tooltip {
                  anchors.fill: parent
                  text: qsTrId("quest_log_completed")
                } //Tooltip
              } //Image
            } //delegate: Item
          } //TableViewColumn

          TableViewColumn {
            id: partNameColumn
            role: "name"
            width: questPartsTableView.contentItem.width
              - partCompletedColumn.width
          } //TableViewColumn
        } //TableView

        TibiaTextArea {
          id: questFlagDescription
          Layout.fillWidth: true
          Layout.fillHeight: true
          readOnly: true
          wrapMode: TextEdit.Wrap

          property int modelRevision: 0

          Connections {
            target: questPartsTableView.model
            function onDataChanged()   { questFlagDescription.modelRevision++ }
          }

          text: {
            void(modelRevision); // explicit binding dependency
            let newText = questPartsTableView.getDataForRow(
                questPartsTableView.currentRow,
                questPartsTableView.model.questPartDescriptionEnumValue);
            if (newText != null) {
              return newText;
            }
            return "";
          } //text
        } // TibiaTextArea

        RowLayout {
          spacing: 0

          TibiaCheckBox {
            id: isTrackedCheckBox
            text: qsTrId("quest_tracker_show_in_quest_tracker")

            enabled: (controller.canTrackAdditionalQuestFlags || checked) && questPartsTableView.selection.count > 0
            shouldBeChecked: controller.isTracked

            onClicked: {
              let id = questPartsTableView.getDataForRow(
                questPartsTableView.currentRow,
                questPartsTableView.model.questPartIdEnumValue);
              if (id != null) {
                controller.setTrackingOfQuestFlag(
                  id,
                  checked);
              }
            } //onClicked
          } //TibiaCheckBox

          Item { Layout.fillWidth: true }

          TibiaGuiHelp {
            visible: !isTrackedCheckBox.enabled
              && questPartsTableView.rowCount > 0
            text: qsTrId("iteminfo_maximum_number_of_tracked_items")
          } //TibiaGuiHelp
        } //RowLayout
      } //ColumnLayout
    } //TibiaFrame2PixelUpFilledWithCaption
  } //RowLayout

  ColumnLayout {
    id: buttonLayout
    anchors { left: parent.left; right: parent.right; top: contentLayout.bottom; topMargin: TibiaStyle.marginUnrelated }

    spacing: TibiaStyle.marginUnrelated

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } //TibiaHorizontalSeparator

    RowLayout {
      spacing: TibiaStyle.marginRelated

      TibiaButton {
        text: qsTrId("quest_log_open_quest_tracker")
        Layout.preferredWidth: TibiaStyle.buttonWidthWide

        onClicked: controller.questTrackerButtonPressed()
      } // TibiaButton

      Item {
        Layout.fillWidth: true
      } //Item

      TibiaButton {
        id: closeButton
        text: qsTrId("close")

        onClicked: root.onCancelPressedFunction()
      } // TibiaButton
    } // RowLayout
  } // ColumnLayout
} // TibiaDialog
