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

  property int taskIndex: -1
  property int typeId: 0
  property string captionText: ""
  property int availableAmount: -1
  property int requiredAmount: -1
  property bool delivered: false
  property var deliverAction: null

  signal clicked(int TypeID, int MouseButton, int KeyboardModifier)

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
        
        SingleObjectAppearanceInstanceRenderer {
          anchors.centerIn: parent
          width: parent.width / 2
          height: parent.height / 2
          animated: true
          typeid: typeId
        
          Tooltip {
            anchors.fill: parent
            text: captionText
          }
        }
      }

      MouseArea {
        id: deliveryItemMouseArea
        anchors.fill: parent
        drag.threshold: TibiaStyle.dragThreshold
        acceptedButtons: Qt.RightButton | Qt.LeftButton
      
        property bool dualMouseClickEmulationActive: false
      
        onClicked: (mouse) => {
          if (mouse.buttons == 0) {
            if (!dualMouseClickEmulationActive) {
              root.clicked(typeId, mouse.button, mouse.modifiers);
            } else {
              // Left+Right is mapped to MiddleMouse
              root.clicked(typeId, Qt.MiddleButton, Qt.NoModifier);
            }
          }
        } //onClicked
      
      } // MouseArea
    }

    ColumnLayout {
      Layout.alignment: Qt.AlignVCenter
      Layout.bottomMargin: TibiaStyle.marginNarrow * 4 -1
      Layout.preferredWidth: 52
      spacing: TibiaStyle.marginNarrow + 1

      ColumnLayout {
        spacing: TibiaStyle.marginNarrow
        Layout.alignment: Qt.AlignHCenter
        
        TibiaText {
          visible: !delivered
          Layout.alignment: Qt.AlignHCenter
          color: (availableAmount >= requiredAmount) ? TibiaStyle.green1 : TibiaStyle.red2
          text: availableAmount
        }
        
        TibiaText {
          visible: !delivered
          Layout.alignment: Qt.AlignHCenter
          text: "of"
        }
        
        TibiaText {
          visible: !delivered
          Layout.alignment: Qt.AlignHCenter
          text: requiredAmount
        }
        
        Image {
          Layout.alignment: Qt.AlignHCenter
          visible: delivered
          source: "qrc:/images/icon-yes.png"
        }
      } // ColumnyLayout

      TibiaButton {
        Layout.alignment: Qt.AlignHCenter
        text: qsTrId("taskboard_deliver_label")
        
        visible: !delivered
        enabled: availableAmount >= requiredAmount

        onClicked: {
          deliverAction();
        }
      }
    }
  }

} // TibiaFrame2PixelUpFilledWithCaption
