import QtQuick
import QtQuick.Controls.Basic
//import QtQuick.Templates as T

TabButton {
  id: control

  implicitWidth: TibiaStyle.tabWidth
  implicitHeight: TibiaStyle.defaultTextLineHeight + 5

  background: BorderImage {
    border { left: 2; top: 2; right: 2; bottom: 2 }
    horizontalTileMode: BorderImage.Repeat
    verticalTileMode: BorderImage.Repeat

    source: control.TabBar.index === control.TabBar.tabBar.currentIndex ? "/images/console-tab-active.png" : "/images/console-tab-passive.png"
  } //BorderImage

  contentItem: TibiaText {
    id: text
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    text: control.text
    font: TibiaStyle.buttonFont
    color: TibiaStyle.buttonTextColor
    elide: Text.ElideNone
  } //TibiaText
}
