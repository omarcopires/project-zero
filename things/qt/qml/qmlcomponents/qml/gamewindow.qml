import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qmlcomponents
import qmlenumvalues


Item {
  id: gameWindowScreen
  visible: true
  anchors.fill: parent

  // When using TibiaStyle.smallFont in Combination with Text.Outline the rendering of small font can be destroyed
  // when certain special chars like "|" are used in an action bar button
  // For some reason this happens only once. After refresh of the text components the rendering is correct
  // so we render a problematic char at the beginning without showing it and then remove it again
  // see TIBIA-24112 for more information
  // This is especially prominent in action bars
  TibiaText {
    style: Text.Outline
    font: TibiaStyle.smallFont
    visible: false
    text: "|"
    Component.onCompleted: {
      Qt.callLater(function() {
        destroy();
      });
    }
  } // end of workaround

  TibiaText {
    visible: false
    text: "ABCabc123"
    onHeightChanged: {
      TibiaStyle.defaultTextLineHeight = height;
    }
  } //TibiaText

  property var controller: null
  property var mapWindowPaneElement: mapWindowPane
  property var bottomPanelPlaceholder: bottomPanelPlaceholder

  focus: true
  onFocusChanged: {
    if(focus) {
      gameWindowFocusScope.focus = true;
    }
  } //onFocusChanged

  onControllerChanged: {
    if (controller != null && controller.rememberEmail && controller.initialLoginEmail.length > 0) {
      passwordTextField.forceActiveFocus();
    } else {
      eMailAddressTextField.forceActiveFocus();
    }
    // this must be done first since it triggers the overwrite of upperPaneUserSetHeight and lowerPaneUserSetHeight
    gamewindowSplitView.resizingBehaviour = controller.resizingMode;

    gamewindowSplitView.upperPaneUserSetHeight = controller.upperPaneHeight;
    gamewindowSplitView.lowerPaneUserSetHeight = controller.lowerPaneHeight;
    gamewindowSplitView.correctLayout();
  }

  Connections {
    target: mapWindowPaneElement
    function onMaximumHeightChanged() {
      gamewindowSplitView.correctLayout();
    }
  }

  function bindFocusToChatInput() {
    if (state == "INGAME") {
      chat.keepChatInputFocus = true;
    } else {
      setFocusToLoginTextField();
    }
  } //function binFocusToChatInput()

  function releaseFocusFromChatInput() {
    chat.keepChatInputFocus = false;
  } //function releaseFocusFromChatInput()

  function setFocusToLoginTextField() {
    releaseFocusFromChatInput();
    if (eMailAddressTextField.text.length == 0) {
      eMailAddressTextField.forceActiveFocus();
    } else {
      passwordTextField.forceActiveFocus();
    }
  } //function setFocusToLoginTextField()

  function clearLoginMask() {
    // The email field is only cleared if the user does not want to remember his login email
    if (controller != null && !controller.rememberEmail && eMailAddressTextField.text.length > 0) {
      eMailAddressTextField.text = controller != null ? controller.initialLoginEmail : "";
    }
    passwordTextField.text = "";
  } //function clearLoginMask()

  function createNewAccountClicked() {
    if (state != "INGAME" && controller != null ) {
        creatAccountDoubleClickStopTimer.restart();
        controller.handleCreateNewAccount();
    }
  } //function createNewAccountClicked()

  function loginClicked() {
    if (state != "INGAME" && controller != null &&
        eMailAddressTextField.text.length > 0 && passwordTextField.text.length > 0) {
      controller.loginPressed(eMailAddressTextField.text, passwordTextField.text);
    }
    clearLoginMask();
  } //loginClicked

  function reportLeftAndRightStatusAndActionBarsWidth() {
    triggerReportLeftAndRightStatusAndActionBarsWidth.restart();
  } //reportLeftAndRightStatusAndActionBarsWidth

  Timer {
    id: triggerReportLeftAndRightStatusAndActionBarsWidth
    interval: 0;
    running: false;
    repeat: false
    onTriggered: {
      if (controller != null) {
        var totalExtraWidth = 0;
        totalExtraWidth = totalExtraWidth + rightActionBars.width + leftActionBars.width;
        totalExtraWidth = totalExtraWidth + (statusBarLeftLoader.visible ? statusBarLeftLoader.width : 0)
        totalExtraWidth = totalExtraWidth + (statusBarRightLoader.visible ? statusBarRightLoader.width : 0);
        controller.leftAndRightStatusActionBarWidthChanged(totalExtraWidth);
      }
    gamewindowSplitView.correctLayout();
    } //onTriggered
  } //Timer


  onWidthChanged: gamewindowSplitView.correctLayout()

  Keys.onReturnPressed: { loginClicked(); }
  Keys.onEnterPressed: { loginClicked(); }
  Keys.onCancelPressed: { clearLoginMask(); }
  Keys.onEscapePressed: { clearLoginMask(); }

  states: [
    // Default state "" is showing the start screen
    State {
      name: ""
      StateChangeScript { script: setFocusToLoginTextField(); }
    }, //State

    State {
      name: "INGAME"
      PropertyChanges { target: gameWindow; visible: true; }
      PropertyChanges { target: cipSoftLogo; visible: false; source: ""}
      PropertyChanges { target: loginMask; visible: false; }
      PropertyChanges { target: topBarLoader; sourceComponent: null; }
      PropertyChanges { target: bottomBarLoader; sourceComponent: null; }

      StateChangeScript { script: bindFocusToChatInput(); }
      StateChangeScript { script: mapWindowPane.clearShaders(); }
    } //State
  ] //states

  state: controller != null ? controller.gameWindowState : ""

  ColumnLayout {
    anchors.fill: parent
    spacing: 0
    FocusScope {
      id: gameWindowFocusScope
      Layout.fillWidth: true
      Layout.fillHeight: true

      // START "Home" SCREEN-NEW

      //Menu with buttons and live information
      Loader {
        id: topBarLoader
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: -2
        sourceComponent: liveInfoAndButtonsTopBar
        asynchronous: true
      } //Loader

      Component {
        id: liveInfoAndButtonsTopBar
        TibiaFrame2PixelUpFilled {
          id: topBarRoot
          width: TibiaStyle.clientMinWidth + 2 * borderWidth
          height: 33

          readonly property int contentMarginSides: borderWidth + TibiaStyle.marginRelated
          readonly property int contentVerticalCenterOffset: topBarLoader.anchors.topMargin

          RowLayout {
            id: liveInformationSection
            anchors.left: parent.left
            anchors.leftMargin: parent.contentMarginSides
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: parent.contentVerticalCenterOffset

            spacing: TibiaStyle.marginRelated
            readonly property int streamerInfoWidth: 50

            MouseArea {
              Layout.preferredWidth: twitchLayoutSection.width
              Layout.preferredHeight: twitchLayoutSection.height

              hoverEnabled: true
              onEntered: {
                if(tibiaMouseCursorController != null) { tibiaMouseCursorController.setPointingHand(true); }
              }
              onExited: {
                if(tibiaMouseCursorController != null) { tibiaMouseCursorController.setPointingHand(false); }
              }
              onClicked: {
                if (controller != null) {
                  controller.twitchLogoPressed();
                }
              } //onClicked

              GridLayout {
                id: twitchLayoutSection
                columnSpacing: TibiaStyle.marginRelated
                rowSpacing: 0
                columns: 3

                Image {
                  Layout.rowSpan: 2
                  Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                  source: "/images/icon-twitch.png"
                  smooth: false
                } //Image

                Image {
                  source: "/images/icon-streamers.png"
                  smooth: false
                } //Image

                TibiaText {
                  Layout.preferredWidth: liveInformationSection.streamerInfoWidth
                  text: controller != null ? controller.twitchStreamCount : "0"
                } //TibiaText

                Image {
                  source: "/images/icon-viewers.png"
                  smooth: false
                } //Image

                TibiaText {
                  Layout.preferredWidth: liveInformationSection.streamerInfoWidth
                  text: controller != null ? controller.twitchViewerCount : "0"
                } //TibiaText
              } //GridLayout
            } //MouseArea

            MouseArea {
              Layout.preferredWidth: youTubeLayoutSection.width
              Layout.preferredHeight: youTubeLayoutSection.height

              hoverEnabled: true
              onEntered: {
                if(tibiaMouseCursorController != null) { tibiaMouseCursorController.setPointingHand(true); }
              }
              onExited: {
                if(tibiaMouseCursorController != null) { tibiaMouseCursorController.setPointingHand(false); }
              }
              onClicked: {
                if (controller != null) {
                  controller.youTubeLogoPressed();
                }
              } //onClicked

              GridLayout {
                id: youTubeLayoutSection
                columnSpacing: TibiaStyle.marginRelated
                rowSpacing: 0
                columns: 3

                Image {
                  Layout.rowSpan: 2
                  Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                  source: "/images/icon-youtube.png"
                  smooth: false
                } //Image

                Image {
                  source: "/images/icon-streamers.png"
                  smooth: false
                } //Image

                TibiaText {
                  Layout.preferredWidth: liveInformationSection.streamerInfoWidth
                  text: controller != null ? controller.youTubeStreamCount : "0"
                } //TibiaText

                Image {
                  source: "/images/icon-viewers.png"
                  smooth: false
                } //Image

                TibiaText {
                  Layout.preferredWidth: liveInformationSection.streamerInfoWidth
                  text: controller != null ? controller.youTubeViewerCount : "0"
                } //TibiaText
              } //GridLayout
            } //MouseArea
          } //RowLayout

          RowLayout {
            id: playersOnlineSection
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: parent.contentVerticalCenterOffset

            spacing: TibiaStyle.marginRelated

            Image {
              source: "/images/icon-players.png"
              smooth: false
            } //Image

            TibiaText {
              text: qsTrId("live_info_players_online").arg(controller != null ? controller.onlinePlayerCount : 0)
            } //TibiaText
          } //RowLayout

          RowLayout {
            id: buttonsSection
            anchors.right: parent.right
            anchors.rightMargin: parent.contentMarginSides
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: parent.contentVerticalCenterOffset

            spacing: TibiaStyle.marginNarrow

            TibiaButton {
              text: qsTrId("manage_account")
              Layout.preferredWidth: TibiaStyle.buttonWidthWider

              onClicked: {
                if (controller != null) {
                  controller.manageAccountPressed();
                }
                clearLoginMask();
              } //onClicked
            } // TibiaButton

            TibiaButton {
              text: qsTrId("manage_clients")
              Layout.preferredWidth: TibiaStyle.buttonWidthWider

              onClicked: {
                if (controller != null) {
                  controller.manageClientsPressed();
                }
                clearLoginMask();
              } //onClicked
            } // TibiaButton

            Item {
              Layout.preferredHeight: muteAnthemButton.height
              Layout.preferredWidth: muteAnthemButton.width

              Tooltip {
                anchors.fill: parent
                maxWidth: TibiaStyle.tooltipRestrictedWidth
                text: qsTrId("music_muted")
                enabled: !muteAnthemButton.enabled
              } // Tooltip

              TibiaButton {
                id: muteAnthemButton
                width: height

                imageSourceUp: "/images/icon-mute-idle.png"
                imageSourceDown: "/images/icon-mute-pressed.png"
                imageSourceDisabled: "/images/icon-mute-pressed-disabled.png"

                tooltipText: qsTrId("mute_anthem")
                tooltipTextChecked: qsTrId("unmute_anthem")

                enabled: controller != null && !controller.musicMuted

                checkable: true
                useButtonShouldBeChecked: true
                buttonShouldBeChecked: controller != null && (controller.anthemMuted || controller.musicMuted)

                onClicked: {
                  if (controller != null) {
                    controller.muteAnthemPressed();
                  }
                } //onClicked
              } //TibiaButton
            } //Item

            TibiaIconButton {
              id: optionsButton
              sourceUp: "/images/button-options-up.png"
              sourceDown: "/images/button-options-down.png"
              tooltipText: qsTrId("buttonbar_options_open_tooltip")

              onClicked: {
                if (controller != null) {
                  controller.optionsPressed();
                }
                clearLoginMask();
              } //onClicked
            } // TibiaIconButton

            TibiaIconButton {
              sourceUp: "/images/button-logout-up.png"
              sourceDown: "/images/button-logout-down.png"
              tooltipText: qsTrId("quit")
              //text: qsTrId("quit")

              onClicked: {
                if (controller != null) {
                  controller.quitPressed();
                }
                clearLoginMask();
              } //onClicked
            } // TibiaIconButton
          } //RowLayout
        } //TibiaFrame2PixelUpFilled
      } //Component

      //Login mask and dragon logo
      AnimatedImage {
        id: dragonLogo
        anchors.horizontalCenter: loginMask.horizontalCenter
        anchors.bottom: loginMask.top
        anchors.bottomMargin: TibiaStyle.marginWide

        source: controller != null && visible ? controller.dragonLogoSource : ""
        onSourceChanged: {
          currentFrame = 0;
          if (playing == false) {
            playing = true;
          }
        }
        visible: loginMask.visible || showCreateAccountOption.visible

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
              if(tibiaMouseCursorController != null) { tibiaMouseCursorController.setPointingHand(true); }
            }
            onExited: {
              if(tibiaMouseCursorController != null) { tibiaMouseCursorController.setPointingHand(false); }
            }
            onClicked: {
              if (controller != null) {
                controller.tibiaLogoPressed();
              }
            } //onClicked
          } //MouseArea
      } //Image

        TibiaDialogFrameWithCaption {
          id: showCreateAccountOption
          caption: qsTrId("welcome_caption")
          visible: controller != null && !controller.isAuthenticated && controller.showCreateAccountOption
          anchors.centerIn: parent

          width: 260
          height: topMarginToContent + marginsToContent  + showCreateAccountOptionLayout.height

          ColumnLayout {
            id: showCreateAccountOptionLayout
            anchors { left: parent.left; right: parent.right; top: parent.top}
            anchors.margins: parent.marginsToContent
            anchors.topMargin: parent.topMarginToContent
            spacing: TibiaStyle.marginRelated

            TibiaButton {
              id: goToLoginButton
              Layout.alignment: Qt.AlignHCenter
              Layout.fillWidth: true
              Layout.preferredHeight: 36

              text: qsTrId("login")
              textFont: TibiaStyle.defaultTextFont

              onClicked: {
                if (controller != null) {
                  controller.goToLogin()
                }
              } //onClicked
            } //TibiaButton

            RowLayout {
              Layout.alignment: Qt.AlignHCenter
              spacing: TibiaStyle.marginRelated

              TibiaHorizontalSeparator {
                Layout.fillWidth: true
              } //TibiaHorizontalSeparator

              Item {
                Layout.preferredWidth: orText.width
                Layout.preferredHeight: orText.height
                Layout.topMargin: -1

                TibiaText {
                  id: orText
                  text: qsTrId("or")
                  y: -1
                } //TibiaText
              } //Item

              TibiaHorizontalSeparator {
                Layout.fillWidth: true
              } //TibiaHorizontalSeparator
            } //RowLayout

            TibiaButton {
              id: goToCreateNewAccountButton
              Layout.fillWidth: true
              Layout.preferredHeight: 36
              Layout.alignment: Qt.AlignHCenter

              text: qsTrId("create_account")
              textFont: TibiaStyle.defaultTextFont

              onClicked: {
                if (controller != null) {
                  controller.goToCreateNewAccount()
                }
              } //onClicked
            } //TibiaButton
          } //ColumnLayout
        } //TibiaDialogFrameWithCaption


        TibiaDialogFrameWithCaption {
          id: loginMask
          caption: qsTrId("journey_onwards_caption")

          visible: controller != null && !controller.isAuthenticated && !controller.showCreateAccountOption
          anchors.centerIn: parent

          height: loginMaskColumnLayout.height + topMarginToContent + marginsToContent
          width: 280

          ColumnLayout {
            id: loginMaskColumnLayout
            anchors { left: parent.left; right: parent.right; top: parent.top}
            anchors.margins: parent.marginsToContent
            anchors.topMargin: parent.topMarginToContent

            spacing: TibiaStyle.marginUnrelated

            RowLayout {
              id: columnEMailAdress
              spacing: TibiaStyle.marginNarrow

              TibiaText {
                text: qsTrId("email_address")
              } //TibiaText

              TibiaGuiHelp {
                id: eMailGUIHelp
                opacity: eMailAddressTextField.validEMailOrNothingEntered ? 0 : 1
                visible: !eMailAddressTextField.validEMailOrNothingEntered
                text: qsTrId("email_address_gui_help_text")
                color: "red"
              } //TibiaGuiHelp

              Item {
                Layout.fillWidth: true
              } //Item

              TibiaFrame1PixelDown {
                id: eMailFrame
                Layout.preferredWidth: passwordTextField.width
                Layout.preferredHeight: 20

                TibiaTextField {
                  id: eMailAddressTextField
                  anchors { left: parent.left; top: parent.top; bottom: parent.bottom;
                            right: showEMailButton.left; rightMargin: -parent.borderWidth }

                  echoMode: showEMailButton.checked ? TextInput.Normal : TextInput.Password
                  maximumLength: TibiaStyle.eMailAdressLength
                  focus: true
                  KeyNavigation.tab: passwordTextField
                  property bool validEMailOrNothingEntered: true
                  text: controller != null ? controller.initialLoginEmail : ""
                  allowSpaces: false

                  onTextChanged: {
                    // check text
                    if (text.indexOf("@") != -1) {
                      validEMailOrNothingEntered = true;
                    } else {
                      if (text != "") {
                        validEMailOrNothingEntered = false;
                      } else {
                        validEMailOrNothingEntered = true;
                      }
                    }
                  } //onTextChanged
                } //TibiaTextField

                TibiaButton {
                  id: showEMailButton
                  anchors { top: parent.top; topMargin: parent.borderWidth;
                            bottom: parent.bottom; bottomMargin: parent.borderWidth;
                            right: parent.right; rightMargin: parent.borderWidth; }
                  width: height
                  tooltipText: qsTrId("email_address_show_tooltip")
                  tooltipTextChecked: qsTrId("email_address_hide_tooltip")
                  imageSource: "/images/icon-viewers.png"
                  checkable: true
                  useButtonShouldBeChecked: true
                  buttonShouldBeChecked: controller != null && controller.showEmailAsPlainText

                  onClicked: {
                    if (controller != null) {
                      controller.showEmailAsPlainText = !checked
                    }
                  }
                } // TibiaButton

              } // TibiaFrame1PixelDown

            } //RowLayout

            RowLayout {
              id: columnPassword
              spacing: TibiaStyle.marginNarrow

              TibiaText {
                text: qsTrId("password")
              } //TibiaText

              TibiaTextField {
                id: passwordTextField
                echoMode: TextInput.Password
                Layout.fillWidth: true
                Layout.preferredHeight: TibiaStyle.buttonHeightDefault
                KeyNavigation.tab: eMailAddressTextField
                maximumLength: TibiaStyle.passwordLength
              } //TibiaTextField
            } //RowLayout

            ColumnLayout {
              spacing: TibiaStyle.marginRelated

              RowLayout {
                Layout.fillWidth: true

                TibiaCheckBox {
                  id: rememberEmailCheckbox
                  Layout.fillWidth: true
                  text: qsTrId("remember_email")
                  shouldBeChecked: controller != null && controller.rememberEmail

                  onClicked: {
                    if (controller != null) {
                      controller.rememberEmail = !controller.rememberEmail;
                    }
                  }
                }

                TibiaGuiHelp {
                  text: qsTrId("remember_email_help")
                  visible: rememberEmailCheckbox.checked
                }
              }

              TibiaClickableLink {
                text: qsTrId("recover_account")
                onLinkClicked: {
                  if (controller != null) {
                    controller.forgotEMailAddressOrPasswordPressed();
                  }
                }
              } // TibiaClickableLink
            } //ColumnLayout

            TibiaHorizontalSeparator {
              Layout.fillWidth: true
            } //TibiaHorizontalSeparator

            RowLayout {
              spacing: TibiaStyle.marginRelated

              TibiaButton {
                Layout.preferredWidth: TibiaStyle.buttonWidthWider
                visible: controller != null && controller.createAccountEnabled
                enabled: !creatAccountDoubleClickStopTimer.running

                text: qsTrId("create_account")

                onClicked: createNewAccountClicked()

                Timer {
                  id: creatAccountDoubleClickStopTimer
                  interval: 1000
                } //Timer
              } //TibiaButton

              Item {
                Layout.fillWidth: true
              } //Item

              TibiaButton{
                Layout.preferredWidth: TibiaStyle.buttonWidthWide

                text: qsTrId("login")

                onClicked: loginClicked()
              } //TibiaButton
            } //RowLayout
          } //ColumnLayout

          TooltipTemplate {
            useRichText: true
            visible : (controller != null) && controller.isCapsLockActive && passwordTextField.activeFocus
            x: 84
            y: 80
            text: qsTrId("caps_lock_warning")
          } //TooltipTemplate
        } //TibiaDialogFrameWithCaption


      //CipSoft logo
      Image {
        id: cipSoftLogo
        smooth: false
        anchors { bottom: bottomBarLoader.top; horizontalCenter: parent.horizontalCenter }
        //anchors.margins: Math.ceil(implicitHeight * 0.5) //not needed anymore as included in the graphics
        source: "/images/skin/classic/cipsoft-logo.png"

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          onEntered: {
            if(tibiaMouseCursorController != null) { tibiaMouseCursorController.setPointingHand(true); }
          }
          onExited: {
            if(tibiaMouseCursorController != null) { tibiaMouseCursorController.setPointingHand(false); }
          }
          onClicked: {
            if (controller != null) {
              controller.cipSoftLogoPressed();
            }
          } //onClicked
        } //MouseArea
      } //Image

      //Bottom bar, hints, event kalender, monster/creature of the day
      Loader {
        id: bottomBarLoader
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        sourceComponent: bottomBarLayout
        asynchronous: true
      } //Loader

      Component {
        id: bottomBarLayout
        RowLayout {
          width: TibiaStyle.clientMinWidth
          height: 117

          spacing: 0

          TibiaDialogFrameWithCaption {
            Layout.fillHeight: true
            Layout.fillWidth: true

            caption: controller != null ? controller.hintAreaTitle : qsTrId("hint_area_title")

            TibiaScrollView {
              anchors.fill: parent
              anchors.margins: parent.borderWidth
              anchors.topMargin: parent.captionHeight

              Flickable {
                contentHeight: hintText.contentHeight

                boundsBehavior: Flickable.StopAtBounds
                interactive: false //prevent flick behavior on touch screens

                TibiaText {
                  id: hintText
                  property string hintAreaRichText: controller != null ? controller.hintAreaRichText : qsTrId("default_hint")
                  onHintAreaRichTextChanged: {
                    hintText.text = hintAreaRichText;
                  }

                  width: parent.width
                  wrapMode: Text.WordWrap
                  textFormat: Text.RichText
                  /// this is a dirty workaround for a Qt bug (see https://bugreports.qt.io/browse/QTBUG-115183)
                  /// as long as an image element is loaded via url that has no with and no height property set
                  /// subsequent text contents with images that have height and width set won't log an error at the console
                  /// so we just load a transparent dummy image on initialization
                  text: '<img src="https://static.tibia.com/images/mmorpg/transparent-25.png"/>'

                  onLinkActivated: { controller.linkClicked(link); }
                  onLinkHovered: { controller.linkHoverChanged(link.length != 0); }
                } //TibiaText
              } //Flickable
            } //TibiaScrollView
          } //TibiaDialogFrameWithCaption

          TibiaDialogFrameWithCaption {
            Layout.fillHeight: true
            Layout.preferredWidth: 246

            caption: qsTrId("calendar_caption")

            TibiaFrame1PixelDown {
              anchors.fill: parent
              anchors.margins: parent.marginsToContent - TibiaStyle.marginNarrow*3
              anchors.topMargin: parent.topMarginToContent - TibiaStyle.marginNarrow*3

              RowLayout {
                anchors.fill: parent
                anchors.margins: parent.borderWidth
                spacing: 0

                ColumnLayout {
                  Layout.fillWidth: true
                  spacing: 0

                  TibiaCalendarDayCaption {
                    Layout.fillWidth: true
                    caption: qsTrId("calendar_current_events_caption")
                    rightFrameVisible: true
                  } //TibiaCalendarDayCaption

                  TibiaCalendarDay {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    eventModel: controller != null ? controller.eventsScheduleCurrent : null
                    isToday: true
                    isVisibleMonth: true
                    tooltip: controller != null? controller.eventsScheduleCurrentTooltip : ""
                    seasonalTooltip: controller != null? controller.eventsScheduleCurrentSeasonalTooltip : ""
                    rightFrameVisible: true
                    isEntryOfCalendar: false
                  } //TibiaCalendarDay
                } //ColumnLayout

                ColumnLayout {
                  Layout.fillWidth: true
                  spacing: 0

                  TibiaCalendarDayCaption {
                    Layout.fillWidth: true
                    caption: qsTrId("calendar_upcoming_events_caption")
                    rightFrameVisible: false
                  } //TibiaCalendarDayCaption

                  TibiaCalendarDay {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    eventModel: controller != null ? controller.eventsScheduleUpcoming : null
                    isToday: false
                    isVisibleMonth: false
                    tooltip: controller != null? controller.eventsScheduleUpcomingTooltip : ""
                    seasonalTooltip: controller != null? controller.eventsScheduleUpcomingSeasonalTooltip : ""
                    rightFrameVisible: false
                    isEntryOfCalendar: false
                  } //TibiaCalendarDay
                } //ColumnLayout
              } //RowLayout

              TibiaBreathingHighlight {
                running: controller != null && controller.newEventToday
              } //TibiaBreathingHighlight
            } //TibiaFrame1PixelDown

            MouseArea {
              anchors.fill: parent
              z:-1

              hoverEnabled: true
              onEntered: {
                if(tibiaMouseCursorController != null) { tibiaMouseCursorController.setPointingHand(true); }
              } //onEntered
              onExited: {
                if(tibiaMouseCursorController != null) { tibiaMouseCursorController.setPointingHand(false); }
              } //onExited

              onClicked: {
                if (controller != null) {
                  controller.requestOpenCalendar();
                }
              } //onClicked
            } //MouseArea
          } //TibiaDialogFrameWithCaption

          TibiaDialogFrameWithCaption {
            Layout.fillHeight: true
            Layout.preferredWidth: TibiaStyle.mapWindowPixelPerField * 4 + TibiaStyle.marginUnrelated * 4

            caption: qsTrId("info_boosted_creature_caption")

            Item {
              id: boostedCreatureBox
              width: boostedCreatureRenderer.width
              height: boostedCreatureRenderer.height
              anchors { top: parent.top; topMargin: parent.topMarginToContent;
                        left: parent.left; leftMargin: parent.borderWidth + TibiaStyle.marginUnrelated }

              RaceAppearanceInstanceRenderer {
                id: boostedCreatureRenderer
                height: 2* TibiaStyle.mapWindowPixelPerField
                width:  height
                raceID:  controller != null? controller.boostedCreatureRace : 0
                animated: true
                center: true
                moving: true
                visible: true

                Image {
                  source: "/images/icon-questionmark.png"
                  smooth: false
                  anchors.centerIn: parent
                  visible: controller == null || controller.boostedCreatureRace == 0
                } // Image
              } // RaceAppearanceInstanceRenderer

              Tooltip {
                anchors.fill: parent
                text: controller != null && controller.boostedCreatureRace != 0 ? qsTrId("info_boosted_creature_tooltip").arg(controller != null ? controller.boostedCreatureName : "") : qsTrId("info_boosted_creature_tooltip_empty")
              } // Tooltip
            } //Item

            TibiaText {
              text: qsTrId("info_boosted_creature_type")
              anchors { horizontalCenter: boostedCreatureBox.horizontalCenter;
                        top: boostedCreatureBox.bottom; topMargin: TibiaStyle.marginRelated }
            }

            Item {
              id: boostedBossBox
              width: boostedBossRenderer.width
              height: boostedBossRenderer.height
              anchors { top: parent.top; topMargin: parent.topMarginToContent;
                        left: boostedCreatureBox.right; leftMargin: TibiaStyle.marginUnrelated }

              RaceAppearanceInstanceRenderer {
                id: boostedBossRenderer
                height: 2* TibiaStyle.mapWindowPixelPerField
                width:  height
                raceID:  controller != null? controller.boostedBossRace : 0
                animated: true
                center: true
                moving: true
                visible: true

                Image {
                  source: "/images/icon-questionmark.png"
                  smooth: false
                  anchors.centerIn: parent
                  visible: controller == null || controller.boostedBossRace == 0
                } // Image
              } // RaceAppearanceInstanceRenderer

              Tooltip {
                anchors.fill: parent
                text: controller != null && controller.boostedBossRace != 0 ? qsTrId("info_boosted_boss_tooltip").arg(controller != null ? controller.boostedBossName : "") : qsTrId("info_boosted_boss_tooltip_empty")
              } // Tooltip
            } //Item

            TibiaText {
              text: qsTrId("info_boosted_boss_type")
              anchors { horizontalCenter: boostedBossBox.horizontalCenter;
                        top: boostedBossBox.bottom; topMargin: TibiaStyle.marginRelated }
            }

          } //TibiaDialogFrameWithCaption
        } //RowLayout
      } //Component

      // Start "in game" window

      Item {
        id: gameWindow //FocusScope
        anchors.fill: parent
        visible: false

        RowLayout {
          anchors.fill: parent
          spacing: 0

          Item {
            id: leftSidebarPane
            Layout.preferredWidth: leftSidebarPlaceholder.width
            Layout.fillHeight: true

            RowLayout {
              id: leftSidebarPlaceholder
              objectName: "leftSidebarPlaceholder"
              anchors {top: parent.top; bottom: parent.bottom }
              spacing: 0
              layoutDirection: Qt.LeftToRight
            } //RowLayout

            SidebarManager {
              id: leftSidebarManager
              objectName: "leftSidebarManager"
              position: "left"

              anchors.top: parent.top
              anchors.left: parent.right
              anchors.leftMargin: leftSidebarPlaceholder.width > 0 ? -2 : 0
            } //SidebarManager
          } //Item


          ColumnLayout {

            Layout.fillHeight: true
            Layout.fillWidth: true
            z: -1
            spacing: 0

            Loader {
              id: statusBarTopLoader
              Layout.fillWidth: true
              visible: (statusBarTopLoader.status == Loader.Ready)
              source: {
                if (controller != null) {
                  if (controller.statusBarVisible) {
                    if (controller.statusBarController.dialogAnchor == StatusBarController.Top) {
                      return "StatusBar.qml"
                    }
                  }
                }
                return "";
              }

              onLoaded: {
                item.statusController = Qt.binding(function() {
                  if (controller != null) {
                    return  controller.statusBarController;
                  }
                  return null;
                });
              } // onLoaded
            } // Loader

            GamewindowSplitView {
              objectName: "mainFrame"
              id: gamewindowSplitView
              z:-1
              Layout.fillHeight: true
              Layout.fillWidth: true

              upperPaneMinimumHeight: mapWindowPane.minimumHeight
              lowerPaneMinimumHeight: TibiaStyle.chatMinimumHeight + cooldownAndActionBars.height
              scaleInPercent: mapWindowPane.scaleInPercent

              upperPaneResizeCallback: mapWindowPane.calculateValidHeightForDesiredHeight

              onVisibleChanged: () => {
                if (!visible && controller) {
                  controller.closeOpenMultiActionButtons();
                }
              }

              onLayoutChanged: () => {
                Qt.callLater( () => {
                  if(controller) {
                    controller.upperPaneHeight = gamewindowSplitView.upperPaneUserSetHeight;
                    controller.lowerPaneHeight = gamewindowSplitView.lowerPaneUserSetHeight;
                    controller.resizingMode = gamewindowSplitView.resizingBehaviour;

                    controller.closeOpenMultiActionButtons();
                  }
                });
              }

              Row {
                objectName: "gamewindowUpperPane"
                id: gamewindowUpperPane

                width: parent.width
                spacing: 0

                property int desiredMapWindowHeight: TibiaStyle.mapWindowUnscaledHeight
                Layout.minimumHeight: mapWindowPane.minimumHeight
                Layout.minimumWidth: mapWindowPane.minimumWidth
                Layout.maximumHeight: mapWindowPane.maximumHeight

                height: mapWindowPane.calculateHeightForDesiredMapWindowHeight(desiredMapWindowHeight)//only used initial later it is manipulated with the SplitView

                Loader {
                  id: statusBarLeftLoader
                  anchors {top: parent.top; bottom: parent.bottom }
                  visible: (statusBarLeftLoader.status == Loader.Ready)
                  source: {
                    if (controller != null) {
                      if (controller.statusBarVisible) {
                        if (controller.statusBarController.dialogAnchor == StatusBarController.Left) {
                          return "StatusBarLeft.qml"
                        }
                      }
                    }
                    return "";
                  }

                  onLoaded: {
                    item.statusController = Qt.binding(function() {
                      if (controller != null) {
                        return  controller.statusBarController;
                      }
                      return null;
                    });
                  } // onLoaded

                  onWidthChanged: gameWindowScreen.reportLeftAndRightStatusAndActionBarsWidth()
                  onVisibleChanged: gameWindowScreen.reportLeftAndRightStatusAndActionBarsWidth()
                  onStatusChanged: gameWindowScreen.reportLeftAndRightStatusAndActionBarsWidth()
                } // Loader

                VerticalActionBarContainer {
                  id: leftActionBars
                  objectName: "leftActionBars"
                  anchors {top: parent.top; bottom: parent.bottom }
                  leftActionBars: true
                  topMargin: !statusBarLeftLoader.visible ? leftSidebarManager.height - (statusBarTopLoader.visible ? statusBarTopLoader.height : 0)
                                                          : 0
                  firstVisibleButtonIdCanBeSaved: gameWindowScreen.state != ""

                  onWidthChanged: gameWindowScreen.reportLeftAndRightStatusAndActionBarsWidth()
                } //VerticalActionBarContainer

                MapWindowPane {
                  objectName: "mapWindowPane"
                  id: mapWindowPane
                  anchors {top: parent.top; bottom: parent.bottom }
                  width: parent.width
                          - (statusBarLeftLoader.visible ? statusBarLeftLoader.width : 0)
                          - (statusBarRightLoader.visible ? statusBarRightLoader.width : 0)
                          - (leftActionBars.visible ? leftActionBars.width : 0)
                          - (rightActionBars.visible ? rightActionBars.width : 0)
                  clip: true

                  ColumnLayout {
                    spacing: TibiaStyle.marginUnrelated
                    anchors {
                      left: parent.left
                      top: parent.top
                      topMargin: TibiaStyle.marginRelated
                      leftMargin: TibiaStyle.marginUnrelated
                    } //anchors
                    z: 100

                    FpsLatencyIndicator {
                      objectName: "tibiaFpsLatencyIndicator"
                    } //FpsLatencyIndicator

                  } //ColumnLayout
                } //MapWindowPane

                VerticalActionBarContainer {
                  id: rightActionBars
                  objectName: "rightActionBars"
                  anchors {top: parent.top; bottom: parent.bottom }
                  leftActionBars: false
                  topMargin: !statusBarRightLoader.visible ? rightSidebarManager.height - (statusBarTopLoader.visible ? statusBarTopLoader.height : 0)
                                                           : 0
                  firstVisibleButtonIdCanBeSaved: gameWindowScreen.state != ""

                  onWidthChanged: gameWindowScreen.reportLeftAndRightStatusAndActionBarsWidth()
                } //VerticalActionBarContainer

                Loader {
                  id: statusBarRightLoader
                  anchors {top: parent.top; bottom: parent.bottom }
                  visible: (statusBarRightLoader.status == Loader.Ready)
                  source: {
                    if (controller != null) {
                      if (controller.statusBarVisible) {
                        if (controller.statusBarController.dialogAnchor == StatusBarController.Right) {
                          return "StatusBarRight.qml"
                        }
                      }
                    }
                    return "";
                  }

                  onLoaded: {
                    item.statusController = Qt.binding(function() {
                      if (controller != null) {
                        return  controller.statusBarController;
                      }
                      return null;
                    });
                  } // onLoaded

                  onWidthChanged: gameWindowScreen.reportLeftAndRightStatusAndActionBarsWidth()
                  onVisibleChanged: gameWindowScreen.reportLeftAndRightStatusAndActionBarsWidth()
                  onStatusChanged: gameWindowScreen.reportLeftAndRightStatusAndActionBarsWidth()
                } // Loader
              } // Row

              Item {
                id: gamewindowLowerPane
                objectName: "gamewindowLowerPane"
                Layout.minimumHeight: TibiaStyle.chatMinimumHeight + cooldownAndActionBars.height
                width: parent.width
                Layout.fillWidth: true

                TibiaTiledImage {
                  anchors { left: parent.left; top: parent.top; right: parent.right }
                  height: chat.tabBarHeight + cooldownAndActionBars.height + TibiaStyle.marginRelated
                  source: "/images/background-dark.png"
                } //BorderImage

                ColumnLayout {
                  anchors.fill: parent
                  spacing: 0

                  ColumnLayout {
                    id: cooldownAndActionBars
                    Layout.fillWidth: true
                    spacing: 0

                    HorizontalActionBarContainer {
                      objectName: "bottomActionBars"
                      Layout.fillWidth: true
                      Layout.topMargin: TibiaStyle.marginNarrow
                    } //HorizontalActionBarContainer

                    Loader {
                      id: statusBarBottomLoader
                      Layout.fillWidth: true
                      visible: (statusBarBottomLoader.status == Loader.Ready)
                      source: {
                        if (controller != null) {
                          if (controller.statusBarVisible) {
                            if (controller.statusBarController.dialogAnchor == StatusBarController.Bottom) {
                              return "StatusBar.qml"
                            }
                          }
                        }
                        return "";
                      }

                      onLoaded: {
                        item.statusController = Qt.binding(function() {
                          if (controller != null) {
                            return  controller.statusBarController;
                          }
                          return null;
                        });
                      } // onLoaded
                    } // Loader

                    CooldownBar {
                      objectName: "cooldownBar"
                      Layout.fillWidth: true
                      Layout.topMargin: TibiaStyle.marginNarrow
                      Layout.leftMargin: TibiaStyle.marginCooldownBar
                      Layout.rightMargin: TibiaStyle.marginCooldownBar
                      visible: false
                    } //CooldownBar

                    Item {
                      Layout.fillWidth: true
                      Layout.preferredHeight: TibiaStyle.marginNarrow
                      //for unknown reasons this item is need to prevent the cooldownAndActionBars ColumnLayout form going
                      //crazy with its height if action and cooldown bars are invisible
                      //this is also the reason to use topMargin instead of spacing
                    } //Item
                  } //ColumnLayout

                  Chat {
                    id: chat
                    objectName: "chat"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    focus: true
                    keepChatInputFocus: false
                    clip: true
                  } //Chat
                } //ColumnLayout
              } //Item
            } // GamewindowSplitView

          } // ColumnLayout

          Item {
            id: rightSidebarPane
            Layout.preferredWidth: rightSidebarPlaceholder.width
            Layout.fillHeight: true

            RowLayout {
              id: rightSidebarPlaceholder
              objectName: "rightSidebarPlaceholder"
              anchors {top: parent.top; bottom: parent.bottom }
              spacing: 0
              layoutDirection: Qt.RightToLeft
            } //RowLayout

            SidebarManager {
              id: rightSidebarManager
              objectName: "rightSidebarManager"
              position: "right"

              anchors.top: parent.top
              anchors.right: parent.left
              anchors.rightMargin: -2
            } //SidebarManager
          } //Item
        } //RowLayout
      } //Item
      Item {
        id: tutorialOverlayAffectedDialogPlaceholder
        anchors.fill: parent
        objectName: "tutorialOverlayAffectedDialogPlaceholder"
      } //Item
      Item {
        id: tutorialOverlay
        anchors.fill: parent
        objectName: "tutorialOverlay"
      } //Item
      Item {
        id: dialogPlaceholder
        anchors.fill: parent
        objectName: "dialogPlaceholder"
      } //Item
    } //FocusScope
    ColumnLayout {
      id: bottomPanelPlaceholder
      objectName: "bottomPanelPlaceholder"
      Layout.fillWidth: true
      Layout.fillHeight: false
    } // ColumnLayout
  }


  SingleObjectAppearanceInstanceRenderer {
    id: dragApperanceInstanceIcon
    objectName: "dragApperanceInstanceIcon"
    width: TibiaStyle.mapWindowPixelPerField
    height: TibiaStyle.mapWindowPixelPerField

    animated: true
  } //SingleObjectAppearanceInstanceRenderer
  RenderDriver {
    objectName: "renderDriver"
  }
} // Item
