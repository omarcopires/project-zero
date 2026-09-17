import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "qrc:/qt/qml/qmlcomponents/qml"

Item {
  id: colorGrid
  property int selectedColorIndex: 0 //Qt.rgba(1.0, 1.0, 1.0, 1.0)
  property color selectedColor: "white"
  property var colors: [Qt.rgba(1.0, 0.0, 0.0, 1.0), Qt.rgba(0.0, 1.0, 0.0, 1.0), Qt.rgba(0.0, 0.0, 1.0, 1.0)]
  implicitWidth: grid.width
  implicitHeight: grid.height

  onSelectedColorIndexChanged: {
    // restore "checked" status - for some reason its binding to colorGrid.selectedColor gets broken when assigning to selectedColor
    let newColorIndex = Math.max(Math.min(selectedColorIndex, colors.length - 1), 0);
    if (selectedColorIndex != newColorIndex) {
      selectedColorIndex = newColorIndex;
    }
    for (var i = 0; i < colorButtonRepeater.count; i++) {
      colorButtonRepeater.itemAt(i).checked = (colorGrid.selectedColorIndex == i);
    }
    selectedColor = colors[selectedColorIndex];
  }

  Item {
    anchors.fill: parent
    GridLayout {
      id: grid
      columnSpacing: 0
      rowSpacing: 0
      columns: TibiaStyle.colorSelectionGridNumberOfColorsPerRow

      ButtonGroup {
        id: selectedColorExclusiveGroup
      } //ButtonGroup

      Repeater {
        id: colorButtonRepeater
        model: colorGrid.colors

        delegate: TibiaColorButton {
              id: colorButton
              buttonColor: modelData
              Layout.preferredWidth: 13
              Layout.preferredHeight: 13
              onCheckedChanged: {
                if (checked) {
                  colorGrid.selectedColorIndex = index;
                }
              }
              checked: (colorGrid.selectedColorIndex == index)
              ButtonGroup.group: selectedColorExclusiveGroup
              z: checked ? 1000 : 0
              Loader {
                sourceComponent: checked ? selectionRectangleComponent : undefined
                anchors.fill: parent
                anchors.margins: 0
              }
              Component {
                id: selectionRectangleComponent
                Rectangle {
                  color: "transparent"
                  border.color: "white"
                  border.width: 1
                }
              }
            } //TibiaColorButton
      } //Repeater

    } //GridLayout
    MouseArea {
      acceptedButtons: Qt.LeftButton
      anchors.fill: parent
      onPositionChanged: (mouse) => {
        checkColorButtonAtPosition(mouse.x, mouse.y);
      }
      onPressed: (mouse) => {
        checkColorButtonAtPosition(mouse.x, mouse.y);
      }
      onReleased: (mouse) => {
        checkColorButtonAtPosition(mouse.x, mouse.y);
      }
      function checkColorButtonAtPosition(x, y) {
        x = Math.max(0, Math.min(x, grid.width - 2));
        y = Math.max(0, Math.min(y, grid.height - 2));
        let foundButton = grid.childAt(x, y);
        if (foundButton && foundButton instanceof TibiaColorButton) {
          foundButton.checked = true;
        }
      }
    }
  }
} //Item
