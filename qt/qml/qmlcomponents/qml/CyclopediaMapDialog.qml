import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qmlcomponents




Item {
  id: rendererWrapper

  property var controller: null
  property int baseLayer: 7
  property bool isUnderground: baseLayer > 7
  property bool isAboveGround: baseLayer < 7
  property alias mapTileType: minimapRenderer.tileType
  property alias userSelectedMapTileType: minimapRenderer.userSelectedTileType
  property bool showInformationSidebar: true
  property alias showZones: minimapRenderer.showZones
  property alias showExploreOverlay: minimapRenderer.showExploreOverlay
  property alias levelSeparator: minimapRenderer.levelSeparator
  property alias showNPCMarkers: minimapRenderer.showNPCMarkers
  property alias showPassages: minimapRenderer.showPassages
  property alias showHouses: minimapRenderer.showHouses
  property alias markerSymbolsToShow: minimapRenderer.minimapMarkersFilter
  property var selectedItem: controller != null ? controller.selectedItem : null
  property var selectedItemComponent: null
  property string selectedItemCaption: ""
  property string currentTooltip: controller != null ? controller.currentTooltip : ""

  onCurrentTooltipChanged: {
    mapTooltip.hideTooltip();
  }

  Connections {
    id: controllerConnections
    target: null
    function onShowTooltip() {
      mapTooltip.showTooltip();
    } //onShowTooltip
    function onRequestSetScaleFactor(ScaleFactor) {
      minimapRenderer.scaleFactorAnimationBehavior.enabled = false;
      minimapRenderer.targetScaleFactor = ScaleFactor;
      minimapRenderer.scaleFactorAnimationBehavior.enabled = true;
    } //onRequestSetScaleFactor
  } //Connections

  function changeLayer(direction, x, y) {
    var addValue = direction;
    if (direction > 0) {
      addValue = -1;
    } else if (direction < 0) {
      addValue = 1;
    }
    rendererWrapper.baseLayer = Math.min(15, Math.max(0, rendererWrapper.baseLayer + addValue));
    mapTooltip.hideTooltip();
  }

  function changeZoom(direction, x, y) {
    var multiplyValue = 0;
    if (direction > 0) {
      multiplyValue = 2.0;
    } else if (direction < 0) {
      multiplyValue = 0.5;
    }
    if (x == null) {
      x = minimapRenderer.width / 2;
    }
    if (y == null) {
      y = minimapRenderer.height / 2;
    }

    minimapRenderer.camera.referencePoint = Qt.point(x, y);
    minimapRenderer.targetScaleFactor = Math.max(Math.min(minimapRenderer.camera.scaleFactor * multiplyValue, 1.0 / 2.0), 1.0 / 64.0);
    mapTooltip.hideTooltip();
  }

  function moveInDirection(x, y) {
    var offset = Qt.point(x * 10, y * 10);
    minimapRenderer.camera.referencePoint = Qt.point(0,0);
    minimapRenderer.camera.moveDistanceRelativeToReferencePoint(offset);
    mapTooltip.hideTooltip();
  }

  Shortcut {
    sequence: StandardKey.MoveToNextPage
    onActivated: {
      changeLayer(-1);
    }
  }

  Shortcut {
    sequence: StandardKey.MoveToPreviousPage
    onActivated: {
      changeLayer(1);
    }
  }

  Shortcut {
    sequences: [StandardKey.MoveToEndOfLine, "Ctrl+E"]
    onActivated: {
      changeZoom(1);
    }
  }
  Shortcut {
    sequence: StandardKey.MoveToStartOfLine
    onActivated: {
      changeZoom(-1);
    }
  }

  Shortcut {
    sequence: StandardKey.MoveToNextChar
    onActivated: {
      moveInDirection(1, 0);
    }
  }
  Shortcut {
    sequence: StandardKey.MoveToPreviousChar
    onActivated: {
      moveInDirection(-1, 0);
    }
  }
  Shortcut {
    sequence: StandardKey.MoveToNextLine
    onActivated: {
      moveInDirection(0, 1);
    }
  }
  Shortcut {
    sequence: StandardKey.MoveToPreviousLine
    onActivated: {
      moveInDirection(0, -1);
    }
  }


  onSelectedItemChanged: {
    if (selectedItem != null) {
      if (selectedItem.selectionType == TibiaEnums.SelectionTypeSubArea) {
        selectedItemComponent = areaAndSubAreaInfo;
        selectedItemCaption = qsTrId("cyclopedia_map_subarea")
        setScrollingPosition();
      } else if (selectedItem.selectionType == TibiaEnums.SelectionTypeArea) {
        selectedItemComponent = areaInfo;
        selectedItemCaption = qsTrId("cyclopedia_map_area")
        setScrollingPosition();
      } else if (selectedItem.selectionType == TibiaEnums.SelectionTypePassage) {
        selectedItemComponent = passageInfo;
        selectedItemCaption = qsTrId("cyclopedia_map_passage")
        setScrollingPosition();
      } else {
        selectedItemComponent = null;
      }
    } else {
      selectedItemComponent = null;
    }
  }

  function calculateCorrectMapTileTypeDependingOnBaseLayer() {
    if (baseLayer > 7) {
      mapTileType = MinimapRenderer.LocalMinimap;
    } else {
      mapTileType = userSelectedMapTileType;
    }
  }

  onBaseLayerChanged: {
    minimapRenderer.camera.changeLayerWithIsometricProjection(baseLayer);
    calculateCorrectMapTileTypeDependingOnBaseLayer();
  }

  onControllerChanged: {
    if (controller != null) {
      controllerConnections.target = controller;
      controller.setMinimapRendererQuickItem(minimapRenderer);
    }
  } //onControllerChanged

  onUserSelectedMapTileTypeChanged: {
    calculateCorrectMapTileTypeDependingOnBaseLayer();
  } //onUserSelectedMapTileTypeChanged

  function resetMarkerFilters(value) {
    var newArray = rendererWrapper.markerSymbolsToShow.slice(0);
    for (var i = 0; i < newArray.length; i++) {
      newArray[i] = value;
    }
    setNewMinimapMarkerModel(newArray);
    rendererWrapper.showNPCMarkers = value;
    rendererWrapper.showPassages = value;
    rendererWrapper.showHouses = value;
  }

  function setMinimapMarker(index, value) {
    var newArray = rendererWrapper.markerSymbolsToShow.slice(0);
    newArray[index] = value;

    setNewMinimapMarkerModel(newArray);
  }

  function setNewMinimapMarkerModel(array) {
    for (var i = 0; i < TibiaStyle.numberOfMinimapMarkers; i++) {
      if (rendererWrapper.markerSymbolsToShow[i] != array[i]) {
        rendererWrapper.markerSymbolsToShow = array;
        break;
      }
    }
  }

  Timer {
    id: scrollBarPositionTimer
    interval: 1;
    running: false;
    repeat: false
    onTriggered: {
      if (selectionPanel.expanded) {
        var upperPanelsHeight = mapMarkerPanel.height +  navigationPanel.height + 2*informationPanelContent.spacing;
        var totalHeight = upperPanelsHeight + selectionPanel.height;
        var scrollPositionEnd = Math.max(totalHeight - scrollView.height, 0);
        flickableInformation.contentY = (selectionPanel.height > scrollView.height ? upperPanelsHeight : scrollPositionEnd );
      }
    } //onTriggered
  } //Timer


  function setScrollingPosition() {
    scrollBarPositionTimer.restart();
  }

  Component {
    id: creatureOccurrencesComponent
    ColumnLayout {
      id: creatureOccurrencesRoot
      property var creatureOccurrencesModel
      property var subAreaName: creatureOccurrencesModel != null ? creatureOccurrencesModel.subAreaName : ""
      property var showSubAreaName: false
      property var commonCreaturesModel: creatureOccurrencesModel != null ? creatureOccurrencesModel.commonCreatures : null
      property var rareCreaturesModel: creatureOccurrencesModel != null ? creatureOccurrencesModel.rareCreatures : null
      property var dynamicCreaturesModel: creatureOccurrencesModel != null ? creatureOccurrencesModel.dynamicCreatures : null

      Component {
        id: creatureList
        ColumnLayout {
          id: categoryMonsters
          property var creaturesModel: null
          property var categoryString: ""
          property var preferredHeight: categoryText.height + spacing + monstersGrid.height
          TibiaText {
            id: categoryText
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft;
            Layout.fillWidth: true
            text: categoryString
          }
          GridView {
            id: monstersGrid
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft;
            Layout.fillWidth: true
            Layout.preferredHeight: Math.ceil(count / 4) * cellHeight
            cellWidth: 34
            cellHeight: 34
            snapMode: GridView.SnapToRow
            interactive: false
            clip: true
            model: categoryMonsters.creaturesModel
            delegate:

              Item {
                width: 32
                height: 32
                TibiaButton {
                  id: monsterIconButton
                  anchors.fill: parent
  //                imageSourceDisabled:true
                  enabled: !modelData.isUnknown
                  onClicked: {
                    if (controller != null) {
                      controller.onCreatureClicked(modelData.raceID);
                    }
                  }

                  RaceAppearanceInstanceRenderer {
                    anchors.fill: parent
                    anchors.margins: 1
                    raceID: modelData.raceID
                    isUnknown: modelData.isUnknown
                    autofit: true
                  }
                } // TibiaButton
                Tooltip {
                  anchors.fill: parent
                  text: modelData.raceName
                }
              }
          }
        }
      }

      Loader {
        Component {
          id: loaderComponent
          TibiaText {
            text: subAreaName
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
          }
        }
        Layout.fillWidth: true;
        sourceComponent: showSubAreaName ? loaderComponent : null
      }
      Loader {
        sourceComponent: commonCreaturesModel != null ? (commonCreaturesModel.length > 0 ? creatureList : null) : null
        onItemChanged: {
          if (item == null) {
            Layout.preferredHeight = 0;
          } else {
            Layout.fillWidth = true;
            Layout.preferredHeight = Qt.binding(function(){ return item.preferredHeight; });
            item.creaturesModel = Qt.binding(function(){ return commonCreaturesModel; });
            item.categoryString = qsTrId("cyclopedia_map_creature_occurrence_common")
          }
        }
      }

      Loader {
        sourceComponent: rareCreaturesModel != null ? (rareCreaturesModel.length > 0 ? creatureList : null) : null
        onItemChanged: {
          if (item == null) {
            Layout.preferredHeight = 0;
          } else {
            Layout.fillWidth = true;
            Layout.preferredHeight = Qt.binding(function(){ return item.preferredHeight; });
            item.creaturesModel = Qt.binding(function(){ return rareCreaturesModel; });
            item.categoryString = qsTrId("cyclopedia_map_creature_occurrence_rare")
          }
        }
      }

      Loader {
        sourceComponent: dynamicCreaturesModel != null ? (dynamicCreaturesModel.length > 0 ? creatureList : null) : null
        onItemChanged: {
          if (item == null) {
            Layout.preferredHeight = 0;
          } else {
            Layout.fillWidth = true;
            Layout.preferredHeight = Qt.binding(function(){ return item.preferredHeight; });
            item.creaturesModel = Qt.binding(function(){ return dynamicCreaturesModel; });
            item.categoryString = qsTrId("cyclopedia_map_creature_occurrence_dynamic")
          }
        }
      }
    }
  }

  RowLayout {

    anchors { left: parent.left;
              right: parent.right;
              top: parent.top;
              bottom: parent.bottom; bottomMargin: TibiaStyle.marginRelated;}

    TibiaFrame2PixelUpFilled {
      id: informationPanel
      Layout.alignment: Qt.AlignTop | Qt.AlignLeft
      Layout.preferredWidth: 170
      Layout.fillHeight: true
      visible: rendererWrapper.showInformationSidebar
      TibiaFrame1PixelDown {
        id: informationPanelInnerBorder
        anchors.fill: parent
        anchors.margins: 5
        anchors.topMargin: parent.topMarginToContent

        TibiaScrollView {
          id: scrollView
          anchors.fill: parent
          anchors.margins: parent.borderWidth

          Flickable {
            id: flickableInformation

            contentHeight: informationPanelContent.height
            interactive: false //prevent flick behavior on touch screens
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
              id: informationPanelContent
              anchors.left: parent.left
              anchors.right: parent.right
              spacing: TibiaStyle.marginRelated

              TibiaPanelWithCaption {
                id: mapMarkerPanel
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                Layout.fillWidth: true
                visible: rendererWrapper.showInformationSidebar
                caption: qsTrId("cyclopedia_map_information_panel_display_caption")
                shouldBeExpanded: controller != null && controller.showMapMarkerPanel
                onExpandedChanged: {
                  if (controller != null) {
                    controller.showMapMarkerPanel = expanded;
                  }
                } //onExpandedChanged

                contentDelegate: ColumnLayout {
                  TibiaText {
                    Layout.alignment: Qt.AlignCenter
                    text: qsTrId("cyclopedia_map_information_panel_map_markers_caption")
                  } //TibiaText

                  TibiaFrame1PixelDown {
                    Layout.fillWidth: true
                    Layout.preferredHeight: mapMarkersContent.height + TibiaStyle.marginRelated * 2

                    ColumnLayout {
                      id: mapMarkersContent
                      anchors.left: parent.left
                      anchors.right: parent.right
                      anchors.top: parent.top
                      anchors.margins: TibiaStyle.marginRelated

                      RowLayout {
                        spacing: 0
                        Layout.fillWidth: true

                        GridView {
                          id: minimapMarkersGridView

                          property var markerSymbolsToShow: rendererWrapper.markerSymbolsToShow
                          onMarkerSymbolsToShowChanged: {
                            // needs this workaround because otherwise the model wont work
                            model = markerSymbolsToShow.slice(0);
                          }

                          Layout.preferredHeight: 4 * cellWidth - TibiaStyle.marginRelated
                          Layout.fillWidth: true
                          cellWidth: 16 + TibiaStyle.marginRelated
                          cellHeight: cellWidth
                          flow: GridView.FlowLeftToRight
                          interactive: false //prevent flick behavior on touch screens
                          boundsBehavior: Flickable.StopAtBounds


                          model: markerSymbolsToShow
                          delegate: TibiaIconSelectionButton {
                            required property int index
                            width: 16
                            height: 16

                            iconPath: "image://minimap-markers/" + index
                            checked: rendererWrapper.markerSymbolsToShow[index]

                            onCheckedChanged: {
                              rendererWrapper.setMinimapMarker(index, checked);
                            } //onCheckedChanged
                          } //delegate: TibiaIconSelectionButton

                          Tooltip {
                            anchors.fill: parent
                            text: qsTrId("cyclopedia_map_information_panel_map_marker_tooltip")
                          } //Tooltip
                        } //GridView

                        ColumnLayout {
                          Layout.alignment: Qt.AlignTop
                          spacing: TibiaStyle.marginRelated

                          TibiaIconSelectionButton {
                            property var checkedValue: minimapRenderer.showNPCMarkers
                            onCheckedValueChanged: {
                              checked = checkedValue;
                            } //TibiaIconSelectionButton
                            iconPath: "/images/icon-map-npc.png"
                            iconOffset: Qt.point(10,6)
                            width: 16
                            height: 16
                            checked: checkedValue
                            onCheckedChanged: {
                              minimapRenderer.showNPCMarkers = checked;
                            } //onCheckedChanged
                            Tooltip {
                              anchors.fill: parent
                              text: qsTrId("cyclopedia_map_information_panel_npc_marker_tooltip")
                            } //Tooltip
                          } //TibiaIconSelectionButton

                          TibiaIconSelectionButton {
                            property var checkedValue: minimapRenderer.showPassages
                            onCheckedValueChanged: {
                              checked = checkedValue;
                            } //onCheckedValueChanged
                            iconPath: "/images/icon-map-passage-idle.png"
                            iconOffset: Qt.point(0,0)
                            width: 16
                            height: 16
                            checked: rendererWrapper.showPassages
                            onCheckedChanged: {
                              minimapRenderer.showPassages = checked;
                            } //onCheckedChanged
                            Tooltip {
                              anchors.fill: parent
                              text: qsTrId("cyclopedia_map_information_panel_passage_marker_tooltip")
                            } //Tooltip
                          } //TibiaIconSelectionButton
                          TibiaIconSelectionButton {
                            property var checkedValue: minimapRenderer.showHouses
                            onCheckedValueChanged: {
                              checked = checkedValue;
                            } //onCheckedValueChanged
                            iconPath: "/images/icon-map-house.png"
                            iconOffset: Qt.point(0,0)
                            width: 16
                            height: 16
                            checked: rendererWrapper.showHouses
                            onCheckedChanged: {
                              minimapRenderer.showHouses = checked;
                            } //onCheckedChanged
                            Tooltip {
                              anchors.fill: parent
                              text: qsTrId("cyclopedia_map_information_panel_house_marker_tooltip")
                            } //Tooltip
                          } //TibiaIconSelectionButton
                        } //ColumnLayout
                      } //RowLayout

                      TibiaCheckBox {
                        text: qsTrId("cyclopedia_map_information_panel_show_all")
                        shouldBeChecked: {
                          var allMinimapMarkers = true;
                          for (var i = 0; i < TibiaStyle.numberOfMinimapMarkers; i++) {
                            if (!rendererWrapper.markerSymbolsToShow[i]) {
                              allMinimapMarkers = false;
                              break;
                            }
                          }

                          return    minimapRenderer.showNPCMarkers
                                 && minimapRenderer.showPassages
                                 && minimapRenderer.showHouses
                                 && allMinimapMarkers;
                        }

                        onClicked: {
                          if (checked) {
                            rendererWrapper.resetMarkerFilters(true);
                          } else {
                            rendererWrapper.resetMarkerFilters(false);
                          }
                        } //onClicked
                      } //TibiaCheckbox
                    } //ColumnLayout
                  } //TibiaFrame1PixelDown
                  TibiaText {
                    Layout.alignment: Qt.AlignCenter
                    text: qsTrId("cyclopedia_map_information_panel_views_caption")
                  } //TibiaText
                  TibiaFrame1PixelDown {
                    Layout.fillWidth: true
                    Layout.preferredHeight: viewContent.height + TibiaStyle.marginRelated * 2
                    ColumnLayout {
                      id: viewContent
                      anchors.left: parent.left
                      anchors.right: parent.right
                      anchors.top: parent.top
                      anchors.topMargin: TibiaStyle.marginRelated
                      anchors.leftMargin: TibiaStyle.marginRelated
                      anchors.rightMargin: TibiaStyle.marginRelated
                      ButtonGroup { id: mapTileTypeExclusiveGroup }
                      TibiaRadioButton {
                        text: qsTrId("cyclopedia_map_information_panel_surface_view")
                        enabled: !isUnderground
                        ButtonGroup.group: mapTileTypeExclusiveGroup
                        Component.onCompleted: {
                          checked = (rendererWrapper.userSelectedMapTileType == MinimapRenderer.Satellite);
                        }
                        onCheckedChanged: {
                          if (checked) {
                            rendererWrapper.userSelectedMapTileType = MinimapRenderer.Satellite;
                          }
                        }
                      }
                      TibiaRadioButton {
                        text: qsTrId("cyclopedia_map_information_panel_map_view")
                        enabled: !isUnderground
                        ButtonGroup.group: mapTileTypeExclusiveGroup
                        Component.onCompleted: {
                          checked = (rendererWrapper.userSelectedMapTileType == MinimapRenderer.Minimap);
                        }
                        onCheckedChanged: {
                          if (checked) {
                            rendererWrapper.userSelectedMapTileType = MinimapRenderer.Minimap;
                          }
                        }
                      }
                      TibiaText {
                        text: qsTrId("cyclopedia_map_information_panel_level_separator")
                        enabled: rendererWrapper.isAboveGround
                      }
                      TibiaSlider {
                        id: levelSeparatorSlider
                        Layout.fillWidth: true
                        enabled: rendererWrapper.isAboveGround
                        minimumValue: 0
                        maximumValue: 100
                        stepSize: 1
                        value: rendererWrapper.levelSeparator
                        onValueChanged: {
                          rendererWrapper.levelSeparator = value;
                        } //onValueChanged
                      } //TibiaSlider
                    }
                  }
                }
              }

              TibiaPanelWithCaption {
                id: navigationPanel
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                Layout.fillWidth: true
                visible: rendererWrapper.showInformationSidebar
                caption: qsTrId("cyclopedia_map_navigation_panel_caption")
                shouldBeExpanded: controller != null && controller.showNavigationPanel
                onExpandedChanged: {
                  if (controller != null) {
                    controller.showNavigationPanel = expanded;
                  }
                } //onExpandedChanged

                contentDelegate: ColumnLayout {
                  spacing: TibiaStyle.marginRelated

                  TibiaText {
                    visible: controller != null && controller.currentPlayerArea != 0
                    text: qsTrId("player_area_headline_text")
                    Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter

                    TibiaGuiHelp {
                      anchors.left: parent.left
                      anchors.top: parent.top
                      text: qsTrId("cyclopedia_map_exploration_reward_info_tooltip").arg(controller.explorationRewardAmountGoStrength)
                    }
                  } // TibiaText

                  TibiaText {
                    visible: controller != null && controller.currentPlayerArea != 0
                    text: controller != null ? controller.currentPlayerAreaName : ""
                    Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                  } // TibiaText

                  RowLayout {
                    Layout.alignment: Qt.AlignTop | Qt.AlignCenter
                    spacing: TibiaStyle.marginRelated

                    ColumnLayout {
                      Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                      spacing: TibiaStyle.marginRelated

                      TibiaMinimapRose {
                        id: minimapRose
                        timeOfDayNormalized: controller != null ? controller.timeOfDayNormalized : 0.0
                        onMouseButtonClicked: (offsetX, offsetY) => {
                          if (offsetX == 0 && offsetY == 0) {
                            if (controller != null) {
                              controller.centerToPlayer();
                            }
                          } else {
                            var offset = Qt.point(offsetX * 10, offsetY * 10);
                            minimapRenderer.camera.referencePoint = Qt.point(0,0);
                            minimapRenderer.camera.moveDistanceRelativeToReferencePoint(offset);
                          }
                        } //onMouseButtonClicked
                      } //TibiaMinimapRose

                      RowLayout {
                        id: buttonsWrapper
                        spacing: 0
                        Layout.maximumWidth: minimapRose.width

                        TibiaIconButton {
                          id: automap_button_zoomout
                          sourceUp: "/images/automap-button-zoomout-up.png"
                          sourceDown: "/images/automap-button-zoomout-down.png"
                          tooltipText: qsTrId("cyclopedia_map_zoom_out_tooltip")

                          onClicked: {
                            changeZoom(-1);
                          } //onClicked
                        } // TibiaIconButton

                        Item { Layout.fillWidth: true }

                        TibiaIconButton {
                          id: automap_button_zoomin
                          sourceUp: "/images/automap-button-zoomin-up.png"
                          sourceDown: "/images/automap-button-zoomin-down.png"
                          tooltipText: qsTrId("cyclopedia_map_zoom_in_tooltip")

                          onClicked: {
                            changeZoom(1);
                          } //onClicked
                        } // TibiaIconButton
                      } // RowLayout
                    } // ColumnLayout

                    TibiaMapLayersSlider {
                      property int baseLayer: rendererWrapper.baseLayer
                      onBaseLayerChanged: {
                        currentLayer = baseLayer;
                      } //onBaseLayerChanged

                      Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                      id: mapLayersSlider

                      currentLayer: baseLayer
                      onCurrentLayerChanged: {
                        rendererWrapper.baseLayer = currentLayer;
                      } //onCurrentLayerChanged
                      tooltip: qsTrId("cyclopedia_map_change_layer_tooltip")
                    } //TibiaMapLayersSlider
                  } //RowLayout
                } //contentDelegate: ColumnLayout
              } //TibiaPanelWithCaption

              TibiaPanelWithCaption {
                id: selectionPanel

                Component {
                  id: areaAndSubAreaInfo

                  ColumnLayout {
                    Component {
                      id: subAreaExplorationProgressBar

                      TibiaProgressBar {
                        fillPercentage: {
                          if (selectedItem != null
                            && (selectedItem.unlocked || selectedItem.unlockable)
                            && selectedItem.viewpointsCount > 0) {
                            return selectedItem.viewpointsFound / selectedItem.viewpointsCount;
                          }
                          return 0;
                        }

                        frameSource: "/images/1pixel-down-frame.png"
                        backgroundSource: "/images/backdrop-dark-grey.png"
                        fillSource: "/images/progressbar-orange-large.png"

                        frameBorder { left: 1; right: 1; top:1; bottom: 1}
                        fillOffset { left: 1; right: 1; top:1; bottom: 1}

                        TibiaText {
                          anchors.centerIn: parent
                          text: selectedItem != null ? (selectedItem.unlocked
                                  ? qsTrId("cyclopedia_map_subarea_complete_caption")
                                  : qsTrId("count_slash_total").arg(selectedItem.viewpointsFound).arg(selectedItem.viewpointsCount)) : ""
                        } //TibiaText
                      }
                    }
                    Component {
                      id: subAreaExplorationResetViewpoints

                      TibiaButton {
                        text: qsTrId("cyclopedia_map_reset_points_of_interest")
                        enabled: (selectedItem != null && selectedItem.unlockable)
                        onClicked: {
                          if (controller != null) {
                            controller.resetSubAreaViewPoints(selectedItem.subAreaID);
                          }
                        }
                      }
                    }

                    Component {
                      id: subareaNotExplorableInfo

                      TibiaText {
                        Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap
                        text: qsTrId("cyclopedia_map_subarea_not_explorable")
                      } // TibiaText
                    }

                    TibiaText {
                      Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
                      Layout.fillWidth: true
                      elide: Text.ElideRight
                      horizontalAlignment: Text.AlignHCenter
                      text: selectedItem != null ? (selectedItem.areaName != null ? selectedItem.areaName : "") : ""
                    }

                    TibiaProgressBar {
                      id: areaExplorationProgressBar
                      Layout.preferredHeight: TibiaStyle.progressBarLargeHeight
                      Layout.fillWidth: true
                      fillPercentage: selectedItem != null ? selectedItem.percentExplored : 0
                      visible: selectedItem != null ? (selectedItem.percentExplored <= 1 ? true : false ) : false // a higher number than 1 encodes, that the area is not explorable

                      frameSource: "/images/1pixel-down-frame.png"
                      backgroundSource: "/images/backdrop-dark-grey.png"
                      fillSource: "/images/progressbar-orange-large.png"

                      frameBorder { left: 1; right: 1; top:1; bottom: 1}
                      fillOffset { left: 1; right: 1; top:1; bottom: 1}

                      TibiaText {
                        anchors.centerIn: parent
                        text: selectedItem != null ? qsTrId("cyclopedia_map_area_progress_caption").arg(parseInt(selectedItem.percentExplored * 100)) : ""
                      } //TibiaText
                    } //TibiaProgressBar


                    TibiaText {
                      Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
                      Layout.fillWidth: true
                      horizontalAlignment: Text.AlignHCenter
                      wrapMode: Text.Wrap
                      text: qsTrId("area_donation_text")
                      visible: selectedItem!= null? !selectedItem.rejectDonations : false
                      Tooltip {
                        anchors.fill: parent
                        useRichText: true
                        text: selectedItem != null? selectedItem.areaDonationsTooltip : ""
                      } // Tooltip
                    } // TibiaText

                    TibiaProgressBar {
                      id: subareaValueProgressBar
                      Layout.preferredHeight: TibiaStyle.progressBarLargeHeight
                      Layout.fillWidth: true
                      fillPercentage: selectedItem != null ? (selectedItem.percentUnlockedImprovedRespawn) : 0
                      visible: selectedItem!= null? !selectedItem.rejectDonations : false

                      frameSource: "/images/1pixel-down-frame.png"
                      backgroundSource: "/images/backdrop-dark-grey.png"
                      fillSource: "/images/progressbar-orange-large.png"

                      frameBorder { left: 1; right: 1; top:1; bottom: 1}
                      fillOffset { left: 1; right: 1; top:1; bottom: 1}

                      RowLayout {
                        anchors.centerIn: parent
                        TibiaText {
                          text: selectedItem != null ? selectedItem.areaDonationString : "0"
                        } //TibiaText
                        Image {
                          source: "/images/icon-goldcoin.png"
                        }
                      } // RowLayout

                      Tooltip {
                        anchors.fill: parent
                        text: selectedItem != null? qsTrId("donation_progress_tooltip").arg(selectedItem.areaDonationString).arg(selectedItem.areaDonationThreshold).arg(selectedItem.areaDonationThreshold) : ""

                      } // Tooltip
                    } //TibiaProgressBar

                    RowLayout {
                      Layout.fillWidth: true
                      visible: selectedItem!= null? !selectedItem.rejectDonations : false
                      TibiaTextField {
                        id: donationField
                        placeholderText: qsTrId("donation_textbox_text")
                        Layout.fillWidth: true
                        validator: RegularExpressionValidator { regularExpression: /[0-9]{0,9}/; }
                        maximumLength: 9
                        onTextChanged: {
                         ///
                        } // onTextChanged
                        Image {
                          source: "/images/icon-goldcoin.png"
                          anchors.right: parent.right
                          anchors.verticalCenter: parent.verticalCenter
                          anchors.rightMargin: TibiaStyle.marginNarrow
                        }
                      } // TibiaTextField
                      TibiaButton {
                        text: qsTrId("donation_button_text")
                        Layout.preferredWidth: 50
                        Layout.fillWidth: true
                        enabled: (donationField.text.length > 0) && (storeAndResourceBalanceHelper.totalGoldBalance >= parseInt(donationField.text))
                        onClicked: {
                          if (controller != null && parseInt(donationField.text) > 0) {
                            controller.donateMoneyForArea(selectedItem.areaID, parseInt(donationField.text));
                            donationField.text = "";
                          }
                        } // onClicked
                      } // TibiaButton
                    } // RowLayout


                    TibiaText {
                      Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
                      Layout.fillWidth: true
                      elide: Text.ElideRight
                      horizontalAlignment: Text.AlignHCenter
                      text: selectedItem != null ? (selectedItem.subAreaName != null ? selectedItem.subAreaName : "") : ""
                    }
                    Loader {
                      sourceComponent: {
                        if (selectedItem == null) return null;

                        if (!selectedItem.unlockable && !selectedItem.unlocked)
                          return subareaNotExplorableInfo;

                        if (!selectedItem.viewpointInfoDelayed || selectedItem.unlocked)
                          return subAreaExplorationProgressBar;

                        return null;
                      }
                      Layout.fillWidth: true
                      onItemChanged: {
                        if (item == null) {
                          Layout.preferredHeight = 0;
                        } else {
                          Layout.preferredHeight = TibiaStyle.progressBarLargeHeight;
                        }
                      }
                    }

                    Loader {
                      sourceComponent: {
                        if (selectedItem == null
                          || selectedItem.unlocked
                          || !selectedItem.unlockable
                          || selectedItem.subAreaID != controller.currentPlayerSubAreaID
                          || selectedItem.subAreaID != controller.currentExploringSubAreaID) {
                          return null;
                        }
                        return subAreaExplorationResetViewpoints
                      }
                      Layout.fillWidth: true
                      onItemChanged: {
                        if (item == null) {
                          Layout.preferredHeight = 0;
                        } else {
                          Layout.preferredHeight = TibiaStyle.progressBarLargeHeight;
                        }
                      }

                    } // Loader

                    Loader {
                      sourceComponent: creatureOccurrencesComponent
                      Layout.fillWidth: true
                      onLoaded: {
                        item.creatureOccurrencesModel = Qt.binding(function(){ return (selectedItem != null ? selectedItem.creatureOccurrences : null); });
                        item.showSubAreaName = false;
                      }
                    }
                  }
                }

                Component {
                  id: areaInfo
                  ColumnLayout {
                    TibiaText {
                      Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
                      text: selectedItem != null ? (selectedItem.areaName != null ? selectedItem.areaName : "") : ""
                    }
                    TibiaProgressBar {
                      id: areaExplorationProgressBar
                      Layout.preferredHeight: TibiaStyle.progressBarLargeHeight
                      Layout.fillWidth: true
                      fillPercentage: selectedItem != null ? selectedItem.percentExplored : 0
                      visible: selectedItem != null ? (selectedItem.percentExplored <= 1 ? true : false ) : false // a higher number than 1 encodes, that the area is not explorable

                      frameSource: "/images/1pixel-down-frame.png"
                      backgroundSource: "/images/backdrop-dark-grey.png"
                      fillSource: "/images/progressbar-orange-large.png"

                      frameBorder { left: 1; right: 1; top:1; bottom: 1}
                      fillOffset { left: 1; right: 1; top:1; bottom: 1}

                      TibiaText {
                        anchors.centerIn: parent
                        text: selectedItem != null ? qsTrId("cyclopedia_map_area_progress_caption").arg(parseInt(selectedItem.percentExplored * 100)) : ""
                      } //TibiaText
                    } //TibiaProgressBar


                    TibiaText {
                      Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
                      Layout.fillWidth: true
                      horizontalAlignment: Text.AlignHCenter
                      wrapMode: Text.Wrap
                      text: qsTrId("area_donation_text")
                      visible: selectedItem!= null? !selectedItem.rejectDonations : false
                      Tooltip {
                        anchors.fill: parent
                        useRichText: true
                        text: selectedItem != null? selectedItem.areaDonationsTooltip : ""
                      } // Tooltip
                    } // TibiaText

                    TibiaProgressBar {
                      id: areaValueProgressBar
                      Layout.preferredHeight: TibiaStyle.progressBarLargeHeight
                      Layout.fillWidth: true
                      fillPercentage: selectedItem != null ? (selectedItem.percentUnlockedImprovedRespawn) : 0
                      visible: selectedItem!= null? !selectedItem.rejectDonations : false

                      frameSource: "/images/1pixel-down-frame.png"
                      backgroundSource: "/images/backdrop-dark-grey.png"
                      fillSource: "/images/progressbar-orange-large.png"

                      frameBorder { left: 1; right: 1; top:1; bottom: 1}
                      fillOffset { left: 1; right: 1; top:1; bottom: 1}

                      RowLayout {
                        anchors.centerIn: parent
                        TibiaText {
                          text: selectedItem != null ? selectedItem.areaDonationString : "0"
                        } //TibiaText
                        Image {
                          source: "/images/icon-goldcoin.png"
                        }
                      } // RowLayout

                      Tooltip {
                        anchors.fill: parent
                        text: selectedItem != null? qsTrId("donation_progress_tooltip").arg(selectedItem.areaDonationString).arg(selectedItem.areaDonationThreshold).arg(selectedItem.areaDonationThreshold) : ""

                      } // Tooltip

                    } //TibiaProgressBar

                    RowLayout {
                      Layout.fillWidth: true
                      visible: selectedItem!= null? !selectedItem.rejectDonations : false
                      TibiaTextField {
                        id: donationFieldArea
                        placeholderText: qsTrId("donation_textbox_text")
                        Layout.fillWidth: true
                        validator: RegularExpressionValidator { regularExpression: /[0-9]{0,9}/; }
                        maximumLength: 9
                        onTextChanged: {
                        } // onTextChanged
                        Image {
                          source: "/images/icon-goldcoin.png"
                          anchors.right: parent.right
                          anchors.verticalCenter: parent.verticalCenter
                          anchors.rightMargin: TibiaStyle.marginNarrow
                        }
                      } // TibiaTextField
                      TibiaButton {
                        text: qsTrId("donation_button_text")
                        Layout.preferredWidth: 50
                        Layout.fillWidth: true
                        enabled: (donationFieldArea.text.length > 0) && (storeAndResourceBalanceHelper.totalGoldBalance >= parseInt(donationFieldArea.text))
                        onClicked: {
                          if (controller != null && parseInt(donationFieldArea.text) > 0) {
                            controller.donateMoneyForArea(selectedItem.areaID, parseInt(donationFieldArea.text));
                            donationFieldArea.text = "";
                          }
                        } // onClicked
                      } // TibiaButton
                    } // RowLayout

                  }
                }

                Component {
                  id: passageInfo
                  ColumnLayout {
                    Repeater {
                      model: selectedItem != null ? selectedItem.reachableCreatureOccurrences : null
                      delegate: Loader {
                        Layout.fillWidth: true
                        sourceComponent: creatureOccurrencesComponent
                        onItemChanged: {
                          if (item != 0) {
                            item.creatureOccurrencesModel = modelData;
                            item.showSubAreaName = true;
                          }
                        }
                      }
                    }
                  }
                }


                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                Layout.fillWidth: true
                visible: selectedItem != null
                caption: selectedItemCaption
                contentDelegate: selectedItemComponent

                shouldBeExpanded: controller != null && controller.showAreaAndSubAreaInfoPanel
                onExpandButtonClicked: {
                  if (expanded) {
                    rendererWrapper.setScrollingPosition();
                  }
                  if (controller != null) {
                    controller.showAreaAndSubAreaInfoPanel = expanded;
                  }
                } //onExpandButtonClicked
              } // TibiaPanelWithCaption
            }
          }
        } // TibiaScrollView
      }
    }
    TibiaFrame1PixelDown {
      id: topButtonBar
      Layout.alignment: Qt.AlignTop | Qt.AlignLeft
      Layout.fillWidth: true
      Layout.fillHeight: true

      property int margin: 1
      Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        color: "black"

        MinimapRenderer {
          id: minimapRenderer
          anchors.fill: parent

          property var targetScaleFactor: 1.0 / 64.0;
          property double tempScaleFactor: targetScaleFactor
          property var topLeftWorldMapCoordinate: Qt.point(996 * 32, 968 * 32)
          property var cameraPositionCenter: Qt.point(32369 * 32, 32215 * 32)
          property alias scaleFactorAnimationBehavior: scaleFactorAnimation

          Connections {
            id: cameraConnections
            target: null
            function onCameraViewportChanged() {
              var currentCoordinate = minimapRenderer.camera.topLeftSubfieldCoordinate;
              if (rendererWrapper.baseLayer != currentCoordinate.z) {
                rendererWrapper.baseLayer = currentCoordinate.z;
              }
            }
          }


          Behavior on tempScaleFactor {
            id: scaleFactorAnimation
            enabled: false
            PropertyAnimation {duration: 250}
          }

          onTempScaleFactorChanged: {
            minimapRenderer.camera.scaleFactor = tempScaleFactor;
          }

          clip: true
          showExploreOverlay: true
          showZones: true

          Component.onCompleted: {
            minimapRenderer.camera.scaleFactor = 1.0 / 16.0;
            minimapRenderer.targetScaleFactor = minimapRenderer.camera.scaleFactor;
            scaleFactorAnimation.enabled = true;
            cameraConnections.target = minimapRenderer.camera;
          }

          function updateHoverCoordinate(x, y)
          {
            if (controller != null) {
              controller.hoverAtPixelCoordinate(x, y);
            }
          }

          function updateClickCoordinate(x, y, button, modifiers)
          {
            if (controller != null) {
              controller.onClickAtPixelCoordinate(x, y, button, modifiers);
            }
          }

          MouseArea {
            property var clickCoordinate: null
            property var mapMoved: false
            anchors.fill: parent
            hoverEnabled: true
            propagateComposedEvents: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onExited: {
              if (controller != null) {
                controller.onMouseExited();
              }
            }
            onPressed: (mouse) => {
              clickCoordinate = Qt.point(mouse.x, mouse.y);
              mapMoved = false;
              minimapRenderer.camera.referencePoint = clickCoordinate;
              var worldMapCoordinate = minimapRenderer.camera.coordinateAtPoint(clickCoordinate);
              minimapRenderer.updateHoverCoordinate(mouse.x, mouse.y);
            }
            onReleased: (mouse) => {
              clickCoordinate = null;
              if (mapMoved == false) {
                minimapRenderer.updateClickCoordinate(mouse.x, mouse.y, mouse.button, mouse.modifiers);
              } else {
                minimapRenderer.updateHoverCoordinate(mouse.x, mouse.y);
              }
            }
            onPositionChanged: (mouse) => {
              if (clickCoordinate !== null) {
                var mouseDistance =  Qt.point((clickCoordinate.x - mouse.x), (clickCoordinate.y - mouse.y));
                if (mapMoved == true || Math.abs(mouseDistance.x) > 3 || Math.abs(mouseDistance.y) > 3) {
                  minimapRenderer.camera.moveDistanceRelativeToReferencePoint(mouseDistance);
                  mapMoved = true;
                }
              }
              minimapRenderer.updateHoverCoordinate(mouse.x, mouse.y);
              mouse.accepted = false;
            }
            onWheel: (wheel) => {
              if (wheel.modifiers & Qt.ShiftModifier) {
                changeLayer(wheel.angleDelta.y, wheel.x, wheel.y);
              } else {
                changeZoom(wheel.angleDelta.y, wheel.x, wheel.y);
              }
              minimapRenderer.updateHoverCoordinate(wheel.x, wheel.y);
            }
            Tooltip {
              id: mapTooltip
              anchors.fill: parent
              autoShow: false
              text: rendererWrapper.currentTooltip
            }
          }
        }
      } // Rectangle
    }
  }
} // Item
