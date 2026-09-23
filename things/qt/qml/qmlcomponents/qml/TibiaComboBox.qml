import QtQuick
import QtQuick.Controls.Basic

import qmlcomponents

ComboBox {
  id: root

  property var textHorizontalAlignment: Text.AlignHCenter
  property var textVerticalAlignment: Text.AlignVCenter
  property int popupMaxHeight: 400

  implicitWidth: 200
  implicitHeight: TibiaStyle.comboBoxHeight

  //helps to give the combo box its correct index if used from outside
  property int shouldBeCurrentIndex: 0
  onShouldBeCurrentIndexChanged: {
    if (currentIndex != shouldBeCurrentIndex) {
      currentIndex = shouldBeCurrentIndex;
    }
  } //onButtonShouldBeCheckedChanged

  onVisibleChanged: {
    if (!visible) {
      // Changing visibility from true to false might be an indicator that the combo box and their parent
      // elements are about to be destroyed, so make sure the combo box popup is destroyed before to avoid any
      // dangling mouse event handlers causing crashes.
      closePopup()
    }
  }

  onCountChanged: {
    closePopup()
  }

  // If the menu popup is currently opened, it will be closed and properly destroyed using this function.
  function closePopup()
  {
    if (popup.opened) {
      popup.close()
    }
  } //function closePopup()

  TibiaWheelHandler {
    onWheel: (event) => {
      var changeFunction = event.angleDelta.y < 0 ? root.incrementCurrentIndex : root.decrementCurrentIndex;
      changeFunction()
      if (root.popup.opened) {
        // If the popup is open, the incremnt function only touches the highlighted index. For compatibility with old
        // behaviour, the active index is also changed here.
        if (root.currentIndex != root.highlightedIndex) {
          root.currentIndex = root.highlightedIndex
          root.activated(root.currentIndex)
        }
      }
    }
  }

  background: BorderImage {
    id: backgroundImage
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    border { left: 1; top: 1; right: 1; bottom: 1 }
    horizontalTileMode: BorderImage.Repeat
    verticalTileMode: BorderImage.Repeat
    source: root.pressed || popup.opened ? "/images/skin/classic/button-9grid-pressed.png" : "/images/skin/classic/button-9grid-idle.png"
    smooth: false
  } //background: BorderImage

  indicator: BorderImage {
    id: dropDownButton
    width: height
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.right: parent.right
    border { left: 1; top: 1; right: 1; bottom: 1 }
    horizontalTileMode: BorderImage.Stretch
    verticalTileMode: BorderImage.Stretch
    source: root.pressed || popup.opened ? "/images/skin/classic/button-dropdown-20x20-pressed.png" : "/images/skin/classic/button-dropdown-20x20-idle.png"
    smooth: false
  } // indicator: BorderImage

  contentItem: TibiaText {
    horizontalAlignment: textHorizontalAlignment
    verticalAlignment: textVerticalAlignment
    text: root.currentText
    width: parent.width - parent.height - TibiaStyle.marginRelated
  } // contentItem: TibiaText

  delegate: ItemDelegate {
    id: itemDelegate
    required property var model
    required property int index

    width: root.width
    padding: TibiaStyle.marginNarrow
    leftPadding: TibiaStyle.marginRelated

    background: Rectangle {
      width: root.width
      color: root.highlightedIndex === index ? TibiaStyle.comboBoxSelectionColor : "transparent"
    }

    contentItem: TibiaText {
      color: root.highlightedIndex === index ? TibiaStyle.textFieldSelectionTextColor : TibiaStyle.textFieldTextColor
      text: itemDelegate.model[root.textRole]
    }
  } //delegate

  popup.background: Optimized1PixelBorderImage {
    borderimagesource: "/images/skin/classic/button-9grid-pressed.png"
  }

  popup.contentItem: TibiaScrollView {
    id: control
    implicitHeight: Math.min(listView.contentHeight, popupMaxHeight)
    verticalScrollBarPolicy: ScrollBar.AsNeeded
    ListView {
      id: listView
      clip: true
      model: root.delegateModel
      currentIndex: root.highlightedIndex
      highlightMoveDuration: 0

      interactive: false //prevent flick behavior on touch screens
      boundsBehavior: Flickable.StopAtBounds
    }
  }
} //ComboBox
