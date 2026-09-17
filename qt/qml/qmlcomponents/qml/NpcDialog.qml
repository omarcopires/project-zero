import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.LegacyControls

import qmlcomponents

TibiaDialog {
  id: root
  caption: controller.talkPartnerNames
  flagCaption: true
  dialogClip: false
  resizeable: true
  remembersPosition: true

  width: 600
  minWidth: leftPadding
    + TibiaStyle.dialogMarginBorder
    + chatMinWidth
    + addonDialogExtraWidth
    + TibiaStyle.dialogMarginBorder
  minHeight: 350

  required property var controller
  property QtObject chatController: controller.chatController

  property alias keepChatInputFocus: chatInput.keepChatInputFocus
  property alias currentChatInput: chatInput.currentChatInput
  property alias currentChatInputSelectedText: chatInput.currentChatInputSelectedText

  readonly property int addonWidth: 180
  readonly property int chatMinWidth: (talkButtonLayout.keywordButtonSize + talkButtonLayout.spacing) * 6 + talkButtonLayout.keywordButtonSize
  readonly property int addonDialogExtraWidth: tradeLayout.width + contentLayout.spacing
  readonly property rect positionAndSize: controller.positionAndSize

  leftPadding: Math.max(0, (-outOfBoundAnchor.leftOutOfBound) - TibiaStyle.dialogMarginBorder)
  rightPadding: addonDialogExtraWidth
  topPadding: Math.max(0, (-outOfBoundAnchor.topOutOfBound) - topMarginsToContent)

  initialFocusItem: chatInput

  opacity: controller.hasFocus || controller.tradeHasFocus ? 1.0 : 0.90

  onReturnPressedFunction: function() {}

  onCancelPressedFunction: function() {
    //this is never triggered as ESC is consumed by event system
    controller.closeButtonPressed();
  } //onCancelPressedFunction

  customButtonComponent: RowLayout {
    spacing: 0
    TibiaIconButton {
      id: contextMenuButton
      sourceUp:   "/images/skin/classic/button-contextmenu-12x12-idle.png"
      sourceDown: "/images/skin/classic/button-contextmenu-12x12-pressed.png"
      tooltipText: qsTrId("npc_trade_configure_tooltip")

      visible: controller.showTrade
      onClicked: controller.tradeController.contextMenuForObject(0, 0)
    } //TibiaIconButton
  } //customButtonComponent: RowLayout

  readonly property bool addonVisible: controller.showTrade
  onAddonVisibleChanged: {
    startResizing();
    if (addonVisible) {
      rightPadding = 0;
    } else {
      rightPadding = addonDialogExtraWidth;
    }

    tradeLayout.visible = controller.showTrade;

    finishResizing();
  } //onAddonVisibleChanged


  onResizeRequest: (newDialogWidth, newContentHeight) => {
    controller.onSizeChanged(newDialogWidth, newContentHeight);
  } //onResizeRequest

  onPositionChanged: (x, y) => {
    controller.onPositionChanged(x, y);
  } //onPositionChanged

  onPositionAndSizeChanged: {
    startResizing();

    if (minWidth <= positionAndSize.width) {
      root.width = positionAndSize.width;
    }

    if (0 < positionAndSize.height) {
      contentLayout.height = positionAndSize.height;
    }
    finishResizing();

    if (0 <= positionAndSize.x
      && 0 <= positionAndSize.y) {
      x = positionAndSize.x;
      y = positionAndSize.y;
    } else {
      centerDialog(true);
    }
  } //onPositionAndSizeChanged

  function selectAllChatInput() {
    chatInput.selectAll();
  } //function selectAllChatInput()

  RowLayout {
    id: contentLayout
    anchors { left: parent.left; right: parent.right; top: parent.top;}
    spacing: TibiaStyle.marginUnrelated

    height: 350

    ColumnLayout {
      id: mainColumnLayout
      Layout.fillHeight: true
      Layout.fillWidth: true

      spacing: TibiaStyle.marginRelated

      TibiaFrame3Pixel {
        Layout.fillHeight: true
        Layout.fillWidth: true

        Item {
          id: outOfBoundAnchor
          height: 33
          width: podestalImage.width - 4
          z: 10

          readonly property int leftOutOfBound: (width - podestalImage.width)
            + (podestalImage.width - npcOutfit.width)
            - npcOutfit.anchors.rightMargin

          readonly property int topOutOfBound: (height - podestalImage.height)
            + (podestalImage.height - npcOutfit.height)
            - npcOutfit.anchors.bottomMargin

          Image {
            id: podestalImage
            source: "/images/backdrop-npcdialog-podestal.png"
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            OutfitAppearanceInstanceRenderer {
              id: npcOutfit
              width: 64
              height: 64
              anchors.right: parent.right
              anchors.bottom: parent.bottom
              anchors.rightMargin: 14
              anchors.bottomMargin: 15
              visible: !controller.isMultiNpcTalk

              outfitId: controller.npcOutfit.outfitID
              headColor: controller.npcOutfit.colors.headColor
              legsColor: controller.npcOutfit.colors.legsColor
              torsoColor: controller.npcOutfit.colors.torsoColor
              detailColor: controller.npcOutfit.colors.detailColor
              firstAddOn: controller.npcOutfit.firstAddOn
              secondAddOn: controller.npcOutfit.secondAddOn
              outfitIsObject: controller.npcOutfit.isObjectOutfit
            } //OutfitAppearanceInstanceRenderer

            Image {
              id: npcOutifFallback
              source: "/images/icon-npcdialog-multiplenpcs.png"
              anchors.right: parent.right
              anchors.bottom: parent.bottom
              anchors.rightMargin: npcOutfit.anchors.rightMargin
              anchors.bottomMargin: npcOutfit.anchors.bottomMargin
              visible: controller.isMultiNpcTalk
            } //Image
          } //Image
        } //Item


        TibiaScrollView  {
          anchors.fill: parent
          anchors.margins: TibiaStyle.consoletextFrameBorderWidth

          verticalScrollBarPolicy: ScrollBar.AlwaysOn
          horizontalScrollBarPolicy: ScrollBar.AlwaysOff

          ChatOutput {
            id: chatOutput
            leftMargin: TibiaStyle.chatTextToFrameMargin
            rightMargin: TibiaStyle.chatTextToFrameMargin

            chatController: root.controller
            chatChannelModel: root.controller.chatChannelModel

            onRequestDeselectChatInput: {
              chatInput.deselect();
            } //onRequestDeselectChatInput
          } //ChatOutput
        } //ScrollView
      } //TibiaFrame3Pixel

      Item {
        clip: true
        Layout.fillWidth: true
        Layout.preferredHeight: talkButtonLayout.height

        RowLayout {
          id: talkButtonLayout
          Layout.maximumWidth: mainColumnLayout.width
          Layout.preferredHeight: keywordButtonSize
          spacing: TibiaStyle.marginRelated
          visible: talkButtonRepeater.count > 0

          readonly property int keywordButtonSize: 32 + 3

          Repeater {
            id: talkButtonRepeater
            model: controller.keywordButtonsModel

            TibiaButton {
              Layout.preferredWidth: talkButtonLayout.keywordButtonSize
              Layout.preferredHeight: talkButtonLayout.keywordButtonSize
              imageXOffset: -1
              imageYOffset: -1
              imageSource: buttonImage
              tooltipText: keyword

              onClicked: {
                controller.sendKeyword(keyword);
              } //onClicked
            } //TibiaButton
          } //Repeater
        } //RowLayout
      } //Item

      ChatInput {
        id: chatInput
        Layout.fillWidth: true

        chatController: root.chatController
        chatChannelModel: root.controller.chatChannelModel
        showSpeechVolumeButton: false

        keepChatInputFocus: controller.hasFocus && !controller.tradeHasFocus
      } //ChatInput
    } //ColumnLayout

    RowLayout {
      id: tradeLayout
      spacing: TibiaStyle.marginUnrelated
      visible: false

      TibiaVerticalSeparator {
        id: vSpacer
        Layout.fillHeight: true
      } //TibiaVerticalSeparator

      NpcTrade {
        objectName: "npcTrade"
        Layout.fillHeight: true
        Layout.preferredWidth: root.addonWidth
        Layout.maximumWidth: Layout.preferredWidth

        tradeController: controller.tradeController

        onRequestTakeFocus: {
          controller.onTradeRequestTakeFocus();
        } //onRequestTakeFocus

        onRequestReleaseFocus: {
          controller.onTradeRequestReleaseFocus();
        } //onRequestReleaseFocus

        Rectangle {
          id: highlightFrame
          anchors.fill: parent
          anchors.margins: -TibiaStyle.marginRelated
          visible: controller.tradeHasFocus
          color: "transparent"
          border.width: 2
          border.color: "white"
        } //Rectangle
      } //NpcTrade
    } //RowLayout
  } //RowLayout
} // TibiaDialog
