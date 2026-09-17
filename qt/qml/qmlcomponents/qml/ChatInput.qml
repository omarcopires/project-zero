import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qmlcomponents

FocusScope {
  id: root
  implicitWidth: 200
  implicitHeight: chatInputLayout.height

  property alias showSpeechVolumeButton: speechVolumeButton.visible

  property QtObject chatController: null
  property var chatChannelModel: null
  property bool writeToLocalChat: false

  property alias keepChatInputFocus: chatInputLayout.keepChatInputFocus
  property alias currentChatInput: chatInput.text
  property alias currentSpeechVolume: speechVolumeButton.speechVolume
  property alias currentSpeechVolumeButtonState: speechVolumeButton.state
  property alias currentChatInputSelectedText: chatInput.selectedText

  function selectAll() {
    chatInput.selectAll();
  } //function selectAll

  function deselect() {
    chatInput.deselect();
  } //function deselect

  RowLayout {
    id: chatInputLayout
    anchors.left: parent.left
    anchors.right: parent.right

    spacing: TibiaStyle.chatGuiMargins

    TibiaButton {
      id: speechVolumeButton
      Layout.preferredHeight: chatInput.height
      Layout.preferredWidth: height

      imageSource: "/images/icon-speech-say.png"

      tooltipText: qsTrId("chat_adjust_speech_volume_tooltip")

      hide: !writeToLocalChat
      onHideChanged: { state = ""; }

      property int speechVolume: 0
      onClicked: {
        if (state == "") {
          state = "YELL_MODE";
        } else if (state == "YELL_MODE") {
          state = "WHISPER_MODE";
        } else if (state == "WHISPER_MODE") {
          state = "";
        }
      } //onClicked

      state: ""
      states: [
        State {
          name: "YELL_MODE"
          PropertyChanges {
            target: speechVolumeButton
            imageSource: "/images/icon-speech-yell.png"
            speechVolume: +1
          } //PropertyChanges
        }, //State "YELL_MODE"
        State {
          name: "WHISPER_MODE"
          PropertyChanges {
            target: speechVolumeButton
            imageSource: "/images/icon-speech-whisper.png"
            speechVolume: -1
          } //PropertyChanges
        } //State "WHISPER_MODE"
      ] //states
    } //TibiaButton

    TibiaTextField {
      id: chatInput

      Layout.fillWidth: true
      maximumLength: TibiaStyle.chatInputMaxLength
      color: writeToLocalChat ? TibiaStyle.textColors["Default"] : TibiaStyle.chatInputSpecialChannelColor
      placeholderText: qsTrId("chat_placeholder_text")

      KeyNavigation.tab: chatInput

      Keys.onUpPressed: (event) => {
        if(chatController && (event.modifiers & Qt.ShiftModifier)) {
            chatInput.text = chatController.getOlderChatInputHistoryEntry();
            return;
        }
        event.accepted = false;
      } //Keys.onUpPressed

      Keys.onDownPressed: (event) => {
        if(chatController && (event.modifiers & Qt.ShiftModifier)) {
            var historyEntry = chatController.getNewerChatInputHistoryEntry();
            if(historyEntry.length == 0) {
              chatController.addEntryToChatInputHistory(chatInput.text); //empty strings are not stored by the history
            }
            chatInput.text = historyEntry;
            return;
        }
        event.accepted = false;
      } //Keys.onUpPressed

      Keys.onLeftPressed: (event) => {
        if(event.modifiers == Qt.ShiftModifier) {
          cursorPosition = Math.min(cursorPosition, selectionStart);
          cursorPosition = Math.max(0, cursorPosition -1);
        }
      } //Keys.onLeftPressed

      Keys.onRightPressed: (event) => {
        if(event.modifiers == Qt.ShiftModifier) {
          cursorPosition = Math.max(cursorPosition, selectionEnd);
          cursorPosition = Math.min(length, cursorPosition +1);
        }
      } //Keys.onLeftPressed

      onSelectedTextChanged: {
        if((selectedText.length > 0) && (chatChannelModel != null)) {
          //deselct chat channel selection
          chatChannelModel.startNewSelection(0, 0);
        }
      } //onSelectedTextChanged

      property bool keepChatInputFocusForModeOn: chatInputLayout.keepChatInputFocus
        && chatInputLayout.chatMode != 0 //check tibia::chat::EChatMode::CHAT_OFF

      focus: true
      Component.onCompleted: resetActiveFocusToTextFieldAsync()
      onActiveFocusChanged: resetActiveFocusToTextFieldAsync()
      onKeepChatInputFocusForModeOnChanged: resetActiveFocusToTextFieldAsync()

      function resetActiveFocusToTextFieldAsync() {
        Qt.callLater(function() {
          chatInput.refreshActiveFocus();
        });
      } //function resetActiveFocusToTextFieldAsync

      function refreshActiveFocus() {
        if(!activeFocus && keepChatInputFocusForModeOn) {
          chatInput.forceActiveFocus();
        }
      } //function refreshActiveFocus

      MouseArea {
        anchors.fill: parent
        enabled: !chatInput.keepChatInputFocusForModeOn
        onClicked: (mouse) => {
          if (chatController) {
            mouse.accepted = false;
            chatController.onChatInputClicked();
          }
        } //onClicked
      } //MouseArea
    } //TibiaTextField

    TibiaButton {
      id: chatEnabledButton
      Layout.preferredHeight: TibiaStyle.textFieldHeight
      Layout.preferredWidth: TibiaStyle.buttonWidthBroad

      function getButtonText() {
        if (chatInputLayout.chatMode == 1) { //check tibia::chat::EChatMode::CHAT_ON
          return qsTrId("chat_mode_on");
        } else if (chatInputLayout.chatMode == 2) { //check tibia::chat::EchatMode::CHAT_TEMPORARY_ON
          return qsTrId("chat_mode_temporary_on");
        }
        return qsTrId("chat_mode_off");
      } //function getButtonText()

      text: getButtonText()
      tooltipText: qsTrId("chat_mode_button_tooltip")

      onClicked: {
        if (chatController) {
          chatController.onChatModeButtonClicked();
        }
      } //onClicked
    } //TibiaIconButton

    //for values see tibia::chat::EChatMode
    property int chatMode: chatController != null ? chatController.chatMode : 0
    property bool keepChatInputFocus: true

    KeyNavigation.tab: chatInputLayout
    property bool keepChatInputFocusForModeOff: chatInputLayout.keepChatInputFocus
      && chatInputLayout.chatMode == 0 //check tibia::chat::EChatMode::CHAT_OFF

    focus: true
    Component.onCompleted: refreshActiveFocusModeOffAsync()
    onActiveFocusChanged: refreshActiveFocusModeOffAsync()
    onKeepChatInputFocusForModeOffChanged: refreshActiveFocusModeOffAsync()

    function refreshActiveFocus() {
      if(!activeFocus && keepChatInputFocusForModeOff) {
        forceActiveFocus();
      }
    } //function refreshActiveFocus()

    function refreshActiveFocusModeOffAsync() {
      Qt.callLater(function() {
        chatInputLayout.refreshActiveFocus();
      });
    }
  } //RowLayout
} //FocusScope
