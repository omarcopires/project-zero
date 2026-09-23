import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs

Item {
  id: root
  implicitWidth: 550
  implicitHeight: contentLayout.height

  clip: true
  KeyNavigation.tab: root

  property var controller: null
  readonly property int buttonWidth: TibiaStyle.buttonWidthWidest

  ColumnLayout {
    id: contentLayout
    anchors { left: parent.left; top: parent.top; right: parent.right }
    spacing: TibiaStyle.marginUnrelated

    TibiaFrame1PixelDown {
      Layout.fillWidth: true
      Layout.preferredHeight: helpButtonsLayout.height + 2 * marginsToContent

      ColumnLayout {
        id: helpButtonsLayout
        anchors { left: parent.left; top: parent.top; right: parent.right }
        anchors.margins: parent.marginsToContent
        spacing: TibiaStyle.marginRelated

        RowLayout {
          Layout.fillWidth: true
          spacing: TibiaStyle.marginRelated
          visible: controller != null && controller.isInGame

          TibiaButton {
            text: qsTrId("optionsmenu_client_help")
            Layout.preferredWidth: root.buttonWidth

            onClicked: {
              if (controller != null) {
                controller.activateLensehelp();
              }
            } //onClicked
          } //TibiaButton

          Item {
            Layout.fillWidth: true
          } //Item

          TibiaGuiHelp {
            text: qsTrId("optionsmenu_client_help_help")
          } //TibiaGuiHelp
        } //RowLayout

        RowLayout {
          Layout.fillWidth: true
          spacing: TibiaStyle.marginRelated
          visible: controller != null && controller.isInGame
        } //RowLayout

        RowLayout {
          Layout.fillWidth: true
          spacing: TibiaStyle.marginRelated
          visible: controller != null && controller.isInGame

          TibiaButton {
            text: qsTrId("news_dialog_caption")
            Layout.preferredWidth: root.buttonWidth

            onClicked: {
              if (controller != null) {
                controller.showCompendium();
              }
            } //onClicked
          } //TibiaButton

          Item {
            Layout.fillWidth: true
          } //Item

          TibiaGuiHelp {
            text: qsTrId("optionsmenu_news_dialog_button_help")
          } //TibiaGuiHelp
        } //RowLayout

        RowLayout {
          Layout.fillWidth: true
          spacing: TibiaStyle.marginRelated

          TibiaButton {
            text: qsTrId("optionsmenu_rule_violation")
            Layout.preferredWidth: root.buttonWidth

            onClicked: {
              if (controller != null) {
                controller.showRuleViolationsText();
              }
            } //onClicked
          } //TibiaButton

          Item {
            Layout.fillWidth: true
          } //Item

          TibiaGuiHelp {
            text: qsTrId("optionsmenu_rule_violation_help")
          } //TibiaGuiHelp
        } //RowLayout

        RowLayout {
          Layout.fillWidth: true
          spacing: TibiaStyle.marginRelated

          TibiaButton {
            text: qsTrId("optionsmenu_manual")
            Layout.preferredWidth: root.buttonWidth

            onClicked: {
              if (controller != null) {
                controller.openManuelUrl();
              }
            } //onClicked
          } //TibiaButton

          Item {
            Layout.fillWidth: true
          } //Item

          TibiaGuiHelp {
            text: qsTrId("optionsmenu_manual_help")
          } //TibiaGuiHelp
        } //RowLayout

        RowLayout {
          Layout.fillWidth: true
          spacing: TibiaStyle.marginRelated

          TibiaButton {
            text: qsTrId("optionsmenu_faq")
            Layout.preferredWidth: root.buttonWidth

            onClicked: {
              if (controller != null) {
                controller.openFaqUrl();
              }
            } //onClicked
          } //TibiaButton

          Item {
            Layout.fillWidth: true
          } //Item

          TibiaGuiHelp {
            text: qsTrId("optionsmenu_faq_help")
          } //TibiaGuiHelp
        } //RowLayout

        RowLayout {
          Layout.fillWidth: true
          spacing: TibiaStyle.marginRelated

          TibiaButton {
            text: qsTrId("optionsmenu_info")
            Layout.preferredWidth: root.buttonWidth

            onClicked: {
              if (controller != null) {
                controller.showAboutDialog();
              }
            } //onClicked
          } //TibiaButton

          Item {
            Layout.fillWidth: true
          } //Item

          TibiaGuiHelp {
            text: qsTrId("optionsmenu_info_help")
          } //TibiaGuiHelp
        } //RowLayout
      } //ColumnLayout
    } //TibiaFrame1PixelDown

    TibiaFrame1PixelDown {
      Layout.fillWidth: true
      Layout.preferredHeight: exportImportResetButtonLayout.height + 2 * marginsToContent

      ColumnLayout {
        id: exportImportResetButtonLayout
        anchors { left: parent.left; top: parent.top; right: parent.right }
        anchors.margins: parent.marginsToContent
        spacing: TibiaStyle.marginRelated

        RowLayout {
          Layout.fillWidth: true
          spacing: TibiaStyle.marginRelated

          TibiaButton {
            text: qsTrId("optionsmenu_export_all_options");
            tooltipText: qsTrId("optionsmenu_export_all_tooltip")
            Layout.preferredWidth: root.buttonWidth

            FileDialog {
              id: exportOptionsDialog
              title: qsTrId("optionsmenu_export_all_options_dialog_caption")
              nameFilters: [qsTrId("optionsmenu_file_selection_zip"), qsTrId("optionsmenu_file_selection_all")]
              fileMode: FileDialog.SaveFile

              onAccepted: {
                if (controller != null) {
                  controller.requestExportAllOptions(exportOptionsDialog.selectedFile);
                }
              }
            } // FileDialog

            onClicked: {
              exportOptionsDialog.open()
            }
          } // TibiaButton

          Item {
            Layout.fillWidth: true
          } //Item

          TibiaGuiHelp {
            text: qsTrId("optionsmenu_export_all_options_help")
          } //TibiaGuiHelp
        } // RowLayout

        RowLayout {
          Layout.fillWidth: true
          spacing: TibiaStyle.marginRelated

          TibiaButton {
            text: qsTrId("optionsmenu_export_minimap");
            tooltipText: qsTrId("optionsmenu_export_minimap_tooltip")
            Layout.preferredWidth: root.buttonWidth

            FileDialog {
              id: exportMinimapDialog
              title: qsTrId("optionsmenu_export_all_options_dialog_caption")
              nameFilters: [qsTrId("optionsmenu_file_selection_zip"), qsTrId("optionsmenu_file_selection_all")]
              fileMode: FileDialog.SaveFile

              onAccepted: {
                if (controller != null) {
                  controller.requestExportMinimap(exportMinimapDialog.selectedFile);
                }
              }
            } // FileDialog

            onClicked: {
              exportMinimapDialog.open()
            }
          } // TibiaButton

          Item {
            Layout.fillWidth: true
          } //Item

          TibiaGuiHelp {
            text: qsTrId("optionsmenu_export_minimap_help")
          } //TibiaGuiHelp
        } // RowLayout

        RowLayout {
          Layout.fillWidth: true
          spacing: TibiaStyle.marginRelated

          TibiaButton {
            text: qsTrId("optionsmenu_import_all_options");
            tooltipText: qsTrId("optionsmenu_import_all_tooltip")
            Layout.preferredWidth: root.buttonWidth

            FileDialog {
              id: importOptionsDialog
              title: qsTrId("optionsmenu_import_all_options_dialog_caption")
              nameFilters: [qsTrId("optionsmenu_file_selection_zip"), qsTrId("optionsmenu_file_selection_all")]
              fileMode: FileDialog.OpenFile

              onAccepted: {
                if (controller != null) {
                  controller.requestImportAllOptions(importOptionsDialog.selectedFile);
                }
              }
            } // FileDialog

            onClicked: {
              importOptionsDialog.open()
            }
          } // TibiaButton

          Item {
            Layout.fillWidth: true
          } //Item

          TibiaGuiHelp {
            text: qsTrId("optionsmenu_import_all_options_help")
          } //TibiaGuiHelp
        } // RowLayout

        RowLayout {
          Layout.fillWidth: true
          spacing: TibiaStyle.marginRelated

          TibiaButton {
            text: qsTrId("optionsmenu_reset_all_options")
            tooltipText: qsTrId("optionsmenu_reset_all_tooltip")
            Layout.preferredWidth: root.buttonWidth

            onClicked: {
              if (controller != null) {
                controller.requestResetAllOptionsToDefault();
              }
            } //onClicked
          } //TibiaButton

          Item {
            Layout.fillWidth: true
          } //Item

          TibiaGuiHelp {
            text: qsTrId("optionsmenu_reset_all_options_help")
          } //TibiaGuiHelp
        } //RowLayout


      } //ColumnLayout
    } //TibiaFrame1PixelDown
  } //ColumnLayout
} //Item
