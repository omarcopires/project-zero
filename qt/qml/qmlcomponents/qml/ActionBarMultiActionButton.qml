import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qmlcomponents
import qmlenumvalues

ActionBarButton {
  id: root

  property alias direction: expandable.direction

  property bool showMultiAction: controller != null ? root.buttonData.multiActionExpanded : false

  ActionBarMultiActionExpandable {
    id: expandable
    controller: root.controller
    buttonData: root.buttonData.multiActions
    visible: root.showMultiAction
  }

  states: [
    State {
      name: "showMultiAction"
      when: root.showMultiAction
    }
  ]

  transitions: [
    Transition {
      to: "showMultiAction"
      ParentAnimation {
        target: expandable
      }
      PropertyAction { target: expandable; property: "parent"; value: root.parentWhileDragging }
      ScriptAction {
        script: {
          let expandableOffset = expandable.getPositioningOffset();
          let posAtRoot = root.mapToItem(root.parentWhileDragging, 0, 0);
          expandable.x = posAtRoot.x + expandableOffset.x;
          expandable.y = posAtRoot.y + expandableOffset.y;
        }
      }
    } //Transition
  ] //transitions
}
