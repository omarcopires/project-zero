import QtQuick
import QtQuick.Layouts

import qmlcomponents
import "qrc:/qt/qml/qmlcomponents/qml/"


ColumnLayout {
  property var notificationsModel: null
  property string infoText: qsTrId("charactertrade_conditions_hint_text")

  anchors.fill: parent

  TibiaText {
    id: summaryCaptionText
    Layout.fillWidth: true
    Layout.margins: TibiaStyle.marginRelated
    textFormat: Text.RichText
    text: infoText
    wrapMode: Text.WordWrap
  }

  TibiaFrame1PixelDown {
    Layout.fillWidth: true
    Layout.fillHeight: true
    Item {
      anchors.fill: parent
      anchors.margins: parent.borderWidth
      Rectangle {
        anchors.fill: parent
        color: TibiaStyle.textFieldBackgroundColor
      }
      TibiaScrollView {
        id: conditionsScrollView
        anchors.fill: parent

        ListView {
          id: conditionsListView
          model: notificationsModel

          boundsBehavior: Flickable.StopAtBounds
          interactive: false //prevent flick behavior on touch screens

          header: Item {
            height: TibiaStyle.marginNarrow
          } //header: Item

          footer: Item {
            height: TibiaStyle.marginNarrow
          } //header: Item

          delegate: Item {
            height: outerLayout.height
            width: conditionsListView.width - TibiaStyle.marginRelated
            RowLayout {
              id: outerLayout
              spacing: TibiaStyle.marginRelated
              anchors.left: parent.left
              anchors.right: parent.right
              anchors.leftMargin: TibiaStyle.marginRelated
              RowLayout {
                id: icon
                Layout.minimumWidth: 12
                Layout.topMargin: 3
                Layout.alignment: Qt.AlignTop
                Image {
                  Layout.alignment: Qt.AlignHCenter
                  source: {
                    if (model.status == TibiaEnums.Yes) {
                      return "qrc:/images/icon-yes.png";
                    } else if (model.status == TibiaEnums.No) {
                      return "qrc:/images/icon-no.png";
                    } else if (model.status == TibiaEnums.Warning) {
                      return "qrc:/images/icon-exclamationmark.png";
                    }
                  }
                } // Image
              } // RowLayout
              TibiaText {
                Layout.fillWidth: true
                text: {
                  return model.notification;
                }
                wrapMode: Text.WordWrap
              }
            }
          }
        }
      }
    }
  }
}
