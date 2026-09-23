import QtQuick
import QtQuick.Layouts
import qmlcomponents
import qmlenumvalues


Item {
  id: statusBarRightCompact

  property var statusController: null

  property int maxValueHitPoints: statusController != null ? statusController.maxHitpoints : 0
  property int currentValueHitPoints: statusController != null ? statusController.currentHitpoints : 0
  property real hitpointsPercent: statusController != null ? statusController.hitpointsPercent : 1.0
  property int maxValueMana: statusController != null ? statusController.maxMana : 0
  property int currentValueMana: statusController != null ? statusController.currentMana : 0
  property real manaPercent: statusController != null ? statusController.manaPercent : 1.0
  property int maxValueManashield: statusController != null ? statusController.maxManaShield : 0
  property int currentValueManashield: statusController != null ? statusController.manaShield : 0
  property real manaShieldPercent: statusController != null ? statusController.manaShieldPercent : 1.0
  property bool showManaShield: statusController != null ? statusController.showManaShield : false
  property var playerStates : statusController != null && statusController.showPlayerStatesInBar ? statusController.playerStates : null
  property var skillList: statusController != null ? statusController.skillList : null
  property bool showCombopointsAndSerene: statusController != null ? statusController.showCombopointsAndSerene : false
  property int comboPoints: statusController != null ? statusController.comboPoints : 0
  property bool isSerene: statusController != null ? statusController.isSerene : false

  implicitWidth: background.width

  layer.enabled: UICachingEnabled

  BorderImage {
    id: background

    anchors {right: parent.right; top: parent.top; bottom: parent.bottom}
    border { right: TibiaStyle.sidebarButtonWidth + TibiaStyle.statusBarBackgroundBorderWidth; left: TibiaStyle.statusBarBackgroundBorderWidth;
             top: Math.min(background.height,TibiaStyle.sidebarButtonHeight); bottom: TibiaStyle.statusBarBackgroundBorderWidth }
    source: "/images/borderimage-statusbar-right.png"
    verticalTileMode: BorderImage.Repeat
    width: outerLayout.anchors.rightMargin + outerLayout.width + TibiaStyle.marginNarrow + TibiaStyle.statusBarBackgroundBorderWidth
    smooth: false

    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.RightButton
      onClicked: {
        if (statusController != null) {
          statusController.requestContextMenu();
        }
      } // onClicked
    } // MouseArea

    Tooltip {
      anchors.fill: parent
      text: qsTrId("right_click_for_more_options_tooltip")
    } //Tooltip

    RowLayout {
      id: outerLayout
      anchors { right: background.right; top: background.top; bottom: background.bottom;
                rightMargin: background.border.right + TibiaStyle.marginNarrow;
                topMargin: background.border.bottom + TibiaStyle.marginNarrow;
                bottomMargin: background.border.bottom + TibiaStyle.marginNarrow; }

      spacing: TibiaStyle.marginNarrow

      Loader {
        id: myStatesLoader
        Layout.alignment: Qt.AlignVCenter
        visible: sourceComponent != undefined

        sourceComponent: {
          if (statusController != null) {
            if (   statusController.dialogStyle == StatusBarController.Default
                || statusController.dialogStyle == StatusBarController.Parallel) {
              return statusBarStatesComponent
            }
          }
          return undefined;
        } //sourceComponent

        Component {
          id: statusBarStatesComponent
          ColumnLayout {
            id: columnLayOutStatusBar
            property alias playerStatesList: statesBar.playerStatesList
            property bool showCombopointsAndIsSerene: true
            property alias amountOfCombopoints: comboPointsAndSereneState.amountOfCombopoints
            property alias isSerene: comboPointsAndSereneState.isSerene

            spacing: TibiaStyle.marginRelated

            ColumnLayout {
              spacing: 0
              visible: columnLayOutStatusBar.showCombopointsAndIsSerene

              Item {
                Layout.preferredHeight: comboPointsAndSereneState.height < statesBar.height
                  ? statesBar.height - comboPointsAndSereneState.height
                  : 0
              } //Item

              ComboPointsAndSereneState {
                id: comboPointsAndSereneState
                horizontalView: false
              } // ComboPointsAndSereneState
            } //ColumnLayout

            ColumnLayout {
              spacing: 0

              StatesBar {
                id: statesBar
                fillColumns: true
                Layout.preferredWidth: TibiaStyle.healthManaBarSmallHeight
                Layout.preferredHeight: TibiaStyle.states10Width
                //Layout.alignment: Qt.AlignHCenter
              } //StatesBar

              Item {
                Layout.preferredHeight: statesBar.height < comboPointsAndSereneState.height
                  ? comboPointsAndSereneState.height - statesBar.height
                  : 0
              } //Item
            } //ColumnLayout

            StatusBarProficiencyButton {
              isHighlighted: statusController?.isProficiencyHighlighted
              positionType: StatusBarProficiencyButton.PositionType.Right
              Layout.bottomMargin: -3
              Layout.preferredWidth: statesBar.width
              Layout.preferredHeight: statesBar.width

              onClicked: {
                if (statusController != null) {
                  statusController.onClickedOpenProficiencies()
                }
              }
            }

            TibiaProgressBar {
              visible: statusController?.showProficiencyProgress
              fillPercentage: statusController?.proficiencyBarFillProgress || 0.0
              Layout.preferredWidth: 13
              Layout.preferredHeight: 100
              Layout.rightMargin: TibiaStyle.marginRelated
              vertical: true
              rightToLeft: false
              frameSource: "/images/1pixel-down-frame.png"
              frameBorder { left: 1; right: 1; top:1; bottom: 1 }
              backgroundSource: "/images/backdrop-dark-grey.png"
              fillSource: "/images/progressbar-teal-11px-vertical.png"
              fillOffset { left: 1; right: 1; top:1; bottom: 1 }

              Tooltip {
                anchors.fill: parent
                text: qsTrId("statusbar_proficiency_progress_tooltip")
                  .arg(TextHelper.formatNumberWithThousandSeparators(statusController?.currentProficiencyProgress))
                  .arg(TextHelper.formatNumberWithThousandSeparators(statusController?.proficiencyProgressNextLevel))
              } //Tooltip

              Image {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: -5
                rotation: 90
                source: statusController?.isProficiencyHighlighted ? "/images/icon-proficiencytree-on.png" : "/images/icon-proficiencytree-off.png"
                smooth: false

                Tooltip {
                  anchors.fill: parent
                  text: statusController?.isProficiencyHighlighted ? qsTrId("statusbar_proficiency_perk_choice_available_tooltip") : ""
                } // Tooltip
              } // Image

              TibiaText {
                anchors.centerIn: parent
                styleType: "Default"
                rotation: 90
                text: "%1%".arg(Math.trunc(parent.fillPercentage * 100))
              }
            } // TibiaProgressBar
          } //ColumnLayout
        } //Component

        onLoaded: {
          item.playerStatesList = Qt.binding(function() { return playerStates; });
          item.showCombopointsAndIsSerene = Qt.binding(function() { return showCombopointsAndSerene; });
          item.amountOfCombopoints = Qt.binding(function() { return comboPoints; });
          item.isSerene = Qt.binding(function() { return isSerene; });
          Layout.preferredWidth = item.implicitWidth;
        } //onLoaded
      } //Loader

      StatusBarSkillRight {
        Layout.fillHeight: true
        visible: (statusController != null ? (statusController.remainingSkill != null? true : false) : false)
        skillData: (statusController != null ? statusController.remainingSkill : null)
        dialogStyle: (statusController != null ? statusController.dialogStyle : StatusBarController.Default)
        skillText: (statusController != null ? (statusController.remainingSkill != null? statusController.remainingSkill.valueString : "") : "")
      } // StatusBarSkillRight

      GridLayout {
        id: gridLayout
        rows: 2
        visible: (skillList != null ? (skillList.length > 0 ? true : false) : false)
        flow: GridLayout.TopToBottom
        Layout.preferredHeight: outerLayout.height
        rowSpacing: TibiaStyle.marginRelated
        columnSpacing: TibiaStyle.marginRelated
        property int rowHeight: Math.floor((outerLayout.height - (rowSpacing))/2)

        Repeater {
          id: skillListRepeater
          model: skillList != null ? skillList.length : 0

          StatusBarSkillRight {
            Layout.minimumHeight: Math.floor(gridLayout.rowHeight)
            Layout.maximumHeight : Layout.minimumHeight
            property int initialIndex: (modelData % 2 == 0 ? ((skillList.length-1) - (modelData + 1)) : ((skillList.length-1) - (modelData -1)))
            property int index: (initialIndex >= 0 && initialIndex < skillList.length ? initialIndex : 0)
            skillData: skillList[index]
            dialogStyle: (statusController != null ? statusController.dialogStyle : StatusBarController.Default)
            skillText: (skillList[index] != null ? skillList[index].valueString : "")
          } // StatusBarSkillRight
        } // Repeater
      } // GridLayout


      ColumnLayout { // experience, if selected, it has to be shown first (always)
        id: xpLayout
        visible: (statusController != null ? (statusController.xpSkill != null? true : false) : false)
        Layout.fillHeight: true
        spacing: TibiaStyle.marginRelated

        // XP Boost Button
        TibiaIconButton {
          id: storeXpBoostButton
          sourceUp: "/images/button-storexp-noborder-right-idle.png"
          sourceDown: "/images/button-storexp-noborder-right-pressed.png"
          tooltipText: qsTrId("store_xp_boost_tooltip")
          Layout.alignment: Qt.AlignHCenter
          onClicked: {
            if (statusController != null) {
              statusController.onClickedOpenStoreXPBoost();
            }
          }
        } // TibiaIconButton


        StatusBarSkillRight {
          Layout.fillHeight: true
          Layout.alignment: Qt.AlignVCenter
          visible: (statusController != null ? (statusController.xpSkill != null? true : false) : false)
          skillData: (statusController != null ? statusController.xpSkill : null)
          dialogStyle: (statusController != null ? statusController.dialogStyle : StatusBarController.Default)
          skillText: (statusController != null ? (statusController.xpSkill != null? statusController.xpSkill.additionalValueString : "") : "")
        } // StatusBarSkillRight
      } // ColumnLayout

      Loader {
        id: contentLoader
        Layout.fillHeight: true
        source: {
          if (statusController != null) {
            if (statusController.dialogStyle == StatusBarController.Parallel) {
              return "StatusBarHealthManaParallelSides.qml";
            } else if (statusController.dialogStyle == StatusBarController.Large) {
              return "StatusBarHealthManaSides.qml";
            } else if (statusController.dialogStyle == StatusBarController.Compact) {
              return "StatusBarHealthManaSides.qml";
            } else if (statusController.dialogStyle == StatusBarController.Default) {
              return "StatusBarHealthManaSides.qml";
            }
          }
          return "";
        } //source

        onLoaded: {
          item.maxValueHitPoints = Qt.binding(function() { return maxValueHitPoints; });
          item.currentValueHitPoints = Qt.binding(function() { return currentValueHitPoints; });
          item.hitpointsPercent = Qt.binding(function() { return hitpointsPercent; });
          item.maxValueMana = Qt.binding(function() { return maxValueMana; });
          item.currentValueMana = Qt.binding(function() { return currentValueMana; });
          item.manaPercent = Qt.binding(function() { return manaPercent; });
          item.maxValueManashield = Qt.binding(function() { return maxValueManashield; });
          item.currentValueManashield = Qt.binding(function() { return currentValueManashield; });
          item.manaShieldPercent = Qt.binding(function() { return manaShieldPercent; });
          item.showManaShield = Qt.binding(function() { return showManaShield; });
          item.playerStates = Qt.binding(function() { return playerStates; });
          item.showCombopointsAndSerene = Qt.binding(function() { return showCombopointsAndSerene; });
          item.comboPoints = Qt.binding(function() { return comboPoints; });
          item.isSerene = Qt.binding(function() { return isSerene; });
          item.showPlayerStates = Qt.binding(function() {
            return (statusController != null)
                && (   statusController.dialogStyle == StatusBarController.Compact
                    || statusController.dialogStyle == StatusBarController.Large)
          });
          item.statusBarWidth = Qt.binding(function() {
            if (statusController != null) {
              if (statusController.dialogStyle == StatusBarController.Large) {
                return TibiaStyle.healthManaBarLargeHeight;
              } else {
                return TibiaStyle.healthManaBarSmallHeight;
              }
            }
            return 0;
          });
          item.sizeString = Qt.binding(function() {
            if (statusController != null) {
              if (statusController.dialogStyle == StatusBarController.Large) {
                return TibiaStyle.largeString;
              }
            }
            return TibiaStyle.smallString;
          });
          item.isOnLeftSide = false;
        } //onLoaded
      } // Loader
    } // RowLayout
  } // BorderImage
} // Item
