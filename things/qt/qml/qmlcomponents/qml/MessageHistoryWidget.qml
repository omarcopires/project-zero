import QtQuick
import QtQuick.Layouts



TibiaSidebarWidget {
  id: root

  caption: "Message History"
  picSource: "/images/skin/classic/pic-premium.png"
  initialContentHeight: 400

  readonly property string noNames: "For this to work adjust proto-files:\nput all 'option optimize_for = LITE_RUNTIME;' in comments"

  customButtonContainerData: [
    TibiaIconButton {
      id: optionsButton
      checkable: true
      enabled: root.maximized
      sourceUp:   "/images/skin/classic/button-expand-12x12-up.png"
      sourceDown: "/images/skin/classic/button-expand-12x12-down.png"
      useButtonShouldBeChecked: true
      buttonShouldBeChecked: widgetController != null && widgetController.optionsVisible
      onClicked: {
        if (widgetController != null) {
          widgetController.optionsVisible = !checked;
        }
      } //onClicked
    } //TibiaIconButton
  ] //customButtonContainerData

  ColumnLayout {
    anchors.fill: parent
    spacing: 0

    ColumnLayout {
      Layout.fillWidth: true
      Layout.bottomMargin: TibiaStyle.marginRelated
      spacing: TibiaStyle.marginRelated

      visible: widgetController != null && widgetController.optionsVisible

      TibiaCheckBox {
        text: "GS Messages"
        shouldBeChecked: widgetController!=null && widgetController.showGameServerMessages
        onCheckedChanged: {
          if (widgetController != null) {
            widgetController.showGameServerMessages = checked;
          }
        } //onCheckedChanged
      } //TibiaCheckBox

      TibiaCheckBox {
        text: "Client Messages"
        styleType: "Default"
        shouldBeChecked: widgetController!=null && widgetController.showClientMessages
        onCheckedChanged: {
          if (widgetController != null) {
            widgetController.showClientMessages = checked;
          }
        } //onCheckedChanged
      } //TibiaCheckBox

      TibiaCheckBox {
        text: "Show Ping"
        shouldBeChecked: widgetController!=null && widgetController.showPingMessages
        onCheckedChanged: {
          if (widgetController != null) {
            widgetController.showPingMessages = checked;
          }
        } //onCheckedChanged
      } //TibiaCheckBox

      RowLayout {
        TibiaCheckBox {
          Layout.fillWidth: true
          text: "Show Names"
          shouldBeChecked: widgetController!=null && widgetController.showMessasgeNames
          onCheckedChanged: {
            if (widgetController != null) {
              widgetController.showMessasgeNames = checked;
            }
          } //onCheckedChanged
        } //TibiaCheckBox

        TibiaGuiHelp {
          text: root.noNames
          color: "orange"
        } //TibiaGuiHelp
      } //RowLayout

      TibiaGuiHelp {
        text: "For Tooltip hover over ID\nClick Entry to copy it to clipboard"
      } //TibiaGuiHelp
    } //ColumnLayout

    TibiaScrollView {
      Layout.fillWidth: true
      Layout.fillHeight: true
      ListView {
        id: messageHistoryList

        model: widgetController != null ? widgetController.messageHistory : null
        clip: true

        boundsBehavior: Flickable.StopAtBounds
        interactive: false //prevent flick behavior on touch screens

        delegate: RowLayout {
          width: messageHistoryList.width - TibiaStyle.marginNarrow
          spacing: TibiaStyle.marginNarrow

          layoutDirection: model.isGsMessage ? Qt.LeftToRight : Qt.RightToLeft

          TibiaText {
            Layout.preferredWidth: 25

            text: model.messageType
            horizontalAlignment: model.isGsMessage ? Text.AlignLeft : Text.AlignRight
            tooltipText: model.tooltip

            styleType: model.isGsMessage ? "Dialog" : "Default"

            MouseArea {
              anchors.fill: parent
              acceptedButtons: Qt.LeftButton | Qt.RightButton

              onClicked: {
                if (widgetController != null) {
                  widgetController.onEntryClicked(model.tooltip);
                }
              } //onClicked
            } //MouseArea
          } //TibiaTex

          TibiaText {
            Layout.fillWidth: true
            horizontalAlignment: model.isGsMessage ? Text.AlignLeft : Text.AlignRight

            text: widgetController!=null && widgetController.showMessasgeNames
             ? model.name
             : ""

            styleType: model.isGsMessage ? "Dialog" : "Default"

            tooltipText: model.name == "?"
             ? root.noNames
             : model.tooltip

            MouseArea {
              anchors.fill: parent
              acceptedButtons: Qt.LeftButton | Qt.RightButton

              onClicked: {
                if (widgetController != null) {
                  widgetController.onEntryClicked(model.tooltip);
                }
              } //onClicked
            } //MouseArea
          } //TibiaText
        } //delegate: RowLayout
      } //ListView
    } //TibiaScrollView

  } //ColumnLayout
} //TibiaSidebarWidget
