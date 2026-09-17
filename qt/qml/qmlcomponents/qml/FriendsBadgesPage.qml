import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qmlcomponents
import qmlenumvalues
import QtQuick.LegacyControls


ColumnLayout {
  id: root
  property var controller: null
  property var initialFocusItem: badgesTable

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
        id: badgeFilterGroup

        checkedButton: {
          if (controller != null) {
            if (controller.badgeFilter == FriendsBadgesController.ShowAll) {
              return showAllButton;
            } else if (controller.badgeFilter == FriendsBadgesController.ShowLocked) {
              return showLockedButton;
            } else if (controller.badgeFilter == FriendsBadgesController.ShowUnlocked) {
              return showUnlockedButton;
            } else if (controller.badgeFilter == FriendsBadgesController.ShowPublic) {
              return showPublicButton;
            } else if (controller.badgeFilter == FriendsBadgesController.ShowHidden) {
              return showHiddenButton;
            }
          }

          return null;
        }
      }

      Item {
        Layout.fillWidth: true
      }

      TibiaRadioButton {
        id: showAllButton
        ButtonGroup.group: badgeFilterGroup
        text: qsTrId("friends_badge_filter_all")

        onClicked: {
          if (controller != null) {
            badgesTable.__listView.positionViewAtBeginning(); // Reset table scroll position
            controller.badgeFilter = FriendsBadgesController.ShowAll;
          }
        }
      }

      TibiaRadioButton {
        id: showLockedButton
        ButtonGroup.group: badgeFilterGroup
        text: qsTrId("friends_badge_filter_locked")

        onClicked: {
          if (controller != null) {
            badgesTable.__listView.positionViewAtBeginning(); // Reset table scroll position
            controller.badgeFilter = FriendsBadgesController.ShowLocked;
          }
        }
      }

      TibiaRadioButton {
        id: showUnlockedButton
        ButtonGroup.group: badgeFilterGroup
        text: qsTrId("friends_badge_filter_unlocked")

        onClicked: {
          if (controller != null) {
            badgesTable.__listView.positionViewAtBeginning(); // Reset table scroll position
            controller.badgeFilter = FriendsBadgesController.ShowUnlocked;
          }
        }
      }

      TibiaRadioButton {
        id: showPublicButton
        ButtonGroup.group: badgeFilterGroup
        text: qsTrId("friends_badge_filter_public")

        onClicked: {
          if (controller != null) {
            badgesTable.__listView.positionViewAtBeginning(); // Reset table scroll position
            controller.badgeFilter = FriendsBadgesController.ShowPublic;
          }
        }
      }

      TibiaRadioButton {
        id: showHiddenButton
        ButtonGroup.group: badgeFilterGroup
        text: qsTrId("friends_badge_filter_hidden")

        onClicked: {
          if (controller != null) {
            badgesTable.__listView.positionViewAtBeginning(); // Reset table scroll position
            controller.badgeFilter = FriendsBadgesController.ShowHidden;
          }
        }
      }

      Item {
        Layout.fillWidth: true
      }
    } // RowLayout
  } // TibiaFrame2PixelUpFilled

  TibiaTableView {
    id: badgesTable
    Layout.fillWidth: true
    Layout.fillHeight: true
    horizontalScrollBarPolicy: ScrollBar.AlwaysOff
    headerVisible: true
    model: controller != null ? controller.badges : null
    rowHeight: 67

    TableViewColumn {
      role: "badgeName"
      title: qsTrId("friends_badge_name_header")
      movable: false
      resizable: false
      width: 270

      delegate: RowLayout {
        Image {
          Layout.leftMargin: TibiaStyle.marginNarrow
          smooth: false
          source: {
            if (model != null) {
              if (model.isBadgeUnlocked) {
                return model.badgeIcon;
              } else {
                return "/images/social/friend-badge-locked.png";
              }
            } else {
              return "";
            }
          }
        }

        TibiaText {
          text: styleData.value
          wrapMode: Text.Wrap
          textFormat: Text.RichText
          color: styleData.selected
            ? TibiaStyle.textFieldSelectionTextColor
            : TibiaStyle.textFieldTextColor
          Layout.fillWidth: true
        }

        TibiaVerticalSeparator {
          Layout.fillHeight: true
        }
      } // RowLayout
    } // TableViewColumn

    TableViewColumn {
      role: "badgeDescription"
      title: qsTrId("friends_badge_description_header")
      movable: false
      resizable: false
      width: 280

      delegate: RowLayout {
        TibiaText {
          Layout.fillWidth: true
          Layout.leftMargin: TibiaStyle.marginNarrow
          wrapMode: Text.Wrap
          text: styleData.value
          color: styleData.selected
            ? TibiaStyle.textFieldSelectionTextColor
            : TibiaStyle.textFieldTextColor
        }

        TibiaVerticalSeparator {
          Layout.fillHeight: true
        }
      } // delegate RowLayout
    } // TableViewColumn

    TableViewColumn {
      title: qsTrId("friends_badge_visible_header")
      movable: false
      resizable: false
      width: 150

      delegate: ColumnLayout {
        TibiaCheckBox {
          id: visibleCheckbox
          Layout.leftMargin: TibiaStyle.marginUnrelated
          text: qsTrId("friends_badge_show_for_others")
          shouldBeChecked: model != null && model.isBadgeVisible
          visible: model != null && model.isBadgeUnlocked

          onClicked: {
            if (controller != null && model != null) {
              controller.updateBadgeVisibility(model.badgeID, visibleCheckbox.checked)
            }
          }
        }

        TibiaText {
          Layout.fillWidth: true
          Layout.leftMargin: TibiaStyle.marginNarrow
          wrapMode: Text.Wrap
          text: qsTrId("friends_badge_not_unlocked")
          visible: model != null && !model.isBadgeUnlocked
          horizontalAlignment: Text.AlignHCenter
        }
      } // delegate ColumnLayout
    } // TableViewColumn
  } // TibiaTableView
} // ColumnLayout
