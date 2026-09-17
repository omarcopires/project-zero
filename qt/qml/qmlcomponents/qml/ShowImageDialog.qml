import QtQuick
import QtQuick.Layouts

import qmlcomponents

TibiaDialog {
  id: root
  caption: controller != null ? controller.caption : ""

  width: mainContentLayout.width + 2 * TibiaStyle.dialogMarginBorder
  showCaption: controller != null ? controller.showCaption : true

  initialFocusItem: root
  KeyNavigation.tab: root
  KeyNavigation.backtab: root

  property var controller: null

  property bool showDragonHeader: controller != null ? controller.showDragonHeader : false
  property bool showCrestHeader: controller != null ? controller.showCrestHeader : false
  property string bannerPath: controller != null ? controller.bannerPath : ""
  property int imageCount: controller != null ? controller.imageCount : 1
  property var imageTabIcons: controller != null ? controller.imageTabIcons : []

  property int currentIndex: controller != null ? controller.currentIndex : 0
  property string currentImage: controller != null ? controller.currentImagePath : ""

  onCancelPressedFunction: function () {
    if (controller != null) {
      controller.requestClose();
    }
  } //onCancelPressedFunction

  Component {
    id: dragonHeaderComponent
    DialogHeaderDragon {
    }
  } //Component

  Component {
    id: crestHeaderComponent
    DialogHeaderCrest {
    }
  } //Component

  headerDelegate: {
    if (root.showDragonHeader) {
      return dragonHeaderComponent;
    } else if (root.showCrestHeader) {
      return crestHeaderComponent;
    }
    return null;
  }

  ColumnLayout {
    id: mainContentLayout

    spacing: TibiaStyle.marginRelated

    Item {
      Layout.preferredHeight: TibiaStyle.dialogContentToFrameMargin - mainContentLayout.spacing
        + (bannerImage.visible ? 0 : 10)
      visible: root.showCrestHeader
    } //Item

    Image {
      id: bannerImage
      Layout.alignment: Qt.AlignHCenter
      source: root.bannerPath

      visible: source != ""
    } //Image

    RowLayout {
      id: iconsTabLayout
      Layout.fillWidth: true
      Layout.preferredHeight: TibiaStyle.buttonHeightAppearance
      Layout.bottomMargin: TibiaStyle.marginNarrow
      spacing: TibiaStyle.marginNarrow
      visible: imageCount > 1

      Repeater {
        model: imageTabIcons

        delegate: TibiaButton {
          Layout.preferredWidth: TibiaStyle.buttonHeightAppearance
          Layout.preferredHeight: TibiaStyle.buttonHeightAppearance
          imageSource: modelData
          checkable: true
          enabled: false
          checked: index == currentIndex
        }
      } //Repeater

      Item {
        Layout.fillWidth: true
      } //Item
    } //RowLayout

    TibiaFrame1PixelDown {
      Layout.preferredWidth: contentImage.width + 2 * borderWidth
      Layout.preferredHeight: contentImage.height + 2 * borderWidth

      Image {
        id: contentImage
        x: parent.borderWidth
        y: parent.borderWidth

        source: root.currentImage
      } //Image
    } //TibiaFrame1PixelDown
  } //ColumnLayout

  ColumnLayout {
    id: buttonLayout
    spacing: TibiaStyle.marginUnrelated
    anchors {
      left: parent.left; right: parent.right; top: mainContentLayout.bottom; topMargin: TibiaStyle.marginRelated
    }

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } // TibiaHorizontalSeparator

    RowLayout {
      id: buttonBar
      Layout.fillWidth: true
      spacing: TibiaStyle.marginRelated

      Item {
        // Padding
        Layout.fillWidth: true
        height: 1
      } //Item

      TibiaButton {
        text: qsTrId("back")
        enabled: root.currentIndex > 0
        visible: root.imageCount > 1
        onClicked: {
          if (controller != null) {
            controller.backClicked();
          }
        }
      } //TibiaButton

      TibiaButton {
        id: nextButton
        text: qsTrId("next")
        enabled: root.currentIndex < root.imageCount
        visible: root.imageCount > 1 && root.currentIndex < root.imageCount - 1
        onClicked: {
          if (controller != null) {
            controller.nextClicked();
          }
        }
      } //TibiaButton

      TibiaButton {
        id: closeButton
        visible: !nextButton.visible
        text: qsTrId("close")
        onClicked: onCancelPressedFunction()
      } //TibiaButton
    } // RowLayout
  } // ColumnLayout
} // TibiaDialog
