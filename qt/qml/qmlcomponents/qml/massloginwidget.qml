import QtQuick



TibiaSidebarWidget {
  id: gameObjectContainerInner

  property var gameSessions: widgetController != null ? widgetController.connectedGameSessions : []
  property var primaryGamesessionIndex: widgetController != null ? widgetController.primaryGamesessionIndex : -1
  caption: "Mass Login (%1)".arg(widgetController != null ? widgetController.numberOfSessions : 0)
  picSource: "/images/skin/classic/pic-premium.png"
  initialContentHeight: 400

  onPrimaryGamesessionIndexChanged: {
    sessiondumpList.currentIndex = primaryGamesessionIndex;
  }

  TibiaScrollView {
    anchors.fill: parent
    ListView {
      id: sessiondumpList
      leftMargin: 7
      topMargin: 5
      rightMargin: 7
      bottomMargin: 7

      model: gameSessions
      interactive: false //prevent flick behavior on touch screens

      clip: true
      delegate:
        Rectangle {
          id: sessiondumpEntryDelegate
          color: "transparent"
          width: sessiondumpList.width - sessiondumpList.leftMargin - sessiondumpList.rightMargin
          height: 15
          TibiaText {
            anchors.fill: parent
            text: modelData
            color: "white"
            font: TibiaStyle.defaultTextFont
            elide: Text.ElideRight
          }

        states: [
          State {
            name: "Current"
            when: sessiondumpEntryDelegate.ListView.isCurrentItem
            PropertyChanges { target: sessiondumpEntryDelegate; color: "#ff0000" }

          }
        ]

        MouseArea {
          id: mouseArea
          anchors.fill: parent
          onClicked: {
//            sessiondumpList.currentIndex = index;
            gameObjectContainerInner.widgetController.setNewGameSessionIndex(index);
          }
        }
      }
    }
  }
}
