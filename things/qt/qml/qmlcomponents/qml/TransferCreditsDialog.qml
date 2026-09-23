import QtQuick
import QtQuick.Layouts



TibiaDialog {
  id: transferCreditsDialog
  caption: qsTrId("store_gift_coins_caption")
  width: 280

  property var controller: null

  onReturnPressedFunction: function() {
    if (controller != null && okButton.enabled) {
      controller.requestTransfer(nameField.text, amountSlider.value);
    }
  }

  onCancelPressedFunction: function() {
    if (controller != null) {
      controller.requestCancel();
    }
  }

  initialFocusItem: nameField

  ColumnLayout {
    spacing: TibiaStyle.marginUnrelated
    anchors { top: parent.top; left: parent.left; right: parent.right; }

    TibiaText {
      text: qsTrId("store_gift_coins_description")
      Layout.fillWidth: true
      wrapMode: Text.Wrap
    } //TibiaText

    RowLayout {
      spacing: TibiaStyle.marginRelated
      Layout.fillWidth: true

      TibiaText {
        text: qsTrId("store_gift_coins_recipient")
        Layout.rightMargin: 30
      } //TibiaText

      TibiaTextField {
        id: nameField
        Layout.fillWidth: true
        KeyNavigation.tab: nameField
        maximumLength: controller != null ? controller.maximumNameLength : 0
      } //TibiaTextField
    } //RowLayout

    RowLayout {
      spacing: TibiaStyle.marginRelated
      TibiaText {
        text: qsTrId("store_gift_tibia_coins_transferable_amount").arg(
          controller != null ? controller.formatCreditNumber(controller.transferableCredits) : "0")
      } //TibiaText

      Image {
        source: "/images/icon-tibiacointransferable.png"
      } //Image
    } //RowLayout

    RowLayout {
      spacing: TibiaStyle.marginRelated
      TibiaText {
        text: qsTrId("store_gift_amount").arg(
        controller != null ? controller.formatCreditNumber(amountSlider.value) : "-")
      } //TibiaText

      Image {
        source: "/images/icon-tibiacointransferable.png"
      } //Image
    } // RowLayout

    TibiaSlider {
      id: amountSlider
      Layout.fillWidth: true
      minimumValue: controller != null ? controller.creditPacketSize : 0
      maximumValue: controller != null ? controller.transferableCredits - (controller.transferableCredits % controller.creditPacketSize) : 0
      stepSize: controller != null ? controller.creditPacketSize : 1
      value: minimumValue
    }

    TibiaHorizontalSeparator {
      Layout.topMargin: TibiaStyle.marginRelated
      Layout.fillWidth: true
    }

    RowLayout {
      Layout.alignment: Qt.AlignRight
      spacing: TibiaStyle.marginUnrelated

      TibiaButton {
        id: okButton
        text: qsTrId("store_gift_button")
        enabled: nameField.length > 0 && amountSlider.value > 0
        onClicked: onReturnPressedFunction();
      }

      TibiaButton {
        text: qsTrId("cancel")
        onClicked: onCancelPressedFunction();
      }
    } // RowLayout
  } // ColumnLayout
} // TibiaDialog
