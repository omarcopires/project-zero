import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qmlcomponents


FocusScope {
  id: chatRoot
  focus:true

  layer.enabled: UICachingEnabled

  property QtObject chatController: null
  property var chatChannelModel: null
  property var secondaryChatChannelModel: null
  property var chatChannelTabModel: null

  property alias keepChatInputFocus: chatInput.keepChatInputFocus
  property alias currentChatInput: chatInput.currentChatInput
  property alias currentSpeechVolume: chatInput.currentSpeechVolume
  property alias currentSpeechVolumeButtonState: chatInput.currentSpeechVolumeButtonState
  property alias currentChatInputSelectedText: chatInput.currentChatInputSelectedText
  readonly property int tabBarHeight: TibiaStyle.tabBarHeight + TibiaStyle.tabOverlapFakeHeight

  property bool writeToLocalChat: chatChannelModel == null ? true : chatChannelModel.writesToLocalChat

  function onTriggerScrollChatListToEnd() {
    mainChatOutput.scrollViewToEnd();
  } //function onTriggerScrollChatListToEnd()

  function onTriggerScrollSecondaryChatListToEnd() {
    secondaryChatOutput.scrollViewToEnd();
  } //function onTriggerScrollSecondaryChatListToEnd()

  function selectAllChatInput() {
    chatInput.selectAll();
  } //function selectAllChatInput()


  ColumnLayout {
    id: chat
    anchors.fill:parent
    spacing: -TibiaStyle.tabOverlapFakeHeight

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //TAB BAR

    RowLayout {
      id: tabBar
      Layout.fillWidth: true
      implicitHeight: chatRoot.tabBarHeight
      spacing: 0

      TibiaIconButton {
        id: scrollChannelsLeftButton
        Layout.alignment: Qt.AlignTop
        sourceUp: "/images/console-buttonleft-up.png"
        sourceDown: "/images/console-buttonleft-down.png"
        tooltipText: qsTrId("chat_move_channels_right_tooltip")

        hide: channelTabList.atXBeginning

        onClicked: {
          channelTabList.contentX = Math.max(0, channelTabList.contentX-TibiaStyle.chatTabWidth);
        } //onClicked

        state: "IDLE"
        property int buttonHighlight: chatChannelTabModel != null ? chatChannelTabModel.leftButtonHighlight : 0
        onButtonHighlightChanged: {
            //see: gamewindow\chatchanneltabcontroller.h
            //enum class EChatChannelTabHighlight : uint
            //{ NONE = 0, CURRENT = 1, FLASH_NEW_ENTRY = 2, NEW_ENTRY = 3, };

            if (buttonHighlight == 2) {
              state = "FLASHING";
            } else if (buttonHighlight == 3) {
              state = "UPDATE";
            } else {
              state = "IDLE";
            }
        } //onHighlightChanged

        states: [
        State {
            name: "IDLE"
            PropertyChanges { target: scrollChannelsLeftButton; sourceUp: "/images/console-buttonleft-up.png" }
            PropertyChanges { target: scrollChannelsLeftButton; sourceDown: "/images/console-buttonleft-down.png" }
          },
          State {
            name: "FLASHING"
            PropertyChanges { target: scrollChannelsLeftButton; sourceUp: "/images/console-buttonleft-flash-up.png" }
            PropertyChanges { target: scrollChannelsLeftButton; sourceDown: "/images/console-buttonleft-flash-down.png" }
          },
          State {
            name: "UPDATE"
            PropertyChanges { target: scrollChannelsLeftButton; sourceUp: "/images/console-buttonleft-update-up.png" }
            PropertyChanges { target: scrollChannelsLeftButton; sourceDown: "/images/console-buttonleft-update-down.png" }
          }
        ] //states
      } //TibiaIconButton

      Item {
        implicitHeight: TibiaStyle.tabBarHeight + TibiaStyle.tabOverlapFakeHeight
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignBottom

        id: tabDraggingParent
        z:99

        ListView {
          id: channelTabList
          anchors {left: parent.left; top: parent.top; right:parent.right}
          implicitHeight: TibiaStyle.tabBarHeight + TibiaStyle.tabOverlapFakeHeight
          clip: true

          orientation: ListView.Horizontal
          boundsBehavior: Flickable.StopAtBounds
          interactive: false //prevent flick behavior on touch screens
          highlightFollowsCurrentItem: true
          highlightMoveDuration: 0

          model: chatChannelTabModel
          currentIndex: chatChannelTabModel != null ? chatChannelTabModel.currentRowId : -1

          //////////////////////////////////////////////////////////////////////////////////////////
          //FORWARD INFORMATION FOR HILIGHTING NAVIGATION BUTTONS
          onContentWidthChanged: calculateHiddenTabs()
          onContentXChanged: calculateHiddenTabs()
          onWidthChanged: calculateHiddenTabs()

          function calculateHiddenTabs() {
            if(chatChannelTabModel != null) {
              var leftWidthConsidderdAsHidden = contentX + 0.5*TibiaStyle.chatTabWidth;
              var hiddenLeft = Math.floor(leftWidthConsidderdAsHidden/ TibiaStyle.chatTabWidth);

              var rightWidthConsidderdAsHidden = contentWidth - contentX - (channelTabList.width - 0.5*TibiaStyle.chatTabWidth);
              var hiddenRight = Math.floor(Math.max(0, rightWidthConsidderdAsHidden) / TibiaStyle.chatTabWidth);

              chatChannelTabModel.setNumberOfHiddenTabs(hiddenLeft, hiddenRight)
            }
          } //function calculateHiddenTabs()
          //FORWARD INFORMATION FOR HILIGHTING NAVIGATION BUTTONS
          //////////////////////////////////////////////////////////////////////////////////////////

          delegate: MouseArea {
            id: tabDelegate
            objectName: "tabDelegate " + index
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            property bool isCurrentTab: ListView.view.currentIndex === index

            implicitWidth: tabLoader.implicitWidth
            implicitHeight: tabLoader.implicitHeight

            drag.target: tabLoader
            drag.axis: Drag.XAxis
            drag.minimumX: drag.active ? 0 : -Number.MAX_VALUE //trick to allow to drag directly to the left before parent was changed in transition

            property int maxInternalX: channelTabList.width - 1
            property int maxOutsideX: channelTabList.width + rightControllsContainer.width - tabDelegate.width
            property bool allowOutsideDrag: false
            drag.maximumX: allowOutsideDrag ? maxOutsideX : maxInternalX

            property int mouseXOnInsideBound: -1
            onPositionChanged: {
              if (drag.active && tabLoader.x == maxInternalX) {
                if (mouseXOnInsideBound != -1 && Math.abs(mouseXOnInsideBound - mouseX) > TibiaStyle.dragStickTreshold) {
                  allowOutsideDrag = true;
                } else if(mouseXOnInsideBound == -1) {
                  mouseXOnInsideBound = mouseX;
                }
              }
            } //onPositionChanged

            //needed to create dop events
            onReleased: {
              if (drag.target != undefined && drag.active) {
                drag.target.Drag.drop();
              }
            } //onReleased

            z: isCurrentTab ? 1 : -index

            function setTabAsCurrent() {
              chatChannelTabModel.onMakeChannelWithRowIdCurrent(index);
            } //function setTabAsCurrent()


            onPressed: { setTabAsCurrent(); }
            onClicked: (mouse) => {
              setTabAsCurrent();
              chatChannelTabModel.onChannelTabClicked(index, mouse.button, mouse.modifiers);
            } //onClicked

            Loader {
              id: tabLoader

              property int tabIndex: index

              sourceComponent: Image {
                source: isCurrentTab ? "/images/console-tab-active.png" : "/images/console-tab-passive.png"
                smooth: false
                TibiaTabCaption {
                  id: caption
                  anchors { horizontalCenter: parent.horizontalCenter; top: parent.top}
                  anchors.topMargin: TibiaStyle.tabTextTopMarin
                  width: TibiaStyle.chatTabWidth - 2*TibiaStyle.tabTextSideMargin

                  text: channelName
                  highlightMode: tabHighlight
                } //TibiaTabCaption
              } //Image

              Drag.keys: TibiaStyle.dragKeyChatChannelTab
              Drag.active: tabDelegate.drag.active
              Drag.source: tabDelegate

              property real prevX: 0
              property real dragX: 0
              onXChanged: {
                if (Drag.active) {
                  // keep track for the snap back animation
                  dragX = tabDelegate.mapFromItem(tabDraggingParent, tabLoader.x, 0).x;
                  prevX = x;
                }
              } //onXChanged

              Drag.onActiveChanged: {
                if (!Drag.active) {
                  allowOutsideDrag = false;
                  mouseXOnInsideBound = -1;
                }
              } //Drag.onActiveChanged

              state: Drag.active ? "DRAGGING" : ""
              transitions: [
                Transition {
                  to: "DRAGGING"
                  PropertyAction { target: tabLoader; property: "parent"; value: tabDraggingParent }
                }, //Transition
                Transition {
                  from: "DRAGGING"
                  SequentialAnimation {
                    PropertyAction { target: tabLoader; property: "parent"; value: tabDelegate }
                    NumberAnimation {
                      target: tabLoader
                      duration: 50
                      easing.type: Easing.OutQuad
                      property: "x"
                      from: tabLoader.dragX
                      to: 0
                    } //NumberAnimation
                  } //SequentialAnimation
                } //Transition
              ] //transitions
            } //Loader
          } //delegate: MouseArea

        } //ListView


        DropArea {
          anchors.fill: channelTabList
          keys: TibiaStyle.dragKeyChatChannelTab
          onPositionChanged: (drag) => {
            var source = drag.source
            var target = channelTabList.itemAt(channelTabList.contentX + drag.x, drag.y)

            if (source && target && source !== target) {
                source = source.drag.target;
                target = target.drag.target;

                var center = target.parent.x - channelTabList.contentX + target.width / 2

                if (    (source.tabIndex > target.tabIndex && source.x < center)
                     || (source.tabIndex < target.tabIndex && source.x + source.width > center)) {

                    if(chatChannelTabModel != null) {
                      chatChannelTabModel.moveTab(source.tabIndex, target.tabIndex);
                    }
                }
            }
          } //onPositionChanged
        } //DropArea
      } //Item

      Item {
        id: rightControllsContainer
        Layout.preferredWidth: rightControllsLayout.width
        Layout.preferredHeight: rightControllsLayout.height

        RowLayout {
          id: rightControllsLayout
          spacing: 0

          TibiaIconButton {
            id: scrollChannelsRightButton
            Layout.alignment: Qt.AlignTop
            sourceUp: "/images/console-buttonright-up.png"
            sourceDown: "/images/console-buttonright-down.png"
            tooltipText: qsTrId("chat_move_channels_left_tooltip")

            hide: channelTabList.atXEnd
            onClicked: {
              var newContentX = channelTabList.contentX + TibiaStyle.chatTabWidth;
              if (newContentX + channelTabList.width > channelTabList.contentWidth) {
                channelTabList.positionViewAtEnd();
              } else {
                channelTabList.contentX = newContentX;
              }
            } //onClicked

            state: "IDLE"
            property int buttonHighlight: chatChannelTabModel != null ? chatChannelTabModel.rightButtonHighlight : 0
            onButtonHighlightChanged: {
                //see: gamewindow\chatchanneltabcontroller.h
                //enum class EChatChannelTabHighlight : uint
                //{ NONE = 0, CURRENT = 1, FLASH_NEW_ENTRY = 2, NEW_ENTRY = 3, };

                if (buttonHighlight == 2) {
                  state = "FLASHING";
                } else if (buttonHighlight == 3) {
                  state = "UPDATE";
                } else {
                  state = "IDLE";
                }
            } //onHighlightChanged

            states: [
            State {
                name: "IDLE"
                PropertyChanges { target: scrollChannelsRightButton; sourceUp: "/images/console-buttonright-up.png" }
                PropertyChanges { target: scrollChannelsRightButton; sourceDown: "/images/console-buttonright-down.png" }
              },
              State {
                name: "FLASHING"
                PropertyChanges { target: scrollChannelsRightButton; sourceUp: "/images/console-buttonright-flash-up.png" }
                PropertyChanges { target: scrollChannelsRightButton; sourceDown: "/images/console-buttonright-flash-down.png" }
              },
              State {
                name: "UPDATE"
                PropertyChanges { target: scrollChannelsRightButton; sourceUp: "/images/console-buttonright-update-up.png" }
                PropertyChanges { target: scrollChannelsRightButton; sourceDown: "/images/console-buttonright-update-down.png" }
              }
            ] //states

          } //TibiaIconButton

          TibiaIconButton {
            id: closeChannelButton
            Layout.alignment: Qt.AlignTop
            sourceUp: "/images/console-buttonclose-up.png"
            sourceDown: "/images/console-buttonclose-down.png"
            tooltipText: qsTrId("chat_close_channel_tooltip")

            hide: chatChannelModel == null ? true : !chatChannelModel.canBeClosed

            onClicked: {
             if(chatChannelModel != null) {
              chatChannelModel.closeChannel();
             }
            } //onClicked
          } //TibiaIconButton

          TibiaIconButton {
            id: subscribeServerMessagesButton
            Layout.alignment: Qt.AlignTop
            sourceUp: "/images/console-buttonmessages-up.png"
            sourceDown: "/images/console-buttonmessages-down.png"
            tooltipText: qsTrId("chat_show_server_messages_tooltip")
            tooltipTextChecked: qsTrId("chat_hide_server_messages_tooltip")

            checkable: true
            useButtonShouldBeChecked: true

            hide: chatChannelModel != null && !chatChannelModel.canSubscribeToServerLog
            onClicked: {
             if(chatChannelModel != null) {
              chatChannelModel.setSubscribeToServerLog(!chatChannelModel.isSubscribedToServerLog);
             }
            } //onClicked
            buttonShouldBeChecked: chatChannelModel != null && chatChannelModel.isSubscribedToServerLog
          } //TibiaIconButton

          TibiaIconButton {
            id: openChatChannelDialogButton
            Layout.alignment: Qt.AlignTop
            sourceUp: "/images/console-buttonnew-up.png"
            sourceDown: "/images/console-buttonnew-down.png"
            tooltipText: qsTrId("chat_open_channel_tooltip")

            onClicked: {
             if(chatController != null) {
              chatController.requestChannelList();
             }
            } //onClicked
          } //TibiaIconButton

          TibiaIconButton {
            id: showIgnorelistButton
            Layout.alignment: Qt.AlignTop
            property bool flash: chatController != null ? chatController.messageIgnoredFlash : false
            sourceUp: flash ? "/images/console-buttonignore-up-flash.png" : "/images/console-buttonignore-up.png"
            sourceDown: "/images/console-buttonignore-down.png"
            tooltipText: qsTrId("chat_open_black_whitelist_tooltip")

            onClicked: chatController != null ? chatController.openWhiteBlacklistDialog() : undefined
          } //TibiaIconButton

          Item {
            Layout.alignment: Qt.AlignTop
            Layout.preferredWidth: showIgnorelistButton.width
            Layout.preferredHeight: showIgnorelistButton.height

            TibiaButton {
              id: showExivaOptionsButton
              anchors.fill: parent
              property bool flash: chatController != null ? chatController.exivaSuppressedFlash : false
              enabled: chatController != null ? chatController.exivaOptionsAvailable : true

              imageSource: flash ? "/images/icon-exiva-flash.png" : "/images/icon-exiva.png"
              imageSourceDisabled: "/images/icon-exiva-disabled.png"
              tooltipText: qsTrId("chat_open_exiva_options_tooltip")

              onClicked: chatController != null ? chatController.openExivaOptionsDialog() : undefined
            } //TibiaButton

            Tooltip {
              anchors.fill: parent
              enabled: !showExivaOptionsButton.enabled
              text: qsTrId("chat_open_exiva_options_disabled_tooltip")
            } //Tooltip
          } //Item

          Image {
            Layout.leftMargin: TibiaStyle.marginNarrow
            Layout.rightMargin: TibiaStyle.marginNarrow

            source: chatRoot.secondaryChatChannelModel != null ? "/images/console-tab-active.png" : "/images/console-tab-passive.png"
            smooth: false
            MouseArea {
              anchors.fill: parent
              acceptedButtons: Qt.LeftButton | Qt.RightButton

              onClicked: (mouse) => {
                chatController.onSecondaryChannelClicked(mouse.button, mouse.modifiers);
              } //onClicked
            } //MouseArea

            Image {
              anchors.centerIn: parent
              source: "/images/icon-splitchat.png"
              visible: chatRoot.secondaryChatChannelModel == null
              smooth: false
            } //Image

            TibiaTabCaption {
              anchors { horizontalCenter: parent.horizontalCenter; top: parent.top}
              anchors.topMargin: TibiaStyle.tabTextTopMarin
              width: TibiaStyle.chatTabWidth - 2*TibiaStyle.tabTextSideMargin

              text: chatRoot.secondaryChatChannelModel != null ? chatRoot.secondaryChatChannelModel.channelName : ""
              highlightMode: chatRoot.secondaryChatChannelModel != null ? 1 : 0
            } //TibiaTabCaption

            Rectangle {
              anchors.fill: parent
              visible: secondaryChatChannelDropArea.containsDrag
              color: "transparent"
              border.width: 1
              border.color: "white"
            } //Rectangle

            Tooltip {
              anchors.fill: parent
              text: qsTrId("chat_secondary_chat_channel_drop_area_tooltip")
            } //Tooltip
          } //Image
        } //RowLayout

        DropArea {
          id: secondaryChatChannelDropArea
          anchors.fill: parent
          keys: TibiaStyle.dragKeyChatChannelTab

          onDropped: (drop) => {
            if (drag.source && chatController != null) {
              chatController.onSelectTabAsSecondaryChannel(drag.source.drag.target.tabIndex);
            }
          } //onDropped
        } //DropArea
      } //Item
    } //RowLayout

    //TAB BAR
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //CHAT OUTPUT

    Item {
      id: chatConsole
      Layout.fillWidth: true
      Layout.fillHeight: true
      z: tabBar.z -1

      TibiaFrame2PixelUpFilled {
        anchors.fill: parent
        pinnedToBottom: true
      } //TibiaFrame2PixelUpFilled

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: TibiaStyle.chatBackgroundToFrameMargin
        spacing: TibiaStyle.chatGuiMargins

        SplitView {
          id: chatOutputSplitView
          readonly property int handleWidth: TibiaStyle.marginNarrow
          readonly property int preferredWidthForSplit: (width - handleWidth) / 2
          Layout.fillWidth: true
          Layout.fillHeight: true

          handle: Item {
            implicitWidth: chatOutputSplitView.handleWidth

            HoverHandler {
              onHoveredChanged: {
                if (tibiaMouseCursorController != null) {
                  tibiaMouseCursorController.setResizeHorizontal(hovered)
                }
              }
            } // HoverHandler
          } //handle: Item

          TibiaFrame3Pixel {
            SplitView.fillWidth: true
            SplitView.minimumWidth: 100
            SplitView.fillHeight: true

            TibiaScrollView  {
              anchors.fill: parent
              anchors.margins: TibiaStyle.consoletextFrameBorderWidth

              verticalScrollBarPolicy: ScrollBar.AlwaysOn
              horizontalScrollBarPolicy: ScrollBar.AlwaysOff

              ChatOutput {
                id: mainChatOutput
                leftMargin: TibiaStyle.chatTextToFrameMargin
                rightMargin: TibiaStyle.chatTextToFrameMargin

                chatController: chatRoot.chatController
                chatChannelModel: chatRoot.chatChannelModel
              } //ChatOutput
            } //ScrollView
          } //TibiaFrame3Pixel

          TibiaFrame3Pixel {
            SplitView.minimumWidth: 100
            SplitView.fillHeight: true
            SplitView.preferredWidth: chatOutputSplitView.preferredWidthForSplit

            visible: chatRoot.secondaryChatChannelModel != null
            onVisibleChanged: {
              if (visible) {
                width = parent.width * 0.5;
              }
            } //onVisibleChanged

            TibiaScrollView  {
              anchors.fill: parent
              anchors.margins: TibiaStyle.consoletextFrameBorderWidth

              verticalScrollBarPolicy: ScrollBar.AlwaysOn
              horizontalScrollBarPolicy: ScrollBar.AlwaysOff

              ChatOutput {
                id: secondaryChatOutput
                leftMargin: TibiaStyle.chatTextToFrameMargin
                rightMargin: TibiaStyle.chatTextToFrameMargin

                chatController: chatRoot.chatController
                chatChannelModel: chatRoot.secondaryChatChannelModel

                onRequestDeselectChatInput: {
                  chatInput.deslect()
                } //onRequestDeselectChatInput
              } //ChatOutput
            } //ScrollView
          } //TibiaFrame3Pixel
        } //SplitView

        //CHAT OUTPUT
        ////////////////////////////////////////////////////////////////////////////////////////////////////////
        //CHAT INPUT

        ChatInput {
          id: chatInput
          Layout.fillWidth: true

          chatController: chatRoot.chatController
          chatChannelModel: chatRoot.chatChannelModel
          writeToLocalChat: chatRoot.writeToLocalChat
        } //ChatInput

       //CHAT INPUT
       ////////////////////////////////////////////////////////////////////////////////////////////////////////
      } //ColumnLayout
    } //Item
  } //ColumnLayout

  Lenshelp {
    x: tabBar.x
    y: tabBar.y
    width: tabBar.width
    height: tabBar.height
    z: 100
    caption: qsTrId("chat_tab_lenshelp_caption")
    content: qsTrId("chat_tab_lenshelp")
  } //Lenshelp

  Lenshelp {
    x: chatConsole.x
    y: chatConsole.y
    width: chatConsole.width
    height: chatConsole.height
    z: 100
    caption: qsTrId("chat_lenshelp_caption")
    content: qsTrId("chat_lenshelp")
  } //Lenshelp

} //FocusScope
