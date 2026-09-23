import QtQuick
import QtQuick.Layouts

import qmlcomponents


Item {
  id: areaCaptionItem
  property var controller: null
  property string caption: controller != null ? controller.caption: ""
  property int imminentRaids: controller != null ? controller.numberOfImminentRaids : 0
  property string captionTextColor: controller != null ? controller.captionColor : "white"
  TibiaText {
    id: invisibleText
    visible: false
    text: "<a href=\"\\1\" style=\"color:" + captionTextColor + "; text-decoration:none;\">" + caption + "</a>"
    textFormat: Text.RichText
    style: Text.Outline
    wrapMode: Text.WordWrap
    elide: Text.ElideNone
    horizontalAlignment : Text.AlignHCenter
    width: 70
  }
  RowLayout {
    anchors.centerIn: parent
    TibiaText {
      Layout.preferredWidth: Math.min(invisibleText.implicitWidth, invisibleText.contentWidth)
      text: invisibleText.text
      textFormat: invisibleText.textFormat
      style: invisibleText.style
      wrapMode: invisibleText.wrapMode
      elide: invisibleText.elide
      horizontalAlignment : invisibleText.horizontalAlignment
//      onLinkHovered: {
//        if (hoveredLink != "" && controller != null) {
//          controller.onHovered();
//        }
//      }
//      onLinkActivated: {
//        if (controller != null) {
//          controller.onClicked();
//        }
//      }
      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        onEntered: {
//          console.log('AreaCaption onEntered');
        }

        onExited: {
//          console.log('AreaCaption onExited');
        }

        onClicked: (mouse) => {
//          console.log('AreaCaption onClicked');
          mouse.accepted = false;
          controller.onClicked();
        } // onClicked
      }
      Tooltip {
        anchors.fill: parent
        visible: imminentRaids > 0
        text: controller != null ? (controller.numberOfImminentRaids == 1 ? qsTrId("imminent_raids_tooltip_singular").arg(caption).arg(imminentRaids) : qsTrId("imminent_raids_tooltip_plural").arg(caption).arg(imminentRaids)) : ""
      } // Tooltip
    }
    Image {
      id: imminentRaidImage
      Layout.alignment: Qt.AlignVCenter
      source: controller != null ? controller.numberOfImminentRaids > 0 ? "/images/icon-imminentraid.png" : "" : ""
      Tooltip {
        anchors.fill: parent
        visible: imminentRaids > 0
        text: controller != null ? (controller.numberOfImminentRaids == 1 ? qsTrId("imminent_raids_tooltip_singular").arg(caption).arg(imminentRaids) : qsTrId("imminent_raids_tooltip_plural").arg(caption).arg(imminentRaids)) : ""
      } // Tooltip
    }

    Image {
      id: activeAreaImage
      Layout.alignment: Qt.AlignVCenter
      source: controller != null ? controller.isImprovedRespawnActive ? "/images/icon-map-improvedrespawn.png" : "" : ""
      Tooltip {
        anchors.fill: parent
        visible: controller != null ? controller.isImprovedRespawnActive : false
        text: qsTrId("improved_respawn_tooltip")
      } // Tooltip
    } // Image

  }


} // Item
