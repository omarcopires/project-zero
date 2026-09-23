import QtQuick
import QtQuick.Layouts

import "qrc:/qt/qml/qmlcomponents/qml/"

TibiaDialog {
  id: root

  property var controller: null;
  centerAtElement: controller != null ? controller.mapWindowPane() : parent

  property int currentIndex: 0
  property bool runAnimationsInSequentially: true

  showCaption: false

  width: mainLayout.width + 2*TibiaStyle.dialogMarginBorder
  caption: "Tutorial"
  headerDelegate: DialogHeaderCrest {}


  onReturnPressedFunction: function() {
    if (controller != null) {
      controller.requestClose();
    }
  } //onReturnPressedFunction: function()

  onRunAnimationsInSequentiallyChanged: {
    initializeAnimationOrder();
  }

  onCurrentIndexChanged: {
    initializeAnimationOrder();
  }

  Connections {
    readonly property var nextAnimation: runAnimationsInSequentially ? healCard : attackCard
    target: attackCard
    function onFinished() {
      nextAnimation.restartAnimation();
    }
  }
  Connections {
    readonly property var nextAnimation: runAnimationsInSequentially ? xpCard : healCard
    target: healCard
    function onFinished() {
      nextAnimation.restartAnimation();
    }
  }
  Connections {
    readonly property var nextAnimation: runAnimationsInSequentially ? attackCard : xpCard
    target: xpCard
    function onFinished() {
      if (runAnimationsInSequentially) {
        attackCard.resetAnimation();
        healCard.resetAnimation();
        xpCard.resetAnimation();
      }
      nextAnimation.restartAnimation();
    }
  }

  Connections {
    readonly property var nextAnimation: runAnimationsInSequentially ? sellingCard : lootingCard
    target: lootingCard
    function onFinished() {
      nextAnimation.restartAnimation();
    }
  }
  Connections {
    readonly property var nextAnimation: runAnimationsInSequentially ? bankCard : sellingCard
    target: sellingCard
    function onFinished() {
      nextAnimation.restartAnimation();
    }
  }
  Connections {
    readonly property var nextAnimation: runAnimationsInSequentially ? lootingCard : bankCard
    target: bankCard
    function onFinished() {
      if (runAnimationsInSequentially) {
        lootingCard.resetAnimation();
        sellingCard.resetAnimation();
        bankCard.resetAnimation();
      }
      nextAnimation.restartAnimation();
    }
  }

  function initializeAnimationOrder() {
    attackCard.stopAnimation();
    healCard.stopAnimation();
    xpCard.stopAnimation();
    lootingCard.stopAnimation();
    sellingCard.stopAnimation();
    bankCard.stopAnimation();

    switch (currentIndex) {
      case 1: {
        attackCard.restartAnimation();
        if (!runAnimationsInSequentially) {
          healCard.restartAnimation();
          xpCard.restartAnimation();
        }
        break;
      }
      case 2: {
        lootingCard.restartAnimation();
        if (!runAnimationsInSequentially) {
          sellingCard.restartAnimation();
          bankCard.restartAnimation();
        }
        break;
      }
    }
  }

  Component.onCompleted: () => {
    Qt.callLater( () => {
      root.centerDialog();
      initializeAnimationOrder();
    });
  }

  component VocationCardWithBanner: TibiaFrame1PixelDown {
    id: root
    property alias bannerSource: bannerImage.source
    property alias backdropSource: backdropImage.source
    property alias vocationText: vocationText.text
    implicitWidth: backdropImage.width + 2
    implicitHeight: backdropImage.height + 2
    Image {
      id: backdropImage
      anchors.left: parent.left
      anchors.top: parent.top
      anchors.leftMargin: 1
      anchors.topMargin: 1
      source: ""

    }
    TibiaText {
      id: vocationText
      anchors.fill: parent
      anchors.topMargin: 45
      horizontalAlignment: Text.AlignHCenter
      styleType: "White"
      font: TibiaStyle.defaultTightFont
    }
    Image {
      id: bannerImage
      anchors.top: parent.top
      anchors.topMargin: -12
      anchors.horizontalCenter: parent.horizontalCenter
      source: "/images/tutorial/banner_combat_01.png"
    }
  }

  component CombatCardWithBanner: TibiaFrame1PixelDown {
    id: root
    signal finished()

    function restartAnimation() {
      animation.restartAnimation();
    }
    function stopAnimation() {
      animation.stopAnimation();
    }
    function resetAnimation() {
      animation.resetAnimation();
    }

    property alias bannerSource: bannerImage.source
    property alias tutorialText: tutorialText.text
    property alias running: animation.running
    property alias tutorialType: animation.tutorialType

    Layout.fillWidth: true
    Layout.fillHeight: true
    Image {
      id: bannerImage
      anchors.top: parent.top
      anchors.topMargin: -12
      anchors.horizontalCenter: parent.horizontalCenter
      source: "/images/tutorial/banner_combat_01.png"
    }

    ColumnLayout {
      id: container
      anchors {left: parent.left; right: parent.right; top:bannerImage.bottom; bottom: parent.bottom;}
      anchors.margins: TibiaStyle.marginRelated
      clip: true
      TutorialAnimationCombat {
        id: animation
        Layout.fillWidth: true
        Layout.fillHeight: true

        onFinished: () => {
          root.finished()
        }
      }
      TibiaText {
        id: tutorialText
        Layout.fillWidth: true
        Layout.minimumHeight: 68
        Layout.leftMargin: -20 // markdown text bullet point has a huge left margin
        wrapMode: Text.WordWrap
        textFormat: Text.MarkdownText
      }
    } //Item
  }

  component LootCardWithBanner: TibiaFrame1PixelDown {
    id: root

    signal finished()

    function restartAnimation() {
      animation.restartAnimation();
    }
    function stopAnimation() {
      animation.stopAnimation();
    }
    function resetAnimation() {
      animation.resetAnimation();
    }

    default property alias content: container.data
    property alias bannerSource: bannerImage.source
    property alias tutorialText: tutorialText.text
    property alias tutorialType: animation.tutorialType
    property alias running: animation.running

    Image {
      id: bannerImage
      anchors.top: parent.top
      anchors.topMargin: -12
      anchors.horizontalCenter: parent.horizontalCenter
      source: "/images/tutorial/banner_combat_02.png"
    }
    ColumnLayout {
      id: container
      anchors {left: parent.left; right: parent.right; top:bannerImage.bottom; bottom: parent.bottom;}
      anchors.margins: TibiaStyle.marginRelated
      TutorialAnimationLoot {
        id: animation
        Layout.fillWidth: true
        Layout.fillHeight: true

        onFinished: () => {
          root.finished()
        }
      }
      TibiaText {
        id: tutorialText
        Layout.fillWidth: true
        Layout.minimumHeight: 68
        Layout.leftMargin: -20 // markdown text bullet point has a huge left margin
        wrapMode: Text.WordWrap
        textFormat: Text.MarkdownText
      }
    } //Item
  }

  component CaptionBackdrop: Image {
    id: root
    property alias imageSource: root.source
    property string numberText: ""
    property string captionText: ""
    property bool showNumberLeft: false
    property bool showLeftBorderLine: false
    property bool showRightBorderLine: false

    readonly property int gapWidth: (root.parent.width - root.width) / 2

    RowLayout {
      anchors.topMargin: 1
      anchors.leftMargin: 0
      anchors.fill: parent
      spacing: 0
      Rectangle {
        Layout.fillHeight: true
        Layout.preferredWidth: 1
        Layout.topMargin: -2
        color: "#646464"
        visible: showLeftBorderLine
      }
      RowLayout {
        Layout.fillHeight: true
        height: broadestNumberText.implicitHeight
        spacing: 0
        TibiaText {
          id: broadestNumberText
          visible: showNumberLeft
          font: TibiaStyle.tutorialCaptionFont
          styleType: "TutorialCaption"
          text: root.numberText
          horizontalAlignment: Text.AlignHCenter
          lineHeight: 1.0
          lineHeightMode: Text.ProportionalHeight // : Text.ProportionalHeight
          Layout.preferredWidth: gapWidth
        }
        Rectangle {
          Layout.fillHeight: true
          Layout.preferredWidth: 1
          Layout.topMargin: -2
          color: "#646464"
        }
        TibiaText {
          Layout.fillWidth: true
          Layout.leftMargin: 6
          font: TibiaStyle.tutorialCaptionFont
          styleType: "TutorialCaption"
          lineHeight: 1.0
          lineHeightMode: Text.ProportionalHeight // : Text.ProportionalHeight
          text: captionText
        }
        TibiaText {
          id: numberIIIRightText
          visible: !showNumberLeft
          font: TibiaStyle.tutorialCaptionFont
          styleType: "TutorialCaption"
          text: root.numberText
          horizontalAlignment: Text.AlignHCenter
          lineHeight: 1.0
          lineHeightMode: Text.ProportionalHeight // : Text.ProportionalHeight
          Layout.preferredWidth: gapWidth
        }
      }
      Rectangle {
        Layout.fillHeight: true
        Layout.preferredWidth: 1
        color: "#767676"
        visible: showRightBorderLine
      }
    }
  }


  component CaptionBackdropImage: TibiaFrame1PixelDown {
    id: root
    property int currentIndex: 0

    implicitWidth: imageBackdropVocations.width + 2 * borderWidth
    implicitHeight: imageBackdropVocations.height + 2 * borderWidth

    states: [
        State {
            name: "vocations"
            when: root.currentIndex == 0
            PropertyChanges { target: imageBackdropLoot;      z: 0 }
            PropertyChanges { target: imageBackdropCombat;    z: 1 }
            PropertyChanges { target: imageBackdropVocations; z: 2; showNumberLeft: true }
        },
        State {
            name: "combat"
            when: root.currentIndex == 1
            PropertyChanges { target: imageBackdropVocations; z: 1; showNumberLeft: true }
            PropertyChanges { target: imageBackdropCombat;    z: 2; showNumberLeft: true }
            PropertyChanges { target: imageBackdropLoot;      z: 0 }
        },
        State {
            name: "loot"
            when: root.currentIndex == 2
            PropertyChanges { target: imageBackdropLoot;      z: 2 ; showNumberLeft: true }
            PropertyChanges { target: imageBackdropCombat;    z: 1 ; showNumberLeft: true}
            PropertyChanges { target: imageBackdropVocations; z: 0 ; showNumberLeft: true}
        }
    ]

    CaptionBackdrop {
      id: imageBackdropLoot
      anchors.right: parent.right
      anchors.top: parent.top
      anchors.topMargin: 1
      anchors.rightMargin: 1
      source: "/images/tutorial/backdrop_loot.jpg"
      numberText: "III"
      captionText: "Loot and Gold"
      showLeftBorderLine: true
    }
    CaptionBackdrop {
      id: imageBackdropCombat
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.top: parent.top
      anchors.topMargin: 1
      source: "/images/tutorial/backdrop_combat.jpg"
      numberText: "II"
      captionText: "Combat"
      showLeftBorderLine: true
      showRightBorderLine: true
    }
    CaptionBackdrop {
      id: imageBackdropVocations
      anchors.left: parent.left
      anchors.top: parent.top
      anchors.topMargin: 1
      anchors.leftMargin: 1
      source: "/images/tutorial/backdrop_vocations.jpg"
      numberText: "I"
      captionText: "Vocations"
      showRightBorderLine: true
    }
  }

  ColumnLayout {
    id: mainLayout
    anchors.left: parent.left

    ColumnLayout {
      Layout.fillWidth: true
      Image {
        Layout.topMargin: 10
        source: "/images/tutorial/banner_tutorialpopup01.png"
        Layout.alignment: Qt.AlignHCenter
      }
      CaptionBackdropImage {
        currentIndex: root.currentIndex
        Layout.fillWidth: true
        // Layout.preferredHeight: imageProgressbar.height
      }
    }
    StackLayout {
      Layout.topMargin: 8
      currentIndex: root.currentIndex
      RowLayout {
        spacing: TibiaStyle.marginRelated
        VocationCardWithBanner {
          bannerSource: "/images/tutorial/banner_vocation_knight.png"
          backdropSource: "/images/tutorial/backdrop_knight.jpg"
          vocationText: qsTrId("tutorial_text_vocation_knight")
        }
        VocationCardWithBanner {
          bannerSource: "/images/tutorial/banner_vocation_sorcerer.png"
          backdropSource: "/images/tutorial/backdrop_sorcerer.jpg"
          vocationText: qsTrId("tutorial_text_vocation_sorcerer")
        }
        VocationCardWithBanner {
          bannerSource: "/images/tutorial/banner_vocation_druid.png"
          backdropSource: "/images/tutorial/backdrop_druid.jpg"
          vocationText: qsTrId("tutorial_text_vocation_druid")
        }
        VocationCardWithBanner {
          bannerSource: "/images/tutorial/banner_vocation_paladin.png"
          backdropSource: "/images/tutorial/backdrop_paladin.jpg"
          vocationText: qsTrId("tutorial_text_vocation_paladin")
        }
        VocationCardWithBanner {
          bannerSource: "/images/tutorial/banner_vocation_monk.png"
          backdropSource: "/images/tutorial/backdrop_monk.jpg"
          vocationText: qsTrId("tutorial_text_vocation_monk")
        }
      }
      RowLayout {
        Layout.fillHeight: true
        Layout.fillWidth: true
        CombatCardWithBanner {
          id: attackCard
          Layout.fillHeight: true
          Layout.fillWidth: true
          bannerSource: "/images/tutorial/banner_combat_01.png"
          tutorialText: qsTrId("tutorial_text_combat_attack")
          tutorialType: TutorialEnums.TutorialType.Attack
        }
        CombatCardWithBanner {
          id: healCard
          Layout.fillHeight: true
          Layout.fillWidth: true
          bannerSource: "/images/tutorial/banner_combat_02.png"
          tutorialText: qsTrId("tutorial_text_combat_healing")
          tutorialType: TutorialEnums.TutorialType.Heal
        }
        CombatCardWithBanner {
          id: xpCard
          Layout.fillHeight: true
          Layout.fillWidth: true
          bannerSource: "/images/tutorial/banner_combat_03.png"
          tutorialText: qsTrId("tutorial_text_combat_xp")
          tutorialType: TutorialEnums.TutorialType.XP
        }
      }
      RowLayout {
        Layout.fillHeight: true
        Layout.fillWidth: true
        Item {
          Layout.fillHeight: true
          Layout.fillWidth: true
          LootCardWithBanner {
            id: lootingCard
            anchors.fill: parent
            bannerSource: "/images/tutorial/banner_loot_01.png"
            tutorialText: qsTrId("tutorial_text_loot_looting")
            tutorialType: TutorialEnums.TutorialType.Looting
          }
        }
        Item {
          Layout.fillHeight: true
          Layout.preferredWidth: 368
          LootCardWithBanner {
            id: sellingCard
            anchors.fill: parent
            bannerSource: "/images/tutorial/banner_loot_02.png"
            tutorialText: qsTrId("tutorial_text_loot_sell")
            tutorialType: TutorialEnums.TutorialType.Selling
          }
        }
        Item {
          Layout.fillHeight: true
          Layout.fillWidth: true
          LootCardWithBanner {
            id: bankCard
            anchors.fill: parent
            bannerSource: "/images/tutorial/banner_loot_03.png"
            tutorialText: qsTrId("tutorial_text_loot_bank")
            tutorialType: TutorialEnums.TutorialType.Bank
          }
        }
      }
    }

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } // TibiaHorizontalSeparator

    RowLayout {
      id: buttonBar
      Layout.fillWidth: true
      spacing: TibiaStyle.marginRelated
      Item {
        Layout.fillWidth: true
      }

      Item {
        Layout.preferredWidth: okButton.width
        Layout.preferredHeight: okButton.height

        TibiaButton {
          id: okButton
          text: qsTrId("back")
          enabled: root.currentIndex > 0
          onClicked: {
            root.currentIndex -= 1
          }
        } //TibiaButton
      } //Item

      Item {
        Layout.preferredWidth: applyButton.width
        Layout.preferredHeight: applyButton.height
        TibiaButton {
          id: applyButton
          text: root.currentIndex < 2 ? qsTrId("next") : qsTrId("ok")
          onClicked: {
            if (root.currentIndex < 2) {
              root.currentIndex += 1
            } else {
              root.onReturnPressedFunction();
            }
          }
        } //TibiaButton
      } //Item
    } // RowLayout
  }
}
