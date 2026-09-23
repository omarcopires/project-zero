import QtQuick
import QtQuick.Layouts

import qmlcomponents


FocusScope {
  id: root
  implicitWidth: 100
  implicitHeight: TibiaStyle.buttonHeightDefault

  property alias text: searchTextField.text
  property alias shouldBeText: searchTextField.shouldBeText
  property alias maximumLength: searchTextField.maximumLength
  property string searchText: ""

  function clearSearch() {
    searchTextField.text = '';
    searchText = '';
  }

  signal escPressedInSearchTextField()

  TibiaFrame1PixelDown {
    id: visualRoot
    anchors.fill:  parent

    RowLayout {
      anchors.fill: parent
      spacing: 0

      TibiaTextField {
        id: searchTextField
        Layout.fillWidth: true
        Layout.fillHeight: true
        KeyNavigation.tab: root.KeyNavigation.tab
        KeyNavigation.backtab: root.KeyNavigation.backtab
        placeholderText: qsTrId("type_to_search_placeholder")
        maximumLength: TibiaStyle.maxTextFieldDefaultLength
        focus: true

        onTextChanged: {
          filterRefreshTimer.restart();
        } //onTextChanged

        Keys.onPressed: (event) => {
          if (focus && event.key == Qt.Key_Escape) {
            root.escPressedInSearchTextField()
            // Intentionally do not accept event to propagate further up
          }
        }

        Timer {
          id: filterRefreshTimer
          interval: TibiaStyle.searchDelay

          onTriggered: {
            if (root.searchText != searchTextField.text) {
              root.searchText = searchTextField.text;
            }
          } //onTriggered
        } //Timer
      } //TibiaTextField

      TibiaButton {
        Layout.topMargin: visualRoot.borderWidth
        Layout.bottomMargin: visualRoot.borderWidth
        Layout.rightMargin: visualRoot.borderWidth
        Layout.leftMargin: -visualRoot.borderWidth
        Layout.fillHeight: true
        Layout.preferredWidth: height
        imageSource: root.enabled ? "/images/icon-erase-small.png" : "/images/icon-erase-small-disabled.png"
        tooltipText: qsTrId("clear_search_tooltip")

        onClicked: {
          clearSearch();
        } //onClicked
      } //TibiaButton
    } //RowLayout
  } //TibiaFrame1PixelDown
} //FocusScope
