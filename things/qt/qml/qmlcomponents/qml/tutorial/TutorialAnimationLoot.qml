import QtQuick
import QtQuick.Layouts

import qmlcomponents
import "qrc:/qt/qml/qmlcomponents/qml/"

Item {
  id: rootDialog

  signal finished()

  required property var tutorialType

  property alias running: tutorialAnimation._startPending

  states: [
      State {
          name: "looting"
          when: tutorialType == TutorialEnums.TutorialType.Looting;
          PropertyChanges { target: leftStackLayout; currentIndex: 0 }
          PropertyChanges { target: rightStackLayout; currentIndex: 0 }
      },
      State {
          name: "selling"
          when: tutorialType == TutorialEnums.TutorialType.Selling;
          PropertyChanges { target: leftStackLayout; currentIndex: 1 }
          PropertyChanges { target: rightStackLayout; currentIndex: 1 }
      },
      State {
          name: "bank"
          when: tutorialType == TutorialEnums.TutorialType.Bank;
          PropertyChanges { target: leftStackLayout; currentIndex: 2 }
          PropertyChanges { target: rightStackLayout; currentIndex: 3 }
      }
  ]

  property var tutorialMarkers: {
    "monster": {
      "id": tutorialWorldMapCombat.monsterTutorialMarkerID,
      "marker": null
    },
    "npc": {
      "id": tutorialWorldmapLoot.npcTutorialMarkerID,
      "marker": null
    },
    "npcBank": {
      "id": tutorialWorldmapBank.npcTutorialMarkerID,
      "marker": null
    },
    "monsterLootbagLoot": {
      "id": TutorialHelper.nextUniqueTutorialMarkerID(),
      "marker": null
    },
    "playerBagSlot": {
      "id": TutorialHelper.nextUniqueTutorialMarkerID(),
      "marker": null
    },
    "npcTradeOKButton": {
      "id": TutorialHelper.nextUniqueTutorialMarkerID(),
      "marker": null
    },
  }

  Component.onCompleted: {
    Qt.callLater( () => {
      resetAnimation();
    });
  }

  function findTutorialMarkers() {
    Object.entries(tutorialMarkers).forEach(([key, value]) => {
      value.marker = TutorialHelper.findTutorialMarkerQuickItemWithID(value.id);
    });
  }

  function restartAnimation() {
    tutorialAnimation.stop();

    Qt.callLater( () => {
      switch (rootDialog.tutorialType) {
        case TutorialEnums.TutorialType.Looting:
          tutorialAnimation.createTutorialLootingAnimation();
          break;
        case TutorialEnums.TutorialType.Selling:
          tutorialAnimation.createTutorialSellingAnimation();
          break;
        case TutorialEnums.TutorialType.Bank:
          tutorialAnimation.createTutorialBankAnimation();
          break;
      }
      tutorialAnimation.restart();
    });
  }

  function resetAnimation() {
    if (tutorialAnimation) {
      tutorialAnimation.stop();
    }
    switch (rootDialog.tutorialType) {
      case TutorialEnums.TutorialType.Looting:
        tutorialAnimation.resetTutorialLootingAnimation();
        break;
      case TutorialEnums.TutorialType.Selling:
        tutorialAnimation.resetTutorialSellingAnimation();
        break;
      case TutorialEnums.TutorialType.Bank:
        tutorialAnimation.resetTutorialBankAnimation();
        break;
    }
  }

  function stopAnimation() {
    tutorialAnimation.stop();
    animationPlaceholder.stop();
    animationPlaceholder.animations = [];
  }

  QtObject {
    id: appearances
    readonly property int worthlessLoot: AppearanceTypeHelper.getObjectAppearanceTypeIDByName("insectoid eggs")
    readonly property int valuableLoot: AppearanceTypeHelper.getObjectAppearanceTypeIDByName("brass helmet")
    readonly property int blankRune: AppearanceTypeHelper.getObjectAppearanceTypeIDByName("blank rune")
    readonly property int goldCoin: AppearanceTypeHelper.getObjectAppearanceTypeIDByName("gold coin")
    readonly property int bag: AppearanceTypeHelper.getObjectAppearanceTypeIDByName("classic bag")
    readonly property int deadSalamander: 17427 // has no name in appearances.dat
  }

  component TutorialFakeContainer: Loader {
    id: root
    property alias caption: containerControllerMock.caption
    property alias numberOfContainerSlots: containerControllerMock.numberOfContainerSlots
    property alias objectID: containerControllerMock.objectID
    property alias tutorialMarkerIDs: containerControllerMock.tutorialMarkerIDs

    source: "qrc:/qt/qml/qmlcomponents/qml/container.qml"
    Component.onCompleted: {
      item.widgetController = containerControllerMock;
      item.showHighlightFlash = false;
    }

    function getTutorialMarkerForSlot(slotIndex) {
      if (slotIndex < containerControllerMock.tutorialMarkerIDs.length) {
        return containerControllerMock.tutorialMarkerIDs[slotIndex];
      }
      return 0;
    }
    function generateContainerContent(items) {
      containerControllerMock.generateContainerContent(items);
    }
    function setTutorialMarkerOnSlot(slot, tutorialMarkerID) {
      var newTutorialMarkerIDs = containerControllerMock.tutorialMarkerIDs;
      while (newTutorialMarkerIDs.length < slot) {
        newTutorialMarkerIDs.push(0);
      }
      newTutorialMarkerIDs[slot] = tutorialMarkerID;
      containerControllerMock.tutorialMarkerIDs = newTutorialMarkerIDs;
    }

    QtObject {
      id: containerControllerMock

      property var caption: ""
      property int objectID: 0
      property int objectCount: 0
      property int currentPage: 0
      property int numberOfPages: 0
      property int numberOfContainerSlots: 0
      property int numberOfFilledContainerSlots: 0
      property int indexOfFirstVisibleObject: 0
      property bool isUpdatable: false
      property bool hasPossiblyMorePages: false
      property bool searchButtonVisible: false
      property bool configButtonVisible: false
      property bool levelUpButtonVisible: false
      property bool isInManualSortMode: false
      property var liquidType: ObjectAppearanceInstance.EMPTY
      property var hookDirection: ObjectAppearanceInstance.NONE
      property var tutorialMarkerIDs: []
      property var appearanceTypeListModel
      property int parentSidebarId: 255
      property int decoItemObjectID: 0
      property var gameWindowQuickItem: root

      function generateContainerContent(items) {
        numberOfFilledContainerSlots = items.length
        var itemsModel = AbstractItemModelHelper.createDynamicAbstractListModel(["alternativeSlotString", "lootContainerTooltip", "lootvalueImageSourceUnderItem", "lootvalueImageSourceOverItem", "typeID", "upgradeTier", "cumulativeCount", "liquideType", "hookDirection", "decoItemObjectID"]);
        var offset = 0;
        for (var i = 0; i < numberOfContainerSlots; ++i) {
          var itemTemplate = items[i];
          var newItem = {
            "alternativeSlotString": "",
            "lootContainerTooltip": "",
            "lootvalueImageSourceUnderItem": null,
            "lootvalueImageSourceOverItem": null,
            "typeID": 0,
            "upgradeTier": 0,
            "cumulativeCount": 0,
            "liquideType": ObjectAppearanceInstance.EMPTY,
            "hookDirection": ObjectAppearanceInstance.NONE,
            "decoItemObjectID": 0
          };
          if (currentPage === 0 && i >= offset && (i - offset) < numberOfFilledContainerSlots) {
            for (var property in itemTemplate) {
              newItem[property] = itemTemplate[property];
            }
          }
          itemsModel.appendRow(newItem);
        }
        this.appearanceTypeListModel = itemsModel;
      }

      function setCursorToResizeVertical() {
      }

      function onNextPageClicked() {
        currentPage = currentPage < numberOfPages ? currentPage + 1 : currentPage;
        updateContainerContent();
      }

      function onPreviousPageClicked() {
        currentPage = currentPage > 1 ? currentPage - 1 : currentPage;
        updateContainerContent();
      }

      function updateIndexOfFirstVisibleObject() {
        indexOfFirstVisibleObject = numberOfContainerSlots * (currentPage - 1);
      }

      function updateContainerContent() {
        updateIndexOfFirstVisibleObject();
      }

      function bindControllerToItem(item) {
        item.nextPageClicked.connect(controllerMock.onNextPageClicked);
        item.previousPageClicked.connect(controllerMock.onPreviousPageClicked);
      }

      Component.onCompleted: {
        generateContainerContent([]);
      }
    }
  }

  component FakeNPCTrade: Loader {
    id: root
    // property var initialContentHeight: item != null ? item.initialContentHeight : 0
    // property var implicitWidth: 200 // item != null ? item.implicitWidth : 0
    property alias okButtonTutorialMarker: npcTradeWidgetController.okButtonTutorialMarker

    source: "qrc:/qt/qml/qmlcomponents/qml/NpcTradeWidget.qml"
    function tryShrinkLowerWidgets() {
    }
    onItemChanged: {
      if (item) {
        item.widgetController = npcTradeWidgetController;
        item.showHighlightFlash = false;
        item.tryChangeHeightTo(300);
      }
    }

    QtObject {
      id: npcTradeWidgetController

      signal requestSaveScrollPositionAndRestoreAfterTradableGoodsListUpdate()
      signal requestPositionViewAtBeginning()

      property var gameWindowQuickItem: root

      property int parentSidebarId: 0

      property int amountPreselected: 1
      property bool hasFocus: false
      property int currencyTypeId: 0
      property string currencyName: qsTrId("gold_coin")
      property bool npcIsBuying: false
      property bool showNameFilter: true
      property int buyOrSellPrice: 30
      property int totalBalance: 1
      property bool currencyIsGold: true
      property int okButtonTutorialMarker: 0

      property var traderInventoryModel: []

      Component.onCompleted: {
        createModel();
      }

      function setCursorToResizeVertical() { }


      function createModel() {
        var model = AbstractItemModelHelper.createDynamicAbstractListModel(["appearanceID", "liquidType", "hookDirection", "canBeTraded", "maximumTradeAmount", "name", "priceAndWeight", "tradePrice", "weight"]);

        for (var i = 0; i < 1; ++i) {
          var newItem = {
            "appearanceID": 0,
            "liquidType": 0,
            "hookDirection": 0,
            "canBeTraded": true,
            "maximumTradeAmount": 0,
            "name": "",
            "priceAndWeight": "",
            "tradePrice": 0,
            "weight": 0
          };
          if (i == 0) {
            newItem.appearanceID = appearances.valuableLoot;
            newItem.name = "brass helmet";
            newItem.priceAndWeight = "Price 30, 27,00 oz";
            newItem.maximumTradeAmount = "1";
          }
          model.appendRow(newItem);
        }
        this.traderInventoryModel = model;

      }
    }
  }

  component FakeChat:
    Item {
      signal typingFinished()

      property var chatLines: []

      property string _pendingChatInputText: ""
      readonly property bool chatInputRunning: chatInputTimer.running

      function clearChat() {
        chatLines = [];
        refreshChatlinesText();
      }

      function addChatline(color, text) {
        var htmlText = text.replace(/\n/g, "<br/>");
        var hexColor = color.toString().slice(1, 7);
        var colorEncodedText = "{#" + hexColor + "|" + htmlText + "}"
        var coloredText = TextHelper.replaceColorCodingsWithHtmlTags(colorEncodedText);
        chatLines.push(coloredText);
        refreshChatlinesText();
      }

      function refreshChatlinesText() {
        var chatString = chatLines.join("<br/>");
        chatLinesText.text = chatString;
      }

      function addTypedText(text, duration) {
        _pendingChatInputText = text;
        chatInput.text = "";
        chatInputTimer.currentIndex = 0;
        chatInputTimer.start();
        blinkTimer.start();
      }

      Timer {
        id: chatInputTimer
        property int currentIndex: 0
        interval: 200
        repeat: true
        onTriggered: {
          if (currentIndex < _pendingChatInputText.length) {
            chatInput.text += _pendingChatInputText.charAt(currentIndex);
            currentIndex++;
          } else {
            chatInputTimer.stop();
            typingFinished();
          }
        }
      }

      function confirmTypedText() {
        blinkTimer.stop();
        simulatedCursor.visible = false;
        chatInput.text = "";
      }

      Timer {
        id: blinkTimer
        interval: 500 // 500ms Blinkintervall
        running: true
        repeat: true
        onTriggered: {
          simulatedCursor.visible = !simulatedCursor.visible
        }
      }

      implicitHeight: chatBlockLayout.height
      ColumnLayout {
        id: chatBlockLayout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        spacing: 0
        Item {
          id: chatlinesWrapper
          Layout.fillWidth: true
          Layout.preferredHeight: 39
          Layout.bottomMargin: TibiaStyle.marginRelated
          clip: true
          TibiaText {
            id: chatLinesText
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            wrapMode: Text.Wrap
          }
        }
        Item {
          id: chatInputLayoutWrapper
          Layout.fillWidth: true
          Layout.preferredHeight: chatInputLayout.height + 4
          TibiaFrame2PixelUpFilled {
            anchors.fill: parent
          }
          RowLayout {
            id: chatInputLayout
            spacing: TibiaStyle.chatGuiMargins
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 2

            TibiaButton {
              id: speechVolumeButton
              Layout.preferredHeight: chatInput.height
              Layout.preferredWidth: height

              imageSource: "/images/icon-speech-say.png"
              tooltipText: qsTrId("chat_adjust_speech_volume_tooltip")
              property int speechVolume: 0

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
              color: TibiaStyle.textColors["Default"]
              enabled: false

              Rectangle { // Simulierter Cursor
                id: simulatedCursor
                width: 1
                height: chatInput.font.pixelSize
                color: "white"
                anchors.verticalCenter: chatInput.verticalCenter
                x: textMetrics.width + 6 // Nach dem Text positionieren
                visible: false

                TextMetrics {
                  id: textMetrics
                  font: chatInput.font
                  text: chatInput.text
                }
              }
            } //TibiaTextField

            TibiaButton {
              id: chatEnabledButton
              Layout.preferredHeight: TibiaStyle.textFieldHeight
              Layout.preferredWidth: TibiaStyle.buttonWidthBroad

              text: qsTrId("chat_mode_on")
              tooltipText: qsTrId("chat_mode_button_tooltip")
            } //TibiaIconButton
          } //RowLayout
        }
      }
    }


  ColumnLayout {
    id: animationWrapper
    anchors.left: parent.left
    anchors.right: parent.right
    RowLayout {

      ColumnLayout {
        StackLayout {
          id: leftStackLayout
          Layout.alignment: Qt.AlignHCenter
          Item {
            Layout.fillHeight: true
            TutorialFakeContainer {
              id: monsterLootbag
              visible: false
              anchors.bottom: parent.bottom
              caption: "Dead Salamander"
              objectID: appearances.deadSalamander
              numberOfContainerSlots: 4
            }
          }
          Item {
            Layout.preferredHeight: 32 * 4
            Layout.fillWidth: true
            TutorialWorldmapLoot {
              id: tutorialWorldmapLoot
              anchors.horizontalCenter: parent.horizontalCenter
              anchors.horizontalCenterOffset: -16
              anchors.leftMargin: 32
              Component.onCompleted: {
                showTraderAndPlayer();
              }
            }
          }
          Item {
            Layout.preferredHeight: 32 * 4
            Layout.fillWidth: true
            TutorialWorldmapLoot {
              id: tutorialWorldmapBank
              anchors.horizontalCenter: parent.horizontalCenter
              anchors.horizontalCenterOffset: -16
              Layout.preferredHeight: 32 * 4
              Component.onCompleted: {
                showBankerAndPlayer();
              }
            }
          }
        }
        TutorialFakeContainer {
          id: playerBag
          caption: "Bag"
          objectID: appearances.bag
          numberOfContainerSlots: 4
        }
      }
      ColumnLayout {
        StackLayout {
          id: rightStackLayout
          Layout.fillHeight: true
//            Layout.maximumWidth: currentIndex == 1 ?  fakeNPCTrade.width : tutorialWorldMapCombat.width + 16
          ColumnLayout {
            TutorialWorldmapCombat {
              id: tutorialWorldMapCombat
              worldmapFieldsX: 2
              monsterHUDVisible: false
              Component.onCompleted: {
                showMonsterCorpseAndPlayer();
              }
            }
          }
          ColumnLayout {
            spacing: 0
            Item {
              Layout.fillHeight: true
            }
            FakeNPCTrade {
              id: fakeNPCTrade
              visible: false
              Component.onCompleted: {
                fakeNPCTrade.okButtonTutorialMarker = tutorialMarkers.npcTradeOKButton.id;
              }
            }
          }
          Item {
            Layout.preferredWidth: fakeNPCTrade.width
          }
          Item {
            Layout.fillWidth: true
          }
        }
      }
    }
    ColumnLayout {
      Layout.fillWidth: true
      Layout.topMargin: -6
      Item {
        // needed to fill the available width for the FakeChat
        Layout.fillWidth: true
      }
      FakeChat {
        id: fakeChat
        Layout.fillWidth: true
        visible: false

      }
    }
  }

  Connections {
    target: fakeChat
    function onTypingFinished() {
      tutorialAnimation.resumeAfterTyping();
    }
  }

  SequentialAnimation {
    id: tutorialAnimation

    signal resumeAfterTyping()

    onResumeAfterTyping: () => {
      // this will resume the animation when the fakeChat triggers "typingFinished"
      tutorialAnimation.resume();
    }

    property bool _startPending: false
    property bool _animationCreated: false

    running: false

    on_StartPendingChanged: {
      if (_startPending && _animationCreated) {
        _startPending = false;
        running = true;
      }
    }

    onRunningChanged: {
      rootDialog.running = running;
    }

    onStopped: {
      animationPlaceholder.animations = [];
    }

    onFinished: {
      rootDialog.finished()
      stop();
    }

    function mapCoordinatesToMouse(element, point) {
      if (element) {
        var mappedPoint = element.mapToItem(animationTemplate, point);
        return mappedPoint;
      } else {
        return Qt.point(0,0);
      }
    }

    function offsetPoint(point, offset) {
      return Qt.point(point.x + offset.x, point.y + offset.y);
    }

    function changeMonsterLootbagVisibility(visible) {
      monsterLootbag.visible = visible;
    }

    function setChatVisible(value) {
      fakeChat.visible = value;
    }

    function clearChat() {
      fakeChat.clearChat();
    }

    function addChatline(color, text) {
      fakeChat.addChatline(color, text)
    }

    function addTypedText(text, duration) {
      fakeChat.addTypedText(text, duration)
      // "this" refers to the root animation here
      // we pause it until the finishedTyping signal is triggered from the fake chat
      this.pause();
    }

    function confirmTypedText() {
      fakeChat.confirmTypedText()
    }

    function setNPCTradeOKButtonPressed(pressed) {
      if (tutorialMarkers.npcTradeOKButton.marker) {
        var okButton = tutorialMarkers.npcTradeOKButton.marker.parent.parent;
        okButton.checked = pressed;
      }
    }

    function resetTutorialLootingAnimation() {
      animationTemplate.visible = false;
      changeMonsterLootbagVisibility(false);
      monsterLootbag.generateContainerContent([{ typeID: appearances.worthlessLoot }, { typeID: appearances.worthlessLoot }, { typeID: appearances.valuableLoot } ]);
      playerBag.generateContainerContent([{ typeID: appearances.blankRune, cumulativeCount: 96 } ]);
    }

    function createTutorialLootingAnimation() {
      monsterLootbag.setTutorialMarkerOnSlot(2, tutorialMarkers.monsterLootbagLoot.id);
      playerBag.setTutorialMarkerOnSlot(1, tutorialMarkers.playerBagSlot.id);

      findTutorialMarkers();
      const monsterPosition = mapCoordinatesToMouse(tutorialMarkers.monster.marker, Qt.point(16, 16));
      const startPosition = offsetPoint(monsterPosition, Qt.point(-50, -32));
      var monsterLootbagLootPosition = mapCoordinatesToMouse(tutorialMarkers.monsterLootbagLoot.marker, Qt.point(16, 16));
      var playerBagPosition = mapCoordinatesToMouse(tutorialMarkers.playerBagSlot.marker, Qt.point(16, 16));

      animationPlaceholder.animations = [
        animationTemplate.createAnimation()
          .initialize(startPosition, 0.0, TutorialMouseCursor.CursorType.NO_BUTTON, "")
          .scriptAction( () =>  {
            resetTutorialLootingAnimation();
            animationTemplate.visible = true;
          })
          .fadeIn()
          .addPause(1000)
          .moveTo(monsterPosition)
          .clickPress()
          .addPause(1000)
          .clickRelease()
          .scriptAction( () =>  {
            changeMonsterLootbagVisibility(true);
          })
          .moveTo(monsterLootbagLootPosition)
          .leftButtonPress(TibiaEnums.Drag)
          .addPause(500)
          .moveTo(playerBagPosition)
          .leftButtonPress(TibiaEnums.Drop)
          .leftButtonRelease()
          .scriptAction( () =>  {
            monsterLootbag.generateContainerContent([{ typeID: appearances.worthlessLoot }, { typeID: appearances.worthlessLoot } ]);
            playerBag.generateContainerContent([{ typeID: appearances.blankRune, cumulativeCount: 96 }, { typeID: appearances.valuableLoot } ]);
          })
          .addPause(1000)
          .fadeOut()
      ];
      _animationCreated = true;
      if (_startPending) {
        _startPending = false;
        tutorialAnimation.running = true;
      }
    }

    function resetTutorialSellingAnimation() {
      animationTemplate.visible = false;
      clearChat();
      setChatVisible(false);
      playerBag.generateContainerContent([{ typeID: appearances.blankRune, cumulativeCount: 96 }, { typeID: appearances.valuableLoot } ]);
      fakeNPCTrade.visible = false;
      setNPCTradeOKButtonPressed(false);
    }

    function createTutorialSellingAnimation() {
      playerBag.setTutorialMarkerOnSlot(1, tutorialMarkers.playerBagSlot.id);

      findTutorialMarkers();
      const npcPosition = mapCoordinatesToMouse(tutorialMarkers.npc.marker, Qt.point(16, 16));
      const startPosition = offsetPoint(npcPosition, Qt.point(50, -32));
      var monsterLootbagLootPosition = mapCoordinatesToMouse(tutorialMarkers.monsterLootbagLoot.marker, Qt.point(16, 16));
      var playerBagPosition = mapCoordinatesToMouse(tutorialMarkers.playerBagSlot.marker, Qt.point(34, 16));
      var npcTradeOKButton = mapCoordinatesToMouse(tutorialMarkers.npcTradeOKButton.marker, Qt.point(tutorialMarkers.npcTradeOKButton.marker.width / 2, tutorialMarkers.npcTradeOKButton.marker.height / 2));

      findTutorialMarkers();

      // this will resume the paused animation while the fakeChat is typing
      resumeAfterTyping.connect( () => {
        this.resume();
      });

      animationPlaceholder.animations = [
        animationTemplate.createAnimation()
          .initialize(startPosition, 0.0, TutorialMouseCursor.CursorType.NO_BUTTON, "")
          .scriptAction( () =>  {
            resetTutorialSellingAnimation();
            animationTemplate.visible = true;
          })
          .fadeIn()
          .addPause(1000)
          .moveTo(npcPosition)
          .clickPress()
          .addPause(1000)
          .clickRelease()
          .scriptAction( () =>  {
            setChatVisible(true);
            addChatline(ColorHelper.createColorFromName("#a0a0ff"), qsTrId("tutorial_text_loot_chat_trade_1"))
          })
          .addPause(1000)
          .scriptAction( () =>  {
            addChatline(ColorHelper.createColorFromName("#60f8f8"), qsTrId("tutorial_text_loot_chat_trade_2"))
          })
          .addPause(1000)
          .scriptAction( () =>  {
            addTypedText(qsTrId("tutorial_text_loot_chat_loot_player_typed_text_trade"), 1000);
          })
          .addPause(500)
          .scriptAction( () =>  {
            confirmTypedText();
            addChatline(ColorHelper.createColorFromName("#a0a0ff"), qsTrId("tutorial_text_loot_chat_trade_3"))
          })
          .addPause(500)
          .scriptAction( () =>  {
            fakeNPCTrade.visible = true;
          })
          .addPause(1000)
          .moveTo(npcTradeOKButton)
          .addPause(1000)
          .clickPress()
          .scriptAction( () =>  {
            setNPCTradeOKButtonPressed(true)
          })
          .addPause(500)
          .clickRelease()
          .scriptAction( () =>  {
            setNPCTradeOKButtonPressed(false)
            playerBag.generateContainerContent([{ typeID: appearances.goldCoin, cumulativeCount: 30 }, { typeID: appearances.blankRune, cumulativeCount: 96 } ]);
            fakeNPCTrade.visible = false;
          })
          .addPause(500)
          .fadeOut()
      ];
      _animationCreated = true;
      if (_startPending) {
        _startPending = false;
        tutorialAnimation.running = true;
      }
    }

    function resetTutorialBankAnimation() {
      animationTemplate.visible = false;
      clearChat();
      setChatVisible(false);
      playerBag.generateContainerContent([{ typeID: appearances.goldCoin, cumulativeCount: 30 }, { typeID: appearances.blankRune, cumulativeCount: 96 } ]);
      fakeNPCTrade.visible = false;
    }

    function createTutorialBankAnimation() {
      playerBag.setTutorialMarkerOnSlot(1, tutorialMarkers.playerBagSlot.id);

      findTutorialMarkers();
      const npcPosition = mapCoordinatesToMouse(tutorialMarkers.npcBank.marker, Qt.point(16, 16));
      const startPosition = offsetPoint(npcPosition, Qt.point(50, -32));
      var monsterLootbagLootPosition = mapCoordinatesToMouse(tutorialMarkers.monsterLootbagLoot.marker, Qt.point(16, 16));
      var playerBagPosition = mapCoordinatesToMouse(tutorialMarkers.playerBagSlot.marker, Qt.point(34, 16));
      var npcTradeOKButton = mapCoordinatesToMouse(tutorialMarkers.npcTradeOKButton.marker, Qt.point(tutorialMarkers.npcTradeOKButton.marker.width / 2, tutorialMarkers.npcTradeOKButton.marker.height / 2));

      findTutorialMarkers();

      animationPlaceholder.animations = [
        animationTemplate.createAnimation()
          .initialize(startPosition, 0.0, TutorialMouseCursor.CursorType.NO_BUTTON, "")
          .scriptAction( () =>  {
            resetTutorialBankAnimation();
            animationTemplate.visible = true;
          })
          .fadeIn()
          .addPause(1000)
          .moveTo(npcPosition)
          .clickPress()
          .addPause(1000)
          .clickRelease()
          .scriptAction( () =>  {
            setChatVisible(true);
            addChatline(ColorHelper.createColorFromName("#a0a0ff"), qsTrId("tutorial_text_loot_chat_bank_1"))
          })
          .addPause(1000)
          .scriptAction( () =>  {
            addChatline(ColorHelper.createColorFromName("#60f8f8"), qsTrId("tutorial_text_loot_chat_bank_2"))
          })
          .addPause(1000)
          .scriptAction( () =>  {
            addTypedText(qsTrId("tutorial_text_loot_chat_bank_player_typed_text_deposit_all"), 1000);
          })
          .addPause(500)
          .scriptAction( () =>  {
            confirmTypedText();
            addChatline(ColorHelper.createColorFromName("#a0a0ff"), qsTrId("tutorial_text_loot_chat_bank_3"))
          })
          .addPause(1000)
          .scriptAction( () =>  {
            addChatline(ColorHelper.createColorFromName("#60f8f8"), qsTrId("tutorial_text_loot_chat_bank_4"))
          })
          .addPause(1000)
          .scriptAction( () =>  {
            addTypedText(qsTrId("tutorial_text_loot_chat_bank_player_typed_text_yes"), 500);
          })
          .addPause(500)
          .scriptAction( () =>  {
            confirmTypedText();
            addChatline(ColorHelper.createColorFromName("#a0a0ff"), qsTrId("tutorial_text_loot_chat_bank_5"))
            playerBag.generateContainerContent([{ typeID: appearances.blankRune, cumulativeCount: 96 } ]);
          })
          .fadeOut()
          .addPause(2000)
      ];
      _animationCreated = true;
      if (_startPending) {
        _startPending = false;
        tutorialAnimation.running = true;
      }
    }

    SequentialAnimation {
      id: animationPlaceholder
    }
  }
  TutorialMouseCursorAnimation {
    id: animationTemplate
    visible: false
  }

  TibiaMouseShield {
    anchors.fill: parent
  }

} // Item

