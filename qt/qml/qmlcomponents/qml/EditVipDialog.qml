import QtQuick
import QtQuick.Controls
import QtQuick.Layouts



TibiaDialog {
  id: enterTextDialog
  caption: qsTrId("edit_vip_caption")
  width: 285


  property QtObject controller: null
  property string vipName: "Default Vip Name"
  property int vipIconID: 0
  property string vipDescription: ""
  property bool vipNotify: false
  property var vipGroupInfos: null

  onVipDescriptionChanged: {
    descriptionTextArea.text  = vipDescription;
    descriptionTextArea.cursorPosition = vipDescription.length;
  } //onVipDescriptionChanged

  function sendUpdatedVipData() {
   if(null != controller) {
     controller.onOkClicked(vipIconID, descriptionTextArea.text, notifyCheckBox.checked);
   }
  } //function sendEnteredText()


  onReturnPressedFunction: sendUpdatedVipData
  onCancelPressedFunction: controller!=null ? controller.onCancelClicked : null
  initialFocusItem: descriptionTextArea

  ColumnLayout {
    id: columns
    anchors { left: parent.left; right: parent.right}
    spacing: TibiaStyle.marginUnrelated

    ColumnLayout {
      Layout.fillWidth: true
      spacing: TibiaStyle.marginRelated

      TibiaText {
        id: vipNameText
        Layout.fillWidth: true
        text: vipName
      } //TibiaText

      TibiaHorizontalSeparator {
        Layout.fillWidth: true
      } //TibiaHorizontalSeparator
    } //ColumnLayout

    ColumnLayout{
      Layout.fillWidth: true
      spacing: TibiaStyle.marginRelated

      TibiaText {
        Layout.fillWidth: true
        text: qsTrId("edit_vip_select_type")
      } //TibiaText


      RowLayout {
        spacing: TibiaStyle.marginRelated

        ButtonGroup {
          id: selectedVipIcon
        } //ButtonGroup

        Repeater {
          model: TibiaStyle.numberOfVipIcons

          delegate: TibiaIconSelectionButton {
            iconPath: "image://vip-icons/" + modelData
            onClicked: { vipIconID = modelData; }
            checked: (modelData == vipIconID)
            ButtonGroup.group: selectedVipIcon
          } //TibiaIconButton
        } //Repeater
      } //RowLayout

    } //ColumnLayout


    ColumnLayout{
      Layout.fillWidth: true
      spacing: TibiaStyle.marginRelated

      TibiaText {
        Layout.fillWidth: true
        text: qsTrId("edit_vip_description")
      } //TibiaText


      TibiaTextArea {
        id: descriptionTextArea
        Layout.fillWidth: true
        Layout.preferredHeight: 50
        textFormat: TextEdit.PlainText
        maximumLength: TibiaStyle.maxDescriptionLength

        KeyNavigation.tab: descriptionTextArea
        focus:true
      } //TibiaTextField
    } //ColumnLayout

    TibiaMenuOptionCheckBox {
      id: notifyCheckBox
      text: qsTrId("edit_vip_notify_on_login")
      Layout.fillWidth: true
      checked: vipNotify
    }

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } //TibiaHorizontalSeparator

    ColumnLayout{
      Layout.fillWidth: true
      spacing: TibiaStyle.marginRelated

      TibiaText {
        Layout.fillWidth: true
        text: qsTrId("edit_vip_groups_caption")
      } //TibiaText

      ListView {
        id: vipGroupsList
        spacing: TibiaStyle.marginNarrow

        Layout.fillWidth: true
        Layout.preferredHeight: contentHeight
        model: vipGroupInfos

        delegate: TibiaCheckBox {
          width: vipGroupsList.width - 7
          text: modelData.groupName
          checked: modelData.selected

          Binding {
            target: modelData
            property: "selected"
            value: checked
          } //Binding
        } //VipGroupEntry
      } // ListView
    } //ColumnLayout

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } //TibiaHorizontalSeparator

    RowLayout {
      Layout.fillWidth: true
      spacing: TibiaStyle.marginUnrelated

      Item {
        Layout.fillWidth: true
      } //Item

      TibiaButton{
        id: okButton
        text: qsTrId("ok")
        onClicked: { sendUpdatedVipData(); }
      } //TibiaButton

      TibiaButton{
        id: cancelButton
        text: qsTrId("cancel")
        onClicked: controller!=null ?  controller.onCancelClicked() : undefined
      } //TibiaButton
    } //RowLayout

  }//ColumnLayout
} //TibiaDialog
