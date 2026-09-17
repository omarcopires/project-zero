import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qmlcomponents

import "qrc:/qt/qml/qmlcomponents/qml/"

TibiaDialog {
  id: root
  caption: controller.caption
  width: contentWrapper.width + 2 * TibiaStyle.dialogMarginBorder
  centerAtElement: controller.mapWindowPane()

  required property var controller
  readonly property int tutorialMarkerID: controller.tutorialMarkerID ?? 0

  showCaption: controller.caption.length > 0
  headerDelegate: !showCaption ? headerDelegateComponent : null

  Component {
    id: headerDelegateComponent
    DialogHeaderCrest {}
  } //Component


  onReturnPressedFunction: function() {
    controller.requestClose();
  } //onReturnPressedFunction: function()

  onWidthChanged: root.centerDialog()
  onHeightChanged: root.centerDialog()

  onCancelPressedFunction: onReturnPressedFunction

  initialFocusItem: root
  KeyNavigation.tab: root
  KeyNavigation.backtab: root

  Component {
    id: tutorialMarkerComponent
    TibiaTutorialMarker {
      anchors.fill: parent
      markerID: containerSlot.tutorialMarkerID
    } //TibiaTutorialMarker
  } //Component

  ColumnLayout {
    anchors { left: parent.left; right: parent.right; top: parent.top }
    spacing: TibiaStyle.marginUnrelated

    Image {
      Layout.alignment: Qt.AlignHCenter
      Layout.topMargin: TibiaStyle.captionFlagTopMargin
      visible: !root.showCaption
      source: visible ? controller.captionImagePath : ""
    } //Image

    Item {
      id: contentWrapper
      Layout.preferredWidth: contentLayout.width + (contentFrame.visible ? 2*contentFrame.borderWidth : 0)
      Layout.preferredHeight: contentLayout.height  + (contentFrame.visible ? 2*contentFrame.borderWidth : 0)

      TibiaFrame1PixelDown {
        id: contentFrame
        anchors.fill: parent
        z: 1
        visible: root.controller.hasBevelFrame
      } //TibiaFrame1PixelDown

      RowLayout {
        id: contentLayout
        spacing: 0
        x: contentFrame.visible ? contentFrame.borderWidth : 0
        y: contentFrame.visible ? contentFrame.borderWidth : 0
        z:0

        Image {
          id: contentImage
          source: root.controller.imagePath

          TibiaButton {
            id: imageButton
            anchors.bottom: parent.bottom
            anchors.left : parent.left
            anchors.bottomMargin: 33 //magic number aproved by hannes
            anchors.leftMargin: 163 //magic number aproved by hannes
            visible: text.length > 0

            width: TibiaStyle.buttonWidthWider
            color: "green"
            textStyle: "Default"
            text: root.controller.imageButtonText
            onClicked: root.onReturnPressedFunction()

            Image {
              x: -TibiaStyle.startplayingDecorationMargin
              y: -TibiaStyle.startplayingDecorationMargin
              source: "/images/tutorial/button_startplaying_idle.png"
            } //Image

            Loader {
              id: imageButtonTutorialMarkerLoader
              anchors.fill: parent
              sourceComponent: imageButton.visible
                && root.tutorialMarkerID != 0
                ? tutorialMarkerComponent : null
              onLoaded: {
                item.markerID = Qt.binding(function() { return root.tutorialMarkerID });
              } //onLoaded
              z: 999
            } //Loader
            HoverHandler {
              onHoveredChanged: {
                if (tibiaMouseCursorController != null) {
                  tibiaMouseCursorController.setPointingHand(hovered)
                }
              }
            } // HoverHandler
          } //TibiaButton
        } //Image

        Item {
          Layout.fillHeight: true
          Layout.preferredWidth: height - Layout.leftMargin
          visible: root.controller.mapImagePath
          Layout.leftMargin: -49 //magic number aproved by hannes
          z:-1

          Item {
            id: viewport
            anchors.fill: parent
            clip: true

            readonly property real hereX: root.controller.youAreHereCoordianteWithinImage.x
            readonly property real hereY: root.controller.youAreHereCoordianteWithinImage.y

            property real scale: 1.0
            readonly property real minScale: 0.25
            readonly property real maxScale: 1.0 //no zoom
            property real panX: 0
            property real panY: 0

            Item {
              id: content
              x: viewport.panX
              y: viewport.panY
              scale: viewport.scale
              transformOrigin: Item.TopLeft

              Image {
                id: mapImage
                source: root.controller.mapImagePath
                cache: true
                smooth: true
                mipmap: true
              } //Image
            } //Item

            Image {
              id: youAreHerePin
              source: "/images/tutorial/overlay_pin.png"
              visible: mapImage.status === Image.Ready

              readonly property real anchorX: 64
              readonly property real anchorY: 16

              x: viewport.worldToScreen(viewport.hereX, viewport.hereY).x - anchorX
              y: viewport.worldToScreen(viewport.hereX, viewport.hereY).y - anchorY

              z: 10
            } //Image

            function worldToScreen(wx, wy) {
              return Qt.point(
                viewport.panX + wx * viewport.scale,
                viewport.panY + wy * viewport.scale
              )
            } //function worldToScreen

            function clampToScaleBounds(wantedScale) {
              return Math.max(viewport.minScale, Math.min(viewport.maxScale, wantedScale))
            }

            function scaleAndMoveImage(scale, panX, panY) {
              viewport.scale = clampToScaleBounds(scale)

              //scaled image size
              const w = mapImage.implicitWidth * viewport.scale
              const h = mapImage.implicitHeight * viewport.scale

              if (w <= viewport.width) {
                viewport.panX = (viewport.width - w) / 2
              } else {
                viewport.panX = Math.min(0, Math.max(viewport.width - w, panX))
              }

              if (h <= viewport.height) {
                viewport.panY = (viewport.height - h) / 2
              } else {
                viewport.panY = Math.min(0, Math.max(viewport.height - h, panY))
              }
            } //function clampPan

            DragHandler {
              id: drag
              target: null

              property real lastX: 0
              property real lastY: 0

              onActiveChanged: {
                if (active) {
                  lastX = centroid.position.x
                  lastY = centroid.position.y
                }
              } //onActiveChanged

              onCentroidChanged: {
                if (!active) return

                const x = centroid.position.x
                const y = centroid.position.y

                viewport.scaleAndMoveImage(
                  viewport.scale,
                  viewport.panX + (x - lastX),
                  viewport.panY + (y - lastY)
                )

                lastX = x
                lastY = y
              } //onCentroidChanged
            } //DragHandler

            //wheel zoom
            WheelHandler {
              id: wheel
              target: null
              acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad

              onWheel: (event) => {
                const step = event.angleDelta.y / 120.0
                if (step === 0) return

                const zoomFactor = Math.pow(1.15, step)

                const oldScale = viewport.scale
                let newScale = oldScale * zoomFactor
                newScale = viewport.clampToScaleBounds(newScale)
                if (newScale === oldScale) return

                // cursor position
                const mx = event.x
                const my = event.y

                // position on image
                const wx = (mx - viewport.panX) / oldScale
                const wy = (my - viewport.panY) / oldScale

                // move zoomed imge to stay under cursor
                viewport.scaleAndMoveImage(
                  newScale,
                  mx - wx * newScale,
                  my - wy * newScale
                )
                event.accepted = true
              } //onWheel
            } //WheelHandler

            //initial focus position and zoom
            Connections {
              target: viewport
              function onWidthChanged() {
                if (mapImage.status === Image.Ready) {
                  const initialScale = 1.0
                  viewport.scaleAndMoveImage(
                    initialScale,
                    viewport.width / 2 - viewport.hereX * initialScale,
                    viewport.height / 2 - viewport.hereY * initialScale
                  )
                }
              } //function onWidthChanged
            } //Connections
          } //Item
        } //Item
      } //RowLayout
    } //Item

    ColumnLayout {
      spacing: TibiaStyle.marginUnrelated
      visible: !imageButton.visible

      TibiaHorizontalSeparator {
        Layout.fillWidth: true
      } //TibiaHorizontalSeparator

      TibiaButton {
        id: okButton
        Layout.alignment: Qt.AlignRight
        text: qsTrId("ok")

        onClicked: onReturnPressedFunction();

        Loader {
          id: okButtonTutorialMarkerLoader
          anchors.fill: parent
          sourceComponent: okButton.visible
            && root.tutorialMarkerID != 0
            ? tutorialMarkerComponent : null
          onLoaded: {
            item.markerID = Qt.binding(function() { return root.tutorialMarkerID });
          } //onLoaded
          z: 999
        } //Loader
      } //TibiaButton
    } //ColumnLayout
  } // ColumnLayout
} // TibiaDialog
