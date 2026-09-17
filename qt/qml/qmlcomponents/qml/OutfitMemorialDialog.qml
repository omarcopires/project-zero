import QtQuick
import QtQuick.Layouts
import qmlcomponents



TibiaDialog {
  id: outfitMemorialDialog
  caption: qsTrId("outfitmemorial_caption")
  width: 500

  property var controller: null

  readonly property int tabGoldenOutfit: 1
  readonly property int tabTokenOutfit: 2

  onReturnPressedFunction: function() {}

  onCancelPressedFunction: function() {
    if (controller != null) {
      controller.requestClose();
    }
  }

  initialFocusItem: outfitMemorialDialog

  ColumnLayout {
    width: parent.width
    height: 400
    spacing: TibiaStyle.marginUnrelated

    TibiaDialogTabBar {
      id: tabBar
      Layout.fillWidth: true

      activeTabId: tabGoldenOutfit
      buttonImageXOffset: 20

      onRequestedTabIdChanged: {
        activeTabId = requestedTabId
      } //onRequestedTabIdChanged

      tabModel: [
        {
          "tabId": tabGoldenOutfit,
          "caption": qsTrId("outfitmemorial_tab_goldenoutfit"),
          "tooltip": qsTrId("outfitmemorial_tab_goldenoutfit"),
          "icon": "/images/skin/classic/icon-goldenoutfit.png"
        }
        , {
          "tabId": tabTokenOutfit,
          "caption": qsTrId("outfitmemorial_tab_tokenoutfit"),
          "tooltip": qsTrId("outfitmemorial_tab_tokenoutfit"),
          "icon": "/images/skin/classic/icon-crownsetoutfit.png"
        }
      ] //tabModel
    } //TibiaDialogTabBar

    TibiaTextArea {
      Layout.fillWidth: true
      Layout.fillHeight: true
      text: {
        if (controller == null) {
          return qsTrId("dummy_unknown");
        }

        let listFormat = function(stringList) {
          let listText = "";
          for (let i = 0; i < stringList.length; ++i) {
            listText += qsTrId("outfitmemorial_list_entry").arg(stringList[i])
            listText += '\n'
          }
          listText += '\n'
          return listText;
        }

        if (tabBar.activeTabId == tabGoldenOutfit) {
          if (controller.baseGoldenOutfitOwners.length == 0 &&
              controller.oneAddonGoldenOutfitOwners.length == 0 &&
              controller.fullGoldenOutfitOwners.length == 0) {
            return qsTrId("outfitmemorial_goldenoutfit_noowner");
          }
          let text = qsTrId("outfitmemorial_goldenoutfit_header")
          if (controller.fullGoldenOutfitOwners.length > 0) {
            text += qsTrId("outfitmemorial_goldenoutfit_fulloutfit").arg(controller.fullGoldenOutfitCost)
            text += listFormat(controller.fullGoldenOutfitOwners)
          }
          if (controller.oneAddonGoldenOutfitOwners.length > 0) {
            text += qsTrId("outfitmemorial_goldenoutfit_oneaddonoutfit").arg(controller.oneAddonGoldenOutfitCost)
            text += listFormat(controller.oneAddonGoldenOutfitOwners)
          }
          if (controller.baseGoldenOutfitOwners.length > 0) {
            text += qsTrId("outfitmemorial_goldenoutfit_baseoutfit").arg(controller.baseGoldenOutfitCost)
            text += listFormat(controller.baseGoldenOutfitOwners)
          }
          return text;
        } else if (tabBar.activeTabId == tabTokenOutfit) {
          if (controller.baseTokenOutfitOwners.length == 0 &&
              controller.oneAddonTokenOutfitOwners.length == 0 &&
              controller.fullTokenOutfitOwners.length == 0) {
            return qsTrId("outfitmemorial_tokenoutfit_noowner");
          }
          let text = qsTrId("outfitmemorial_tokenoutfit_header")
          if (controller.fullTokenOutfitOwners.length > 0) {
            text += qsTrId("outfitmemorial_tokenoutfit_fulloutfit")
              .arg(controller.fullTokenOutfitSilverToken)
              .arg(controller.fullTokenOutfitGoldToken)
            text += listFormat(controller.fullTokenOutfitOwners)
          }
          if (controller.oneAddonTokenOutfitOwners.length > 0) {
            text += qsTrId("outfitmemorial_tokenoutfit_oneaddonoutfit")
              .arg(controller.oneAddonTokenOutfitSilverToken)
              .arg(controller.oneAddonTokenOutfitGoldToken)
            text += listFormat(controller.oneAddonTokenOutfitOwners)
          }
          if (controller.baseTokenOutfitOwners.length > 0) {
            text += qsTrId("outfitmemorial_tokenoutfit_baseoutfit")
              .arg(controller.baseTokenOutfitSilverToken)
              .arg(controller.baseTokenOutfitGoldToken)
            text += listFormat(controller.baseTokenOutfitOwners)
          }
          return text;
        } else {
          return qsTrId("dummy_unknown");
        }
      }
      readOnly: true
      wrapMode: TextEdit.Wrap
    }

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } //TibiaHorizontalSeparator

    RowLayout {
      Layout.alignment: Qt.AlignRight
      spacing: TibiaStyle.marginRelated

      Item {
        Layout.fillWidth: true
      }

      TibiaButton {
        text: qsTrId("close")
        onClicked: outfitMemorialDialog.onCancelPressedFunction();
      } // TibiaButton
    } // RowLayout
  } // ColumnLayout
} // TibiaDialog
