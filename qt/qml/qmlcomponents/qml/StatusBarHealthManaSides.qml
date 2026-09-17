import QtQuick
import QtQuick.Layouts

import qmlcomponents
import qmlenumvalues



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
  property var playerStates : null
  property bool showPlayerStates: false
  property int statusBarWidth: TibiaStyle.progressBarSmallHeight
  property string sizeString: TibiaStyle.smallString
  property bool showCombopointsAndSerene: false
  property int comboPoints: 0
  property bool isSerene: false

  property bool isOnLeftSide: false
  readonly property int textRotation: isOnLeftSide ? 270 : 90

  implicitWidth: healthAndMana.width

  ColumnLayout {
    id: healthAndMana
    anchors { left: parent.left; bottom: parent.bottom; top: parent.top; }

    TibiaProgressBar { // health bar
      id: healthBar
      Layout.preferredWidth: statusBarWidth
      Layout.fillHeight: true
      fillPercentage: hitpointsPercent
      vertical: true

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

    Loader {
      id: myStatesLoader
      visible: sourceComponent != undefined
      sourceComponent: showPlayerStates ? statusBarStatesComponent : undefined

      Component {
        id: statusBarStatesComponent
        ColumnLayout {

          id: columnLayOutStatusBar
          property alias playerStatesList: statesBar.playerStatesList
          property bool showCombopointsAndIsSerene: true
          property alias amountOfCombopoints: comboPointsAndSereneState.amountOfCombopoints
          property alias isSerene: comboPointsAndSereneState.isSerene


          ComboPointsAndSereneState {
            id: comboPointsAndSereneState
            Layout.alignment: Qt.AlignCenter
            visible: columnLayOutStatusBar.showCombopointsAndIsSerene

            horizontalView: false
          } // ComboPointsAndSereneState

          StatesBar {
            id: statesBar
            Layout.preferredWidth: sizeString == "small" ? TibiaStyle.healthManaBarSmallHeight : TibiaStyle.healthManaBarLargeHeight
            Layout.preferredHeight: sizeString == "small" ? TibiaStyle.states10Width : TibiaStyle.states5Width

            fillColumns: true
          } //StatesBar

          BorderImage {
            id: proficiencyButtonContainer
            readonly property bool isLargeStyle: statusController.dialogStyle == StatusBarController.Large

            Layout.preferredWidth: statesBar.width //+ (proficiencyButtonContainer.isLargeStyle ? 0 : 1)
            Layout.preferredHeight: statesBar.width

            source: "/images/backdrop-dark-grey.png"
            horizontalTileMode: BorderImage.Repeat
            verticalTileMode: BorderImage.Repeat
            smooth: false

            TibiaFrame1PixelDown {
              anchors.fill: parent
              visible: proficiencyButtonContainer.isLargeStyle
            } //TibiaFrame1PixelDown

            StatusBarProficiencyButton {
              isHighlighted: statusController?.isProficiencyHighlighted
              anchors.fill: parent
              anchors.margins: statusController?.showProficiencyProgress
                ? (proficiencyButtonContainer.isLargeStyle ? 3 : 1)
                : 0

              onClicked: {
                if (statusController != null) {
                  statusController.onClickedOpenProficiencies()
                }
              } //onClicked

              TibiaProgressBarWrapAround {
                z: -1
                barWidth: proficiencyButtonContainer.isLargeStyle ? 2 : 1
                visible: statusController?.showProficiencyProgress

                fillPercentage: statusController?.proficiencyBarFillProgress || 0.0
                color: "#00b9b1"
              } //TibiaProgressBarWrapAround
            } //StatusBarProficiencyButton

            Tooltip {
              anchors.fill: parent
              visible: statusController?.showProficiencyProgress
              text: qsTrId("statusbar_proficiency_button_tooltip")
                + "<br><br>"
                + qsTrId("statusbar_proficiency_progress_tooltip")
                  .arg(TextHelper.formatNumberWithThousandSeparators(statusController?.currentProficiencyProgress))
                  .arg(TextHelper.formatNumberWithThousandSeparators(statusController?.proficiencyProgressNextLevel))
            } //ToolTip

            Lenshelp {
              anchors.fill: parent
              caption: qsTrId("statusbar_proficiency_button_lenshelp_caption")
              content: qsTrId("statusbar_proficiency_button_lenshelp_content")
            } //Lenshelp
          } //BorderImage
        } // ColumnLayout
      } //Component

      onLoaded: {
        item.playerStatesList = Qt.binding(function() { return playerStates; });
        item.showCombopointsAndIsSerene = Qt.binding(function() { return showCombopointsAndSerene; });
        item.amountOfCombopoints = Qt.binding(function() { return comboPoints; });
        item.isSerene = Qt.binding(function() { return isSerene; });
      } //onLoaded
    } //Loader

    Component {
      id: defaultManaBarComponent

      TibiaProgressBar { // mana bar
        id: manaBar
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
    } // Component

    Component {
      id: manaBarAndShieldComponent

      TibiaProgressBarDoubleBars {
        id: manaBarDouble
        fillPercentageTop: isOnLeftSide ? manaPercent : manaShieldPercent
        fillPercentageBottom: isOnLeftSide ? manaShieldPercent : manaPercent
        vertical: true
        bottomToTop: true

        frameSource: "/images/1pixel-down-frame.png"
        backgroundSource: "/images/backdrop-dark-grey.png"
        fillSourceTop: isOnLeftSide ? "/images/progressbar-blue-tiny-vertical.png" : "/images/progressbar-manashield-tiny-vertical.png"
        fillSourceBottom: isOnLeftSide ? "/images/progressbar-manashield-tiny-vertical.png" : "/images/progressbar-blue-tiny-vertical.png"

        frameBorder { left: 1; right: 1; top:1; bottom: 1}
        fillOffset { left: 1; right: 1; top:1; bottom: 1}

        TibiaText {
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.verticalCenter: parent.verticalCenter
          anchors.horizontalCenterOffset: isOnLeftSide ? -(height/8)+1 : 0
          styleType: "White"
          text: currentValueMana + "/" + maxValueMana + " (" + currentValueManashield + "/" + maxValueManashield + "   )"

          //rotate text
          visible: (manaBarDouble.height > width)
          rotation: textRotation

          Image {
            source: "/images/manashield.png"
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: 6
            anchors.bottomMargin: 2
            smooth: false
          } // Image
        } // TibiaText
      } // TibiaProgressBarDoubleBars
    } // Component

    Component {
      id: largeManaBarAndShieldComponent

      RowLayout {
        spacing: 1
        layoutDirection: isOnLeftSide ? Qt.LeftToRight : Qt.RightToLeft

        TibiaProgressBar { // mana bar
          id: manaBarLarge

          Layout.fillHeight: true

          Layout.preferredWidth: Math.floor(statusBarWidth/2)
          fillPercentage: manaPercent
          vertical: true
          bottomToTop: true

          frameSource: "/images/1pixel-down-frame.png"
          backgroundSource: "/images/backdrop-dark-grey.png"
          fillSource: "/images/progressbar-blue-small-vertical.png"

          frameBorder { left: 1; right: 1; top:1; bottom: 1}
          fillOffset { left: 1; right: 1; top:1; bottom: 1}

          TibiaText {
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: isOnLeftSide ? -(height/8)+1 : 0
            styleType: "White"
            text: currentValueMana + "/" + maxValueMana
            rotation: textRotation
            visible: (manaBarLarge.height > width)
          } //TibiaText
        } //TibiaProgressBar

        TibiaProgressBar { // mana shield
          id: manaShieldBarLarge

          Layout.fillHeight: true

          Layout.preferredWidth: Math.floor(statusBarWidth/2)
          fillPercentage: manaShieldPercent
          vertical: true
          bottomToTop: true

          frameSource: "/images/1pixel-down-frame.png"
          backgroundSource: "/images/backdrop-dark-grey.png"
          fillSource: "/images/progressbar-manashield-small-vertical.png"

          frameBorder { left: 1; right: 1; top:1; bottom: 1}
          fillOffset { left: 1; right: 1; top:1; bottom: 1}

          TibiaText {
            styleType: "White"
            text: currentValueManashield + "/" + maxValueManashield
            rotation: textRotation

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenterOffset: isOnLeftSide ? -(height/8)+1 : 0.5

            visible: (manaShieldBarLarge.height > width)

            Image {
              source: "/images/manashield.png"

              anchors.left: parent.right
              anchors.bottom: parent.bottom
              anchors.rightMargin: 6
              anchors.bottomMargin: 2
              smooth: false
            } // Image
          } // TibiaText
        } //TibiaProgressBar
      } // RowLayout
    } // Component

    Loader {
      Layout.fillHeight: true
      Layout.preferredWidth: statusBarWidth
      sourceComponent: {
        if (!showManaShield) {
          return defaultManaBarComponent;
        } else if (showManaShield && sizeString == TibiaStyle.smallString) {
          return manaBarAndShieldComponent;
        } else if (showManaShield && sizeString == TibiaStyle.largeString) {
          return largeManaBarAndShieldComponent;
        } else {
          return undefined;
        }
      }
    } // Loader
  } // ColumnLayout
} // Item
