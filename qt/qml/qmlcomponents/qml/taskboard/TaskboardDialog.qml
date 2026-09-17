import QtQuick
import QtQuick.Layouts
import qmlcomponents
import qmlenumvalues

import "qrc:/qt/qml/qmlcomponents/qml"

TibiaDialog {
  id: root
  caption: qsTrId("taskboard_caption")
  width: 1000
  
  required property var controller
  property var bountyTaskController: controller.bountyTaskController
  property var weeklyTaskController: controller.weeklyTaskController
  property var rewardShopController: controller.rewardShopController

  property var activeTab: controller.dialogTab

  initialFocusItem: topButtonBar
  KeyNavigation.tab: topButtonBar
  KeyNavigation.backtab: topButtonBar

  onReturnPressedFunction: function () {}

  onCancelPressedFunction: function () {
    if (controller != null) {
      controller.requestClose();
    }
  }

  onActiveTabChanged: {
    if (activeTab == TaskboardDialogController.BountyTasks) {
      contentLoader.setSource("BountyTaskDialogTab.qml", {
        "controller": root.bountyTaskController
      });
    } else if (activeTab == TaskboardDialogController.WeeklyTasks) {
      contentLoader.setSource("WeeklyTaskDialogTab.qml", {
        "controller": root.weeklyTaskController
      });
    } else if (activeTab == TaskboardDialogController.Shop) {
      contentLoader.setSource("TaskboardRewardShopDialogTab.qml", {
        "controller": root.rewardShopController
      });
    } else {
      contentLoader.source = "";
    }
  }

  TibiaDialogTabBar {
    id: topButtonBar
    anchors {
      left: parent.left
      top: parent.top
      right: parent.right
    }

    activeTabId: activeTab
    
    buttonImageXOffset: 5
    compactStyle: false
    activeTabWidth: TibiaStyle.dialogTabBarHugeWidth

    onRequestedTabIdChanged: {
      if (controller != null) {
        controller.requestTabSwitch(requestedTabId);
      }
    }

    tabModel: [
      {
        "tabId": TaskboardDialogController.BountyTasks,
        "caption": qsTrId("taskboard_bountytasks_function"),
        "tooltip": qsTrId("taskboard_bountytasks_function"),
        "icon": "/images/taskboard/icon-bountytasks.png"
      },
      {
        "tabId": TaskboardDialogController.WeeklyTasks,
        "caption": qsTrId("taskboard_weeklytasks_function"),
        "tooltip": qsTrId("taskboard_weeklytasks_function"),
        "icon": "/images/taskboard/icon-weeklytasks.png"
      },
      {
        "tabId": TaskboardDialogController.Shop,
        "caption": qsTrId("taskboard_shop_function"),
        "tooltip": qsTrId("taskboard_shop_function"),
        "icon": "/images/taskboard/icon-huntingtaskshop.png"
      }
    ]
  }

  Item {
    id: contentArea
    height: 504
    anchors {
      top: topButtonBar.bottom
      topMargin: TibiaStyle.marginRelated
      left: parent.left
      right: parent.right
    }

    Loader {
      id: contentLoader
      anchors.fill: parent

      onLoaded: {
        if (item.initialFocusItem) {
          item.initialFocusItem.forceActiveFocus();
        }
        if (item.hasOwnProperty("onCancelPressedFunction")) {
          item.onCancelPressedFunction = root.onCancelPressedFunction;
        }
        if (item.hasOwnProperty("needsTabNavigation")) {
          topButtonBar.tabShortcutsActive = Qt.binding(function () {
            return !(item != null && item.needsTabNavigation);
          });
        } else {
          topButtonBar.tabShortcutsActive = true;
        }
      }
    }
  }

  ColumnLayout {
    id: buttonLayout
    spacing: TibiaStyle.marginUnrelated
    anchors {
      left: parent.left
      right: parent.right
      top: contentArea.bottom
      topMargin: TibiaStyle.marginUnrelated
    }

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    }

    RowLayout {
      id: buttonBar
      Layout.fillWidth: true
      spacing: TibiaStyle.marginRelated


      TibiaCurrencyView {
        Layout.preferredWidth: TibiaStyle.currencyViewWidthLong
        balance: controller.bountyPointsString ? controller.bountyPointsString : "-"
        rightAligned: true
        iconId: "BountyPoints"
      }

      TibiaCurrencyView {
        Layout.preferredWidth: TibiaStyle.currencyViewWidthLong
        balance: controller != null && controller.preyHuntingTaskTokensString ? controller.preyHuntingTaskTokensString : "-"
        rightAligned: true
        iconId: "PreyHuntingTaskTokens"
      }

      TibiaCurrencyView {
        Layout.preferredWidth: TibiaStyle.currencyViewWidthLong
        balance: controller.soulSealsString ? controller.soulSealsString : ""
        rightAligned: true
        iconId: "SoulSeals"
      }


      Item {
        Layout.fillWidth: true
      }

      TibiaButton {
        text: qsTrId("close")
        onClicked: onCancelPressedFunction()
      }
    }
  }
}
