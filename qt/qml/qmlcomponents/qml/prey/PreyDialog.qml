import QtQuick
import QtQuick.Layouts
import qmlcomponents
import qmlenumvalues

import "qrc:/qt/qml/qmlcomponents/qml"

TibiaDialog {
  id: preyDialog
  caption: qsTrId("prey_caption")
  width: 698

  property var controller: null

  property var activeTab: (controller != null
                            ? controller.activeTab
                            : PreyDialogController.NoTabInitialState)
  property var availableTabs: [ PreyDialogController.PreyCreatures ]

  property var preyPageController: controller != null ? controller.preyPageController : null

  onReturnPressedFunction: function() {
  }

  onCancelPressedFunction: function() {
    if (controller != null) {
      controller.requestClose();
    }
  }

  function incrementOrDecrementTabCycleIndex(valueChange) {
    var tabIndex = availableTabs.indexOf(activeTab);
    var newIndex = tabIndex + valueChange;
    if (newIndex < 0) {
      newIndex = availableTabs.length - 1;
    } else if (newIndex >= availableTabs.length) {
      newIndex = 0;
    }
    if (controller != null) {
      controller.requestTabSwitch(availableTabs[newIndex])
    }
  }

  function switchToNextTab()
  {
    incrementOrDecrementTabCycleIndex(1);
  }

  function switchToPreviousTab()
  {
    incrementOrDecrementTabCycleIndex(-1);
  }

  Shortcut {
    sequence: "Tab"
    onActivated: {
      switchToNextTab()
      SoundHelper.playSound(SoundHelper.BUTTON_PRESS);
    }
  }

  Shortcut {
    sequence: "Shift+Tab"
    onActivated: {
      switchToPreviousTab()
      SoundHelper.playSound(SoundHelper.BUTTON_PRESS);
    }
  }

  Keys.onTabPressed: switchToNextTab()
  Keys.onBacktabPressed: switchToPreviousTab()

  onActiveTabChanged: {
    if (contentLoader.status == Loader.Ready && contentLoader.item) {
      // Unload controller to clear bindings
      contentLoader.item.controller = null;
    }

    if (activeTab == PreyDialogController.PreyCreatures) {
      contentLoader.contentController = preyPageController;
      contentLoader.source = "PreyPreyPage.qml";
    } else {
      contentLoader.contentController = null;
      contentLoader.source = "";
    }
  }

  initialFocusItem: preyDialog

  TibiaFrame1PixelDown {
    id: topButtonBar
    height: 36
    anchors { left: parent.left; top: parent.top; right: parent.right; }

    property int buttonImageXOffset: 0
    property int buttonTextXOffset: 10
    property int childItems: topButtonsModel.length
    property int itemWidth: (width - borderWidth * 2) / childItems
    property int itemHeight: height - borderWidth * 2

    property var topButtonsModel: [
      {
        "id": PreyDialogController.PreyCreatures,
        "caption": qsTrId("prey_preyview_function"),
        "icon": "/images/icon-prey-preycreature.png"
      }
    ]


    RowLayout {
      id: topButtonBarLayout
      spacing: 0
      anchors { top: parent.top;  left: parent.left; right: parent.right }
      anchors.margins: topButtonBar.borderWidth

      Repeater {
        id: buttonRepeater
        Loader {
          property bool isLast: index + 1 < buttonRepeater.count ? false : true

          Component {
            id: topButtonBarButtonComponent
            TibiaButton {
              property int buttonForTab: PreyDialogController.NoTabInitialState

              textFont: TibiaStyle.defaultTextFont
              imageAnchor: "left"
              imageXOffset: topButtonBar.buttonImageXOffset
              textXOffset: topButtonBar.buttonTextXOffset

              checkable: true
              useButtonShouldBeChecked: true
              buttonShouldBeChecked: activeTab == buttonForTab

              onClicked: {
                if (controller != null) {
                  controller.requestTabSwitch(buttonForTab);
                }
              }
            } //TibiaButton
          }
          sourceComponent: topButtonBarButtonComponent
          Layout.preferredWidth: topButtonBar.itemWidth
          Layout.fillWidth: true
          Layout.preferredHeight: topButtonBar.itemHeight
          onItemChanged: {
            if (item != null) {
              item.buttonForTab = modelData.id;
              item.text = modelData.caption;
              item.imageSource = modelData.icon
            }
          }
        }
        model: topButtonBar.topButtonsModel
      }
    } // RowLayout
  } // TibiaFrame1PixelDown

  Loader {
    id: contentLoader
    anchors { top: topButtonBar.bottom; topMargin: TibiaStyle.marginRelated;
              left: parent.left; right: parent.right; }
    height: 440

    property var contentController: null

    onLoaded: {
      item.controller = Qt.binding(function() { return contentLoader.contentController; });
      if (item.initialFocusItem) {
        item.initialFocusItem.forceActiveFocus();
      }
    }
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
        Layout.preferredWidth: TibiaStyle.currencyViewWidthShort
        balanceType: "PreyWildcards"
      } //TibiaCurrencyView

      TibiaButton {
        Layout.preferredHeight: closeButton.height
        Layout.preferredWidth: TibiaStyle.buttonWidthStoreSmall
        color: "blue"
        imageSource: "/images/icon-store-16x10.png"
        onClicked: { if (controller != null) controller.getMorePreyWildcardsClicked(); }
        tooltipText: qsTrId("prey_get_more_prey_wildcards_tooltip")
      } //TibiaIconButton

      Item {
        // Padding
        Layout.fillWidth: true
        height: 1
      }

      TibiaButton {
        id: closeButton
        text: qsTrId("close")
        onClicked: onCancelPressedFunction()
      }
    } // RowLayout
  } // ColumnLayout
} // TibiaDialog
