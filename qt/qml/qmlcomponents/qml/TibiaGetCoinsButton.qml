import QtQuick

import qmlcomponents


TibiaButton {
  text: qsTrId("store_get_coins")
  color: "green"
  imageSource: "/images/icon-tibiacoin.png"
  imageXOffset: 8

  Tooltip {
    anchors.fill: parent
    text: qsTrId("store_get_coins_tooltip")
  } //Tooltip
} //TibiaButton
