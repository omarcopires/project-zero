import QtQuick
import QtQuick.Layouts

import qmlcomponents


TibiaSidebarPanel {
  id: premiumPanel

  property bool maximized: panelController != null && panelController.isMaximized
  property bool highlight: panelController != null && panelController.highlightMaximizeButton

  ColumnLayout {
    id: premiumFeaturesRegion
    anchors.left: parent.left
    anchors.right: parent.right
    spacing: TibiaStyle.marginRelated

    states: [
      State {
        when: premiumPanel.maximized
        name: "MAXIMIZED"
        PropertyChanges { target: premiumFeatureList; visible: true }
        PropertyChanges { target: minButton; visible: true }
        PropertyChanges { target: maxButton; visible: false }
      } //State MAXIMIZED
    ] //states

    RowLayout {
      Layout.fillWidth: true
      spacing: 4

      Image {
        source: "/images/skin/classic/pic-premium.png"
      } //Image

      TibiaText {
        Layout.fillWidth: true
        text: qsTrId("premium_features_caption")
      } //TibiaText

      TibiaIconButton {
        id: minButton
        sourceUp:   "/images/skin/classic/min-button-small-up.png"
        sourceDown: "/images/skin/classic/min-button-small-down.png"
        tooltipText: qsTrId("hide_premium_features_tooltip")
        onClicked: {
          if (panelController != null) {
            panelController.minimizePanel();
          } else {
            premiumFeaturesRegion.state = "";
          }
        } //onClicked
        visible: false
      } //TibiaIconButton

      TibiaIconButton {
        id: maxButton
        sourceUp:  highlight ? "/images/skin/classic/max-button-small-highlight-up.png"
                             : "/images/skin/classic/max-button-small-up.png"
        sourceDown: highlight ? "/images/skin/classic/max-button-small-highlight-down.png"
                              : "/images/skin/classic/max-button-small-down.png"
        tooltipText: qsTrId("show_premium_features_tooltip")
        onClicked: {
          if (panelController != null) {
            panelController.maximizePanel();
          } else {
            premiumFeaturesRegion.state = "MAXIMIZED";
          }
        }//onClicked
      } //TibiaIconButton
    } //RowLayout

    TibiaFrame1PixelDown {
      id: premiumFeatureList
      Layout.fillWidth: true
      Layout.preferredHeight: messagesLayout.height + 2*(borderWidth + TibiaStyle.marginNarrow)
      visible: false

      ColumnLayout {
        id: messagesLayout
        anchors {left: parent.left; top: parent.top; right: parent.right}
        anchors.margins: parent.borderWidth
        anchors.topMargin: parent.borderWidth + TibiaStyle.marginNarrow

        Repeater{
          model:  panelController != null ? panelController.premiumMessages : []

          ColumnLayout { //delegate
            id: delegateRoot
            Layout.fillWidth: true

            spacing: TibiaStyle.marginNarrow

            TibiaHorizontalSeparator {
              Layout.fillWidth: true
              visible: index != 0
            } //TibiaHorizontalSeparator

            RowLayout {
              Layout.fillWidth: true
              Layout.leftMargin: TibiaStyle.marginNarrow
              Layout.rightMargin: TibiaStyle.marginNarrow
              spacing: TibiaStyle.marginNarrow

              Image {
                source: modelData.imageUrl
              } //Image

              TibiaText {
                Layout.fillWidth: true
                text: modelData.message
                wrapMode: Text.Wrap
              } //TibiaText
            } //RowLayout

          } //ColumnLayout delegate
        }//Repeater
      } //ColumnLayout
    } //TibiaFrame1PixelDown
  } //ColumnLayout
} //TibiaSidebarPanel
