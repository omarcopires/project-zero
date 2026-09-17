import QtQuick
import QtQuick.Layouts

import qmlcomponents



TibiaSidebarWidget {
  id: root
  caption: widgetController != null ? widgetController.caption : qsTrId("container_caption")
  captionStyleType: widgetController != null && widgetController.isInManualSortMode ? "ContainerManualSortMode" : "Caption"
  picSource: "/images/skin/classic/icon-trade.png"
  iconTypeid: widgetController != null ? widgetController.objectID : 0
  iconCumulativeCount: widgetController != null ? widgetController.objectCount : 0
  iconLiquidType: widgetController != null ? widgetController.liquidType : ObjectAppearanceInstance.EMPTY
  iconHookDirection: widgetController != null ? widgetController.hookDirection : ObjectAppearanceInstance.NONE
  iconDecoItemObjectID: widgetController != null ? widgetController.decoItemObjectID : 0
  levelUpButtonVisible: widgetController != null ? widgetController.levelUpButtonVisible : false

  signal slotClicked(int SlotID, int MouseButton, int KeyboardModifiers)
  signal slotEntered(int SlotID)
  signal slotExited(int SlotID)
  signal slotStartDrag(int SlotID, QtObject Source)
  signal slotDragDropped(int SlotID)
  signal slotTargetSelected(int SlotID)

  signal previousPageClicked()
  signal nextPageClicked()
  signal searchButtonClicked()

  property int currentPage: widgetController != null ? widgetController.currentPage : 0
  property int numberOfPages: widgetController != null ? widgetController.numberOfPages : 0
  property int numberOfContainerSlots: widgetController != null ? widgetController.numberOfContainerSlots : 0
  property int numberOfFilledContainerSlots: widgetController != null ? widgetController.numberOfFilledContainerSlots : 0
  property int indexOfFirstVisibleObject: widgetController != null ? widgetController.indexOfFirstVisibleObject : 0
  property var tutorialMarkerIDs: widgetController != null ? widgetController.tutorialMarkerIDs : []
  property bool isUpdatable: widgetController != null ? widgetController.isUpdatable : false
  property bool hasPossiblyMorePages: widgetController != null ? widgetController.hasPossiblyMorePages : false
  property bool searchButtonVisible: widgetController != null ? widgetController.searchButtonVisible : false
  property bool configButtonVisible: widgetController != null ? widgetController.configButtonVisible : false
  property bool isInManualSortMode: widgetController != null ? widgetController.isInManualSortMode : false


  property int containerSlotInnerSize: TibiaStyle.containerSlotSize
  property int containerSlotOuterSize: containerSlotInnerSize + TibiaStyle.containerSlotsMargin

  property int containerFooterHeight: 24
  property int currentContainerFooterHeight: numberOfPages > 0 ? containerFooterHeight : 0

  property bool slotContainsDrag: false

  initialContentHeight: (Math.ceil(numberOfFilledContainerSlots / TibiaStyle.numberOfContainerSlotsPerRow) * containerSlotOuterSize)
                        + currentContainerFooterHeight + TibiaStyle.containerContentTopMargin + TibiaStyle.containerContentBottomMargin
  minContentHeight: containerSlotOuterSize + currentContainerFooterHeight + TibiaStyle.containerContentTopMargin
  maxContentHeight: (Math.ceil(numberOfContainerSlots / TibiaStyle.numberOfContainerSlotsPerRow) * containerSlotOuterSize)
                    + currentContainerFooterHeight + TibiaStyle.containerContentTopMargin + TibiaStyle.containerContentBottomMargin
  maxHeightIsLazilyEnforced: true

  function resetScrollView() {
    containerScrollView.contentItem.contentY = 0;
  } //function resetScrollView()

  customButtonContainerData: [
    TibiaButton {
      id: searchButton
      Layout.preferredWidth: TibiaStyle.widgetControllButtonSize
      Layout.preferredHeight: TibiaStyle.widgetControllButtonSize
      visible: root.searchButtonVisible
      imageSource: "/images/icon-search-tiny.png"
      color: "verydarkgrey"
      tooltipText: qsTrId("container_depot_search_tooltip")
      onClicked: root.searchButtonClicked();
    }, //TibiaIconButton
    TibiaIconButton {
      id: contextMenuButton
      sourceUp:   "/images/skin/classic/button-contextmenu-12x12-idle.png"
      sourceDown: "/images/skin/classic/button-contextmenu-12x12-pressed.png"
      visible: root.configButtonVisible
      onClicked: widgetController !=null ? widgetController.onShowConfigurationMenu() : undefined
      tooltipText: widgetController != null && widgetController.hasViewFilterOptions ? qsTrId("container_filteroptions_tooltip") : ""
    } //TibiaIconButton
  ] //customButtonContainerData

  // This item is a mouse area to prevent drag&drop outside of the container slots
  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton


    Item {
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.top: parent.top
      anchors.bottom: containerFooter.top

      Loader {
        anchors.fill: parent
        z: 999
        Component {
          id: containerHighlightBorderComponent
          Rectangle {
            color: "transparent"
            border.color: isUpdatable ? "white" : "red"
            border.width: 1
          } //Rectangle
        }
        sourceComponent: dropArea.containsDrag || slotContainsDrag ? containerHighlightBorderComponent : undefined
      }

      TibiaObjectDropArea {
        id: dropArea
        anchors.fill: parent
        onDropped: {
          if (slotContainsDrag == false && isUpdatable) {
            root.slotDragDropped(-1);
          }
        } //onDropped

        onEntered: {
          root.slotEntered(-1)
        } //onEntered
        onExited: {
          root.slotExited(-1);
        } //onExited

        TibiaScrollView {
          id: containerScrollView
          anchors.fill: parent

          Flickable {
            id: flickContent

            interactive: false //prevent flick behavior on touch screens
            boundsBehavior: Flickable.StopAtBounds

            contentHeight: containerContent.height
            contentWidth: width

            ColumnLayout {
              id: containerContent
              spacing: 0
              anchors.left: parent.left
              anchors.right: parent.right

              Item { //header
                Layout.fillWidth: true
                Layout.preferredHeight: TibiaStyle.containerContentTopMargin
              } //Item

              GridView {
                id: containerGridView
                property int firstEmptySlot: 0
                Layout.fillWidth: true
                Layout.leftMargin: TibiaStyle.containerContentLeftMargin
                Layout.preferredHeight: contentHeight

                cellWidth: TibiaStyle.containerSlotSize + TibiaStyle.containerSlotsMargin
                cellHeight: cellWidth

                interactive: false //prevent flick behavior on touch screens
                boundsBehavior: Flickable.StopAtBounds
                cacheBuffer: 0 //do not buffer any not displayed elements! the load saved by not rendering hidden objects is the objectiv here.

                model: {
                  widgetController != null ? widgetController.appearanceTypeListModel : null
                }

                onModelChanged: {
                  calculateFirstEmptySlot();
                }

                Connections {
                  target: containerGridView.model
                  function onDataChanged() {
                    containerGridView.calculateFirstEmptySlot();
                  }
                  function onModelReset() {
                    containerGridView.calculateFirstEmptySlot();
                  }
                }

                function calculateFirstEmptySlot() {
                  var newFirstEmptySlot = 0;
                  if (model != null && model.length > 0) {
                    var _helperModel = AbstractItemModelHelper.wrapInHelperProxyModel(model);
                    var count = 0;
                    for (var i = 0; i < _helperModel.rowCount(); i++) {
                      var tempModelData = _helperModel.sourceItemDataByRowIndex(i);
                      if (tempModelData.typeID != 0) {
                        newFirstEmptySlot++;
                      } else {
                        break;
                      }
                    }
                  }
                  firstEmptySlot = newFirstEmptySlot;
                }

                delegate: ContainerSlot {
                  slotID: index + root.indexOfFirstVisibleObject
                  slotText: model.alternativeSlotString.length > 0 ? model.alternativeSlotString : (model.cumulativeCount > 1 ? model.cumulativeCount : "")
                  managedContainerTooltipText: model.managedContainerTooltip ? model.managedContainerTooltip : (model.decoItemObjectID ? qsTrId("container_slot_wrappeditem_marker_tooltip") : "")
                  acceptsDrop: objectAppearanceInstanceTypeId != 0
                  isUpdatable: root.isUpdatable
                  tutorialMarkerID: root.tutorialMarkerIDs.length > 0 && index < root.tutorialMarkerIDs.length ? root.tutorialMarkerIDs[index] : TibiaStyle.noTutorialMarker
                  lootvalueImageSourceUnderItem: model.lootvalueImageSourceUnderItem
                  lootvalueImageSourceOverItem: model.lootvalueImageSourceOverItem
                  objectAppearanceInstanceTypeId: model.typeID
                  objectAppearanceInstanceUpgradeTier: model.upgradeTier
                  objectAppearanceInstanceCumulativeCount: model.cumulativeCount
                  objectAppearanceInstanceLiquidType: model.liquideType
                  objectAppearanceInstanceHookDirection: model.hookDirection
                  objectAppearanceInstanceDecoItemObjectID: model.decoItemObjectID
                  isInManualSortMode: root.isInManualSortMode
                  forceShowDropMarker: isInManualSortMode && (model.typeID == 0 && dropArea.containsDrag && !slotContainsDrag && index == containerGridView.firstEmptySlot) ||
                                       !isInManualSortMode && (dropArea.containsDrag && !slotContainsDrag && index == 0)

                  Component.onCompleted: {
                    clicked.connect(root.slotClicked);
                    entered.connect(root.slotEntered);
                    exited.connect(root.slotExited);
                    startDrag.connect(root.slotStartDrag);
                    dragDropped.connect(root.slotDragDropped);
                    targetSelected.connect(root.slotTargetSelected);
                  } //Component.onCompleted

                  onDragDropped: { }

                  onContainsDragChanged: {
                    root.slotContainsDrag = containsDrag;
                  } //onContainsDragChanged
                } //delegate: ContainerSlot
              } //GridView

              Item { //footer
                Layout.fillWidth: true
                Layout.preferredHeight: TibiaStyle.containerContentBottomMargin
              } //Item
            } //ColumnLayout
          } //Flickable
        }  //TibiaScrollView
      } //TibiaObjectDropArea
    } //Item

    Column {
      id: containerFooter
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.bottom: parent.bottom

      Loader {
        id: containerPagingLoader

        states: [
          State {
            name: "SHOW_FOOTER"
            when: numberOfPages > 0
            PropertyChanges { target: containerPagingLoader; sourceComponent: containerPagingComponent }
            PropertyChanges { target: root; currentContainerFooterHeight: containerFooterHeight }
          } //State
        ] //states

        height: currentContainerFooterHeight
        sourceComponent: undefined
        anchors.left: parent.left
        anchors.right: parent.right
      } //Loader
    } //Column
  } //MouseArea

  Component {
    id: containerPagingComponent
    Item {
      id: containerPaging

      states: [
        State {
          name: "FIRST_PAGE"
          when: currentPage == 1
          PropertyChanges { target: previousPageButton; visible: false }
        }, //State
        State {
          name: "LAST_PAGE"
          when: currentPage >= numberOfPages
          PropertyChanges { target: nextPageButton; visible: false }
        } //State
      ] //states

      TibiaTiledImage {
        anchors.fill: parent
        source: "/images/background.png"

        TibiaHorizontalSeparator{
          //drawn on top of background
          anchors {left: parent.left; top: parent.top; right: parent.right}
        } //TibiaHorizontalSeparator
      } //Image

      TibiaIconButton {
        id: previousPageButton
        sourceUp:   "/images/container-browse-left-up.png"
        sourceDown: "/images/container-browse-left-down.png"

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: 3
        anchors.leftMargin: 3
        visible: currentPage != 1
        Component.onCompleted: {
          clicked.connect(root.previousPageClicked);
        } //Component.onCompleted

      } //TibiaIconButton

      TibiaIconButton {
        id: nextPageButton
        sourceUp:   "/images/container-browse-right-up.png"
        sourceDown: "/images/container-browse-right-down.png"

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: 3
        anchors.topMargin: 3
        visible: currentPage < numberOfPages
        Component.onCompleted: {
          clicked.connect(root.nextPageClicked);
        } //Component.onCompleted

      } //TibiaIconButton

      TibiaText {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        text: qsTrId("container_page_information").arg(currentPage).arg(numberOfPages)
              + (hasPossiblyMorePages ? "+" : "")

        Tooltip {
          anchors.fill: parent
          visible: hasPossiblyMorePages
          text: qsTrId("container_more_pages_tooltip").arg(numberOfPages)
        } //Tooltip
      } //TibiaText
    } //Item
  } // component

  Lenshelp {
    anchors.fill: parent
    triggerRect: mapFromItem(widgetRoot, 0, 0, widgetRoot.width, widgetRoot.height)
    caption: qsTrId("container_lenshelp_caption")
    content: qsTrId("container_lenshelp")
  } //Lenshelp

} // tibia sidebar widget
