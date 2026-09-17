import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qmlcomponents
import qmlenumvalues
import QtQuick.LegacyControls


ColumnLayout {
  id: root
  property var controller: null
  property var initialFocusItem: invitesTable

  TibiaFrame2PixelUpFilled {
    Layout.fillWidth: true
    Layout.preferredHeight: 36
    Layout.alignment: Qt.AlignTop

    RowLayout {
      anchors.fill: parent
      anchors.margins: TibiaStyle.marginRelated

      spacing: TibiaStyle.marginUnrelated * 2
      Layout.bottomMargin: TibiaStyle.marginUnrelated

      ButtonGroup {
        id: tableSelectionGroup

        checkedButton: {
          if (controller != null && controller.shownListType == FriendsInvitesController.ReceivedInvites) {
            return receivedInvitesButton;
          } else if (controller != null && controller.shownListType == FriendsInvitesController.SentInvites) {
            return sentInvitesButton;
          } else if (controller != null && controller.shownListType == FriendsInvitesController.Blacklist) {
            return blacklistButton;
          } else {
            return null;
          }
        }
      }

      Item {
        Layout.fillWidth: true
      }

      TibiaRadioButton {
        id: receivedInvitesButton
        text: qsTrId("friends_received_invites_header").arg(controller != null ? controller.receivedInvites.count : 0)
        ButtonGroup.group: tableSelectionGroup

        onClicked: {
          if (controller != null) {
            controller.shownListType = FriendsInvitesController.ReceivedInvites;
          }
        }
      } // TibiaRadioButton

      TibiaRadioButton {
        id: sentInvitesButton
        text: qsTrId("friends_sent_invites_header").arg(controller != null ? controller.sentInvites.count : 0)
        ButtonGroup.group: tableSelectionGroup

        onClicked: {
          if (controller != null) {
            controller.shownListType = FriendsInvitesController.SentInvites;
          }
        }
      } // TibiaRadioButton

      TibiaRadioButton {
        id: blacklistButton
        text: qsTrId("friends_blacklist_header").arg(controller != null ? controller.blacklist.count : 0)
        ButtonGroup.group: tableSelectionGroup

        onClicked: {
          if (controller != null) {
            controller.shownListType = FriendsInvitesController.Blacklist;
          }
        }
      } // TibiaRadioButton

      Item {
        Layout.fillWidth: true
      }
    } // RowLayout
  } // TibiaFrame2PixelUpFilled

  TibiaTableView {
    id: invitesTable
    Layout.fillWidth: true
    Layout.fillHeight: true
    horizontalScrollBarPolicy: ScrollBar.AlwaysOff
    headerVisible: true
    model: {
      if (controller != null && controller.shownListType == FriendsInvitesController.ReceivedInvites) {
        return controller.receivedInvites;
      } else if (controller != null && controller.shownListType == FriendsInvitesController.SentInvites) {
        return controller.sentInvites;
      } else {
        return null;
      }
    }
    visible: {
      return controller != null && (
        controller.shownListType == FriendsInvitesController.ReceivedInvites ||
        controller.shownListType == FriendsInvitesController.SentInvites
      )
    }

    TableViewColumn {
      role: "maincharName"
      title: qsTrId("friends_invites_mainchar_name")
      width: 290
      movable: false
      resizable: false

      delegate: RowLayout {
        anchors { left: parent.left; right: parent.right }
        spacing: TibiaStyle.marginNarrow

        TibiaText {
          id: mainCharTitle
          Layout.rightMargin: TibiaStyle.marginNarrow
          Layout.leftMargin: TibiaStyle.marginNarrow
          text: model != null ? model.title : ""
          visible: text.length != 0
          styleType: "Caption"
        } //TibiaText

        Item {
          Layout.fillWidth: true
          Layout.preferredHeight: mainCharName.height
          Layout.leftMargin: mainCharTitle.visible ? 0 : TibiaStyle.marginNarrow

          TibiaText {
            id: mainCharName
            anchors { left: parent.left; right: parent.right }
            text: styleData.value

            color: styleData.selected ? TibiaStyle.textFieldSelectionTextColor
                                      : TibiaStyle.textFieldTextColor
          } //TibiaText

        } //Item

        TibiaButton {
          imageSourceUp: "/images/icon-edit.png"
          visible: styleData.selected
          Layout.preferredHeight: mainCharName.height
          Layout.preferredWidth: mainCharName.height

          onClicked: {
            if (controller != null && controller.shownListType == FriendsInvitesController.ReceivedInvites) {
              controller.showContextMenuForReceivedInvite(model.accountID);
            } else if (controller != null && controller.shownListType == FriendsInvitesController.SentInvites) {
              controller.showContextMenuForSentInvite(model.accountID);
            }
          }
        } // TibiaButton

        TibiaVerticalSeparator {
          Layout.fillHeight: true
        } // TibiaVerticalSeparator
      } // delegate RowLayout
    } // TableViewColumn

    TableViewColumn {
      role: "inviterName"
      title: qsTrId("friends_invites_inviter_name")
      width: 260
      movable: false
      resizable: false
    }

    TableViewColumn {
      role: "inviteDate"
      title: qsTrId("date_column_header")
      movable: false
      resizable: false
    }
  } // TibiaTableView

  TibiaTableView {
    id: blacklistTable
    Layout.fillWidth: true
    Layout.fillHeight: true
    horizontalScrollBarPolicy: ScrollBar.AlwaysOff
    headerVisible: true
    model: controller != null ? controller.blacklist : null
    visible: controller != null && controller.shownListType == FriendsInvitesController.Blacklist

    TableViewColumn {
      role: "maincharName"
      title: qsTrId("friends_invites_mainchar_name")
      width: 480
      movable: false
      resizable: false

      delegate: RowLayout {
        spacing: TibiaStyle.marginNarrow

        TibiaText {
          id: mainCharName
          text: styleData.value
          Layout.fillWidth: true
          color: styleData.selected
            ? TibiaStyle.textFieldSelectionTextColor
            : TibiaStyle.textFieldTextColor
          Layout.leftMargin: TibiaStyle.marginNarrow
        }

        TibiaButton {
          imageSourceUp: "/images/icon-edit.png"
          visible: styleData.selected
          Layout.preferredHeight: mainCharName.height
          Layout.preferredWidth: mainCharName.height

          onClicked: {
            if (controller != null) {
              controller.showContextMenuForBlacklistedAccount(model.accountID);
            }
          }
        } // TibiaButton

        TibiaVerticalSeparator {
          Layout.fillHeight: true
        } // TibiaVerticalSeparator
      } // delegate RowLayout
    } // TableViewColumn

    TableViewColumn {
      role: "blacklistDate"
      title: qsTrId("friends_blacklist_date")
      movable: false
      resizable: false
    }
  } // TibiaTableView
} // ColumnLayout
