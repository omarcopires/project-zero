import QtQuick

FocusScope {
  implicitHeight: TibiaStyle.optionLineFrameHeight //22 same distance to the checkbox form all 3 sideds
  implicitWidth: checkBox.width + 2*5 + (frame.guiHelpItem.visible ? frame.guiHelpItem.width + TibiaStyle.marginRelated : 0) //same disteand from the left as from the top
  property alias checkboxEnabled: checkBox.enabled

  property alias text:               checkBox.text
  property alias checked:            checkBox.checked
  property alias checkState:         checkBox.checkState
  property alias hovered:            checkBox.hovered
  property alias pressed:            checkBox.pressed
  property alias styleType:          checkBox.styleType
  property alias shouldBeChecked:    checkBox.shouldBeChecked
  property alias guiHelpText:        frame.guiHelpText
  property alias guiHelpMarkColor:   frame.guiHelpMarkColor
  property alias guiHelpUseRichText: frame.guiHelpUseRichText

  signal clicked()

  TibiaFrame1PixelDownWithGuiHelp {
    id: frame
    anchors.fill: parent
    guiHelpAlignVerticalCenter: true

    MouseArea {
      anchors.fill: parent
      z: -1

      onClicked: {
        checkBox.checked = !checkBox.checked
      } //onClicked
    } //MouseArea
  } //TibiaFrame1PixelDownWithGuiHelp

  TibiaCheckBox {
    id:checkBox
    anchors { margins: 5; left: parent.left; verticalCenter: parent.verticalCenter }
    Component.onCompleted: clicked.connect(parent.clicked)
  } //TibiaCheckBox
} //FocusScope
