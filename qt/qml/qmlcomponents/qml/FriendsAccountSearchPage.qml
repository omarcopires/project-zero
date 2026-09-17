import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qmlcomponents
import QtQuick.LegacyControls


Item {
  id: root
  property var controller: null
  property var initialFocusItem: null

  property var accountCharacterListModel: controller != null ? controller.accountCharacterList.accountCharactersModel : null
  property var accountBadgesListModel: controller != null ? controller.accountBadgeList.accountBadgesModel : null
  property bool showAccountInfo: controller != null ? controller.showAccountInfo : true
  property bool isOnline: controller != null ? controller.isOnline : true
  property bool isPremium: controller != null ? controller.isPremium : true
  property bool isFriendOrInvited: controller != null ? controller.isFriendOrInvited : false
  property bool isOnBlacklist: controller != null ? controller.isOnBlacklist : false
  property var loyaltyTitle: controller != null ? controller.loyaltyTitle : ""
  property var lastGameLogin: controller != null ? controller.lastGameLogin : ""
  property bool showLoadingComponent: controller != null ? controller.showLoadingComponent : false
  property bool showEmptyTab: controller != null ? controller.showEmptyTab : true
  property bool showNoResultsFound: controller != null ? controller.showNoResultsFound : false
  property bool hasMainCharacter: controller != null ? controller.hasMainCharacter : false
  property bool disableButtonsAfterClick: controller != null ? controller.disableButtonsAfterClick : false
  property var characterInfoDialogController: controller != null ? controller.characterInfoDialogController : null
  property bool showCharacterInfo: controller != null ? controller.showCharacterInfo: false

  Component {
    id: emptyTabComponent
    TibiaFrame1PixelDown {
       TibiaText {
         visible: !showLoadingComponent
         anchors.centerIn: parent
         text: showNoResultsFound ? qsTrId("noresults") : qsTrId("friends_account_search_explanation")
       } // TibiaText

      Image {
        visible: showLoadingComponent
        source: "/images/dynamic/dynamic-image-loading.png"
        anchors.centerIn: parent
      } // Image

    } // TibiaFrame1PixelDown

  } // Component


  Component {
    id: searchResultComponent

    ColumnLayout {

      TibiaFrame2PixelUpFilled {
        id: accountInfoBox
        Layout.fillWidth: true
        Layout.preferredHeight: childrenRect.x * 2 + childrenRect.height
        Layout.alignment: Qt.AlignTop
        visible: showAccountInfo

        RowLayout {

          id: outerRowLayout
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.top: parent.top
          anchors.topMargin: TibiaStyle.marginUnrelated
          anchors.leftMargin: TibiaStyle.marginUnrelated

          ColumnLayout {
            id: accountInfoColumn
            Layout.alignment: Qt.AlignVCenter

            spacing: TibiaStyle.marginRelated

            RowLayout {
              spacing: TibiaStyle.marginRelated
              TibiaText {
                text: qsTrId("friends_account_search_onlinestatus")
              } // TibiaText

              TibiaText {
                text: isOnline ? qsTrId("friends_account_search_onlinestatus_online") : qsTrId("friends_account_search_onlinestatus_offline")
                color: isOnline? TibiaStyle.textColors['VipOnline'] : TibiaStyle.textColors['VipOffline']
              } // TibiaText
            } // RowLayout

            RowLayout {
              spacing: TibiaStyle.marginRelated
              visible: !isOnline

              TibiaText {
                text: qsTrId("friends_account_search_last_game_login")
              } // TibiaText

              TibiaText {
                text: lastGameLogin
              } // TibiaText
            } // RowLayout

            RowLayout {
              spacing: TibiaStyle.marginRelated
              TibiaText {
                text: qsTrId("friends_account_search_accountstatus")
              } // TibiaText

              TibiaText {
                text: isPremium ? qsTrId("friends_account_search_accountstatus_premium") : qsTrId("friends_account_search_accountstatus_free")
              } // TibiaText
            } // RowLayout

            RowLayout {
              spacing: TibiaStyle.marginRelated
              visible: loyaltyTitle.length > 0

              TibiaText {
                id: loyaltyTitleText
                text: loyaltyTitle
              } // TibiaText

            } // RowLayout



          } // ColumnLayout

          RowLayout {
            id: scrollViewWrapper
            Item {
              Layout.fillWidth: true
            }
            onWidthChanged: {
              badgesScrollView.calculateSize(true);
            }

            Timer {
              id: asyncTimer
              interval: 0
              repeat: false
              running: true
              triggeredOnStart: true
              onTriggered: {
                badgesScrollView.__internalCalculateSize();
              }
            }

            TibiaScrollView {

              id: badgesScrollView

              function calculateSize(async)
              {
                if (async) {
                  if (scrollViewWrapper.asyncTimer != undefined) {
                    scrollViewWrapper.asyncTimer.start();
                  }
                } else {
                  __internalCalculateSize();
                }
              }
              function __internalCalculateSize() {
                var maximumWidth = scrollViewWrapper.width - 2 * TibiaStyle.marginUnrelated;
                var preferredWidth = Math.min(badgesListView.contentWidth, maximumWidth);

                if (badgesScrollView.__preferredWidth != preferredWidth) {
                  badgesScrollView.__preferredWidth = preferredWidth;
                }

                var scrollbarHeight = 0;
                if (badgesListView.contentWidth >= maximumWidth) {
                  scrollbarHeight = TibiaStyle.scrollBarWidth + TibiaStyle.marginNarrow;
                } else {
                  scrollbarHeight = 0;
                }
                var newPreferredHeight = badgesScrollView.imageWidth + scrollbarHeight;
                if (badgesScrollView.__preferredHeight != newPreferredHeight) {
                  badgesScrollView.__preferredHeight = newPreferredHeight;
                }
              }

              property int __preferredWidth: 0
              property int __preferredHeight: 0

              Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
              Layout.preferredWidth: __preferredWidth
              Layout.preferredHeight: __preferredHeight

              property int imageWidth: 0

              horizontalScrollBarPolicy: ScrollBar.AsNeeded
              verticalScrollBarPolicy: ScrollBar.AlwaysOff

              ListView {
                id: badgesListView
                boundsBehavior: Flickable.StopAtBounds
                orientation: ListView.Horizontal
                model: accountBadgesListModel
                spacing: TibiaStyle.marginNarrow

                onContentWidthChanged: {
                  badgesScrollView.calculateSize();
                }

                delegate: Image {
                    source: model != null ? model.badgeIcon : ""
                    Tooltip {
                      anchors.fill: parent
                      text: model != null ? model.badgeName : ""
                    } //Tooltip
                    onStatusChanged: {
                      if (status == Image.Ready) {
                        badgesScrollView.imageWidth = width;
                        badgesScrollView.calculateSize();
                      }
                    } //onStatusChanged
                  } //Image

              } // ListView

            } // TibiaScrollView
            Item {
              Layout.fillWidth: true
            } //Item
          } // RowLayout
        } // RowLayout
      } // TibiaFrame2PixelUpFilled

      TibiaTableView {
        id: characterList
        selectionMode: SelectionMode.SingleSelection
        Layout.fillHeight: true
        Layout.fillWidth: true
        //KeyNavigation.tab: characterList
        model: accountCharacterListModel

        headerVisible: true
        rowHeight: 66

        TableViewColumn {
          id: columnCharacter
          title: qsTrId("friends_account_search_tableview_column_characters")
          role: "characterID"
          resizable: false
          movable: false
          width: characterList.contentItem.width - columnLevel.width - columnVocation.width - columnWorld.width
          delegate: RowLayout {
            spacing: TibiaStyle.marginRelated

            OutfitAppearanceInstanceRenderer {
              Layout.preferredHeight: 64
              Layout.preferredWidth: 64
              Layout.leftMargin: TibiaStyle.marginUnrelated
              center: true
              animated: true

              outfitId: model != null ? model.outfitID : 0
              headColor: model != null ? model.headColor : "black"
              torsoColor: model != null ? model.torsoColor : "black"
              legsColor: model != null ? model.legsColor : "black"
              detailColor: model != null ? model.detailColor : "black"
              firstAddOn: model != null ? model.addon1 : false
              secondAddOn: model != null ? model.addon2 : false

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
                    controller.openCyclopediaCharacterInfo(model.characterID);
                  }
                } // onClicked
              } // MouseArea
            } //OutfitAppearanceInstanceRenderer

            ColumnLayout {
              spacing: TibiaStyle.marginRelated
              Layout.fillWidth: true

              RowLayout {
                spacing: TibiaStyle.marginRelated

                Item {
                  implicitHeight: charNameText.height
                  implicitWidth: charNameText.width

                  TibiaText {
                    id: charNameText
                    text: model ? model.characterName : ""

                    styleType: model && model.isOnline ? "VipOnline" : "Dialog"
                    wrapMode: Text.Wrap

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
                          controller.openCyclopediaCharacterInfo(model.characterID);
                        }
                      } // onClicked
                    } // MouseArea
                  } //TibiaText

                } //Item

                Image {
                  source: "/images/maincharacter.png"
                  visible: model? model.isMainCharacter : false
                  Tooltip {
                    anchors.fill: parent
                    text: qsTrId("friends_account_search_tooltip_maincharacter")
                  }
                } // Image
              } // RowLayout

              TibiaText {
                text: model ? model.characterTitle : ""
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
                      controller.openCyclopediaCharacterInfo(model.characterID);
                    }
                  } // onClicked
                } // MouseArea
              } //TibiaText
            } // ColumnLayout

            Item {
              Layout.fillWidth: true
              Layout.margins: - parent.spacing
            } //Item

            TibiaButton {
              Layout.preferredHeight: TibiaStyle.buttonHeightDefault
              Layout.preferredWidth: Layout.preferredHeight
              imageSource: "/images/icon-displayresults.png"

              onClicked: {
                if (tibiaMouseCursorController != null) {
                  tibiaMouseCursorController.setPointingHand(false);
                }
                if (controller != null && model != null) {
                  controller.openCyclopediaCharacterInfo(model.characterID);
                }
              } // onClicked
            } //TibiaButton

            TibiaVerticalSeparator {
              Layout.fillHeight: true
            } // TibiaVerticalSeparator
          } // delegate
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
               Layout.alignment: Qt.AlignCenter
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
               Layout.alignment: Qt.AlignCenter
               text: model ? model.world : ""
             }
             //TibiaVerticalSeparator {
             // Layout.fillHeight: true
            //} // TibiaVerticalSeparator
          }
        } // TableViewColumn

      } //TibiaTableView

      RowLayout {
        spacing: TibiaStyle.marginUnrelated
        Item {
          Layout.fillWidth: true
        } // Item

        Item {

          Layout.preferredWidth: 100
          Layout.preferredHeight: TibiaStyle.buttonHeightDefault

          TibiaButton {
            id: inviteAsFriendButton
            text: qsTrId("friends_account_search_button_friendinvite")
            anchors.fill: parent
            enabled: !disableButtonsAfterClick && hasMainCharacter && !showLoadingComponent && !showEmptyTab && !showNoResultsFound && !isFriendOrInvited && !isOnBlacklist
            onClicked: {
              if (controller) {
                controller.onClickedInviteAsFriend();
              }
            } // onClicked

          } //TibiaButton
          Tooltip {
            anchors.fill: parent
            text: qsTrId("friends_account_search_button_friendinvite_tooltip")
          } //Tooltip
        } // Item

        TibiaButton {
          id: blackListButton
          text: qsTrId("friends_account_search_button_blacklist")
          Layout.preferredWidth: 100
          enabled: !disableButtonsAfterClick && hasMainCharacter && !showLoadingComponent && !showEmptyTab && !showNoResultsFound && !isFriendOrInvited && !isOnBlacklist
          onClicked: {
            if (controller) {
              controller.onClickedSetOnBlacklist();
            }
          } // onClicked
        } //TibiaButton

        Item {
          Layout.fillWidth: true
        } // Item
      } // RowLayout

    } // ColumnLayout

  } // Component

  Component {
    id: accountSearchComponent

    ColumnLayout {
      anchors.fill: parent

      Component.onCompleted: {
        nameFilterText.forceActiveFocus();
      }

      TibiaFrame2PixelUpFilled {
        Layout.fillWidth: true
        Layout.preferredHeight: 42
        Layout.alignment: Qt.AlignTop
        RowLayout {
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.top: parent.top
          anchors.topMargin: TibiaStyle.marginUnrelated
          spacing: TibiaStyle.marginUnrelated

          Item {
            Layout.fillWidth: true
          } // Item

          TibiaText {
            Layout.alignment: Qt.AlignVCenter
            text: qsTrId("friends_account_search_search_description")
          } // TibiaText

          TibiaFrame1PixelDown {
            Layout.preferredHeight: TibiaStyle.buttonHeightDefault + 2*borderWidth
            Layout.preferredWidth: 200
            Layout.alignment: Qt.AlignVCenter

            TibiaTextField {
              id: nameFilterText
              maximumLength: TibiaStyle.maxCharacterNameLength

              anchors { left:parent.left; top: parent.top; right: searchCharacterButton.left; bottom: parent.bottom}
              anchors.rightMargin: -1
              z: -1
              KeyNavigation.tab: nameFilterText
              KeyNavigation.backtab: nameFilterText
              placeholderText: qsTrId("type_to_search_placeholder")

              Keys.onEnterPressed: {
                if (!showLoadingComponent && text.length >= 2) {
                  controller.onClickedSearchForCharacter(text);
                }
              }

              Keys.onReturnPressed: {
                if (!showLoadingComponent && text.length >= 2) {
                  controller.onClickedSearchForCharacter(text);
                }
              }

            } // TibiaTextField
            TibiaButton {
              id: searchCharacterButton
              imageSource: "/images/icon-search.png"
              anchors {top: parent.top; right: parent.right}
              anchors.margins: parent.borderWidth
              height: parent.height - 2*parent.borderWidth
              width: height

              enabled: !showLoadingComponent && nameFilterText.text.length >= 2

              onClicked: {
                if (controller) {
                  controller.onClickedSearchForCharacter(nameFilterText.text);
                }
              } // onClicked

              TibiaDisabledOverlay {
                anchors.fill: parent
                visible: !searchCharacterButton.enabled
              } //TibiaDisabledOverlay

            } //TibiaButton
          } // TibiaFrame1PixelDown

          Item {
            Layout.fillWidth: true
          } // Item

        } // RowLayout
      } // TibiaFrame2PixelUpFilled

      Loader {
        Layout.fillWidth: true
        Layout.fillHeight: true
        sourceComponent: (showLoadingComponent || showEmptyTab || showNoResultsFound) ? emptyTabComponent : searchResultComponent
      } // Loader

    } // ColumnLayout
  }

  Component {
    id: characterDetailsComponent
    CharacterInfoDialog {
      controller: characterInfoDialogController
      anchors.fill: parent
    }
  }

  Loader {
    anchors.fill: parent
    sourceComponent: showCharacterInfo ? characterDetailsComponent : accountSearchComponent
  } // Loader
}
