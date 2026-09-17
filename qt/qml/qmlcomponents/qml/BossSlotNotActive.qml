import QtQuick
import QtQuick.Layouts

import qmlcomponents



TibiaPanel2PixelUpFilledWithCaption {

  property var controller: null
  property int gridMargin: TibiaStyle.marginRelated//TibiaStyle.marginNarrow
  property int slotNumber: 0
  property int unlockBosspoints: 0

  caption: qsTrId("bosstiary_caption_slot_not_active").arg(slotNumber)

  Item {
    id: outerItem
    Layout.fillWidth: true
    Layout.preferredHeight: bosspointsText.height + 280

    Layout.alignment: Qt.AlignVCenter

    TibiaText {
      id: bosspointsText
      text: unlockBosspoints > 0 ? qsTrId("bosstiary_slot_not_active_text").arg(unlockBosspoints) : qsTrId("bosstiary_slot_not_active_text_first_slot")
      anchors.centerIn: parent
      wrapMode: Text.Wrap
      verticalAlignment: Text.AlignVCenter
      horizontalAlignment: Text.AlignHCenter

      width: outerItem.width
    }
  } // Item

} // TibiaPanel2PixelUpFilledWithCaption
