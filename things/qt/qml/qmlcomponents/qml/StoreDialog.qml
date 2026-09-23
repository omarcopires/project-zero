import QtQuick
import QtQuick.Layouts

import qmlcomponents



TibiaDialog {
  id: root
  caption: qsTrId("store_caption")
  width: 780

  property var controller: null
  property var dynamicallyLoadedImageManager: controller != null ? controller.dynamicallyLoadedImageManager : null
  property var transactionPage: controller != null ? controller.transactionPage : null
  readonly property var selectedCategoryName: controller != null ? controller.selectedCategoryName
                                                                 : qsTrId("store_home_catergory_name")

  onReturnPressedFunction: function() {}
  onCancelPressedFunction: onCloseClicked
  KeyNavigation.tab: searchInput
  KeyNavigation.backtab: searchInput
  initialFocusItem: contentLoader.item != null && contentLoader.item.initialFocusItem != null ? contentLoader.item.initialFocusItem : searchInput

  function onCloseClicked() {
    if (controller != null) {
      controller.requestClose();
    }
  } //function onCancelClicked

  function onHistoryClicked() {
    switchContentPage("StoreTransactionHistoryPage.qml");

    if (controller != null) {
      controller.openTransactionHistory()
    }
  } //function onHistoryClicked()

  function switchContentPage(QmlSource) {
    if (contentLoader.status == Loader.Ready && contentLoader.item) {
      contentLoader.item.controller = null;
      contentLoader.source = "";
      // Controller is set again when loader has finished loading
    }

    contentLoader.source = QmlSource;
  } // function switchContentPage

  function onSearchClicked() {
    if (controller != null && searchButton.enabled) {
      controller.requestSearch(searchInput.text);
      searchInput.text = "";
    }
  } //function onCancelClicked

  function selectCategoryInController(CategoryName) {
    if (controller != null) {
      controller.selectCategory(CategoryName)
    }
  }

  onSelectedCategoryNameChanged: {
    if (selectedCategoryName == qsTrId("store_home_catergory_name")) {
      // Show special HOME category
      switchContentPage("StoreMainPage.qml");
      if (root.visible) {
        // Only force focus if dialog is visible to prevent stealing it from other dialogs
        searchInput.forceActiveFocus();
      }
    } else if (selectedCategoryName == qsTrId("store_search_result_catergory_name")) {
      switchContentPage("StoreOfferPage.qml");
    }  else if (selectedCategoryName.length > 0) {
      // Show selected normal cagetory
      switchContentPage("StoreOfferPage.qml");
    }
  } // onActiveCategoryChanged

  ColumnLayout {
    anchors { left: parent.left; top: parent.top; right: parent.right }
    spacing: TibiaStyle.marginUnrelated

    RowLayout {
      Layout.fillWidth: true
      spacing: TibiaStyle.marginRelated

      TibiaFrame2PixelUpFilled {
        id: navigation
        Layout.preferredWidth: 180
        readonly property int margin: borderWidth + TibiaStyle.marginRelated
        dark: true

        Layout.fillHeight: true

        ColumnLayout {
          anchors { left: parent.left; top: parent.top; right: parent.right }
          anchors.margins: parent.margin
          spacing: 0 //margins set with Layout.bottomMargin as spacing sometimes leads to wrong margins
          clip: true

          Repeater {
            Layout.fillHeight: true
            model: controller != null ? controller.categoryList : null

            StoreCategoryWithSubcategory {
              Layout.fillWidth: true
              Layout.bottomMargin: TibiaStyle.marginUnrelated
              category: modelData
              activeCategory: root.selectedCategoryName
              selectedCategoryFunction: selectCategoryInController
              dynamicallyLoadedImageManager: root.dynamicallyLoadedImageManager
            } //StoreCategoryWithSubcategory
          } //Repeater

          StoreCategoryWithSubcategory {
            Layout.fillWidth: true
            visible: selectedCategoryName == qsTrId("store_search_result_catergory_name")
            category: controller != null ? controller.searchResultCategory : null
            activeCategory: root.selectedCategoryName
          } //StoreCategoryWithSubcategory
        } //ColumnLayout

        TibiaFrame1PixelDown {
          anchors { left: parent.left; bottom: parent.bottom; right: parent.right }
          anchors.margins: parent.margin
          height: TibiaStyle.buttonHeightDefault + 2*borderWidth

          TibiaButton {
            id: searchButton
            anchors {top: parent.top; right: parent.right}
            anchors.margins: parent.borderWidth
            height: parent.height - 2*parent.borderWidth
            width: height
            imageSource: "/images/icon-search.png"
            enabled: searchInput.text.length >= 3

            onClicked: root.onSearchClicked()

            TibiaDisabledOverlay {
              anchors.fill: parent
              anchors.margins: 1
              visible: !parent.enabled
            } //TibiaDisabledOverlay
          } //TibiaButton

          TibiaTextField {
            id: searchInput
            anchors { left:parent.left; top: parent.top; right: searchButton.left; bottom: parent.bottom}
            anchors.rightMargin: -1
            z: -1
            KeyNavigation.tab: contentLoader.item && contentLoader.item.initialFocusItem
                               ? contentLoader.item.initialFocusItem : searchInput
            KeyNavigation.backtab: contentLoader.item && contentLoader.item.initialFocusItem
                               ? contentLoader.item.initialFocusItem : searchInput
            maximumLength: TibiaStyle.maxTextFieldDefaultLength
            placeholderText: qsTrId("type_to_search_placeholder")

            Keys.onEnterPressed: root.onSearchClicked()
            Keys.onReturnPressed: root.onSearchClicked()
          } //TibiaTextField
        } //TibiaFrame1PixelDown
      } //TibiaFrame2PixelUpFilled

      TibiaFrame2PixelUpFilled {
        Layout.fillWidth: true
        Layout.preferredHeight: 450

        Loader {
          id: contentLoader
          anchors.fill: parent
          anchors.margins: parent.borderWidth + TibiaStyle.marginRelated

          property var contentController: controller

          onLoaded: {
            item.controller = Qt.binding(function() { return contentLoader.contentController; });
            if (item.initialFocusItem) {
              item.initialFocusItem.forceActiveFocus();
            }
            if (item.parentFocusItem !== undefined) {
              item.parentFocusItem = Qt.binding(function() { return searchInput; });
            }
          } //onLoaded
        } //Loader
      } //TibiaFrame2PixelUpFilled

    } //RowLayout

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } //TibiaHorizontalSeparator

    RowLayout {
      Layout.alignment: Qt.AlignRight
      spacing: TibiaStyle.marginRelated

      TibiaCurrentBalanceView {
        Layout.preferredWidth: TibiaStyle.currencyViewWidthVeryLong
        balanceType: "TibiaCoinLong"
      } //TibiaCurrentBalanceView

      TibiaGetCoinsButton {
        Layout.preferredWidth: TibiaStyle.buttonWidthBroad
        onClicked: {
          if (controller != null) {
            controller.openGetCoinsUrl();
          }
        } //onClicked
      } //TibiaGetCoinsButton

      TibiaButton {
        Layout.preferredWidth: TibiaStyle.buttonWidthBroad
        imageSource: "/images/skin/classic/icon-transfercoins.png"
        tooltipText: qsTrId("store_transfer_coins_tooltip")

        onClicked: {
          if (controller != null) {
            controller.requestTransferCredits();
          }
        } //onClicked
      } //TibiaIconButton

      TibiaButton {
        id: tradeCharacterButton
        Layout.preferredWidth: TibiaStyle.buttonWidthBroad
        imageSource: "/images/icon-charactertrade.png"
        tooltipText: qsTrId("store_trade_character_tooltip")

        onClicked: {
          if (controller != null) {
            controller.requestTradeCharacter();
          }
        } //onClicked
      } // TibiaButton

      Item {Layout.fillWidth: true}

      TibiaButton {
        id: transactionHistoryButton
        text: qsTrId("history")
        enabled: controller != null && !controller.transactionHistoryLoading
        onClicked: root.onHistoryClicked()
      } // TibiaButton

      TibiaButton {
        id: closeButton
        text: qsTrId("close")
        onClicked: root.onCloseClicked()
      } // TibiaButton
    } // RowLayout
  } //ColumnLayout
} //TibiaDialog
