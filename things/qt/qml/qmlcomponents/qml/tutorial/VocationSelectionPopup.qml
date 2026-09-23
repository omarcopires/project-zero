import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import qmlcomponents

import "qrc:/qt/qml/qmlcomponents/qml/"

TibiaDialog {
  id: dialogRoot

  required property var controller
  centerAtElement: controller.mapWindowPane()

  property var spellListModel: controller.spellListModel

  showCaption: false

  width: mainLayout.width + 2*TibiaStyle.dialogMarginBorder
  caption: "Tutorial"
  headerDelegate: DialogHeaderCrest {}

  //no keyboard navigation to close dialog
  onReturnPressedFunction: null
  onCancelPressedFunction: null

  component VocationCardWithBanner: TibiaFrame1PixelDown {
    id: root
    property int vocation: TibiaEnums.Knight
    property alias bannerSource: bannerImage.source
    property alias backdropSource: backdropImage.source
    property alias vocationText: vocationText.text
    property string vocationName: ""
    property var exampleSpells: []
    property var exampleGear: []
    property int bannerBaseline: 57
    property bool confirmVisible: false
    property bool hovered: mouseArea.containsMouse
    implicitWidth: backdropImage.width + 2
    implicitHeight: backdropImage.height + 2


    Image {
      id: backdropImage
      anchors.left: parent.left
      anchors.top: parent.top
      anchors.leftMargin: 1
      anchors.topMargin: 1
      source: ""
      opacity: 0.7
    }
    TibiaText {
      id: vocationText
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.top: backdropImage.top
      anchors.topMargin: bannerBaseline + 4
      horizontalAlignment: Text.AlignHCenter
      styleType: "White"
      font: TibiaStyle.defaultTightFont
    }
    Item {
      id: framedButtonSelect
      implicitWidth: btnFrame2.implicitWidth
      implicitHeight: btnFrame2.implicitHeight
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 45
      anchors.horizontalCenter: parent.horizontalCenter
      z: 10
      Image {
        id: btnFrame2
        source: "/images/tutorial/button_startplaying_idle.png"
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        visible: !root.confirmVisible
      }

      TibiaButton {
        anchors.fill: parent
        id: selectButton
        anchors.margins: TibiaStyle.startplayingDecorationMargin
        anchors.bottomMargin: TibiaStyle.startplayingDecorationBottomMargin
        enabled: !root.confirmVisible
        text: qsTrId("vocation_selection_select_vocation_button").arg(vocationName)
        color: root.confirmVisible ? "darkgrey" : "green"
        checked: root.confirmVisible
        textXOffset: root.confirmVisible ? -pressedPadding : 0
        textYOffset: root.confirmVisible ? -pressedPadding : 0

        onClicked: {
          confirmVisible = true   //open Scroll-Up
        } //onClicked
      } //TibiaButton
    }
    Image {
      id: bannerImage
      anchors.top: parent.top
      anchors.topMargin: 0
      anchors.horizontalCenter: parent.horizontalCenter
      source: "/images/tutorial/banner_combat_01.png"
    }
    Item {
      id: hintRectangleWrapper
      anchors.fill: parent
      clip: true
      TibiaFrame2PixelUpFilled {
        id: hintRectangle
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: root.borderWidth
        source: "/images/tutorial/backdrop-vocationinfo.png"
        height: source.height
        y: -height
        visible: true

        ColumnLayout {
          id: spellRow
          anchors.fill: parent
          spacing: TibiaStyle.marginRelated
          Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: spellsLayout.height
            Layout.margins: TibiaStyle.marginUnrelated
            color: "transparent"
            ColumnLayout {
                id: spellsLayout
              ColumnLayout {
                Layout.margins: TibiaStyle.marginRelated
                Layout.fillWidth: true
                GridLayout {
                  columns: 4

                  Repeater {
                  model: exampleSpells

                  Item {
                    width: 40
                    height: 40

                    Image {
                      id: spellBorder
                      anchors.centerIn: parent
                      source: "/images/tutorial/border-vocationinfo-spells.png"
                    }

                    Image {
                      id: spellIcon
                      anchors.centerIn: spellBorder
                      width: 32
                      height: 32
                      property int spellId: getSpellIdForSpellName(modelData)
                      source: spellId !== -1 ? `image://spell-icons-32x32/${spellId}` : ""
                    }

                    MultiEffect {
                      anchors.fill: spellBorder
                      source: spellBorder
                      shadowEnabled: true
                      shadowHorizontalOffset: 5
                      shadowVerticalOffset: 5
                      shadowBlur: 0
                      opacity: 0.33
                      z: -1
                    }
                    MultiEffect {
                      anchors.fill: spellIcon
                      source: spellIcon
                      shadowEnabled: true
                      shadowHorizontalOffset: 5
                      shadowVerticalOffset: 5
                      shadowBlur: 0
                      opacity: 0.33
                      z: -1
                    }
                  }
                }
                }
              }
            }
          }
          Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: gearLayout.height
            Layout.margins: TibiaStyle.marginUnrelated
            color: "transparent"

            ColumnLayout {
              id: gearLayout
              ColumnLayout {
                Layout.margins: TibiaStyle.marginRelated
                Layout.fillWidth: true

                Item {
                  Layout.alignment: Qt.AlignRight
                  implicitWidth: gearGrid.implicitWidth
                  implicitHeight: gearGrid.implicitHeight
                  width: gearGrid.implicitWidth

                  GridLayout {
                    id: gearGrid
                    y: -20
                    anchors.right: parent.right   //right-alignment
                    anchors.rightMargin: -10
                    columns: 4
                    rowSpacing: 6
                    columnSpacing: 6

                    Item {   // placeholder for column 0
                      Layout.column: 0
                      Layout.row: 0
                      Layout.rowSpan: 2
                      Layout.preferredWidth: 32
                      Layout.preferredHeight: 32
                    }

                    // Gear-Icons
                    Repeater {
                      model: exampleGear
                      Item {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        Layout.column: (index % 3) + 1
                        Layout.row: Math.floor(index / 3)
                        SingleObjectAppearanceInstanceRenderer {
                          id: exampleGearRenderer
                          anchors.fill: parent
                          animated: true
                          typeid: modelData
                        }
                        MultiEffect {
                          anchors.fill: exampleGearRenderer
                          source: exampleGearRenderer
                          shadowBlur: 0.0
                          shadowEnabled: true
                          shadowColor: "black"
                          shadowVerticalOffset: 5
                          shadowHorizontalOffset: 5
                          opacity: 0.33
                        }
                      }
                    }
                  }
                }
              }
            }
          }
          Item {
            Layout.fillHeight: true
          }
          Item {
            id: framedButtonConfirm
            implicitWidth: btnFrame.implicitWidth
            implicitHeight: btnFrame.implicitHeight
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: TibiaStyle.marginUnrelated
            anchors.bottomMargin: TibiaStyle.marginUnrelated
            visible: root.confirmVisible
            enabled: root.confirmVisible
            opacity: root.confirmVisible ? 1 : 0
            Image {
              id: btnFrame
              source: "/images/tutorial/button_startplaying_idle.png"
              anchors.fill: parent
              fillMode: Image.PreserveAspectFit
            }
            TibiaButton {
              id: confirmButton
              anchors.fill: parent
              anchors.margins: TibiaStyle.startplayingDecorationMargin
              anchors.bottomMargin: TibiaStyle.startplayingDecorationBottomMargin
              text: qsTrId("confirm")
              color: "green"
              onClicked: {
                dialogRoot.controller.selectVocation(root.vocation);
              } //onClicked
            } //TibiaButton
          } //Item
        }
      }
    }


    MouseArea {
      id: mouseArea
      anchors.fill: root
      hoverEnabled: true
      height: parent.height
      acceptedButtons: Qt.NoButton
      z: 11
      onExited: {
        root.confirmVisible = false   // reset visibility of buttons
      }
    } //MouseArea

    states: [
      State {
          name: "HOVERED"
          when: root.hovered
          PropertyChanges { target: backdropImage; opacity: 1.0 }
          PropertyChanges { target: hoverBorder; visible: true; opacity: 1 }
      },
      State {
        name: ""
        PropertyChanges { target: root; confirmVisible: false }
        PropertyChanges { target: hoverBorder; visible: false; opacity: 0 }
      }
    ]
    transitions: [
      Transition {
        from: ""
        to: "HOVERED"
        NumberAnimation {
          target: hintRectangle
          duration: 300
          from: hintRectangleWrapper.height
          to: hintRectangleWrapper.height - hintRectangle.height
          property: "y"
        }
      },
      Transition {
        from: "HOVERED"
        to: ""
        NumberAnimation {
          target: hintRectangle
          duration: 100
          to: hintRectangleWrapper.height
          property: "y"
        }
      }
    ]
    BorderImage {
      id: hoverBorder
      anchors.fill: root
      source: "/images/containerslot-goldenborder.png"

      border { left: 2; top: 2; right: 2; bottom: 2 }

      horizontalTileMode: BorderImage.Stretch
      verticalTileMode:   BorderImage.Stretch

      visible: root.hovered
      opacity: root.hovered ? 1 : 0
      z: 99

      // weiche Ein- & Ausblendung
      Behavior on opacity { NumberAnimation { duration: 150 } }
    } //BorderImage
  } //component VocationCardWithBanner


  ColumnLayout {
    id: mainLayout
    spacing: TibiaStyle.marginRelated

    Image {
      Layout.alignment: Qt.AlignHCenter
      Layout.topMargin: TibiaStyle.captionFlagTopMargin
      source: switch (dialogRoot.controller.stage) {
        case 1: "/images/tutorial/banner_tutorialpopup01.png"; break;
        case 0: "/images/tutorial/banner_tutorialpopup_welcometonewhaven.png"; break;
        default: ""; break;
      } //source
    } //Image
    Item {
      Layout.fillWidth: true
    } //Item

    RowLayout {
      id: vocationCardsLayout
      property var vocationCards: []

      spacing: TibiaStyle.marginRelated

      visible: dialogRoot.controller.stage == 1

      Component.onCompleted: {
        for (let i = 0; i < children.length; i++) {
          let child = children[i];
          if (child.toString().startsWith("VocationCardWithBanner")) {
            vocationCards.push(child);
          }
        }
      } //Component.onCompleted

      VocationCardWithBanner {
        vocation: TibiaEnums.Knight
        bannerSource: "/images/tutorial/banner_vocation_knight.png"
        backdropSource: "/images/tutorial/backdrop_knight.jpg"
        vocationText: qsTrId("tutorial_text_vocation_knight")
        vocationName: qsTrId("knight")
      }
      VocationCardWithBanner {
        vocation: TibiaEnums.Sorcerer
        bannerSource: "/images/tutorial/banner_vocation_sorcerer.png"
        backdropSource: "/images/tutorial/backdrop_sorcerer.jpg"
        vocationText: qsTrId("tutorial_text_vocation_sorcerer")
        vocationName: qsTrId("sorcerer")
      }
      VocationCardWithBanner {
        vocation: TibiaEnums.Druid
        bannerSource: "/images/tutorial/banner_vocation_druid.png"
        backdropSource: "/images/tutorial/backdrop_druid.jpg"
        vocationText: qsTrId("tutorial_text_vocation_druid")
        vocationName: qsTrId("druid")

      }
      VocationCardWithBanner {
        vocation: TibiaEnums.Paladin
        bannerSource: "/images/tutorial/banner_vocation_paladin.png"
        backdropSource: "/images/tutorial/backdrop_paladin.jpg"
        vocationText: qsTrId("tutorial_text_vocation_paladin")
        vocationName: qsTrId("paladin")
      }
      VocationCardWithBanner {
        vocation: TibiaEnums.Monk
        bannerSource: "/images/tutorial/banner_vocation_monk.png"
        backdropSource: "/images/tutorial/backdrop_monk.jpg"
        vocationText: qsTrId("tutorial_text_vocation_monk")
        vocationName: qsTrId("monk")
      }
    } //RowLayout

    TibiaFrame1PixelDown {
      Layout.preferredWidth: welcomeBackropImage.width + 2 * borderWidth
      Layout.preferredHeight: welcomeBackropImage.height + 2 * borderWidth

      visible: dialogRoot.controller.stage == 0

      Image {
        id: welcomeBackropImage
        anchors.centerIn: parent
        source: "/images/tutorial/backdrop_popup_welcometotibia.jpg"

        TibiaButton {
          anchors.bottom: parent.bottom
          anchors.left: parent.left
          anchors.bottomMargin: 45
          anchors.leftMargin: 129
          width: TibiaStyle.buttonWidthWider
          color: "green"
          textStyle: "Default"
          text: qsTrId("journey_on")
          onClicked: dialogRoot.controller.nextPageClicked();

          Image {
            x: -TibiaStyle.startplayingDecorationMargin
            y: -TibiaStyle.startplayingDecorationMargin
            source: "/images/tutorial/button_startplaying_idle.png"
          } //Image

          ButtonHighlightAnimation {
            running: true
            anchors.fill: parent
            animationSpeedFactor: 1.4
            pauseBetweenLoops: 0
            highlightLoops: Animation.Infinite
            pauseBetweenHighlights: 2000
          }
          HoverHandler {
            onHoveredChanged: {
              if (tibiaMouseCursorController != null) {
                tibiaMouseCursorController.setPointingHand(hovered)
              }
            }
          } // HoverHandler
        } //TibiaButton
      } //Image
    } //TibiaFrame1PixelDown

  } //ColumnLayout

  function getSpellIdForSpellName(spellName) {
    if (dialogRoot.spellListModel) {
      let _helperModel = AbstractItemModelHelper.wrapInHelperProxyModel(dialogRoot.spellListModel);
      for (let i = 0; i < _helperModel.rowCount(); i++) {
        let spellInfo = _helperModel.sourceItemDataByRowIndex(i)
        if (spellInfo.name == spellName) {
          return spellInfo.iconIndex;
        }
      }
    }
    return -1;
  } //function getSpellIdForSpellName

  Component.onCompleted: {
    let vocationSelectionData = AbstractItemModelHelper.loadJsonFromResource(":/tutorial/vocation-selection-dialog-data.json");

    let jsonNamesForVocation =  {};
    jsonNamesForVocation[TibiaEnums.Knight] = "Knight";
    jsonNamesForVocation[TibiaEnums.Sorcerer] = "Sorcerer";
    jsonNamesForVocation[TibiaEnums.Druid] = "Druid";
    jsonNamesForVocation[TibiaEnums.Paladin] = "Paladin";
    jsonNamesForVocation[TibiaEnums.Monk] = "Monk";

    vocationCardsLayout.vocationCards.forEach ( (vocationCard) => {
      let jsonNameForVocation = jsonNamesForVocation[vocationCard.vocation];
      if (jsonNameForVocation) {
        if (vocationSelectionData.vocationData[jsonNameForVocation]) {
          vocationCard.exampleSpells = vocationSelectionData.vocationData[jsonNameForVocation].exampleSpells;
          vocationCard.exampleGear = vocationSelectionData.vocationData[jsonNameForVocation].exampleGear;
        }
      }
    });
  } //Component.onCompleted
} //TibiaDialog
