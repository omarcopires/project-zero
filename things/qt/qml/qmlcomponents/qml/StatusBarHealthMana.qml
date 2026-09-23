import QtQuick
import QtQuick.Layouts

import qmlcomponents
import qmlenumvalues

Item {
  id: root
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
  property int statusBarHeight: TibiaStyle.progressBarSmallHeight
  property string sizeString: TibiaStyle.smallString
  property bool showCombopointsAndSerene: false
  property int comboPoints: 0
  property bool isSerene: false

  implicitHeight: healthAndMana.height

  RowLayout {
    id: healthAndMana
    anchors { left: parent.left; right: parent.right; top: parent.top; }
    spacing: TibiaStyle.marginRelated

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

    Loader {
      id: myStatesLoader
      visible: sourceComponent != undefined
      sourceComponent: showPlayerStates ? statusBarStatesComponent : undefined

      Component {
        id: statusBarStatesComponent
        RowLayout {
          id: rowLayOutStatusBar
          property alias playerStatesList: statesBar.playerStatesList
          property bool showCombopointsAndIsSerene: true
          property alias amountOfCombopoints: comboPointsAndSereneState.amountOfCombopoints
          property alias isSerene: comboPointsAndSereneState.isSerene

          spacing: TibiaStyle.marginRelated

          BorderImage {
            id: proficiencyButtonContainer
            readonly property bool isLargeStyle: statusController.dialogStyle == StatusBarController.Large

            Layout.preferredWidth: statesBar.height + (proficiencyButtonContainer.isLargeStyle ? 0 : 1)
            Layout.preferredHeight: statesBar.height

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

          StatesBar {
            id: statesBar
            Layout.preferredWidth: sizeString == "small" ? TibiaStyle.states10Width : TibiaStyle.states5Width
            Layout.preferredHeight: sizeString == "small" ? TibiaStyle.healthManaBarSmallHeight : TibiaStyle.healthManaBarLargeHeight
          } //StatesBar

          ComboPointsAndSereneState {
            id: comboPointsAndSereneState
            visible: rowLayOutStatusBar.showCombopointsAndIsSerene

            horizontalView: true
          } // ComboPointsAndSereneState
        } // RowLayout
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

      TibiaProgressBar {
        fillPercentage: manaPercent
        rightToLeft: true

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
    } // Component

    Component {
      id: manaBarAndShieldComponent

      TibiaProgressBarDoubleBars {
        fillPercentageTop: manaPercent
        fillPercentageBottom: manaShieldPercent
        rightToLeft: true

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
    } // Component

    Component {
      id: largeManaBarAndShieldComponent

      ColumnLayout {
        spacing: 1

        TibiaProgressBar {
          Layout.fillWidth: true
          Layout.preferredHeight: Math.floor(statusBarHeight/2)
          fillPercentage: manaPercent
          rightToLeft: true

          frameSource: "/images/1pixel-down-frame.png"
          backgroundSource: "/images/backdrop-dark-grey.png"
          fillSource: "/images/progressbar-blue-" + "small" + ".png"

          frameBorder { left: 1; right: 1; top:1; bottom: 1}
          fillOffset { left: 1; right: 1; top:1; bottom: 1}

          TibiaText {
            anchors.centerIn: parent
            styleType: "White"
            text: currentValueMana + "/" + maxValueMana
          } //TibiaText
        } //TibiaProgressBar

        TibiaProgressBar {
          Layout.fillWidth: true
          Layout.preferredHeight: Math.floor(statusBarHeight/2)
          fillPercentage: manaShieldPercent
          rightToLeft: true

          frameSource: "/images/1pixel-down-frame.png"
          backgroundSource: "/images/backdrop-dark-grey.png"
          fillSource: "/images/progressbar-manashield-" + "small" + ".png"

          frameBorder { left: 1; right: 1; top:1; bottom: 1}
          fillOffset { left: 1; right: 1; top:1; bottom: 1}

          Row {
            anchors.centerIn: parent

            TibiaText {
              styleType: "White"
              text: currentValueManashield + "/" + maxValueManashield
            } // TibiaText

            Image {
              anchors.verticalCenter: parent.verticalCenter
              source: "/images/manashield.png"
              smooth: false
            } // Image
          } // Row
        } //TibiaProgressBar
      } // ColumnLayout
    } // Component


    Loader {
      Layout.preferredHeight: statusBarHeight
      Layout.fillWidth: true
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
  } // RowLayout
} // Item
