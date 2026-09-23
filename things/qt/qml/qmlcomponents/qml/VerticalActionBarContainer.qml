import QtQuick
import QtQuick.Layouts
import qmlcomponents



TibiaTiledImage {
  id: root
  source: "/images/background.png"

  property QtObject controller: null
  property bool leftActionBars: false
  property int topMargin: 0

  property bool firstVisibleButtonIdCanBeSaved: true

  visible: controller != null && controller.actionBarCount > 0
  implicitWidth: actionbarLayout.width + TibiaStyle.marginNarrow + frame.width

  onFirstVisibleButtonIdCanBeSavedChanged: {
    if (controller != null) {
      controller.setFirstVisibleButtonIdCanBeSaved(firstVisibleButtonIdCanBeSaved)
    }
  } //onFirstVisibleButtonIdCanBeSavedChanged

  ColumnLayout {
    id: actionbarLayout
    spacing: 0
    anchors {top: parent.top; bottom: parent.bottom }
    anchors.left: root.leftActionBars ? parent.left : undefined
    anchors.right: root.leftActionBars ? undefined : parent.right
    anchors.topMargin: Math.max(root.topMargin, 0)

    GridLayout {
      //grid layout to allow ordering by Layout.row
      id: actionBarContainer
      objectName: "actionBarContainer"
      Layout.fillHeight: true
      rows: 1
      columnSpacing: TibiaStyle.marginNarrow
      layoutDirection: root.leftActionBars ? Qt.RightToLeft : Qt.LeftToRight
    } //GridLayout

    TibiaButton {
      Layout.preferredHeight: TibiaStyle.actionBarLockButtonHeight
      Layout.preferredWidth: root.visible ? actionBarContainer.width : 0
      imageSourceUp:   root.controller != null && root.controller.locked ? "/images/icon-locked.png" : "/images/icon-unlocked.png"
      imageSourceDown: root.controller != null && root.controller.locked ? "/images/icon-unlocked.png" : "/images/icon-locked.png"
      tooltipText: root.controller != null && root.controller.locked ? qsTrId("actionbar_button_locked_tooltip") : qsTrId("actionbar_button_unlocked_tooltip")

      onClicked: {
        if (root.controller != null) {
          root.controller.onLockButtonClicked();
        }
      } //onClicked
    } //TibiaButton
  } //ColumnLayout

  Image {
    id: frame
    anchors {top: parent.top; bottom: parent.bottom }
    anchors.right: root.leftActionBars ? parent.right : undefined
    anchors.left: root.leftActionBars ? undefined : parent.left

    source: root.leftActionBars ? "/images/skin/classic/vertical-line-dark.png"
                                : "/images/skin/classic/vertical-line-bright.png"
    smooth: false
  } //Image

  Lenshelp {
    anchors.fill: parent
    caption: qsTrId("actionbar_lenshelp_caption")
    content: qsTrId("actionbar_lenshelp")
  } //Lenshelp
} //TibiaTiledImage
