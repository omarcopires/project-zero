import QtQuick

import qmlcomponents

Rectangle {  
  property int rowHeight: TibiaStyle.tableViewRowHeight
  property bool alternatingRowColors: true

  height: rowHeight
  color: styleData.selected
    ? TibiaStyle.tableViewSelectionColor
    : alternatingRowColors
      ? styleData.alternate
        ? TibiaStyle.tableViewAlternateBackgroundColor
        : TibiaStyle.tableViewItemBackgroundColor
      : TibiaStyle.tableViewBackgroundColor
}