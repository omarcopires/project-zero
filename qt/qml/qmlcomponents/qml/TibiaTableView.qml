import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.LegacyControls

import qmlcomponents

TableViewOld {
  id: tableView
  alternatingRowColors: true
  headerVisible: false
  verticalScrollBarPolicy: ScrollBar.AlwaysOn
  selectionMode: SelectionMode.SingleSelection;

  flickableItem.boundsBehavior: Flickable.StopAtBounds
  flickableItem.rebound: Transition {}
  flickableItem.pixelAligned: true

  __listView.highlightMoveDuration: 0 //disabels visible scrolling to the selected row
  __listView.interactive: false //prevent flick behavior on touch screens
  property int cacheBuffer: 40 //as many delegate as will fit in cachBuffer pixel will be created above and below the table
                               //many of our talbe have a line height of 16
  __listView.cacheBuffer: cacheBuffer

  __listView.highlightRangeMode: headerVisible ? ListView.ApplyRange : ListView.NoHighlightRange
  __listView.preferredHighlightBegin: headerVisible ? TibiaStyle.tableViewHeaderHeight : 0
  __listView.preferredHighlightEnd: height - 1 // respect TibiaFrame1PixelDown border on the bottom

  property int rowHeight: TibiaStyle.tableViewRowHeight //this is the default value

  function turnOffMouseWheelEventsWorkaround() {
    // setting flickableItem.interactive to false is not enough. The mouse wheel events are still swallowed so
    // that a TableView steals away the events. This workaround prevents this (best to call it in Component.onCompleted)
    // @see https://bugreports.qt.io/browse/QTBUG-49652
    for (var i = 0; i < flickableItem.children.length; ++i) {
      if (flickableItem.children[i].toString().indexOf("QQuickWheelArea_QML_") === 0) {
          flickableItem.children[i].enabled = flickableItem.interactive;
      }
    }
  }

  style: TableViewStyle {
    backgroundColor: TibiaStyle.tableViewBackgroundColor
    alternateBackgroundColor: TibiaStyle.tableViewAlternateBackgroundColor

    handleOverlap: 0
    minimumHandleLength: 14 // 6+6 for mover-top/bottom +2 (14 found in legacy code)

    handle: TibiaScrollBarHandle {
      horizontal: styleData.horizontal
    } // handle

    scrollBarBackground: TibiaTiledImage {
      source: styleData.horizontal
       ? "/images/skin/classic/scrollbar-texture-horizontal.png"
        : "/images/skin/classic/scrollbar-texture-vertical.png"
    } // scrollBarBackground: Image

    decrementControl: Image {
      source: styleData.horizontal
      ? (styleData.pressed ? "/images/skin/classic/scrollbar-buttonleft-down.png" : "/images/skin/classic/scrollbar-buttonleft-up.png")
      : (styleData.pressed ? "/images/skin/classic/scrollbar-buttonup-down.png" : "/images/skin/classic/scrollbar-buttonup-up.png")
    } //decrementControl: Image

    incrementControl: Image {
      source: styleData.horizontal
      ? (styleData.pressed ? "/images/skin/classic/scrollbar-buttonright-down.png" : "/images/skin/classic/scrollbar-buttonright-up.png")
      : (styleData.pressed ? "/images/skin/classic/scrollbar-buttondown-down.png" : "/images/skin/classic/scrollbar-buttondown-up.png")
    } //incrementControl: Image

    corner: Item {
    } // corner: Item

    frame: TibiaFrame1PixelDown {
      id: backgroundImage
      //anchors.fill: parent
    } //frame: TibiaFrame1PixelDown
    padding.top: 1 //1==backgroundImage.borderWidth need to overwrite this value to allow the frame to be shown even if heaterVisible==true
    padding.bottom: 1
    padding.left: 1
    padding.right: 1

    itemDelegate: TibiaText {
      text: styleData.value
      styleType: styleData.selected ? "TextFieldTextSelected" : "TextFieldText"
      anchors.fill: parent
      anchors.leftMargin: TibiaStyle.marginNarrow
      anchors.rightMargin: TibiaStyle.marginRelated
      elide: styleData.elideMode
      wrapMode: Text.Wrap
      tooltipMaxWidth: TibiaStyle.tooltipRestrictedWidth
      horizontalAlignment: styleData.textAlignment
      //see texthelper.cpp:15 and http://doc.qt.io/qt-5/qml-qtquick-text.html#elide-prop
      textFormat: text.indexOf("\x9C") != -1 ? Text.PlainText
                                             : Text.StyledText

      TibiaVerticalSeparator {
        visible: tableView.headerVisible && tableView.columnCount > 1
                 && styleData.column < tableView.columnCount-1
        anchors { top: parent.top; bottom: parent.bottom; left: parent.right; leftMargin: 3 }
      } // TibiaVerticalSeparator
    } //itemDelegate: TibiaText

    rowDelegate: TibiaTableViewRowDelegate {
      height: tableView.rowHeight
      alternatingRowColors: tableView.alternatingRowColors
    } //rowDelegate: TibiaTableViewRowDelegate

    headerDelegate: Rectangle {
      height: TibiaStyle.tableViewHeaderHeight
      color: TibiaStyle.tableViewHeaderBackgroundColor

      TibiaText {
        id: textItem
        text: styleData.value
        anchors.fill: parent
        anchors.leftMargin: 2
        anchors.rightMargin: TibiaStyle.marginRelated
        anchors.bottomMargin: 2
        styleType: "Dialog"
        horizontalAlignment: styleData.textAlignment
      } //TibiaText

      Image {
        id: sortIndicator
        smooth: false
        anchors.right: parent.right
        anchors.rightMargin: 3
        anchors.verticalCenter: textItem.verticalCenter
        anchors.verticalCenterOffset: control.sortIndicatorOrder == Qt.DescendingOrder ? -1 : 0

        visible: control.sortIndicatorVisible
              && control.sortIndicatorColumn == styleData.column
        rotation: control.sortIndicatorOrder == Qt.DescendingOrder ? 0 : 180
        source: "/images/icon-arrow7x7-down.png"
      } //Image

      TibiaVerticalSeparator {
        visible: styleData.column < tableView.columnCount-1 && textItem.text.length > 0
        anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
      } //TibiaVerticalSeparator

      TibiaHorizontalSeparator {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
      } //TibiaHorizontalSeparator
    } //headerDelegate: Rectangle

  } //style: TableViewStyle
} //TableView
