import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtWebChannel
import QtWebEngine

import qmlcomponents
import "qrc:/qt/qml/qmlcomponents/qml/"
import QtQuick.LegacyControls

TibiaDialog {
  id: root
  caption: qsTrId("create_account_dialog_caption")
  initialFocusItem: eMailTextField
  width: 510
  movable: false

  required property QtObject controller

  property int accountCreationStage: 0
  property bool showPasswordAsPlainText: false
  property var mostRecentlySelectedWorld: null
  property bool recaptchaV2ViewAvailable: false
  property bool recaptchaV3ViewAvailable: false
  readonly property bool capsLock: controller.capsLock
  readonly property bool startPlayingProcessing: startPlayingButton.processing || controller.asyncStartPlayingInProgress

  readonly property bool showRecaptchaV2: controller.showRecaptchaV2
  readonly property string isWorldSelected: controller.selectedWorld != ""

  readonly property bool showPasswordRules: {
    return controller.passwordCriteria != null
      && controller.passwordCriteria.length > 0
      && accountCreationStage == 0
      && passwordTextField.activeFocus
      && passwordTextField.text.length > 0;
  }

  readonly property string currentDisplay: {
    if (controller.showRecaptchaV2) {
      return "RecaptchaV2";
    }

    if (accountCreationStage == 0) {
      return "FillForm";
    } else if (accountCreationStage == 1) {
      return "SelectWorld";
    }
  }

  onCancelPressedFunction: cancel

  onIsWorldSelectedChanged: {
    if( !isWorldSelected ) {
      worldSelection.selection.clear();
      worldSelection.currentIndex = -1;
    }
  } //onIsWorldSelectedChanged

  onShowPasswordRulesChanged: {
    updatePasswordHintPosition()
  }

  onXChanged: {
    updatePasswordHintPosition()
  }

  onYChanged: {
    updatePasswordHintPosition()
  }

  onHeightChanged: centerDialog()
  onWidthChanged: centerDialog()

  function updateWorldTableViewSelection(){
    worldSelection.updateWorldTableViewSelection();
  }

  function updatePasswordHintPosition(){
    if (showPasswordRules) {
      passwordHints.state = "reparented";

      let passwordHintsPosition = mapToItem(controller.tooltipContainer, root.width - 50, 100 );
      passwordHints.x = passwordHintsPosition.x
      passwordHints.y = passwordHintsPosition.y
    }
  }

  function getTibiaCheckIcon( checkValue ) {
    if (checkValue)
    {
      return "qrc:/images/icon-yes.png";
    }

    return "qrc:/images/icon-no.png";
  }

  function backFromWorldSelect() {
    controller.selectedWorld = mostRecentlySelectedWorld;
    accountCreationStage = 0;
  } //function backFromWorldSelect

  function cancel() {
    if (accountCreationStage == 1) {
      backFromWorldSelect();
    } else {
      controller.cancel();
    }
  } //function cancel

  function getBannerAccountDataImage() {
    if (controller.accountDataValid)
    {
      return "qrc:/images/banneraccountdatavalid.png";
    }

    return "qrc:/images/banneraccountdatainvalid.png";
  }

  function getBannerCharacterDataImage() {
    if (controller.allDataValid)
    {
      return "qrc:/images/banneralldatavalid.png";
    }

    return "qrc:/images/banneralldatainvalid.png";
  }

  function getBannerWorldDataImage() {
    if (controller.characterDataValid)
    {
      return "qrc:/images/bannercharacterdatavalid.png";
    }

    return "qrc:/images/bannercharacterdatainvalid.png";
  }

  component TibiaTextContainingHTMLLinks : TibiaText {
    textFormat: Text.RichText

    onLinkActivated: Qt.openUrlExternally(link)

    onLinkHovered: {
      if (tibiaMouseCursorController) {
        tibiaMouseCursorController.setPointingHand(link !== "")
      }
    }
  }

  Timer {
    id: updateEmailTimer
    interval: TibiaStyle.textAsyncValidationDealy
    running: false
    repeat: false
    onTriggered: {
      if( eMailTextField.text != null ) {
        controller.updateAccountEmail( eMailTextField.text );
      }
    }
  } //Timer

  Timer {
    id: updatePasswordTimer
    interval: TibiaStyle.textAsyncValidationDealy
    running: false
    repeat: false
    onTriggered: {
      if( (passwordTextField.text != null) && (passwordRepeatTextField.text!=null)){
        controller.updateAccountPasswords( passwordTextField.text, passwordRepeatTextField.text );
      }
    }
  } //Timer

  Timer {
    id: updateCharacterNameTimer
    interval: TibiaStyle.textAsyncValidationDealy
    running: false
    repeat: false
    onTriggered: {
      if( characterNameTextField.text != null){
        controller.updateCharacterName( characterNameTextField.text );
      }
    }
  } //Timer

  Timer {
    id: updateWorldTableViewSelectionTimer
    interval: 0
    running: false
    repeat: false
    onTriggered: {
      worldSelection.updateWorldTableViewSelection();
    }
  } //Timer

  ColumnLayout {
    id: rootLayout
    anchors { left: parent.left; right: parent.right; top: parent.top }
    spacing: TibiaStyle.marginRelated

    RowLayout {
      id: bannerArea
      visible: root.currentDisplay == "FillForm" || root.currentDisplay == "SelectWorld"
      Layout.alignment: Qt.AlignHCenter
      spacing: 0

      Image { source: "qrc:/images/bannerleft.png" }
      Image { source: getBannerAccountDataImage() }
      Image { source: getBannerCharacterDataImage() }
      Image { source: getBannerWorldDataImage() }
      Image { source: "qrc:/images/bannerright.png" }
    } //RowLayout

    ColumnLayout {
      id: accountAndCharacterCreation
      visible: root.currentDisplay == "FillForm"
      spacing: TibiaStyle.marginRelated

      TibiaPanel2PixelUpFilledWithCaption {
        id: createAccountPanel
        caption: qsTrId("create_account_caption");
        Layout.fillWidth: true
        Layout.fillHeight: true

        GridLayout {
          id: eMailAndPasswordGrid
          columns: 4
          columnSpacing: TibiaStyle.marginRelated
          rowSpacing: TibiaStyle.marginRelated

          TibiaText {
            Layout.preferredWidth: TibiaStyle.lableTextWidth
            text: qsTrId("email_address")
            horizontalAlignment: Text.AlignRight
          } //TibiaText

          TibiaTextField {
            id: eMailTextField
            KeyNavigation.tab: passwordTextField
            Layout.preferredWidth: TibiaStyle.textFieldWidth
            Layout.preferredHeight: TibiaStyle.buttonHeightDefault
            readOnly: root.startPlayingProcessing

            maximumLength: TibiaStyle.eMailAdressLength
            allowSpaces: false
            text: controller.accountEmail

            onTextChanged: {
              updateEmailTimer.restart();
            }
          } //TibiaTextField

          Image {
            id: emailStatusImage
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            source: getTibiaCheckIcon(controller.eMailDataValid)
          } //Image

          Item {
            Layout.fillWidth: true
          }

          // password row
          TibiaText {
            Layout.preferredWidth: TibiaStyle.lableTextWidth
            text: qsTrId("password")
            horizontalAlignment: Text.AlignRight
          } //TibiaText

          TibiaFrame1PixelDown {
            Layout.preferredWidth: TibiaStyle.textFieldWidth
            Layout.preferredHeight: TibiaStyle.buttonHeightDefault

            TibiaTextField {
              id: passwordTextField
              KeyNavigation.tab: passwordRepeatTextField
              text: controller.accountPassword
              echoMode: showPasswordAsPlainText ? TextInput.Normal: TextInput.Password
              readOnly: root.startPlayingProcessing

              anchors {
                top: parent.top;
                left: parent.left;
                bottom: parent.bottom;
                right: showPasswordTextFieldButton.left;
              }

              maximumLength: TibiaStyle.passwordLength

              onTextChanged: {
                updatePasswordTimer.restart();
              }
            } //TibiaTextField

            TibiaButton {
              id: showPasswordTextFieldButton
              anchors { top: parent.top; topMargin: parent.borderWidth;
                bottom: parent.bottom; bottomMargin: parent.borderWidth;
                right: parent.right; rightMargin: parent.borderWidth; }

              width: height
              tooltipText: qsTrId("create_account_dialog_password_show_tooltip")
              tooltipTextChecked: qsTrId("create_account_dialog_password_hide_tooltip")
              imageSource: "/images/icon-viewers.png"
              checkable: true
              useButtonShouldBeChecked: true
              buttonShouldBeChecked: showPasswordAsPlainText

              onClicked: {
                  showPasswordAsPlainText = !checked
              }
            } //TibiaButton
          } //TibiaFrame1PixelDown

          Image {
            id: passwordStatusImage
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            source: getTibiaCheckIcon( controller.passwordValid )
          } //Image

          TibiaText {
            Layout.fillWidth: true
            id: passwordStrengthText
            text: controller.passwordStrength
            color: controller.passwordStrengthColor
          } //TibiaText

          // password repeat row
          TibiaText {
            Layout.preferredWidth: TibiaStyle.lableTextWidth
            text: qsTrId("repeat_password")
            horizontalAlignment: Text.AlignRight
          } //TibiaText

          TibiaFrame1PixelDown {
            z: -1
            Layout.preferredWidth: TibiaStyle.textFieldWidth
            Layout.preferredHeight: TibiaStyle.buttonHeightDefault

            TibiaTextField {
              id: passwordRepeatTextField
              KeyNavigation.tab: termsAndServicesCheckBox
              text: controller.accountPasswordRepeat
              echoMode: showPasswordAsPlainText ? TextInput.Normal: TextInput.Password
              readOnly: root.startPlayingProcessing

              anchors {
                top: parent.top;
                left: parent.left;
                bottom: parent.bottom;
                right: showPasswordRepeatTextFieldButton.left;
              }

              maximumLength: TibiaStyle.passwordLength

              onTextChanged: {
                updatePasswordTimer.restart();
              }
            } //TibiaTextField

            TibiaButton {
              id: showPasswordRepeatTextFieldButton
              anchors { top: parent.top; topMargin: parent.borderWidth;
                bottom: parent.bottom; bottomMargin: parent.borderWidth;
                right: parent.right; rightMargin: parent.borderWidth; }

              width: height
              tooltipText: qsTrId("create_account_dialog_password_show_tooltip")
              tooltipTextChecked: qsTrId("create_account_dialog_password_hide_tooltip")
              imageSource: "/images/icon-viewers.png"
              checkable: true
              useButtonShouldBeChecked: true
              buttonShouldBeChecked: showPasswordAsPlainText

              onClicked: {
                  showPasswordAsPlainText = !checked
              }
            } //TibiaButton
          } //TibiaFrame1PixelDown

          Image {
            id: passwordRepeatStatusImage
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            source: getTibiaCheckIcon(controller.passwordValid && passwordTextField.text ==  passwordRepeatTextField.text)
          } //Image

          Item {
            Layout.fillWidth: true
          }

          // terms and services
          RowLayout {
            Layout.fillWidth: true
            Layout.columnSpan: 2
            spacing: 0

            Rectangle {
              Layout.fillWidth: true
            } //Item

            TibiaCheckBox {
              id: termsAndServicesCheckBox
              KeyNavigation.tab: personalizedAdsCheckBox
              shouldBeChecked: controller.termsAndServicesAccepted

              enabled: !root.startPlayingProcessing

              onCheckedChanged: {
                if (controller.termsAndServicesAccepted != checked) {

                  controller.setTermsAndServicesAccepted(checked);
                }
              }
            }

            TibiaTextContainingHTMLLinks {
              Layout.preferredWidth: 280
              text: qsTrId("create_account_dialog_terms_and_services_which_is_long_text")
              wrapMode: Text.Wrap
            } //TibiaText
          } //RowLayout

          Image {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            source: getTibiaCheckIcon(controller.termsAndServicesAccepted)
          } //Image

          Item {
            Layout.fillWidth: true
          }

          // personalized Ads
          RowLayout {
            Layout.fillWidth: true
            Layout.columnSpan: 2
            spacing: 0

            Rectangle {
              Layout.fillWidth: true
            } //Item

            TibiaCheckBox {
              id: personalizedAdsCheckBox
              KeyNavigation.tab: characterNameTextField
              shouldBeChecked: controller.personalizedAdsAccepted

              enabled: !root.startPlayingProcessing

              onCheckedChanged: {
                if (controller.personalizedAdsAccepted != checked) {

                  controller.setPersonalizedAdsAccepted(checked);
                }
              }
            }

            TibiaTextContainingHTMLLinks {
              Layout.preferredWidth: 280
              text: qsTrId("create_account_dialog_personalized_ads")
              wrapMode: Text.Wrap
            } //TibiaText
          }

          Item {
            Layout.columnSpan: 2            
            Layout.fillWidth: true
          }          
        } //GridLayout
      } //TibiaPanel2PixelUpFilledWithCaption

      TibiaPanel2PixelUpFilledWithCaption {
        id: createCharacterPanel
        caption: qsTrId("create_account_dialog_create_character_caption");
        Layout.fillWidth: true
        Layout.fillHeight: true

        GridLayout {
          id: characterAndWorldGrid
          columns: 3
          columnSpacing: TibiaStyle.marginRelated
          rowSpacing: TibiaStyle.marginRelated

          // Character name input
          RowLayout {
            spacing: TibiaStyle.marginRelated

            TibiaText {
              Layout.preferredWidth: TibiaStyle.lableTextWidth
              text: qsTrId("create_account_dialog_character_name_label")
              horizontalAlignment: Text.AlignRight
            }

            TibiaTextField {
              id: characterNameTextField
              KeyNavigation.tab: eMailTextField
              Layout.preferredWidth: TibiaStyle.textFieldWidth
              Layout.preferredHeight: TibiaStyle.buttonHeightDefault
              readOnly: root.startPlayingProcessing

              maximumLength: TibiaStyle.maxCharacterNameLength
              allowSpaces: true

              shouldBeText: controller.characterName

              onTextChanged: {
                if(controller.characterName != text) {
                  updateCharacterNameTimer.restart();
                }
              } //onTextChanged
            } //TibiaTextField
          } //RowLayout

          Image {
            id: characterNameStatusImage
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            source: getTibiaCheckIcon(controller.characterNameValid)
          } //Image

          TibiaButton {
            id: suggestNameButton
            Layout.preferredWidth: TibiaStyle.buttonWidthWider
            Layout.alignment: Qt.AlignHCenter
            text: qsTrId("create_account_dialog_suggest_create_account_dialog_character_name_label")

            onClicked: {
              if (!controller.asyncOperationInProgress
                  && !root.startPlayingProcessing ) {
                controller.suggestCharacterName();
              }
            }
          } //TibiaButton

          // Character sex input
          RowLayout {
            id: characterSexSelectionRowLayout
            spacing: TibiaStyle.marginRelated

            TibiaText {
              Layout.preferredWidth: TibiaStyle.lableTextWidth
              text: qsTrId("create_account_dialog_character_sex_label")
              horizontalAlignment: Text.AlignRight
            } //TibiaText

            RowLayout {
              id: sexRadioButtonsGroup
              Layout.preferredWidth: TibiaStyle.textFieldWidth
              spacing: TibiaStyle.marginRelated

              property bool isCharacterSexMale : controller.characterSexMale

              function setCharacterSexToMale(isMale) {
                if (controller.characterSexMale != isMale) {
                  controller.characterSexMale = isMale;
                }
              }

              TibiaRadioButton {
                id: maleRadioButton
                enabled: !root.startPlayingProcessing
                text: qsTrId("male")
                checked: sexRadioButtonsGroup.isCharacterSexMale
                onCheckedChanged: {
                  sexRadioButtonsGroup.setCharacterSexToMale(checked);
                }
              } //TibiaRadioButton

              TibiaRadioButton {
                id: femaleRadioButton
                enabled: !root.startPlayingProcessing
                text: qsTr("female")
                checked: !sexRadioButtonsGroup.isCharacterSexMale
                onCheckedChanged: {
                  sexRadioButtonsGroup.setCharacterSexToMale(!checked);
                }
              } //TibiaRadioButton
            } //RowLayout
          } //RowLayout

          Image {
            id: characterSexStatusImage
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            source: getTibiaCheckIcon( true )
          } //Image

          Item {
            Layout.fillWidth: true
          }

          // Character world input
          RowLayout {
            spacing: TibiaStyle.marginRelated

            TibiaText {
              Layout.preferredWidth: TibiaStyle.lableTextWidth
              text: qsTrId("create_account_dialog_character_world_label")
              horizontalAlignment: Text.AlignRight
            } //TibiaText

            TibiaText {
              property string selectedWorldText: {
                return controller.selectedWorld + " (" + controller.selectedWorldRegion + ")";
              }

              Layout.preferredWidth: TibiaStyle.textFieldWidth
              text: selectedWorldText
              horizontalAlignment: Text.AlignLeft
            } //TibiaText
          } //RowLayout

          Image {
            id: characterworldStatusImage
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            source: getTibiaCheckIcon(controller.selectedWorld != null)
          } //Image

          TibiaButton {
            id: changeWorldButton
            Layout.preferredWidth: TibiaStyle.buttonWidthWider
            Layout.alignment: Qt.AlignHCenter
            text: qsTrId("create_account_dialog_change_world_label")

            onClicked: {
              if (!root.startPlayingProcessing)
              {
                mostRecentlySelectedWorld = controller.selectedWorld

                accountCreationStage = 1;
                updateWorldTableViewSelection();
              }
            }
          } //TibiaButton
        } //GridLayout
      } //TibiaPanel2PixelUpFilledWithCaption

      TibiaHorizontalSeparator {
        Layout.fillWidth: true
      }

      RowLayout {
        id: buttonFooterAccountCreation
        spacing: TibiaStyle.marginUnrelated

        readonly property int decortionMargin: 6

        Layout.topMargin: decortionMargin
        Layout.rightMargin: decortionMargin
        Layout.bottomMargin: decortionMargin

        TibiaButton {
          id: cancelButton
          Layout.preferredWidth: TibiaStyle.buttonWidthWider
          text: qsTrId("create_account_dialog_already_registered")

          onClicked: cancel()
        } //TibiaButton

        Item {
          Layout.fillWidth: true
        }

        TibiaButton {
          id: startPlayingButton
          Layout.preferredWidth: TibiaStyle.buttonWidthWider
          text: qsTrId("create_account_dialog_start_playing")
          color: "green"
          enabled: controller.allDataValid && (controller.recaptchaDisabled || recaptchaV3ViewAvailable)

          property bool processing: false

          onClicked: {
            processing = true;
            if (!controller.asyncOperationInProgress) {
              if (controller.recaptchaDisabled) {
                controller.startPlaying(null, null);
                startPlayingButton.processing = false;
              } else if(recaptchaV3ViewAvailable) {
                recaptchaV3View.runJavaScript("(function(){ return window.v3Token })()", function(token) {
                  controller.startPlaying(null, token);
                  startPlayingButton.processing = false;
                  });
                recaptchaV3View.runJavaScript( "execCreateAccount()" );
              }
            }
          } //onClicked

          Image {
            source: "qrc:/images/button_startplaying_idle.png"
            x: -buttonFooterAccountCreation.decortionMargin
            y: -buttonFooterAccountCreation.decortionMargin
          } //Image

          Image {
            id: buttonHighlight
            anchors.centerIn: parent
            visible: controller.allDataValid

            SequentialAnimation {
              running: true
              loops: Animation.Infinite
              alwaysRunToEnd: true

              SequentialAnimation {
                loops: -1
                alwaysRunToEnd: true
                PropertyAnimation { target: buttonHighlight; property: "source"; to: "image://store-button-animation/0"; duration: 5000 } //wait 5sec
                PropertyAnimation { target: buttonHighlight; property: "source"; to: "image://store-button-animation/1"; duration: 50 }
                PropertyAnimation { target: buttonHighlight; property: "source"; to: "image://store-button-animation/2"; duration: 50 }
                PropertyAnimation { target: buttonHighlight; property: "source"; to: "image://store-button-animation/3"; duration: 50 }
                PropertyAnimation { target: buttonHighlight; property: "source"; to: "image://store-button-animation/4"; duration: 20 }
                PropertyAnimation { target: buttonHighlight; property: "source"; to: "image://store-button-animation/5"; duration: 20 }
                PropertyAnimation { target: buttonHighlight; property: "source"; to: "image://store-button-animation/6"; duration: 20 }
                PropertyAnimation { target: buttonHighlight; property: "source"; to: "image://store-button-animation/7"; duration: 20 }
                PropertyAnimation { target: buttonHighlight; property: "source"; to: "image://store-button-animation/8"; duration: 20 }
                PropertyAnimation { target: buttonHighlight; property: "source"; to: "image://store-button-animation/9"; duration: 20 }
                PropertyAnimation { target: buttonHighlight; property: "source"; to: ""; duration: 50 }
              }

              PropertyAnimation { target: buttonHighlight; property: "source"; to: ""; duration: 30000 } //wait 30sec
            } //SequentialAnimation
          } //Image
        } //TibiaButton
      } //RowLayout

      TibiaHorizontalSeparator {
        Layout.fillWidth: true
      }

      TibiaTextContainingHTMLLinks {
        Layout.fillWidth: true
        font: TibiaStyle.smallFont
        horizontalAlignment: Text.AlignHCenter

        text: qsTrId("create_account_dialog_google_recaptcha_text")
        wrapMode: Text.Wrap
      } //TibiaText
    } //ColumnLayout

    ColumnLayout {
      id: selectWorldLaoyut
      spacing: TibiaStyle.marginRelated
      visible: root.currentDisplay == "SelectWorld"

      TibiaPanel2PixelUpFilledWithCaption {
        id: selectGameWorldPanel
        caption: qsTrId("create_account_dialog_select_a_game_world")
        Layout.fillWidth: true
        Layout.fillHeight: true

        ColumnLayout {
          spacing: TibiaStyle.marginUnrelated
          Layout.fillHeight: true

          RowLayout {
            spacing: TibiaStyle.marginRelated

            TibiaText {
              text: qsTrId("create_account_dialog_world_region_label")
            }

            TibiaComboBox {
              id: regionFilterComboBox
              Layout.fillWidth: true
              model: controller.worldRegions
              shouldBeCurrentIndex: controller.selectedWorldRegionFilterIndex

              onActivated: (index) => {
                controller.updateWorldRegionFilter(index);
                updateWorldTableViewSelectionTimer.restart();
                worldTypeFilterComboBox.currentIndex = 0;
              }
            } //TibiaComboBox

            Item {
              Layout.fillWidth: true
            }

            TibiaText {
              text: qsTrId("create_account_dialog_pvp_type_label")
            }

            TibiaComboBox {
              id: worldTypeFilterComboBox
              Layout.fillWidth: true
              model: controller.worldPvPTypesForRegion[regionFilterComboBox.currentText]
              shouldBeCurrentIndex: controller.selectedWorldPvPTypeFilterIndex < count ? controller.selectedWorldPvPTypeFilterIndex: -1

              onActivated: (index) => {
                controller.updateWorldPvPTypeFilter(index);
                updateWorldTableViewSelectionTimer.restart();
              }
            } //TibiaComboBox
          } //RowLayout

          RowLayout {
            spacing: TibiaStyle.marginRelated

            TibiaTableView {
              id: worldSelection
              Layout.fillHeight: true
              Layout.preferredWidth: 140
              model: controller.worldsModel
              property var ominousHelper: null
              selectionMode: SelectionMode.SingleSelection

              function updateWorldTableViewSelection() {
                if( (model == null) || (model.rowCount() == 0) ) {
                  return;
                }

                for (let i = 0; i < rowCount; ++i) {
                  let row = ominousHelper.sourceItemDataByRowIndex(i);

                  if( row && row.WorldName == controller.selectedWorld ) {
                    selection.clear();
                    selection.select(i);
                    break;
                  }
                }
              } //function updateWorldTableViewSelection

              function updateSelectedWorld() {
                if ( selection.count == 1 ) {
                  selection.forEach( function(rowIndex) {
                    let row = ominousHelper.sourceItemDataByRowIndex(rowIndex);
                    if (row) {
                      controller.updateSelectedWorld(row.WorldName)
                    }
                  } );
                }
              } //function updateSelectedWorld

              onModelChanged: {
                if (model != null) {
                  ominousHelper = AbstractItemModelHelper.wrapInHelperProxyModel(model);
                } else {
                  ominousHelper = null;
                }

                updateWorldTableViewSelection();
              }

              onClicked: {
                updateSelectedWorld();
              }

              selection.onSelectionChanged: {
                updateSelectedWorld();
              }

              onRowCountChanged: {
                updateWorldTableViewSelection();
              }

              TableViewColumn {
                id: worldname
                movable: false
                resizable: false
                role: "WorldName"
              } //TableViewColumn
            } //TibiaTableView

            TibiaPanel2PixelUpFilledWithCaption {
              id: worldInformationPanel
              Layout.fillWidth: true
              Layout.fillHeight: true
              caption: controller.selectedWorld

              TibiaText {
                id: selectAWorldHintText
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                visible: controller.selectedWorld == ""
                text: qsTrId("create_account_dialog_select_a_world_text")
              } //TibiaText

              GridLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: 3
                columnSpacing: TibiaStyle.marginRelated
                rowSpacing: TibiaStyle.marginRelated

                visible: controller.selectedWorld != ""

                TibiaText { text: qsTrId("create_account_dialog_players_online_label") }
                TibiaText { text: (controller.selectedWorldPlayersOnline != null ? controller.selectedWorldPlayersOnline: "" )}
                Item { Layout.fillWidth: true }

                TibiaText { text: qsTrId("create_account_dialog_pvp_type_label") }
                TibiaText { text: (controller.selectedWorldPvPType != null ? controller.selectedWorldPvPType: "")}

                RowLayout {
                  spacing: 0

                  Item {
                    Layout.fillWidth: true
                  }
                  TibiaGuiHelp {
                    id: pvptypehelp
                    text: (controller.selectedWorldPvPTypeHelp != null ? controller.selectedWorldPvPTypeHelp: "")
                  }
                } //RowLayout

                TibiaText { text: qsTrId("create_account_dialog_world_region_label") }
                TibiaText { text: (controller.selectedWorldRegion != null ? controller.selectedWorldRegion: "")}
                Item { Layout.fillWidth: true }

                TibiaText { text: qsTrId("create_account_dialog_creation_date_label") }
                TibiaText { text: (controller.selectedWorldCreationDate != null ? controller.selectedWorldCreationDate: "")}
                Item { Layout.fillWidth: true }

                TibiaText { text: qsTrId("create_account_dialog_battle_eye_status_label") }
                TibiaText { text: (controller.selectedWorldBattleEyeStatus != null ? controller.selectedWorldBattleEyeStatus: "")}

                RowLayout {
                  spacing: 0

                  Item {
                    Layout.fillWidth: true
                  }
                  TibiaGuiHelp { text: qsTrId("create_account_dialog_battle_eye_status_help") }
                }

                TibiaText { text: qsTrId("create_account_dialog_premium_only_label") }
                TibiaText { text: (controller.selectedWorldPremiumOnly != null ? controller.selectedWorldPremiumOnly: "Yes")}

                RowLayout {
                  spacing: 0

                  Item {
                    Layout.fillWidth: true
                  }

                  TibiaGuiHelp {
                    visible: ((controller.selectedWorldPremiumOnly != null) ? controller.selectedWorldPremiumOnly: false )
                    text: qsTrId("create_account_dialog_premium_only_help")
                  }
                }

                TibiaText { text: qsTrId("create_account_dialog_transfer_type_label") }
                TibiaText { text: (controller.selectedWorldTransferType != null ? controller.selectedWorldTransferType: "")}

                RowLayout {
                  spacing: 0

                  Item {
                    Layout.fillWidth: true
                  }

                  TibiaGuiHelp {
                    text: qsTrId("create_account_dialog_transfer_types_help")
                  } //TibiaGuiHelp
                } //RowLayout
              } //GridLayout
            } //TibiaPanel2PixelUpFilledWithCaption
          } //RowLayout
        } //ColumnLayout
      } //TibiaPanel2PixelUpFilledWithCaption

      TibiaHorizontalSeparator {
        Layout.fillWidth: true
      } //TibiaHorizontalSeparator

      RowLayout {
        id: buttonFooterWorldSelection
        spacing: TibiaStyle.marginUnrelated

        TibiaButton {
          id: backButton
          Layout.preferredWidth: TibiaStyle.buttonWidthWider
          text: qsTrId("back")

          onClicked: backFromWorldSelect()
        } //TibiaButton

        Item {
          Layout.fillWidth: true
        } //Item

        TibiaButton {
          id: resetButton
          Layout.preferredWidth: TibiaStyle.buttonWidthWider
          text: qsTrId("create_account_dialog_reset_button_label")

          onClicked: {
            controller.resetWorldSelection();
            updateWorldTableViewSelection();
          }
        } //TibiaButton

        TibiaButton {
          id: okayButton
          Layout.preferredWidth: TibiaStyle.buttonWidthWider
          text: qsTrId("ok")

          onClicked: {
            accountCreationStage = 0;
          }
        } //TibiaButton
      } //RowLayout
    } //ColumnLayout

    WebEngineView {
      //this is invisible so it needs no size
      id: recaptchaV3View
      visible: !controller.showRecaptchaV2

      url: !controller.recaptchaDisabled ? controller.recaptchaV3ContentUrl : ""
      profile.httpCacheType: WebEngineProfile.NoCache

      onLoadingChanged: (loadRequest) =>  {
        if (loadRequest.status == WebEngineView.LoadSucceededStatus) {
          recaptchaV3ViewAvailable = true;
        }

        if (loadRequest.status == WebEngineView.LoadFailedStatus) {
          console.log("RecaptchaV3View loading failed. Status:",
            loadRequest.url,
            loadRequest.status,
            loadRequest.errorCode,
            loadRequest.errorDomain,
            loadRequest.errorString );
        }
      }
    } //WebEngineView

      WebEngineView {
        id: recaptchaV2View
        webChannel: recaptchaV2webChannel
        Layout.preferredWidth: 420
        Layout.preferredHeight: 590
        Layout.alignment: Qt.AlignHCenter

        visible: root.currentDisplay == "RecaptchaV2"

        Action {
          shortcut: "Escape"
          onTriggered: {
            root.cancel();
          }
        } //Action

        QtObject {
          id: callbackObject
          WebChannel.id: "callbackObject"

          function imnotarobotCallback( token ) {
            if ( recaptchaV2ViewAvailable ) {
              controller.startPlaying(token, null);
            }
          }
        } //QtObject

        WebChannel {
          id:recaptchaV2webChannel
        } //WebEngineView


        url: !controller.recaptchaDisabled ? controller.recaptchaV2ContentUrl: ""
        profile.httpCacheType: WebEngineProfile.NoCache

        onLoadingChanged: (loadRequest) =>  {
          if (loadRequest.status == WebEngineView.LoadSucceededStatus) {
            recaptchaV2webChannel.registerObject("callbackObject", callbackObject);
            recaptchaV2ViewAvailable = true;
          }
        }
      } //WebEngineView
  } //ColumnLayout

  TooltipTemplate {
    x: rootLayout.mapFromItem(eMailTextField, 0,eMailTextField.height).x
    y: rootLayout.mapFromItem(eMailTextField, 0,eMailTextField.height).y

    visible: eMailTextField.text != null
      && eMailTextField.text.length > 0
      && !controller.eMailDataValid
      && eMailTextField.activeFocus
      && passwordTextField.visible
    onVisibleChanged: {
      let point = rootLayout.mapFromItem(eMailTextField, 0,eMailTextField.height);
      x = point.x;
      y = point.y;
    } //onVisibleChanged

    useRichText: true
    text: qsTrId("email_address_gui_help_text")
  } //TooltipTemplate

  TooltipTemplate {
    x: rootLayout.mapFromItem(passwordTextField, 0,passwordTextField.height).x
    y: rootLayout.mapFromItem(passwordTextField, 0,passwordTextField.height).y

    visible: capsLock && passwordTextField.activeFocus && passwordTextField.visible
    onVisibleChanged: {
      let point = rootLayout.mapFromItem(passwordTextField, 0,passwordTextField.height);
      x = point.x;
      y = point.y;
    } //onVisibleChanged

    useRichText: true
    text: qsTrId("caps_lock_warning")
  } //TooltipTemplate

  TooltipTemplate {
    x: rootLayout.mapFromItem(passwordRepeatTextField, 0, passwordRepeatTextField.height).x
    y: rootLayout.mapFromItem(passwordRepeatTextField, 0, passwordRepeatTextField.height).y

    readonly property var passwordDiffer: passwordRepeatTextField.text.length > 0
      && passwordRepeatTextField.text != passwordTextField.text

    visible: (capsLock || passwordDiffer)
      && passwordRepeatTextField.activeFocus
      && passwordRepeatTextField.visible

    onVisibleChanged: {
      let point = rootLayout.mapFromItem(passwordRepeatTextField, 0, passwordRepeatTextField.height);
      x = point.x;
      y = point.y;
    } //onVisibleChanged

    useRichText: true
    text: {
      let message = ""
      if (capsLock) {
        message = qsTrId("caps_lock_warning");
      }
      if (passwordDiffer) {
        if (message.length > 0) {
          message += "<br><br>";
        }
        message += qsTrId("create_account_dialog_passwords_differ_warning");

      }
      return message;
    }
  } //TooltipTemplate

  TooltipTemplate {
    x: rootLayout.mapFromItem(characterNameTextField, 0, characterNameTextField.height).x
    y: rootLayout.mapFromItem(characterNameTextField, 0, characterNameTextField.height).y

    visible: (controller.characterNameError.length > 0) && characterNameTextField.activeFocus && characterNameTextField.visible
    onVisibleChanged: {
      let point = rootLayout.mapFromItem(characterNameTextField, 0, characterNameTextField.height);
      x = point.x;
      y = point.y;
    } //onVisibleChanged

    useRichText: true
    clientWidth: 200
    text: (controller.characterNameError != null) ? qsTrId(controller.characterNameError): ""
  } //TooltipTemplate

  Rectangle {
    id: passwordHints
    x: passwordStrengthText.x + 75
    y: 84

    visible: showPasswordRules

    border.width: 1
    border.color: "black"

    color: TibiaStyle.tooltipBackgroundColor
    width: textColumn.width + 2 * TibiaStyle.tooltipBorderMargin
    height: textColumn.height + 2 * TibiaStyle.tooltipBorderMargin

    Column {
      id: textColumn
      anchors.centerIn: parent
      spacing: TibiaStyle.marginNarrow

      TibiaText {
        id: passwordRuleHeaderText
        width: 252
        font: TibiaStyle.tooltipFont
        color: TibiaStyle.tooltipTextColor
        wrapMode: Text.Wrap
        elide: Text.ElideNone

        textFormat: Text.RichText
        text: qsTrId("create_account_dialog_password_rules")
      } //TibiaText

      Repeater {
        model: controller.passwordCriteria != null ? controller.passwordCriteria : null

        RowLayout {
          Layout.preferredWidth: passwordRuleHeaderText.width
          spacing: TibiaStyle.marginRelated

          Image {
            id: passwordRuleCriterionImage
            Layout.topMargin: 4
            Layout.alignment: Qt.AlignTop
            source: getTibiaCheckIcon( modelData.criterionMet )
          } //Image

          TibiaText {
            Layout.preferredWidth: passwordRuleHeaderText.width - passwordRuleCriterionImage.width - parent.spacing
            font: TibiaStyle.tooltipFont
            color: TibiaStyle.tooltipTextColor
            wrapMode: Text.WordWrap

            textFormat: Text.RichText
            text: qsTrId("create_account_dialog_password_criterion_" + modelData.criterionKey.toLowerCase())
          } //TibiaText
        } //RowLayout
      } //Repeater
    } //Column

    states: State {
      name: "reparented"
      ParentChange
      {
        target: passwordHints;
        parent: controller.tooltipContainer;
      }
    } //states
  } //Rectangle
} //TibiaDialog
