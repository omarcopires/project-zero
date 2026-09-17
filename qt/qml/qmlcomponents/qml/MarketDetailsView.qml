import QtQuick
import QtQuick.Layouts



ColumnLayout {
  property var controller: null
  property var itemDetailsModel: ""
  property var itemStatisticsModel: ""

  Layout.alignment: Qt.AlignTop
  Layout.fillWidth: true
  Layout.fillHeight: true
  spacing: TibiaStyle.marginUnrelated

  TibiaText {
    text: qsTrId("market_details")
    styleType: "Dialog"
  }

  TibiaTextArea {
    id: itemStatText
    Layout.fillWidth: true
    Layout.fillHeight: true
    readOnly: true
    text: itemDetailsModel
  }

  TibiaText {
    text: qsTrId("market_statistics")
    styleType: "Dialog"
  }

  TibiaTextArea {
    Layout.fillWidth: true
    Layout.fillHeight: true
    readOnly: true
    text: itemStatisticsModel
  }

  Item {
    Layout.fillHeight: true
  }

  Loader {
    sourceComponent: controller != null && controller.showStoreDeeplink ? storeButtonComponent: undefined
    Layout.preferredWidth: TibiaStyle.buttonWidthWider
    Component {
      id: storeButtonComponent
      TibiaButton {
        imageSource: "/images/icon-tibiastore.png"
        imageAnchor: "left"
        text: qsTrId("market_open_store").arg(
          controller != null ? controller.selectedCategoryName : qsTrId("dummy_unknown"));
        color: "blue"
        textXOffset: TibiaStyle.marginUnrelated

        onClicked: {
          if (controller != null) {
            controller.onStoreDeeplinkClicked();
          }
        }
      } // TibiaButton
    }
  }

} // ColumnLayout
