import QtQuick
import QtQuick.Layouts
import qmlcomponents

BorderImage {
  id: root
  property var playerStatesList: null
  property int maxColumns: (root.width - root.border.left - root.border.right - root.iconSpacing) / 10 // One icon is 9x9, plus 1 pixel spacing.
  property int maxRows: (root.height - root.border.top - root.border.bottom - root.iconSpacing) / 10
  readonly property int iconSpacing: 1
  readonly property int borderWidth: 1
  property var _helperModel: null


  property bool fillColumns: false

  onPlayerStatesListChanged: {
    if (playerStatesList) {
      _helperModel = AbstractItemModelHelper.wrapInHelperProxyModel(playerStatesList);
    } else {
      _helperModel = null;
    }
  }

  border { top: root.borderWidth; right: root.borderWidth; bottom: root.borderWidth; left: root.borderWidth }
  source: "/images/inventory-states-bar.png"
  horizontalTileMode: BorderImage.Repeat
  verticalTileMode: BorderImage.Repeat
  smooth: false

  GridLayout   {
    id: layout
    anchors.left: parent.left
    anchors.top: parent.top
    anchors.margins: root.iconSpacing + root.borderWidth

    columnSpacing: root.iconSpacing
    rowSpacing: root.iconSpacing
    columns: root.maxColumns
    rows: root.maxRows

    flow: root.fillColumns ? GridLayout.TopToBottom : GridLayout.LeftToRight

    Repeater {
      id: stateIconRepeater
      property int modelIconCount: _helperModel ? _helperModel.rowCount() : 0
      model: Math.min(maxRows*maxColumns, modelIconCount)

      Image {
        property var entry: _helperModel.sourceItemDataByRowIndex(modelData)
        Layout.alignment: Qt.AlignTop | Qt.AlignLeft
        source: entry.imageSource ?? undefined
        smooth: false
        Tooltip {
          anchors.fill: parent
          text: entry.tooltip ?? ""
          useRichText: true
        } //Tooltip
      }
    } // Repeater
  } // GridLayout
} // BorderImage
