import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qmlcomponents
import qmlenumvalues


Item {
  id: buttonRoot
  objectName: TibiaStyle.dragSourceActionButton

  property QtObject controller: null
  property var buttonData: null

  readonly property var parentWhileDragging: controller != null ? controller.gameWindowQuickItem : buttonRoot
  readonly property var mapWindowPane: controller != null ? controller.mapWindowPane : null
  readonly property bool isLocked: controller != null ? controller.locked : false

  implicitWidth: TibiaStyle.actionBarSlotSize
  implicitHeight: TibiaStyle.actionBarSlotSize

  readonly property int actionBarID: buttonRoot.buttonData.actionBarID
  readonly property int actionButtonID: buttonRoot.buttonData.actionButtonID
  readonly property int multiActionIndex: buttonRoot.buttonData.multiActionIndex
  readonly property bool hasMultiActions: (buttonRoot.buttonData.multiActions && buttonRoot.buttonData.multiActions.length > 0)
  readonly property bool isMultiActionChild: buttonRoot.multiActionIndex >= 0
  readonly property bool isEmpty:  buttonRoot.buttonData.type === ActionButton.EMPTY
  readonly property bool isSpell:  buttonRoot.buttonData.type === ActionButton.SPELL
  readonly property bool isObject: buttonRoot.buttonData.type === ActionButton.OBJECT
  readonly property bool isText:   buttonRoot.buttonData.type === ActionButton.TEXT
  readonly property bool isPassiveAbility: buttonRoot.buttonData.type === ActionButton.PASSIVEABILITY
  readonly property int tutorialMarkerID: buttonRoot.buttonData.tutorialMarkerID ?? 0
  readonly property bool hasHighlight: buttonRoot.buttonData.hasHighlight ?? false
  readonly property bool isNewlyUnlocked: buttonRoot.buttonData.isNewlyUnlocked ?? false

  /////////////////////////////////////////////////////////////////////
  //CONTEXT MENU TRIGGER AREA

  onTutorialMarkerIDChanged: {
    tutorialMarkerLoader.sourceComponent = tutorialMarkerID != 0 ? tutorialMarkerComponent : null
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.RightButton

    onClicked: {
      buttonRoot.buttonData.contextMenuRequested();
    } //onClicked
  } //MouseArea

  TibiaTargetSelection {
    anchors.fill: parent
    onTargetSelected: {
      if (buttonRoot.buttonData) {
        buttonRoot.buttonData.onTargetSelected();
      }
    } //onTargetSelected
  } //TibiaTargetSelection

  //CONTEXT MENU TRIGGER AREA
  /////////////////////////////////////////////////////////////////////
  //EMPTY SLOT BACKGROUND

  Optimized1PixelBorderImage {
    anchors.fill: parent
    visible: buttonRoot.isEmpty || actionSlot.Drag.active || flyAnim.running
    borderimagesource: "/images/slot-actionbar.png"
  } // OptimizedBorderImage1PixelBorder

  //EMPTY SLOT BACKGROUND
  /////////////////////////////////////////////////////////////////////
  //DRAG TRIGGER AREA

  MouseArea {
    id: dragTriggerArea
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton
    drag.target: buttonRoot.isLocked
              || actionButton.buttonIsRepeating
              || dragDisabled ? undefined : actionSlot
    drag.threshold: TibiaStyle.dragThreshold
    drag.filterChildren: true

    drag.onActiveChanged: {
      if (drag.active && drag.target !== undefined) {
        buttonRoot.buttonData.multiActionExpanded = false;
      }
    }

    //needed to create dop events
    onReleased: {
      if (drag.target != undefined && drag.active) {
        drag.target.Drag.drop();
      }
    } //onReleased
    enabled: !buttonRoot.isEmpty

    //workaround to allow press -> leaf button (still pressed) -> return (still pressed) -> do not start drag
    property bool dragDisabled: false
    onPressedChanged: {
      if (!pressed) {
        dragDisabled = false;
      }
    } //onPressedChanged

    /////////////////////////////////////////////////////////////////////
    //ACTION BUTTON

    Item {
      id: actionSlot
      width: buttonRoot.width
      height: buttonRoot.height

      TibiaButton {
        id: actionButton
        width: buttonRoot.width
        height: buttonRoot.height
        visible: !(buttonRoot.isEmpty || buttonRoot.isPassiveAbility)
        // Disable click animation for button
        sourceDown: buttonRoot.isMultiActionChild ?
          "/images/skin/classic/button-" + color + "-up.png" :
          "/images/skin/classic/button-" + color + "-down.png"

        //////////////////////////////////////////////////////////////////
        //TRIGGER ACTION
        function triggerButtonAction() {
          waitForEquipeToChange.restart();
          buttonRoot.buttonData.onTriggered();
        } //function triggerButtonAction()

        onClicked: {
          if (!buttonIsRepeating && !buttonRoot.isMultiActionChild) {
            actionButton.triggerButtonAction();
          }
        } //onClicked

        property bool buttonIsRepeating: false
        onPressedChanged: {
          if (!pressed) {
            if (buttonIsRepeating) {
              dragTriggerArea.dragDisabled = true;
            }
            buttonIsRepeating = false;
          }
        } //onPressedChanged

        Timer {
          id: repeatActionTimer
          interval: !actionButton.buttonIsRepeating ? TibiaStyle.actionBarPressedTriggerDelay
                                                    : (isText ? TibiaStyle.actionBarReapeatTextDelay : TibiaStyle.actionBarReapeatDealy)
          repeat: true
          running:    actionButton.pressed
                  &&  !cooldownLoader.cooldownRunning
                  &&  !buttonRoot.isMultiActionChild
                  &&  !buttonRoot.hasMultiActions
          onTriggered: {
            actionButton.buttonIsRepeating = true

            // Do not allow to hold multi action buttons (TIBIA-40094)
            if (buttonRoot.hasMultiActions) {
              return;
            }

            actionButton.triggerButtonAction();
          } //onTriggered
        } //Timer

        //allow button to be pressed for equipe/unequip
        checkable: buttonRoot.buttonData.isEquipeAction
        useButtonShouldBeChecked: true
        buttonShouldBeChecked: buttonRoot.buttonData.isEquipeAction ? buttonRoot.buttonData.objectIsEquiped || waitForEquipeToChange.running : false

        Loader {
          id: tutorialMarkerLoader
          Component {
            id: tutorialMarkerComponent
            TibiaTutorialMarker {
            } //TibiaTutorialMarker
          } //Component

          anchors.fill: parent
          onLoaded: {
            item.markerID = Qt.binding(function() { return tutorialMarkerID });
          } //onLoaded
          z: 999
        } //Loader

        //TRIGGER ACTION
        //////////////////////////////////////////////////////////////////
      } //TibiaButton

      //////////////////////////////////////////////////////////////////
      //SPELL ACTION

      Image {
        id: spellIcon
        anchors.centerIn: parent
        visible: buttonRoot.isSpell
        source: buttonRoot.buttonData.spellIconUrl
        smooth: false
      } //Image

      TibiaCachedOutlineTextBase {
        id: spellParameters
        anchors {left: parent.left; right: parent.right; bottom: parent.bottom }
        anchors.margins: 1
        styleType: "ActionButtonOverlay"
        font: TibiaStyle.smallFont
        highQuality: true
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        visible: buttonRoot.isSpell && text != "" && buttonRoot.controller != null && buttonRoot.controller.buttonsDisplayOptions.showSpellParameters
        text: "<div>" + buttonRoot.buttonData.spellParameters + "</div>" //div needed to auto enable RichText but also allow elide which is not working for Text.RichText
      } //TibiaCachedOutlineTextBase

      //SPELL ACTION
      //////////////////////////////////////////////////////////////////
      //OBJECT ACTION

      ScalableObjectDisplay {
        anchors.centerIn: parent
        width: TibiaStyle.mapWindowPixelPerField
        height: TibiaStyle.mapWindowPixelPerField
        clip: false
        visible: buttonRoot.isObject
        showBackground: false

        animated: true
        typeid: buttonRoot.buttonData.objectID
        cumulativeCount: buttonRoot.buttonData.objectCount
        // upgradeTier: buttonRoot.buttonData.objectUpgradeTier // Disabled because it overlaps with button hotkey text
        liquidType: buttonRoot.buttonData.liquidType
        hookDirection: buttonRoot.buttonData.hookDirection
      } // ScalableObjectDisplay

      //curtain the equipe delay between pressing the button and actually changing the inventory
      property bool objectIsEquipedState: buttonRoot.buttonData.objectIsEquiped
      onObjectIsEquipedStateChanged: waitForEquipeToChange.stop()
      Timer {
        id: waitForEquipeToChange
        interval: TibiaStyle.actionBarServerEquipDelay
      } //Timer

      TibiaCachedOutlineTextBase {
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right}
        anchors.margins: 1
        styleType: "ActionButtonOverlay"
        font: TibiaStyle.smallFont
        highQuality: true
        horizontalAlignment: Text.AlignRight

        visible: buttonRoot.isObject && buttonRoot.controller != null && buttonRoot.controller.buttonsDisplayOptions.showAmount
        text: TextHelper.formatNumberToShortStringWithMax999k(buttonRoot.buttonData.objectCount)
      } //TibiaCachedOutlineTextBase

      //OBJECT ACTION
      //////////////////////////////////////////////////////////////////
      //TEXT ACTION

      TibiaCachedOutlineTextBase {
        anchors.fill: parent
        anchors.margins: 1
        styleType: "ActionButtonOverlay"
        font: TibiaStyle.smallFont
        highQuality: true
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.Wrap

        visible: buttonRoot.isText && text != ""
        text: "<div>" + (needExtraLine ? "<br>\n" : "") + buttonRoot.buttonData.text + "</div>" //div needed to auto enable RichText but also allow elide which is not working for Text.RichText

        property bool needExtraLine: (hotkeyText.visible && textSizeMeasurement.lineCount > 1) ? true : false

        TibiaTextBase {
          id: textSizeMeasurement
          anchors.fill: parent
          styleType: parent.styleType
          font: parent.font
          horizontalAlignment: parent.horizontalAlignment
          verticalAlignment: parent.verticalAlignment
          wrapMode: parent.wrapMode
          visible: false
          text: buttonRoot.isText ? "<div>" + buttonRoot.buttonData.text + "</div>" : "" //div needed to auto enable RichText but also allow elide which is not working for Text.RichText
        }
      } //TibiaText

      //TEXT ACTION
      //////////////////////////////////////////////////////////////////
      //PASSIVE ABILITY
      Optimized1PixelBorderImage {
        width: buttonRoot.width
        height: buttonRoot.height
        borderimagesource: "/images/slot-actionbar.png"
        visible: buttonRoot.isPassiveAbility
        Image {
          anchors.centerIn: parent
          source: buttonRoot.buttonData.passiveAbilityIconUrl
          smooth: false
        } //Image
      } //Optimized1PixelBorderImage
      //PASSIVE ABILITY
      //////////////////////////////////////////////////////////////////

      //////////////////////////////////////////////////////////////////
      //MULTIACTION BUTTON MARKER
      Image {
        source: "/images/skin/classic/marker-multiactionbutton.png"
        visible: buttonRoot.hasMultiActions
        anchors.left: parent.left
        anchors.leftMargin: 1
        anchors.top: parent.top
        anchors.topMargin: 1
      } //Image
      //MULTIACTION BUTTON MARKER
      //////////////////////////////////////////////////////////////////

      //////////////////////////////////////////////////////////////////
      //BUTTON DISABLED

      TibiaDisabledOverlay {
        anchors.fill: parent
        anchors.margins: 1
        visible: !buttonRoot.buttonData.isEnabled
      } //TibiaDisabledOverlay

      //BUTTON DISABLED
      /////////////////////////////////////////////////////////////////////
      //COOLDOWN VIEW

      Loader {
        id: cooldownLoader
        property bool cooldownEnabled: buttonRoot.controller != null && (buttonRoot.controller.buttonsDisplayOptions.showCooldown || buttonRoot.controller.buttonsDisplayOptions.showCooldownNumber)
        property bool cooldownRunning: item != null ? item.cooldownRunning: false
        sourceComponent: cooldownEnabled ? cooldownComponent : undefined
        anchors.fill: parent
        Component {
          id: cooldownComponent
          Item {
            id: cooldown

            property bool cooldownRunning: buttonRoot.buttonData != null && buttonRoot.buttonData.cooldownRemainingPercent > 0

            onCooldownRunningChanged: { //retrigger a pressed action button
              if (!cooldownRunning && actionButton.pressed) {
                buttonRoot.buttonData.onTriggered();
              }
            } //onCooldownRunningChanged

            Image {
              id: cooldownImage
              anchors.fill: parent
              anchors.margins: 1

              visible: cooldown.cooldownRunning && buttonRoot.controller.buttonsDisplayOptions.showCooldown
              source: "image://action-bar-cooldown/" + (buttonRoot.buttonData != null ? buttonRoot.buttonData.cooldownRemainingPercent : 0)

              // using smooth: false led to the problem TIBIA-29366
              // see https://confluence.cipsoft.de/display/Tibia/Recherche+Render-Performance+Optimierungen+im+Client%3A+Analyse+der+Render-Pipeline
              // update 2023-03-21: it seems that the bug is gone in Qt 5.15.8. This comment can be removed if the effect doesn't occur any longer
              smooth: false

              fillMode: Image.Pad
              //code to create the cooldown image stripe
              //----------------------------------------
              //const int CooldownSize = 32;
              //const int HalfeSize = static_cast<int>(32 * 0.5);
              //const int Radius = static_cast<int>(CooldownSize * 0.75);
              //const QColor CooldownColor(0, 0, 0, 179); //#B3000000
              //
              //QImage ResultImage(CooldownSize*101, CooldownSize, QImage::Format_ARGB32);
              //ResultImage.fill(Qt::transparent);
              //QPainter ResultPainter(&ResultImage);
              //
              //for (int i = 0; i <= 100; ++i) {
              //  QImage CooldownImage(CooldownSize, CooldownSize, QImage::Format_ARGB32);
              //  CooldownImage.fill(Qt::transparent);
              //  QPainterPath CooldownPath;
              //  CooldownPath.moveTo(HalfeSize, HalfeSize);
              //  CooldownPath.arcTo(HalfeSize - Radius, HalfeSize - Radius, 2 * Radius, 2 * Radius, 90, i * 360.0 / 100.0);
              //  CooldownPath.closeSubpath();
              //  QPainter CooldownPainter(&CooldownImage);
              //  CooldownPainter.fillPath(CooldownPath, CooldownColor);
              //  CooldownPainter.end();
              //
              //  ResultPainter.drawImage(QRect(i*CooldownSize, 0, CooldownSize, CooldownSize), CooldownImage);
              //}
              //ResultImage.save("action-bar-cooldown.png");
            } //Image

            TibiaCachedOutlineTextBase {
              anchors.centerIn: parent
              styleType: "ActionButtonOverlay"
              cacheMode: CachedOutlineText.ReleaseLater
              visible: text != "0.0" && buttonRoot.controller != null && buttonRoot.controller.buttonsDisplayOptions.showCooldownNumber

              // TIBIA-31622: FORCE 'enabled' style type and disable this TibiaText to make drag and drop possible.
              // Otherwise, if this component is enabled, it breaks the mouse Qt onPressed / onReleased processing somehow,
              // so that it is not possible to drag and drop passive abilities, when a cooldown is active.
              color: TibiaStyle.textColors[styleType]
              enabled: false

              text: buttonRoot.buttonData != null ? buttonRoot.buttonData.cooldownText : ""
            } //TibiaCachedOutlineTextBase
          } //Item
        }
      }

      //COOLDOWN VIEW
      //////////////////////////////////////////////////////////////////
      // DRAG PROPETIES

      Drag.keys: [ TibiaStyle.dragKeyActionButton ]
      Drag.active: dragTriggerArea.drag.active
                && dragTriggerArea.drag.target == this
      Drag.source: buttonRoot

      Drag.hotSpot.x: Math.ceil(actionSlot.width * 0.5)
      Drag.hotSpot.y: Math.ceil(actionSlot.height * 0.5)

      Drag.onActiveChanged: {
        if (buttonRoot.buttonData != null) {
          buttonRoot.buttonData.onDragChanged(Drag.active);
        }
      } // Drag.onActiveChanged

      state: Drag.active ? "DRAGGING" : ""
      transitions: [
        Transition {
          to: "DRAGGING"
          PropertyAction { target: actionSlot; property: "parent"; value: buttonRoot.parentWhileDragging }
        }, //Transition
        Transition {
          from: "DRAGGING"
          SequentialAnimation {
            PropertyAction { target: actionSlot; property: "parent"; value: dragTriggerArea }
            ParallelAnimation {
              PropertyAction { target: actionSlot; property: "y"; value: 0 }
              PropertyAction { target: actionSlot; property: "x"; value: 0 }
            } //ParallelAnimation
          } //SequentialAnimation
        } //Transition
      ] //transitions

      // DRAG PROPETIES
      //////////////////////////////////////////////////////////////////
    } //Item

    //ACTION BUTTON
    /////////////////////////////////////////////////////////////////////

  } //MouseArea

  //DRAG TRIGGER AREA
  /////////////////////////////////////////////////////////////////////
  //HOTKEY OVERLAY

  TibiaCachedOutlineTextBase {
    id: hotkeyText
    anchors { top: parent.top; left: parent.left; right: parent.right}
    anchors.margins: 1
    styleType: "ActionButtonOverlay"
    font: TibiaStyle.smallFont
    highQuality: true
    elide: Text.ElideLeft
    horizontalAlignment: Text.AlignRight

    visible: text != "" && buttonRoot.controller != null && buttonRoot.controller.buttonsDisplayOptions.showHotkey
    text: buttonRoot.buttonData.hotkeyShort
  } //TibiaCachedOutlineTextBase

  //HOTKEY OVERLAY
  /////////////////////////////////////////////////////////////////////
  //ACTIVE HIGHLIGHT
  Loader {
    id: aktiveHighlightLoader
    Component {
      id: aktiveHighlightComponent
      Image {
        source: "/images/border_activespell.png"
      } //Image
    } //Component

    anchors.centerIn: parent
    z: 999

    sourceComponent: buttonRoot.hasHighlight ? aktiveHighlightComponent : null
  } //Loader
  //ACTIVE HIGHLIGHT
  /////////////////////////////////////////////////////////////////////
  //IS NEWLY UNLOCKED HIGHLIGHT
  TibiaRectangleHighlight {
    visible: buttonRoot.isNewlyUnlocked && !flyAnim.running
  }

  Connections {
    target: buttonRoot.buttonData
    function onStartInsertAnimation() {
      const startCenter = buttonRoot.parentWhileDragging.mapFromItem(
        buttonRoot.mapWindowPane,
        buttonRoot.mapWindowPane.width / 2,
        buttonRoot.mapWindowPane.height - buttonRoot.mapWindowPane.height * 0.1,
      );
      const endCenter = buttonRoot.parentWhileDragging.mapFromItem(
        dragTriggerArea,
        actionSlot.width / 2,
        actionSlot.height / 2
      );

      const control = {
        x: (startCenter.x + endCenter.x) / 2,
        y: Math.min(startCenter.y, endCenter.y) - 120, // raise/lower arc height here
      };

      const oldParent = actionSlot.parent;
      const globalPos = buttonRoot.parentWhileDragging.mapFromItem(oldParent, actionSlot.x, actionSlot.y);

      actionSlot.parent = buttonRoot.parentWhileDragging;
      actionSlot.x = startCenter.x - actionSlot.width / 2;
      actionSlot.y = startCenter.y - actionSlot.height / 2;

      flyPath.startX = startCenter.x;
      flyPath.startY = startCenter.y;
      curve.x = endCenter.x;
      curve.y = endCenter.y;
      curve.controlX = control.x;
      curve.controlY = control.y;

      flyAnim.start();
    }
  }

  PathAnimation {
    id: flyAnim
    target: actionSlot
    duration: 625
    easing.type: Easing.InOutQuad
    anchorPoint: Qt.point(actionSlot.width / 2, actionSlot.height / 2)

    onStarted: {
      actionSlot.scale = 1.3;
      actionSlot.opacity = 0.0;
      fadeIn.start();
      scaleInAnim.start();
    }

    onStopped: {
      actionSlot.parent = dragTriggerArea
      actionSlot.x = 0;
      actionSlot.y = 0;
      actionSlot.scale = 1.0;

      popAnim.start();
    }

    path: Path {
      id: flyPath
      startX: 0
      startY: 0
      PathQuad {
        id: curve
        x: 0
        y: 0
        controlX: 0
        controlY: 0
      }
    }
  }

  NumberAnimation {
    id: fadeIn
    target: actionSlot
    property: "opacity"
    from: 0.0; to: 1.0
    duration: 300
  }

  NumberAnimation {
    id: scaleInAnim
    target: actionSlot
    property: "scale"
    from: 1.3; to: 1.0
    duration: flyAnim.duration
    easing.type: Easing.OutQuad
  }

  SequentialAnimation {
    id: popAnim
    PropertyAnimation {
      target: actionSlot
      property: "scale"
      from: 1.0; to: 1.3
      duration: 100
      easing.type: Easing.OutQuad
    }
    PropertyAnimation {
      target: actionSlot
      property: "scale"
      from: 1.3; to: 1.0
      duration: 160
      easing.type: Easing.OutBack
    }
  }

  //IS NEWLY UNLOCKED HIGHLIGHT
  //////////////////////////////////////////////////////////////////
  //TOOLTIP

  Tooltip {
    anchors.fill: parent
    text: buttonRoot.buttonData.tooltip
    maxWidth: TibiaStyle.actionBarTooltipMaxWidth
    useRichText: true
    enabled: (!actionButton.pressed || (buttonRoot.buttonData.isEquipeAction && buttonRoot.buttonData.objectIsEquiped))
             && buttonRoot.controller != null && buttonRoot.controller.buttonsDisplayOptions.allowTooltip
             && !actionSlot.Drag.active

    onBeforeShowTooltip: {
      buttonRoot.buttonData.isNewlyUnlocked = false;
    }
  } //Tooltip

  //TOOLTIP
  /////////////////////////////////////////////////////////////////////
  //DROP

  DropArea {
    id: actionDropArea
    anchors.fill: parent
    keys: [ TibiaStyle.dragKeyMoveTibiaObject, TibiaStyle.dragKeyActionButton, TibiaStyle.dragKeySpell ]
    enabled: !buttonRoot.isLocked

    onDropped: {
      if (buttonRoot.controller != null) {
        if (drag.source && drag.source.objectName == TibiaStyle.dragSourceActionButton) {
          buttonRoot.controller.onSwapActions(drag.source.actionBarID, drag.source.actionButtonID, drag.source.multiActionIndex,
                                   buttonRoot.buttonData.actionBarID, buttonRoot.buttonData.actionButtonID, buttonRoot.buttonData.multiActionIndex);
        } else if (drag.source && drag.source.objectName == TibiaStyle.dragSourceSpellIcon) {
          buttonRoot.controller.onSpellIconDropped(buttonRoot.buttonData.actionButtonID, drag.source.enumId, buttonRoot.buttonData.multiActionIndex);
        } else {
          buttonRoot.controller.onDropped(buttonRoot.buttonData.actionButtonID, buttonRoot.buttonData.multiActionIndex);
        }
      }
    } //onDropped

    Loader {
      Component {
        id: dragBorderComponent
        Rectangle {
          anchors.fill: parent
          color: "transparent"
          opacity: actionSlot.Drag.active ? 0.6 : 1.0
          border.width: 1
          border.color: "white"
        } //Rectangle
      }
      anchors.fill: parent
      sourceComponent: actionSlot.Drag.active || actionDropArea.containsDrag ? dragBorderComponent : undefined
    }
  } //DropArea

  //DROP
  /////////////////////////////////////////////////////////////////////
} //Item

