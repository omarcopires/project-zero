import QtQuick
import QtQuick.Layouts




Item {
  id: root
  implicitWidth: 550
  implicitHeight: 300

  clip: false

  KeyNavigation.tab: root

  property var controller: null
  property QtObject optionsSet: null

  TibiaButton {
    anchors { bottom: parent.bottom; right: parent.right }
    text: qsTrId("reset")
    tooltipText: qsTrId("optionsmenu_reset_tooltip")
    onClicked: {
      if (controller != null) {
        controller.requestResetCurrentPageToDefault();
      }
    } //onClicked
  } //TibiaButton
} //Item
