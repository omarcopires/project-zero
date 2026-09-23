import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qmlcomponents
import QtQuick.LegacyControls



TibiaDialog {
  id: blessingsDialog
  caption: qsTrId("blessings_dialog_caption")
  width: 615

  required property var controller
  property var blessingsData: null

  Component.onCompleted: {
    blessingsData = controller.blessingsData;
  }

  onReturnPressedFunction: function() {
    if (controller != null) {
      controller.requestClose();
    }
  } // onReturnPressedFunction

  onCancelPressedFunction: function() {
    if (controller != null) {
      controller.requestClose();
    }
  } // onCancelPressedFunction

  initialFocusItem: blessingsDialog
  KeyNavigation.tab: blessingsDialog

  ColumnLayout {
    anchors { left: parent.left; top: parent.top; right: parent.right; }
    spacing: TibiaStyle.marginUnrelated
    width: blessingsFrame.width

    TibiaFrame2PixelUpFilledWithCaption {
      id: blessingsFrame
      caption: qsTrId("blessings_dialog_inventory_header")
      Layout.preferredHeight: blessingsInventory.height + captionHeight + TibiaStyle.marginUnrelated * 2
      Layout.fillWidth: true

      RowLayout {
        id: blessingsInventory
        spacing: TibiaStyle.marginRelated
        anchors { horizontalCenter: parent.horizontalCenter;
                  top: parent.top; topMargin: TibiaStyle.marginUnrelated + blessingsFrame.captionHeight }

        Repeater {
          model: blessingsData != null ? blessingsData.blessingsWithCharges : null

          // Each repeater item shows one blessing icon and its charges, or a store button if the charges count is zero.
          ColumnLayout {
            spacing: TibiaStyle.marginNarrow

            BorderImage {
              id: resourceBackground
              Layout.preferredWidth: 66
              Layout.preferredHeight: 66
              source: "/images/backdrop-dark-grey.png"
              horizontalTileMode: BorderImage.Repeat
              verticalTileMode: BorderImage.Repeat 

              TibiaFrame1PixelDown {
                anchors.fill: parent

                Image {
                  id: blessingImage
                  x: 1
                  y: 1
                  source: modelData.blessingImage
                } // Image

                BorderImage {
                  x: 1
                  y: 1
                  width: blessingImage.width
                  height: blessingImage.height
                  horizontalTileMode: BorderImage.Repeat
                  verticalTileMode: BorderImage.Repeat 
                  source: "/images/ditherpattern.png"
                  visible: modelData.blessingCharges == 0
                } // Image

                Tooltip {
                  anchors.fill: parent
                  text: modelData.blessingName
                } // Tooltip
              } //TibiaFrame1PixelDown
            } //Image

            TibiaCurrencyView {
              balance: qsTrId("blessings_dialog_charges_value").arg(modelData.blessingCharges).arg(modelData.blessingChargesFromStore)
              tooltipText: qsTrId("blessings_dialog_charges_tooltip").arg(modelData.blessingCharges).arg(modelData.blessingChargesFromStore)
              rightAligned: false
              iconId: ""
              Layout.preferredWidth: resourceBackground.width
              visible: modelData.blessingCharges > 0
            } // TibiaCurrencyView

            TibiaIconButton {
              sourceUp:   "/images/button-store-small-up.png"
              sourceDown: "/images/button-store-small-down.png"
              visible: modelData.blessingCharges == 0

              onClicked: {
                if (controller != null) {
                  controller.requestOpenStoreWithBlessingOffer(modelData.blessingId);
                }
              }
            } // TibiaIconButton
          } // ColumnLayout
        } // Repeater
      } // RowLayout
    } // TibiaFrame2PixelUpFilledWithCaption

    TibiaFrame2PixelUpFilledWithCaption {
      id: promotionFrame
      caption: qsTrId("blessings_dialog_promotion_header")
      Layout.fillWidth: true
      Layout.preferredHeight: captionHeight + premiumStatusButton.height + TibiaStyle.marginUnrelated * 2

      TibiaText {
        anchors { left: parent.left; leftMargin: TibiaStyle.marginUnrelated;
                  right: premiumStatusButton.left; rightMargin: TibiaStyle.marginUnrelated;
                  top: parent.top; topMargin: promotionFrame.captionHeight + TibiaStyle.marginUnrelated;
                  bottom: parent.bottom; bottomMargin: TibiaStyle.marginUnrelated; }
        text: blessingsData != null ? blessingsData.promotionLossReductionText : ""
        wrapMode: Text.Wrap
        verticalAlignment: Text.AlignVCenter
        textFormat: Text.StyledText
      }

      TibiaButton {
        id: premiumStatusButton
        property bool isPremium: blessingsData != null ? blessingsData.isPremium : false
        anchors { right: parent.right; rightMargin: TibiaStyle.marginUnrelated;
                  top: parent.top; topMargin: promotionFrame.captionHeight + TibiaStyle.marginUnrelated }
        width: TibiaStyle.premiumStateButtonWidth
        height: TibiaStyle.premiumStateButtonHeight

        checkable: isPremium
        checked: isPremium
        enabled: !isPremium
        color: isPremium ? "grey" : "blue"
        imageSource: isPremium ? "/images/imbuing/imbuing-icon-premium.png" : "/images/imbuing/imbuing-icon-nopremium.png"
        imageSourceDisabled: imageSource

        onClicked: {
          if (!checkable && controller != null) {
            controller.requestOpenStoreWithPremiumCategory();
          }
        }
      } // TibiaButton
    } // TibiaFrame2PixelUpFilledWithCaption

    TibiaFrame2PixelUpFilledWithCaption {
      id: deathPenaltyFrame
      caption: qsTrId("blessings_dialog_death_penalty_header")
      Layout.fillWidth: true
      Layout.preferredHeight: deathPenaltyTextBox.height + TibiaStyle.marginUnrelated * 2 + captionHeight

      ColumnLayout {
        id: deathPenaltyTextBox
        spacing: TibiaStyle.marginNarrow
        anchors { left: parent.left; leftMargin: TibiaStyle.marginUnrelated;
                  right: parent.right; rightMargin: TibiaStyle.marginUnrelated;
                  top: parent.top; topMargin: promotionFrame.captionHeight + TibiaStyle.marginUnrelated; }

        Repeater {
          model: blessingsData != null ? blessingsData.deathPenaltyText : null

          RowLayout {
            spacing: TibiaStyle.marginRelated

            TibiaText {
              text: "\u2022" // Bullet point
              Layout.alignment: Qt.AlignTop
            } // TibiaText

            TibiaText {
              text: modelData
              wrapMode: Text.Wrap
              textFormat: Text.StyledText
              Layout.fillWidth: true
            } // TibiaText
          } // RowLayout
        } // Repeater
      } // ColumnLayout
    } // TibiaFrame2PixelUpFilledWithCaption


    TibiaFrame2PixelUpFilledWithCaption {
      id: historyFrame
      caption: qsTrId("blessings_dialog_history_header")
      Layout.fillWidth: true
      Layout.preferredHeight: blessingsFrame.height + promotionFrame.height + deathPenaltyFrame.height + TibiaStyle.marginUnrelated * 2
      visible: false

      TibiaTableView {
        anchors { left: parent.left; leftMargin: TibiaStyle.marginUnrelated;
                  right: parent.right; rightMargin: TibiaStyle.marginUnrelated;
                  top: parent.top; topMargin: promotionFrame.captionHeight + TibiaStyle.marginUnrelated;
                  bottom: parent.bottom; bottomMargin: TibiaStyle.marginUnrelated }

        model: blessingsData != null ? blessingsData.blessingHistory : null
        headerVisible: true
        verticalScrollBarPolicy: ScrollBar.AlwaysOn
        horizontalScrollBarPolicy: ScrollBar.AsNeeded

        TableViewColumn { role: "timestamp"; title: qsTrId("date_column_header"); movable: false; resizable: false; width: 150 }
        TableViewColumn {
          role: "description"
          title: qsTrId("blessings_dialog_history_event_header")
          movable: false
          resizable: false
          width: 395

          delegate: TibiaText {
            text: styleData.value
            color: modelData != null && !modelData.blessingWasGained
              ? TibiaStyle.red1
              : styleData.selected
                ? TibiaStyle.textFieldSelectionTextColor
                : TibiaStyle.textFieldTextColor
            anchors.fill: parent
            anchors.leftMargin: TibiaStyle.marginNarrow
            anchors.rightMargin: TibiaStyle.marginNarrow
            elide: styleData.elideMode
            horizontalAlignment: styleData.textAlignment
          } // TibiaText
        } // TableViewColumn
      } // TibiaTableView
    } // TibiaFrame2PixelUpFilledWithCaption

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } // TibiaHorizontalSeparator

    RowLayout {
      spacing: TibiaStyle.marginRelated

      Item {
        // Padding
        Layout.fillWidth: true
        height: 1
      }

      TibiaButton {
        text: historyFrame.visible ? qsTrId("back") : qsTrId("history")

        onClicked: {
          // The order in which elements are made invisible/visible is important:
          // Unless elements are made invisible first, the dialog height temporarily increases,
          // which leads to an undesired repositioning of the dialog in y direction
          if (!historyFrame.visible) {
            blessingsFrame.visible = false;
            promotionFrame.visible = false;
            deathPenaltyFrame.visible = false;
            historyFrame.visible = true;
          } else {
            historyFrame.visible = false;
            blessingsFrame.visible = true;
            promotionFrame.visible = true;
            deathPenaltyFrame.visible = true;
          }
        } //onClicked
      } //TibiaButton

      TibiaButton {
        text: qsTrId("close")
        onClicked: onCancelPressedFunction()
      } // TibiaButton
    } // RowLayout
  }  // ColumnLayout
} // TibiaDialog
