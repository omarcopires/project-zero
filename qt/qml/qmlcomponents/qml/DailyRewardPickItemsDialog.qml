import QtQuick
import QtQuick.Layouts

import qmlcomponents


TibiaDialog {
  id: dialogRoot
  caption: qsTrId("pickitems_caption")
  width: 450

  property var controller: null

  property int totalPickCount: controller != null ? controller.totalPickCount : 0
  property int pickCountLeft: controller != null ? controller.pickCountLeft : 0
  property int currentPickCount: controller != null ? controller.currentPickCount : 0

  onReturnPressedFunction: okButtonClicked
  onCancelPressedFunction: closeDialog

  function closeDialog() {
    if (controller != null) {
      controller.closeButtonClicked();
    }
  } //function closeDialog

  function okButtonClicked() {
    if (controller != null && confirmButton.enabled) {
      controller.okButtonClicked();
    }
  } //function okButtonClicked

  initialFocusItem: dialogRoot
  KeyNavigation.tab: dialogRoot

  ColumnLayout {
    anchors { left: parent.left; top: parent.top; right: parent.right }
    spacing: TibiaStyle.marginRelated

    TibiaText {
      text: qsTrId("pickitems_pick_count_tracker").arg(dialogRoot.currentPickCount)
                                                  .arg(dialogRoot.totalPickCount)
                                                  .arg(dialogRoot.pickCountLeft == 0 ? TibiaStyle.green1 : TibiaStyle.red2)
    } // TibiaText

    TibiaFrame1PixelDown {
      id: listFrame
      Layout.fillWidth: true
      Layout.preferredHeight: 265

      Rectangle {
        anchors.fill: parent
        anchors.margins: parent.borderWidth
        color: TibiaStyle.tableViewBackgroundColor
      } //Rectangle

      TibiaScrollView {
        anchors.fill: parent
        anchors.margins: parent.borderWidth

        ListView {
          id: listView
          boundsBehavior: Flickable.StopAtBounds
          interactive: false //prevent flick behavior on touch screens

          model: controller != null ? controller.objectToPickModel : null

          delegate: Rectangle {
            width: listView.width
            property int margin: 1
            height: TibiaStyle.containerSlotSize + 2 * margin

            color: index % 2 == 0 ? TibiaStyle.tableViewItemBackgroundColor : TibiaStyle.tableViewAlternateBackgroundColor

            RowLayout {
              anchors.fill: parent
              anchors.margins: parent.margin
              spacing: TibiaStyle.marginRelated

              ContainerSlot {
                objectAppearanceInstanceTypeId: modelData.objectID
                objectAppearanceInstanceCumulativeCount: 1
                mouseAreaEnabled: false
              } //ContainerSlot

              TibiaText {
                Layout.fillWidth: true
                Layout.maximumHeight: TibiaStyle.containerSlotSize
                wrapMode: Text.Wrap
                text: modelData.name
              } //TibiaText

              RowLayout {
                spacing: TibiaStyle.marginNarrow

                TibiaButton {
                  Layout.preferredHeight: amountField.height
                  Layout.preferredWidth: Layout.preferredHeight
                  imageSource: "/images/icon-arrowskip.png"
                  imageSourceDisabled: "/images/icon-arrowskip-disabled.png"
                  onClicked: amountField.changeAmountTo(0)
                  enabled: amountField.amount > 0
                } //TibiaButton

                TibiaButton {
                  Layout.preferredHeight: amountField.height
                  Layout.preferredWidth: Layout.preferredHeight
                  imageSource: "/images/icon-arrow.png"
                  imageSourceDisabled: "/images/icon-arrow-disabled.png"
                  autoRepeat: true
                  onClicked: amountField.changeAmountBy(-1)
                  enabled: amountField.amount > 0
                } //TibiaButton

                TibiaTextField {
                  id: amountField
                  Layout.preferredWidth: 24
                  maximumLength:2
                  horizontalAlignment: TextInput.AlignHCenter
                  validator: RegularExpressionValidator { regularExpression: /[0-9]{0,2}/; }
                  KeyNavigation.tab: amountField

                  text: "0"
                  property int amount: modelData.amount

                  onTextChanged: {
                    stringToIntTimer.restart();
                  } //onTextChanged
                  onEditingFinished: amountField.convertTextToAmountAndForceBounds()
                  onActiveFocusChanged: amountField.convertTextToAmountAndForceBounds()

                  Timer {
                    id: stringToIntTimer
                    interval: 500
                    onTriggered: amountField.convertTextToAmountAndForceBounds()
                  } //Timer

                  onAmountChanged: {
                    text = amount;
                    modelData.setAmount(amount);
                  } //onAmountChanged

                  function convertTextToAmountAndForceBounds() {
                    var newAmount = text == "" ? 0 : parseInt(text) //parseInt returns NaN for empty strings

                    amount = Math.max(0, Math.min(newAmount, dialogRoot.totalPickCount));
                    text = amount;
                  } //function convertTextToAmountAndForceBounds()

                  function changeAmountBy(changeBy) {
                    convertTextToAmountAndForceBounds();
                    amount = Math.max(0, Math.min(dialogRoot.totalPickCount, amount + changeBy));
                  } //function changeAmountBy(changeBy)

                  function changeAmountTo(changeTo) {
                    convertTextToAmountAndForceBounds();
                    amount = Math.max(0, Math.min(dialogRoot.totalPickCount, changeTo));
                  } //function changeAmountTo(changeTo)
                } //TibiaTextField

                TibiaButton {
                  Layout.preferredHeight: amountField.height
                  Layout.preferredWidth: Layout.preferredHeight
                  imageSource: "/images/icon-arrow.png"
                  imageSourceDisabled: "/images/icon-arrow-disabled.png"
                  autoRepeat: true
                  imageMirrored: true
                  onClicked: amountField.changeAmountBy(+1)
                  enabled: dialogRoot.pickCountLeft > 0
                } //TibiaButton

                TibiaButton {
                  Layout.preferredHeight: amountField.height
                  Layout.preferredWidth: Layout.preferredHeight
                  imageSource: "/images/icon-arrowskip.png"
                  imageSourceDisabled: "/images/icon-arrowskip-disabled.png"
                  imageMirrored: true
                  onClicked: amountField.changeAmountTo(amountField.amount + dialogRoot.pickCountLeft)
                  enabled: dialogRoot.pickCountLeft > 0
                } //TibiaButton
              } //RowLayout

              Item {
                Layout.preferredWidth: weightText.width
                Layout.preferredHeight: weightText.height

                RowLayout {
                  id: weightText
                  spacing: TibiaStyle.marginNarrow

                  TibiaText {
                    Layout.preferredWidth: TibiaStyle.pickItemWeightWith
                    Layout.maximumWidth: Layout.preferredWidth
                    horizontalAlignment: Text.AlignRight
                    text: modelData.totalWeight
                  } //TibiaText

                  TibiaText {
                    text: qsTrId("ounce_short")
                  } //TibiaText
                } //RowLayout

                Tooltip {
                  anchors.fill: parent
                  text: qsTrId("pickitems_single_weight").arg(modelData.singleWeight)
                } //Tooltip
              } //Item
            } //RowLayout

          } //delegate: Rectangle
        } //ListView
      } //TibiaScrollView
    } //TibiaFrame1PixelDown

    RowLayout {
      Layout.rightMargin: TibiaStyle.scrollBarWidth + 1 + listFrame.borderWidth //+1 delegates right margin
      spacing: TibiaStyle.marginNarrow

      TibiaText {
        text: qsTrId("pickitems_free_capacity")
      } //TibiaText

      TibiaText {
        text: controller != null ? controller.capacity : "0.00"
      } //TibiaText

      TibiaText {
        text: qsTrId("ounce_short")
      } //TibiaText

      Item {
        Layout.fillWidth: true
      } //Item

      TibiaText {
        text: qsTrId("pickitems_total_weight")
      } //TibiaText

      TibiaText {
        id: totalWeightText
        Layout.preferredWidth: TibiaStyle.pickItemWeightWith
        Layout.maximumWidth: Layout.preferredWidth
        horizontalAlignment: Text.AlignRight
        styleType: controller != null && controller.isTooHeavy ? "Negative" : "Dialog"
        text: controller != null ? controller.currentTotalWeight : "0.00"
      } //TibiaText

      TibiaText {
        styleType: totalWeightText.styleType
        text: qsTrId("ounce_short")
      } //TibiaText
    } //RowLayout


    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } //TibiaHorizontalSeparator

    RowLayout {
      Layout.alignment: Qt.AlignRight
      spacing: TibiaStyle.marginRelated

      Item {Layout.fillWidth: true}

      Item {
        Layout.preferredWidth: confirmButton.width
        Layout.preferredHeight: confirmButton.height

        TibiaButton {
          id: confirmButton
          text: qsTrId("ok")
          enabled: dialogRoot.pickCountLeft == 0 && (controller != null && !controller.isTooHeavy)

          onClicked: dialogRoot.okButtonClicked()
        } //TibiaButton

        Tooltip {
          anchors.fill: parent

          text: {
            var tooltip = "";
            if (dialogRoot.pickCountLeft != 0) {
              tooltip += qsTrId("pickitems_exact_amount_tooltip").arg(dialogRoot.totalPickCount)
            }

            if (controller != null && controller.isTooHeavy) {
              if(tooltip.length > 0) {
                tooltip += "\n"
              }
              tooltip += qsTrId("pickitems_too_heavy_tooltip")
            }

            return tooltip
          } //text
          enabled: text != ""
        } //Tooltip
      } //Item

      TibiaButton {
        id: closeButton
        text: qsTrId("close")

        onClicked: dialogRoot.closeDialog()
      } //TibiaButton
    } //RowLayout
  } //ColumnLayout

} //TibiaDialog
