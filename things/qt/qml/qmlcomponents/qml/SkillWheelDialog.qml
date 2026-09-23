import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qmlcomponents
import qmlenumvalues
import QtQuick.LegacyControls


TibiaDialog {
  id: root
  caption: {
    let prefix = "";
    let postfix = "";
    if (root.wheelPageController != null) {
      if (!root.isLocalPlayer) {
        prefix = qsTrId("skill_wheel_dialog_caption_name_prefix").arg(root.wheelPageController.playerName);
      } else if (root.isPreview) {
        postfix = qsTrId("skill_wheel_dialog_caption_preview_postfix");
      }
    }

    return prefix + qsTrId("skill_wheel_dialog_caption") + postfix;
  }

  width: 1000

  initialFocusItem: topButtonBar
  KeyNavigation.tab: topButtonBar
  KeyNavigation.backtab: topButtonBar

  property var controller: null
  property var activeTab: controller.dialogTab

  property var wheelPageController: controller.wheelPageController
  property var gemAtelierPageController: controller.gemAtelierPageController
  property var fragmentWorkshopPageController: controller.fragmentWorkshopPageController

  readonly property bool isLocalPlayer: wheelPageController != null && wheelPageController.isLocalPlayer
  readonly property bool isPreview: wheelPageController != null && wheelPageController.isPreview
  readonly property bool isWheelDirty: wheelPageController != null && wheelPageController.isWheelDirty
  readonly property bool canBeDecreased: wheelPageController != null && wheelPageController.canBeDecreased
  readonly property bool isPremium: controller != null && controller.isPremium

  function onApplyPressedFunction() {
    if (root.isLocalPlayer) {
      controller.onApplyClicked();
    }
  } //onApplyPressedFunction

  onCancelPressedFunction: function() {
    if (controller != null) {
      controller.requestClose();
    }
  } //onCancelPressedFunction

  onActiveTabChanged: {
    if (activeTab == SkillWheelDialogController.Wheel) {
      contentLoader.setSource("SkillWheelPage.qml",
        {"controller": root.wheelPageController})
    } else if (activeTab == SkillWheelDialogController.GemAtelier) {
      contentLoader.setSource("SkillWheelGemAtelierPage.qml",
        {"controller": root.gemAtelierPageController})
    } else if (activeTab == SkillWheelDialogController.FragmentWorkshop) {
      contentLoader.setSource("SkillWheelFragmentWorkshopPage.qml",
        {"controller": root.fragmentWorkshopPageController})
    } else {
      contentLoader.source = "";
    }
  } //onActiveTabChanged

  TibiaDialogTabBar {
    id: topButtonBar
    anchors { left: parent.left; top: parent.top; right: parent.right; }

    activeTabId: root.activeTab
    compactStyle: false

    onRequestedTabIdChanged:{
      if (controller != null) {
        controller.requestTabSwitch(requestedTabId);
      }
    } //onRequestedTabIdChanged

    tabModel: [
      {
        "tabId": SkillWheelDialogController.Wheel,
        "caption": qsTrId("skill_wheel_dialog_caption"),
        "tooltip": qsTrId("skill_wheel_dialog_caption"),
        "icon": "/images/icon-skillwheel-large.png"
      }
      , {
        "tabId": SkillWheelDialogController.GemAtelier,
        "caption": qsTrId("skill_wheel_dialog_gem_atelier_tab_caption"),
        "tooltip": qsTrId("skill_wheel_dialog_gem_atelier_tab_caption"),
        "icon": "/images/skillwheel/icon-gematelier.png",
        "disabled": controller == null || !root.isLocalPlayer,
        "disabledTooltip": qsTrId("skill_wheel_dialog_no_gem_atelier_tooltip")
      }
      , {
        "tabId": SkillWheelDialogController.FragmentWorkshop,
        "caption": qsTrId("skill_wheel_dialog_fragment_workshop_tab_caption"),
        "tooltip": qsTrId("skill_wheel_dialog_fragment_workshop_tab_caption"),
        "icon": "/images/skillwheel/icon-fragmentworkshop.png",
        "disabled": controller == null || !root.isLocalPlayer,
        "disabledTooltip": qsTrId("skill_wheel_dialog_no_fragment_workshop_tooltip")
      }
    ] //tabModel
  } //TibiaDialogTabBar

  Loader {
    id: contentLoader
    anchors { top: topButtonBar.bottom; topMargin: TibiaStyle.marginRelated;
              left: parent.left; right: parent.right; }
    height: 522

    onLoaded: {
      if (item.initialFocusItem) {
        item.initialFocusItem.forceActiveFocus();
        item.initialFocusItem.Keys.forwardTo = [topButtonBar]
      }
      if (item.hasOwnProperty("needsTabNavigation")) {
        topButtonBar.tabShortcutsActive = Qt.binding(function() { return !(item != null && item.needsTabNavigation); });
      } else {
        topButtonBar.tabShortcutsActive = true;
      }
      if (item.hasOwnProperty("isPremium")) {
        item.isPremium = Qt.binding(function() { return root.isPremium; });
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

      TibiaButton {
        Layout.preferredHeight: closeButton.height
        Layout.preferredWidth: TibiaStyle.buttonWidthStoreSmall
        color: "blue"
        imageSource: "/images/icon-store-16x10.png"
        visible: !root.isPremium && root.isLocalPlayer
        onClicked: {
          if (controller != null) {
            controller.getPremiumClicked();
          }
        } //onClicked
        tooltipText: qsTrId("get_premium")
      } //TibiaIconButton

      TibiaCurrentBalanceView {
        Layout.preferredWidth: TibiaStyle.currencyViewWidthLong
        visible: root.isLocalPlayer
        balanceType: "GoldCoin"
      } // TibiaCurrentBalanceView

      TibiaCurrentBalanceView {
        Layout.preferredWidth: TibiaStyle.currencyViewWidthLong
        visible: root.isLocalPlayer
        balanceType: "LesserFragments"
      } // TibiaCurrentBalanceView

      TibiaCurrentBalanceView {
        Layout.preferredWidth: TibiaStyle.currencyViewWidthLong
        visible: root.isLocalPlayer
        balanceType: "GreaterFragments"
      } // TibiaCurrentBalanceView

      TibiaIconButton {
        sourceUp: "/images/button-copytoclipboard-up.png"
        sourceDown: "/images/button-copytoclipboard-down.png"
        tooltipText: qsTrId("skill_wheel_dialog_copy_exportstring_to_clipboard_tooltip")

        onClicked: {
          if (controller != null ) {
            controller.requestCopyExportCodeToClipboarClicked();
          }
        } //onClicked
      } //TibiaIconButton

      RowLayout {
        spacing: TibiaStyle.marginNarrow
        visible: currentPresetNameText.text.length > 0

        TibiaText {
          text: qsTrId("skill_wheel_dialog_current_preset")
        } //TibiaText

        TibiaText {
          id: currentPresetNameText
          text: wheelPageController != null ? wheelPageController.currentPresetName : ""
        } //TibiaText
      } //RowLayout

      Item {
        // Padding
        Layout.fillWidth: true
        Layout.preferredHeight: 1
      } //Item

      Item {
        Layout.preferredWidth: okButton.width
        Layout.preferredHeight: okButton.height
        visible: root.isLocalPlayer && !root.isPreview

        TibiaButton {
          id: okButton
          text: qsTrId("ok")
          enabled: root.isWheelDirty

          onClicked: {
            if (root.isLocalPlayer) {
              controller.onOkClicked();
            }
          }
        } //TibiaButton

        Tooltip {
          anchors.fill: parent
          maxWidth: TibiaStyle.guiHelpTooltipWidth

          enabled: !okButton.enabled
          text: qsTrId("skill_wheel_dialog_no_changes")
        } //Tooltip
      } //Item

      Item {
        Layout.preferredWidth: applyButton.width
        Layout.preferredHeight: applyButton.height
        visible: root.isLocalPlayer && !root.isPreview

        TibiaButton {
          id: applyButton
          text: qsTrId("apply")
          enabled: root.isWheelDirty
          tooltipText: qsTrId("skill_wheel_dialog_save_preset_tooltip")

          onClicked: onApplyPressedFunction()
        } //TibiaButton

        Tooltip {
          anchors.fill: parent
          maxWidth: TibiaStyle.guiHelpTooltipWidth

          enabled: !applyButton.enabled
          text: qsTrId("skill_wheel_dialog_no_changes")
        } //Tooltip
      } //Item

      Item {
        Layout.preferredWidth: resetButton.width
        Layout.preferredHeight: resetButton.height
        visible: root.isLocalPlayer && !root.isPreview

        TibiaButton {
          id: resetButton
          text: qsTrId("reset")
          enabled: root.canBeDecreased

          onClicked: {
            if (controller != null) {
              controller.onResetClicked();
            }
          } //onClicked
        } //TibiaButton

        Tooltip {
          anchors.fill: parent
          maxWidth: TibiaStyle.guiHelpTooltipWidth

          enabled: !resetButton.enabled
          text: {
            if (   root.isLocalPlayer
                && !root.isPremium
                && !root.canBeDecreased) {
              return qsTrId("skill_wheel_dialog_no_change_because_no_premium");
            }
            return qsTrId("skill_wheel_dialog_why_no_reduction");
          } //text
        } //Tooltip
      } //Item

      TibiaButton {
        id: closeButton
        text: root.isWheelDirty ? qsTrId("cancel") : qsTrId("close")
        onClicked: onCancelPressedFunction()
      } //TibiaButton
    } // RowLayout
  } // ColumnLayout
} // TibiaDialog
