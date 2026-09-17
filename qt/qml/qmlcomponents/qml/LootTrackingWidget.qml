import QtQuick
import QtQuick.Layouts

import qmlcomponents


TibiaSidebarWidget {
  id: lootTrackingWidget
  caption: qsTrId("loottracker_caption")
  picSource: "/images/skin/classic/icon-loottracker-widget.png"

  minContentHeight: 40
  initialContentHeight: Math.max(TibiaStyle.widgetWithScrollbarMinContentHeight, lootListItem.height)

  customButtonContainerData: [
    TibiaIconButton {
      id: contextMenuButton
      sourceUp:   "/images/skin/classic/button-contextmenu-12x12-idle.png"
      sourceDown: "/images/skin/classic/button-contextmenu-12x12-pressed.png"
      tooltipText: qsTrId("loottracker_configure_tooltip")
      onClicked: widgetController!=null ?  widgetController.requestConfigurationMenu() : undefined;
    } //TibiaIconButton
  ] //customButtonContainerData

  TibiaScrollView {
    id: scrollView
    anchors.fill: parent

    Flickable {
      id: lootListItem
      leftMargin: TibiaStyle.marginNarrow
      topMargin: TibiaStyle.marginNarrow
      rightMargin: TibiaStyle.marginNarrow
      bottomMargin: TibiaStyle.marginNarrow

      contentHeight: lootLayout.contentHeight + trackButton.height + TibiaStyle.marginUnrelated * 2
      pixelAligned: true

      interactive: false //prevent flick behavior on touch screens
      boundsBehavior: Flickable.StopAtBounds
      rebound: Transition {}

      Item {
        anchors.fill: parent

        ListView {
          id: lootLayout
          spacing: TibiaStyle.marginNarrow
          anchors { top: parent.top; left: parent.left; right: parent.right; bottom: trackButton.top; bottomMargin: TibiaStyle.marginUnrelated * 2 }
          model: widgetController != null ? widgetController.trackedItems : null
          interactive: false //prevent flick behavior on touch screens
          boundsBehavior: Flickable.StopAtBounds
          rebound: Transition {}

          delegate: Item {
            height: itemSprite.height + dropView.contentHeight + TibiaStyle.marginNarrow
            width: lootLayout.width

            // Item that is tracked
            SingleObjectAppearanceInstanceRenderer {
              id: itemSprite
              width: TibiaStyle.mapWindowPixelPerField
              height: TibiaStyle.mapWindowPixelPerField

              animated: true
              typeid: modelData != null ? modelData.objectID : 0
              //no further properties

              Tooltip {
                anchors.fill: parent
                text: modelData != null ? qsTrId("loottracker_item_value").arg(modelData.itemValueString) : qsTrId("dummy_unknown")
              } //Tooltip
            } //SingleObjectAppearanceInstanceRenderer

            TibiaText {
              id: itemName
              anchors { left: itemSprite.right; leftMargin: TibiaStyle.marginRelated; top: parent.top; right: parent.right; }
              text: modelData != null ? modelData.itemName : qsTrId("dummy_unknown")
              styleType: "Default"
            } // TibiaText

            TibiaText {
              anchors { left: itemSprite.right; leftMargin: TibiaStyle.marginRelated;
                        top: itemName.bottom; topMargin: TibiaStyle.marginNarrow; right: parent.right; }
              text: modelData != null ? qsTrId("loottracker_drops").arg(modelData.dropCountString) : qsTrId("dummy_unknown")
              Tooltip {
                anchors.fill: parent
                text: modelData != null ? qsTrId("loottracker_tracked_since").arg(modelData.trackingStartTime) : qsTrId("dummy_unknown")
              } // Tooltip
            } // TibiaText

            // Actual loot drops are displayed in this ListView
            ListView {
              id: dropView
              anchors { left: parent.left; right: parent.right; top: itemSprite.bottom; topMargin: TibiaStyle.marginNarrow; bottom: parent.bottom }
              model: modelData != null ? modelData.lootDrops : null
              spacing: TibiaStyle.marginNarrow
              interactive: false //prevent flick behavior on touch screens
              boundsBehavior: Flickable.StopAtBounds
              rebound: Transition {}

              delegate: RowLayout {
                height: TibiaStyle.battleListMonsterSize
                width: dropView.width
                spacing: 0

                Image {
                  Layout.leftMargin: TibiaStyle.marginRelated
                  source: "/images/hierarchy-branch.png"
                  smooth: false
                } //Image

                OutfitAppearanceInstanceRenderer {
                  id: outfitAppearanceInstanceRenderer
                  Layout.preferredWidth: TibiaStyle.battleListMonsterSize
                  Layout.preferredHeight: TibiaStyle.battleListMonsterSize
                  shrinkToFit: true

                  outfitId: modelData != null ? modelData.creatureOutfitId : 0
                  headColor: modelData != null ? modelData.creatureHeadColor : "black"
                  torsoColor: modelData != null ? modelData.creatureTorsoColor : "black"
                  legsColor: modelData != null ? modelData.creatureLegsColor : "black"
                  detailColor: modelData != null ? modelData.creatureDetailColor : "black"
                  firstAddOn: modelData != null ? modelData.creatureFirstAddOn : false
                  secondAddOn: modelData != null ? modelData.creatureSecondAddOn : false
                } //OutfitAppearanceInstanceRenderer

                TibiaText {
                  Layout.fillWidth: true
                  Layout.leftMargin: TibiaStyle.marginRelated
                  text: modelData != null ? qsTrId("loottracker_monster_loot").arg(modelData.monsterName).arg(modelData.dropCountString) : qsTrId("dummy_unknown")

                  Tooltip {
                    anchors.fill: parent
                    text: modelData != null ? qsTrId("loottracker_drop_time").arg(modelData.dropTimestamp) : qsTrId("dummy_unknown")
                  } // Tooltip
                } // TibiaText
              } // delegate: RowLayout
            } // ListView

            MouseArea {
              anchors.fill: parent
              acceptedButtons: Qt.RightButton
              onClicked: modelData != null && widgetController != null ? widgetController.requestContextMenu(modelData.appearanceTypeID) : null;
            } // MouseArea
          } // Item
        } // ListView

        TibiaButton {
          id: trackButton
          text: qsTrId("loottracker_track_new")
          anchors { horizontalCenter: parent.horizontalCenter;
                    bottom: parent.bottom; bottomMargin: TibiaStyle.marginUnrelated; }
          width: TibiaStyle.buttonWidthWider

          onClicked: {
            if (widgetController != null) {
              widgetController.requestOpenItemInfoDialog()
            }
          }
        } // TibiaButton
      } // Item
    } // Flickable
  } //TibiaScrollView


  Lenshelp {
    anchors.fill: parent
    triggerRect: mapFromItem(widgetRoot, 0, 0, widgetRoot.width, widgetRoot.height)
    caption: qsTrId("loottracker_lenshelp_caption")
    content: qsTrId("loottracker_lenshelp")
  } //Lenshelp
} // TibiaSidebarWidget
