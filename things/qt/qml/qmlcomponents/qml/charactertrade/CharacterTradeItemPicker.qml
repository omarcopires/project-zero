import QtQuick
import QtQuick.Layouts

import qmlcomponents
import "qrc:/qt/qml/qmlcomponents/qml/"

ColumnLayout {
  id: root
  property var itemsModel: null
  property int selectedAppearanceTypeID: 0
  property int selectedUpgradeTier: 0
  property string filterString: ""

  signal itemSelected();

  anchors.fill: parent
//  anchors.margins: TibiaStyle.marginUnrelated
  RowLayout {
    TibiaText {
        text: qsTrId("search") + ":"
        horizontalAlignment: Text.AlignRight
    } //TibiaText

    TibiaFrame1PixelDown {
      id: serachFieldFrame
      Layout.fillWidth: true
      Layout.preferredHeight: TibiaStyle.buttonHeightDefault

      RowLayout {
        anchors.fill: parent
        spacing: 0

        TibiaTextField {
          id: searchTextField
          Layout.fillWidth: true
          Layout.fillHeight: true
          KeyNavigation.tab: searchTextField
          KeyNavigation.backtab: searchTextField
          placeholderText: qsTrId("type_to_search_placeholder")
          text: filterString

          onTextChanged: {
            filterRefreshTimer.restart();
          } //onTextChanged

          Timer {
            id: filterRefreshTimer
            interval: TibiaStyle.searchDelay

            onTriggered: {
              root.filterString = searchTextField.text;
            } //onTriggered
          } //Timer
        } //TibiaTextField

        TibiaButton {
          Layout.topMargin: serachFieldFrame.borderWidth
          Layout.bottomMargin: serachFieldFrame.borderWidth
          Layout.rightMargin: serachFieldFrame.borderWidth
          Layout.leftMargin: -serachFieldFrame.borderWidth
          Layout.fillHeight: true
          Layout.preferredWidth: height
          imageSource: "/images/icon-erase-small.png"
          tooltipText: qsTrId("hotkeyoptions_clear_search_tooltip")

          onClicked: {
            searchTextField.text = '';
          } //onClicked
        } //TibiaButton
      } //RowLayout
    } //TibiaFrame1PixelDown
  }

  TibiaFrame1PixelDown {
    id: scrollAreaFrame
    Layout.fillWidth: true
    Layout.fillHeight: true

    Rectangle {
      anchors.fill: parent
      anchors.margins: parent.borderWidth
      color: TibiaStyle.textFieldBackgroundColor
    }

    TibiaScrollView {
      anchors.fill: parent
      anchors.margins: parent.borderWidth
      anchors.leftMargin: parent.borderWidth + TibiaStyle.containerSlotsMargin

      GridView {
        id: itemsGridView
        property var _helperModel: null

        topMargin: TibiaStyle.containerSlotsMargin
        bottomMargin: TibiaStyle.containerSlotsMargin

        cellWidth: TibiaStyle.containerSlotSize + TibiaStyle.containerSlotsMargin
        cellHeight: cellWidth

        interactive: false //prevent flick behavior on touch screens
        boundsBehavior: Flickable.StopAtBounds

        cacheBuffer: contentHeight //for smooth scrolling

        footer: Item {
          height: TibiaStyle.containerSlotsMargin
        } //header: Item

        model: itemsModel

        onModelChanged: {
          if (model != null) {
            _helperModel = AbstractItemModelHelper.wrapInHelperProxyModel(model);
          } else {
            _helperModel = null;
          }
        }

        onCurrentItemChanged: {
          if (_helperModel) {
            var modelData = _helperModel.sourceItemDataByRowIndex(currentIndex);
            if (modelData) {
              root.selectedAppearanceTypeID = modelData.id;
              root.selectedUpgradeTier = modelData.upgradetier;
            } else {
              root.selectedAppearanceTypeID = -1;
              root.selectedUpgradeTier = 0;
            }
          }
        }

        delegate: ContainerSlot {
          property string tooltipText: {
            var tooltip = model.name;
            if (model.description != "") {
              tooltip = tooltip + "<br/>" + model.description;
            }
            return tooltip;
          }

          showPointingHandCursor: true
          slotID:  model.id
          mouseAreaEnabled: true
          slotText: TextHelper.formatNumberWithThousandSeparatorsAndThousandShortcutsAsMultiString(model.amount)
          slotTooltip: tooltipText
          objectAppearanceInstanceTypeId:  model.id
          objectAppearanceInstanceCumulativeCount: model.amount
          objectAppearanceInstanceUpgradeTier: model.upgradetier
          showSelectionBorder: itemsGridView.currentIndex == index;
          onClicked: {
            itemsGridView.currentIndex = index;
          }
          onDoubleClicked: {
            if (tibiaMouseCursorController != null) {
              tibiaMouseCursorController.setPointingHand(false);
              containsMouse = false;
            }
            itemSelected();
          }
        } //delegate: ContainerSlot
      } // GridView
    }
  }

}
