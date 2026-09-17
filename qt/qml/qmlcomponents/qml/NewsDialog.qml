import QtQuick
import QtQuick.Layouts

import qmlcomponents
import qmlenumvalues

/*
 * Developer hints for using NewsDialog
 *
 * You can request a update form the web API via Strg+F5
 */

TibiaDialog {
  id: root
  caption: qsTrId("news_dialog_caption")

  width: 937 //with is choosen to align the menu scrollbar with the with the first dialog tab

  property var controller: null
  property var activeTab: controller != null ? controller.dialogTab
                                             : NewsDialogController.NoTabInitialState

  onReturnPressedFunction: function() {}

  onCancelPressedFunction: function() {
    if (controller != null) {
      controller.requestClose();
    }
  } //onCancelPressedFunction

  onKeyPressedFunction: function(key, modifiers) {
    if (key == Qt.Key_F5
        && (modifiers & Qt.ControlModifier)
        && !ctrlF5Timer.running) {
      controller.requestUpdateNewsFromWebsite();
      ctrlF5Timer.start();
    }
  } // onKeyPressedFunction

  Timer {
    id: ctrlF5Timer
    interval: 10*1000
  } //Timer

  initialFocusItem: root
  KeyNavigation.tab: root
  KeyNavigation.backtab: root

  Component {
    id: menuListModel

    ListModel {
      function withButton(id, name, imageUrl) {
        this.append({
          "categoryId": id,
          "categoryName": name,
          "categoryImageUrl": imageUrl
        });
        return this;
      } //function withButton
    } //ListModel
  } //Component

  function createSubmenuModel(model) {
    var newModel = menuListModel.createObject(root, { });

    newModel.withButton(
      model.categoryId,
      model.headline,
      model.isRead ? "" : "/images/icon-new.png");

    if (model.subEntryModel) {
      for (let i = 0; i < model.subEntryModel.count; ++i) {
        var idx = model.subEntryModel.index(i, 0);
        let isRead = model.subEntryModel.data(idx, model.subEntryModel.isReadEnumValue)

        newModel.withButton(
          model.subEntryModel.data(idx, model.subEntryModel.categoryIdEnumValue),
          model.subEntryModel.data(idx, model.subEntryModel.headlineEnumValue),
          isRead ? "" : "/images/icon-new.png");
      }
    }

    return newModel;
  } //function createSubmenuModel

  TibiaDialogTabBar {
    id: topButtonBar
    anchors { left: parent.left; top: parent.top; right: parent.right; }

    activeTabId: root.activeTab
    buttonImageXOffset: -5
    buttonTextXOffset: 25

    onRequestedTabIdChanged:{
      if (controller != null) {
        controller.requestTabSwitch(requestedTabId);
      }
    } //onRequestedTabIdChanged

    //keep order in sync with newsdialogcontroller.cpp 'CATEGORY_ORDER_LIST''
    tabModel: [
      {
        "tabId": NewsDialogController.PlayerGuide,
        "caption": qsTrId("news_category_playerguide"),
        "tooltip": qsTrId("news_category_playerguide_tooltip"),
        "icon": "/images/news/icon-news-game-content.png"
      }
      , {
        "tabId": NewsDialogController.ClientFeatures,
        "caption": qsTrId("news_category_clientfeatures"),
        "tooltip": qsTrId("news_category_clientfeatures_tooltip"),
        "icon": "/images/news/icon-news-client-features.png"
      }
      , {
        "tabId": NewsDialogController.UsefulInfo,
        "caption": qsTrId("news_category_usefulinfo"),
        "tooltip": qsTrId("news_category_usefulinfo_tooltip"),
        "icon": "/images/news/icon-news-useful-info.png"
      }
      , {
        "tabId": NewsDialogController.MajorUpdates,
        "caption": qsTrId("news_category_majorupdates"),
        "tooltip": qsTrId("news_category_majorupdates_tooltip"),
        "icon": "/images/news/icon-news-major-updates.png"
      }
      , {
        "tabId": NewsDialogController.Support,
        "caption": qsTrId("news_category_support"),
        "tooltip": qsTrId("news_category_support_tooltip"),
        "icon": "/images/news/icon-news-support.png"
      }
    ] //tabModel
  } //TibiaDialogTabBar

  ColumnLayout {
    anchors { left: parent.left; top: topButtonBar.bottom; right: parent.right }
    anchors.topMargin: TibiaStyle.marginRelated
    spacing: TibiaStyle.marginUnrelated

    RowLayout {
      id: mainLayout
      Layout.fillWidth: true
      spacing: TibiaStyle.marginRelated

      TibiaFrame2PixelUpFilled {
        id: menuBackground
        Layout.fillWidth: true
        Layout.fillHeight: true

        dark: true

        TibiaScrollView {
          id: scrollViewMenu
          anchors.fill: parent
          anchors.margins: parent.borderWidth
          anchors.leftMargin: menuBackground.marginsToContent

          ListView {
            id: menuListView
            anchors.fill: parent
            anchors.rightMargin: TibiaStyle.scrollBarWidth
            anchors.topMargin: TibiaStyle.marginRelated
            anchors.bottomMargin: TibiaStyle.marginRelated

            model: controller != null ? controller.entryModel : null

            boundsBehavior: Flickable.StopAtBounds
            interactive: false //prevent flick behavior on touch screens
            highlightFollowsCurrentItem: true
            highlightMoveDuration: 0

            spacing: TibiaStyle.marginUnrelated

            clip: true


            //needed to restore scroll position eg. if isRead flag changes
            property int oldListPosition: 0
            property int oldCount: 0
            property bool resetListPosition: false

            Timer {
              id: saveListPositionTimer
              interval: 1
              onTriggered: {
                parent.oldListPosition = parent.contentY;
              } //onTriggered
            } //Timer

            onContentYChanged: {
              saveListPositionTimer.restart();
            } //onContentYChanged

            onCountChanged: {
              if (count != oldCount) {
                oldCount = count;
              } else {
                if (resetListPosition) {
                  oldListPosition = 0;
                  resetListPosition = false;
                }
                contentY = oldListPosition;
              }
            } //onCountChanged

            delegate: MenuWithSubMenu {
              width: menuListView.width - TibiaStyle.marginRelated
              controller: root.controller
              indentSubMenuEntries: topButtonBar.activeTabId == NewsDialogController.PlayerGuide
                || topButtonBar.activeTabId == NewsDialogController.ClientFeatures

              textHorizontalAlignment: Text.AlignLeft
              textXOffset: TibiaStyle.marginRelated
              imageTopLeftCorner: true

              categories: createSubmenuModel(model);

              onIsActiveChanged: {
                if (isActive) {
                  menuListView.currentIndex = index;
                  menuListView.resetListPosition = true;
                }
              } //onIsActiveChanged
            } //delegate: MenuWithSubMenu
          } //ListView
        } //TibiaScrollView
      } //TibiaFrame2PixelUpFilled

      TibiaFrame2PixelUpFilledWithCaption {
        Layout.preferredWidth: TibiaStyle.newsContentWidth
          + TibiaStyle.scrollBarWidth
          + 2 * marginsToContent
          + 2 * contentFrame.borderWidth
          + 2 * TibiaStyle.marginRelated
        Layout.minimumWidth: Layout.preferredWidth
        Layout.maximumWidth: Layout.preferredWidth
        Layout.preferredHeight: 510 //choos hight to have ne last button in the menu so be shown so that some text is visble

        caption: controller != null ? controller.headline : qsTrId("dummy_unknown")

        onCaptionChanged: {
          contentFlickable.contentY = 0;
        } //onCaptionChanged

        TibiaFrame1PixelDown {
          id: contentFrame
          anchors.fill: parent
          anchors.margins: parent.marginsToContent
          anchors.topMargin: parent.topMarginToContent

          TibiaScrollView {
            id: contentScrollView
            anchors.fill: parent
            anchors.margins: parent.borderWidth
            anchors.topMargin: parent.borderWidth

            Flickable {
              id: contentFlickable
              anchors.fill: parent
              anchors.margins: TibiaStyle.marginRelated

              contentHeight: contentText.contentHeight + 2* anchors.margins
              contentWidth: parent.width - TibiaStyle.scrollBarWidth - 2 * anchors.margins

              TibiaText {
                id: contentText
                anchors.fill: parent

                clip: true
                wrapMode: Text.WordWrap
                textFormat: Text.RichText
                text: controller != null ? controller.contentText : qsTrId("dummy_unknown")

                onLinkActivated: { controller.linkClicked(link); }
                onLinkHovered: { controller.linkHoverChanged(link.length != 0); }
              } //TibiaText
            } //Flickable
          } //TibiaScrollView
        } //TibiaFrame1PixelDown
      } //TibiaFrame2PixelUpFilledWithCaption
    } // RowLayout

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } //TibiaHorizontalSeparator

    RowLayout {
      Layout.alignment: Qt.AlignRight
      spacing: TibiaStyle.marginRelated

      TibiaButton {
        text: qsTrId("close")
        onClicked: onCancelPressedFunction();
      } //TibiaButton
    } // RowLayout
  } //ColumnLayout
} // TibiaDialog
