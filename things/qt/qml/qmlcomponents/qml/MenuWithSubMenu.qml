import QtQuick
import QtQuick.Layouts

import qmlcomponents
import qmlenumvalues

TibiaFrame1PixelDown {
  id: root
  implicitHeight: layout.height + 2 * borderWidth

  property alias categories: buttonRepeater.model
  property int textXOffset: 0
  property bool imageTopLeftCorner: false
  property var textHorizontalAlignment: Text.AlignHCenter
  property var controller: null
  property bool indentSubMenuEntries: false
  readonly property var activeCategory: controller != null ? controller.dialogCategory : TibiaEnums.NoCategoryInitialState
  readonly property bool isActive: isSubCategoryActive()

  function isSubCategoryActive() {
    for (var i=0; i < categories.count; i++) {
      if(categories.get(i).categoryId == root.activeCategory) {
        return true;
      }
    }
    return false;
  } //function isSubCategoryActive()

  function getMenuName() {
    return categories.get(0).categoryName ?? "";
  }

  function getMenuIcon() {
    return categories.get(0).categoryImageUrl ?? "";
  }

  function getMenuId() {
    return categories.get(0).categoryId ?? 0;
  }

  function hasSubMenuEntries() {
    // first entry is the menu name, further entries are considered sub menu entries
    return categories.count > 1;
  }

  ColumnLayout {
    id: layout
    anchors { left: parent.left; top: parent.top; right: parent.right }
    anchors.margins: parent.borderWidth
    spacing: 0

    TibiaButton {
      id: menuButton
      Layout.fillWidth: true

      checked: getMenuId() == root.activeCategory

      text: getMenuName()
      textHorizontalAlignment: root.textHorizontalAlignment
      textXOffset: root.textXOffset ?? 0
      rightTextXOffset: menuButtonArrowIconRight.visible && menuButtonArrowIconRight.source != ""
        ? menuButtonArrowIconRight.width : 0

      imageSource: root.getMenuIcon()
      imageAnchor: root.imageTopLeftCorner ? "lefttop" : "left"

      onClicked: {
        if (controller) {
          controller.setDialogCategory(getMenuId())
        }
      } //onClicked

      Image {
        id: menuButtonArrowIconRight
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 1 + TibiaStyle.marginRelated - (menuButton.pressed || menuButton.checked ? 1 : 0)

        source: {
          // behavior when indentSubMenuEntries is ON
          if (root.indentSubMenuEntries) {
            if (isSubCategoryActive()) {
              return menuButton.checked ? "/images/icon-arrow7x7-right.png" : ""
            }
            return menuButton.checked ? "" : "/images/icon-arrow7x7-down.png";
          }

          // behavior when indentSubMenuEntries is OFF
          if (!menuButton.checked) {
            if (!hasSubMenuEntries()) return "";
            return isSubCategoryActive() ? "" : "/images/icon-arrow7x7-down.png";
          }
          return "/images/icon-arrow7x7-right.png";
        }
      } //Image
    } //TibiaButton

    RowLayout {
      id: menuLayout
      Layout.fillWidth: true
      spacing: 0

      visible: isSubCategoryActive()

      TibiaButton {
        visible: root.indentSubMenuEntries
        Layout.preferredWidth: 12
        Layout.fillHeight: true
        enabled: false
        color: "darkgrey"
      } //TibiaButton

      ColumnLayout {
        id: subMenuLayout
        Layout.fillWidth: true
        spacing: 0

        Repeater {
          id: buttonRepeater

          delegate: TibiaButton {
            id: button

            readonly property int categoryId: model.categoryId ?? TibiaEnums.CategoryBasic
            readonly property string categoryName: model.categoryName ?? ""
            readonly property string categoryImageUrl: model.categoryImageUrl ?? ""
            readonly property int leftTextXOffset: model.leftTextXOffest ?? root.textXOffset

            Layout.fillWidth: true

            text: button.categoryName
            imageSource: button.categoryImageUrl
            imageAnchor: root.imageTopLeftCorner ? "lefttop" : "left"
            textHorizontalAlignment: root.textHorizontalAlignment
            textXOffset: button.leftTextXOffset
            rightTextXOffset: subEntryArrowIconRight.visible && subEntryArrowIconRight.source != ""
              ? subEntryArrowIconRight.width : 0

            visible: index > 0 && isSubCategoryActive()

            checked: button.categoryId == root.activeCategory

            onClicked: {
              if (controller) {
                controller.setDialogCategory(button.categoryId)
              }
            } //onClicked

            Image {
              id: subEntryArrowIconRight
              visible: !root.indentSubMenuEntries
              anchors.verticalCenter: parent.verticalCenter
              anchors.right: parent.right
              anchors.rightMargin: 1 + TibiaStyle.marginRelated - (button.pressed || button.checked ? 1 : 0)

              source: button.checked
                ? "/images/icon-arrow7x7-right.png"
                : ((index == 0) && !isSubCategoryActive() && (buttonRepeater.count > 1)
                    ? "/images/icon-arrow7x7-down.png"
                    : "")
            } //Image

            Image {
              id: arrowIconLeft
              visible: parent.checked && root.indentSubMenuEntries
              source: "/images/icon-arrow7x7-right.png"
              anchors.left: parent.left
              anchors.verticalCenter: parent.verticalCenter
              anchors.rightMargin: 3
              anchors.leftMargin: -10
            } //Image
          } //delegate: TibiaButton
        } //Repeater
      } //ColumnLayout
    } //RowLayout
  } //ColumnLayout
}
