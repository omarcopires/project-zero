import QtQuick
import QtQuick.Layouts
import qmlcomponents
import qmlenumvalues


TibiaDialog {
  id: confirmationDialog
  caption: qsTrId("taskboard_shop_purchase_confirmation_caption")
  width: 380

  required property var controller
  property var rewardName: controller.title
  property var rewardCost: controller.cost
  property var rewardType: controller.rewardType
  property var appearanceId: controller.appearanceId

  onReturnPressedFunction: function() {
    if (controller != null) {
      controller.purchaseRequested();
    }
  }

  onCancelPressedFunction: function() {
    if (controller != null) {
      controller.closeRequested();
    }
  }

  initialFocusItem: confirmationDialog
  KeyNavigation.tab: confirmationDialog

  ColumnLayout {
    spacing: TibiaStyle.marginUnrelated
    anchors { left: parent.left; right: parent.right; top: parent.top }

    TaskboardShopOffer {
      Layout.fillWidth: true
      Layout.preferredHeight: 80   
      Layout.alignment: Qt.AlignHCenter
      
      rewardType: confirmationDialog.rewardType
      appearanceId: confirmationDialog.appearanceId
      optionalAppearanceId: controller.optionalId
      outfitAppearanceId: controller.appearanceId
      headColor: controller.headColor
      torsoColor: controller.torsoColor
      legsColor: controller.legsColor
      detailColor: controller.detailColor
      addOn1: controller.addOn1
      addOn2: controller.addOn2
    } // TaskboardShopOffer

  
    
    TibiaText {
      text: qsTrId("taskboard_shop_purchase_confirmation").arg(rewardName).arg(rewardCost)
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignHCenter
      wrapMode: Text.Wrap
      textFormat: Text.RichText
    } // TibiaText


    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    }

    RowLayout {
      Layout.alignment: Qt.AlignHCenter
      spacing: TibiaStyle.marginRelated

      TibiaButton {
        id: buyButton
        text: qsTrId("buy")

        onClicked: onReturnPressedFunction();
      } // TibiaButton

      TibiaButton {
        id: cancelButton
        text: qsTrId("cancel")

        onClicked: onCancelPressedFunction();
      } // TibiaButton
    } // RowLayout
  } // ColumnLayout
} // TibiaDialog
