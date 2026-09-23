import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic

import qmlcomponents
import qmlenumvalues

Rectangle {
  id: root

  property alias imageSource: proficiencyPerk.imageSource
  property alias hasAugmentEffect: proficiencyPerk.hasAugmentEffect
  property alias augmentEffectImageSource: proficiencyPerk.augmentEffectImageSource
  property alias isShaped: proficiencyPerk.isShaped
  property alias perkRank: proficiencyPerk.perkRank
  property alias hasHighlight: proficiencyPerk.hasHighlight
  property alias isActive: proficiencyPerk.isActive
  property alias isSelected: proficiencyPerk.isSelected
  property alias showLockIcon: proficiencyPerk.showLockIcon
  property alias isInteractive: proficiencyPerk.isInteractive
  property alias perkName: proficiencyPerk.perkName
  property alias perkDescription: proficiencyPerk.perkDescription

  implicitWidth: 200
  implicitHeight: 300

  TibiaFrame2PixelUpFilledWithCaption {
    id: innerFrame
    caption: root.perkName
    width: root.width
    height: root.height
    ColumnLayout {
      id: selectedLayout
      anchors.fill: parent
      anchors.margins: parent.marginsToContent
      anchors.topMargin: parent.topMarginToContent

      spacing: TibiaStyle.marginUnrelated

      TibiaProficiencyPerk {
        id: proficiencyPerk
        Layout.alignment: Qt.AlignHCenter
      } //ProficiencyPerk

      TibiaTextArea {
        id: infoTextArea
        Layout.fillWidth: true
        Layout.fillHeight: true
        readOnly: true
        verticalScrollBarPolicy: ScrollBar.AlwaysOff

        text: root.perkDescription
      } //TibiaTextArea
    } //ColumnLayout
  } //TibiaFrame2PixelUpFilledWithCaption
}