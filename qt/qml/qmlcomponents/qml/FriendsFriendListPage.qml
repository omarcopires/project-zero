import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qmlcomponents
import qmlenumvalues
import QtQuick.LegacyControls


Item {
  id: root
  property var controller: null
  property var initialFocusItem: friendList

  property var friendListModel: controller != null ? controller.friendList : null

  function friendGroupIDToCaption(friendGroup)
  {
    switch (friendGroup) {
      case SocialDialogController.CloseFriend:
        return qsTrId("friends_friendgroup_closefriends");
      case SocialDialogController.Friend:
        return qsTrId("friends_friendgroup_friends");
      case SocialDialogController.Contact:
        return qsTrId("friends_friendgroup_contacts");
    }
    return "";
  }

  ColumnLayout {
    anchors.fill: parent

    TibiaFrame2PixelUpFilled {
      Layout.fillWidth: true
      Layout.preferredHeight: 36
      Layout.alignment: Qt.AlignTop
      RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: TibiaStyle.marginUnrelated
        spacing: TibiaStyle.marginUnrelated * 2
        Item {
          Layout.fillWidth: true
        }

        ButtonGroup {
          id: showFilterGroup

          checkedButton: {
            if (controller != null) {
              if (controller.showFilter == FriendsFriendListController.ShowAll) {
                return showAllButton;
              } else if (controller.showFilter == FriendsFriendListController.ShowCloseFriends) {
                return showCloseFriendsButton;
              } else if (controller.showFilter == FriendsFriendListController.ShowFriends) {
                return showFriendsButton;
              } else if (controller.showFilter == FriendsFriendListController.ShowContacts) {
                return showContactsButton;
              }
            }
            return null;
          }
        }

        TibiaRadioButton {
          id: showAllButton
          ButtonGroup.group: showFilterGroup
          text: qsTrId("friends_friendlist_show_all_label")

          onClicked: {
            if (controller != null) {
              controller.showFilter = FriendsFriendListController.ShowAll;
            }
          }
        }
        TibiaRadioButton {
          id: showCloseFriendsButton
          ButtonGroup.group: showFilterGroup
          text: qsTrId("friends_friendlist_show_close_friends_label")

          onClicked: {
            if (controller != null) {
              controller.showFilter = FriendsFriendListController.ShowCloseFriends;
            }
          }
        }
        TibiaRadioButton {
          id: showFriendsButton
          ButtonGroup.group: showFilterGroup
          text: qsTrId("friends_friendlist_show_friends_label")

          onClicked: {
            if (controller != null) {
              controller.showFilter = FriendsFriendListController.ShowFriends;
            }
          }
        }
        TibiaRadioButton {
          id: showContactsButton
          ButtonGroup.group: showFilterGroup
          text: qsTrId("friends_friendlist_show_contacts_label")

          onClicked: {
            if (controller != null) {
              controller.showFilter = FriendsFriendListController.ShowContacts;
            }
          }
        }
        Item {
          Layout.fillWidth: true
        }
      }
    }
    TibiaTableView {
      id: friendList
      selectionMode: SelectionMode.SingleSelection
      Layout.fillHeight: true
      Layout.fillWidth: true
      KeyNavigation.tab: friendList
      model: friendListModel
      onModelChanged: {
        applyLastSelectedIndex();
      } //onModleChanged

      focus: true

      headerVisible: true

      Component.onCompleted: {
        forceActiveFocus();
      } //Component.onCompleted

      rowHeight: 66
      onRowHeightChanged: {
        applyLastSelectedIndex();
      } //onRowHeightChanged

      TableViewColumn {
        id: columnMainChar
        title: qsTrId("friends_friendlist_mainchar_name")
        resizable: false
        movable: false
        width: friendList.contentItem.width - columnLevel.width - columnVocation.width - columnWorld.width - columnFriendGroup.width
        delegate: RowLayout {
          anchors { left: parent.left; right: parent.right }
          spacing: TibiaStyle.marginRelated

          OutfitAppearanceInstanceRenderer {
            Layout.preferredHeight: 64
            Layout.preferredWidth: 64
            Layout.leftMargin: TibiaStyle.marginUnrelated

            outfitId: model != null ? model.outfitID : 0;
            headColor:   model != null ? model.outfitHeadColor : "black"
            torsoColor:  model != null ? model.outfitTorsoColor : "black"
            legsColor:   model != null ? model.outfitLegsColor : "black"
            detailColor: model != null ? model.outfitDetailColor : "black"
            firstAddOn:  model != null ? model.outfitFirstAddOn : false
            secondAddOn: model != null ? model.outfitSecondAddOn : false

            MouseArea {
              anchors.fill: parent
              hoverEnabled: true
              onEntered: {
                if (tibiaMouseCursorController != null) {
                  tibiaMouseCursorController.setPointingHand(true);
                }
              } //onEntered
              onExited: {
                if (tibiaMouseCursorController != null) {
                  tibiaMouseCursorController.setPointingHand(false);
                }
              } //onExited

              onClicked: {
                if (tibiaMouseCursorController != null) {
                  tibiaMouseCursorController.setPointingHand(false);
                }
                if (controller != null && model != null) {
                  controller.showAccountDetails(model.accountID);
                }
              } // onClicked
            } // MouseArea

          } //OutfitAppearanceInstanceRenderer

          ColumnLayout {
            spacing: TibiaStyle.marginRelated
            Layout.fillWidth: true

            Item {
              Layout.fillWidth: true
              Layout.preferredHeight: mainCharNameText.height
              TibiaText {
                id: mainCharNameText
                anchors { left: parent.left; right: parent.right }

                text: model ? model.maincharName : ""

                MouseArea {
                  anchors.fill: parent
                  hoverEnabled: true
                  onEntered: {
                    if (tibiaMouseCursorController != null) {
                      tibiaMouseCursorController.setPointingHand(true);
                    }
                  } //onEntered
                  onExited: {
                    if (tibiaMouseCursorController != null) {
                      tibiaMouseCursorController.setPointingHand(false);
                    }
                  } //onExited

                  onClicked: {
                    if (tibiaMouseCursorController != null) {
                      tibiaMouseCursorController.setPointingHand(false);
                    }
                    if (controller != null && model != null) {
                      controller.showAccountDetails(model.accountID);
                    }
                  } // onClicked
                } // MouseArea
              } //TibiaText

            } //Item

            TibiaText {
              Layout.fillWidth: true
              text: model ? model.title : ""
              visible: text.length != 0
              styleType: "Caption"
              MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                  if (tibiaMouseCursorController != null) {
                    tibiaMouseCursorController.setPointingHand(true);
                  }
                } //onEntered
                onExited: {
                  if (tibiaMouseCursorController != null) {
                    tibiaMouseCursorController.setPointingHand(false);
                  }
                } //onExited

                onClicked: {
                  if (tibiaMouseCursorController != null) {
                    tibiaMouseCursorController.setPointingHand(false);
                  }
                  if (controller != null && model != null) {
                    controller.showAccountDetails(model.accountID);
                  }
                } // onClicked
              } // MouseArea
            } //TibiaText
          } //ColumnLayout

          TibiaButton {
            Layout.preferredHeight: TibiaStyle.buttonHeightDefault
            Layout.preferredWidth: Layout.preferredHeight
            imageSource: "/images/icon-displayresults.png"

            onClicked: {
              if (tibiaMouseCursorController != null) {
                tibiaMouseCursorController.setPointingHand(false);
              }
              if (controller != null && model != null) {
                controller.showAccountDetails(model.accountID);
              }
            } // onClicked
          } //TibiaButton

          TibiaVerticalSeparator {
            Layout.fillHeight: true
          } // TibiaVerticalSeparator
        } //delegate: RowLayout
      } //TableViewColumn

      TableViewColumn {
        id: columnLevel
        title: qsTrId("level")
        role: "level"
        resizable: false
        movable: false
        width: 50
        delegate : RowLayout {
          spacing: TibiaStyle.marginRelated

          TibiaText {
            Layout.leftMargin: TibiaStyle.marginNarrow
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter
            text: model ? model.level : ""
            horizontalAlignment: Text.AlignRight
          } //TibiaText

          TibiaVerticalSeparator {
            Layout.fillHeight: true
          } // TibiaVerticalSeparator
        } //delegate : RowLayout
      } // TableViewColumn

      TableViewColumn {
        id: columnVocation
        title: qsTrId("vocation")
        role: "vocation"
        resizable: false
        movable: false
        width: 100
        delegate : RowLayout {

            TibiaText {
              Layout.leftMargin: TibiaStyle.marginNarrow
              Layout.fillWidth: true
              text: model ? model.vocation : ""
            }
            TibiaVerticalSeparator {
            Layout.fillHeight: true
          } // TibiaVerticalSeparator
        }
      } // TableViewColumn

      TableViewColumn {
        id: columnWorld
        title: qsTrId("friends_account_search_tableview_column_world")
        role: "world"
        resizable: false
        movable: false
        width: 100
        delegate : RowLayout {

            TibiaText {
              Layout.leftMargin: TibiaStyle.marginNarrow
              Layout.fillWidth: true
              text: model ? model.world : ""
            }
            TibiaVerticalSeparator {
              Layout.fillHeight: true
            } // TibiaVerticalSeparator
        }
      } // TableViewColumn

      TableViewColumn {
        id: columnFriendGroup
        title: qsTrId("friends_friendlist_friendgroup")
        resizable: false
        movable: false
        width: 140
        delegate: Item {
          property bool editMode: false
          property bool selected: styleData.selected
          onSelectedChanged: {
            editMode = false;
          }
          Component {
            id: showComponent
            RowLayout {
              TibiaText {
                text: model ? friendGroupIDToCaption(model.friendGroup) : 0
                Layout.fillWidth: true
                Layout.leftMargin: TibiaStyle.marginNarrow
              }
              RowLayout {
                Item {
                  Layout.preferredWidth: 18
                  Layout.preferredHeight: 18
                  TibiaButton {
                    anchors.fill: parent
                    imageSourceUp: "/images/icon-edit.png"
                    visible: styleData.selected
                    onClicked: {
                      if (controller != null) {
                        controller.showContextMenuForAccountID(model.accountID)
                      }
                      editMode = true;
                    }
                  } // TibiaButton
                }
              }
            }
          }
          Loader {
            id: groupCellLoader
            anchors.fill: parent
            anchors.rightMargin: TibiaStyle.marginRelated
            sourceComponent: showComponent
          }
        }
      }

      function selectRow(row) {
        if (rowCount > 0 && model != null && model.length > 0) {
          characterList.currentRow = row;
          characterList.selection.clear();
          characterList.selection.select(row);
        }
      } //function selectRow(row)

      function applyLastSelectedIndex() {
        selectDelay.restart();
      } //function applyLastSelectedIndex()

      Timer {
        id: selectDelay
        interval: 0
        onTriggered: {
          if (controller!=null) {
//            characterList.selectRow(controller.lastSelectedIndex);
          }
        } //onTriggered
      } //Timer

      onVisibleChanged: {
        applyLastSelectedIndex();
      } //onVisibleChanged
    } //TibiaTableView

  }

}
