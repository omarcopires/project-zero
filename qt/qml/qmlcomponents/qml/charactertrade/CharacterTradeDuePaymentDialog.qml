import QtQuick
import QtQuick.Layouts

import qmlcomponents
import "qrc:/qt/qml/qmlcomponents/qml/"


TibiaDialog {
  id: charTradeDuePaymentDialog
  caption: qsTrId("chartrade_duepayment_caption")
  width: 450

  property QtObject controller: null

  function closeClicked() {
    if (controller != null) {
      controller.onClosePressed(doNotRemindAgainCheckbox.checked);
    }
  }

  onReturnPressedFunction: closeClicked
  onCancelPressedFunction: closeClicked
  initialFocusItem: charTradeDuePaymentDialog
  KeyNavigation.tab: charTradeDuePaymentDialog

  ColumnLayout {
    id: columns
    anchors { left: parent.left; right: parent.right }
    spacing: TibiaStyle.marginUnrelated

    TibiaText {
      Layout.fillWidth: true
      wrapMode: Text.Wrap
      textFormat: Text.StyledText
      text: qsTrId("chartrade_duepayment_info")
    } //TibiaText

    ListView {
      model: controller.duePayments
      Layout.preferredHeight: contentHeight
      Layout.fillWidth: true
      spacing: TibiaStyle.marginNarrow

      boundsBehavior: Flickable.StopAtBounds
      interactive: false //prevent flick behavior on touch screens

      delegate: TibiaText {
        text: qsTrId("chartrade_duepayment_entry")
          .arg(model.characterName)
          .arg(model.dueAmountString)
          .arg(model.dueDateString)
      } // TibiaText
    } // ListView

    TibiaMenuOptionCheckBox {
      id: doNotRemindAgainCheckbox
      Layout.fillWidth: true
      text: qsTrId("chartrade_duepayment_donotremindagain")
    } //TibiaMenuOptionCheckBox

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
        text: qsTrId("close")

        onClicked: closeClicked();
       } //TibiaButton
    } //RowLayout

  }//ColumnLayout
} //TibiaDialog
