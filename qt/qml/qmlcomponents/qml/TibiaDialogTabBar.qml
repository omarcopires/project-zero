import QtQuick
import QtQuick.Layouts

import qmlcomponents
import qmlenumvalues

/*
 * Developer hints for using TibiaDialogTabBar
 *
 * use 'buttonImageXOffset' and 'buttonTextXOffset' to manipulate the position of text and icons
 *
 * 'compactStyle' enables the compate style where inactive tabs only show the icon but no text
 *
 * 'tabShortcutsActive' allows to deactivate the tab navigation.
 * This is especially useful to temporary deactivate this behaviour to allow tab navigation within a form
 *
 * Set 'tabModel' like this:
 * tabModel: [
 *     {
 *       "tabId": SocialDialogController.FriendList,
 *       "caption": qsTrId("social_friendlist_tab_caption"),
 *       "tooltip": qsTrId("social_friendlist_tab_caption"),
 *       "icon": "/images/social/icon-friends-friendlist.png"
 *     }
 *     , {
 *       "tabId": SocialDialogController.Invites,
 *       "caption": qsTrId("social_friendsinvites_tab_caption"),
 *       "tooltip": qsTrId("social_friendsinvites_tab_caption"),
 *       "icon": "/images/social/icon-friends-invites.png"
 *       "disabled": true
 *       "disabledTooltip": "normal tooltip wil be used if not provided"
 *     }
 *  ]
 */


TibiaFrame1PixelDown {
  id: root
  implicitHeight: TibiaStyle.dialogTabBarHeight

  property alias tabModel: buttonRepeater.model
  property int activeTabId: -1

  property bool compactStyle: false
  property bool fillWithCurrentTab: false
  property bool tabShortcutsActive: true
  property int activeTabWidth: TibiaStyle.dialogTabBarDefaultWidth

  property int buttonImageXOffset: 0
  property int buttonTextXOffset: 15

  property int requestedTabId: -1

  property var _tabCycleIndex: 0

  Shortcut {
    enabled: root.visible && root.tabShortcutsActive
    sequence: "Tab"
    onActivated: {
      switchToNextTab();
      SoundHelper.playSound(SoundHelper.BUTTON_PRESS);
    } //onActivated
  } //Shortcut

  Shortcut {
    enabled: root.visible && root.tabShortcutsActive
    sequence: "Shift+Tab"
    onActivated: {
      switchToPreviousTab();
      SoundHelper.playSound(SoundHelper.BUTTON_PRESS);
    } //onActivated
  } //Shortcut

  function switchToNextTab()
  {
    incrementOrDecrementTabCycleIndex(1);
  } //function switchToNextTab()

  function switchToPreviousTab()
  {
    incrementOrDecrementTabCycleIndex(-1);
  } //function switchToNextTab()

  on_TabCycleIndexChanged: {
    if (root.tabModel != null && root.tabModel.length > 0) {
      var NewTabId = root.tabModel[_tabCycleIndex].tabId;
      if (NewTabId != root.requestedTabId) {
        root.requestedTabId = root.tabModel[_tabCycleIndex].tabId;
      }
    }
  } //on_TabCycleIndexChanged

  function incrementOrDecrementTabCycleIndex(valueChange) {
    if (root.tabModel != null && root.tabModel.length > 0) {
      let newIndex = _tabCycleIndex;
      while (true) {
        newIndex = newIndex + valueChange;
        if (newIndex < 0) {
          newIndex = root.tabModel.length - 1;
        } else if (newIndex >= root.tabModel.length) {
          newIndex = 0;
        }

        let newModelData = root.tabModel[newIndex];
        if (   !newModelData.hasOwnProperty("disabled")
            || !newModelData.disabled
            || _tabCycleIndex == newIndex) {
            break;
        }
      }
      _tabCycleIndex = newIndex
    }
  } //function incrementOrDecrementTabCycleIndex(valueChange)

  onActiveTabIdChanged: {
    root.requestedTabId = root.activeTabId;
    if (root.tabModel != null && root.tabModel.length > 0) {
      for (var i=0; i < root.tabModel.length; i++) {
        if(root.tabModel[i].tabId == root.activeTabId) {
          _tabCycleIndex = i;
          return;
        }
      }
    }
  } //activeTabId

  RowLayout {
    id: tabLayout
    anchors.fill: parent
    anchors.margins: root.borderWidth
    spacing: 0


    Repeater {
      id: buttonRepeater

      readonly property bool validModelForSize: model != null && model.length > 0
      readonly property int itemWidth: validModelForSize ? tabLayout.width / model.length : TibiaStyle.dialogTabBarDefaultWidth
      readonly property int lastItemWidth: validModelForSize ? (tabLayout.width - (model.length -1) * itemWidth) : TibiaStyle.dialogTabBarDefaultWidth

      Loader {
          Component {
            id: tabButtonNormal
            Item {
              id: normalRoot
              property int tabId: -1
              property bool disabled: false
              property alias disabledTooltip: normalDisabledTooltip.text

              property alias buttonShouldBeChecked: normalButton.buttonShouldBeChecked
              property alias text: normalButton.text
              property alias tooltipText: normalButton.tooltipText
              property alias imageSource: normalButton.imageSource

              TibiaButton {
                id: normalButton
                anchors.fill: normalRoot

                enabled: !normalRoot.disabled
                textFont: TibiaStyle.defaultTextFont
                imageAnchor: "left"
                imageXOffset: root.buttonImageXOffset
                textXOffset: root.buttonTextXOffset

                checkable: true
                useButtonShouldBeChecked: true
                buttonShouldBeChecked: root.activeTabId == tabId

                onClicked: {
                  root.requestedTabId = normalRoot.tabId
                  root._tabCycleIndex = index
                } //onClicked
              } //TibiaButton

              Tooltip {
                id: normalDisabledTooltip
                anchors.fill: normalRoot
                enabled: normalRoot.disabled
              } //Tooltip
            } //Item
          } //Component

          Component {
            id: tabButtonCompact
            Item {
              id: compactRoot
              property int tabId: -1
              property bool disabled: false
              property alias disabledTooltip: compactDisabledTooltip.text

              property alias buttonShouldBeChecked: compactButton.buttonShouldBeChecked
              property alias text: compactButton.text
              property alias tooltipText: compactButton.tooltipText
              property alias imageSource: compactButton.imageSource

              TibiaButton {
                id: compactButton
                anchors.fill: parent

                enabled: !compactRoot.disabled
                checkable: true
                useButtonShouldBeChecked: true
                buttonShouldBeChecked: root.activeTabId == tabId

                onClicked: {
                  root.requestedTabId = compactRoot.tabId;
                  root._tabCycleIndex = index
                } //onClicked

              } //TibiaButton

              TibiaDisabledOverlay {
                anchors.fill: compactRoot
                anchors.margins: 1
                visible: compactRoot.disabled
              } //TibiaDisabledOverlay

              Tooltip {
                id: compactDisabledTooltip
                anchors.fill: compactRoot
                enabled: compactRoot.disabled
              } //Tooltip
            } //Item
          } //Component

          property bool isActiveTab: root.activeTabId == modelData.tabId
          property bool textVisible: root.compactStyle && isActiveTab || !root.compactStyle

          sourceComponent: textVisible ? tabButtonNormal : tabButtonCompact
          Layout.fillHeight: true
          Layout.preferredWidth: {
            if (root.compactStyle) {
              if (isActiveTab) {
                if (root.fillWithCurrentTab) {
                  return tabLayout.width
                    - (buttonRepeater.model.length-1) * height;
                } else  {
                  return root.activeTabWidth;
                }
              } else {
                return height;
              }
            } else if (index == root.tabModel.length - 1) {
              return buttonRepeater.lastItemWidth;
            } else {
              return buttonRepeater.itemWidth;
            }
          } //Layout.preferredWidth

          onItemChanged: {
            if (item != null) {
              item.tabId = modelData.tabId;
              item.buttonShouldBeChecked = Qt.binding(function() { return isActiveTab; });
              item.text = Qt.binding(function() { return textVisible ? modelData.caption : ""; });
              item.tooltipText = modelData.tooltip;
              item.imageSource = modelData.icon;
              if (   modelData.hasOwnProperty("disabled")
                  && modelData.disabled) {
                item.disabled = modelData.disabled;

                if (modelData.hasOwnProperty("disabledTooltip")) {
                  item.disabledTooltip = modelData.disabledTooltip;
                } else {
                  item.disabledTooltip = modelData.tooltip;
                }
              }
            }
          }
        } //Loader
    } //Repeater


    BorderImage {
      source: "/images/background-dark.png"
      Layout.fillHeight: true
      Layout.fillWidth: true
      horizontalTileMode: BorderImage.Repeat
      verticalTileMode: BorderImage.Repeat
      visible: root.compactStyle
    }
  } //RowLayout
} //TibiaFrame1PixelDown
