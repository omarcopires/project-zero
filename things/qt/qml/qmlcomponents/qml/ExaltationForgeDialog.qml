import QtQuick
import QtQuick.Layouts
import qmlcomponents
import qmlenumvalues


TibiaDialog {
  id: root
  caption: qsTrId("exaltation_forge_dialog_caption")
  width: 500

  property var controller: null

  property var activeTab: controller != null ? controller.dialogTab
                                             : ExaltationForgeDialogController.NoTabInitialState

  property var fusionController: controller != null ? controller.fusionController : null
  property var transferController: controller != null ? controller.transferController : null
  property var conversionController: controller != null ? controller.conversionController : null
  property var historyController: controller != null ? controller.historyController : null

  property bool readOnlyMode: controller != null ? controller.readOnlyMode : true
  property bool smoothTextureFiltering: controller != null ? controller.smoothTextureFiltering : false

  initialFocusItem: root
  KeyNavigation.tab: root
  KeyNavigation.backtab: root

  onReturnPressedFunction: function() {
  }

  onCancelPressedFunction: function() {
    if (controller != null) {
      controller.requestClose();
    }
  } //onCancelPressedFunction

  onActiveTabChanged: {
    if (contentLoader.status == Loader.Ready && contentLoader.item) {
      // Unload controller to clear bindings
      contentLoader.item.controller = null;
    }

    if (activeTab == ExaltationForgeDialogController.Fusion) {
      contentLoader.contentController = fusionController;
      contentLoader.source = "ExaltationForgeFusionPage.qml";
    } else if (activeTab == ExaltationForgeDialogController.Transfer) {
      contentLoader.contentController = transferController;
      contentLoader.source = "ExaltationForgeTransferPage.qml";
    } else if (activeTab == ExaltationForgeDialogController.Conversion) {
      contentLoader.contentController = conversionController;
      contentLoader.source = "ExaltationForgeConversionPage.qml";
    } else if (activeTab == ExaltationForgeDialogController.History) {
      contentLoader.contentController = historyController;
      contentLoader.source = "ExaltationForgeHistoryPage.qml";
    } else {
      contentLoader.contentController = null;
      contentLoader.source = "";
    }
  } //onActiveTabChanged

  TibiaDialogTabBar {
    id: topButtonBar
    anchors { left: parent.left; top: parent.top; right: parent.right; }

    activeTabId: activeTab
    compactStyle: false

    onRequestedTabIdChanged:{
      if (controller != null) {
        controller.requestTabSwitch(requestedTabId);
      }
    } //onRequestedTabIdChanged

    tabModel: [
      {
        "tabId": ExaltationForgeDialogController.Fusion,
        "caption": qsTrId("exaltation_forge_fusion_tab_caption"),
        "tooltip": qsTrId("exaltation_forge_fusion_tab_caption"),
        "icon": "/images/icon-fusion.png"
      }
      , {
        "tabId": ExaltationForgeDialogController.Transfer,
        "caption": qsTrId("exaltation_forge_transfer_tab_caption"),
        "tooltip": qsTrId("exaltation_forge_transfer_tab_caption"),
        "icon": "/images/icon-transfer.png"
      }
      , {
        "tabId": ExaltationForgeDialogController.Conversion,
        "caption": qsTrId("exaltation_forge_conversion_tab_caption"),
        "tooltip": qsTrId("exaltation_forge_conversion_tab_caption"),
        "icon": "/images/icon-conversion.png"
      }
      , {
        "tabId": ExaltationForgeDialogController.History,
        "caption": qsTrId("history"),
        "tooltip": qsTrId("history"),
        "icon": "/images/icon-history.png"
      }
    ] //tabModel
  } //TibiaDialogTabBar

  Loader {
    id: contentLoader
    anchors { top: topButtonBar.bottom; topMargin: TibiaStyle.marginRelated;
              left: parent.left; right: parent.right; }
    height: 313

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
      if (item.hasOwnProperty("readOnlyMode")) {
        item.readOnlyMode = Qt.binding(function() { return root.readOnlyMode; });
      }
      if (item.hasOwnProperty("smoothTextureFiltering")) {
        item.smoothTextureFiltering = Qt.binding(function() { return root.smoothTextureFiltering; });
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

      TibiaCurrentBalanceView {
        Layout.preferredWidth: TibiaStyle.currencyViewWidthLong
        balanceType: "GoldCoin"
      } //TibiaCurrentBalanceView

       TibiaCurrentBalanceView {
        Layout.preferredWidth: TibiaStyle.currencyViewWidthLong
        balanceType: "Dust"
      } //TibiaCurrentBalanceView

       TibiaCurrentBalanceView {
        Layout.preferredWidth: TibiaStyle.currencyViewWidthShort
        balanceType: "Slivers"
      } //TibiaCurrentBalanceView

       TibiaCurrentBalanceView {
        Layout.preferredWidth: TibiaStyle.currencyViewWidthShort
        balanceType: "ExaltedCore"
      } //TibiaCurrentBalanceView

      Item {
        // Padding
        Layout.fillWidth: true
        height: 1
      } //Item

      TibiaButton {
        text: qsTrId("close")
        onClicked: onCancelPressedFunction()
      } //TibiaButton
    } // RowLayout
  } // ColumnLayout
} // TibiaDialog
