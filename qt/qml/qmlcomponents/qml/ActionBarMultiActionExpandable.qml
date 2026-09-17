import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qmlcomponents
import qmlenumvalues

Item {
  id: root

  enum Direction { Up, Right, Down, Left }

  required property QtObject controller
  required property list<QtObject> buttonData

  property int direction: ActionBarMultiActionExpandable.Direction.Up

  readonly property bool vertical: (direction == ActionBarMultiActionExpandable.Direction.Up || direction == ActionBarMultiActionExpandable.Direction.Down)
  readonly property bool mirrored: (direction == ActionBarMultiActionExpandable.Direction.Left || direction == ActionBarMultiActionExpandable.Direction.Up)

  readonly property var arrangedData: mirrored ? buttonData.slice().reverse() : buttonData

  readonly property int infobarSize: 28

  implicitWidth: multiActionButtonsWrapper.width
  implicitHeight: multiActionButtonsWrapper.height

  width: implicitWidth
  height: implicitHeight

  function getPositioningOffset() {
    let offsetPosition = {
      x: 0,
      y: 0,
    };

    switch (direction) {
      case ActionBarMultiActionExpandable.Direction.Up:
        offsetPosition.x = -multiActionButtonsWrapper.width + 4 + TibiaStyle.actionBarSlotSize;
        offsetPosition.y = -multiActionButtonsWrapper.height;
        break;
      case ActionBarMultiActionExpandable.Direction.Left:
        offsetPosition.x = -multiActionButtonsWrapper.width;
        offsetPosition.y = -multiActionButtonsWrapper.height + 4 + TibiaStyle.actionBarSlotSize;
        break;
      case ActionBarMultiActionExpandable.Direction.Right:
        offsetPosition.x = TibiaStyle.actionBarSlotSize;
        offsetPosition.y = -multiActionButtonsWrapper.height + 4 + TibiaStyle.actionBarSlotSize;
        break;
      default:
        break;
    }

    return offsetPosition;
  }

  // -- multiaction buttons wrapper
  TibiaFrame2PixelUpFilled {
    id: multiActionButtonsWrapper

    width: vertical
      ? (TibiaStyle.actionBarSlotSize * 1 + root.infobarSize + TibiaStyle.marginRelated)
      : (TibiaStyle.actionBarSlotSize * 3 + TibiaStyle.marginRelated * 2 + 2 * 2) // 2 * 2 = buttons spacing
    height: vertical
      ? (TibiaStyle.actionBarSlotSize * 3 + TibiaStyle.marginRelated * 2 + 2 * 2) // 2 * 2 = buttons spacing
      : (TibiaStyle.actionBarSlotSize * 1 + root.infobarSize + TibiaStyle.marginRelated)

    // Mouse area to avoid interacting with ui behind the expandable (e.g. the resize separator for the game window)
    TibiaMouseShield {
      anchors.fill: parent
    }

    // Drop area blocker avoids dropping objects on slots behind the popup
    // see TIBIA-39847
    DropArea {
      id: blockDropArea
      anchors.fill: parent

      onDropped: {}
    } //DropArea

    Tooltip {
      anchors.fill: parent
      text: qsTrId("actionbar_button_multiaction_tooltip")
      maxWidth: TibiaStyle.tooltipRestrictedWidth
    } // Tooltip

    // -- multiaction buttons
    GridLayout {
      id: buttonsLayout
      flow: (vertical ? GridLayout.TopToBottom : GridLayout.LeftToRight)

      property var anchorConfig: {
        // left action bar
        if (!vertical && !mirrored) {
          return {
            bottom: multiActionButtonsWrapper.bottom,
            bottomMargin: TibiaStyle.marginRelated,
            left: multiActionButtonsWrapper.left,
            leftMargin: TibiaStyle.marginRelated
          };
        }

        // right action bar
        if (!vertical && mirrored) {
          return {
            bottom: multiActionButtonsWrapper.bottom,
            bottomMargin: TibiaStyle.marginRelated,
            right: multiActionButtonsWrapper.right,
            rightMargin: TibiaStyle.marginRelated
          };
        }

        // bottom action bar
        if (vertical && mirrored) {
          return {
            right: multiActionButtonsWrapper.right,
            rightMargin: TibiaStyle.marginRelated,
            top: multiActionButtonsWrapper.top,
            topMargin: TibiaStyle.marginRelated
          };
        }

        return {};
      } // anchorConfig

      anchors.top: anchorConfig.top
      anchors.topMargin: anchorConfig.topMargin
      anchors.right: anchorConfig.right
      anchors.rightMargin: anchorConfig.rightMargin
      anchors.bottom: anchorConfig.bottom
      anchors.bottomMargin: anchorConfig.bottomMargin
      anchors.left: anchorConfig.left
      anchors.leftMargin: anchorConfig.leftMargin

      rowSpacing: 2
      columnSpacing: 2

      Repeater {
        model: arrangedData

        ActionBarButton {
          required property var modelData

          controller: root.controller
          buttonData: modelData
        }
      } // Repeater
    } // GridLayout

    // -- infobar labels
    GridLayout {
      id: infobarLabelsLayout
      flow: (vertical ? GridLayout.TopToBottom : GridLayout.LeftToRight)

      width: vertical ? root.infobarSize : buttonsLayout.width
      height: vertical ? buttonsLayout.height : root.infobarSize

      uniformCellWidths: true
      uniformCellHeights: true

      readonly property var infobarButtonLabels: ["I", "II", "III"]

      property var anchorConfig: {
        // left action bar
        if (!vertical && !mirrored) {
          return {
            top: multiActionButtonsWrapper.top,
            left: buttonsLayout.left
          };
        }

        // right action bar
        if (!vertical && mirrored) {
          return {
            top: multiActionButtonsWrapper.top,
            right: buttonsLayout.right
          };
        }

        // bottom action bar
        if (vertical && mirrored) {
          return {
            left: multiActionButtonsWrapper.left,
            top: buttonsLayout.top
          };
        }

        return {};
      }

      anchors.top: anchorConfig.top
      anchors.topMargin: anchorConfig.topMargin
      anchors.right: anchorConfig.right
      anchors.rightMargin: anchorConfig.rightMargin
      anchors.bottom: anchorConfig.bottom
      anchors.bottomMargin: anchorConfig.bottomMargin
      anchors.left: anchorConfig.left
      anchors.leftMargin: anchorConfig.leftMargin
      anchors.horizontalCenter: anchorConfig.horizontalCenter
      anchors.verticalCenter: anchorConfig.verticalCenter

      Repeater {
        model: arrangedData

        TibiaText {
          Layout.fillWidth: true
          Layout.fillHeight: true
          text: infobarLabelsLayout.infobarButtonLabels[modelData.multiActionIndex]
          verticalAlignment: Text.AlignVCenter
          horizontalAlignment: Text.AlignHCenter
        }
      }
    }

    // -- arrows
    Repeater {
      // multiaction buttons count - 1
      model: 2

      Image {
        smooth: false
        source: vertical || mirrored
          ? "/images/skin/classic/icon-arrow-greater-vertical.png"
          : "/images/skin/classic/icon-arrow-greater-horizontal.png"

        rotation: !vertical && mirrored ? -90 : 0

        property var anchorConfig: {
          let arrowSpacing = (vertical ? buttonsLayout.height : buttonsLayout.width) / 3;
          let arrowHorizontalBarMargin = infobarLabelsLayout.height / 2 - height / 2 + 2;
          let arrowVerticalBarMargin = infobarLabelsLayout.width / 2 - width / 2;

          // left action bar
          if (!vertical && !mirrored) {
            let arrowDistanceFinal = arrowSpacing * (modelData + 1) - width / 2;
            return {
              left: buttonsLayout.left,
              leftMargin: arrowDistanceFinal,
              top: infobarLabelsLayout.top,
              topMargin: arrowHorizontalBarMargin
            };
          }

          // right action bar
          if (!vertical && mirrored) {
            let arrowDistanceFinal = arrowSpacing * (modelData + 1) - width / 2;
            return {
              right: buttonsLayout.right,
              rightMargin: arrowDistanceFinal,
              top: infobarLabelsLayout.top,
              topMargin: arrowHorizontalBarMargin
            };
          }

          // bottom action bar
          if (vertical && mirrored) {
            let arrowDistanceFinal = arrowSpacing * (modelData + 1) - height / 2;
            return {
              top: buttonsLayout.top,
              topMargin: arrowDistanceFinal,
              left: infobarLabelsLayout.left,
              leftMargin: arrowVerticalBarMargin
            };
          }

          return {};
        } // anchorConfig

        anchors.top: anchorConfig.top
        anchors.topMargin: anchorConfig.topMargin
        anchors.right: anchorConfig.right
        anchors.rightMargin: anchorConfig.rightMargin
        anchors.bottom: anchorConfig.bottom
        anchors.bottomMargin: anchorConfig.bottomMargin
        anchors.left: anchorConfig.left
        anchors.leftMargin: anchorConfig.leftMargin
      } // Image
    } // Repeater
  } // TibiaFrame2PixelUpFilled
} // Item
