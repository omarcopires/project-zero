import QtQuick
import QtQuick.Layouts

import qmlcomponents



ColumnLayout {
  id: sidebarManager
  spacing: 0

  property QtObject controller: null
  property string position: "right"

  property bool canCloseSidebar: {
    if (controller != null) {
      if (position == "left") {
        return controller.canCloseLeftSidebar;
      } else {
        return controller.canCloseRightSidebar;
      }
    }
    return false;
  }

  Item {
    Layout.preferredWidth: addButton.width
    Layout.preferredHeight: addButton.height

    TibiaIconButton {
      id: addButton
      enabled: controller != null && controller.canOpenSidebar
      sourceUp: enabled ? "/images/button-sidebar-" + position + "-add-up.png"
                        : "/images/button-sidebar-" + position + "-add-disabled.png"
      sourceDown: "/images/button-sidebar-" + position + "-add-down.png"

      tooltipText: qsTrId("sidebar_manager_add_tooltip")
      onClicked: {
        if (controller != null) {
          controller.openAdditionalSidebar(position);
        }
      } //onClicked
    } //TibiaIconButton

    Tooltip {
      anchors.fill: parent
      enabled: !addButton.enabled
      text: qsTrId("sidebar_manager_add_not_possible_tooltip")
    } //Tooltip

    Lenshelp {
      anchors.fill: parent
      caption: qsTrId("sidebar_manager_lenshelp_caption")
      content: qsTrId("sidebar_manager_lenshelp").arg("/images/button-sidebar-" + position + "-add-up.png").arg("/images/button-sidebar-" + position + "-remove-up.png")
    } //Lenshelp
  } //Item

  Item {
    Layout.preferredWidth: removeButton.width
    Layout.preferredHeight: removeButton.height

    TibiaIconButton {
      id: removeButton
      enabled: canCloseSidebar
      sourceUp: enabled ? "/images/button-sidebar-" + position + "-remove-up.png"
                        : "/images/button-sidebar-" + position + "-remove-disabled.png"
      sourceDown: "/images/button-sidebar-" + position + "-remove-down.png"

      tooltipText: qsTrId("sidebar_manager_remove_tooltip")
      onClicked: {
        if (controller != null) {
          controller.closeSidebarClosestToGamewindow(position);
        }
      } //onClicked
    } //TibiaIconButton

    Tooltip {
      anchors.fill: parent
      enabled: !removeButton.enabled
      text: qsTrId("sidebar_manager_remove_not_possible_tooltip")
    } //Tooltip

    Lenshelp {
      anchors.fill: parent
      caption: qsTrId("sidebar_manager_lenshelp_caption")
      content: qsTrId("sidebar_manager_lenshelp").arg("/images/button-sidebar-" + position + "-add-up.png").arg("/images/button-sidebar-" + position + "-remove-up.png")
    } //Lenshelp
  } //Item
} //ColumnLayout
