import QtQuick

import qmlcomponents


Image {
  property alias text: mouseOverHelp.text
  property string color: "grey"
  property alias useRichText: mouseOverHelp.useRichText

  source: "/images/skin/classic/show-gui-help-" + color + ".png"

  smooth: false

  Tooltip {
    id: mouseOverHelp
    anchors.fill: parent
    delayInMs: TibiaStyle.guiHelpDelay
    maxWidth: TibiaStyle.guiHelpTooltipWidth
  } //Tooltip
} //Image
