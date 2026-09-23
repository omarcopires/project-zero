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
  property int statusBarWidth: TibiaStyle.progressBarSmallHeight
  property string sizeString: TibiaStyle.smallString
  property bool showCombopointsAndSerene: false // not used in this style
  property int comboPoints: 0 // not used in this style
  property bool isSerene: false // not used in this style

  property bool isOnLeftSide: false
  readonly property int textRotation: isOnLeftSide ? 270 : 90

  implicitWidth: healthAndMana.width

  RowLayout {
    id: healthAndMana
    anchors { left: parent.left; bottom: parent.bottom; top: parent.top; }
    spacing: TibiaStyle.marginNarrow

    TibiaProgressBar { // health bar
      id: healthBar
      Layout.preferredWidth: statusBarWidth
      Layout.fillHeight: true
      fillPercentage: hitpointsPercent
      vertical: true
      bottomToTop: true

      frameSource: "/images/1pixel-down-frame.png"
      backgroundSource: "/images/backdrop-dark-grey.png"
      fillSource: "/images/progressbar-" + sizeString + "-" + TibiaStyle.getThresholdForHealthPercent(hitpointsPercent) + "-vertical.png"

      frameBorder { left: 1; right: 1; top:1; bottom: 1}
      fillOffset { left: 1; right: 1; top:1; bottom: 1}

      TibiaText {
        anchors.centerIn: parent
        styleType: "White"
        text: currentValueHitPoints + "/" + maxValueHitPoints

        //rotate text
        visible: (healthBar.height > width)
        anchors.horizontalCenterOffset: isOnLeftSide ? -(height/8)+1 : 0
        rotation: textRotation
      } //TibiaText
    } //TibiaProgressBar

    TibiaProgressBar { // mana bar
      id: manaBar
      Layout.preferredWidth: statusBarWidth
      Layout.fillHeight: true
      fillPercentage: manaPercent
      vertical: true
      bottomToTop: true
      visible: !showManaShield

      frameSource: "/images/1pixel-down-frame.png"
      backgroundSource: "/images/backdrop-dark-grey.png"
      fillSource: "/images/progressbar-blue-" + sizeString + "-vertical.png"

      frameBorder { left: 1; right: 1; top:1; bottom: 1}
      fillOffset { left: 1; right: 1; top:1; bottom: 1}

      TibiaText {
        anchors.centerIn: parent
        styleType: "White"
        text: currentValueMana + "/" + maxValueMana

        //rotate text
        visible: (manaBar.height > width)
        anchors.horizontalCenterOffset: isOnLeftSide ? -(height/8)+1 : 0
        rotation: textRotation
      } //TibiaText
    } //TibiaProgressBar


    TibiaProgressBarDoubleBars { // mana bar and mana shield
      id: manaAndManaShieldBar
      Layout.preferredWidth: statusBarWidth
      Layout.fillHeight: true

      fillPercentageTop: isOnLeftSide ? manaPercent : manaShieldPercent
      fillPercentageBottom: isOnLeftSide ? manaShieldPercent : manaPercent
      vertical: true
      bottomToTop: true

      visible: showManaShield

      frameSource: "/images/1pixel-down-frame.png"
      backgroundSource: "/images/backdrop-dark-grey.png"
      fillSourceTop: isOnLeftSide ? "/images/progressbar-blue-tiny-vertical.png" : "/images/progressbar-manashield-tiny-vertical.png"
      fillSourceBottom: isOnLeftSide ? "/images/progressbar-manashield-tiny-vertical.png" : "/images/progressbar-blue-tiny-vertical.png"

      frameBorder { left: 1; right: 1; top:1; bottom: 1}
      fillOffset { left: 1; right: 1; top:1; bottom: 1}

      ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenterOffset: isOnLeftSide ? -(height/8)+1 : 0

        TibiaText {
          styleType: "White"
          text: currentValueMana + "/" + maxValueMana + " (" + currentValueManashield + "/" + maxValueManashield + "   )"

          //rotate text
          visible: (manaAndManaShieldBar.height > width)
          rotation: textRotation

          Image {
            //anchors.verticalCenter: parent.verticalCenter
            source: "/images/manashield.png"
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: 6
            anchors.bottomMargin: 2
            smooth: false
          } // Image
        } // TibiaText
      } // ColumnLayout
    } // TibiaProgressBarDoubleBars
  } // RowLayout
} // Item
