import QtQuick
import QtQuick.Layouts
import qmlcomponents



ColumnLayout {
  id: root

  property bool clientSettingSmoothFiltering: true

  property var currentSelectedObject: null
  property var inspectObjectList: null
  property var leftSideInventorySlots: null
  property var middleInventorySlots: null
  property var rightSideInventorySlots: null
  property var playerInformation: null
  property bool showInventory: true
  property bool applyDualWielding : false
  property int dualWieldingObjectID: 0

  onInspectObjectListChanged: {
    //allowHoverMouse = false;
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
      //delayAllowHoverMouse.start();
    } else {
      leftSideInventorySlots = null;
      middleInventorySlots = null;
      rightSideInventorySlots = null;
      playerInformation = null;
      currentSelectedObject = null;
    }
  } //oninspectObjectListChanged

  function setCurrentSelectedObject(object) {
    currentSelectedObject = object;
  } //function setCurrentSelectedObject(object)

  GridLayout {
    Layout.fillWidth: true
    columnSpacing : TibiaStyle.marginRelated
    rowSpacing : TibiaStyle.marginRelated
    columns: 3

    Item {
      Layout.preferredWidth: inventoryView.width
      Layout.preferredHeight: inventoryView.height

      RowLayout {
        id: inventoryView
        spacing: TibiaStyle.marginNarrow
        visible: root.showInventory

        Component {
          id: inventorySlotComponent

          ContainerSlot {
            property var inspectModel: modelData

            slotText: inspectModel.textOnSprite
            objectAppearanceInstanceTypeId: inspectModel.objectName != "" ? inspectModel.appearanceID : ((applyDualWielding && inspectModel.slotID == 5) ? dualWieldingObjectID : 0)
            objectAppearanceInstanceCumulativeCount: inspectModel.objectName != "" ? inspectModel.objectCount : 0
            objectAppearanceInstanceLiquidType: inspectModel.objectName != "" ? inspectModel.liquidType : ObjectAppearanceInstance.EMPTY
            objectAppearanceInstanceHookDirection: inspectModel.objectName != "" ? inspectModel.hookDirection : ObjectAppearanceInstance.NONE
            objectAppearanceInstanceUpgradeTier: inspectModel.objectName != "" ? inspectModel.objectUpgradeTier : 0
            objectAppearanceInstanceDecoItemObjectID: inspectModel.objectName != "" ? inspectModel.decoItemObjectID: 0
            acceptsDrop: false
            showPointingHandCursor: inspectModel.objectName != ""
            slotBackgroundImageSource: inspectModel.backgroundImageUrl
            mirrorImage: (applyDualWielding && inspectModel.slotID == 5) ? (true) : false
            opacity: (applyDualWielding && inspectModel.slotID == 5) ? 0.5 : 1

            Component.onCompleted: {
              clicked.connect(slotClicked);
            } //Component.onCompleted

            function slotClicked() {
              if (inspectModel.objectName == "") {
                return
              }
              if (root.currentSelectedObject == inspectModel) {
                root.currentSelectedObject = root.playerInformation
              } else {
                root.currentSelectedObject = inspectModel;
              }
            } //function slotClicked()

            Rectangle {
              id: highlightBorder
              anchors.fill: parent
              color: "transparent"
              border.color: "white"
              border.width: 1
              visible: inspectModel == root.currentSelectedObject
            } //Rectangle
          } //ContainerSlot
        } //Component

        ColumnLayout {
          spacing: TibiaStyle.marginNarrow

          Repeater {
            model: root.leftSideInventorySlots
            delegate: inventorySlotComponent
          } //Repeater
        } //ColumnLayout

        ColumnLayout {
          spacing: TibiaStyle.marginNarrow

          Repeater {
            model: root.middleInventorySlots
            delegate: inventorySlotComponent
          } //Repeater
        } //ColumnLayout

        ColumnLayout {
          spacing: TibiaStyle.marginNarrow

          Repeater {
            model: root.rightSideInventorySlots
            delegate: inventorySlotComponent
          } //Repeater
        } //ColumnLayout
      } //RowLayout

      OutfitAppearanceInstanceRenderer {
        anchors.fill: parent
        visible: !root.showInventory
        smoothTextureFiltering: root.clientSettingSmoothFiltering
        scaleFactor: 2

        outfitId: playerInformation != null ? playerInformation.appearanceID : 0
        headColor: playerInformation != null ? playerInformation.headColor : "black"
        torsoColor: playerInformation != null ? playerInformation.torsoColor : "black"
        legsColor: playerInformation != null ? playerInformation.legsColor : "black"
        detailColor: playerInformation != null ? playerInformation.detailColor : "black"
        firstAddOn: playerInformation != null && playerInformation.firstAddOn
        secondAddOn: playerInformation != null && playerInformation.secondAddOn
      } //OutfitAppearanceInstanceRenderer
    } //Item

    RowLayout {
      spacing: TibiaStyle.marginNarrow
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignLeft | Qt.AlignTop

      TibiaButton {
        Layout.preferredWidth: TibiaStyle.inspectObjectSpriteOuterSize / 2
        Layout.preferredHeight: TibiaStyle.inspectObjectSpriteOuterSize / 2
        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
        tooltipText: root.showInventory ? qsTrId("inspect_player_details_toolitp") : qsTrId("inspect_equipment_details_tooltip")
        imageSource: root.showInventory ? "/images/icon-playerdetails.png" : "/images/icon-equipmentdetails.png"
        onClicked: {
          root.setCurrentSelectedObject(playerInformation)
          root.showInventory = !root.showInventory
        } //onClicked
      } //TibiaButton

      TibiaButton {
        Layout.preferredWidth: TibiaStyle.inspectObjectSpriteOuterSize / 2
        Layout.preferredHeight: TibiaStyle.inspectObjectSpriteOuterSize / 2
        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
        tooltipText: qsTrId("inspect_character_skillwheel_tooltip")
        imageSource: "/images/icon-skillwheel-large.png"
        onClicked: {
          if (controller != null) {
            controller.openSkillWheelDialog();
          }
        } //onClicked
      } //TibiaButton

      Item {
        Layout.fillWidth: true
      } //Item
    } //RowLayout

    RowLayout {
      spacing: TibiaStyle.marginRelated

      Layout.rowSpan: 2
      Layout.alignment: Qt.AlignRight | Qt.AlignBottom

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

    TibiaText {
      Layout.fillWidth: true
      Layout.columnSpan: 2
      Layout.alignment: Qt.AlignBottom | Qt.AlignLeft
      text: currentSelectedObject != null ? qsTrId("inspect_inspecting").arg(currentSelectedObject.objectName) : ""
      wrapMode: Text.Wrap
    } //TibiaText
  } //GridLayout

  TibiaTextArea {
    id: objectInformation
    Layout.fillWidth: true
    Layout.fillHeight: true
    text: currentSelectedObject != null ? currentSelectedObject.objectInformation : ""
    readOnly: true
    wrapMode: TextEdit.Wrap
    textFormat: TextEdit.RichText
  } //TibiaTextArea
} //ColumnLayout
