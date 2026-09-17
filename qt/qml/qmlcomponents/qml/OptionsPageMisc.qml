import QtQuick
import QtQuick.Layouts


TibiaOptionsPage {
  id: root
  implicitHeight: contentLayout.height

  optionsSet: controller != null ? controller.miscOptions : null

  ColumnLayout {
    id: contentLayout
    anchors { left: parent.left; top: parent.top; right: parent.right }
    spacing: TibiaStyle.marginRelated

    TibiaMenuOptionCheckBox {
      id: askBeforeBuyingStoreProducts
      text: qsTrId("optionsmenu_ask_before_buying")
      guiHelpText: qsTrId("optionsmenu_ask_before_buying_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet && optionsSet.askBeforeBuyingStoreProducts
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.askBeforeBuyingStoreProducts = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: askBeforeStowContainerContent
      text: qsTrId("optionsmenu_ask_before_stow_container_content")
      guiHelpText: qsTrId("optionsmenu_ask_before_stow_container_content_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet && optionsSet.askBeforeStowContainerContent
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.askBeforeStowContainerContent = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: askBeforeSortContainerRecursive
      text: qsTrId("optionsmenu_ask_before_sort_container_recursive")
      guiHelpText: qsTrId("optionsmenu_ask_before_sort_container_recursive_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet && optionsSet.askBeforeSortContainerRecursive
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.askBeforeSortContainerRecursive = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: askBeforeMoveContainerContentToManagedContainersRecursive
      text: qsTrId("optionsmenu_ask_before_move_container_content_to_managed_containers_recursive")
      guiHelpText: qsTrId("optionsmenu_ask_before_move_container_content_to_managed_containers_recursive_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet && optionsSet.askBeforeMoveContainerContentToManagedContainersRecursive
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.askBeforeMoveContainerContentToManagedContainersRecursive = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: stayLoggedInByDefault
      text: qsTrId("optionsmenu_stay_logged_in")
      guiHelpText: qsTrId("optionsmenu_stay_logged_in_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet && optionsSet.stayLoggedInByDefault
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.stayLoggedInByDefault = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: optimizeConnectionStability
      text: qsTrId("optionsmenu_optimize_connection_stability")
      guiHelpText: qsTrId("optionsmenu_optimize_connection_stability_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet && optionsSet.optimizeConnectionStability
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.optimizeConnectionStability = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: quickLogin
      text: qsTrId("optionsmenu_quicklogin")
      guiHelpText: qsTrId("optionsmenu_quicklogin_help")
      Layout.fillWidth: true
      shouldBeChecked: optionsSet && optionsSet.quickLogin
      onCheckedChanged: {
        if (optionsSet != null) {
          optionsSet.quickLogin = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox

    TibiaMenuOptionCheckBox {
      id: freetypeRenderer
      text: qsTrId("optionsmenu_freetypefontrenderer")
      guiHelpText: qsTrId("optionsmenu_freetypefontrenderer_help")
      Layout.fillWidth: true
      shouldBeChecked: root.optionsSet && root.optionsSet.useFreetypeFontRenderer
      visible: root.optionsSet && root.optionsSet.isWindows
      onCheckedChanged: {
        if (root.optionsSet != null) {
          root.optionsSet.useFreetypeFontRenderer = checked;
        }
      } //onCheckedChanged
    } //TibiaMenuOptionCheckBox
  } //ColumnLayout
} //TibiaOptionsPage
