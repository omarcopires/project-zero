import QtQuick
import QtQuick.Layouts

import qmlcomponents
import qmlenumvalues
import "qrc:/qt/qml/qmlcomponents/qml/"

Item {
  id: rootDialog

  signal finished()

  property var tutorialType: TutorialEnums.TutorialType.Attack

  property alias running: tutorialAnimation._startPending

  property var tutorialMarkers: {
    "monster": {
      "id": worldmap.monsterTutorialMarkerID,
      "marker": null
    },
    "healthPotion": {
      "id": TutorialHelper.nextUniqueTutorialMarkerID(),
      "marker": null
    },
    "attackSpell": {
      "id": TutorialHelper.nextUniqueTutorialMarkerID(),
      "marker": null
    },
    "healingSpell": {
      "id": TutorialHelper.nextUniqueTutorialMarkerID(),
      "marker": null
    }
  }

  readonly property var spellInfos: {
    "attackSpell":  TutorialHelper.findSpellInfoForSpell("mud attack"),
    "healingSpell":    TutorialHelper.findSpellInfoForSpell("magic patch")
  }

  QtObject {
    id: appearances
    readonly property int healthPotion: AppearanceTypeHelper.getObjectAppearanceTypeIDByName("small health potion")
    readonly property int manaPotion: AppearanceTypeHelper.getObjectAppearanceTypeIDByName("mana potion")
  }

  function findTutorialMarkers() {
    Object.entries(tutorialMarkers).forEach(([key, value]) => {
      value.marker = TutorialHelper.findTutorialMarkerQuickItemWithID(value.id);
    });
  }

  function resetAnimation() {
    if (tutorialAnimation) {
      tutorialAnimation.stop();
    }
    switch (rootDialog.tutorialType) {
      case TutorialEnums.TutorialType.Attack:
        tutorialAnimation.resetTutorialAttackAnimation();
        break;
      case TutorialEnums.TutorialType.Heal:
        tutorialAnimation.resetTutorialHealAnimation();
        break;
      case TutorialEnums.TutorialType.XP:
        tutorialAnimation.resetTutorialXPAnimation();
        break;
    }
  }

  function restartAnimation() {
    tutorialAnimation.stop();

    Qt.callLater( () => {
      switch (rootDialog.tutorialType) {
        case TutorialEnums.TutorialType.Attack:
          tutorialAnimation.createTutorialAttackAnimation();
          break;
        case TutorialEnums.TutorialType.Heal:
          tutorialAnimation.createTutorialHealAnimation();
          break;
        case TutorialEnums.TutorialType.XP:
          tutorialAnimation.createTutorialXPAnimation();
          break;
      }
      resetAnimation();
      tutorialAnimation.restart();
    });
  }

  function stopAnimation() {
    tutorialAnimation.stop();
    animationPlaceholder.stop();

    animationPlaceholder.animations = [];
  }

  Component.onCompleted: {
    Qt.callLater( () => {
      resetAnimation();
    });
  }

  QtObject {
    id: buttonDisplayOptionsMock
    property bool showCooldown       : true
    property bool showCooldownNumber : true
    property bool allowTooltip       : true
    property bool showHotkey         : true
    property bool showSpellParameters: false
    property bool showAmount         : false
  }

  Timer {
    id: cooldownTimer
    property var listeningButtons: []
    interval: 16
    repeat: true

    function addListeningButton(button) {
      for (var i = 0; i < listeningButtons.length; i++) {
        if (listeningButtons[i] === button) {
          return;
        }
      }
      listeningButtons.push(button);
      start();
    }

    function removeListeningButton(button) {
      for (var i = 0; i < listeningButtons.length; i++) {
        if (listeningButtons[i] === button) {
          listeningButtons.splice(i, 1);
          return;
        }
      }
    }

    onTriggered: {
      for (var i = 0; i < listeningButtons.length; i++) {
        listeningButtons[i].cooldownTick();
      }
      if (listeningButtons.length == 0) {
        stop();
      }
    }
  }

  Component {
     id: actionButtonControllerComponent
     QtObject {
        id: root
        signal cooldownTick()
        property var gameWindowQuickItem: null
        property bool isLocked: false
        property int actionBarID: 0
        property int actionButtonID: 0
        property int type: 0
        property int progressType: 0
        property string spellIconUrl: ""
        property string spellParameters: ""
        property string tooltip: ""
        property string hotkeyShort: ""
        property string text: ""
        property int objectID: 0
        property int objectCount: 0
        property int objectUpgradeTier: 0
        property int liquidType: 0
        property int hookDirection: 0
        property bool objectIsEquiped: false
        property bool isEquipeAction: false
        property bool isEnabled: true
        property string passiveAbilityIconUrl: ""
        property string cooldownText: ""
        property int tutorialMarkerID: 0
        property bool cooldownRunning: true
        property int  cooldownRemainingPercent: 0

        property int _cooldownValue: 0
        property int _cooldownDuration: 1000
        property var _cooldownStart: 0

        function startCooldown(duration) {
          _cooldownValue = 100;
          _cooldownDuration = duration;
          _cooldownStart = new Date().getTime();
          cooldownTimer.addListeningButton(this);
          cooldownTimer.start();
        }

        onCooldownTick: {
          var elapsedTime = new Date().getTime() - _cooldownStart;
          var elapsedPercentage = (elapsedTime / _cooldownDuration) * 100;
          _cooldownValue = Math.max(0, 100 - elapsedPercentage);
          if (elapsedTime >= _cooldownDuration) {
            _cooldownValue = 0;
            cooldownTimer.removeListeningButton(this);
          }

          cooldownRemainingPercent = _cooldownValue;
        }
     }
  }

  Component {
    id: actionbarControllerComponent
    QtObject {
      id: controllerMock

      property var actionButtonControllers: []

      property int actionBarId: 0
      property bool vertical: false
      property var actionButtonModel: actionButtonControllers
      property int firstVisibleButtonId: 1
      property var gameWindowQuickItem: null
      property bool locked: false
      property var buttonsDisplayOptions: buttonDisplayOptionsMock


      Component.onCompleted: {
        var newActionButtonModel = [];
        var button1 = actionButtonControllerComponent.createObject(controllerMock);
        button1.type = ActionButton.OBJECT;
        button1.objectID = appearances.healthPotion;
        button1.objectCount = 10;
        button1.hotkeyShort = "F1";
        button1.tutorialMarkerID = tutorialMarkers.healthPotion.id
        newActionButtonModel.push(button1);

        var button2 = actionButtonControllerComponent.createObject(controllerMock);
        button2.type = ActionButton.OBJECT;
        button2.objectID = appearances.manaPotion;
        button2.objectCount = 5;
        button2.hotkeyShort = "F2";
        newActionButtonModel.push(button2);

        var button3 = actionButtonControllerComponent.createObject(controllerMock);
        button3.type = ActionButton.SPELL;
        button3.spellIconUrl = "image://spell-icons-32x32/" + spellInfos.attackSpell.icon;
        button3.hotkeyShort = "F3";
        button3.tutorialMarkerID = tutorialMarkers.attackSpell.id
        newActionButtonModel.push(button3);

        var button4 = actionButtonControllerComponent.createObject(controllerMock);
        button4.type = ActionButton.SPELL;
        button4.spellIconUrl = "image://spell-icons-32x32/" + spellInfos.healingSpell.icon;
        button4.hotkeyShort = "F4";
        button4.tutorialMarkerID = tutorialMarkers.healingSpell.id

        newActionButtonModel.push(button4);

        var button5 = actionButtonControllerComponent.createObject(controllerMock);
        button5.type = ActionButton.NONE;
        button5.hotkeyShort = "F5";
        newActionButtonModel.push(button5);

        controllerMock.actionButtonControllers = newActionButtonModel;
      }
    }
  }

  RowLayout {
    id: worldmapAndActionbarWrapper
    anchors.fill: parent
    Item {
      Layout.fillWidth: true
      Layout.preferredHeight: worldmap.height + actionbar.height

      TutorialWorldmapCombat {
        id: worldmap
        anchors.horizontalCenter: parent.horizontalCenter
      }

      Item {
        id: actionbarWrapper
        anchors.top: worldmap.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        height: actionbar.height
        width: 5 * 32 + 20
        clip: true
        ActionBar {
          id: actionbar
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.leftMargin: -18
          anchors.rightMargin: -100
          Component.onCompleted: {
            controller = actionbarControllerComponent.createObject(actionbar);
          }
          function changeButtonPressed(buttonIndex, pressed) {
            let buttonController = actionbar.controller.actionButtonControllers[buttonIndex];
            buttonController.objectIsEquiped = pressed;
            buttonController.isEquipeAction = pressed;
          }

          function startCooldown(buttonIndex, duration) {
            let buttonController = actionbar.controller.actionButtonControllers[buttonIndex];
            buttonController.startCooldown(duration);
          }
        }
      }

      RowLayout {
        id: xpBarWrapper
        anchors.top: worldmap.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: 30


        height: actionbar.height
        width: 5 * 32 + 20
        clip: true
        visible: false

        StatusBarSkill {
          id: xpBar
          property int level: 1
          property double percent: 0.8
          property int xpToLevelup: 30
          property alias showTooltip: xpTooltip.visible
          skillData: {
            "valueStringColor": Qt.rgba(1.0,0.0,0.0,1.0),
            "iconSource": "image://skills-icons/1",
            "iconTooltip": "",
            "progressBarValue": percent,
            "progressBarColor": Qt.rgba(1.0,0.0,0.0,1.0),
            "tooltip": "",
          }
          skillText: level
          Layout.preferredHeight: TibiaStyle.progressBarSlimHeight
          Layout.fillWidth: true

          TooltipTemplate {
            id: xpTooltip
            visible: false
            x: 99
            y: -16
            text: qsTrId("exp_to_levelup_tooltip").arg(xpBar.xpToLevelup)
          }
        }
      }

      TutorialMouseCursorAnimation {
        id: animationTemplate
        visible: false
      }

      SequentialAnimation {
        id: tutorialAnimation

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

        function resetTutorialAttackAnimation() {
          animationTemplate.visible = false;
          worldmap.changeHealth(TutorialEnums.CreatureType.Monster, 1.0);
          worldmap.changeMana(TutorialEnums.CreatureType.Player, 1.0);
          worldmap.changeMonsterTargetBorder(false, "red");
          actionbar.changeButtonPressed(2, false);
        }

        function createTutorialAttackAnimation() {
          const PLAYER = TutorialEnums.CreatureType.Player;
          const MONSTER = TutorialEnums.CreatureType.Monster;

          findTutorialMarkers();
          const monsterPosition =  mapCoordinatesToMouse(tutorialMarkers.monster.marker, Qt.point(16, 16));
          const actionButtonPosition = mapCoordinatesToMouse(tutorialMarkers.attackSpell.marker,  Qt.point(16, 16));
          const startPosition = offsetPoint(monsterPosition, Qt.point(50, -32));

          animationPlaceholder.animations = [
            animationTemplate.createAnimation()
              .initialize(startPosition, 0.0, TutorialMouseCursor.CursorType.NO_BUTTON, "")
              .scriptAction( () =>  {
                resetTutorialAttackAnimation();
                animationTemplate.visible = true;
              })
              .fadeIn()
              .addPause(1000)
              .moveTo(monsterPosition)
              .clickPress()
              .addPause(1000)
              .clickRelease()
              .scriptAction( () =>  {
                worldmap.changeMonsterTargetBorder(true, "red");
              })
              .addPause(500)
              .scriptAction( () =>  {
                worldmap.showGraphicalEffect(MONSTER, TutorialEnums.GraphicalEffect.EFFECT_BLOOD_SPLASH);
                worldmap.showNumericalEffect(MONSTER, 28, TutorialEnums.NumericalColor.Bleeding);
                worldmap.changeHealth(MONSTER, 0.8);
              })
              .moveTo(actionButtonPosition)
              .clickPress()
              .scriptAction( () =>  {
                actionbar.changeButtonPressed(2, true);
              })
              .addPause(1000)
              .clickRelease()
              .scriptAction( () => {
                worldmap.showGraphicalEffect(MONSTER, TutorialEnums.GraphicalEffect.EFFECT_SNAPPER);
                worldmap.showNumericalEffect(MONSTER, 56, TutorialEnums.NumericalColor.Earth);
                worldmap.changeHealth(MONSTER, 0.4);
                worldmap.changeMana(PLAYER, 0.7);
                actionbar.changeButtonPressed(2, false);
                actionbar.startCooldown(2, spellInfos.attackSpell.cooldown);
              })
              .addPause(2000)
              .fadeOut()
          ];
          _animationCreated = true;
          if (_startPending) {
            _startPending = false;
            tutorialAnimation.running = true;
          }
        }

        function resetTutorialHealAnimation() {
          animationTemplate.visible = false;
          worldmap.changeHealth(TutorialEnums.CreatureType.Monster, 0.4);
          worldmap.changeHealth(TutorialEnums.CreatureType.Player, 1.0);
          worldmap.changeMana(TutorialEnums.CreatureType.Player, 0.7);
          actionbar.changeButtonPressed(3, false);
        }

        function createTutorialHealAnimation() {
          const PLAYER = TutorialEnums.CreatureType.Player;
          const MONSTER = TutorialEnums.CreatureType.Monster;

          findTutorialMarkers();
          const monsterPosition =  mapCoordinatesToMouse(tutorialMarkers.monster.marker, Qt.point(16, 16));
          const actionButtonPositionHealingSpell = mapCoordinatesToMouse(tutorialMarkers.healingSpell.marker,  Qt.point(16, 16));
          const actionButtonPositionHealthPotion = mapCoordinatesToMouse(tutorialMarkers.healthPotion.marker,  Qt.point(16, 16));
          const startPosition = offsetPoint(monsterPosition, Qt.point(50, -32));

          animationPlaceholder.animations = [
            animationTemplate.createAnimation()
              .initialize(startPosition, 0.0, TutorialMouseCursor.CursorType.NO_BUTTON, "")
              .scriptAction( () =>  {
                resetTutorialHealAnimation();
                animationTemplate.visible = true;
                worldmap.showTemporaryTargetBorder(MONSTER, 1000, "black");
              })
              .scriptAction( () =>  {
                worldmap.showNumericalEffect(PLAYER, 84, TutorialEnums.NumericalColor.Bleeding);
                worldmap.showGraphicalEffect(PLAYER, TutorialEnums.GraphicalEffect.EFFECT_BLOOD_SPLASH);
                worldmap.changeHealth(PLAYER, 0.6);
              })
              .addPause(500)
              .fadeIn()
              .moveTo(actionButtonPositionHealingSpell)
              .addPause(500)
              .clickPress()
              .scriptAction( () =>  {
                actionbar.changeButtonPressed(3, true);
              })
              .addPause(500)
              .clickRelease()
              .scriptAction( () =>  {
                worldmap.showNumericalEffect(PLAYER, 42, TutorialEnums.NumericalColor.Healing);
                worldmap.showGraphicalEffect(PLAYER, TutorialEnums.GraphicalEffect.EFFECT_BLUE_STARS);
                worldmap.changeHealth(PLAYER, 0.8);
                worldmap.changeMana(PLAYER, 0.3);
                actionbar.changeButtonPressed(3, false);
                actionbar.startCooldown(3, spellInfos.healingSpell.cooldown);
              })
              .addPause(1000)
              .scriptAction( () =>  {
                worldmap.showNumericalEffect(PLAYER, 92, TutorialEnums.NumericalColor.Bleeding);
                worldmap.showGraphicalEffect(PLAYER, TutorialEnums.GraphicalEffect.EFFECT_BLOOD_SPLASH);
                worldmap.showTemporaryTargetBorder(MONSTER, 1000, "black");
                worldmap.changeHealth(PLAYER, 0.3);
              })
              .addPause(1000)
              .moveTo(actionButtonPositionHealthPotion)
              .clickPress()
              .scriptAction( () =>  {
                actionbar.changeButtonPressed(0, true);
              })
              .addPause(500)
              .scriptAction( () =>  {
                worldmap.showGamewindowMessage(Qt.point(32 + 20, 58 + 20), "Aaahh...", TutorialEnums.NumericalColor.Healing);
                worldmap.showGraphicalEffect(PLAYER, TutorialEnums.GraphicalEffect.EFFECT_BLUE_STARS);
                worldmap.changeHealth(PLAYER, 0.8);
                worldmap.showNumericalEffect(PLAYER, 124, TutorialEnums.NumericalColor.Healing);
                actionbar.changeButtonPressed(0, false);
              })
              .addPause(1000)
              .clickRelease()
              .fadeOut()
          ];
          _animationCreated = true;
          if (_startPending) {
            _startPending = false;
            tutorialAnimation.running = true;
          }
        }

        function resetTutorialXPAnimation() {
            animationTemplate.visible = false;
            worldmap.monsterHUDVisible = true;
            worldmap.changeHealth(TutorialEnums.CreatureType.Monster, 0.4);
            worldmap.changeHealth(TutorialEnums.CreatureType.Player, 0.8);
            worldmap.changeMana(TutorialEnums.CreatureType.Player, 0.3);
            worldmap.showMonsterAndPlayer();
            worldmap.changeMonsterTargetBorder(true, "red");
            actionbar.changeButtonPressed(2, false);
            actionbar.visible = false;
            xpBarWrapper.visible = true;
            xpBar.showTooltip = false;
            xpBar.level = 1;
            xpBar.percent = 0.8;
            xpBar.xpToLevelup = 15;
        }

        function createTutorialXPAnimation() {
          const PLAYER = TutorialEnums.CreatureType.Player;
          const MONSTER = TutorialEnums.CreatureType.Monster;

          const progressBarPosition = mapCoordinatesToMouse(xpBar,  Qt.point(100, xpBar.height / 2 + 6));
          const startPosition = offsetPoint(progressBarPosition, Qt.point(-50, -100));


          animationPlaceholder.animations = [
            animationTemplate.createAnimation()
              .initialize(startPosition, 0.0, TutorialMouseCursor.CursorType.NO_BUTTON, "")
              .scriptAction( () =>  {
                resetTutorialXPAnimation();
                animationTemplate.visible = true;
              })
              .fadeIn()
              .moveTo(progressBarPosition)
              .addPause(200)
              .scriptAction( () =>  {
                xpBar.showTooltip = true;
              })

              .addPause(800)
              .scriptAction( () =>  {
                worldmap.showGraphicalEffect(MONSTER, TutorialEnums.GraphicalEffect.EFFECT_BLOOD_SPLASH);
                worldmap.showNumericalEffect(MONSTER, 25, TutorialEnums.NumericalColor.Bleeding);
                worldmap.changeHealth(MONSTER, 0.2);
              })
              .addPause(2000)
              .scriptAction( () =>  {
                worldmap.showMonsterCorpseAndPlayer();
              })
              .addPause(100)
              .scriptAction( () =>  {
                // must be delayed a little bit to show up after changing fake worldmap
                worldmap.showGraphicalEffect(MONSTER, TutorialEnums.GraphicalEffect.EFFECT_BLOOD_SPLASH);
                worldmap.showNumericalEffect(MONSTER, 31, TutorialEnums.NumericalColor.Bleeding);
                worldmap.changeHealth(MONSTER, 0.0);
                worldmap.changeHealth(TutorialEnums.CreatureType.Player, 1.0);
                worldmap.changeMana(TutorialEnums.CreatureType.Player, 1.0);
                worldmap.showNumericalEffect(PLAYER, 23, TutorialEnums.NumericalColor.ExperienceGain);
                worldmap.changeMonsterTargetBorder(false, "red");
                worldmap.monsterHUDVisible = false;
                xpBar.level = 2;
                xpBar.percent = 0.07;
                xpBar.xpToLevelup = 93;
              })
              .addPause(3000)
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

    }
  }
  TibiaMouseShield {
    anchors.fill: parent
  }
} // Item

