import QtQuick
import QtQuick.Layouts
import QtQuick.LegacyControls



TibiaDialog {
  id: openChatChannelDialog
  caption: qsTrId("openchannel_caption")
  width: 250

  property QtObject controller: null
  property alias channelsModel: channelList.model
  property int selectedChannelRowIndex: -1

  function openSelectedOrPrivteChannel() {
    if(null != controller) {
      if(privateMessageRecipient.text != "") {
        //recipient for private message is given
        controller.onOpenPrivateChannelTo(privateMessageRecipient.text);
      } else if(selectedChannelRowIndex != -1) {
        //no recipient but a channel is selected
        controller.onOpenChannelFromList(selectedChannelRowIndex);
      } else {
        //noting selected just cancel
        controller.onCancelClicked();
      }
    }
  } //function openSelectedOrPrivteChannel

  onReturnPressedFunction: openSelectedOrPrivteChannel
  onCancelPressedFunction: controller!=null ? controller.onCancelClicked : null
  initialFocusItem: privateMessageRecipient

  ColumnLayout {
    id: columns
    anchors { left: parent.left; right: parent.right}
    spacing: TibiaStyle.marginRelated

    TibiaText {
      text:  qsTrId("openchannel_description")
      styleType: "Dialog"
    } //TibiaText

    TibiaTableView {
      id: channelList
      objectName: "channelList"
      Layout.fillWidth: true
      Layout.preferredHeight: 144+2 //9entries*16pixel +2*"1pixel-frame"
      headerVisible: false

      Keys.forwardTo: [privateMessageRecipient]

      selection.onSelectionChanged: {
        //ass current row is not relayable we use selection
        channelList.selection.forEach( function(rowIndex) {selectedChannelRowIndex = rowIndex;} );
      } //selection.onSelectionChanged

      onFocusChanged: {
        if(focus) {
          privateMessageRecipient.focus = true;
        }
      } // onFocusChanged

      TableViewColumn{role: "modelData "} //modelData provieded by string list

      onDoubleClicked: {
        if(null != controller) {
          controller.onOpenChannelFromList(selectedChannelRowIndex);
        }
      }
    } //TibiaTableView

    Item { //double spacing dummy
      Layout.fillWidth: true
      Layout.preferredHeight: 0
    } //Item


    TibiaText {
      text: qsTrId("openchannel_private_channel_name")
      styleType: "Dialog"
    } //TibiaText

    TibiaTextField{
      id: privateMessageRecipient
      Layout.fillWidth: true

      maximumLength: TibiaStyle.maxCharacterNameLength

      KeyNavigation.tab: privateMessageRecipient

      focus: true
      Component.onCompleted: {
        forceActiveFocus();
      } //Component.onCompleted
    } //TibiaTextField


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
        id: openButton
        text: qsTrId("openchannel_open_button")
        onClicked: { openSelectedOrPrivteChannel(); }

      } //TibiaButton

      TibiaButton{
        id: cancelButton
        text: qsTrId("cancel")
        onClicked: controller!=null ?  controller.onCancelClicked() : undefined
      } //TibiaButton
    } //RowLayout
  }//ColumnLayout
} //TibiaDialog
