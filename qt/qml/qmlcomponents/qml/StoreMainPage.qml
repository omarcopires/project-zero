import QtQuick
import QtQuick.Layouts

import qmlcomponents


Item {
  id: root

  property var controller: null
  property var autoScrollFeaturedOffers: true;

  KeyNavigation.tab: root

  onAutoScrollFeaturedOffersChanged: {
    if (autoScrollFeaturedOffers) {
      featuredOfferTimer.restart();
    } else {
      featuredOfferTimer.stop();
    }
  }

  ColumnLayout {
    id: contentLayout
    anchors.fill: parent
    spacing: TibiaStyle.marginRelated

    TibiaFrame1PixelDown {
      id: imageContainer
      Layout.fillWidth: true
      Layout.preferredHeight: 200
      property var showDummyImage: true
      clip: true

      Timer {
        id: featuredOfferTimer
        repeat: true
        interval: controller != null ? controller.displayTimePerFeature : 1000
        running: true

        onTriggered: {
          if (controller != null) {
            controller.getNextFeaturedOffer();
          }
        } // onTriggered
      } // Timer

      MouseArea {
        anchors.fill: parent
        anchors.margins: parent.borderWidth
        hoverEnabled: true

        onEntered: {
          if (tibiaMouseCursorController != null) { tibiaMouseCursorController.setPointingHand(true); }
          root.autoScrollFeaturedOffers = false;
        }

        onExited: {
          if (tibiaMouseCursorController != null) { tibiaMouseCursorController.setPointingHand(false); }
          root.autoScrollFeaturedOffers = true;
        }

        onClicked: {
          if (controller != null) {
            if (tibiaMouseCursorController != null) { tibiaMouseCursorController.setPointingHand(false); }
            controller.onFeaturedOfferClicked();
          }
        } // onClicked
      } // MouseArea

      Repeater {
        model: controller != null ? controller.featuredOffers : null
        anchors.fill: parent
        anchors.margins: parent.borderWidth
        Image {
          source: modelData
          visible: controller != null ? (index == controller.featuredOfferIndex) : false
          anchors.centerIn: parent


          onStatusChanged: {
            if (visible && status == Image.Ready) {
              imageContainer.showDummyImage = false;
            }
          } // onStatusChanged

          onVisibleChanged: {
            if (visible && status != Image.Ready) {
              imageContainer.showDummyImage = true;
            }
            if (visible && status == Image.Ready) {
              imageContainer.showDummyImage = false;
            }
          } // onVisibleChanged
        } // Image
      } // Repeater

      Image {
        visible: imageContainer.showDummyImage
        source: "/images/dynamic/dynamic-image-loading.png"
        anchors.centerIn: parent
      } // Image

      MouseArea {
        id: leftButtonMouseArea
        anchors { left: parent.left; verticalCenter: parent.verticalCenter; }
        width: leftButton.width * 3
        height: leftButton.height * 3
        hoverEnabled: true
        visible: !imageContainer.showDummyImage && controller != null && controller.featuredOffers.length > 1

        onClicked: {
          if (controller != null) {
            featuredOfferTimer.restart();
            controller.getPreviousFeaturedOffer();
          }
        }

        onEntered: {
          root.autoScrollFeaturedOffers = false;
        }

        onExited: {
          root.autoScrollFeaturedOffers = true;
        }

        Image {
          id: leftButton
          anchors.centerIn: parent
          source: leftButtonMouseArea.containsMouse ? "/images/button-featured-offers-left-highlight.png" : "/images/button-featured-offers-left.png"
        } // Image
      } // MouseArea

      MouseArea {
        id: rightButtonMouseArea
        anchors { right: parent.right; verticalCenter: parent.verticalCenter; }
        width: rightButton.width * 3
        height: rightButton.height * 3
        hoverEnabled: true
        visible: !imageContainer.showDummyImage && controller != null && controller.featuredOffers.length > 1

        onClicked: {
          if (controller != null) {
            featuredOfferTimer.restart();
            controller.getNextFeaturedOffer();
          }
        }

        onEntered: {
          root.autoScrollFeaturedOffers = false;
        }

        onExited: {
          root.autoScrollFeaturedOffers = true;
        }

        Image {
          id: rightButton
          anchors.centerIn: parent
          source: rightButtonMouseArea.containsMouse ? "/images/button-featured-offers-right-highlight.png" : "/images/button-featured-offers-right.png"
        } // Image
      } // MouseArea
    } //TibiaFrame1PixelDown

    TibiaFrame2PixelUpFilledWithCaption {
      caption: qsTrId("store_recently_added")
      Layout.fillWidth: true
      Layout.fillHeight: true

      TibiaSunkenRectangle {
        anchors.fill: parent
        anchors.margins: parent.marginsToContent
        anchors.topMargin: parent.topMarginToContent

        TibiaScrollView {
          anchors.fill: parent
          anchors.margins: parent.borderWidth

          GridView {
            id: offerGrid
            model: controller != null ? controller.availableOffers : null

            interactive: false //prevent flick behavior on touch screens
            boundsBehavior: Flickable.StopAtBounds
            pixelAligned: true

            cellWidth: Math.floor(width / 2)

            delegate: StoreOfferDisplay {
              id: offerDelegate
              width: offerGrid.cellWidth
              currentIndex: offerGrid.currentIndex
              dynamicallyLoadedImageManager: controller != null ? controller.dynamicallyLoadedImageManager : null
              highlightOnHover: true
              smoothTextureFiltering: controller != null ? controller.smoothTextureFiltering : false

              Component.onCompleted: {
                offerGrid.cellHeight = implicitHeight;
              }

              onClicked: {
                if (controller != null) {
                  for (var i = 0; i < modelData.quantities.length; ++i) {
                    if (tibiaMouseCursorController != null) {
                      tibiaMouseCursorController.setPointingHand(false);
                    }
                    controller.requestJumpToOfferWithID(modelData.quantities[i].offerID);
                    break;
                  }
                }
              }
            } // delegate: StoreOfferDisplay
          } //GridView
        } // TibiaScrollView
      } //TibiaSunkenRectangle
    } //TibiaFrame2PixelUpFilledWithCaption
  } //ColumnLayout
} //Item
