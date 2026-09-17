import QtQuick
import QtQuick.Layouts

import qmlcomponents



TibiaSidebarWidget {
  id: vipSidebarWidget
  caption: qsTrId("vip_caption")
  picSource: "/images/skin/classic/icon-vip-widget.png"

  property var vipModel: null

  initialContentHeight: 200

  customButtonContainerData: [
    TibiaIconButton {
      id: contextMenuButton
      sourceUp:   "/images/skin/classic/button-contextmenu-12x12-idle.png"
      sourceDown: "/images/skin/classic/button-contextmenu-12x12-pressed.png"
      tooltipText: qsTrId("vip_configure_tooltip")
      onClicked: widgetController != null ? widgetController.onWidgetClicked(Qt.RightButton, Qt.NoModifier) : undefined
    } //TibiaIconButton
  ]

  TibiaScrollView {
    id: vipListScrollView
    anchors.fill: parent

    ListView {
      id: vipListView
      leftMargin: TibiaStyle.marginNarrow
      topMargin: TibiaStyle.marginNarrow
      rightMargin: TibiaStyle.marginNarrow
      bottomMargin: TibiaStyle.marginNarrow


      model: vipModel

      interactive: false //prevent flick behavior on touch screens
      pixelAligned : true
      boundsBehavior: Flickable.StopAtBounds
      spacing: 3

      section.property: vipModel == null || vipModel.showGroups == false ? "": "groupName"
      section.delegate:
        Item {
          id: sectionComponent
          width: vipListView.width
          height: sectionLayout.height

          MouseArea {
            anchors.fill: sectionLayout
            acceptedButtons: Qt.RightButton
            onClicked: (mouse) => {
              widgetController.onVipOrGroupClicked("", section, mouse.button, mouse.modifiers);
            }
          } // MouseArea

          ColumnLayout {
            id: sectionLayout
            visible: true
            width: vipListView.width

            spacing: 2

            Item {
              Layout.fillWidth: true
              height: 2
            }

            TibiaText {
              text: section == "" ? qsTrId("vip_ungrouped_group_name") : section
              styleType: "VipGroup"
              Layout.fillWidth: true
            } // TibiaText

            TibiaHorizontalSeparator {
              Layout.fillWidth: true
            } //TibiaHorizontalSeparator
            Item {
              Layout.fillWidth: true
              height: 2
            }
          } // ColumnLayout
        } // Rectangle


      delegate: MouseArea {
        width: vipListView.width - vipListView.leftMargin - vipListView.rightMargin
        height: vipRowEntry.height

        acceptedButtons: Qt.RightButton
        onClicked: (mouse) => widgetController.onVipOrGroupClicked(vipName, "", mouse.button, mouse.modifiers)

        MouseArea {
          anchors.fill: parent
          acceptedButtons: Qt.LeftButton
          onDoubleClicked: widgetController.onVipDoubleClicked(vipName)
        } //MouseArea

        RowLayout {
          id: vipRowEntry
          anchors {left: parent.left; right:parent.right}
          spacing: 4

          Image {
            source: "image://vip-icons/" + vipIconId
            smooth: false
          } //Image

          TibiaText {
            id: nameText
            text: vipName
            styleType: {
              if (vipHighlighted == true) {
                return "VipHighlight";
              }

              //see enum class EVipState in creaturtypes.h
              switch(vipState) {
                case 0: return "VipOffline";
                case 1: return "VipOnline";
                case 2: return "VipPending";
                case 3: return "VipExerciseWeaponTraining";
                case 4: return "VipOnline";
                case 5: return "VipOffline";
                default: return "VipOnline";
              }
            }
            elide: Text.ElideRight
            Layout.fillWidth: true

            property string vipStateString: {
              //see enum class EVipState in creaturtypes.h
              switch(vipState) {
                case 0: return qsTrId("vip_offline");
                case 1: return qsTrId("vip_online");
                case 2: return qsTrId("vip_pending");
                case 3: return qsTrId("vip_exerciseweapon_training");
                case 4: return qsTrId("vip_online");
                case 5: return qsTrId("vip_offline");
                default: return qsTrId("dummy_unknown");
              }
            }

            tooltipText: qsTrId("vip_entry_tooltip").arg(vipName).arg(vipStateString)
          } //TibiaText
        } //RowLayout
      } //delegate: MouseArea

      footer: Item {
        height: TibiaStyle.vipListBottomMargin
      }

      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        z: parent.z -1
        onClicked: (mouse) => widgetController != null ? widgetController.onWidgetClicked( mouse.button, mouse.modifiers) : undefined
      } //MouseArea
    } //ListView
  } // TibiaScrollView

  Lenshelp {
    anchors.fill: parent
    triggerRect: mapFromItem(widgetRoot, 0, 0, widgetRoot.width, widgetRoot.height)
    caption: qsTrId("vip_caption")
    content: qsTrId("vip_widget_lenshelp")
  } //Lenshelp

} // TibiaSidebarWidget
