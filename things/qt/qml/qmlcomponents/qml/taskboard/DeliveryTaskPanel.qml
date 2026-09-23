import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtWebChannel
import QtWebEngine

import qmlcomponents
import "qrc:/qt/qml/qmlcomponents/qml/"
import QtQuick.LegacyControls

TibiaFrame2PixelUpFilledWithCaption {
  id: root

  required property var deliveryTasks
  required property bool showPermanentWeeklyTaskExpansionUnlockButton
  required property var deliverTaskAction
  required property var unlockAction
  required property var clickedAction
  caption: qsTrId("taskboard_delivery_task_panel_caption")

  function slotClicked(TypeID, MouseButton, KeyboardModifiers) {
    clickedAction(TypeID, MouseButton, KeyboardModifiers);
  } //function slotClicked
  
  width: 465
  height: 347

  GridLayout {
    id: tasks

    anchors.left: parent.left
    anchors.top: parent.top
    anchors.right: parent.right
    anchors.leftMargin: TibiaStyle.marginUnrelated
    anchors.topMargin: TibiaStyle.marginUnrelated + root.captionHeight
    anchors.rightMargin: TibiaStyle.marginUnrelated
    
    columnSpacing: TibiaStyle.marginNarrow
    rowSpacing: TibiaStyle.marginNarrow * 2
    
    columns: 3

    Repeater {
      model: deliveryTasks
      Layout.fillWidth: true

      DeliveryTask {
        Layout.preferredWidth: 144
        Layout.preferredHeight: 100
        taskIndex: model.taskIndex
        typeId: model.typeId
        captionText : model.caption
        availableAmount: model.availableAmount
        requiredAmount: model.requiredAmount
        delivered: model.delivered
        deliverAction: function () {
          deliverTaskAction(model.taskIndex)
        }

        Component.onCompleted: {
          clicked.connect(root.slotClicked);
        } //Component.onCompleted
      }
    }


    TibiaButton {
      id: unlockPermanentlyButton
      Layout.preferredHeight: 100
      Layout.preferredWidth: 3 * 144 + TibiaStyle.marginNarrow * 5
      Layout.columnSpan: 3
      color: "blue"

      visible: showPermanentWeeklyTaskExpansionUnlockButton

      imageSource: "/images/prey-unlock-permanently.png"

      onClicked: {
        unlockAction()
      }
    }
  }
}
