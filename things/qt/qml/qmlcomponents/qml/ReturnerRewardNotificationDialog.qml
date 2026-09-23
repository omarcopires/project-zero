import QtQuick
import QtQuick.Layouts



TibiaDialog {
  id: returnerRewardNotificationDialog
  caption: qsTrId("returner_reward_notification_caption")
  width: 560

  property QtObject controller: null

  function continueClicked() {
    if(null != controller) {
      controller.onContinueClicked();
    }
  } //function continueClicked()

  onReturnPressedFunction: continueClicked
  onCancelPressedFunction: continueClicked
  initialFocusItem: returnerRewardNotificationDialog
  KeyNavigation.tab: returnerRewardNotificationDialog

  ColumnLayout {
    id: columns
    anchors { left: parent.left; right: parent.right}
    spacing: TibiaStyle.marginUnrelated

    RowLayout {
      TibiaText {
        Layout.fillWidth: true
        Layout.preferredHeight: contentHeight
        Layout.maximumHeight: Layout.preferredHeight
        wrapMode: Text.WordWrap
        textFormat: Text.RichText
        text: controller!=null ? controller.dialogText : qsTrId("returner_reward_notification_text");
      } //TibiaText

      Image {
        source: "/images/premium/illustration-welcomeback.png"
      } //Image

    } //RowLayout

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } //TibiaHorizontalSeparator

    RowLayout {
      Layout.fillWidth: true
      spacing: TibiaStyle.marginUnrelated

      Item {
        Layout.fillWidth: true
      } //Item

      TibiaButton {
        text: qsTrId("continue")
        Layout.preferredWidth: TibiaStyle.buttonWidthBroad

        onClicked: { continueClicked(); }
      } //TibiaButton
    } //RowLayout

  }//ColumnLayout
} //TibiaDialog
