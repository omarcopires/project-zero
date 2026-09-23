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
  caption: qsTrId("create_character_dialog_caption")
  initialFocusItem: characterNameTextField
  width: 510
  movable: false

  required property QtObject controller
  readonly property bool createCharacterProcessing: false

  readonly property string isWorldSelected: controller.selectedWorld != ""

  onCancelPressedFunction: cancel

  onHeightChanged: centerDialog()
  onWidthChanged: centerDialog()

  function getTibiaCheckIcon( checkValue ) {
    if (checkValue)
    {
      return "qrc:/images/icon-yes.png";
    }

    return "qrc:/images/icon-no.png";
  }

  function cancel() {
    controller.cancel();
  } //function cancel

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

  ColumnLayout {
    id: rootLayout
    anchors { left: parent.left; right: parent.right; top: parent.top }
    spacing: TibiaStyle.marginRelated

    TibiaPanel2PixelUpFilledWithCaption {
      id: createCharacterPanel
      caption: qsTrId("create_character_dialog_create_character_caption");
      Layout.fillWidth: true
      Layout.fillHeight: true

      GridLayout {
        id: characterAndWorldGrid
        columns: 5
        columnSpacing: TibiaStyle.marginRelated
        rowSpacing: TibiaStyle.marginRelated

        // Character name input
        TibiaText {
          Layout.preferredWidth: TibiaStyle.lableTextWidth
          text: qsTrId("create_account_dialog_character_name_label")
          horizontalAlignment: Text.AlignRight
        }

        TibiaTextField {
          id: characterNameTextField
          Layout.preferredWidth: TibiaStyle.textFieldWidth
          Layout.preferredHeight: TibiaStyle.buttonHeightDefault
          Layout.columnSpan: 2
          readOnly: root.createCharacterProcessing

          maximumLength: TibiaStyle.maxCharacterNameLength
          allowSpaces: true

          shouldBeText: controller.characterName

          onTextChanged: {
            if(controller.characterName != text) {
              updateCharacterNameTimer.restart();
            }
          } //onTextChanged
        } //TibiaTextField
        

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
        TibiaText {
          Layout.preferredWidth: TibiaStyle.lableTextWidth
          text: qsTrId("create_account_dialog_character_sex_label")
          horizontalAlignment: Text.AlignRight
        } //TibiaText

        ButtonGroup {
            id: sexToMaleGroup
        }
        
        property bool isCharacterSexMale : controller.characterSexMale

        function setCharacterSexToMale(isMale) {
          if (controller.characterSexMale != isMale) {
            controller.characterSexMale = isMale;
          }
        }

        TibiaRadioButton {
          ButtonGroup.group: sexToMaleGroup
          text: qsTrId("male")
          checked: characterAndWorldGrid.isCharacterSexMale
          onCheckedChanged: {
            characterAndWorldGrid.setCharacterSexToMale(checked);
          }
          
        } //TibiaRadioButton

        TibiaRadioButton {
          ButtonGroup.group: sexToMaleGroup
          text: qsTr("female")
          checked: !characterAndWorldGrid.isCharacterSexMale
          onCheckedChanged: {
            characterAndWorldGrid.setCharacterSexToMale(!checked);
          }
        } //TibiaRadioButton
       
        Image {
          id: characterSexStatusImage
          Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
          source: getTibiaCheckIcon( true )
        } //Image

        Item {
          Layout.fillWidth: true
        }

        // Skip Tutorial
        TibiaText {
          Layout.preferredWidth: TibiaStyle.lableTextWidth
          text: qsTrId("create_account_dialog_play_tutorial")
          horizontalAlignment: Text.AlignRight
        } //TibiaText

        ButtonGroup {
            id: playTutorialGroup
        }
    
        property bool playTutorial : controller.playTutorial

        function setplayTutorial(play) {
          if (controller.playTutorial != play) {
            controller.playTutorial = play;
          }
        }

        TibiaRadioButton {
          ButtonGroup.group: playTutorialGroup
          text: qsTrId("yes")
          checked: characterAndWorldGrid.playTutorial
          enabled: controller.canChangePlayTutorial
          onCheckedChanged: {
            characterAndWorldGrid.setplayTutorial(checked);
          }
        } //TibiaRadioButton

        TibiaRadioButton {
          ButtonGroup.group: playTutorialGroup
          text: qsTrId("no")
          checked: !characterAndWorldGrid.playTutorial
          enabled: controller.canChangePlayTutorial
          onCheckedChanged: {
            characterAndWorldGrid.setplayTutorial(!checked);
          }
        } //TibiaRadioButton
          
        Image {
          id: playTutorialStatusImage
          Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
          source: getTibiaCheckIcon( true )
        } //Image

        Item {
          Layout.fillWidth: true
        }      
      }
    } //TibiaPanel2PixelUpFilledWithCaption

    WorldSelection {
      id: worldSelection
      worldsModel: controller.worldsModel
    }

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

      Item {
        Layout.fillWidth: true
      }

      TibiaButton {
        id: cancelButton
        Layout.preferredWidth: TibiaStyle.buttonWidthWider
        text: qsTrId("cancel")
        visible: controller.canCancelCharacterCreation

        onClicked: cancel()
      }

      TibiaButton {
        id: createCharacterButton
        Layout.preferredWidth: TibiaStyle.buttonWidthWider
        text: qsTrId("create_character_dialog_create_character")
        enabled: 
          controller.characterNameValid
          && worldSelection.selectedWorldName != ""
          && !controller.asyncOperationInProgress

        property bool processing: false

        onClicked: {
          controller.createCharacter(
            controller.characterName,
            controller.characterSexMale,
            controller.playTutorial,
            worldSelection.selectedWorldName);
        }
      }
    }
  }

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

} //TibiaDialog
