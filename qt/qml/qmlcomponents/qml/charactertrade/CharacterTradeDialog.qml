import QtQuick
import QtQuick.Layouts

import qmlcomponents
import "qrc:/qt/qml/qmlcomponents/qml/"

TibiaDialog {
  id: root
  caption: dialogCaption
  width: 780

  property var controller: null

  property var    characterData: controller != null ? controller.characterData : null
  property var    conditionsModel: controller != null ? controller.conditionsModel : null
  property bool   hasUnfulfilledConditions: controller != null ? controller.hasUnfulfilledConditions : true
  property var    highlightsModel: controller != null ? controller.highlightsModel : null
  property var    itemsModel: controller != null ? controller.itemsModel : null
  property var    confirmationsModel: controller != null ? controller.confirmationsModel : null
  property bool   hasConfirmationError: controller != null ? controller.hasConfirmationError : true

  property var    auctionConfiguration: controller != null ? controller.auctionConfiguration : null
  property var    characterOverviewHighlightsModel: controller != null ? controller.characterOverviewHighlightsModel : null
  property var    characterOverviewItemsModel: controller != null ? controller.characterOverviewItemsModel : null


  property var    dialogState: CharacterTradeEnums.DialogState.Conditions
  property var    configurationState: CharacterTradeEnums.ConfigurationState.None
  property string dialogCaption: qsTrId("charactertrade_dialog_caption").arg(1)

  property bool   hasConfigurationError: characterTradeOverview.hasConfigurationError

  onDialogStateChanged: {
    // reset configuration state
    configurationState = CharacterTradeEnums.ConfigurationState.None
    var dialogStateStep = 0;
    switch (dialogState) {
      case CharacterTradeEnums.DialogState.Conditions:
        dialogStateStep =  1;
        break;
      case CharacterTradeEnums.DialogState.Configuration:
        dialogStateStep =  2;
        break;
      case CharacterTradeEnums.DialogState.Confirmation:
        dialogStateStep =  3;
        break;
    }
    dialogCaption = qsTrId("charactertrade_dialog_caption").arg(dialogStateStep);
  }

  onCancelPressedFunction: function() {
    if (controller != null) {
      controller.requestClose();
    }
  }

  initialFocusItem: root

  Component {
    id: conditionsComponent
    CharacterTradeNotifications {
      infoText: qsTrId("charactertrade_conditions_hint_text")
      notificationsModel: root.conditionsModel
    }
  }
  Component {
    id: hintTextComponent
    CharacterTradeHintText { }
  }
  Component {
    id: auctionEndPickerComponent
    CharacterTradeAuctionEndDateTimePicker {
      minimumAuctionEndTimestamp: root.auctionConfiguration.minimumAuctionEndTimestamp
      maximumAuctionEndTimestamp: root.auctionConfiguration.maximumAuctionEndTimestamp
      auctionEndTimestamp: root.auctionConfiguration.auctionEndTimestamp
    }
  }
  Component {
    id: highlightPickerComponent
    CharacterTradeHighlightPicker {
      highlightsModel: root.highlightsModel
      filterString: "";
      Component.onCompleted: {
        root.highlightsModel.filterString = "";
      }

      onFilterStringChanged: {
        if (root.highlightsModel.filterString != filterString) {
          root.highlightsModel.filterString = filterString;
        }
      }
      onHighlightSelected: {
        if (controller) {
          if (selectedHighlightID > -1) {
            controller.addHighlight(selectedHighlightID);
          }
          configurationState = CharacterTradeEnums.ConfigurationState.None;
        }
      }
    }
  }
  Component {
    id: itemPickerComponent
    CharacterTradeItemPicker {
      itemsModel: root.itemsModel
      filterString: "";
      Component.onCompleted: {
        root.itemsModel.filterString = "";
      }

      onFilterStringChanged: {
        if (root.itemsModel.filterString != filterString) {
          root.itemsModel.filterString = filterString;
        }
      }
      onItemSelected: {
        if (controller) {
          if (selectedAppearanceTypeID > 0) {
            controller.addItem(selectedAppearanceTypeID, selectedUpgradeTier);
          }
          configurationState = CharacterTradeEnums.ConfigurationState.None;
        }
      }
    }
  }
  Component {
    id: confirmationComponent
    CharacterTradeNotifications {
      infoText: qsTrId("charactertrade_confirmation_hint_text")
      notificationsModel: root.confirmationsModel
    }
  }

  states: [
    State {
      name: "conditions"
      when: root.dialogState == CharacterTradeEnums.DialogState.Conditions
      PropertyChanges { target: lowerContentLoader; sourceComponent: conditionsComponent }
    },
    State {
      name: "hintText"
      when: root.dialogState == CharacterTradeEnums.DialogState.Configuration &&
            root.configurationState == CharacterTradeEnums.ConfigurationState.None
      PropertyChanges { target: lowerContentLoader; sourceComponent: hintTextComponent }
    },
    State {
      name: "pickAuctionEndTime"
      when: root.dialogState == CharacterTradeEnums.DialogState.Configuration &&
            root.configurationState == CharacterTradeEnums.ConfigurationState.AuctionEnd
      PropertyChanges { target: lowerContentLoader; sourceComponent: auctionEndPickerComponent }
      PropertyChanges { target: dialogButtonsWrapper; visible: false }
      PropertyChanges { target: actionButtonsWrapper; visible: true }
    },
    State {
      name: "pickHighlight"
      when: root.dialogState == CharacterTradeEnums.DialogState.Configuration &&
            root.configurationState == CharacterTradeEnums.ConfigurationState.Highlights
      PropertyChanges { target: lowerContentLoader; sourceComponent: highlightPickerComponent }
      PropertyChanges { target: dialogButtonsWrapper; visible: false }
      PropertyChanges { target: actionButtonsWrapper; visible: true }
    },
    State {
      name: "pickItem"
      when: root.dialogState == CharacterTradeEnums.DialogState.Configuration &&
            root.configurationState == CharacterTradeEnums.ConfigurationState.Items
      PropertyChanges { target: lowerContentLoader; sourceComponent: itemPickerComponent }
      PropertyChanges { target: dialogButtonsWrapper; visible: false }
      PropertyChanges { target: actionButtonsWrapper; visible: true }
    },
    State {
      name: "confirmation"
      when: root.dialogState == CharacterTradeEnums.DialogState.Confirmation
      PropertyChanges { target: nextButton; text: qsTrId("confirm"); isConfirmationButton: true }
      PropertyChanges { target: lowerContentLoader; sourceComponent: confirmationComponent }
    }
  ]

  ColumnLayout {
    id: buttonLayout
    spacing: TibiaStyle.marginRelated
    anchors { left: parent.left; top: parent.top; right: parent.right;}
    height: 492 // this should be the same height as the store dialog

    CharacterTradeCharacterOverview {
      id: characterTradeOverview
      characterData: root.characterData
      auctionConfiguration: root.auctionConfiguration
      characterOverviewHighlightsModel: root.characterOverviewHighlightsModel
      characterOverviewItemsModel: root.characterOverviewItemsModel
      visible: root.dialogState != CharacterTradeEnums.DialogState.Conditions

      enabled: root.dialogState == CharacterTradeEnums.DialogState.Configuration &&
               root.configurationState == CharacterTradeEnums.ConfigurationState.None

      onPickMinimumBid: {
        if (configurationState == CharacterTradeEnums.ConfigurationState.None) {
          configurationState = CharacterTradeEnums.ConfigurationState.MinimumBid;
        }
      }
      onPickAuctionEndTime: {
        if (configurationState == CharacterTradeEnums.ConfigurationState.None) {
          configurationState = CharacterTradeEnums.ConfigurationState.AuctionEnd;
        }
      }
      onPickHighlight: {
        if (configurationState == CharacterTradeEnums.ConfigurationState.None) {
          configurationState = CharacterTradeEnums.ConfigurationState.Highlights;
        }
      }
      onRemoveHighlight: (highlightID) => {
        if (controller && configurationState == CharacterTradeEnums.ConfigurationState.None) {
          controller.removeHighlight(highlightID);
        }
      }
      onPickItem: {
        if (configurationState == CharacterTradeEnums.ConfigurationState.None) {
          configurationState = CharacterTradeEnums.ConfigurationState.Items;
        }
      }
      onRemoveItem: (appearanceTypeID, upgradeTier) => {
        if (controller && configurationState == CharacterTradeEnums.ConfigurationState.None) {
          controller.removeItem(appearanceTypeID, upgradeTier);
        }
      }
    }

    TibiaFrame2PixelUpFilled {
      Layout.fillWidth: true
      Layout.fillHeight: true

      Loader {
        id: lowerContentLoader
        anchors.fill: parent
        anchors.margins: parent.borderWidth + TibiaStyle.marginRelated
      } // Loader
    }

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } // TibiaHorizontalSeparator

    RowLayout {
      id: buttonBar
      Layout.fillWidth: true
      spacing: TibiaStyle.marginRelated

      TibiaCurrentBalanceView {
        Layout.preferredWidth: TibiaStyle.currencyViewWidth
        balanceType: "TibiaCoinTransferable"
      } //TibiaCurrentBalanceView

      Item {
        // Padding
        Layout.fillWidth: true
        height: 1
      }

      RowLayout {
        id: actionButtonsWrapper
        spacing: TibiaStyle.marginRelated
        visible: false
        TibiaButton {
          id: okButton
          Layout.preferredWidth: TibiaStyle.buttonWidthBroad
          text: qsTrId("ok")
          onClicked: {
            if (lowerContentLoader.item) {
              if (configurationState == CharacterTradeEnums.ConfigurationState.Highlights) {
                var highlightID = lowerContentLoader.item.selectedHighlightID;
                if (highlightID > -1) {
                  controller.addHighlight(highlightID);
                }
              } else if (configurationState == CharacterTradeEnums.ConfigurationState.Items) {
                var selectedAppearanceTypeID = lowerContentLoader.item.selectedAppearanceTypeID;
                var selectedUpgradeTier = lowerContentLoader.item.selectedUpgradeTier;
                if (selectedAppearanceTypeID > 0) {
                  controller.addItem(selectedAppearanceTypeID, selectedUpgradeTier);
                }
              } else if (configurationState == CharacterTradeEnums.ConfigurationState.AuctionEnd) {
                root.auctionConfiguration.auctionEndTimestamp = lowerContentLoader.item.selectedAuctionEndTimestamp;
              }
            }
            configurationState = CharacterTradeEnums.ConfigurationState.None;
          }
        } // TibiaButton
        TibiaButton {
          id: cancelButton
          Layout.preferredWidth: TibiaStyle.buttonWidthBroad
          text: qsTrId("cancel")
          onClicked: {
            configurationState = CharacterTradeEnums.ConfigurationState.None;
          }
        } // TibiaButton
      }
      RowLayout {
        id: dialogButtonsWrapper
        spacing: TibiaStyle.marginRelated
        visible: true

        states: [
          State {
            name: "conditions"
            when: root.dialogState == CharacterTradeEnums.DialogState.Conditions
            PropertyChanges { target: previousButton; enabled: false }
            PropertyChanges { target: nextButton; enabled: hasUnfulfilledConditions == false }
          },
          State {
            name: "configuration"
            when: root.dialogState == CharacterTradeEnums.DialogState.Configuration
            PropertyChanges { target: nextButton; enabled: characterTradeOverview.hasConfigurationError == false}
          },
          State {
            name: "confirmation"
            when: root.dialogState == CharacterTradeEnums.DialogState.Confirmation
            PropertyChanges { target: nextButton; enabled: controller.hasConfirmationError == false && characterTradeOverview.hasConfigurationError == false}
          }
        ]

        TibiaButton {
          id: previousButton
          Layout.preferredWidth: TibiaStyle.buttonWidthBroad
          text: qsTrId("previous")
          onClicked: {
            if (root.dialogState == CharacterTradeEnums.DialogState.Configuration) {
              characterTradeOverview.acceptMinimumBid(); // this is needed so that the focus is lost and the value is written back
              root.dialogState = CharacterTradeEnums.DialogState.Conditions
              if (controller) {
                controller.requestConditions();
              }
            } else if (root.dialogState == CharacterTradeEnums.DialogState.Confirmation) {
              root.dialogState = CharacterTradeEnums.DialogState.Configuration
            }
          }
        }
        TibiaButton {
          id: nextButton
          property bool isConfirmationButton: false
          color: isConfirmationButton && enabled ? "blue" : "grey"
          Layout.preferredWidth: TibiaStyle.buttonWidthBroad
          text: qsTrId("next")
          onClicked: {
            if (root.dialogState == CharacterTradeEnums.DialogState.Conditions) {
              root.dialogState = CharacterTradeEnums.DialogState.Configuration
            } else if (root.dialogState == CharacterTradeEnums.DialogState.Configuration) {
              characterTradeOverview.acceptMinimumBid(); // this is needed so that the focus is lost and the value is written back
              controller.requestCheckConfiguration();
              root.dialogState = CharacterTradeEnums.DialogState.Confirmation
            } else if (root.dialogState == CharacterTradeEnums.DialogState.Confirmation) {
              controller.requestConfirmConfiguration();
            }
          }
        }
        TibiaButton {
          id: closeButton
          Layout.preferredWidth: TibiaStyle.buttonWidthBroad
          text: qsTrId("cancel")
          onClicked: onCancelPressedFunction()
        }
      }
    } // RowLayout
  } // ColumnLayout


}
