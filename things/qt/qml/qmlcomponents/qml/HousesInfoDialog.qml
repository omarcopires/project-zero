import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qmlcomponents


Item {
  id: root
  property var controller: null
  property bool needsTabNavigation: false

  readonly property var currentModel: housesListView.currentItem != null && housesListView.currentItem.modelData != null ? housesListView.currentItem.modelData : null
  property var activeActionType: TibiaEnums.HouseActionNone

  property alias currentLayer: mapLayersSlider.currentLayer

  property int minimumHouseLayer : controller != null ? controller.minimumHouseLayer : 0
  property int maximumHouseLayer : controller != null ? controller.maximumHouseLayer : 0

  readonly property var _currentHouseId: controller != null ? controller.currentHouseId : 0
  readonly property var _houseValid: _currentHouseId != 0;

  readonly property var lastServerSave: controller != null ? controller.lastServerSave : new Date()
  readonly property var in30DaysDate: {
    if (controller != null) {
      return controller.in30DaysServerSave;
    } else {
      var date = new Date();
      date.setDate(date.getDate() + 30);
      return date;
    }
  } //readonly property var in30DaysDate


  property var initialFocusItem: housesListView
  KeyNavigation.tab: housesListView
  KeyNavigation.backtab: housesListView

  onControllerChanged: {
    if (controller != null) {
      controller.setHouseWorldMapQuickItem(houseView);
      controller.setHouseCameraViewport(cameraViewport);
    }
  } //onControllerChanged

  Connections {
    target: root.controller

    function onHouseActionConfirmed() {
      root.activeActionType = TibiaEnums.HouseActionNone;
    } //function onHouseActionConfirmed()
  } // Connections

  onActiveActionTypeChanged: {
    root.needsTabNavigation = false;
    if (root.activeActionType == TibiaEnums.HouseActionNone) {
      housesListView.forceActiveFocus();
    }
  } //onActiveActionTypeChanged

  onCurrentModelChanged: {
    root.activeActionType = TibiaEnums.HouseActionNone;
  } //onCurrentModelChanged

  onCurrentLayerChanged: {
    if (controller) {
      cameraViewport.translateToLayer(currentLayer);
    }
  } //onCurrentLayerChanged

  function getHouseActionName(HouseAction)
  {
    if (HouseAction == TibiaEnums.HouseActionBid) {
      return qsTrId("houses_action_name_bid");
    } else if (HouseAction == TibiaEnums.HouseActionMoveOut) {
      return qsTrId("houses_action_name_move_out");
    } else if (HouseAction == TibiaEnums.HouseActionCancelMoveOut) {
      return qsTrId("houses_action_name_cancel_move_out");
    } else if (HouseAction == TibiaEnums.HouseActionTransfer) {
      return qsTrId("houses_action_name_transfer");
    } else if (HouseAction == TibiaEnums.HouseActionCancelTransfer) {
      return qsTrId("houses_action_name_cancel_transfer");
    } else if (HouseAction == TibiaEnums.HouseActionAcceptTransfer) {
      return qsTrId("houses_action_name_accept_transfer");
    } else if (HouseAction == TibiaEnums.HouseActionRejectTransfer) {
      return qsTrId("houses_action_name_reject_transfer");
    }
    return qsTrId("dummy_unknown");
  } //function getHouseActionName()

  ColumnLayout {
    anchors.fill: parent
    anchors.bottomMargin: TibiaStyle.marginRelated;
    spacing: TibiaStyle.marginRelated

    TibiaFrame2PixelUpFilled {
      Layout.fillWidth: true
      Layout.preferredHeight: filterLayout.height + 2 * marginsToContent

      ColumnLayout {
        id: filterLayout
        anchors { left: parent.left; top: parent.top; right: parent.right }
        anchors.margins: parent.marginsToContent

        spacing: TibiaStyle.marginRelated

        RowLayout {
          Layout.fillWidth: true
          spacing: TibiaStyle.marginRelated

          TibiaComboBox {
            id: townFilterComboBox
            Layout.fillWidth: true
            model: controller != null ? controller.townFilterModel : null

            shouldBeCurrentIndex: controller != null ? controller.townFilterCurrentIndex : 0
            onCurrentTextChanged: {
              if (controller != null && model != null && !controller.disableQmlSelect) {
                controller.setTownFilter(currentText);
              }
            } //onCurrentTextChanged
          } //TibiaComboBox

          TibiaComboBox {
            id: stateFitlerComboBox
            Layout.fillWidth: true
            model: controller != null ? controller.statesFitlerModel : null
            textRole: "text"

            shouldBeCurrentIndex: controller != null ? controller.stateFilterCurrentIndex : 0
            onCurrentTextChanged:{
              if (controller != null && model != null && !controller.disableQmlSelect) {
                controller.setStateFilter(model[stateFitlerComboBox.currentIndex].state);
              }
            } //onCurrentTextChanged
          } //TibiaComboBox

          TibiaComboBox {
            id: sortOrderComboBox
            Layout.fillWidth: true
            model: controller != null ? controller.sortOrderModel : null
            textRole: "text"

            shouldBeCurrentIndex: controller != null ? controller.sortOrderCurrentIndex : 0
            onCurrentTextChanged: {
              if (controller != null && model != null && !controller.disableQmlSelect) {
                controller.setSortOrder(model[sortOrderComboBox.currentIndex].sortOrder);
              }
            } //onCurrentTextChanged
          } //TibiaComboBox
        } //RowLayout

        RowLayout {
          spacing: TibiaStyle.marginRelated
          Layout.alignment: Qt.AlignHCenter

          ButtonGroup {
            id: houseTypeGroup
            property var houseType: TibiaEnums.HouseTypeHouseOrFlat

            checkedButton: {
              if (controller != null) {
                if (controller.houseType == TibiaEnums.HouseTypeHouseOrFlat) {
                  return houseOrFlatRadioButton;
                } else if (controller.houseType == TibiaEnums.HouseTypeGuildHall) {
                  return guildHallRadioButton;
                }
              }
              return houseOrFlatRadioButton;
            } //current

            onCheckedButtonChanged: {
              if (controller != null) {
                if (checkedButton == houseOrFlatRadioButton) {
                  controller.setHouseTypeFilter(TibiaEnums.HouseTypeHouseOrFlat);
                } else if (checkedButton == guildHallRadioButton) {
                  controller.setHouseTypeFilter(TibiaEnums.HouseTypeGuildHall);
                } else {
                  controller.setHouseTypeFilter(TibiaEnums.HouseTypeHouseOrFlat);
                }
              }
            } //onCurrentChanged
          } //ButtonGroup

          TibiaRadioButton {
            id: houseOrFlatRadioButton
            text: qsTrId("houses_filter_houses_flats")
            ButtonGroup.group: houseTypeGroup
          } //TibiaRadioButton

          TibiaRadioButton {
            id: guildHallRadioButton
            text: qsTrId("houses_filter_guildhalls")
            ButtonGroup.group: houseTypeGroup
          } //TibiaRadioButton
        } //RowLayout
      } //ColumnLayout
    } //TibiaFrame2PixelUpFilled

    RowLayout {
      spacing: TibiaStyle.marginRelated
      Layout.fillHeight: true

      TibiaFrame2PixelUpFilled {
        Layout.fillHeight: true
        Layout.preferredWidth: 250
        Layout.maximumWidth: Layout.preferredWidth

        ColumnLayout {
          id: columnWrapper
          anchors.fill: parent
          anchors.margins: parent.marginsToContent

          spacing: TibiaStyle.marginRelated

          RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 212
            Layout.minimumHeight: Layout.preferredHeight
            Layout.maximumHeight: Layout.preferredHeight
            spacing: TibiaStyle.marginRelated
            TibiaFrame1PixelDown {
              Layout.fillWidth: true
              Layout.fillHeight: true
              Rectangle {
                anchors.fill: parent
                color: "black"
                anchors.margins: parent.borderWidth

                Item {
                  anchors.fill: parent
                  clip: true

                  MinimapRenderer {
                    id: minimapRenderer
                    anchors.fill: parent
                    opacity: 0.8
                    showAreaCaptions: false
                    visible: _houseValid
                  }

                  WorldMap {
                    id: houseView
                    anchors.fill: parent
                    smoothTextureFiltering: true
                    onWidthChanged: cameraViewport.setSize();
                    onHeightChanged: cameraViewport.setSize();

                    visible: _houseValid

                    WorldMapCameraViewport {
                      id: cameraViewport

                      function setSize() {
                        size = Qt.size(houseView.width, houseView.height);
                      }
                      onVolumeChanged: {
                      }
                      Component.onCompleted: {
                        cameraViewport.scaleFactor = cameraViewportMouseArea.targetScaleFactor;
                      }
                      onViewportChanged: {
                        var coordinate = cameraViewport.centerSubfieldCoordinate;
                        if (root.currentLayer != coordinate.z) {
                          root.currentLayer = coordinate.z;
                        }
                        if (scaleFactorPropertyAnimation.running == false) {
                          scaleFactorAnimation.enabled = false;
                          cameraViewportMouseArea.targetScaleFactor = cameraViewport.scaleFactor;
                          scaleFactorAnimation.enabled = true;
                        }

                        var currentCoordinate = cameraViewport.centerLayerTopLeftSubfieldCoordinate;
                        minimapRenderer.camera.topLeftSubfieldCoordinate = currentCoordinate;
                        minimapRenderer.camera.scaleFactor = cameraViewport.scaleFactor;
                        if (currentCoordinate.z > 7) {
                          minimapRenderer.tileType = MinimapRenderer.LocalMinimap;
                        } else {
                          minimapRenderer.tileType = MinimapRenderer.Satellite;
                        }
                        minimapRenderer.update();
                      }
                    }


                    MouseArea {
                      id: cameraViewportMouseArea
                      property var zoomCoordinate: null
                      property var zoomSubfieldCoordinate: null
                      property var clickCoordinate: null
                      property var clickSubfieldCoordinate: null

                      property bool mapMoved: false

                      property double targetScaleFactor: 0.5
                      property double tempScaleFactor: targetScaleFactor

                      anchors.fill: parent

                      Behavior on tempScaleFactor {
                        id: scaleFactorAnimation
                        enabled: true
                        PropertyAnimation {
                          id: scaleFactorPropertyAnimation
                          duration: 250
                        }
                      }

                      onTempScaleFactorChanged: {
                        cameraViewport.scaleFactor = tempScaleFactor;
                        if (zoomCoordinate != null && zoomSubfieldCoordinate != null) {
                           cameraViewport.moveWorldMapSubfieldCoordinateToStretchedPixelCoordinate(zoomSubfieldCoordinate, zoomCoordinate);
                        }
                      }

                      function changeLayer(direction, x, y) {
                        var addValue = direction;
                        if (direction > 0) {
                          addValue = -1;
                        } else if (direction < 0) {
                          addValue = 1;
                        }
                        root.currentLayer = Math.min(15, Math.max(0, root.currentLayer + addValue));
                      }

                      function changeZoom(direction, x, y) {
                        zoomCoordinate = Qt.point(x,y);
                        zoomSubfieldCoordinate = cameraViewport.convertToWorldMapSubfieldCoordinate(zoomCoordinate);

                        var multiplyValue = 0;
                        if (direction > 0) {
                          multiplyValue = 2.0;
                        } else if (direction < 0) {
                          multiplyValue = 0.5;
                        }
                        targetScaleFactor = Math.max(Math.min(targetScaleFactor * multiplyValue, 1.0), 1.0 / 16.0);
                      }

                      onPressed: (mouse) => {
                        clickCoordinate = Qt.point(mouse.x, mouse.y);
                        clickSubfieldCoordinate = cameraViewport.convertToWorldMapSubfieldCoordinate(clickCoordinate);
                        mapMoved = false;
                      } //onPressed
                      onReleased: {
                        clickCoordinate = null;
                      } //onReleased
                      onPositionChanged: (mouse) => {
                        if (clickCoordinate !== null) {
                          var mouseDistance =  Qt.point((clickCoordinate.x - mouse.x), (clickCoordinate.y - mouse.y));
                          if (mapMoved == true || Math.abs(mouseDistance.x) > 3 || Math.abs(mouseDistance.y) > 3) {
                            mouseDistance = Qt.point(mouseDistance.x, mouseDistance.y)
                            cameraViewport.moveWorldMapSubfieldCoordinateToStretchedPixelCoordinate(clickSubfieldCoordinate, Qt.point(mouse.x, mouse.y));
                            mapMoved = true;
                          }
                        }
                        mouse.accepted = false;
                      } //onPositionChanged
                      onWheel: (wheel) => {
                        if (wheel.modifiers & Qt.ShiftModifier) {
                          changeLayer(wheel.angleDelta.y, wheel.x, wheel.y);
                        } else {
                          changeZoom(wheel.angleDelta.y, wheel.x, wheel.y);
                        }
                      } //onWheel
                    }
                  }
                }

                Loader {
                  anchors.centerIn: parent
                  z: 100
                  sourceComponent: root.currentModel != null ? undefined : noHouseSelectedComponent

                  Component {
                    id: noHouseSelectedComponent

                    TibiaText {
                      text: qsTrId("houses_no_house_selected")
                    } //TibiaText
                  } //Component
                } //Loader
              } //Rectangle
            } //TibiaFrame1PixelDown
            ColumnLayout {
              id: mapControlsWrapper
              Layout.alignment: Qt.AlignVCenter
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
                        controller.centerHouse();
                      }
                    } else {
                      var offset = Qt.point(-offsetX * 10, -offsetY * 10);
                      var clickSubfieldCoordinate = cameraViewport.convertToWorldMapSubfieldCoordinate(Qt.point(0,0));
                      cameraViewport.moveWorldMapSubfieldCoordinateToStretchedPixelCoordinate(clickSubfieldCoordinate, offset);
                    }
                  } //onMouseButtonClicked
                } //TibiaMinimapRose
                RowLayout {
                  Layout.maximumWidth: minimapRose.width
                  Layout.topMargin: -4
                  ColumnLayout {
                    id: buttonsWrapper
                    Layout.alignment: Qt.AlignBottom | Qt.AlignRight
                    spacing: 0

                    TibiaIconButton {
                      id: automap_button_zoomout
                      sourceUp: "/images/automap-button-zoomout-up.png"
                      sourceDown: "/images/automap-button-zoomout-down.png"
                      tooltipText: qsTrId("cyclopedia_map_zoom_out_tooltip")

                      onClicked: {
                        cameraViewportMouseArea.changeZoom(-1, cameraViewportMouseArea.width / 2, cameraViewportMouseArea.height / 2);
                      } //onClicked
                    } // TibiaIconButton

                    Item { Layout.fillWidth: true }

                    TibiaIconButton {
                      id: automap_button_zoomin
                      sourceUp: "/images/automap-button-zoomin-up.png"
                      sourceDown: "/images/automap-button-zoomin-down.png"
                      tooltipText: qsTrId("cyclopedia_map_zoom_in_tooltip")

                      onClicked: {
                        cameraViewportMouseArea.changeZoom(1, cameraViewportMouseArea.width / 2, cameraViewportMouseArea.height / 2);
                      } //onClicked
                    } // TibiaIconButton
                    TibiaIconButton {
                      id: goToCyclopediaMapButton
                      sourceUp: "/images/automap-button-cyclopediamap-up.png"
                      sourceDown: "/images/automap-button-cyclopediamap-down.png"
                      tooltipText: qsTrId("houses_details_show_on_map")

                      onClicked: {
                        if (controller != null) {
                          controller.showOnCyclopediaMap();
                        }
                      }//onClicked
                    } //TibiaIconButton
                  } // ColumnLayout
                  TibiaMapLayersSlider {
                    id: mapLayersSlider
                    minimumLayer: root.minimumHouseLayer
                    maximumLayer: root.maximumHouseLayer
                    noLayers: root.currentModel == null
                    Layout.alignment: Qt.AlignBottom | Qt.AlignRight
                    tooltip: qsTrId("cyclopedia_map_change_layer_tooltip")
                  } //TibiaMapLayersSlider
                } // RowLayout
              } // ColumnLayout
            } // RowLayout
          }

          RowLayout {
            spacing: 0
            Layout.bottomMargin: -(parent.spacing - TibiaStyle.marginNarrow)

            TibiaText {
              Layout.fillWidth: true
              styleType: "WhiteCaption"
              text: {
                if (root.currentModel != null) {
                  if (root.currentModel.state == TibiaEnums.HouseStateAuctioned) {
                    return qsTrId("houses_state_auction_caption");
                  } else if (root.currentModel.state == TibiaEnums.HouseStateUnoccupied) {
                    return qsTrId("houses_state_empty_caption");
                  } else if (root.currentModel.state == TibiaEnums.HouseStateRented) {
                    return qsTrId("houses_state_rented_caption");
                  } else if (root.currentModel.state == TibiaEnums.HouseStateTransferPending) {
                    return qsTrId("houses_state_rented_caption");
                  } else if (root.currentModel.state == TibiaEnums.HouseStateMoveOutPending) {
                    return qsTrId("houses_state_rented_caption");
                  } else if (root.currentModel.state == TibiaEnums.HouseStateUnknown) {
                    return qsTrId("houses_state_updating_caption");
                  }
                }
                return "";
              } //text
            } //TibiaText

            Image {
              visible: root.currentModel != null && root.currentModel.isOwnHouse
              source: "image://store-description-icons/5"
              Tooltip {
                anchors.fill: parent
                text: qsTrId("houses_your_house_tooltip")
              } //Tooltip
            } //Image

            Image {
              visible: root.currentModel != null && root.currentModel.state == TibiaEnums.HouseStateTransferPending && root.currentModel.isOwnHouse
              source: "image://store-description-icons/16"
              Tooltip {
                anchors.fill: parent
                text: qsTrId("houses_outgoing_transfer_tooltip")
              } //Tooltip
            } //Image

            Image {
              visible: root.currentModel != null && root.currentModel.state == TibiaEnums.HouseStateTransferPending && root.currentModel.isHouseOfferedToMe
              source: "image://store-description-icons/17"
              Tooltip {
                anchors.fill: parent
                text: qsTrId("houses_incoming_transfer_tooltip")
              } //Tooltip
            } //Image

            Image {
              visible: root.currentModel != null && root.currentModel.isShop
              source: "image://store-description-icons/15"
              Tooltip {
                anchors.fill: parent
                text: qsTrId("houses_house_is_shop_tooltip")
              } //Tooltip
            } //Image

            Image {
              visible: root.currentModel != null && !root.currentModel.isRentable
              source: "image://store-description-icons/18"
              Tooltip {
                anchors.fill: parent
                text: qsTrId("houses_scheduled_for_renovation_toolitp")
              } //Tooltip
            } //Image

            TibiaGuiHelp {
              color: "orange"
              visible: text.length > 0
              text:  root.currentModel != null ? root.currentModel.description : ""
            } //TibiaGuiHelp
          } //RowLayout

          Loader {
            id: detailsLoader
            Layout.fillWidth: true
            Layout.fillHeight: true

            sourceComponent: {
              if (root.currentModel != null) {
                if (root.currentModel.state == TibiaEnums.HouseStateAuctioned) {
                  return auctionComponent;
                } else if (root.currentModel.state == TibiaEnums.HouseStateUnoccupied) {
                  return unoccupiedComponent;
                } else if (root.currentModel.state == TibiaEnums.HouseStateRented) {
                  return rentedComponent;
                } else if (root.currentModel.state == TibiaEnums.HouseStateTransferPending) {
                  return transferPendingComponent;
                } else if (root.currentModel.state == TibiaEnums.HouseStateMoveOutPending) {
                  return moveOutPendingComponent;
                } else if (root.currentModel.state == TibiaEnums.HouseStateUnknown) {
                  return unknownComponent;
                }
              }
              return undefined;
            } //sourceComponent

            Component {
              id: auctionComponent

              ColumnLayout {
                id: auctionLayout
                Layout.fillWidth: true

                spacing: TibiaStyle.marginNarrow

                TibiaText {
                  visible: root.currentModel != null && !root.currentModel.hasBids
                  Layout.fillWidth: true
                  wrapMode: Text.Wrap
                  text: qsTrId("houses_details_auction_no_bids")
                } //TibiaText

                TibiaKeyValueRowLayout {
                  visible: root.currentModel != null && root.currentModel.hasBids
                  key: qsTrId("houses_label_highest_bidder")
                  keyTextWidth: TibiaStyle.propertyInformationKeyWidth
                  value: root.currentModel != null ? root.currentModel.highestBidderName : ""
                } //TibiaKeyValueRowLayout

                TibiaKeyValueRowLayout {
                  visible: root.currentModel != null && root.currentModel.hasBids
                  key: qsTrId("houses_label_end_time")
                  keyTextWidth: TibiaStyle.propertyInformationKeyWidth
                  value: root.currentModel != null ? root.currentModel.auctionEndStringMulti : ""
                } //TibiaKeyValueRowLayout

                TibiaKeyValueRowLayout {
                  visible: root.currentModel != null && root.currentModel.hasBids
                  key: qsTrId("houses_label_highest_bid")
                  keyTextWidth: TibiaStyle.propertyInformationKeyWidth
                  readonly property var bid: root.currentModel != null ? root.currentModel.highestBid : 0
                  value: TextHelper.formatNumberWithThousandSeparatorsAndThousandShortcutsAsMultiString(bid)
                  valueAlignment: Text.AlignRight

                  Image {
                    source: "/images/icon-goldcoin.png"
                  } //Image
                } //TibiaKeyValueRowLayout

                TibiaKeyValueRowLayout {
                  visible: root.currentModel != null && root.currentModel.ownLimitSet
                  key: qsTrId("houses_label_your_limit")
                  keyTextWidth: TibiaStyle.propertyInformationKeyWidth
                  readonly property var limit: root.currentModel != null ? root.currentModel.ownBidLimit : 0
                  value: TextHelper.formatNumberWithThousandSeparatorsAndThousandShortcutsAsMultiString(limit)
                  valueAlignment: Text.AlignRight

                  Image {
                    source: "/images/icon-goldcoin.png"
                  } //Image
                } //TibiaKeyValueRowLayout

                Item {
                  Layout.topMargin: -parent.spacing
                  Layout.fillHeight: true
                } //Item

                RowLayout {
                  Layout.alignment: Qt.AlignRight
                  spacing: TibiaStyle.marginRelated

                  TibiaHouseActionButton {
                    text: root.getHouseActionName(TibiaEnums.HouseActionBid)
                    disabledReason: root.currentModel != null ? root.currentModel.disableBidReasonString : qsTrId("dummy_unknown")
                    onClicked: { root.activeActionType = TibiaEnums.HouseActionBid; }
                  } //TibiaHouseActionButton
                } //RowLayout
              } //ColumnLayout
            } //Component

            Component {
              id: unoccupiedComponent

              ColumnLayout {
                Layout.fillWidth: true
                spacing: TibiaStyle.marginNarrow

                TibiaText {
                  Layout.fillWidth: true
                  wrapMode: Text.Wrap
                  text: qsTrId("houses_details_unoccupied")
                } //TibiaText

                Item {
                  Layout.topMargin: -parent.spacing
                  Layout.fillHeight: true
                } //Item
              } //ColumnLayout
            } //Component

            Component {
              id: rentedComponent

              ColumnLayout {
                Layout.fillWidth: true
                spacing: TibiaStyle.marginNarrow

                TibiaKeyValueRowLayout {
                  key: qsTrId("houses_label_rentee")
                  keyTextWidth: TibiaStyle.propertyInformationKeyWidth
                  value: root.currentModel != null ? root.currentModel.renterName : ""
                } //TibiaKeyValueRowLayout

                TibiaKeyValueRowLayout {
                  key: qsTrId("houses_label_paid_until")
                  keyTextWidth: TibiaStyle.propertyInformationKeyWidth
                  value: root.currentModel != null ? root.currentModel.paidUntilStringMulti : ""
                } //TibiaKeyValueRowLayout

                Item {
                  visible: root.currentModel != null && root.currentModel.state == TibiaEnums.HouseStateRented
                  Layout.topMargin: -parent.spacing
                  Layout.fillHeight: true
                } //Item

                RowLayout {
                  Layout.alignment: Qt.AlignRight
                  visible: root.currentModel != null && root.currentModel.isOwnHouse  && root.currentModel.state == TibiaEnums.HouseStateRented

                  spacing: TibiaStyle.marginRelated

                  TibiaHouseActionButton {
                    text: root.getHouseActionName(TibiaEnums.HouseActionMoveOut)
                    disabledReason: root.currentModel != null ? root.currentModel.disableMoveOutReasonString : qsTrId("dummy_unknown")
                    onClicked: { root.activeActionType = TibiaEnums.HouseActionMoveOut; }
                  } //TibiaHouseActionButton

                  TibiaHouseActionButton {
                    text: root.getHouseActionName(TibiaEnums.HouseActionTransfer)
                    disabledReason: root.currentModel != null ? root.currentModel.disableTransferReasonString : qsTrId("dummy_unknown")
                    onClicked: { root.activeActionType = TibiaEnums.HouseActionTransfer; }
                  } //TibiaHouseActionButton
                } //RowLayout
              } //ColumnLayout
            } //Component

            Component {
              id: transferPendingComponent

              ColumnLayout {
                Layout.fillWidth: true
                spacing: TibiaStyle.marginNarrow

                Loader {
                  Layout.fillWidth: true
                  sourceComponent: rentedComponent
                } //Loader

                TibiaText {
                  Layout.fillWidth: true
                  Layout.topMargin: -(parent.spacing - TibiaStyle.marginRelated)
                  styleType: "WhiteCaption"
                  text: qsTrId("houses_state_transfer_pending_caption")
                } //TibiaText

                TibiaKeyValueRowLayout {
                  key: qsTrId("houses_label_new_owner")
                  keyTextWidth: TibiaStyle.propertyInformationKeyWidth
                  value: root.currentModel != null ? root.currentModel.newOwnerName : ""
                } //TibiaKeyValueRowLayout

                TibiaKeyValueRowLayout {
                  key: qsTrId("houses_label_date")
                  keyTextWidth: TibiaStyle.propertyInformationKeyWidth
                  value: root.currentModel != null ? root.currentModel.transferTimestampStringMulti : ""
                } //TibiaKeyValueRowLayout

                TibiaKeyValueRowLayout {
                  key: qsTrId("houses_label_price")
                  keyTextWidth: TibiaStyle.propertyInformationKeyWidth
                  readonly property var price: root.currentModel != null ? root.currentModel.transferPrice : 0
                  value: TextHelper.formatNumberWithThousandSeparatorsAndThousandShortcutsAsMultiString(price)
                  valueFillWidth: false

                  Image {
                    source: "/images/icon-goldcoin.png"
                  } //Image
                } //TibiaKeyValueRowLayout

                Item {
                  Layout.topMargin: -parent.spacing
                  Layout.fillHeight: true
                } //Item

                RowLayout {
                  Layout.alignment: Qt.AlignRight
                  visible: root.currentModel != null && (root.currentModel.isOwnHouse || root.currentModel.isHouseOfferedToMe)

                  spacing: TibiaStyle.marginRelated

                  TibiaHouseActionButton {
                    Layout.preferredWidth: TibiaStyle.buttonWidthWide
                    text: root.getHouseActionName(TibiaEnums.HouseActionCancelTransfer)
                    visible: root.currentModel != null && root.currentModel.isOwnHouse
                    disabledReason: root.currentModel != null ? root.currentModel.disableCancelTransferReasonString : qsTrId("dummy_unknown")
                    onClicked: { root.activeActionType = TibiaEnums.HouseActionCancelTransfer; }
                  } //TibiaHouseActionButton

                  TibiaHouseActionButton {
                    Layout.preferredWidth: TibiaStyle.buttonWidthWide
                    text: root.getHouseActionName(TibiaEnums.HouseActionAcceptTransfer)
                    visible: root.currentModel != null && root.currentModel.isHouseOfferedToMe
                    disabledReason: root.currentModel != null ? root.currentModel.disableAcceptTransferReasonString : qsTrId("dummy_unknown")
                    onClicked: { root.activeActionType = TibiaEnums.HouseActionAcceptTransfer; }
                  } //TibiaHouseActionButton

                  TibiaHouseActionButton {
                    Layout.preferredWidth: TibiaStyle.buttonWidthWide
                    text: root.getHouseActionName(TibiaEnums.HouseActionRejectTransfer)
                    visible: root.currentModel != null && root.currentModel.isHouseOfferedToMe
                    disabledReason: root.currentModel != null ? root.currentModel.disableRejectTransferReasonString : qsTrId("dummy_unknown")
                    onClicked: { root.activeActionType = TibiaEnums.HouseActionRejectTransfer; }
                  } //TibiaHouseActionButton
                } //RowLayout

              } //ColumnLayout
            } //Component

            Component {
              id: moveOutPendingComponent

              ColumnLayout {
                Layout.fillWidth: true
                spacing: TibiaStyle.marginNarrow

                Loader {
                  Layout.fillWidth: true
                  sourceComponent: rentedComponent
                } //Loader

                TibiaText {
                  Layout.fillWidth: true
                  Layout.topMargin: -(parent.spacing - TibiaStyle.marginRelated)
                  styleType: "WhiteCaption"
                  text: qsTrId("houses_state_move_out_pending_caption")
                } //TibiaText

                TibiaKeyValueRowLayout {
                  key: qsTrId("houses_label_date")
                  keyTextWidth: TibiaStyle.propertyInformationKeyWidth
                  value: root.currentModel != null ? root.currentModel.moveOutTimestampStringMulti : ""
                } //TibiaKeyValueRowLayout

                Item {
                  Layout.topMargin: -parent.spacing
                  Layout.fillHeight: true
                } //Item

                RowLayout {
                  Layout.alignment: Qt.AlignRight
                  visible: root.currentModel != null && root.currentModel.isOwnHouse

                  spacing: TibiaStyle.marginRelated

                  TibiaHouseActionButton {
                    Layout.preferredWidth: TibiaStyle.buttonWidthWide
                    text: root.getHouseActionName(TibiaEnums.HouseActionCancelMoveOut)
                    disabledReason: root.currentModel != null ? root.currentModel.disableCancelMoveOutReasonString : qsTrId("dummy_unknown")
                    onClicked: { root.activeActionType = TibiaEnums.HouseActionCancelMoveOut; }
                  } //TibiaHouseActionButton
                } //RowLayout
              } //ColumnLayout
            } //Component

            Component {
              id: unknownComponent

              ColumnLayout {
                Layout.fillWidth: true
                spacing: TibiaStyle.marginNarrow

                TibiaText {
                  Layout.fillWidth: true
                  wrapMode: Text.Wrap
                  text: qsTrId("houses_details_updating").arg(qsTrId("refresh"))
                } //TibiaText

                Item {
                  Layout.topMargin: -parent.spacing
                  Layout.fillHeight: true
                } //Item
              } //ColumnLayout
            } //Component
          } //Loader
        } // ColumnLayout
      } //TibiaFrame2PixelUpFilled

      TibiaFrame1PixelDown {
        Layout.fillHeight: true
        Layout.fillWidth: true

        visible: !actionDetailsView.visible

        Loader {
          anchors.centerIn: parent
          sourceComponent: housesListView.visible ? undefined : noResultsComponent

          Component {
            id: noResultsComponent

            TibiaText {
              text: qsTrId("noresults")
            } //TibiaText
          } //Component
        } //Loader

        TibiaScrollView {
          anchors.fill: parent
          anchors.margins: parent.borderWidth
          visible: housesListView.count > 0
          contentWidth: housesListView.width - TibiaStyle.marginNarrow * 2

          ListView {
            id: housesListView
            leftMargin: TibiaStyle.marginNarrow
            rightMargin: TibiaStyle.marginNarrow
            topMargin: TibiaStyle.marginNarrow
            bottomMargin: 0

            model: controller != null ? controller.housesModel : null

            boundsBehavior: Flickable.StopAtBounds
            interactive: false //prevent flick behavior on touch screens

            highlightMoveDuration: 0

            Keys.onUpPressed: (event) => {
              var oldIndex = housesListView.currentIndex;
              housesListView.decrementCurrentIndex();
              if (oldIndex === housesListView.currentIndex) {
                event.accepted = false;
              }
            } //Keys.onUpPressed

            Keys.onDownPressed: (event) => {
              var oldIndex = housesListView.currentIndex;
              housesListView.incrementCurrentIndex();
              if (oldIndex === housesListView.currentIndex) {
                event.accepted = false;
              }
            } //Keys.onDownPressed

            onCurrentIndexChanged: {
              if (controller != null) {
                if (currentItem != null ) {
                  controller.selectHouse(housesListView.currentItem.modelData.houseId);
                } else if (housesListView.currentIndex == -1 && housesListView.count > 0 && !controller.disableQmlSelect) {
                  selectFirstDelayed.restart();
                } else if(_currentHouseId != 0 && !controller.disableQmlSelect) {
                  controller.selectHouse(0);
                  selectFirstDelayed.stop()
                }
              }
            } //onCurrentIndexChanged

            Timer {
              id: selectFirstDelayed
              property bool enabled: controller != null && !controller.disableQmlSelect
              onEnabledChanged: {
                if (!enabled) {
                  stop();
                }
              } //onEnabledChanged
              repeat: false
              interval: 1
              onTriggered: {
                if (enabled) {
                  housesListView.currentIndex = 0;
                }
              } //onTriggered
            } //Timer

            //type var is important, otherwise not all changes signals are forwarded, using int and changing to the same value would not trigger onChanged
            readonly property var _currentHouseId: controller != null ? controller.currentHouseId : 0
            on_CurrentHouseIdChanged: {
              if (housesListView.model != null) {
                for (var i=0; i < housesListView.count; i++) {
                  var idx = housesListView.model.index(i, 0);
                  var value = housesListView.model.data(idx, housesListView.model.houseIdEnumValue);
                  if (value == housesListView._currentHouseId) {
                    housesListView.currentIndex = i;
                    return;
                  }
                }
              }
              housesListView.currentIndex = -1;
              currentIndexChanged(); //make sure that onCurrentIndexChanged is triggered to select the first entry if needed
            } //on_CurrentHouseIdChanged

            Component {
              id: headerFooterComponent
              Item {
                anchors.left: parent != null ? parent.left : undefined
                anchors.right: parent != null ? parent.right : undefined
                height: TibiaStyle.marginNarrow
              } //header: Item
            } //Component

            //header: count > 0 ? headerFooterComponent : null //does break the scroll bar if there are not enough entries to scroll
            footer: count > 0 ? headerFooterComponent : null

            spacing: 1 //with the borders of the adjacent etnries this is TibiaStyle.marginRelated

            delegate: Rectangle {
              id: delegateRoot
              property int houseID: model.houseId
              anchors { left: parent ? parent.left : undefined; right: parent ? parent.right : undefined }
              readonly property int frameBorderWidth: TibiaStyle.marginNarrow
              height: contentFrame.height + 2 * frameBorderWidth

              color: "transparent"
              border.width: housesListView.currentIndex == index ? frameBorderWidth : 0
              border.color: "white"

              readonly property var modelData: model

              TibiaDialogFrameWithCaption {
                id: contentFrame
                anchors { left: parent.left; top: parent.top; right: parent.right }
                anchors.margins: delegateRoot.frameBorderWidth
                borderToContentMargin: delegateRoot.frameBorderWidth

                height: contentLayout.height + topMarginToContent + marginsToContent

                caption: model.name

                ColumnLayout {
                  id: contentLayout
                  anchors { left: parent.left; top: parent.top; right: parent.right }
                  anchors.margins: parent.marginsToContent
                  anchors.topMargin: parent.topMarginToContent

                  spacing: TibiaStyle.marginRelated

                  RowLayout {
                    spacing: TibiaStyle.marginRelated

                    TibiaText {
                      styleType: "Caption"
                      text: qsTrId("houses_details_label_size")
                    } //TibiaText

                    TibiaText {
                      Layout.preferredWidth: 65
                      Layout.maximumWidth: Layout.preferredWidth

                      horizontalAlignment: Text.AlignRight
                      text: qsTrId("houses_details_label_sqm").arg(model.size)
                    } //TibiaText

                    TibiaText {
                      styleType: "Caption"
                      text: qsTrId("houses_details_label_beds")
                    } //TibiaText

                    TibiaText {
                      Layout.preferredWidth: 25
                      Layout.maximumWidth: Layout.preferredWidth

                      text: model.maxBeds
                    } //TibiaText

                    TibiaText {
                      styleType: "Caption"
                      text: qsTrId("houses_details_label_rent")
                    } //TibiaText

                    RowLayout {
                      Layout.preferredWidth: 55
                      Layout.maximumWidth: Layout.preferredWidth
                      spacing: TibiaStyle.marginNarrow

                      TibiaText {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignRight
                        text: TextHelper.formatNumberWithThousandSeparatorsShortestShortcut(model.rent)

                        Tooltip {
                          anchors.fill: parent
                          text: TextHelper.formatNumberWithThousandSeparators(model.rent)
                        } //Tooltip
                      } //TibiaText

                      Image {
                        source: "/images/icon-goldcoin.png"
                      } //Image
                    } //RowLayout

                    Item {
                      Layout.fillWidth: true
                      Layout.rightMargin: -parent.spacing
                    } //Item

                    RowLayout {
                      id: houseIcons
                      spacing: 0

                      Image {
                        visible: model.isOwnHouse
                        source: "image://store-description-icons/5"
                        Tooltip {
                          anchors.fill: parent
                          text: qsTrId("houses_your_house_tooltip")
                        } //Tooltip
                      } //Image

                      Image {
                        visible: model.state == TibiaEnums.HouseStateTransferPending && model.isOwnHouse
                        source: "image://store-description-icons/16"
                        Tooltip {
                          anchors.fill: parent
                          text: qsTrId("houses_outgoing_transfer_tooltip")
                        } //Tooltip
                      } //Image

                      Image {
                        visible: model.state == TibiaEnums.HouseStateTransferPending && model.isHouseOfferedToMe
                        source: "image://store-description-icons/17"
                        Tooltip {
                          anchors.fill: parent
                          text: qsTrId("houses_incoming_transfer_tooltip")
                        } //Tooltip
                      } //Image

                      Image {
                        visible: model.isShop
                        source: "image://store-description-icons/15"
                        Tooltip {
                          anchors.fill: parent
                          text: qsTrId("houses_house_is_shop_tooltip")
                        } //Tooltip
                      } //Image

                      Image {
                        visible: !model.isRentable
                        source: "image://store-description-icons/18"
                        Tooltip {
                          anchors.fill: parent
                          text: qsTrId("houses_scheduled_for_renovation_toolitp")
                        } //Tooltip
                      } //Image

                      TibiaGuiHelp {
                        color: "orange"
                        visible: text.length > 0
                        text: model.description
                      } //TibiaGuiHelp
                    } //RowLayout
                  } //RowLayout

                  RowLayout {
                    Layout.fillWidth: true
                    spacing: TibiaStyle.marginRelated
                    readonly property bool isRunningAuction: model.state == TibiaEnums.HouseStateAuctioned && model.hasBids

                    TibiaText {
                      styleType: "Caption"
                      text: qsTrId("houses_details_label_status")
                    } //TibiaText

                    TibiaText {
                      Layout.fillWidth: !auctionExtraData.visible
                      text: model.shortStatusString
                    } //TibiaText

                    RowLayout {
                      id: auctionExtraData
                      Layout.fillWidth: true
                      spacing: TibiaStyle.marginNarrow
                      visible: model.state == TibiaEnums.HouseStateAuctioned && model.hasBids

                      TibiaText {
                        text: qsTrId("houses_state_auction_bid")
                      } //TibiaText

                      TibiaText {
                        Layout.maximumWidth: 60
                        horizontalAlignment: Text.AlignRight
                        text: TextHelper.formatNumberWithThousandSeparatorsAndThousandShortcutsAsMultiString(model.highestBid)
                      } //TibiaText

                      Image {
                        source: "/images/icon-goldcoin.png"
                      } //Image

                      TibiaText {
                        Layout.leftMargin: TibiaStyle.marginRelated
                        text: qsTrId("houses_state_auction_end").arg(model.timeUntilAuctionEndString)
                      } //TibiaText
                    } //RowLayout
                  } ///RowLayout
                } //ColumnLayout
              } //TibiaDialogFrameWithCaption

              MouseArea {
                anchors.fill: parent
                z: -1

                onClicked: {
                  if (controller != null) {
                    controller.selectHouse(delegateRoot.modelData.houseId);
                  }

                  housesListView.forceActiveFocus();
                } //onClicked
              } // MouseArea
            } //delegate: Rectangle
          } //ListView
        } //TibiaScrollView
      } //TibiaFrame1PixelDown

      TibiaDialogFrameWithCaption {
        id: actionDetailsView
        Layout.fillWidth: true
        Layout.fillHeight: true

        visible: root.activeActionType != TibiaEnums.HouseActionNone

        caption: {
          if (root.activeActionType == TibiaEnums.HouseActionBid) {
            return qsTrId("houses_action_auction_dialog_caption");
          } else if (root.activeActionType == TibiaEnums.HouseActionMoveOut) {
            return qsTrId("houses_action_move_out_dialog_caption");
          } else if (root.activeActionType == TibiaEnums.HouseActionCancelMoveOut) {
            return qsTrId("houses_action_cancel_move_out_dialog_caption");
          } else if (root.activeActionType == TibiaEnums.HouseActionTransfer) {
            return qsTrId("houses_action_transfer_dialog_caption");
          } else if (root.activeActionType == TibiaEnums.HouseActionCancelTransfer) {
            return qsTrId("houses_action_cancel_transfer_dialog_caption");
          } else if (root.activeActionType == TibiaEnums.HouseActionAcceptTransfer) {
            return qsTrId("houses_action_accept_transfer_dialog_caption");
          } else if (root.activeActionType == TibiaEnums.HouseActionRejectTransfer) {
            return qsTrId("houses_action_reject_transfer_dialog_caption");
          }

          return ""
        } //caption

        ColumnLayout {
          anchors.fill: parent
          anchors.margins: parent.marginsToContent
          anchors.topMargin: parent.topMarginToContent

          spacing: TibiaStyle.marginRelated

          ColumnLayout {
            spacing: TibiaStyle.marginNarrow

            TibiaText {
              Layout.fillWidth: true
              styleType: "WhiteCaption"
              text: qsTrId("houses_action_dialog_section_property_information_caption")
            } //TibiaText

            TibiaKeyValueRowLayout {
              key: qsTrId("houses_label_name")
              keyTextWidth: TibiaStyle.propertyInformationKeyWidth
              value: root.currentModel != null ? root.currentModel.name : qsTrId("dummy_unknown")
            } //TibiaKeyValueRowLayout

            TibiaKeyValueRowLayout {
              key: qsTrId("houses_details_label_size")
              keyTextWidth: TibiaStyle.propertyInformationKeyWidth
              value: root.currentModel != null ? qsTrId("houses_details_label_sqm").arg(root.currentModel.size) : qsTrId("dummy_unknown")
            } //TibiaKeyValueRowLayout

            TibiaKeyValueRowLayout {
              key: qsTrId("houses_details_label_beds")
              keyTextWidth: TibiaStyle.propertyInformationKeyWidth
              value: root.currentModel != null ? root.currentModel.maxBeds : qsTrId("dummy_unknown")
            } //TibiaKeyValueRowLayout

            TibiaKeyValueRowLayout {
              id: rentKeyValue
              Layout.fillWidth: false

              key: qsTrId("houses_details_label_rent")
              keyTextWidth: TibiaStyle.propertyInformationKeyWidth
              value: root.currentModel != null ? TextHelper.formatNumberWithThousandSeparatorsShortestShortcut(root.currentModel.rent) : qsTrId("dummy_unknown")
              valueTooltip: root.currentModel != null ? TextHelper.formatNumberWithThousandSeparators(root.currentModel.rent) : qsTrId("dummy_unknown")

              Image {
                Layout.leftMargin: -(parent.spacing - TibiaStyle.marginNarrow)
                source: "/images/icon-goldcoin.png"
              } //Image
            } //TibiaKeyValueRowLayout
          } //ColumnLayout

          Loader {
            id: actionDetailsLoader
            Layout.fillWidth: true

            sourceComponent: {
              if (root.activeActionType == TibiaEnums.HouseActionBid) {
                return bidComponent;
              } else if (root.activeActionType == TibiaEnums.HouseActionMoveOut) {
                return moveOutComponent;
              } else if (root.activeActionType == TibiaEnums.HouseActionCancelMoveOut) {
                return cancelMoveOutComponent;
              } else if (root.activeActionType == TibiaEnums.HouseActionTransfer) {
                return transferComponent;
              } else if (root.activeActionType == TibiaEnums.HouseActionCancelTransfer) {
                return cancelTransferComponent;
              } else if (root.activeActionType == TibiaEnums.HouseActionAcceptTransfer) {
                return acceptTransferComponent;
              } else if (root.activeActionType == TibiaEnums.HouseActionRejectTransfer) {
                return rejectTransferComponent;
              }
              return undefined;
            } //sourceComponent

            onLoaded: {
              forceInitialFocusToGivenItemTimer.restart();
            } //onLoaded

            onVisibleChanged: {
              if (visible) {
                forceInitialFocusToGivenItemTimer.restart();
              }
            }//onVisibleChanged

            Timer {
              id: forceInitialFocusToGivenItemTimer
              repeat: false
              interval: 1
              onTriggered: {
                if (actionDetailsLoader.item != null && actionDetailsLoader.item.initialFocusItem != null) {
                  actionDetailsLoader.item.initialFocusItem.forceActiveFocus();
                } else {
                  root.forceActiveFocus();
                }
              } //onTriggered
            } //Timer

            Component {
              id: bidComponent

              ColumnLayout {
                Layout.fillWidth: true
                spacing: TibiaStyle.marginNarrow

                readonly property var initialFocusItem: bidTextField
                readonly property bool actionPossible: !bidTextField.notEnoughGold
                  && bidTextField.length > 0
                  && !bidTextField.bidToHight
                readonly property alias newLimit: bidTextField.textInt

                TibiaText {
                  Layout.fillWidth: true
                  styleType: "WhiteCaption"
                  text: qsTrId("houses_action_dialog_section_auction_information_caption")
                } //TibiaText

                TibiaText {
                  visible: root.currentModel != null && !root.currentModel.hasBids
                  text: qsTrId("houses_action_dialog_no_bids_information")
                } //TibiaText

                TibiaKeyValueRowLayout {
                  visible: root.currentModel != null && root.currentModel.hasBids
                  key: qsTrId("houses_label_highest_bidder")
                  keyTextWidth: TibiaStyle.propertyInformationKeyWidth
                  value: root.currentModel != null ? root.currentModel.highestBidderName : qsTrId("dummy_unknown")
                } //TibiaKeyValueRowLayout

                TibiaKeyValueRowLayout {
                  visible: root.currentModel != null && root.currentModel.hasBids
                  key: qsTrId("houses_label_end_time")
                  keyTextWidth: TibiaStyle.propertyInformationKeyWidth
                  value: root.currentModel != null ? root.currentModel.auctionEndString : qsTrId("dummy_unknown")
                } //TibiaKeyValueRowLayout

                TibiaKeyValueRowLayout {
                  id: highestBidKeyValue
                  visible: root.currentModel != null && root.currentModel.hasBids
                  key: qsTrId("houses_label_highest_bid")
                  keyTextWidth: TibiaStyle.propertyInformationKeyWidth
                  readonly property var bid: root.currentModel != null ? root.currentModel.highestBid : 0
                  value: TextHelper.formatNumberWithThousandSeparatorsAndThousandShortcutsAsMultiString(bid)
                  valueTextWidth: TibiaStyle.houseBidWidth
                  valueAlignment: Text.AlignRight

                  Image {
                    source: "/images/icon-goldcoin.png"
                  } //Image

                  Item {
                    Layout.fillWidth: true
                  } //Item
                } //TibiaKeyValueRowLayout

                TibiaKeyValueRowLayout {
                  visible: root.currentModel != null && root.currentModel.ownLimitSet
                  key: qsTrId("houses_label_your_limit")
                  keyTextWidth: TibiaStyle.propertyInformationKeyWidth
                  readonly property var bid: root.currentModel != null ? root.currentModel.ownBidLimit : 0
                  value: TextHelper.formatNumberWithThousandSeparatorsAndThousandShortcutsAsMultiString(bid)
                  valueTextWidth: TibiaStyle.houseBidWidth
                  valueAlignment: Text.AlignRight

                  Image {
                    source: "/images/icon-goldcoin.png"
                  } //Image

                  Item {
                    Layout.fillWidth: true
                  } //Item
                } //TibiaKeyValueRowLayout

                RowLayout {
                  Layout.fillWidth: true
                  spacing: TibiaStyle.marginRelated

                  TibiaText {
                    styleType: "Caption"

                    Layout.preferredWidth: TibiaStyle.propertyInformationKeyWidth
                    horizontalAlignment: Text.AlignRight

                    text: qsTrId("houses_label_set_bid_limit")
                  } //TibiaText

                  TibiaTextField {
                    id: bidTextField
                    placeholderText: qsTrId("houses_palceholder_bid_limit")
                    Layout.preferredWidth: TibiaStyle.houseBidWidth
                    validator: RegularExpressionValidator { regularExpression: /[0-9]{0,11}/; }
                    maximumLength: 11
                    horizontalAlignment: length > 0 ? TextInput.AlignRight : TextInput.AlignLeft

                    text: "0"
                    readonly property var textInt: Number(text)
                    readonly property var highestBid: root.currentModel != null && root.currentModel.hasBids ? root.currentModel.highestBid : 0
                    onHighestBidChanged: updateBidTextFieldTextTimer.restart()
                    readonly property var ownBidLimit: root.currentModel != null && root.currentModel.ownLimitSet ? root.currentModel.ownBidLimit : 0
                    onOwnBidLimitChanged: updateBidTextFieldTextTimer.restart()

                    Timer {
                      id: updateBidTextFieldTextTimer
                      repeat: false
                      interval: 1
                      onTriggered: {
                        //Timer is needed as calling a function in the onChanged handlers leads to access of an unitialized value
                        if (bidTextField.ownBidLimit > bidTextField.highestBid) {
                          bidTextField.text = Number(bidTextField.ownBidLimit).toString(10)
                        } else if (root.currentModel != null && root.currentModel.hasBids) {
                          bidTextField.text = Number(bidTextField.highestBid + 1).toString(10)
                        } else {
                          bidTextField.text = Number(bidTextField.highestBid).toString(10)
                        }
                      } //onTriggered
                    } //Timer

                    readonly property bool isGuildHall : root.currentModel != null && root.currentModel.isGuildHall
                    readonly property bool lessThanCurrentBid: textInt <= highestBidKeyValue.bid && textInt > 0
                    readonly property bool moreThanOwnAccount: textInt > storeAndResourceBalanceHelper.bankGoldBalance + ownBidLimit
                    readonly property bool moreThanGuildAccount: textInt > storeAndResourceBalanceHelper.guildBankGoldBalance + ownBidLimit

                    readonly property bool notEnoughGold: !bidTextField.isGuildHall && moreThanOwnAccount
                                                       || (bidTextField.isGuildHall && moreThanOwnAccount && bidTextField.moreThanGuildAccount)

                    readonly property bool bidToHight: textInt > TibiaStyle.houseMaxBid
                    color: {
                      if (   bidTextField.notEnoughGold
                          || bidTextField.bidToHight) {
                        return TibiaStyle.textColors["CurrencyLowBalance"];
                      } else if (bidTextField.lessThanCurrentBid) {
                        return TibiaStyle.textColors["MessageWarning"];
                      }

                      return TibiaStyle.textFieldTextColor;
                    } //textColor
                  } //TibiaTextField

                  Image {
                    source: "/images/icon-goldcoin.png"
                  } //Image

                  TibiaGuiHelp {
                    visible: text.length > 0
                    useRichText: true
                    text: {
                      if (bidTextField.length == 0) {
                        return qsTrId("houses_action_dialog_empty_field_not_allowed_hover_text");
                      } else if (bidTextField.notEnoughGold) {
                        return qsTrId("houses_action_dialog_not_enough_gold_balance_hover_text");
                      } else if (bidTextField.bidToHight) {
                        return qsTrId("houses_action_dialog_bid_to_high_hover_text")
                          .arg(TextHelper.formatNumberWithThousandSeparators(TibiaStyle.houseMaxBid));
                      } else if (bidTextField.lessThanCurrentBid) {
                        return qsTrId("houses_action_dialog_bid_less_than_current_hover_text");
                      }

                      return "";
                    } //text

                    color: {
                      if (   bidTextField.length == 0
                          || bidTextField.notEnoughGold
                          || bidTextField.bidToHight) {
                        return "red";
                      } else if (bidTextField.lessThanCurrentBid) {
                        return "orange";
                      }

                      return "grey";
                    } //color
                  } //TibiaGuiHelp

                  Item {
                    Layout.fillWidth: true
                  } //Item

                  TibiaGuiHelp {
                    useRichText: true
                    text: qsTrId("houses_action_dialog_bids_increase_by_one_hover_text")
                  } //TibiaGuiHelp
                } //RowLayout

                TibiaText {
                  Layout.fillWidth: true
                  Layout.topMargin: -(parent.spacing - 2*TibiaStyle.marginRelated)
                  wrapMode: Text.Wrap
                  textFormat: Text.RichText
                  text: qsTrId("houses_action_dialog_winning_bid_information")
                         .arg(root.currentModel != null && root.currentModel.hasBids ? " at %1".arg(root.currentModel.auctionEndString) : "")
                         .arg(rentKeyValue.value)
                } //TibiaText
              } //ColumnLayout
            } //Component bidComponent

            Component {
              id: moveOutComponent

              ColumnLayout {
                Layout.fillWidth: true
                spacing: TibiaStyle.marginNarrow

                readonly property var initialFocusItem: null
                readonly property bool actionPossible: datePicker.futureDate
                                                    && datePicker.notMoreThan30Days
                readonly property alias moveOutDate: datePicker.selectedDate

                TibiaText {
                  Layout.fillWidth: true
                  styleType: "WhiteCaption"
                  text: qsTrId("houses_action_dialog_section_move_information_caption")
                } //TibiaText

                TibiaKeyValueRowLayout {
                  key: qsTrId("houses_label_paid_until")
                  keyTextWidth: TibiaStyle.propertyInformationKeyWidth
                  value: root.currentModel != null ? root.currentModel.paidUntilString : ""
                } //TibiaKeyValueRowLayout

                RowLayout{
                  spacing: TibiaStyle.marginRelated

                  TibiaText {
                    styleType: "Caption"
                    Layout.preferredWidth: TibiaStyle.propertyInformationKeyWidth
                    horizontalAlignment: Text.AlignRight

                    text: qsTrId("houses_label_move_date")
                  } //TibiaText

                  TibiaDatePicker {
                    id: datePicker
                    readonly property bool futureDate: selectedDate > root.lastServerSave
                    readonly property bool notMoreThan30Days: selectedDate <= root.in30DaysDate
                  } //TibiaDatePicker

                  TibiaGuiHelp {
                    visible: !datePicker.futureDate
                    text: qsTrId("houses_action_dialog_date_not_in_future_hover_text")
                    color: "red"
                  } //TibiaGuiHelp

                  TibiaGuiHelp {
                    visible: !datePicker.notMoreThan30Days
                    text: qsTrId("houses_error_message_own_house18")
                    color: "red"
                  } //TibiaGuiHelp

                  Item {
                    Layout.fillWidth: true
                  } //Item

                  TibiaGuiHelp {
                    text: qsTrId("houses_action_dialog_move_on_server_save_hover_text")
                  } //TibiaGuiHelp
                } //RowLayout

                TibiaText {
                  Layout.fillWidth: true
                  Layout.topMargin: -(parent.spacing - 2*TibiaStyle.marginRelated)
                  wrapMode: Text.Wrap
                  text: qsTrId("houses_action_dialog_move_empties_house")
                } //TibiaText

              } //ColumnLayout
            } //Component moveOutComponent

            Component {
              id: cancelMoveOutComponent

              ColumnLayout {
                Layout.fillWidth: true
                spacing: TibiaStyle.marginNarrow

                readonly property var initialFocusItem: null
                readonly property bool actionPossible: true

                TibiaText {
                  Layout.fillWidth: true
                  styleType: "WhiteCaption"
                  text: qsTrId("houses_action_dialog_section_move_information_caption")
                } //TibiaText

                TibiaKeyValueRowLayout {
                  key: qsTrId("houses_label_paid_until")
                  keyTextWidth: TibiaStyle.propertyInformationKeyWidth
                  value: root.currentModel != null ? root.currentModel.paidUntilStringMulti : ""
                } //TibiaKeyValueRowLayout

                TibiaKeyValueRowLayout {
                  key: qsTrId("houses_label_move_date")
                  keyTextWidth: TibiaStyle.propertyInformationKeyWidth
                  value: root.currentModel != null ? root.currentModel.moveOutTimestampString : ""
                } //TibiaKeyValueRowLayout

                TibiaText {
                  Layout.fillWidth: true
                  Layout.topMargin: -(parent.spacing - 2*TibiaStyle.marginRelated)
                  wrapMode: Text.Wrap
                  text: qsTrId("houses_action_dialog_cancel_move_out_information").arg(confirmHouseActionButton.text)
                } //TibiaText
              } //ColumnLayout
            } //Component cancelMoveOutComponent

            Component {
              id: transferComponent

              ColumnLayout {
                Layout.fillWidth: true
                spacing: TibiaStyle.marginNarrow

                readonly property var initialFocusItem: newOwnerTextField
                readonly property bool actionPossible: datePicker.futureDate
                                                    && datePicker.notMoreThan30Days
                                                    && newOwnerTextField.hasText
                                                    && priceTextField.hasText
                                                    && guildHallTransfer.confirmed
                readonly property alias transferDate: datePicker.selectedDate
                readonly property alias newOwnerName: newOwnerTextField.text
                readonly property alias price: priceTextField.textInt

                TibiaText {
                  Layout.fillWidth: true
                  styleType: "WhiteCaption"
                  text: qsTrId("houses_action_dialog_section_transfer_information_caption")
                } //TibiaText

                TibiaKeyValueRowLayout {
                  key: qsTrId("houses_label_paid_until")
                  keyTextWidth: TibiaStyle.propertyInformationKeyWidth
                  value: root.currentModel != null ? root.currentModel.paidUntilString : ""
                } //TibiaKeyValueRowLayout

                RowLayout{
                  spacing: TibiaStyle.marginRelated

                  TibiaText {
                    styleType: "Caption"
                    Layout.preferredWidth: TibiaStyle.propertyInformationKeyWidth
                    horizontalAlignment: Text.AlignRight

                    text: qsTrId("houses_label_transfer_date")
                  } //TibiaText

                  TibiaDatePicker {
                    id: datePicker
                    readonly property bool futureDate: selectedDate > root.lastServerSave
                    readonly property bool notMoreThan30Days: selectedDate <= root.in30DaysDate
                  } //TibiaDatePicker

                  TibiaGuiHelp {
                    visible: !datePicker.futureDate
                    text: qsTrId("houses_action_dialog_date_not_in_future_hover_text")
                    color: "red"
                  } //TibiaGuiHelp

                  TibiaGuiHelp {
                    visible: !datePicker.notMoreThan30Days
                    text: qsTrId("houses_error_message_own_house18")
                    color: "red"
                  } //TibiaGuiHelp

                  Item {
                    Layout.fillWidth: true
                  } //Item

                  TibiaGuiHelp {
                    text: qsTrId("houses_action_dialog_transfer_on_server_save_hover_text")
                  } //TibiaGuiHelp
                } //RowLayout

                RowLayout{
                  spacing: TibiaStyle.marginRelated

                  TibiaText {
                    styleType: "Caption"
                    Layout.preferredWidth: TibiaStyle.propertyInformationKeyWidth
                    horizontalAlignment: Text.AlignRight

                    text: qsTrId("houses_label_new_owner")
                  } //TibiaText


                  TibiaTextField {
                    id: newOwnerTextField
                    Layout.preferredWidth: datePicker.width
                    KeyNavigation.tab: priceTextField
                    KeyNavigation.backtab: priceTextField
                    placeholderText: qsTrId("houses_palceholder_new_owner")
                    maximumLength: TibiaStyle.maxCharacterNameLength
                    readonly property bool hasText: length > 0
                    onActiveFocusChanged: {
                      if (activeFocus) {
                        root.needsTabNavigation = true
                      }
                    } //onActiveFocusChanged
                  } //TibiaTextField

                  TibiaGuiHelp {
                    visible: !newOwnerTextField.hasText
                    text: qsTrId("houses_action_dialog_empty_field_not_allowed_hover_text")
                    color: "red"
                  } //TibiaGuiHelp

                  Item {
                    Layout.fillWidth: true
                  } //Item

                  TibiaGuiHelp {
                    text: qsTrId("houses_action_dialog_new_owner_accept_hover_text")
                  } //TibiaGuiHelp
                } //RowLayout

                RowLayout {
                  Layout.fillWidth: true
                  spacing: TibiaStyle.marginRelated

                  TibiaText {
                    styleType: "Caption"
                    Layout.preferredWidth: TibiaStyle.propertyInformationKeyWidth
                    horizontalAlignment: Text.AlignRight

                    text: qsTrId("houses_label_transfer_price")
                  } //TibiaText

                  TibiaTextField {
                    id: priceTextField
                    placeholderText: qsTrId("houses_palceholder_price")
                    Layout.preferredWidth: TibiaStyle.houseBidWidth
                    KeyNavigation.tab: newOwnerTextField
                    KeyNavigation.backtab: newOwnerTextField
                    validator: RegularExpressionValidator { regularExpression: /[0-9]{0,11}/; }
                    maximumLength: 11
                    horizontalAlignment: hasText ? TextInput.AlignRight : TextInput.AlignLeft

                    text: "0"
                    readonly property var textInt: Number(text)
                    readonly property bool hasText: length > 0
                  } //TibiaTextField

                  Image {
                    source: "/images/icon-goldcoin.png"
                  } //Image

                  TibiaGuiHelp {
                    visible: !priceTextField.hasText
                    text: qsTrId("houses_action_dialog_empty_field_not_allowed_hover_text")
                    color: "red"
                  } //TibiaGuiHelp

                  Item {
                    Layout.fillWidth: true
                  } //Item
                } //RowLayout

                RowLayout {
                  Layout.fillWidth: true
                  spacing: TibiaStyle.marginRelated

                  visible: root.currentModel != null && root.currentModel.isGuildHall

                  TibiaText {
                    text: qsTrId("houses_action_dialog_read_more_guildhall_information")
                  } //TibiaText

                  TibiaGuiHelp {
                    text: qsTrId("houses_action_dialog_guildhall_additional_information_hover_text")
                  } //TibiaGuiHelp

                  Item {
                    Layout.fillWidth: true
                  } //Item
                } //RowLayout

                RowLayout {
                  Layout.fillWidth: true
                  spacing: TibiaStyle.marginRelated
                  visible: root.currentModel != null && root.currentModel.isGuildHall

                  TibiaCheckBox {
                    id: guildHallTransfer
                    text: qsTrId("houses_action_dialog_guhildhall_info_read_information")
                    readonly property bool confirmed: !visible || checked
                  } //TibiaCheckBox

                  TibiaGuiHelp {
                    visible: !guildHallTransfer.confirmed
                    text: qsTrId("houses_action_dialog_empty_field_not_allowed_hover_text")
                    color: "red"
                  } //TibiaGuiHelp

                  Item {
                    Layout.fillWidth: true
                  } //Item
                } //RowLayout

                TibiaText {
                  Layout.fillWidth: true
                  Layout.topMargin: -(parent.spacing - 2*TibiaStyle.marginRelated)
                  wrapMode: Text.Wrap
                  text: qsTrId("houses_action_dialog_transfer_information")
                } //TibiaText
              } //ColumnLayout
            } //Component transferComponent


            Component {
              id: transferInformationComponent

              ColumnLayout {
                Layout.fillWidth: true
                spacing: TibiaStyle.marginNarrow

                TibiaText {
                  Layout.fillWidth: true
                  styleType: "WhiteCaption"
                  text: qsTrId("houses_action_dialog_section_transfer_information_caption")
                } //TibiaText

                TibiaKeyValueRowLayout {
                  key: qsTrId("houses_label_paid_until")
                  keyTextWidth: TibiaStyle.propertyInformationKeyWidth
                  value: root.currentModel != null ? root.currentModel.paidUntilString : ""
                } //TibiaKeyValueRowLayout

                TibiaKeyValueRowLayout {
                  key: qsTrId("houses_label_new_owner")
                  keyTextWidth: TibiaStyle.propertyInformationKeyWidth
                  value: root.currentModel != null ? root.currentModel.newOwnerName : ""
                } //TibiaKeyValueRowLayout

                TibiaKeyValueRowLayout {
                  key: qsTrId("houses_label_transfer_date")
                  keyTextWidth: TibiaStyle.propertyInformationKeyWidth
                  value: root.currentModel != null ? root.currentModel.transferTimestampString : ""
                } //TibiaKeyValueRowLayout

                TibiaKeyValueRowLayout {
                  key: qsTrId("houses_label_price")
                  keyTextWidth: TibiaStyle.propertyInformationKeyWidth
                  readonly property var price: root.currentModel != null ? root.currentModel.transferPrice : 0
                  value: TextHelper.formatNumberWithThousandSeparatorsAndThousandShortcutsAsMultiString(price)
                  valueFillWidth: false

                  Image {
                    source: "/images/icon-goldcoin.png"
                  } //Image

                  Item {
                    Layout.fillWidth: true
                  } //Item
                } //TibiaKeyValueRowLayout
              } //ColumnLayout
            } //Component transferInformationComponent

            Component {
              id: cancelTransferComponent

              ColumnLayout {
                Layout.fillWidth: true
                spacing: TibiaStyle.marginNarrow

                readonly property var initialFocusItem: null
                readonly property bool actionPossible: true

                Loader {
                  sourceComponent: transferInformationComponent
                } //Loader

                TibiaText {
                  Layout.fillWidth: true
                  Layout.topMargin: -(parent.spacing - 2*TibiaStyle.marginRelated)
                  wrapMode: Text.Wrap
                  text: qsTrId("houses_action_dialog_cancel_move_out_information").arg(confirmHouseActionButton.text)
                } //TibiaText
              } //ColumnLayout
            } //Component cancelTransferComponent

            Component {
              id: acceptTransferComponent

              ColumnLayout {
                Layout.fillWidth: true
                spacing: TibiaStyle.marginNarrow

                readonly property var initialFocusItem: null
                readonly property bool actionPossible: true

                Loader {
                  sourceComponent: transferInformationComponent
                } //Loader

                TibiaText {
                  Layout.fillWidth: true
                  Layout.topMargin: -(parent.spacing - 2*TibiaStyle.marginRelated)
                  wrapMode: Text.Wrap
                  text: qsTrId("houses_action_dialog_accept_transfer_information")
                } //TibiaText
              } //ColumnLayout
            } //Component acceptTransferComponent

            Component {
              id: rejectTransferComponent

              ColumnLayout {
                Layout.fillWidth: true
                spacing: TibiaStyle.marginNarrow

                readonly property var initialFocusItem: null
                readonly property bool actionPossible: true

                Loader {
                  sourceComponent: transferInformationComponent
                } //Loader

                TibiaText {
                  Layout.fillWidth: true
                  Layout.topMargin: -(parent.spacing - 2*TibiaStyle.marginRelated)
                  wrapMode: Text.Wrap
                  text: qsTrId("houses_action_dialog_reject_transfer_information")
                } //TibiaText
              } //ColumnLayout
            } //Component rejectTransferComponent
          } //Loader

          Item {
            Layout.fillHeight: true
            Layout.topMargin: -parent.spacing
          } //Item

          RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: TibiaStyle.marginRelated

            TibiaHouseActionButton {
              id: confirmHouseActionButton
              Layout.preferredWidth: (root.activeActionType == TibiaEnums.HouseActionBid)
                                  || (root.activeActionType == TibiaEnums.HouseActionTransfer)
                                  || (root.activeActionType == TibiaEnums.HouseActionMoveOut) ? TibiaStyle.buttonWidthBroad
                                                                                              : TibiaStyle.buttonWidthWide

              text: root.getHouseActionName(root.activeActionType)

              disabledReason:   actionDetailsLoader.item != null
                             && actionDetailsLoader.item.actionPossible  ? ""
                                                                         : qsTrId("houses_action_dialog_form_not_completed_tooltip")

              onClicked: {
                if (controller != null && actionDetailsLoader.item != null) {
                  if (root.activeActionType == TibiaEnums.HouseActionBid) {
                    controller.onActionBidClicked(actionDetailsLoader.item.newLimit);
                  } else if (root.activeActionType == TibiaEnums.HouseActionMoveOut) {
                    controller.onActionMoveOutClicked(actionDetailsLoader.item.moveOutDate);
                  } else if (root.activeActionType == TibiaEnums.HouseActionCancelMoveOut) {
                    controller.onActionCancelMoveOutClicked();
                  } else if (root.activeActionType == TibiaEnums.HouseActionTransfer) {
                    controller.onActionTransferClicked(actionDetailsLoader.item.transferDate,
                                                       actionDetailsLoader.item.newOwnerName,
                                                       actionDetailsLoader.item.price);
                  } else if (root.activeActionType == TibiaEnums.HouseActionCancelTransfer) {
                    controller.onActionCancelTransferClicked();
                  } else if (root.activeActionType == TibiaEnums.HouseActionAcceptTransfer) {
                    controller.onActionAcceptTransferClicked();
                  } else if (root.activeActionType == TibiaEnums.HouseActionRejectTransfer) {
                    controller.onActionRejectTransferClicked();
                  }
                }
              } //onClicked
            } //TibiaHouseActionButton

            TibiaButton {
              text: qsTrId("cancel")

              onClicked: { root.activeActionType = TibiaEnums.HouseActionNone; }
            } //TibiaButton
          } //RowLayout
        } //ColumnLayout
      } //TibiaDialogFrameWithCaption
    } //RowLayout
  } //ColumnLayout
} // Item
