import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

import qmlcomponents

TibiaDialog {
  id: root

  caption: qsTrId("weapon_proficiency_shape_dialog_caption")
  width: 500

  initialFocusItem: root
  KeyNavigation.tab: root
  KeyNavigation.backtab: root

  required property var controller

  onCancelPressedFunction: function() {
    if (controller != null) {
      controller.requestClose();
    }
  } //onCancelPressedFunction


  ColumnLayout {
    id: mainLayout
    anchors { left: parent.left; right: parent.right; }
    spacing: TibiaStyle.marginUnrelated

    RowLayout {
      spacing: TibiaStyle.marginUnrelated

      TibiaFrame2PixelUpFilledWithCaption {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredHeight: selectedLayout.height + marginsToContent + topMarginToContent

        caption: root.controller.selectedPerk.perkName

        ColumnLayout {
          id: selectedLayout
          anchors { left: parent.left; top: parent.top; right: parent.right; }
          anchors.margins: parent.marginsToContent
          anchors.topMargin: parent.topMarginToContent

          spacing: TibiaStyle.marginUnrelated

          TibiaProficiencyPerk {
            Layout.alignment: Qt.AlignHCenter

            imageSource: root.controller.selectedPerk.imageSource
            hasAugmentEffect: root.controller.selectedPerk.hasAugmentEffect
            augmentEffectImageSource: root.controller.selectedPerk.augmentEffectImageSource
            isShaped: true
            perkRank: root.controller.selectedPerk.perkRank
            isActive: true
          } //ProficiencyPerk

          TibiaTextArea {
            id: infoTextArea
            Layout.fillWidth: true
            Layout.preferredHeight: buttonLayout.height
            verticalScrollBarPolicy: ScrollBar.AlwaysOff
            readOnly: true

            property string hoverText: "";

            text: "%1\n\n%2"
              .arg(root.controller.selectedPerk.perkDescription)
              .arg(hoverText)

            function setHoverText(newHoverText) {
              hoverText = newHoverText;
            } //function setHoverText

            function resetHoverText() {
              setHoverText("");
            } //unction resetHoverText
          } //TibiaTextArea
        } //ColumnLayout
      } //TibiaFrame2PixelUpFilledWithCaption

      TibiaFrame2PixelUpFilled {
        Layout.preferredWidth: 180
        Layout.fillHeight: true

        ColumnLayout {
          id: actionLayout
          anchors { left: parent.left; top: parent.top; right: parent.right; bottom: parent.bottom}
          anchors.margins: parent.marginsToContent

          spacing: TibiaStyle.marginUnrelated

          ///////////////////////////////////////////
          // FORGE image
          Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Image {
              anchors.centerIn: parent
              source: "/images/proficiency/icon_forge.png"
              width: sourceSize.width * 2
              height: sourceSize.height * 2
              smooth: false
            } //Image

            TibiaButton {
              anchors {top: parent.top; right: parent.right }
              width: 30
              height: width

              imageSourceUp: "/images/icon-info-list.png"
              tooltipText: qsTrId("weapon_proficiency_shape_dialog_show_all_options")

              onClicked: root.controller.onShowShapeOptionsClicked()
            } //TibiaButton
          } //Item

          GridLayout {
            id: buttonLayout
            Layout.fillWidth: true

            columns: 3
            rowSpacing: TibiaStyle.marginRelated
            columnSpacing: TibiaStyle.marginRelated

            ///////////////////////////////////////////
            // REFINE action
            Item {
              Layout.fillWidth: true
              Layout.preferredHeight: TibiaStyle.buttonHeightHigh

              TibiaButton {
                anchors.fill: parent
                textFont: TibiaStyle.defaultTextFont
                enabled: root.controller.refinePossible
                text: qsTrId("weapon_proficiency_shape_dialog_refine")

                onClicked: root.controller.onRefineClicked()

                HoverHandler {
                  onHoveredChanged: {
                    if (hovered) {
                      infoTextArea.setHoverText(root.controller.refineHoverText)
                    } else {
                      infoTextArea.resetHoverText();
                    }
                  } //onHoveredChanged
                } //HoverHandler
              } //TibiaButton

              Tooltip {
                anchors.fill: parent
                enabled: !root.controller.refinePossible
                text: root.controller.refineTooltip
              } //Tooltip
            } //Item

            TibiaCurrencyView {
              Layout.preferredWidth: TibiaStyle.currencyViewWidthShort
              Layout.preferredHeight: TibiaStyle.buttonHeightHigh
              iconId: "Dust"
              balance: root.controller.refinePrice > 0 ? root.controller.refinePrice : "-"
              tooLowBalance: root.controller.refinePriceToHigh
            } //TibiaCurrencyView

            TibiaGuiHelp {
              text: root.controller.refineGuiHelp
            } //TibiaGuiHelp

            ///////////////////////////////////////////
            // MAXIMISE action
            Item {
              Layout.fillWidth: true
              Layout.preferredHeight: TibiaStyle.buttonHeightHigh

              TibiaButton {
                anchors.fill: parent
                textFont: TibiaStyle.defaultTextFont
                enabled: root.controller.maximisePossible
                text: qsTrId("weapon_proficiency_shape_dialog_maximise")

                onClicked: root.controller.onMaximiseClicked()

                HoverHandler {
                  onHoveredChanged: {
                    if (hovered) {
                      infoTextArea.setHoverText(root.controller.maximiseHoverText)
                    } else {
                      infoTextArea.resetHoverText();
                    }
                  } //onHoveredChanged
                } //HoverHandler
              } //TibiaButton

              Tooltip {
                anchors.fill: parent
                enabled: !root.controller.maximisePossible
                text: root.controller.maximiseTooltip
              } //Tooltip
            } //Item

            TibiaCurrencyView {
              Layout.preferredWidth: TibiaStyle.currencyViewWidthShort
              Layout.preferredHeight: TibiaStyle.buttonHeightHigh
              iconId: "LunarAscensionOrbs"
              balance: root.controller.maximisePrice > 0 ? root.controller.maximisePrice : "-"
              tooLowBalance: root.controller.maximisePriceToHigh
            } //TibiaCurrencyView

            TibiaGuiHelp {
              text: root.controller.maximiseGuiHelp
            } //TibiaGuiHelp

            ///////////////////////////////////////////
            // RESHAPE action
            Item {
              Layout.fillWidth: true
              Layout.preferredHeight: TibiaStyle.buttonHeightHigh

              TibiaButton {
                anchors.fill: parent
                textFont: TibiaStyle.defaultTextFont
                enabled: root.controller.reshapePossible
                text: qsTrId("weapon_proficiency_shape_dialog_reshape")

                onClicked: root.controller.onReshapeClicked()
              } //TibiaButton

              Tooltip {
                anchors.fill: parent
                enabled: !root.controller.reshapePossible
                text: root.controller.reshapeTooltip
              } //Tooltip
            } //Item

            TibiaCurrencyView {
              Layout.preferredWidth: TibiaStyle.currencyViewWidthShort
              Layout.preferredHeight: TibiaStyle.buttonHeightHigh
              iconId: "Dust"
              balance: root.controller.reshapePrice > 0 ? root.controller.reshapePrice : "-"
              tooLowBalance: root.controller.reshapePriceToHigh
            } //TibiaCurrencyView

            TibiaGuiHelp {
              text: root.controller.reshapeGuiHelp
            } //TibiaGuiHelp

            ///////////////////////////////////////////
            // CLEAR action
            TibiaButton {
              Layout.fillWidth: true
              Layout.preferredHeight: TibiaStyle.buttonHeightHigh
              Layout.columnSpan: parent.columns -1
              textFont: TibiaStyle.defaultTextFont
              text: qsTrId("clear")

              onClicked: root.controller.onClearClicked()
            } //TibiaButton

            TibiaGuiHelp {
              text: qsTrId("weapon_proficiency_shape_dialog_clear_general_information")
            } //TibiaGuiHelp
          } //GridLayout
        } //ColumnLayout
      } //TibiaFrame2PixelUpFilledWithCaption

    } //RowLayout


    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } // TibiaHorizontalSeparator

    RowLayout {
      spacing: TibiaStyle.marginUnrelated

      TibiaCurrentBalanceView {
        Layout.preferredWidth: TibiaStyle.currencyViewWidth
        balanceType: "Dust"
      } //TibiaCurrentBalanceView

      TibiaCurrentBalanceView {
        Layout.preferredWidth: TibiaStyle.currencyViewWidthShort
        balanceType: "LunarAscensionOrbs"
      } //TibiaCurrentBalanceView

      Item {
        // Padding
        Layout.fillWidth: true
        Layout.preferredHeight: 1
      } //Item

      TibiaButton {
        id: closeButton
        text: qsTrId("close")
        onClicked: root.onCancelPressedFunction()
      } //TibiaButton
    } // RowLayout
  } // ColumnLayout
} // TibiaDialog
