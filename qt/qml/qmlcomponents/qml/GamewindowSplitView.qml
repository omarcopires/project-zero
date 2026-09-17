import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qmlcomponents

Item {
  id: splitView

  signal layoutChanged()

  default property alias content: childrenPlaceholder.children

  property int upperPaneMinimumHeight: 0
  property int lowerPaneMinimumHeight: 0

  property int upperPaneUserSetHeight: upperPane.height
  property int lowerPaneUserSetHeight: lowerPane.height

  property int scaleInPercent: 100

  property var resizingBehaviour: TibiaEnums.PreferMapWindow

  property var upperPaneResizeCallback: null 

  readonly property int splitterHeight: 7

  readonly property bool hoveringOverSplitter: splitter.hovering
  property bool isResizing: false

  property int splitterMouseXPosition: 0

  Item {
    id: childrenPlaceholder

    Component.onCompleted: () => {
      if (children.length == 2) {
        let currentChildren = [children[0], children[1]];
        currentChildren[0].parent = upperPane;
        currentChildren[0].anchors.fill = upperPane;
        
        currentChildren[1].parent = lowerPane;
        currentChildren[1].anchors.fill = lowerPane;
      } else {
        console.log("GamewindowSplitView only works with exactly two children");
      }
    }
  }

  function clamp(value, min, max) {
    return Math.min(Math.max(value, min), max);
  }

  function onParentResize() {
    const MINIMUM_SPLIT_VIEW_COLUMN_HEIGHT = lowerPane.minimumHeight + splitView.splitterHeight + upperPane.minimumHeight;
    const NEW_SPLIT_VIEW_COLUMN_HEIGHT = Math.max(splitView.height, MINIMUM_SPLIT_VIEW_COLUMN_HEIGHT);
    splitViewColumn.height = NEW_SPLIT_VIEW_COLUMN_HEIGHT;

    correctLayout();
  }

  function requestUpperPaneHeight(requestedHeight) {
    let newUpperPaneHeight = requestedHeight;
    if (splitView.upperPaneResizeCallback) {
      newUpperPaneHeight = splitView.upperPaneResizeCallback(requestedHeight);
      newUpperPaneHeight = splitView.upperPaneResizeCallback(splitView.clamp(newUpperPaneHeight, upperPane.minimumHeight, splitViewColumn.height - (splitView.splitterHeight + lowerPane.minimumHeight) ));
    } 
    return newUpperPaneHeight;
  }

  function sliderPositionChanged(heightDifference, startUpperPaneHeight, startLowerPaneHeight) {
    upperPaneUserSetHeight = requestUpperPaneHeight(startUpperPaneHeight - heightDifference);
    lowerPaneUserSetHeight = startLowerPaneHeight + heightDifference;
    splitView.correctLayout();
    splitView.layoutChanged();
  }

  function correctLayout() {
    const NEW_SPLIT_VIEW_COLUMN_AVAILABLE_HEIGHT = splitViewColumn.height - splitter.height;

    switch (splitView.resizingBehaviour) {
      case TibiaEnums.PreferBoth: {
        const RATIO = upperPaneUserSetHeight / (upperPaneUserSetHeight + lowerPaneUserSetHeight);
        upperPane.requestedHeight = requestUpperPaneHeight(parseInt(NEW_SPLIT_VIEW_COLUMN_AVAILABLE_HEIGHT * RATIO));
        break;
      }
      case TibiaEnums.PreferMapWindow: {
        upperPane.requestedHeight = requestUpperPaneHeight(NEW_SPLIT_VIEW_COLUMN_AVAILABLE_HEIGHT - lowerPaneUserSetHeight);
        break;
      }
      case TibiaEnums.PreferChat: {
        upperPane.requestedHeight = requestUpperPaneHeight(upperPaneUserSetHeight);
        break;
      }
      default: {
        // in case its set to an invalid enum value
        splitView.resizingBehaviour = TibiaEnums.PreferChat
        break;
      }
    }
    lowerPane.requestedHeight = NEW_SPLIT_VIEW_COLUMN_AVAILABLE_HEIGHT - upperPane.requestedHeight;

    upperPane.confirmRequestedHeight();
    lowerPane.confirmRequestedHeight();
  }

  onResizingBehaviourChanged: {
    upperPaneUserSetHeight = upperPane.height;
    lowerPaneUserSetHeight = lowerPane.height;
    correctLayout();
    splitView.layoutChanged();
  }

  onWidthChanged: {
    onParentResize();
  }
  onHeightChanged: {
    onParentResize();
  }

  ColumnLayout {
    id: splitViewColumn
    spacing: 0
    anchors.left: parent.left
    anchors.right: parent.right
    height: 200
    Item {
      id: upperPane
      property int requestedHeight: 0
      property int minimumHeight: upperPaneMinimumHeight

      function confirmRequestedHeight() {
        Layout.preferredHeight = requestedHeight;
      }

      Layout.fillWidth: true
    }

    BorderImage {
      id: splitter
      property bool hovering: false
      Layout.preferredHeight: splitView.splitterHeight
      Layout.fillWidth: true
      source: "/images/divider-horizontal.png"
      horizontalTileMode: BorderImage.Repeat
      smooth: false
      MouseArea {
        property real startY: 0 
        property int  startUpperPaneHeight: 0
        property int  startLowerPaneHeight: 0
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton

        onPressed: (mouseEvent) => {
          if (mouseEvent.button == Qt.LeftButton) {
            startY = mapToGlobal(mouseEvent.x, mouseEvent.y).y;
            startUpperPaneHeight = upperPane.height;
            startLowerPaneHeight = lowerPane.height;
            isResizing = true;
          }
        }

        onPositionChanged: (mouseEvent) => {
          if (isResizing) {
            let heightDifference = startY - mapToGlobal(mouseEvent.x, mouseEvent.y).y;
            splitView.sliderPositionChanged(heightDifference, startUpperPaneHeight, startLowerPaneHeight);
          }
          splitterMouseXPosition = mouseEvent.x;
        }
        onEntered: {
          if(tibiaMouseCursorController != null) {
            splitter.hovering = true;
            tibiaMouseCursorController.setResizeVertical(true);
          }
        }
        onExited: {
          if(tibiaMouseCursorController != null && !pressed) {
            splitter.hovering = false;
            tibiaMouseCursorController.setResizeVertical(false);
          }
        }
        onReleased: {
          if (isResizing) {
            isResizing = false;
            isResizing = false;
          }
          if (!containsMouse) {
            splitter.hovering = false;
            if(tibiaMouseCursorController != null) {
              tibiaMouseCursorController.setResizeVertical(false);
            }
          }
        }
      }
    }
    Item {
      id: lowerPane
      property int requestedHeight: 0
      property int minimumHeight: lowerPaneMinimumHeight

      function confirmRequestedHeight() {
        Layout.preferredHeight = requestedHeight;
      }

      Layout.fillWidth: true
    }
  }

  Loader {
    id: resizeModeButtonLoader
    readonly property bool hoveringOverResizeModeButton: item != null ? item.hoveringOverButtons : false
    readonly property alias hoveringOverSplitter: splitView.hoveringOverSplitter
    readonly property alias isResizing: splitView.isResizing

    Timer {
      id: shouldHideTimer
      interval: 500
      onTriggered: {
        resizeModeButtonLoader.checkIfResizeModeButtonShouldHide();
      }
    }

    function checkIfResizeModeButtonShouldBeShown() {
      if (item == null) {
        let newShouldBeShown = isResizing || hoveringOverResizeModeButton;
        if (newShouldBeShown) {
          sourceComponent = resizeModeButtonComponent
        }
      } 
    }

    function checkIfResizeModeButtonShouldHide() {
      if (item != null) {
        let newShouldBeShown = isResizing || hoveringOverResizeModeButton || hoveringOverSplitter;
        if (newShouldBeShown == false) {
          sourceComponent = undefined;
        }
      } 
    }

    onHoveringOverResizeModeButtonChanged: {
      shouldHideTimer.start();
    }
    
    onHoveringOverSplitterChanged: {
      shouldHideTimer.start();
    }

    onIsResizingChanged: {
      resizeModeButtonLoader.checkIfResizeModeButtonShouldBeShown();
    }

    y: {
      let newSplitterY = 0;
      if (item) {
        newSplitterY = splitter.y - item.zoomFactorWrapperHeight;
      }
      return newSplitterY;
    }

    x: {
      let itemWidth = item != null ? item.width : 0
      return Math.min(splitView.width - itemWidth,  Math.max(0, splitterMouseXPosition - itemWidth / 2));
    }
  }
  
  Component {
    id: resizeModeButtonComponent
    Item {
      id: resizeModeButtonWrapper

      property bool hoveringOverButtons: false
      readonly property alias zoomFactorWrapperHeight: zoomFactorWrapper.height

      width: resizeModeButtonColumnLayout.width
      height: resizeModeButtonColumnLayout.height

      Component.onCompleted: onResizingBehaviourChanged()

      function applyNewResizingBehaviour(newResizingBehaviour) {
        if (newResizingBehaviour != splitView.resizingBehaviour) {
          splitView.resizingBehaviour = newResizingBehaviour;
        }
      }

      function onResizingBehaviourChanged() {
        switch (splitView.resizingBehaviour) {
          case TibiaEnums.PreferBoth: {
            resizeModeButton.resizeButtonIconUrl = "/images/icon-resize-mapwindow-and-chat.png"
            break;
          }
          case TibiaEnums.PreferMapWindow: {
            resizeModeButton.resizeButtonIconUrl = "/images/icon-resize-mapwindow.png"
            break;
          }
          case TibiaEnums.PreferChat: {
            resizeModeButton.resizeButtonIconUrl = "/images/icon-resize-chat.png"
            break;
          }
        }
      }

      Connections {
        target: splitView
        function onResizingBehaviourChanged() {
          resizeModeButtonWrapper.onResizingBehaviourChanged();
        }
      }

      ColumnLayout {
        id: resizeModeButtonColumnLayout
        spacing: 0
        

        Item {
          id: zoomFactorWrapper
          Layout.preferredWidth: 60
          Layout.preferredHeight: 22

          BorderImage {
            visible: true
            anchors.fill: parent
            border { left: 1; top: 1; right: 1; bottom: 0 }
            source: "/images/1pixel-up-frame.png"
            smooth: false
            horizontalTileMode: BorderImage.Repeat
            verticalTileMode: BorderImage.Repeat

            TibiaTiledImage {
              anchors.fill: parent
              anchors.margins: 1
              anchors.bottomMargin: -1
              source: "/images/background.png"
            } //BorderImage
          } //BorderImage
          TibiaText {
            text: splitView.scaleInPercent + "%"
            anchors.top: parent.top
            anchors.topMargin: 4
            anchors.horizontalCenter: parent.horizontalCenter
          }
          MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            hoverEnabled: true
            onEntered: {
              resizeModeButtonWrapper.hoveringOverButtons = true;
            }
            onExited: {
              resizeModeButtonWrapper.hoveringOverButtons = false;
            }
          }

        }
        Item {
          Layout.preferredHeight: splitter.height 
        }
        Item {
          property int borderWidth: 4
          Layout.preferredWidth: resizeModeButton.width + borderWidth * 2
          Layout.preferredHeight: resizeModeButton.height + borderWidth * 2
          Layout.alignment: Qt.AlignHCenter

          BorderImage {
            visible: true
            anchors.fill: parent
            anchors.topMargin: -1
            border { left: 1; top: 1; right: 1; bottom: 1 }
            source: "/images/1pixel-up-frame.png"
            smooth: false
            horizontalTileMode: BorderImage.Repeat
            verticalTileMode: BorderImage.Repeat

            TibiaTiledImage {
              anchors.fill: parent
              anchors.margins: 1
              anchors.topMargin: -1
              source: "/images/background.png"
            } //BorderImage
          } //BorderImage

          TibiaButton {
            id: resizeModeButton
            property string resizeButtonIconUrl: ""
            property var newResizeMode: TibiaEnums.PreferBoth
            implicitWidth: 23
            implicitHeight: 23
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            //anchors.verticalCenterOffset: -borderWidth
            imageSourceUp:   resizeButtonIconUrl
            imageSourceDown: resizeButtonIconUrl
            onClicked: {
              let newResizingBehaviour = splitView.resizingBehaviour;
              switch (splitView.resizingBehaviour) {
                case TibiaEnums.PreferBoth: {
                  newResizingBehaviour = TibiaEnums.PreferMapWindow;
                  break;
                }
                case TibiaEnums.PreferMapWindow: {
                  newResizingBehaviour = TibiaEnums.PreferChat;
                  break;
                }
                case TibiaEnums.PreferChat: {
                  newResizingBehaviour = TibiaEnums.PreferBoth;
                  break;
                }

              }
              resizeModeButtonWrapper.applyNewResizingBehaviour(newResizingBehaviour);
            }
          } //TibiaButton
          MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            hoverEnabled: true
            onEntered: {
              resizeModeButtonWrapper.hoveringOverButtons = true;
            }
            onExited: {
              resizeModeButtonWrapper.hoveringOverButtons = false;
            }
          }
        }
      }
    }
  }
}