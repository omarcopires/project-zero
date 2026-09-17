import QtQuick
import QtQuick.Layouts

import qmlcomponents
import "qrc:/qt/qml/qmlcomponents/qml/"


TibiaPanelWithCaption {
  id: root

  signal pickAuctionEndTime()
  signal pickMinimumBid()
  signal pickItem()
  signal pickHighlight()
  signal removeItem(int appearanceTypeID, int upgradeTier)
  signal removeHighlight(int highlightID)

  signal acceptMinimumBid()

  readonly property int cMAXIMUM_HIGHLIGHT_COUNT: 5
  readonly property int cMAXIMUM_ITEMS_COUNT: 4

  property var     characterData: null

  property string  characterName:       characterData != null ? characterData.characterName : ""
  property string  characterVocation: characterData != null ? characterData.characterVocation : ""
  property int     characterLevel:      characterData != null ? characterData.characterLevel : 0
  property string  characterWorldType:  characterData != null ? characterData.characterWorldType : ""

  property var     characterOverviewItemsModel: []
  property var     characterOverviewHighlightsModel: []
  property var     auctionConfiguration: null

  property int     minimumBid: auctionConfiguration != null ? auctionConfiguration.minimumBid : 0

  property int     minimumMinimumBid: auctionConfiguration != null ? auctionConfiguration.minimumMinimumBid : 0
  property int     auctionEndTimestamp: auctionConfiguration != null ? auctionConfiguration.auctionEndTimestamp : 0
  property int     selectedHighlightsCount: auctionConfiguration != null ? auctionConfiguration.selectedHighlightCount : 0
  property int     selectedItemsCount: auctionConfiguration != null ? auctionConfiguration.selectedItemCount : 0
  property bool    hasConfigurationError: contentItem != null ? contentItem.minimumBidTextFieldAcceptableInput == false : true

  Layout.fillWidth: true
  Layout.alignment: Qt.AlignTop
  expanded: true
  collapsible: false

  caption: qsTrId("charactertrade_character_overview_caption")
              .arg(characterName)
              .arg(characterLevel)
              .arg(characterVocation)
              .arg(characterWorldType)

  contentDelegate: ColumnLayout {
    property alias minimumBidTextFieldAcceptableInput: minimumBidTextField.acceptableInput
    RowLayout {
      OutfitAppearanceInstanceRenderer {
        id: outfitAppearanceInstanceRenderer2
        Layout.preferredWidth: TibiaStyle.mapWindowPixelPerField * 2
        Layout.preferredHeight: TibiaStyle.mapWindowPixelPerField * 2
        Layout.alignment: Qt.AlignHCenter
        scaleFactor: 1.0
        moving: true

        outfitId: characterData != null && characterData.outfitConfiguration != null ? characterData.outfitConfiguration.id : 0
        headColor: characterData != null && characterData.outfitConfiguration != null ? characterData.outfitConfiguration.headColor : "black"
        torsoColor: characterData != null && characterData.outfitConfiguration != null ? characterData.outfitConfiguration.torsoColor : "black"
        legsColor: characterData != null && characterData.outfitConfiguration != null ? characterData.outfitConfiguration.legsColor : "black"
        detailColor: characterData != null && characterData.outfitConfiguration != null ? characterData.outfitConfiguration.detailColor : "black"
        firstAddOn: characterData != null && characterData.outfitConfiguration != null ? characterData.outfitConfiguration.firstAddOn : false
        secondAddOn: characterData != null && characterData.outfitConfiguration != null ? characterData.outfitConfiguration.secondAddOn : false
      } //OutfitAppearanceInstanceRendere

      GridLayout {
        columns: 2
        rows: 2
        rowSpacing: TibiaStyle.marginNarrow
        columnSpacing: TibiaStyle.marginNarrow
        Layout.minimumWidth: 70
        Layout.minimumHeight: 70
        Repeater {
          model: characterOverviewItemsModel
          Item {
            width: 34
            height: 34
            RowLayout {
              id: containerSlotWrapper
              ContainerSlot {
                property string tooltipText: {
                  var tooltip = model.name;
                  if (model.description != "") {
                    tooltip = tooltip + "<br/>" + model.description;
                  }
                  return tooltip;
                }

                id: containerSlot
                slotID: model.id
                mouseAreaEnabled: true
                slotText: TextHelper.formatNumberWithThousandSeparatorsAndThousandShortcutsAsMultiString(model.amount)
                slotTooltip: tooltipText
                objectAppearanceInstanceTypeId:  model.id
                objectAppearanceInstanceUpgradeTier: model.upgradetier
                objectAppearanceInstanceCumulativeCount: model.amount

                TibiaButton {
                  id: deleteIcon
                  visible: parent.enabled
                  imageSource: "/images/icon-delete.png"
                  x: 1
                  y: 1
                  width: 12
                  height: 12

                  TibiaDisabledOverlay {
                    anchors.fill: parent
                    anchors.margins: 1
                    visible: !parent.enabled
                  }
                  onClicked: {
                    removeItem(containerSlot.objectAppearanceInstanceTypeId, containerSlot.objectAppearanceInstanceUpgradeTier);
                  }

                  Tooltip {
                    anchors.fill: parent
                    text: qsTrId("charactertrade_remove_item_tooltip")
                  }
                } // TibiaButton
              }
            }
          }
        }
        Repeater {
          model: Math.max(0, cMAXIMUM_ITEMS_COUNT - selectedItemsCount)
          TibiaButton {
            Layout.preferredWidth: 34
            Layout.preferredHeight: 34
            imageSource: "/images/skin/classic/icon-add.png"
            enabled: characterVocation != "None"
            onClicked: {
              pickItem();
            }
            TibiaDisabledOverlay {
              anchors.fill: parent
              anchors.margins: 1
              visible: !parent.enabled
            }
            Tooltip {
              anchors.fill: parent
              text: qsTrId("charactertrade_add_item_tooltip")
            }
          }
        }
      }
      GridLayout {
        id: auctionDetailsGridLayout

        columns: 1
        RowLayout {
          spacing: TibiaStyle.marginRelated
          TibiaText {
            Layout.rightMargin: 9 // just a dirty hack to have the textbox left alignining with the button in the next row
            textFormat: Text.RichText
            text: qsTrId("charactertrade_auction_start_bid_text")
          }
          TibiaTextField {
            id: minimumBidTextField
            property int currentMinimumBid: root.minimumBid
            onCurrentMinimumBidChanged: {
              text = currentMinimumBid.toString();
            }
            Layout.preferredWidth: 60
            color: acceptableInput ? (enabled ? TibiaStyle.white4 : TibiaStyle.textFieldDisabledTextColor) : TibiaStyle.red1
            validator: IntValidator {
              bottom: root.minimumMinimumBid;
              locale: "en_GB"
            }
            horizontalAlignment: Text.AlignRight
            onEditingFinished: {
              auctionConfiguration.minimumBid = parseInt(text);
              var newMinimumBidString = auctionConfiguration.minimumBid.toString();
              if (newMinimumBidString != text) {
                text = newMinimumBidString;
              }
              nextItemInFocusChain().forceActiveFocus();
            }
            onActiveFocusChanged: {
              readOnly = activeFocus == false;
            }
            Connections {
              target: root
              function onAcceptMinimumBid() {
                nextItemInFocusChain().forceActiveFocus();
              }
            }
            Tooltip {
              anchors.fill: parent
              text: qsTrId("charactertrade_tooltip_minimum_bid").arg(root.minimumMinimumBid)
            }
          }
          Image {
            source: "/images/icon-tibiacointransferable.png"
            Tooltip {
              anchors.fill: parent
              text: qsTrId("charactertrade_tooltip_minimum_bid").arg(root.minimumMinimumBid)
            }
          }
        }
        RowLayout {
          TibiaText {
            Layout.alignment: Qt.AlignTop
            textFormat: Text.RichText
            text: qsTrId("charactertrade_auction_end_time_text")
          }
          ColumnLayout {
            RowLayout {
              id: auctionEndTimestampLayout
              TibiaText {
                text: TextHelper.formatDateTime(root.auctionEndTimestamp, false)
                color: enabled ? TibiaStyle.white4 : TibiaStyle.textFieldDisabledTextColor
              }
              TibiaButton {
                Layout.preferredWidth: 12
                Layout.preferredHeight: 12
                imageSourceUp: "/images/icon-edit.png"

                onClicked: {
                  pickAuctionEndTime();
                } //onClicked
                TibiaDisabledOverlay {
                  anchors.fill: parent
                  anchors.margins: 1
                  visible: !parent.enabled
                }
              } // TibiaButton
            }
            TibiaText {
              text: TextHelper.formatDateTimeWithTimeZoneBerlin(root.auctionEndTimestamp, false)
            }
          }
        }

        Item {
          Layout.fillHeight: true
        }
      }
    }
    TibiaHorizontalSeparator {
    }
    ColumnLayout {
      id: highlightsColumnLayout
      spacing: TibiaStyle.marginNarrow
      Layout.alignment: Qt.AlignTop
      Repeater {
        model: characterOverviewHighlightsModel
        delegate: RowLayout {
          property int highlightID: model.highlightid
          spacing: TibiaStyle.marginRelated
          TibiaButton {
            Layout.preferredWidth: 12
            Layout.preferredHeight: 12
            imageSource: "/images/icon-delete.png"
            onClicked: {
              removeHighlight(highlightID);
            }
            TibiaDisabledOverlay {
              anchors.fill: parent
              anchors.margins: 1
              visible: !parent.enabled
            }
            Tooltip {
              anchors.fill: parent
              text: qsTrId("charactertrade_remove_highlight_tooltip")
            }
          }
          Image {
            Layout.preferredWidth: 10
            Layout.preferredHeight: 10
            source: model.categoryicon
          }
          TibiaText {
            Layout.fillWidth: true
            text: model.highlight
            color: enabled ? TibiaStyle.white4 : TibiaStyle.textFieldDisabledTextColor
          }
        }
      }
      Repeater {
        model: Math.max(0, cMAXIMUM_HIGHLIGHT_COUNT - selectedHighlightsCount)

        RowLayout {
          visible: selectedHighlightsCount < cMAXIMUM_HIGHLIGHT_COUNT
          TibiaButton {
            Layout.preferredWidth: 12
            Layout.preferredHeight: 12
            imageSource: "/images/skin/classic/icon-add-small.png"
            onClicked: {
              pickHighlight();
            }
            TibiaDisabledOverlay {
              anchors.fill: parent
              anchors.margins: 1
              visible: !parent.enabled
            }
            Tooltip {
              anchors.fill: parent
              text: qsTrId("charactertrade_add_highlight_tooltip")
            }
          }
          TibiaText {
            text: qsTrId("charactertrade_add_highlight").arg(selectedHighlightsCount + index + 1)
          }
        }
      }
    }
  }
}
