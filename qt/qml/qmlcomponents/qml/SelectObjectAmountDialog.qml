import QtQuick
import QtQuick.Layouts



TibiaDialog {
  id: root
  caption: controller != null ? controller.caption
                              : qsTrId("selectamount_move_caption")
  implicitWidth: 245

  property var controller: null

  //keep focus to the dialog itself, no tab navigation wanted
  initialFocusItem: root
  KeyNavigation.tab: root
  KeyNavigation.backtab: root

  onCancelPressedFunction: onCancelClicked
  onReturnPressedFunction: onOkClicked

  function onCancelClicked() {
    if (controller != null) {
      controller.cancelButtonClicked();
    }
  } //function onCloseClicked

  function onOkClicked() {
    if (controller != null) {
      controller.okButtonClicked();
    }
  } //function onCloseClicked


  property string keySequence: ""
  function addPressedKey(NewKey) {
    keySequence = keySequence.concat(NewKey);
    keyPressCollectTimer.restart();

    if (keyPressCollectTimer.running) {
      var convertedAmount = parseInt(keySequence);

      selectAmountSlider.value = Math.min(selectAmountSlider.maximumValue,
                                          Math.max(selectAmountSlider.minimumValue,
                                                   convertedAmount));
    }
  } //function addPressedKey

  Timer {
    id: keyPressCollectTimer
    interval: 500
    onTriggered: { keySequence = "" }
  } //Timer

  Keys.onPressed: (event) => {
    var stepSize = 1;
    if (event.modifiers & Qt.ShiftModifier) {
      stepSize *= 10;
    }
    if (event.modifiers & Qt.ControlModifier ) {
      stepSize *= 100;
    }

    if (event.key == Qt.Key_Left) {
      selectAmountSlider.value -= stepSize;
    } else if (event.key == Qt.Key_Right) {
      selectAmountSlider.value += stepSize;
    } else if (event.key == Qt.Key_PageUp) {
      selectAmountSlider.value += 10;
    } else if (event.key == Qt.Key_PageDown) {
      selectAmountSlider.value -= 10;
    } else if ((event.key == Qt.Key_0 || event.key == Qt.Key_1 || event.key == Qt.Key_2 ||
                event.key == Qt.Key_3 || event.key == Qt.Key_4 || event.key == Qt.Key_5 ||
                event.key == Qt.Key_6 || event.key == Qt.Key_7 || event.key == Qt.Key_8 ||
                event.key == Qt.Key_9) &&
               (event.modifiers == Qt.NoModifier || event.modifiers == Qt.KeypadModifier)) {
      addPressedKey(event.text);
    }
  } //Keys.onPressed

  ColumnLayout {
    anchors { left: parent.left; right: parent.right }
    spacing: TibiaStyle.marginUnrelated

    RowLayout {
      spacing: TibiaStyle.marginUnrelated

      ContainerSlot {
        id: cumulativeItemContainerSlot
        Layout.alignment: Qt.AlignTop

        slotText: controller != null && controller.slotData != null ? controller.slotData.countString : "0"
        objectAppearanceInstanceTypeId: controller != null && controller.slotData != null ? controller.slotData.displayTypeID : 0
        objectAppearanceInstanceCumulativeCount: controller != null && controller.slotData != null ? controller.slotData.cumulativeCount : 0
      } //ContainerSlot

      ColumnLayout {
        Layout.fillWidth: true

        TibiaText {
          id: messageText
          text: controller != null ? controller.message : ""
          wrapMode: Text.WordWrap

          Layout.fillWidth: true
        } // TibiaText

        TibiaSlider {
          id: selectAmountSlider
          Layout.fillWidth: true
          minimumValue: 1
          maximumValue: controller != null ? controller.maxAmount : 100
          stepSize: 1
          value: maximumValue

          onValueChanged: {
            if (controller != null) {
              controller.setCurrentAmount(value);
            }
          } //onValueChanged
        } //TibiaSlider
      } // ColumnLayout
    } // RowLayout

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } // TibiaHorizontalSeparator

    RowLayout {
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignRight

      TibiaButton{
        id: okButton
        text: qsTrId("ok")
        onClicked: root.onOkClicked()
      } //TibiaButton

      TibiaButton{
        id: cancelButton
        text: qsTrId("cancel")
        onClicked: root.onCancelClicked()
      } //TibiaButton

    } // RowLayout
  } // ColumnLayout

} //TibiaDialog
