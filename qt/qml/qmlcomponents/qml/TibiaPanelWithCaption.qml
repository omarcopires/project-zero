import QtQuick
import QtQuick.Layouts




ColumnLayout {
  signal expandButtonClicked();
  property alias contentDelegate: contentLoader.sourceComponent
  property alias contentItem: contentLoader.item
  property alias caption: borderFrame.caption
  property alias expanded: expandButton.checked
  property alias shouldBeExpanded: expandButton.buttonShouldBeChecked
  property alias collapsible: expandButton.visible
  property alias mouseAreaEnabled: mouseArea.enabled
  property bool fillHeight: false
  property bool useWidthFromContentItem: false
  property int  innerMargin: TibiaStyle.marginRelated

  state: useWidthFromContentItem ? "useWidthFromContentItem" : ""

  states: State {
      name: "useWidthFromContentItem"

      // AnchorChanges {
      //   target: contentLoader
      //   anchors.right: undefined
      // }
      PropertyChanges {
        target: borderFrame
        Layout.fillWidth: false
        Layout.preferredWidth: (contentLoader.item != null ? contentLoader.item.width + 2 * innerMargin + 2 * borderWidth : 0)
      }
  }


  TibiaFrame2PixelUpFilledWithCaption {
    id: borderFrame

    Layout.fillWidth: true
    Layout.preferredWidth: parent.width

    Layout.alignment: Qt.AlignTop | Qt.AlignLeft
    Layout.preferredHeight: (contentLoader.item != null ? contentLoader.item.height + captionHeight + 2 * innerMargin + borderWidth : captionHeight + 2)
    Layout.fillHeight: fillHeight
    
    TibiaIconButton {
      id: expandButton
      anchors.top: parent.top
      anchors.right: parent.right
      anchors.margins: 3
      checkable: true
      sourceUp:   "/images/skin/classic/button-expand-12x12-up.png"
      sourceDown: "/images/skin/classic/button-expand-12x12-down.png"
      onClicked: {
        expandButtonClicked();
      }
    } //TibiaIconButton

    MouseArea {
      id: mouseArea
      anchors {top: parent.top; left: parent.left; right: parent.right;}
      height: borderFrame.captionHeight
      acceptedButtons: Qt.LeftButton
      onClicked: {
        expandButton.checked = !expandButton.checked;
        expandButtonClicked();
      }

      hoverEnabled: true
      onEntered: {
        if (tibiaMouseCursorController != null) {
          tibiaMouseCursorController.setPointingHand(true);
        }
      } //onEntered
      onExited: {
        if (tibiaMouseCursorController != null) { 
          tibiaMouseCursorController.setPointingHand(false);
        }
      } //onExited
    } //MouseArea

    Loader {
      id: contentLoader
      active: expandButton.visible == false || expandButton.checked
      anchors.left: parent.left

      // AnchorChanges don't seem to work for the loader here
      // we have to set the binding directly
      anchors.right: useWidthFromContentItem ? undefined : parent.right

      anchors.top: parent.top
      anchors.bottom: fillHeight ? parent.bottom : undefined
      anchors.rightMargin: borderFrame.borderWidth + innerMargin
      anchors.leftMargin: borderFrame.borderWidth + innerMargin
      anchors.topMargin: parent.captionHeight + innerMargin
      anchors.bottomMargin: borderFrame.borderWidth + innerMargin
    } //Loader
  } //TibiaFrame2PixelUpFilledWithCaption
} //ColumnLayout
