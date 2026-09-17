import QtQuick
import QtQuick.Layouts
import qmlcomponents

Item {
  property var spellGroupCooldowns: null
  property var spellCooldowns: null

  implicitHeight: TibiaStyle.cooldownBarHeight
  implicitWidth: rowLayout.width

  Component {
    id: iconWithProgressBarShadedWhenOnCooldown

    BorderImage {
      id: spellIconBorder
      Layout.preferredWidth: spellIcon.width + 2
      Layout.preferredHeight: spellIcon.height + 2 + 2
      border { left: 1; top: 1; right: 1; bottom: 1 }
      horizontalTileMode: BorderImage.Repeat
      verticalTileMode: BorderImage.Repeat
      source: "/images/skin/classic/button-textured-up.png"
      smooth: false

      Image {
        id: spellIcon
        anchors {left: parent.left; top: parent.top}
        anchors.margins: 1
        source: modelData.sourceURL
        smooth: false

        Rectangle {
          anchors.fill: parent
          color: "black"
          opacity: TibiaStyle.opacityOfCooldownBarIconOverlay
          visible: modelData.remainingDurationMilliseconds == 0
        } //Rectangle
      } //Image

      Rectangle {
        id: cooldownBarBackground
        anchors {left: parent.left; top: spellIcon.bottom; right: parent.right; bottom: parent.bottom }
        anchors.margins: 1
        anchors.topMargin: 0
        color: "black"

        Rectangle {
          Component.onCompleted: {
            numberAnimation.restart();
          }
          anchors {left: parent.left; top: parent.top; bottom: parent.bottom }
          color: "white"

          NumberAnimation on width {
            id: numberAnimation
            from: cooldownBarBackground.width * Math.min(parseFloat(modelData.remainingDurationMilliseconds) / parseFloat(modelData.totalDurationMilliseconds), 1.0);
            to: 0;
            duration: modelData.remainingDurationMilliseconds
          } //NumberAnimation on width
        } //Rectangle

      } //Rectangle

      Tooltip {
        anchors.fill: parent
        text: modelData.tooltip
      } //Tooltip
    }  // BorderImage
  } //Component

  RowLayout {
    id: rowLayout
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left
    Layout.fillWidth: true
    spacing: TibiaStyle.marginCooldownBar

    RowLayout {
      spacing: TibiaStyle.marginCooldownBar

      Repeater {
        id: spellGroupCooldownsRepeater
        model: spellGroupCooldowns

        delegate: iconWithProgressBarShadedWhenOnCooldown
      } // Repeater
    } // RowLayout SpellGroup icons

    TibiaVerticalSeparator {
      Layout.maximumHeight: TibiaStyle.cooldownBarHeight
      Layout.preferredHeight: Layout.maximumHeight
      rotation: 180
    } //TibiaVerticalSeparator

    RowLayout {
      spacing: TibiaStyle.marginCooldownBar

      Repeater {
        id: spellCooldownsRepeater
        model: spellCooldowns

        delegate: iconWithProgressBarShadedWhenOnCooldown
      } // Repeater
    } // RowLayout Spell icons
  } // RowLayout

  Lenshelp {
    anchors.fill: parent
    caption: qsTrId("spellcooldown_lenshelp_caption")
    content: qsTrId("spellcooldown_lenshelp")
  } //Lenshelp
} // Item
