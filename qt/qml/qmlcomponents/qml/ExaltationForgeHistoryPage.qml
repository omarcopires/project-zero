import QtQuick
import QtQuick.Layouts

import qmlcomponents
import QtQuick.LegacyControls


ColumnLayout {
  id: root
  spacing: TibiaStyle.marginRelated

  property var controller: null
  property int currentPage: controller != null ? controller.currentPageId + 1 : 1
  property int numberOfPages: controller != null ? controller.numberOfPages : 1

  TibiaTableView {
    id: historyTable
    Layout.fillWidth: true
    Layout.fillHeight: true
    //verticalScrollBarPolicy: ScrollBar.ScrollBarAlwaysOff

    headerVisible: true
    alternatingRowColors: true
    rowHeight: TibiaStyle.tableViewRowHeight2Lines

    model: controller != null ? controller.exaltationHistoryModel : null

    TableViewColumn {
      id: dateColumn
      role: "dateString"
      title: qsTrId("date_column_header")
      width: TibiaStyle.columnWidthDateTime
      movable: false
      resizable: false
    } //TableViewColumn

    TableViewColumn {
      id: actionColumn
      role: "actionString"
      title: qsTrId("action_column_header")
      width: 95
      movable: false
      resizable: false
    } //TableViewColumn

    TableViewColumn {
      id: detailsColumn
      role: "detailsString"
      title: qsTrId("details")
      width: historyTable.contentItem.width
           - dateColumn.width
           - actionColumn.width
      movable: false
      resizable: false
    } //TableViewColumn

  } //TibiaTableView


  RowLayout {
    Layout.fillWidth: true
    spacing: TibiaStyle.marginRelated

    TibiaButton {
      id: previouPageButton
      Layout.preferredWidth: TibiaStyle.buttonWidthWide
      text: qsTrId("previous_page")
      enabled: root.currentPage > 1
      opacity: enabled ? 1 : 0

      onClicked: {
        if (controller != null) {
          controller.requestPreviousPage();
        }
      } //onClicked
    } //TibiaButton

    TibiaText {
      horizontalAlignment: Text.AlignHCenter
      Layout.fillWidth: true
      text: qsTrId("page_current_and_max").arg(root.currentPage)
                                          .arg(root.numberOfPages)
      opacity: previouPageButton.enabled || nextPageButton.enabled ? 1 : 0
    } //TibiaText

    TibiaButton {
      id: nextPageButton
      Layout.preferredWidth: TibiaStyle.buttonWidthWide
      text: qsTrId("next_page")
      enabled: root.currentPage < root.numberOfPages
      opacity: enabled ? 1 : 0

      onClicked: {
        if (controller != null) {
          controller.requestNextPage();
        }
      } //onClicked
    } //TibiaButton
  } //RowLayout
} //ColumnLayout
