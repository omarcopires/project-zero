import QtQuick

import qmlcomponents



Item {
  id: root

  property int iconID: 0
  property string name: ""
  property alias remainingTime: remainingTimeText.text
  property int visualization: TibiaEnums.AlmostNew

  readonly property bool isUsed: iconID > 0

  implicitHeight: TibiaStyle.containerSlotSize
  implicitWidth: implicitHeight

  BorderImage {
    id: borderFrame
    anchors.fill: parent

    readonly property int borderWidth: 1

    border { left: borderWidth; right: borderWidth; top: borderWidth; bottom: borderWidth }
    source: root.isUsed > 0 ? "/images/1pixel-down-frame.png" : "/images/1pixel-up-frame.png"
    horizontalTileMode: BorderImage.Repeat
    verticalTileMode: BorderImage.Repeat

    Image {
      anchors.fill: parent
      anchors.margins: borderFrame.borderWidth
      source: "image://imbuement-icons/" + root.iconID
    } //Image
  } //BorderImage

  TibiaText {
    id: remainingTimeText
    anchors { left: parent.left; right: parent.right; top: parent.top; leftMargin: -1 }
    styleType: { "InventoryOverlay"
      if (root.visualization == TibiaEnums.AlmostGone) {
        return "RemainingTimeAlmostGone";
      } else if (root.visualization == TibiaEnums.Used) {
        return "RemainingTimeUsed";
      }

      return "RemainingTimeAlmostNew";
    } //styleType
    style: Text.Outline
    horizontalAlignment: Text.AlignHCenter
    visible: root.isUsed

    font: slotTextItemSizeMeasurement.truncated ? TibiaStyle.defaultTightFont : TibiaStyle.defaultTextFont

    TibiaText {
      id: slotTextItemSizeMeasurement
      anchors.fill: parent
      visible: false

      text: parent.text

      styleType: parent.styleType
      style: parent.style
      horizontalAlignment: parent.horizontalAlignment
      font: TibiaStyle.defaultTextFont
    } //TibiaText
  } //TibiaText

  Tooltip {
    anchors.fill: parent

    maxWidth: TibiaStyle.guiHelpTooltipWidth
    text: root.isUsed
      ? "%1\n\n%2 %3"
        .arg(root.name)
        .arg(qsTrId("imbuing_time_remaining"))
        .arg(root.remainingTime)
      : qsTrId("imbuement_tracker_empty_slot")
  } //Tooltip
} //Item
