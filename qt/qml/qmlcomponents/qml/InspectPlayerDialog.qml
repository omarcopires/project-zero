import QtQuick
import QtQuick.Layouts
import qmlcomponents



TibiaDialog {
  id: inspectPlayerDialog
  caption: qsTrId("inspect_player_caption")
         + (playerInformation != null ? (" " +  playerInformation.objectName) : "")
  width: 700

  property var controller: null

  onReturnPressedFunction: closeDialog
  onCancelPressedFunction: closeDialog

  function closeDialog() {
    if (controller != null) {
      controller.okButtonClicked();
    }
  } //function closeDialog

  initialFocusItem: inspectPlayerDialog

  property bool showInventory: true

  property var currentSelectedObject: null
  function setCurrentSelectedObject(object) {
    currentSelectedObject = object;
  } //function setCurrentSelectedObject(object)

  property var inspectObjectList: controller != null ? controller.inspectObjectList : null
  property var leftSideInventorySlots: null
  property var middleInventorySlots: null
  property var rightSideInventorySlots: null
  property var playerInformation: null
  property bool applyDualWielding : controller ? controller.hasDualWielding : false
  property int dualWieldingObjectID: controller ? controller.dualWieldingObjectID : 0

  onInspectObjectListChanged: {
    allowHoverMouse = false;
    if (inspectObjectList != null && inspectObjectList.length == 11) {
      leftSideInventorySlots  = [inspectObjectList[1],   // NECK = 1,
                                 inspectObjectList[5],   // LEFT_HAND = 5 // !!! Left Hand is used for swords. So its more left side of the inventory puppet
                                 inspectObjectList[8]];  // FINGER = 8
      middleInventorySlots    = [inspectObjectList[0],   // HEAD = 0,
                                 inspectObjectList[3],   // TORSO = 3,
                                 inspectObjectList[6],   // LEGS = 6,
                                 inspectObjectList[7]];  // FEET = 7,
      rightSideInventorySlots = [inspectObjectList[2],   // BACK = 2,
                                 inspectObjectList[4],   // RIGHT_HAND = 4 // !!! Right Hand is used for shields. So its more right side of the inventory puppet
                                 inspectObjectList[9]];  // HIP = 9
      playerInformation = inspectObjectList[10]
      currentSelectedObject = playerInformation
      delayAllowHoverMouse.start();
    } else {
      leftSideInventorySlots = null;
      middleInventorySlots = null;
      rightSideInventorySlots = null;
      playerInformation = null;
      currentSelectedObject = null;
    }
  } //oninspectObjectListChanged

  //TIBIA-14803
  property bool allowHoverMouse: false
  Timer {
    id: delayAllowHoverMouse
    interval: 0
    onTriggered: { allowHoverMouse = true; }
  } //Timer

  Component {
    id: inventorySlotBlank

    Item {
      property var inspectModel: modelData
      Layout.preferredWidth: spriteView.width
      Layout.preferredHeight: spriteView.height

      ColumnLayout {
        id: spriteView
        spacing: TibiaStyle.marginRelated

        BorderImage {
          Layout.preferredWidth: TibiaStyle.inspectObjectSpriteOuterSize
          Layout.preferredHeight: TibiaStyle.inspectObjectSpriteOuterSize
          source: "/images/backdrop-dark-grey.png"
          horizontalTileMode: BorderImage.Repeat
          verticalTileMode: BorderImage.Repeat

          BorderImage {
            anchors.fill: parent
            border { left: 1; top: 1; right: 1; bottom: 1 }
            horizontalTileMode: BorderImage.Repeat
            verticalTileMode: BorderImage.Repeat
            source: "/images/containerslot-border-large.png"

            ScalableObjectDisplay {
              anchors.centerIn: parent
              height: TibiaStyle.inspectObjectSpriteViewSize
              width: height
              smoothTextureFiltering: controller != null && controller.clientSettingSmoothFiltering
              scaleFactor: TibiaStyle.inspectObjectScaleFactor
              showBackground: false

              animated: true
              typeid: (applyDualWielding && inspectModel.slotID == 5) ? dualWieldingObjectID : inspectModel.appearanceID
              cumulativeCount: inspectModel.objectCount
              upgradeTier: inspectModel.objectUpgradeTier
              liquidType: inspectModel.liquidType
              hookDirection: inspectModel.hookDirection

              opacity: (applyDualWielding && inspectModel.slotID == 5) ? 0.5 : 1
              mirrorImage: (applyDualWielding && inspectModel.slotID == 5) ? (true) : false
            } //ScalableObjectDisplay

            Image {
              anchors.centerIn: parent
              width: TibiaStyle.inspectObjectSpriteViewSize
              height: TibiaStyle.inspectObjectSpriteViewSize
              source: inspectModel.backgroundImageUrl
              visible: (inspectModel.objectName == "") && !(applyDualWielding && inspectModel.slotID == 5)
              smooth: controller != null && controller.clientSettingSmoothFiltering
            } //Image

            TibiaText {
              anchors.right: parent.right
              anchors.bottom: parent.bottom
              anchors.margins: 2
              styleType: "InventoryOverlay"
              style: Text.Outline
              text: inspectModel.textOnSprite
            } //TibiaText

            Rectangle {
              anchors.fill: parent
              color: "transparent"
              border.color:"white"
              border.width: 1
              visible: inspectModel == inspectPlayerDialog.currentSelectedObject
            } //Rectangle
          } //BorderImage
        } //Image
      } //ColumnLayout

      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        hoverEnabled: allowHoverMouse && inspectModel.objectName != ""
        enabled: allowHoverMouse && inspectModel.objectName != ""

        onClicked: inspectPlayerDialog.setCurrentSelectedObject(inspectModel)

        onEntered: {
          if(tibiaMouseCursorController != null) { tibiaMouseCursorController.setPointingHand(true); }
        }
        onExited: {
          if(tibiaMouseCursorController != null) { tibiaMouseCursorController.setPointingHand(false); }
        }
      } //MouseArea
    } //Item
  } //Component

  ColumnLayout {
    anchors { left: parent.left; right: parent.right }
    spacing: TibiaStyle.marginUnrelated

    RowLayout {
      Layout.fillWidth: true
      spacing: TibiaStyle.marginUnrelated

      ColumnLayout {
        Item {
          Layout.preferredWidth: inventoryView.width
          Layout.preferredHeight: inventoryView.height

          RowLayout {
            id: inventoryView
            spacing: TibiaStyle.marginRelated
            visible: inspectPlayerDialog.showInventory

            ColumnLayout {
              id: leftInventoryView
              spacing: TibiaStyle.marginRelated

              Repeater {
                model: leftSideInventorySlots
                delegate:  inventorySlotBlank
              } //Repeater
            } //ColumnLayout

            ColumnLayout {
              id: middleInventoryView
              spacing: TibiaStyle.marginRelated

              Repeater {
                model: middleInventorySlots
                delegate:  inventorySlotBlank
              } //Repeater
            } //ColumnLayout

            ColumnLayout {
              id: rightInventoryView
              spacing: TibiaStyle.marginRelated

              Repeater {
                model: rightSideInventorySlots
                delegate:  inventorySlotBlank
              } //Repeater
            } //ColumnLayout
          } //RowLayout

          OutfitAppearanceInstanceRenderer {
            anchors.fill: parent
            visible: !inspectPlayerDialog.showInventory
            smoothTextureFiltering: controller != null && controller.clientSettingSmoothFiltering
            scaleFactor: 3

            outfitId: playerInformation != null ? playerInformation.appearanceID : 0
            headColor: playerInformation != null ? playerInformation.headColor : "black"
            torsoColor: playerInformation != null ? playerInformation.torsoColor : "black"
            legsColor: playerInformation != null ? playerInformation.legsColor : "black"
            detailColor: playerInformation != null ? playerInformation.detailColor : "black"
            firstAddOn: playerInformation != null && playerInformation.firstAddOn
            secondAddOn: playerInformation != null && playerInformation.secondAddOn

            //mirrorImage: applyDualWielding && (playerInformation != null && playerInformation.appearanceID == dualWieldingObjectID)
          } //OutfitAppearanceInstanceRenderer
        } //Item

        RowLayout {
          spacing: TibiaStyle.marginNarrow
          Layout.alignment: Qt.AlignCenter

          TibiaButton {
            Layout.preferredWidth: TibiaStyle.inspectObjectSpriteOuterSize / 2
            Layout.preferredHeight: TibiaStyle.inspectObjectSpriteOuterSize / 2
            Layout.alignment: Qt.AlignHCenter
            imageSource: inspectPlayerDialog.showInventory ? "/images/icon-playerdetails.png" : "/images/icon-equipmentdetails.png"
            onClicked: {
              inspectPlayerDialog.setCurrentSelectedObject(playerInformation)
              inspectPlayerDialog.showInventory = !inspectPlayerDialog.showInventory
            } //onClicked

            Tooltip {
              anchors.fill: parent
              text: inspectPlayerDialog.showInventory ? qsTrId("inspect_player_details_toolitp") : qsTrId("inspect_equipment_details_tooltip")
            }
          } //TibiaButton

          TibiaButton {
            Layout.preferredWidth: TibiaStyle.inspectObjectSpriteOuterSize / 2
            Layout.preferredHeight: TibiaStyle.inspectObjectSpriteOuterSize / 2
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            imageSource: "/images/icon-skillwheel-large.png"
            onClicked: {
              if (controller != null) {
                controller.openSkillWheelDialog();
              }
            } //onClicked

            Tooltip {
              anchors.fill: parent
              text: qsTrId("inspect_character_skillwheel_tooltip")
            }
          } //TibiaButton
        } //RowLayout

      } //ColumnLayout

      ColumnLayout {
        id: informationView
        spacing: TibiaStyle.marginRelated
        Layout.fillWidth: true

        RowLayout {
          spacing: TibiaStyle.marginRelated
          Layout.fillWidth: true

          TibiaText {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignBottom | Qt.AlignLeft
            text: currentSelectedObject != null ? qsTrId("inspect_inspecting").arg(currentSelectedObject.objectName) : ""
            wrapMode: Text.Wrap
          } //TibiaText

          Repeater {
            model: currentSelectedObject != null ? currentSelectedObject.imbumentIcons : null

            BorderImage {
              Layout.preferredWidth: TibiaStyle.inspectObjectSpriteOuterSize
              Layout.preferredHeight: TibiaStyle.inspectObjectSpriteOuterSize
              border { left: 1; right: 1; top: 1; bottom: 1 }
              source: "/images/1pixel-down-frame.png"
              horizontalTileMode: BorderImage.Repeat
              verticalTileMode: BorderImage.Repeat

              Image {
                anchors.centerIn: parent
                source: modelData
              } //Image
            } //BorderImage
          } //Repeater
        } //RowLayout

        TibiaTextArea {
          id: objectInformation
          Layout.fillWidth: true
          Layout.fillHeight: true
          text: currentSelectedObject != null ? currentSelectedObject.objectInformation : ""
          readOnly: true
          wrapMode: TextEdit.Wrap
          KeyNavigation.tab: inspectPlayerDialog
          textFormat: TextEdit.RichText
        } //TibiaTextArea
      } //ColumnLayout
    } //RowLayout

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } //TibiaHorizontalSeparator

    RowLayout {
      Layout.alignment: Qt.AlignRight
      spacing: TibiaStyle.marginRelated

      TibiaIconButton {
        sourceUp: "/images/button-copytoclipboard-up.png"
        sourceDown: "/images/button-copytoclipboard-down.png"
        tooltipText: qsTrId("inspect_copy_information")

        onClicked: {
          if (controller != null && currentSelectedObject != null) {
            controller.copyToClipboarClicked(currentSelectedObject.clipboardReadyText);
          }
        } //onClicked
      } //TibiaIconButton

      Item {Layout.fillWidth: true}

      TibiaButton {
        text: qsTrId("inspect_open_weapon_proficiency_dialog")
        tooltipText: qsTrId("inspect_open_weapon_proficiency_dialog_tooltip")
        visible: currentSelectedObject != null && currentSelectedObject.hasProficiency
          && controller != null && controller.isOwnPlayer
        Layout.preferredWidth: TibiaStyle.buttonWidthBroad

        onClicked: {
          inspectPlayerDialog.controller.openWeaponProficiencyDialogClicked(currentSelectedObject.appearanceID);
        }
      } // TibiaButton

      TibiaButton {
        text: qsTrId("inspect_open_charinfo")
        visible: controller != null && controller.isOwnPlayer
        Layout.preferredWidth: TibiaStyle.buttonWidthBroad
        tooltipText: qsTrId("inspect_open_charinfo_tooltip")

        onClicked: {
          if (controller != null) {
            controller.openCharacterInfoClicked();
          }
        }
      } // TibiaButton

      TibiaButton {
        text: qsTrId("close")

        onClicked: inspectPlayerDialog.closeDialog();
      } // TibiaButton
    } // RowLayout
  } // ColumnLayout
} // TibiaDialog
