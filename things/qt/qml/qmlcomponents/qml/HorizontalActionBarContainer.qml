import QtQuick
import QtQuick.Layouts
import qmlcomponents



Item {
  id: root
  property QtObject controller: null

  visible: controller != null && controller.actionBarCount > 0
  implicitHeight: actionbarLayout.height

  RowLayout {
    id: actionbarLayout
    spacing: 0
    anchors {left: parent.left; right: parent.right }

    GridLayout {
      //grid layout to allow ordering by Layout.row
      id: actionBarContainer
      objectName: "actionBarContainer"
      Layout.fillWidth: true
      columns: 1
      rowSpacing: TibiaStyle.marginNarrow
    } //GridLayout

    TibiaButton {
      Layout.preferredHeight: root.visible ? actionBarContainer.height : 0
      Layout.preferredWidth: TibiaStyle.actionBarLockButtonWidth
      imageSourceUp:   root.controller != null && root.controller.locked ? "/images/icon-locked.png" : "/images/icon-unlocked.png"
      imageSourceDown: root.controller != null && root.controller.locked ? "/images/icon-unlocked.png" : "/images/icon-locked.png"
      tooltipText: root.controller != null && root.controller.locked ? qsTrId("actionbar_button_locked_tooltip") : qsTrId("actionbar_button_unlocked_tooltip")

      onClicked: {
        if (root.controller != null) {
          root.controller.onLockButtonClicked();
        }
      } //onClicked
    } //TibiaButton
  } //RowLayout

  Lenshelp {
    anchors.fill: parent
    caption: qsTrId("actionbar_lenshelp_caption")
    content: qsTrId("actionbar_lenshelp")
  } //Lenshelp

} //Item
