import QtQuick
import QtQuick.Layouts

import qmlcomponents



TibiaSidebarWidget {
  id: root
  caption: qsTrId("imbuement_tracker_widget_caption")
  picSource: "/images/skin/classic/icon-imbuementtracker-widget.png"

  readonly property int maxImbueableSlots: 6
  readonly property int containerSlotOuterSize: TibiaStyle.containerSlotSize + TibiaStyle.containerSlotsMargin
  minContentHeight: containerSlotOuterSize + header.height
  maxContentHeight: containerSlotOuterSize * maxImbueableSlots + header.height + footer.height
  initialContentHeight: 200

  customButtonContainerData: [
    TibiaIconButton {
      id: contextMenuButton
      sourceUp:   "/images/skin/classic/button-contextmenu-12x12-idle.png"
      sourceDown: "/images/skin/classic/button-contextmenu-12x12-pressed.png"
      tooltipText: qsTrId("imbuementtrackerwidget_configure_tooltip")
      onClicked: widgetController != null ? widgetController.optionsContextMenu() : undefined
    } //TibiaIconButton
  ] //customButtonContainerData

  TibiaScrollView {
    id: scrollView
    anchors.fill: parent

    Flickable {
      interactive: false //prevent flick behavior on touch screens
      boundsBehavior: Flickable.StopAtBounds

      contentHeight: contentLayout.height
      contentWidth: parent.width

      ColumnLayout {
        id: contentLayout
        anchors { left: parent.left; right: parent.right }
        spacing: 0

        Item {
          id: header
          Layout.fillWidth: true
          Layout.preferredHeight: TibiaStyle.containerContentTopMargin
        } //Item

        ListView {
          id: inventoryImbuementListView
          Layout.fillWidth: true
          Layout.leftMargin: TibiaStyle.containerContentLeftMargin
          Layout.preferredHeight: contentHeight

          spacing: TibiaStyle.containerSlotsMargin
          model: widgetController != null ? widgetController.imbuedObjectsModel : null

          interactive: false //prevent flick behavior on touch screens
          boundsBehavior: Flickable.StopAtBounds

          delegate: RowLayout {
            spacing: TibiaStyle.containerSlotsMargin

            ContainerSlot {
              slotID: model.inventoryPosition
              managedContainerTooltipText: model.managedContainerTooltip

              objectAppearanceInstanceTypeId: model.typeID
              objectAppearanceInstanceUpgradeTier: model.upgradeTier
              objectAppearanceInstanceCumulativeCount: model.cumulativeCount
              objectAppearanceInstanceLiquidType: model.liquideType
              objectAppearanceInstanceHookDirection: model.hookDirection
              slotText: model.alternativeSlotString.length > 0 ? model.alternativeSlotString : (model.cumulativeCount > 1 ? model.cumulativeCount : "")

              onClicked: (SlotID, MouseButton, KeyboardModifier) => {
                if (widgetController != null) {
                  widgetController.onObjectClicked(
                    SlotID,
                    MouseButton,
                    KeyboardModifier);
                }
              } //onClicked
            } //ContainerSlot

            ImbuementInfoLayout {
              enabled: model.slotCount >= 1
              opacity: enabled ? 1 : 0

              iconID: model.imbuement1IconID
              name: model.imbuement1Name
              remainingTime: model.imbuement1RemainingTimeString
              visualization: model.imbuement1Visualization
            } //ImbuementInfoLayout

            ImbuementInfoLayout {
              enabled: model.slotCount >= 2
              opacity: enabled ? 1 : 0

              iconID: model.imbuement2IconID
              name: model.imbuement2Name
              remainingTime: model.imbuement2RemainingTimeString
              visualization: model.imbuement2Visualization
            } //ImbuementInfoLayout

            ImbuementInfoLayout {
              enabled: model.slotCount >= 3
              opacity: enabled ? 1 : 0

              iconID: model.imbuement3IconID
              name: model.imbuement3Name
              remainingTime: model.imbuement3RemainingTimeString
              visualization: model.imbuement3Visualization
            } //ImbuementInfoLayout
          } //delegate RowLayout
        } //ListView

        Item {
          id: footer
          Layout.fillWidth: true
          Layout.preferredHeight: TibiaStyle.containerContentBottomMargin
        } //Item
      } //ColumnLayout
    } //Flickable
  } //TibiaScrollView

  Lenshelp {
    anchors.fill: parent
    triggerRect: mapFromItem(widgetRoot, 0, 0, widgetRoot.width, widgetRoot.height)
    caption: qsTrId("imbuementtrackerwidget_lenshelp_caption")
    content: qsTrId("imbuementtrackerwidget_lenshelp")
  } //Lenshelp

} // TibiaSidebarWidget
