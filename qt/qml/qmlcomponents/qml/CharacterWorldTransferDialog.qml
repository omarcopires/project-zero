import QtQuick
import QtQuick.Layouts



TibiaDialog {
  id: cwtDialog
  caption: controller != null && controller.isExpressWorldTransfer ?
     qsTrId("characterworldtransfer_express_caption").arg(currentPage).arg(2) : qsTrId("characterworldtransfer_caption").arg(currentPage).arg(2)
  width: 450

  property var controller: null
  property int currentPage: 1

  onReturnPressedFunction: function() {
    if (okButton.enabled) {
      if (currentPage == 1) {
        switchPage(2);
      } else if (currentPage == 2 && controller != null) {
        controller.requestWorldTransfer(worldSelectionBox.model[worldSelectionBox.currentIndex].worldName);
      }
    }
  }

  onCancelPressedFunction: function() {
    if (controller != null) {
      controller.requestClose();
    }
  }

  function switchPage(NewPage) {
    currentPage = -1; // This makes ALL elements invisible that depend on currentPage for visibility,
                      // and prevents dialog movement because its height becomes larger when two pages
                      // are visible at once during rebinding
    currentPage = NewPage;
  }

  initialFocusItem: cwtDialog
  KeyNavigation.tab: cwtDialog

  ColumnLayout {
    anchors { left: parent.left; right: parent.right}
    spacing: TibiaStyle.marginUnrelated

    TibiaText {
      text: qsTrId("characterworldtransfer_charactername")
        .arg(controller != null ? controller.characterName : qsTrId("dummy_unknown"))
      textFormat: Text.StyledText
    }

    // Begin content page 1

    TibiaText {
      Layout.fillWidth: true
      wrapMode: Text.Wrap
      text: qsTrId("characterworldtransfer_restriction_explanation")
      visible: currentPage == 1
    }

    ColumnLayout {
      visible: currentPage == 1
      Repeater {
        model: controller != null && currentPage == 1 ? controller.conditions : null

        RowLayout {
          Image {
            source: modelData.meetsCondition ? "/images/icon-yes.png" : "/images/icon-no.png"
          }

          TibiaText {
            text: modelData.conditionText
            Layout.fillWidth: true
            wrapMode: Text.Wrap
          }
        } // RowLayout
      } // Repeater
    } // ColumnLayout

    TibiaText {
      Layout.topMargin: TibiaStyle.marginRelated
      Layout.fillWidth: true
      wrapMode: Text.Wrap
      visible: currentPage == 1
      text: controller != null && controller.canTransfer
        ? qsTrId("characterworldtransfer_transfer_possible") : qsTrId("characterworldtransfer_transfer_not_possible")
    } // TibiaText

    RowLayout {
      id: conditionBox
      visible: controller != null && controller.canTransfer && currentPage == 1
      Layout.topMargin: TibiaStyle.marginRelated

      TibiaText {
        text: qsTrId("characterworldtransfer_select_world")
      }

      TibiaComboBox {
        id: worldSelectionBox
        Layout.fillWidth: true
        enabled: controller != null && controller.canTransfer
        model: controller != null ? controller.worlds : null
        textRole: "detailedWorldName"

        onModelChanged: {
          if (model != null && model.length > 0) {
            currentIndex = 0;
            currentIndexChanged();
          }
        }

        onCurrentIndexChanged: {
          if (model != null && currentIndex > -1 && currentIndex < model.length) {
            if (model[currentIndex].lockedForTransfer) {
              lockedExplanation.opacity = 1.0;
            } else {
              lockedExplanation.opacity = 0.0;
            }
          }
        }
      } // TibiaCombobox

      TibiaGuiHelp {
        text: qsTrId("characterworldtransfer_missing_world_explanation")
      }
    } // RowLayout

    TibiaText {
      id: lockedExplanation
      visible: conditionBox.visible
      text: qsTrId("characterworldtransfer_locked_explanation")
      opacity: 0.0
      Layout.fillWidth: true
      wrapMode: Text.Wrap
    }

    // Begin content page 2

    TibiaText {
      text: qsTrId("characterworldtransfer_targetworld").arg(
        worldSelectionBox.model != null && worldSelectionBox.model.length > 0
          ? worldSelectionBox.model[worldSelectionBox.currentIndex].detailedWorldName : qsTrId("dummy_unknown"))
      visible: currentPage == 2
    }

    TibiaText {
      text: qsTrId("characterworldtransfer_confirmation")
      visible: currentPage == 2
      Layout.fillWidth: true
      wrapMode: Text.Wrap
    }

    ColumnLayout {
      visible: currentPage == 2

      Repeater {
        model: [qsTrId("characterworldtransfer_guild_kick"), qsTrId("characterworldtransfer_divorce"),
                qsTrId("characterworldtransfer_housebid_cancel"), qsTrId("characterworldtransfer_market_cancel"),
                qsTrId("characterworldtransfer_latency_warning"), qsTrId("characterworldtransfer_departure_platform")]

        RowLayout {
          TibiaText {
            Layout.alignment: Qt.AlignTop
            textFormat: Text.RichText
            text: "&bull;"
          }

          TibiaText {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            text: modelData
          }
        } // RowLayout
      } // Repeater
    } // ColumnLayout

    TibiaCheckBox {
      id: finalCheck
      visible: currentPage == 2
      text: qsTrId("characterworldtransfer_confirm_checkbox")
      Layout.topMargin: TibiaStyle.marginRelated
    }

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } // TibiaHorizontalSeparator


    RowLayout {
      spacing: TibiaStyle.marginUnrelated

      Item {
        Layout.fillWidth: true
      } // Item

      TibiaButton {
        text: qsTrId("back")
        visible: currentPage == 2
        Layout.preferredWidth: TibiaStyle.buttonWidthBroad

        onClicked: {
          switchPage(1);
        }
      } // TibiaButton

      TibiaButton {
        id: okButton
        text: currentPage == 1 ? qsTrId("next") : qsTrId("store_buy_now")
        color: currentPage == 2 && enabled ? "blue" : "grey"
        textStyle: currentPage == 1 ? "Dialog" : "Default"
        enabled: controller != null && ((currentPage == 1 && controller.canTransfer && worldSelectionBox.model != null && worldSelectionBox.model.length > 0) || (currentPage == 2 && finalCheck.checked))
        Layout.preferredWidth: TibiaStyle.buttonWidthBroad

        onClicked: {
          onReturnPressedFunction();
        }
      } // TibiaButton

      TibiaButton {
        id: cancelButton
        text: qsTrId("cancel")
        Layout.preferredWidth: TibiaStyle.buttonWidthBroad

        onClicked: {
          onCancelPressedFunction();
        }
      } // TibiaButton
    } // RowLayout
  }// ColumnLayout
} // TibiaDialog
