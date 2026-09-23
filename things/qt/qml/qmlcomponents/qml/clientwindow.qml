import QtQuick
import QtQml
import QtQuick.Window
import Qt5Compat.GraphicalEffects

import "qrc:/qt/qml/qmlcomponents/qml"

Window {
  id: clientWindow

  property int numberOfSidebars: 1
  property int leftAndRightStatusActionBarWidth: 0
  property int minWidthConsideringSidebarsActionBarsStatusBars: TibiaStyle.mapWindowMinWidth
                                                              + 2 * (TibiaStyle.mapWindowMargins + 1) //see MapWindowPane.qml property "mapWindowMargin"
                                                              + numberOfSidebars*TibiaStyle.sidebarWidth
                                                              + leftAndRightStatusActionBarWidth

  minimumWidth: Math.max(TibiaStyle.clientMinWidth,
                         minWidthConsideringSidebarsActionBarsStatusBars)
  minimumHeight: TibiaStyle.clientMinHeight

  Component.onCompleted: {
    //no binding, as it is not broken while resizing the window,
    //so changing the minimum values, direktly influenced the size of the client
    width = minimumWidth;
    height = minimumHeight;
  } //Component.onCompleted

  onMinimumWidthChanged: {
    if (minimumWidth > width) {
      width = minimumWidth;
    }
  } //onMinimumWidthChanged

  title: gamewindowContainer.windowTitleExtension.length > 0
    ? gamewindowContainer.windowTitle + " - " + gamewindowContainer.windowTitleExtension
    : gamewindowContainer.windowTitle

  visible: true
  flags: Qt.Window | Qt.WindowFullscreenButtonHint

  Image {
    property real imageAspectRatio: sourceSize.width / sourceSize.height

    anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter; }

    visible: gamewindowContainer.backgroundImageVisible
    smooth: true // Could also be gamewindowContainer.backgroundImageSmooth to react to Anti-Aliasing on/off (currently not wanted by graphics department)
    source: visible ? "/images/title.jpg" : ""

    fillMode: Image.PreserveAspectCrop
    height: clientWindow.height
    width: height * imageAspectRatio
  }

  Item {
    id: pleaseWaitBox
    property bool gameFinishedLoading: gamewindowContainer.children.length != 0
    visible: !gameFinishedLoading

    anchors {
      top: parent.verticalCenter
      left: parent.left
      right: parent.right
      bottom: parent.bottom
    }

    Timer {
      interval: 750
      repeat: true
      running: pleaseWaitBox.visible

      property int maximumDots: 3;
      property int currentDots: 0;

      onTriggered: {
        // Gradually display more dots, then reset to 0 and start from beginning
        currentDots = (currentDots + 1) % (maximumDots + 1);
        var PleaseWaitDots = "";
        for (var i = 0; i < currentDots; ++i) {
          PleaseWaitDots += ".";
        }
        pleaseWaitDots.text = PleaseWaitDots;
      }
    }

    TibiaDialogFrameWithCaption {
      width: 250
      height: 60
      anchors.centerIn: parent
      caption: qsTrId("startscreen_please_wait_caption")

      TibiaText {
        id: pleaseWaitText
        text: qsTrId("startscreen_please_wait_description")
        anchors {
          horizontalCenter: parent.horizontalCenter
          top: parent.top
          topMargin: parent.border.top + TibiaStyle.marginUnrelated
        }
      } // TibiaText

      TibiaText {
        id: pleaseWaitDots
        anchors {
          left: pleaseWaitText.right;
          verticalCenter: pleaseWaitText.verticalCenter
        }
      } // TibiaText
    } // TibiaDialogFrameWithCaption
  } // Item

  Item {
    id: gamewindowContainer
    objectName: "placeholder"
    anchors.fill: parent
    property string windowTitle: "Tibia"
    property string windowTitleExtension: ""
    property bool backgroundImageVisible: true
    property bool backgroundImageSmooth: false
  }
  // Dirty hack to initialize the graphical effect shaders very early. See https://jira.cipsoft.de/browse/TIBIA-29499 for more information
  // Otherwise the client can crash if OBS Studio is used with an AMD GPU if a graphical effect is used first time (e.g. the Fiendish glow text)
  // it seems that this problem doesn't exist if the graphical effects have already been initialized before OBS Studio installs its hook
  Glow {} 
}
