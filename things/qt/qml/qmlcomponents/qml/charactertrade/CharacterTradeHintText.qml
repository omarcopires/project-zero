import QtQuick
import QtQuick.Layouts

import qmlcomponents
import "qrc:/qt/qml/qmlcomponents/qml/"

ColumnLayout {
  TibiaText {
    id: summaryCaptionText
    Layout.fillWidth: true
    Layout.margins: TibiaStyle.marginRelated
    textFormat: Text.RichText
    text: qsTrId("charactertrade_hint_text")
    wrapMode: Text.WordWrap
  }

  Item {
    Layout.fillHeight: true
  }
}
