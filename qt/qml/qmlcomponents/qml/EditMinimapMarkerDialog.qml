import QtQuick
import QtQuick.Controls
import QtQuick.Layouts



TibiaDialog {
  id: enterTextDialog
  caption: qsTrId("editminimapmark_caption")
  width: 285

  property QtObject controller: null
  property alias text: enteredTextField.text
  property int symbolID: 0


  function sendEnteredDataToController() {
    if(null != controller) {
      controller.onOkClicked(enteredTextField.text, symbolID);
    }
  } //function sendEnteredDataToController()


  onReturnPressedFunction: sendEnteredDataToController
  onCancelPressedFunction: controller!=null ? controller.onCancelClicked : null
  initialFocusItem: enteredTextField

  ColumnLayout {
    id: columns
    anchors { left: parent.left; right: parent.right}
    spacing: TibiaStyle.marginRelated


    TibiaText {
      Layout.fillWidth: true
      wrapMode: Text.Wrap
      text: qsTrId("editminimapmark_description")
      styleType: "Dialog"
    } //TibiaText

    TibiaTextField{
      id: enteredTextField
      Layout.fillWidth: true
      KeyNavigation.tab: enteredTextField
      focus:true
      maximumLength: 100
    } //TibiaTextField


    TibiaText {
      Layout.fillWidth: true
      Layout.topMargin: TibiaStyle.marginRelated //double the margin from marginRelated to Unrelated
      wrapMode: Text.Wrap
      text: qsTrId("editminimapmark_select_type")
      styleType: "Dialog"
    } //TibiaText

    GridLayout {
      columnSpacing: TibiaStyle.marginRelated
      rowSpacing: TibiaStyle.marginRelated
      columns: TibiaStyle.numberOfMinimapMarkersPerSelectRow

      ButtonGroup {
        id: selectedMinimapMarker
      } //ButtonGroup

      Repeater {
        model: TibiaStyle.numberOfMinimapMarkers

        delegate: TibiaIconSelectionButton {
          iconPath: "image://minimap-markers/" + modelData
          width: 16
          height: 16
          onClicked: { symbolID = modelData; }
          checked: (modelData == symbolID)
          ButtonGroup.group: selectedMinimapMarker
        } //TibiaIconButton
      } //Repeater

    } //RowLayout


    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } //TibiaHorizontalSeparator


    RowLayout {
      Layout.fillWidth: true
      spacing: TibiaStyle.marginUnrelated

      Item {
        Layout.fillWidth: true
      } //Item

      TibiaButton {
        id: okButton
        text: qsTrId("ok")
        onClicked: { sendEnteredDataToController(); }
      } //TibiaButton

      TibiaButton {
        id: cancelButton
        text: qsTrId("cancel")
        onClicked: controller!=null ?  controller.onCancelClicked() : undefined
      } //TibiaButton
    } //RowLayout

  }//ColumnLayout
} //TibiaDialog
