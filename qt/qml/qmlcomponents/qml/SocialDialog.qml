import QtQuick
import QtQuick.Layouts
import qmlcomponents
import qmlenumvalues


TibiaDialog {
  id: root
  caption: qsTrId("social_dialog_caption")
  width: 753

  property var controller: null

  property var activeTab: controller != null ? controller.dialogTab
                                             : SocialDialogController.NoTabInitialState

  property var friendListController: controller != null ? controller.friendListController : null
  property var accountSearchController: controller != null ? controller.accountSearchController : null
  property var invitesController: controller != null ? controller.invitesController : null
  property var badgesController: controller != null ? controller.badgesController : null
  property var configurationController: controller != null ? controller.configurationController : null
  property var joinTeamController: controller != null ? controller.joinTeamController : null
  property var assembleTeamController: controller != null ? controller.assembleTeamController : null

  initialFocusItem: root
  KeyNavigation.tab: root
  KeyNavigation.backtab: root

  onReturnPressedFunction: function() {
  }

  onCancelPressedFunction: function() {
    if (controller != null) {
      controller.requestClose();
    }
  }

  onActiveTabChanged: {
    if (contentLoader.status == Loader.Ready && contentLoader.item) {
      // Unload controller to clear bindings
      contentLoader.item.controller = null;
    }

    if (activeTab == SocialDialogController.FriendList) {
      contentLoader.contentController = friendListController;
      contentLoader.source = "FriendsFriendListPage.qml";
    } else if (activeTab == SocialDialogController.Invites) {
      contentLoader.contentController = invitesController;
      contentLoader.source = "FriendsInvitesPage.qml";
    } else if (activeTab == SocialDialogController.AccountSearch) {
      contentLoader.contentController = accountSearchController;
      contentLoader.source = "FriendsAccountSearchPage.qml";
    } else if (activeTab == SocialDialogController.Badges) {
      contentLoader.contentController = badgesController;
      contentLoader.source = "FriendsBadgesPage.qml";
    } else if (activeTab == SocialDialogController.FriendsConfiguration) {
      contentLoader.contentController = configurationController;
      contentLoader.source = "FriendsConfigurationPage.qml";
    } else if (activeTab == SocialDialogController.JoinTeam) {
      contentLoader.contentController = joinTeamController;
      contentLoader.source = "TeamJoinPage.qml";
    } else if (activeTab == SocialDialogController.AssembleTeam) {
      contentLoader.contentController = assembleTeamController;
      contentLoader.source = "TeamAssemblePage.qml";
    } else {
      contentLoader.contentController = null;
      contentLoader.source = "";
    }
  } //onActiveTabChanged

  TibiaDialogTabBar {
    id: topButtonBar
    anchors { left: parent.left; top: parent.top; right: parent.right; }

    activeTabId: activeTab
    compactStyle: true
    buttonTextXOffset: 27

    onRequestedTabIdChanged:{
      if (controller != null) {
        controller.requestTabSwitch(requestedTabId);
      }
    } //onRequestedTabIdChanged

    tabModel: [
      {
        "tabId": SocialDialogController.JoinTeam,
        "caption": qsTrId("social_jointeam_tab_caption"),
        "tooltip": qsTrId("social_jointeam_tab_caption"),
        "icon": "/images/social/icon-findpartygroup.png"
      }
      , {
        "tabId": SocialDialogController.AssembleTeam,
        "caption": qsTrId("social_assembleteam_tab_caption"),
        "tooltip": qsTrId("social_assembleteam_tab_caption"),
        "icon": "/images/social/icon-createpartygroup.png"
      }
      , {
        "tabId": SocialDialogController.FriendList,
        "caption": qsTrId("social_friendlist_tab_caption"),
        "tooltip": qsTrId("social_friendlist_tab_caption"),
        "icon": "/images/social/icon-friends-friendlist.png"
      }
      , {
        "tabId": SocialDialogController.Invites,
        "caption": qsTrId("social_friendsinvites_tab_caption"),
        "tooltip": qsTrId("social_friendsinvites_tab_tooltip"),
        "icon": "/images/social/icon-friends-invites.png"
      }
      , {
        "tabId": SocialDialogController.AccountSearch,
        "caption": qsTrId("social_accountsearch_tab_caption"),
        "tooltip": qsTrId("social_accountsearch_tab_tooltip"),
        "icon": "/images/social/icon-friends-accountsearch.png"
      }
      , {
        "tabId": SocialDialogController.Badges,
        "caption": qsTrId("social_badges_tab_caption"),
        "tooltip": qsTrId("social_badges_tab_caption"),
        "icon": "/images/social/icon-friends-badges.png"
      }
      , {
        "tabId": SocialDialogController.FriendsConfiguration,
        "caption": qsTrId("social_friendsconfiguration_tab_caption"),
        "tooltip": qsTrId("social_friendsconfiguration_tab_caption"),
        "icon": "/images/social/icon-friends-configuration.png"
      }
    ] //tabModel
  } //TibiaDialogTabBar

  Loader {
    id: contentLoader
    anchors { top: topButtonBar.bottom; topMargin: TibiaStyle.marginRelated;
              left: parent.left; right: parent.right; }
    height: 420

    property var contentController: null

    onLoaded: {
      item.controller = Qt.binding(function() { return contentLoader.contentController; });
      if (item.initialFocusItem) {
        item.initialFocusItem.forceActiveFocus();
        item.initialFocusItem.Keys.forwardTo = [topButtonBar]
      }
      if (item.hasOwnProperty("needsTabNavigation")) {
        topButtonBar.tabShortcutsActive = Qt.binding(function() { return !(item != null && item.needsTabNavigation); });
      } else {
        topButtonBar.tabShortcutsActive = true;
      }
    } //onLoaded
  } // Loader

  ColumnLayout {
    id: buttonLayout
    spacing: TibiaStyle.marginUnrelated
    anchors { left: parent.left; right: parent.right; top: contentLoader.bottom; topMargin: TibiaStyle.marginRelated }

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } // TibiaHorizontalSeparator

    RowLayout {
      id: buttonBar
      Layout.fillWidth: true
      spacing: TibiaStyle.marginRelated

      Item {
        // Padding
        Layout.fillWidth: true
        height: 1
      }

      Item {
        Layout.preferredWidth: refreshButton.width
        Layout.preferredHeight: refreshButton.height
        visible: controller != null && controller.refreshButtonVisible

        TibiaButton {
          id: refreshButton
          text: qsTrId("refresh")
          enabled: controller != null && controller.hasPremium
          onClicked: {
            if (controller != null) {
              controller.onRefreshButtonClicked();
            }
          } //onClicked
        } //TibiaButton

        Tooltip {
          anchors.fill: parent
          enabled: !refreshButton.enabled
          text: qsTrId("teamfinder_no_teams_no_premium")
        } //Tooltip
      } //Item

      TibiaButton {
        visible: controller != null && controller.backButtonVisible
        text: qsTrId("back")
        onClicked: {
          if (controller != null) {
            controller.signalBackButtonClicked();
          }
        } //onClicked
      } //TibiaButton

      TibiaButton {
        text: qsTrId("close")
        onClicked: onCancelPressedFunction()
      }
    } // RowLayout
  } // ColumnLayout
} // TibiaDialog
