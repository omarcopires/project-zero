import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qmlcomponents

import QtQuick.LegacyControls



TibiaDialog {
  id: root
  caption: "Important Balancing News"
  width: 700

  property var controller: null
  property var dialogData: controller != null ? controller.dialogData : null
  property string prefixText: dialogData != null ? dialogData.prefixText : ""
  property string postfixText: dialogData != null ? dialogData.postfixText : ""
  property var monstersData: dialogData != null ? dialogData.monsters : []
  property string compareDate: dialogData != null ? dialogData.compareDate: ""

  ColumnLayout {
    width: parent.width
    height: 400

    ColumnLayout {
      id: innerColumnLayout
      Layout.fillWidth: true
      spacing: 0
      TibiaText {
        text: prefixText
        Layout.fillWidth:  true
        wrapMode: Text.Wrap
        textFormat: Text.RichText
        onLinkActivated: Qt.openUrlExternally(link)
        onLinkHovered: {
          if (link == "") {
            tibiaMouseCursorController.setDefaultCursor();
          } else {
            tibiaMouseCursorController.setPointingHand(true);
          }
        }
      }
      TibiaTableView {
        id: tableView
        model: monstersData
        Layout.fillWidth:  true
        Layout.fillHeight: true
//        Layout.topMargin: TibiaStyle.marginUnrelated

        flickableItem.interactive: false
        horizontalScrollBarPolicy: ScrollBar.AlwaysOff
        headerVisible: true
        focus: false
        selectionMode: SelectionMode.NoSelection;

        rowDelegate: Rectangle {
          height: 64 + 60
          color: styleData.selected ? TibiaStyle.tableViewSelectionColor : (styleData.alternate ? TibiaStyle.tableViewAlternateBackgroundColor : TibiaStyle.tableViewItemBackgroundColor)
        } // rowDelegate

        selection.onSelectionChanged: {
          if (selection.count > 0) {
            selection.clear();
          } 
        } //selection.onSelectionChanged

        headerDelegate: Rectangle {
          height: TibiaStyle.tableViewHeaderHeight * 3 - 6
          color: TibiaStyle.tableViewHeaderBackgroundColor

          TibiaText {
            id: textItem
            text: styleData.value
            anchors.fill: parent
            anchors.leftMargin: 2
            anchors.rightMargin: TibiaStyle.marginRelated
            anchors.bottomMargin: 2
            horizontalAlignment: Text.AlignHCenter
            styleType: "Dialog"
            wrapMode: Text.Wrap
          } //TibiaText

          TibiaVerticalSeparator {
            visible: styleData.column < tableView.columnCount-1 && textItem.text.length > 0
            anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
          } //TibiaVerticalSeparator

          TibiaHorizontalSeparator {
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
          } //TibiaHorizontalSeparator
        } //headerDelegate: Rectangle

        TableViewColumn {
          id: monsterColumn
          title: "Monster"
          width: 90
          movable: false
          resizable: false
          delegate: ColumnLayout {
            TibiaText {
              Layout.maximumWidth: parent.width
              Layout.alignment: Qt.AlignHCenter
              Layout.topMargin: TibiaStyle.marginRelated
              wrapMode: Text.Wrap
              text: raceAppearanceInstanceRenderer.raceName
              horizontalAlignment: Text.AlignHCenter
            }
            RaceAppearanceInstanceRenderer {
              id: raceAppearanceInstanceRenderer
              Layout.preferredWidth: 64
              Layout.preferredHeight: 64
              Layout.alignment: Qt.AlignHCenter
              raceID: modelData.race
              scaleFactor: 1.0
              smoothTextureFiltering: false
              autofit: true
              moving: true
            } //RaceAppearanceInstanceRenderer
          }
        }
        TableViewColumn {
          title: "Change in Drop Chance Compared to " + compareDate
          width: (tableView.width - monsterColumn.width - 12) / 4
          movable: false
          resizable: false
          delegate: ColumnLayout {
            TibiaText {
              text: modelData.dropChanceChange
              Layout.fillWidth:  true
              wrapMode: Text.Wrap
              textFormat: Text.RichText
              horizontalAlignment: Text.AlignHCenter
            } 
          }
        }
        TableViewColumn {
          title: "Drop Chance Compared to Pre-Rebalancing"
          width: (tableView.width - monsterColumn.width - 12) / 4
          movable: false
          resizable: false
          delegate: ColumnLayout {
            TibiaText {
              text: modelData.dropChanceChangeBefore
              Layout.fillWidth:  true
              wrapMode: Text.Wrap
              textFormat: Text.RichText
              horizontalAlignment: Text.AlignHCenter
            } 
          }
        }
        TableViewColumn {
          title: "Change in XP Compared to " + compareDate
          width: (tableView.width - monsterColumn.width - 12) / 4
          movable: false
          resizable: false
          delegate: ColumnLayout {
            TibiaText {
              text: modelData.xpChange
              Layout.fillWidth:  true
              wrapMode: Text.Wrap
              textFormat: Text.RichText
              horizontalAlignment: Text.AlignHCenter
            } 
          }
        }
        TableViewColumn {
          title: "Current XP (Pre-Rebalancing XP)"
          width: (tableView.width - monsterColumn.width - 12) / 4
          movable: false
          resizable: false
          delegate: ColumnLayout {
            TibiaText {
              text: modelData.xpChangeBefore
              Layout.fillWidth:  true
              wrapMode: Text.Wrap
              textFormat: Text.RichText
              horizontalAlignment: Text.AlignHCenter
            } 
          }
        }
      }
      TibiaText {
        text: postfixText
        Layout.fillWidth:  true
        wrapMode: Text.Wrap
        textFormat: Text.RichText
      }
      Item {
        Layout.fillHeight: true
      }
    }
    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } //TibiaHorizontalSeparator

    RowLayout {
      Layout.alignment: Qt.AlignRight
      spacing: TibiaStyle.marginRelated

      TibiaCheckBox {
        Layout.alignment: Qt.AlignLeft
        id: showNotAgain
        text: qsTrId("Don't show again")
        shouldBeChecked: controller != null && !controller.showAgain
        enabled: true

        onClicked: {
          if (controller != null) {
            controller.showAgain = !checked;
            shouldBeChecked = checked;
          }
        }
      } // TibiaCheckBox

      Item {
        Layout.fillWidth: true
      }

      TibiaButton {
        text: qsTrId("close")
        onClicked: { if (controller) { controller.onOKClicked(); } } 
      } //TibiaButton
    }
  } // ColumnLayout
} // TibiaDialog
