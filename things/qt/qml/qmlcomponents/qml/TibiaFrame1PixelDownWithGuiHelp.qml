import QtQuick



TibiaFrame1PixelDown {
  property alias guiHelpText: guiHelp.text
  property alias guiHelpMarkColor: guiHelp.color
  property alias guiHelpUseRichText: guiHelp.useRichText
  property bool  guiHelpAlignVerticalCenter: false
  property var guiHelpItem: guiHelp

  TibiaGuiHelp {
    id: guiHelp

    anchors.margins: TibiaStyle.marginRelated
    anchors.right: parent.right
    anchors.verticalCenter: guiHelpAlignVerticalCenter ? parent.verticalCenter : undefined
    anchors.top: !guiHelpAlignVerticalCenter ? parent.top : undefined

    visible: text != ""
    z: 999
  } //TibiaGuiHelp
} //TibiaFrame1PixelDown
