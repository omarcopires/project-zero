import QtQuick
import qmlcomponents



TibiaFrame1PixelDown {
  id: root
  property real horizontalItemCount: 4
  property real verticalItemCount: 2.1
  property bool typeNameAsTooltip: false
  property alias model: itemsGridView.model
  property alias count: itemsGridView.count
  property int cacheBufferRows: 0
  property int selectedTypeID: 0
  property int selectedUpgradeTier: 0
  property bool showProficiencyLevel: false

  property QtObject currentHoverSlot

  signal clicked(int typeID, int upgradeTier)
  signal slotEntered()
  signal slotExited()

  implicitWidth: horizontalItemCount * itemsGridView.cellWidth
               + 2 * borderWidth
               + itemsGridView.leftMargin
               + TibiaStyle.scrollBarWidth
  implicitHeight: Math.floor(verticalItemCount * itemsGridView.cellWidth)
                + 2 * borderWidth
                + itemsGridView.topMargin

  Rectangle {
    color: TibiaStyle.tableViewBackgroundColor
    anchors.fill: parent
    anchors.margins: parent.borderWidth
  } //Rectangle

  TibiaScrollView {
    anchors.fill: parent
    anchors.margins: parent.borderWidth

    GridView {
      id: itemsGridView
      topMargin: TibiaStyle.containerSlotsMargin
      bottomMargin: TibiaStyle.containerSlotsMargin
      leftMargin: TibiaStyle.containerSlotsMargin

      cellWidth: TibiaStyle.containerSlotSize + TibiaStyle.containerSlotsMargin
      cellHeight: cellWidth

      interactive: false //prevent flick behavior on touch screens
      boundsBehavior: Flickable.StopAtBounds
      pixelAligned: true
      highlightFollowsCurrentItem: true
      highlightMoveDuration: 0

      cacheBuffer: cellHeight * root.cacheBufferRows

      readonly property var _shouldBeSelectedId: root.selectedTypeID
      on_ShouldBeSelectedIdChanged: { selectedIdChagedTimer.start(); }
      onCountChanged: { selectedIdChagedTimer.start(); }
      Timer{
        id: selectedIdChagedTimer
        interval: 0

        onTriggered:{
          let newCurrentIndex = -1;

          if (itemsGridView.model != null) {
            for (var i=0; i < itemsGridView.count; i++) {
              let idx = itemsGridView.model.index(i, 0);
              let id = itemsGridView.model.data(idx, itemsGridView.model.typeIdEnumValue);

              if (id == itemsGridView._shouldBeSelectedId) {
                newCurrentIndex = i;
                break;
              }
            }
          }

          itemsGridView.currentIndex = newCurrentIndex;
          itemsGridView.currentIndexChanged();
        } //function onTriggered
      } //Timer


      delegate: ContainerSlot {
        id: containerDelegate
        lootvalueImageSourceUnderItem: model.lootvalueImageSourceUnderItem
        lootvalueImageSourceOverItem: model.lootvalueImageSourceOverItem
        objectAppearanceInstanceTypeId: model.typeID
        objectAppearanceInstanceUpgradeTier: model.upgradeTier
        objectAppearanceInstanceCumulativeCount: model.cumulativeCount
        objectAppearanceInstanceLiquidType: model.liquideType
        objectAppearanceInstanceHookDirection: model.hookDirection
        objectAppearanceInstanceDecoItemObjectID: model.decoItemObjectID
        slotText: model.countString
        slotTooltip: root.typeNameAsTooltip ? model.typeName : ""
        showProficiencyLevel: root.showProficiencyLevel
        proficiencyLevel: model.proficiencyLevel
        hasProficiencyMastery: model.hasProficiencyMastery

        showPointingHandCursor: true

        function slotClicked() {
          root.clicked(model.typeID, model.upgradeTier);
          itemsGridView.currentIndex = index;
        } //function slotClicked

        function slotEntered() {
          root.currentHoverSlot = containerDelegate;
          root.slotEntered();
        } //function slotEntered

        function slotExited() {
          if (root.currentHoverSlot === containerDelegate) {
            root.slotExited();
          }
        } //function slotEntered

        Component.onCompleted: {
          clicked.connect(slotClicked);
          entered.connect(slotEntered)
          exited.connect(slotExited)
        } //Component.onCompleted

        Component.onDestruction: {
          slotExited();
        } //Component.onDestruction

        Rectangle {
          anchors.fill: parent
          anchors.margins: -border.width
          color: "transparent"
          border.width: 1
          border.color: "white"

          visible: model.typeID == root.selectedTypeID
               &&  model.upgradeTier == root.selectedUpgradeTier

          onVisibleChanged: {
            if (visible) {
              containerDelegate.slotClicked();
            }
          } //onVisibleChanged
        } //Rectangle
      } //delegate: ContainerSlot
    } // GridView
  } //TibiaScrollView
} //TibiaFrame1PixelDown
