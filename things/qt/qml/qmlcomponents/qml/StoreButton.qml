import QtQuick

import qmlcomponents


TibiaButton {
  property QtObject buttonController: panelController != null ? panelController.storeButtonController : null
  highlighted: buttonController != null && buttonController.highlighted

  text: qsTrId("store")
  textFont.bold: true
  tooltipText: qsTrId("store_button_tooltip")
  color: "blue"
  textBottomPadding: 1
  textLeftPadding: 24

  imageSource: "/images/icon-tibiastore.png"
  imageXOffset: -16

  implicitWidth: TibiaStyle.minimapViewportWidth

  onClicked: {
    if (buttonController != null) {
      buttonController.onOpenStoreButtonClicked();
    }
  } //onClicked

  TibiaRectangleHighlight {
    visible: highlighted
  } //TibiaRectangleHighlight

  ButtonHighlightAnimation {
    anchors.fill: parent
    running: highlighted   
    highlightLoops: 3
    pauseBetweenHighlights: 5000
    pauseBetweenLoops: 30000
  }
  Image {
    smooth: false
    anchors.left: parent.left
    anchors.top: parent.top
    visible: buttonController != null && buttonController.newFlag 
    source: "/images/button-store-new.png"
  } //Image

  Image {
    smooth: false
    anchors.right: parent.right
    anchors.top: parent.top
    visible: buttonController != null && buttonController.saleFlag 
    source: "/images/button-store-sale.png"
  } //Image

  Lenshelp {
    anchors.fill: parent
    caption: qsTrId("store_button_lenshelp_caption")
    content: qsTrId("store_button_lenshelp")
  } //Lenshelp
} //TibiaIconButton
