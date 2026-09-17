import QtQuick
import QtQuick.Layouts



TibiaDialog {
  id: enterTextDialog
  caption: qsTrId("white_black_list_caption")
  width: 570

  property QtObject controller: null
  property var blacklistSource: null
  property var whitelistSource: null

  onReturnPressedFunction: sendUpdateWhiteBlacklist
  onCancelPressedFunction: controller!=null ? controller.onCancelClicked : null
  initialFocusItem: blacklistTableView

  function sendUpdateWhiteBlacklist() {
    if(controller) {
      //if editing force the active focus away from the editing item
      blacklistTableView.focus = false;
      blacklistTableView.forceActiveFocus();

      //only call onOkClicked if edting was finished
      controller.onOkClicked();
    }
  } //function sendUpdateWhiteBlacklist()

  ColumnLayout {
    id: content
    property int contentWidth: width
    anchors { left: parent.left; right: parent.right}
    spacing: TibiaStyle.marginUnrelated

    RowLayout {
      Layout.fillWidth: true
      spacing: 0

      ////////////////////////////////////////////////////////////////
      //BLACKLIST
      ColumnLayout {
        Layout.fillWidth: false
        Layout.preferredWidth: Math.floor((content.contentWidth - TibiaStyle.marginUnrelated) * 0.5)
        spacing: TibiaStyle.marginRelated

        TibiaMenuOptionCheckBox {
          id: blacklistActive
          text: qsTrId("activate_blacklist_list")
          Layout.fillWidth: true
          checked: controller!=null ? controller.blacklistActive : false
          Binding {
            target: controller
            property: "blacklistActive"
            value: blacklistActive.checked
          }  //Binding
        } //TibiaMenuOptionCheckBox

        TibiaText {
          text: qsTrId("blacklist_cpation")
          Layout.topMargin: TibiaStyle.marginRelated
        }

        TibiaWhiteBlacklistTableView {
          id: blacklistTableView
          KeyNavigation.tab: whitelistTableView
          Layout.fillWidth: true
          Layout.preferredHeight: 115 //7 entries like old client

          model: blacklistSource

          permanentlyCheckbox: ignorePermanently
          permanenltyColor: TibiaStyle.textColors["IgnorePermanently"]
        } //TibiaWhiteBlacklistTableView

        RowLayout {
          Layout.fillWidth: true
          spacing: TibiaStyle.marginUnrelated

          TibiaMenuOptionCheckBox {
            id: ignorePermanently
            text: qsTrId("ignore_permanently")
            Layout.fillWidth: true
            checked: false
            enabled: blacklistTableView.selection.count > 0
            onCheckedChanged: {
              blacklistTableView.focus = false;
              blacklistTableView.forceActiveFocus();
              blacklistTableView.selection.forEach( function(rowIndex) { 
                                                      blacklistSource[rowIndex].permanently = checked;
                                                      } );
            } //onCheckedChanged
          } //TibiaMenuOptionCheckBox

          TibiaButton {
            text: qsTrId("add")
            onClicked: {
              if(controller != null) {
                blacklistTableView.enableAutoFocusHandling = false;
                controller.addNewBlacklistEntry();
                blacklistTableView.selectRow(blacklistTableView.rowCount -1);
                blacklistTableView.enableAutoFocusHandling = true;
              }
            } //onClicked
          } //TibiaButton

          TibiaButton {
            text: qsTrId("delete")
            onClicked: {
              if(controller != null) {
                var foundRowIndex = -1;
                blacklistTableView.selection.forEach( function(rowIndex) { foundRowIndex = rowIndex } );
                blacklistTableView.selection.clear();
                if (foundRowIndex != -1) {
                  controller.removeEntryAtIndexFromBlacklist(foundRowIndex);
                }
              }
            } //onCheckedChanged
          } //TibiaButton
        } //RowLayout

        TibiaText {
          text: qsTrId("gloabl_blacklisting_settings")
          Layout.topMargin: TibiaStyle.marginRelated
        }
        
        TibiaMenuOptionCheckBox {
          id: ignoreYelling
          text: qsTrId("ignore_yelling")
          Layout.fillWidth: true
          checked: controller!=null ? controller.ignoreYelling : false
          Binding {
            target: controller
            property: "ignoreYelling"
            value: ignoreYelling.checked
          }  //Binding
        } //TibiaMenuOptionCheckBox

        TibiaMenuOptionCheckBox {
          id: ignorePrivateMessages
          text: qsTrId("ignore_private_messages")
          Layout.fillWidth: true
          checked: controller!=null ? controller.ignorePrivateMessages : false
          Binding {
            target: controller
            property: "ignorePrivateMessages"
            value: ignorePrivateMessages.checked
          }  //Binding
        } //TibiaMenuOptionCheckBox

        Item {
          Layout.fillHeight: true
          Layout.topMargin: -TibiaStyle.marginRelated
        } //Item
      } //ColumnLayout
      //BLACKLIST
      ////////////////////////////////////////////////////////////////
      Item {
        //setting Layout.fillWidth true for both sides lead to unwanted formating issues 
        Layout.fillWidth: true
      } //Item
      ////////////////////////////////////////////////////////////////
      //WHITELIST
      ColumnLayout {
        Layout.fillWidth: false
        Layout.preferredWidth: Math.floor((content.contentWidth - TibiaStyle.marginUnrelated) * 0.5)
        spacing: TibiaStyle.marginRelated

        TibiaMenuOptionCheckBox {
          id: whitelistActive
          text: qsTrId("activate_whitelist_list")
          Layout.fillWidth: true
          checked: controller!=null ? controller.whitelistActive : false
          Binding {
            target: controller
            property: "whitelistActive"
            value: whitelistActive.checked
          }  //Binding
        } //TibiaMenuOptionCheckBox

        TibiaText {
          text: qsTrId("whitelist_cpation")
          Layout.topMargin: TibiaStyle.marginRelated
        } //TibiaText

        TibiaWhiteBlacklistTableView {
          id: whitelistTableView
          KeyNavigation.tab: blacklistTableView
          Layout.fillWidth: true
          Layout.preferredHeight: 115 //7 entries like old client

          model: whitelistSource

          permanentlyCheckbox: allowPermanently
          permanenltyColor: TibiaStyle.textColors["AllowPermanently"]
        } //TibiaWhiteBlacklistTableView

        RowLayout {
          Layout.fillWidth: true
          spacing: TibiaStyle.marginUnrelated

          TibiaMenuOptionCheckBox {
            id: allowPermanently
            text: qsTrId("allow_permanently")
            Layout.fillWidth: true
            checked: false
            enabled: whitelistTableView.selection.count > 0
            onCheckedChanged: {
              whitelistTableView.focus = false;
              whitelistTableView.forceActiveFocus();
              whitelistTableView.selection.forEach( function(rowIndex) { 
                                        whitelistSource[rowIndex].permanently = checked;
                                        } );
            } //onCheckedChanged
          } //TibiaMenuOptionCheckBox

          TibiaButton {
            text: qsTrId("add")
            onClicked: {
              if(controller != null) {
                whitelistTableView.enableAutoFocusHandling = false;
                controller.addNewWhitelistEntry();
                whitelistTableView.selectRow(whitelistTableView.rowCount -1);
                whitelistTableView.enableAutoFocusHandling = true;
              }
            } //onClicked
          } //TibiaButton

          TibiaButton {
            text: qsTrId("delete")
            onClicked: {
              if(controller != null) {
                var foundRowIndex = -1;
                whitelistTableView.selection.forEach( function(rowIndex) { foundRowIndex = rowIndex; } );
                whitelistTableView.selection.clear();
                if (foundRowIndex != -1) {
                  controller.removeEntryAtIndexFromWhitelist(foundRowIndex);
                }
              }
            } //onCheckedChanged
          } //TibiaButton
        } //RowLayout

        TibiaText {
          text: qsTrId("gloabl_whitelisting_settings")
          Layout.topMargin: TibiaStyle.marginRelated
        } //TibiaText
        
        TibiaMenuOptionCheckBox {
          id: allowVips
          text: qsTrId("allow_vip_messages")
          Layout.fillWidth: true
          checked: controller!=null ? controller.allowVips : false
          Binding {
            target: controller
            property: "allowVips"
            value: allowVips.checked
          } //Binding
        } //TibiaMenuOptionCheckBox

        Item {
          Layout.fillHeight: true
          Layout.topMargin: -TibiaStyle.marginRelated
        } //Item
      } //ColumnLayout
      //WHITELIST
      ////////////////////////////////////////////////////////////////
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
    
      TibiaButton{
        id: okButton
        text: qsTrId("ok")
        onClicked: { sendUpdateWhiteBlacklist(); } 
      } //TibiaButton
    
      TibiaButton{
        id: cancelButton
        text: qsTrId("cancel")
        onClicked: controller!=null ?  controller.onCancelClicked() : undefined 
      } //TibiaButton
    } //RowLayout
  
  }//ColumnLayout
} //TibiaDialog
