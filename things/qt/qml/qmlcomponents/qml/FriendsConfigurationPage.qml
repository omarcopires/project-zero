import QtQuick
import QtQuick.Layouts

import qmlcomponents
import qmlenumvalues

ListView {
  id: root
  property var controller: null
  property var initialFocusItem: null

  model: controller != null ? controller.friendSettings : null
  spacing: TibiaStyle.marginUnrelated

  interactive: false //prevent flick behavior on touch screens
  boundsBehavior: Flickable.StopAtBounds

  delegate: Item {
    width: root.width
    height: settingBox.height

    TibiaPanel2PixelUpFilledWithCaption {
      id: settingBox
      anchors { left: parent.left; right: parent.right; top: parent.top; }

      caption: {
        if (model != null && model.settingType == SocialDialogController.CloseFriend) {
          return qsTrId("friends_friendgroup_closefriends");
        } else if (model != null && model.settingType == SocialDialogController.Friend) {
          return qsTrId("friends_friendgroup_friends")
        } else if (model != null && model.settingType == SocialDialogController.Contact) {
          return qsTrId("friends_friendgroup_contacts");
        } else if (model != null && model.settingType == SocialDialogController.NoFriend) {
          return qsTrId("friends_friendgroup_nofriends");
        } else {
          return qsTrId("dummy_unknown");
        }
      }

      ColumnLayout {
        Layout.leftMargin: TibiaStyle.marginRelated

        TibiaCheckBox {
          id: showCharacterInfoCheckbox
          text: qsTrId("friends_show_character_info")
          tooltipText: qsTrId("friends_show_character_info_tooltip")
          shouldBeChecked: model != null && model.showCharacterInfo
          enabled: model != null && model.enableShowCharacterInfo;

          onClicked: {
            if (controller != null && model != null) {
              controller.setFriendGroupSetting(model.settingType, showCharacterInfoCheckbox.checked,
                                               showAccountInfoCheckbox.checked, allowInspectCheckbox.checked);
            }
          }
        }

        TibiaCheckBox {
          id: showAccountInfoCheckbox
          text: qsTrId("friends_show_account_info")
          tooltipText: qsTrId("friends_show_account_info_tooltip")
          shouldBeChecked: model != null && model.showAccountInfo
          enabled: model != null && model.enableShowAccountInfo;

          onClicked: {
            if (controller != null && model != null) {
              controller.setFriendGroupSetting(model.settingType, showCharacterInfoCheckbox.checked,
                                               showAccountInfoCheckbox.checked, allowInspectCheckbox.checked);
            }
          }
        }

        TibiaCheckBox {
          id: allowInspectCheckbox
          text: qsTrId("friends_allow_inspect")
          tooltipText: qsTrId("friends_allow_inspect_tooltip")
          shouldBeChecked: model != null && model.allowInspect
          enabled: model != null && model.enableAllowInspect;

          onClicked: {
            if (controller != null && model != null) {
              controller.setFriendGroupSetting(model.settingType, showCharacterInfoCheckbox.checked,
                                               showAccountInfoCheckbox.checked, allowInspectCheckbox.checked);
            }
          }
        }
      }
    } // TibiaPanel2PixelFilledWithCaption
  } // delegate Item
} // GridView
