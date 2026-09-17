import QtQuick
import QtQuick.Layouts

import qmlcomponents


TibiaFrame1PixelDown {
  id: root
  implicitHeight: layout.height + 2 * borderWidth

  property var category: null
  property string activeCategory: ""
  property var selectedCategoryFunction: null
  property var dynamicallyLoadedImageManager: null

  function isSubcategoryActive() {
    if (category == null) {
      return false;
    }
    var subcategories = category.subcategoryList;
    for (var i=0; i < subcategories.length; i++) {
      if(subcategories[i].name == root.activeCategory) {
        return true;
      }
    }
    return false;
  } //function isSubCategoryActive()

  ColumnLayout {
    id: layout
    anchors { left: parent.left; top: parent.top; right: parent.right }
    anchors.margins: parent.borderWidth
    spacing: 0

    TibiaButton {
      id: mainButton
      Layout.fillWidth: true

      textHorizontalAlignment: Text.AlignLeft
      textLeftPadding: 24
      textStyle: checked ? "Default" : "Dialog"
      textFont: TibiaStyle.defaultTextFont
      text: category != null ? category.name : ""

      checked: text == root.activeCategory

      imageAnchor: "right"
      imageSource:    category != null
                   && category.subcategoryList.length > 0
                   && !root.isSubcategoryActive() ? "/images/icon-arrow7x7-down.png"
                                                  : ""

      onClicked: {
        if (selectedCategoryFunction != null) {
          selectedCategoryFunction(text);
        }
      } //onClicked

      Item {
        id: iconWrapper
        anchors.left: parent.left
        anchors.verticalCenter : parent.verticalCenter
        anchors.leftMargin: 1 + TibiaStyle.marginRelated + (parent.pressed || parent.checked ? 1 : 0)
        anchors.verticalCenterOffset: (parent.pressed || parent.checked ? 1 : 0)
        height: dynamicIcon.tinySize13
        width:  dynamicIcon.tinySize13

        Image {
          id: staticIcon
          visible: mainButton.text == qsTrId("store_home_catergory_name")
                || mainButton.text == qsTrId("store_search_result_catergory_name")

          source: {
            if (mainButton.text == qsTrId("store_home_catergory_name")) {
              return "/images/icon-store-home.png"
            } else if (mainButton.text == qsTrId("store_search_result_catergory_name")) {
              return "/images/icon-store-search-result.png"
            }
            return "";
          }
        } //Image

        DynamicallyLoadedImage {
          id: dynamicIcon
          anchors.fill: parent
          visible: !staticIcon.visible

          dynamicallyLoadedImageManager: root.dynamicallyLoadedImageManager
          imageKey: category != null && category.imageIdentifiers.length > 0 ? category.imageIdentifiers[0] : ""
        } //DynamicallyLoadedImage
      } //Item
    } //TibiaButton

    RowLayout {
      Layout.fillWidth: true
      spacing: 0
      visible: root.isSubcategoryActive()

      TibiaButton {
        Layout.preferredWidth: 12
        Layout.fillHeight: true
        enabled: false
        color: "darkgrey"
      } //TibiaButton

      ColumnLayout {
        Layout.fillWidth: true
        spacing: 0

        Repeater {
          model: category != null ? category.subcategoryList : null

          TibiaButton {
            Layout.fillWidth: true
            textHorizontalAlignment: Text.AlignLeft
            textLeftPadding: 24
            textFont: TibiaStyle.defaultTextFont

            text: modelData != null ? modelData.name : ""
            checked: text == root.activeCategory
            textStyle: checked ? "Default" : "Dialog"

            onClicked: {
              if (selectedCategoryFunction != null) {
                selectedCategoryFunction(text);
              }
            } //onClicked

            Image {
              visible: parent.checked
              source: "/images/icon-arrow7x7-right.png"
              anchors.right: parent.left
              anchors.verticalCenter: parent.verticalCenter
              anchors.rightMargin: 3
            } //Image

            DynamicallyLoadedImage {
              anchors.left: parent.left
              anchors.verticalCenter : parent.verticalCenter
              anchors.leftMargin: 1 + TibiaStyle.marginRelated + (parent.pressed || parent.checked ? 1 : 0)
              anchors.verticalCenterOffset: (parent.pressed || parent.checked ? 1 : 0)
              height: tinySize13
              width: tinySize13

              dynamicallyLoadedImageManager: root.dynamicallyLoadedImageManager
              imageKey: modelData != null && modelData.imageIdentifiers.length > 0 ? modelData.imageIdentifiers[0] : ""
            } //DynamicallyLoadedImage
          } //TibiaButton
        } //Repeater
      } //ColumnLayout
    } //RowLayout
  } //ColumnLayout
} //TibiaFrame1PixelDown
