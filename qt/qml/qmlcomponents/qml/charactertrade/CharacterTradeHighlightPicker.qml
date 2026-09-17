import QtQuick
import QtQuick.Layouts

import qmlcomponents
import "qrc:/qt/qml/qmlcomponents/qml/"


ColumnLayout {
  id: root
  property var highlightsModel: null
  property int selectedHighlightID: 0
  property string filterString: ""

  signal highlightSelected()

  anchors.fill: parent
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
    Layout.fillWidth: true
    Layout.fillHeight: true
    Item {
      anchors.fill: parent
      anchors.margins: parent.borderWidth
      Rectangle {
        anchors.fill: parent
        color: TibiaStyle.textFieldBackgroundColor
      }

      TibiaScrollView {
        id: higlightsScrollView
        anchors.fill: parent
        ListView {
          id: higlightsListView
          
          property var _helperModel: null

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
                root.selectedHighlightID = modelData.highlightid;
              } else {
                root.selectedHighlightID = -1;
              }
            }
          }

          anchors.fill: parent
          anchors.margins: 2

          model: highlightsModel

          interactive: false //prevent flick behavior on touch screens
          pixelAligned : true
          boundsBehavior: Flickable.StopAtBounds
          spacing: 0
          highlightMoveDuration: 0
          highlightMoveVelocity: 0
          highlightFollowsCurrentItem: true

          section.property: "category" 
          section.delegate:
            Item {
              id: sectionComponent
              width: higlightsListView.width
              height: sectionLayout.height

              ColumnLayout {
                id: sectionLayout
                visible: true
                width: parent.width

                spacing: TibiaStyle.marginNarrow

                Item {
                  Layout.fillWidth: true
                  height: TibiaStyle.marginNarrow
                }

                TibiaText {
                  text: section
                  Layout.alignment: Qt.AlignCenter
                } // TibiaText

                TibiaHorizontalSeparator {
                  Layout.fillWidth: true
                } //TibiaHorizontalSeparator
                Item {
                  Layout.fillWidth: true
                  height: TibiaStyle.marginNarrow
                }
              } // ColumnLayout
            } // Item

          delegate: Rectangle {
            height: 16
            width: higlightsListView.width
            property bool isSelected: index == higlightsListView.currentIndex
            color: {
              if (isSelected) {
                return TibiaStyle.tableViewSelectionColor;
              } else if (index % 2 == 0) {
                return TibiaStyle.tableViewItemBackgroundColor;
              } else {
                return TibiaStyle.tableViewAlternateBackgroundColor;
              }
            }
            RowLayout {
              spacing: TibiaStyle.marginRelated
              anchors.fill: parent
              Image {
                Layout.preferredWidth: 10
                Layout.preferredHeight: 10
                source: model.categoryicon
              }
              TibiaText {
                id: text
                Layout.fillWidth: true
                text: model.highlight
                elide: Text.ElideRight
                color: isSelected ? TibiaStyle.white4 : TibiaStyle.textColors["Dialog"]
              } //TibiaText
            }
            MouseArea {
              anchors.fill: parent
              onClicked: {
                higlightsListView.currentIndex = index;
              }
              onDoubleClicked: {
                highlightSelected();
              }
            }
          }
          

          footer: Item {
             height: TibiaStyle.marginUnrelated
          }

          MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            z: parent.z -1
            onClicked: (mouse) => widgetController != null ? widgetController.onWidgetClicked( mouse.button, mouse.modifiers) : undefined
          } //MouseArea
        } //ListView
      }
    }
  }
}


