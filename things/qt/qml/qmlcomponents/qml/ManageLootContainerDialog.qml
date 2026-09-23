import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qmlcomponents


TibiaDialog {
  id: dialogRoot
  caption: qsTrId("managecontainer_caption")
  width: 700

  property var controller: null
  property bool isPremium: controller != null && controller.isPremium
  property var listItems: controller != null ? controller.listItems : null
  property string filterString: ""

  onFilterStringChanged: {
    if (controller != null) {
      controller.filterString = filterString;
    }
  }

  onReturnPressedFunction: function() {}
  onCancelPressedFunction: closeDialog

  function closeDialog() {
    if (controller != null) {
      controller.closeButtonClicked();
    }
  } //function closeDialog

  initialFocusItem: dialogRoot
  KeyNavigation.tab: dialogRoot

  Connections {
     target: controller
     function onScrollDown() {
       //double call needed to realy position at the end as not all columns have the same hight
       categoryListView.positionViewAtEnd();
       categoryListView.positionViewAtEnd();
     } //onScrollDown
  } //Connections

  ColumnLayout {
    anchors { left: parent.left; top: parent.top; right: parent.right }
    height: 400
    spacing: TibiaStyle.marginRelated

    RowLayout {
      Layout.fillWidth: true
      spacing: TibiaStyle.marginRelated

      ColumnLayout {
        spacing: TibiaStyle.marginRelated
        Layout.maximumWidth: (dialogRoot.width - quickLootFilterOptions.width) / 2

        TibiaMenuOptionCheckBox {
          id: useMainBackpackAsFallback
          implicitWidth: 0 // this seems to be a necessary workaround. otherwise the layout is destroyed
          text: qsTrId("managecontainer_use_main_backpack_as_fallback")
          Layout.fillWidth: true
          checked: controller !=null && controller.useMainBackpackAsFallback
          Binding {
            target: controller
            property: "useMainBackpackAsFallback"
            value: useMainBackpackAsFallback.checked
          } //Binding

          TibiaGuiHelp {
            anchors {right: parent.right; rightMargin: 5;  verticalCenter: parent. verticalCenter}
            text: qsTrId("managecontainer_use_main_backpack_as_fallback_tooltip")
          } //TibiaGuiHelp
        } //TibiaMenuOptionCheckBox

         RowLayout {
          Layout.alignment: Qt.AlignRight
          
          TibiaText {
            Layout.minimumWidth: 80
            text: qsTrId("managecontainer_group_loot")
          }
            
          TibiaText {
            Layout.minimumWidth: 80
            text: qsTrId("managecontainer_group_obtain")
          }
        }
        TibiaFrame1PixelDown {
          Layout.fillWidth: true
          Layout.fillHeight: true

          Rectangle {
            anchors.fill: parent
            anchors.margins: parent.borderWidth
            color: TibiaStyle.tableViewBackgroundColor
          } //Rectangle

          TibiaScrollView {
            anchors.fill: parent
            anchors.margins: parent.borderWidth

            ListView {
              id: categoryListView
              boundsBehavior: Flickable.StopAtBounds
              interactive: false //prevent flick behavior on touch screens

              model: controller != null ? controller.lootContainers : null

              delegate: Rectangle {
                width: categoryListView.width
                property int margin: TibiaStyle.marginNarrow
                height:   TibiaStyle.containerSlotSize + 2 * margin
                        + (modelData.isRetrieve ? sperator.height : 0)

                color: index % 2 == 0 ? TibiaStyle.tableViewItemBackgroundColor : TibiaStyle.tableViewAlternateBackgroundColor

                RowLayout {
                  anchors.fill: parent
                  anchors.margins: parent.margin + 4
                  anchors.topMargin: parent.margin + (modelData.isRetrieve ? sperator.height : 0)
                  spacing: TibiaStyle.marginRelated

                  TibiaText {
                    Layout.fillWidth: true
                    Layout.maximumHeight: TibiaStyle.containerSlotSize
                    wrapMode: Text.Wrap
                    text: modelData.categoryName
                  } //TibiaText

                  ContainerSlot {
                    id: containerSlotLoot
                    objectAppearanceInstanceTypeId: modelData.lootContainerAppearanceTypeID
                    mouseAreaEnabled: false

                    MouseArea {
                      anchors.fill: parent
                      hoverEnabled: true
                      enabled: modelData.isObtainContainerSet

                      onEnabledChanged: {
                        if(tibiaMouseCursorController != null) {
                          tibiaMouseCursorController.setOpenContainer(false);
                        }
                      } //onEnabledChanged

                      onEntered: {
                        if(tibiaMouseCursorController != null) {
                          tibiaMouseCursorController.setOpenContainer(true);
                        }
                      } //onEntered

                      onExited: {
                        if(tibiaMouseCursorController != null) {
                          tibiaMouseCursorController.setOpenContainer(false);
                        }
                      } //onExited

                      onClicked: modelData.onOpenLootContainerClicked()
                    } //MouseArea

                    Image {
                      anchors { top: parent.top; left: parent.left }
                      anchors.margins: 1

                      source: "/images/premium/icon-banner-premium-16x16.png"
                      visible: modelData.isLockedByPremium && !dialogRoot.isPremium

                      Tooltip {
                        anchors.fill: parent
                        text: qsTrId("managecontainer_only_premium_category_tooltip")
                      } //Tooltip
                    } //Image
                  } //ContainerSlot

                  TibiaIconButton {
                    sourceUp: "/images/button-clear-20x20-up.png"
                    sourceDown: "/images/button-clear-20x20-down.png"
                    onClicked: modelData.onClearLootContainerClicked()
                    tooltipText: qsTrId("managecontainer_clear_button_tooltip").arg(modelData.categoryName)

                    enabled: modelData.isLootContainerSet

                    TibiaDisabledOverlay {
                      anchors.fill: parent
                      anchors.margins: 1
                      visible: !parent.enabled
                    } //TibiaDisabledOverlay
                  } //TibiaButton

                  TibiaIconButton {
                    sourceUp: "/images/button-select-20x20-up.png"
                    sourceDown: "/images/button-select-20x20-down.png"
                    onClicked: modelData.onSelectLootContainerClicked()
                    tooltipText: qsTrId("managecontainer_select_button_tooltip").arg(modelData.categoryName)
                  } //TibiaButton
                  ContainerSlot {
                    id: containerSlotObtain
                    objectAppearanceInstanceTypeId: modelData.obtainContainerAppearanceTypeID
                    mouseAreaEnabled: false

                    MouseArea {
                      anchors.fill: parent
                      hoverEnabled: true
                      enabled: modelData.isObtainContainerSet

                      onEnabledChanged: {
                        if(tibiaMouseCursorController != null) {
                          tibiaMouseCursorController.setOpenContainer(false);
                        }
                      } //onEnabledChanged

                      onEntered: {
                        if(tibiaMouseCursorController != null) {
                          tibiaMouseCursorController.setOpenContainer(true);
                        }
                      } //onEntered

                      onExited: {
                        if(tibiaMouseCursorController != null) {
                          tibiaMouseCursorController.setOpenContainer(false);
                        }
                      } //onExited

                      onClicked: modelData.onOpenObtainContainerClicked()
                    } //MouseArea

                    Image {
                      anchors { top: parent.top; left: parent.left }
                      anchors.margins: 1

                      source: "/images/premium/icon-banner-premium-16x16.png"
                      visible: modelData.isLockedByPremium && !dialogRoot.isPremium

                      Tooltip {
                        anchors.fill: parent
                        text: qsTrId("managecontainer_only_premium_category_tooltip")
                      } //Tooltip
                    } //Image
                  } //ContainerSlot

                  TibiaIconButton {
                    sourceUp: "/images/button-clear-20x20-up.png"
                    sourceDown: "/images/button-clear-20x20-down.png"
                    onClicked: modelData.onClearObtainContainerClicked()
                    tooltipText: qsTrId("managecontainer_clear_button_tooltip").arg(modelData.categoryName)

                    enabled: modelData.isObtainContainerSet

                    TibiaDisabledOverlay {
                      anchors.fill: parent
                      anchors.margins: 1
                      visible: !parent.enabled
                    } //TibiaDisabledOverlay
                  } //TibiaButton

                  TibiaIconButton {
                    sourceUp: "/images/button-select-20x20-up.png"
                    sourceDown: "/images/button-select-20x20-down.png"
                    onClicked: modelData.onSelectObtainContainerClicked()
                    tooltipText: qsTrId("managecontainer_select_button_tooltip").arg(modelData.categoryName)
                  }
                } //RowLayout

              } //delegate: Rectangle
            } //ListView
          } //TibiaScrollView
        } //TibiaFrame1PixelDown

      } //ColumnLayout

      ColumnLayout {
        id: quickLootFilterOptions
        Layout.fillWidth: false
        spacing: TibiaStyle.marginRelated

        TibiaFrame2PixelUpFilled {
          Layout.preferredHeight: filterOptionsArea.height + 2 * (TibiaStyle.marginRelated + borderWidth)
          Layout.preferredWidth: filterOptionsArea.width + 2 * (TibiaStyle.marginRelated + borderWidth)

          ColumnLayout {
            id: filterOptionsArea
            anchors { left: parent.left; top: parent.top }
            anchors.margins: TibiaStyle.marginRelated + parent.borderWidth
            spacing: TibiaStyle.marginRelated

            TibiaText {
              text: qsTrId("managecontainer_blacklist_whitelist_caption")
            } //TibiaText

            ButtonGroup {
              id: lootListTypeGroup
              onCheckedButtonChanged: {
                if (dialogRoot.controller != null && checkedButton != null) {
                  itemsListView.positionViewAtBeginning();
                  controller.requestLootBlackWhitelistSwitch(checkedButton == blacklistSelect ? 0 : 1);
                  itemSearchField.clearSearch();
                }
              }
            } // ButtonGroup

            TibiaRadioButton {
              id: blacklistSelect
              property bool controllerChecked: controller != null && controller.blackWhiteListType == 0
              text: qsTrId("managecontainer_blacklist")
              ButtonGroup.group: lootListTypeGroup

              onControllerCheckedChanged: {
                if (controllerChecked != checked) {
                  checked = controllerChecked;
                }
              } //onControllerCheckedChanged
            } // TibiaRadioButton

            TibiaRadioButton {
              id: whitelistSelect
              property bool controllerChecked: controller != null && controller.blackWhiteListType == 1
              text: qsTrId("managecontainer_whitelist")
              ButtonGroup.group: lootListTypeGroup

              onControllerCheckedChanged: {
                if (controllerChecked != checked) {
                  checked = controllerChecked;
                }
              } //onControllerCheckedChanged
            } // TibiaRadioButton


            TibiaButton {
              Layout.preferredWidth: TibiaStyle.premiumStateButtonWidth
              text: controller != null && controller.blackWhiteListType == 1 ? qsTrId("managecontainer_delete_loot_whitelist")
                                                                             : qsTrId("managecontainer_delete_loot_blacklist")
              onClicked: {
                if (controller != null) {
                  controller.requestClearItemBlackWhitelist();
                }
              } //onClicked
            } //TibiaButton
            TibiaButton {
              Layout.preferredWidth: TibiaStyle.premiumStateButtonWidth
              text: controller != null && controller.blackWhiteListType == 1 ? qsTrId("managecontainer_add_to_loot_whitelist")
                                                                             : qsTrId("managecontainer_add_to_loot_blacklist")
              onClicked: {
                if (controller != null) {
                  controller.requestAddItemBlackWhitelist();
                }
              } //onClicked
            } //TibiaButton
          } //ColumnLayout
        } //TibiaFrame2PixelUpFilled

        TibiaFrame2PixelUpFilled {
          Layout.fillWidth: true
          Layout.fillHeight: true

          ColumnLayout {
            id: premiumStateArea
            anchors.fill: parent
            anchors.margins: TibiaStyle.marginRelated + parent.borderWidth
            spacing: TibiaStyle.marginRelated

            TibiaText {
              Layout.fillWidth: true
              wrapMode: Text.Wrap
              visible: !dialogRoot.isPremium
              text: qsTrId("get_premium") + ":"
            } //TibiaText

            TibiaText {
              Layout.fillWidth: true
              wrapMode: Text.Wrap
              textFormat: Text.RichText

              text: dialogRoot.isPremium ? qsTrId("managecontainer_loot_container_for_premium")
                                         : qsTrId("managecontainer_loot_container_for_free")
            } //TibiaText

            TibiaText {
              Layout.fillWidth: true
              wrapMode: Text.Wrap
              textFormat: Text.RichText

              text: dialogRoot.isPremium ? qsTrId("managecontainer_filter_options_for_premium")
                                         : qsTrId("managecontainer_filter_options_for_free")
            } //TibiaText

            Item {
              Layout.fillHeight: true
            } //Item

            TibiaButton {
              Layout.preferredWidth: TibiaStyle.premiumStateButtonWidth
              Layout.preferredHeight: TibiaStyle.premiumStateButtonHeight

              checkable: dialogRoot.isPremium
              checked: dialogRoot.isPremium
              enabled: !dialogRoot.isPremium
              color: dialogRoot.isPremium ? "grey" : "blue"
              imageSource: dialogRoot.isPremium ? "/images/dailyreward/icon-have-premium.png" : "/images/dailyreward/icon-get-premium.png"
              imageSourceDisabled: imageSource

              tooltipText: qsTrId("get_premium")
              onClicked: controller ? controller.getPremiumClicked() : undefined
            } //TibiaButton


          } //ColumnLayout
        } //TibiaFrame2PixelUpFilled
      } //ColumnLayout

      ColumnLayout {
        spacing: TibiaStyle.marginRelated

        Item {
          Layout.fillWidth: true
          Layout.fillHeight: true
          ColumnLayout {
            anchors.fill: parent
            TibiaTextSearchField {
              id: itemSearchField
              Layout.fillWidth: true
              Layout.preferredHeight: TibiaStyle.optionLineFrameHeight
              shouldBeText: dialogRoot.filterString

              onSearchTextChanged: {
                if (controller != null) {
                  controller.filterString = searchText;
                }
              } //onSearchTextChanged
            }

            TibiaFrame1PixelDown {
              Layout.fillWidth: true
              Layout.fillHeight: true

              Rectangle {
                anchors.fill: parent
                anchors.margins: parent.borderWidth
                color: TibiaStyle.tableViewBackgroundColor
              } //Rectangle

              TibiaScrollView {
                anchors.fill: parent
                anchors.margins: parent.borderWidth

                ListView {
                  id: itemsListView
                  boundsBehavior: Flickable.StopAtBounds
                  interactive: false //prevent flick behavior on touch screens

                  model: listItems
                  Connections {
                    id: modelConnections
                    target: listItems
                    function onRowsAboutToBeRemoved() {
                      resetOriginYTimer.startReset(itemsListView);
                    }
                    function onRowsAboutToBeInserted() {
                      resetOriginYTimer.startReset(itemsListView);
                    }
                  }
                  Timer {
                    id: resetOriginYTimer
                    property var storedFlickable: null
                    property int oldYPosition: 0

                    function startReset(flickable)
                    {
                      oldYPosition = flickable.contentY - flickable.originY;
                      storedFlickable = flickable;
                      if (resetOriginYTimer.running == false) {
                        resetOriginYTimer.start();
                      }
                    }

                    repeat: false
                    running: false
                    interval: 0
                    onTriggered: {
                      storedFlickable.contentY = storedFlickable.originY + oldYPosition;
                      storedFlickable.returnToBounds()
                    }
                  }

                  delegate: Rectangle {
                    property int margin: TibiaStyle.marginNarrow

                    width: itemsListView.width
                    height: TibiaStyle.containerSlotSize + 2 * margin

                    color: index % 2 == 0 ? TibiaStyle.tableViewItemBackgroundColor : TibiaStyle.tableViewAlternateBackgroundColor

                    RowLayout {
                      anchors.fill: parent
                      anchors.margins: parent.margin
                      anchors.topMargin: parent.margin
                      spacing: TibiaStyle.marginRelated

                      TibiaText {
                        Layout.fillWidth: true
                        Layout.maximumHeight: TibiaStyle.containerSlotSize
                        wrapMode: Text.Wrap
                        text: model.typeName
                      } //TibiaText

                      ContainerSlot {
                        id: itemListIcon
                        slotID: model.displayTypeID
                        objectAppearanceInstanceTypeId: model.displayTypeID
                        objectAppearanceInstanceCumulativeCount: 1 //model.cumulativeCount
                        lootvalueImageSourceUnderItem: model.lootvalueImageSourceUnderItem
                        lootvalueImageSourceOverItem: model.lootvalueImageSourceOverItem

                        showPointingHandCursor: true
                        mouseAreaEnabled: true
                        onClicked: {
                          if (controller != null) {
                            controller.showItemDetails(model.displayTypeID)
                          }
                        }
                      } // ContainerSlot

                      TibiaIconButton {
                        sourceUp: "/images/button-clear-20x20-up.png"
                        sourceDown: "/images/button-clear-20x20-down.png"
                        onClicked: {
                          if (controller != null) {
                            controller.removeItemFromList(model.typeID)
                          }
                        }
                        tooltipText: controller != null && controller.blackWhiteListType == 1 ? qsTrId("managecontainer_remove_from_loot_whitelist_button_tooltip")
                                                                                              : qsTrId("managecontainer_remove_from_loot_blacklist_button_tooltip")
                      } //TibiaButton
                    } //RowLayout

                  } //delegate: Rectangle
                } //ListView
              } //TibiaScrollView
            } //TibiaFrame1PixelDown
          }
        }
      } //ColumnLayout
    } //RowLayout

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } //TibiaHorizontalSeparator

    RowLayout {
      Layout.alignment: Qt.AlignRight
      spacing: TibiaStyle.marginRelated

      Item {Layout.fillWidth: true}

      TibiaButton {
        id: closeButton
        text: qsTrId("close")

        onClicked: dialogRoot.closeDialog();
      } // TibiaButton
    } // RowLayout
  } // ColumnLayout

} // TibiaDialog
