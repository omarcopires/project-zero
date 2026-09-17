import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtWebChannel
import QtWebEngine

import qmlcomponents
import "qrc:/qt/qml/qmlcomponents/qml/"
import QtQuick.LegacyControls

TibiaFrame2PixelUpFilledWithCaption {
  id: root

  property int raceId: 0
  property string captionText: ""
  property int currentKillAmount: 0
  property int requiredAmount: 0

  width: 144
  height: 100

  caption: captionText

  RowLayout {
    anchors.leftMargin: TibiaStyle.marginNarrow * 4
    anchors.rightMargin: TibiaStyle.marginUnrelated
    anchors.topMargin: TibiaStyle.marginNarrow * 4 + root.captionHeight
    anchors.fill: parent
    spacing: TibiaStyle.marginUnrelated
    

    TibiaFrame1PixelDown {
      Layout.bottomMargin: TibiaStyle.marginNarrow * 4 - 1 
      Layout.alignment: Qt.AlignVCenter
      Layout.preferredWidth: 64 + 2
      Layout.preferredHeight: 64 + 2

      BorderImage {
        smooth: false
        anchors.fill: parent
        anchors.margins: 1
        source: "/images/backdrop-dark-grey.png"
        horizontalTileMode: BorderImage.Repeat
        verticalTileMode: BorderImage.Repeat
        visible: true
        cache: false
      
        Image {
          anchors.fill: parent
          visible: raceId == 0
          source: "/images/taskboard/icon-arbitrarymonster64x64.png"
        }
        
        RaceAppearanceInstanceRenderer {
          visible: raceId != 0
          anchors.fill: parent
          center: true
          raceID: raceId
        
          Tooltip {
            anchors.fill: parent
            text: captionText
          }
        }
      }
    }

    ColumnLayout {
      Layout.alignment: Qt.AlignVCenter
      Layout.preferredWidth: 52
      spacing: TibiaStyle.marginNarrow
      Layout.bottomMargin: TibiaStyle.marginNarrow * 4 - 1

      TibiaText {
        visible: currentKillAmount < requiredAmount      
        Layout.alignment: Qt.AlignHCenter
        color: TibiaStyle.red2
        text: currentKillAmount
      }

      TibiaText {
        visible: currentKillAmount < requiredAmount      
        Layout.alignment: Qt.AlignHCenter
        text: "of"
      }

      TibiaText {
        visible: currentKillAmount < requiredAmount      
        Layout.alignment: Qt.AlignHCenter
        text: requiredAmount
      }

      Image {
        Layout.alignment: Qt.AlignHCenter
        visible: currentKillAmount >= requiredAmount
        source: "qrc:/images/icon-yes.png"
      }
    }
  }
}
