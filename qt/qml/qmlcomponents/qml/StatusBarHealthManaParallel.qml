import QtQuick
import QtQuick.Layouts
import qmlcomponents




Item {
  property int maxValueHitPoints: 0
  property int currentValueHitPoints: 0
  property real hitpointsPercent: 1.0
  property int maxValueMana: 0
  property int currentValueMana: 0
  property real manaPercent: 1.0
  property int maxValueManashield: 0
  property int currentValueManashield: 0
  property real manaShieldPercent: 1.0
  property bool showManaShield: false
  property var playerStates : null // not used in this style
  property bool showPlayerStates: false // not used in this style
  property int statusBarHeight: TibiaStyle.progressBarSmallHeight
  property string sizeString: TibiaStyle.smallString
  property bool showCombopointsAndSerene: false // not used in this style
  property int comboPoints: 0 // not used in this style
  property bool isSerene: false // not used in this style

  implicitHeight: healthAndMana.height

  ColumnLayout {
    id: healthAndMana
    anchors { left: parent.left; right: parent.right; top: parent.top; }
    spacing: TibiaStyle.marginNarrow

    TibiaProgressBar { // health bar
      Layout.preferredHeight: statusBarHeight
      Layout.fillWidth: true
      fillPercentage: hitpointsPercent

      frameSource: "/images/1pixel-down-frame.png"
      backgroundSource: "/images/backdrop-dark-grey.png"
      fillSource: "/images/progressbar-" + sizeString + "-" + TibiaStyle.getThresholdForHealthPercent(hitpointsPercent) + ".png"

      frameBorder { left: 1; right: 1; top:1; bottom: 1}
      fillOffset { left: 1; right: 1; top:1; bottom: 1}

      TibiaText {
        anchors.centerIn: parent
        styleType: "White"
        text: currentValueHitPoints + "/" + maxValueHitPoints
      } //TibiaText
    } //TibiaProgressBar

    TibiaProgressBar { // mana bar
      Layout.preferredHeight: statusBarHeight
      Layout.fillWidth: true
      fillPercentage: manaPercent
      visible: !showManaShield

      frameSource: "/images/1pixel-down-frame.png"
      backgroundSource: "/images/backdrop-dark-grey.png"
      fillSource: "/images/progressbar-blue-" + sizeString + ".png"

      frameBorder { left: 1; right: 1; top:1; bottom: 1}
      fillOffset { left: 1; right: 1; top:1; bottom: 1}

      TibiaText {
        anchors.centerIn: parent
        styleType: "White"
        text: currentValueMana + "/" + maxValueMana
      } //TibiaText
    } //TibiaProgressBar


    TibiaProgressBarDoubleBars { // mana bar with mana shield
      Layout.preferredHeight: statusBarHeight
      Layout.fillWidth: true
      fillPercentageTop: manaPercent
      fillPercentageBottom: manaShieldPercent
      visible: showManaShield

      frameSource: "/images/1pixel-down-frame.png"
      backgroundSource: "/images/backdrop-dark-grey.png"
      fillSourceTop: "/images/progressbar-blue-tiny.png"
      fillSourceBottom: "/images/progressbar-manashield-tiny.png"

      frameBorder { left: 1; right: 1; top:1; bottom: 1}
      fillOffset { left: 1; right: 1; top:1; bottom: 1}

      Row {
        anchors.centerIn: parent

        TibiaText {
          styleType: "White"
          text: currentValueMana + "/" + maxValueMana + " (" + currentValueManashield + "/" + maxValueManashield
        } // TibiaText

        Image {
          anchors.verticalCenter: parent.verticalCenter
          source: "/images/manashield.png"
          smooth: false
        } // Image

        TibiaText {
          styleType: "White"
          text: ")"
        } // TibiaText
      } // Row
    } // TibiaProgressBarDoubleBars
  } // ColumnLayout
} // Item
