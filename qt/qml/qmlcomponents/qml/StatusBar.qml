import QtQuick
import QtQuick.Layouts
import qmlcomponents
import qmlenumvalues


Item {
  id: statusBarUpperCompact

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

  property bool isTopAnchored: statusController != null && statusController.dialogAnchor == StatusBarController.Top

  implicitHeight: background.height + bottomBorder.height

  layer.enabled: UICachingEnabled

  BorderImage { // der hintergrund
    id: background

    readonly property int topBorderHeight: isTopAnchored ? Math.min(background.height, TibiaStyle.sidebarButtonHeight) : TibiaStyle.statusBarBackgroundBorderWidth
    readonly property int sideBorderWidth: isTopAnchored ? TibiaStyle.sidebarButtonWidth + TibiaStyle.statusBarBackgroundBorderWidth : TibiaStyle.statusBarBackgroundBorderWidth
    readonly property int bottomBorderWidth: isTopAnchored ? 0 : TibiaStyle.statusBarBackgroundBorderWidth

    anchors { left: parent.left; top: parent.top; right: parent.right; }
    border { left: sideBorderWidth; right: sideBorderWidth; top: topBorderHeight; bottom: bottomBorderWidth; }
    source: isTopAnchored ? "/images/borderimage-statusbar-top.png" : "/images/2pixel-up-frame-borderimage.png"
    horizontalTileMode: BorderImage.Repeat
    verticalTileMode: BorderImage.Repeat
    height: outerLayout.anchors.topMargin + outerLayout.height + TibiaStyle.marginNarrow + bottomBorderWidth
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

    ColumnLayout {
      id: outerLayout
      anchors { left: background.left; top: background.top; right: background.right;
                leftMargin: background.border.left + TibiaStyle.marginNarrow;
                topMargin: TibiaStyle.statusBarBackgroundBorderWidth + TibiaStyle.marginNarrow
                rightMargin: background.border.right + TibiaStyle.marginNarrow}

      spacing: TibiaStyle.marginNarrow

      Loader {
        id: contentLoader
        Layout.fillWidth: true
        source: {
          if (statusController != null) {
            if (statusController.dialogStyle == StatusBarController.Parallel) {
              return "StatusBarHealthManaParallel.qml";
            } else if (statusController.dialogStyle == StatusBarController.Large) {
              return "StatusBarHealthMana.qml";
            } else if (statusController.dialogStyle == StatusBarController.Compact) {
              return "StatusBarHealthMana.qml";
            } else if (statusController.dialogStyle == StatusBarController.Default) {
              return "StatusBarHealthMana.qml";
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
          item.statusBarHeight = Qt.binding(function() {
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
        } //onLoaded
      } // Loader

      RowLayout { // experience, if selected, it has to be shown first (always)
        visible: statusController != null && statusController.xpSkill != null
        spacing: TibiaStyle.marginRelated

        StatusBarSkill {
          Layout.fillWidth: true
          Layout.alignment: Qt.AlignVCenter
          visible: (statusController != null ? (statusController.xpSkill != null? true : false) : false)
          skillData: (statusController != null ? statusController.xpSkill : null)
          dialogStyle: (statusController != null ? statusController.dialogStyle : StatusBarController.Default)
          skillText: (statusController != null ? (statusController.xpSkill != null? statusController.xpSkill.additionalValueString : "") : "")
        } // StatusBarSkill

        TibiaIconButton {
          id: storeXpBoostButton
          sourceUp: "/images/button-storexp-noborder-idle.png"
          sourceDown: "/images/button-storexp-noborder-pressed.png"
          tooltipText: qsTrId("store_xp_boost_tooltip")

          onClicked: {
            if (statusController != null) {
              statusController.onClickedOpenStoreXPBoost();
            }
          } //onClicked
        } // TibiaIconButton
      } // RowLayout

      GridLayout {
        id: gridLayout
        columns: 2
        visible: (skillList != null ? (skillList.length > 0 ? true : false) : false)
        Layout.preferredWidth: outerLayout.width
        columnSpacing: TibiaStyle.marginRelated//TibiaStyle.marginUnrelated
        rowSpacing: TibiaStyle.marginRelated
        property int columnWidth: Math.floor((outerLayout.width - (columnSpacing))/2)

        Repeater {
          id: skillListRepeater
          model: skillList

          StatusBarSkill {
            Layout.minimumWidth: Math.floor(gridLayout.columnWidth)
            Layout.maximumWidth : Layout.minimumWidth
            skillData: modelData
            dialogStyle: (statusController != null ? statusController.dialogStyle : StatusBarController.Default)
            skillText: (modelData != null ? modelData.valueString : "")
          } // StatusBarSkill
        } // Repeater
      } // GridLayout

      StatusBarSkill {
        Layout.fillWidth: true
        visible: (statusController != null ? (statusController.remainingSkill != null? true : false) : false)
        skillData: (statusController != null ? statusController.remainingSkill : null)
        dialogStyle: (statusController != null ? statusController.dialogStyle : StatusBarController.Default)
        skillText: (statusController != null ? (statusController.remainingSkill != null? statusController.remainingSkill.valueString : "") : "")
      } // StatusBarSkill

      Loader {
        id: myStatesLoader
        Layout.alignment: Qt.AlignHCenter
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
          RowLayout {
            id: rowLayOutStatusBar
            property alias playerStatesList: statesBar.playerStatesList
            property bool showCombopointsAndIsSerene: true
            property alias amountOfCombopoints: comboPointsAndSereneState.amountOfCombopoints
            property alias isSerene: comboPointsAndSereneState.isSerene

            spacing: TibiaStyle.marginRelated

            StatusBarProficiencyButton {
              isHighlighted: statusController?.isProficiencyHighlighted
              Layout.rightMargin: -3
              Layout.preferredWidth: statesBar.height
              Layout.preferredHeight: statesBar.height

              onClicked: {
                if (statusController != null) {
                  statusController.onClickedOpenProficiencies()
                }
              }
            }

            TibiaProgressBar {
              visible: statusController?.showProficiencyProgress
              fillPercentage: statusController?.proficiencyBarFillProgress || 0.0
              Layout.preferredWidth: 100
              Layout.preferredHeight: statesBar.height
              Layout.rightMargin: TibiaStyle.marginRelated
              frameSource: "/images/1pixel-down-frame.png"
              frameBorder { left: 1; right: 1; top:1; bottom: 1 }
              backgroundSource: "/images/backdrop-dark-grey.png"
              fillSource: "/images/progressbar-teal-11px.png"
              fillOffset { left: 1; right: 1; top:1; bottom: 1 }

              Tooltip {
                anchors.fill: parent
                text: qsTrId("statusbar_proficiency_progress_tooltip")
                  .arg(TextHelper.formatNumberWithThousandSeparators(statusController?.currentProficiencyProgress))
                  .arg(TextHelper.formatNumberWithThousandSeparators(statusController?.proficiencyProgressNextLevel))
              } //Tooltip

              Image {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: -4
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
                text: "%1%".arg(Math.trunc(parent.fillPercentage * 100))
              }
            } // TibiaProgressBar

            RowLayout {
              spacing: 0

              Item {
                Layout.preferredWidth: statesBar.width < comboPointsAndSereneState.width
                  ? comboPointsAndSereneState.width - statesBar.width
                  : 0
              } //Item

              StatesBar {
                id: statesBar
              } //StatesBar
            } //RowLayout

            RowLayout {
              spacing: 0
              visible: rowLayOutStatusBar.showCombopointsAndIsSerene

              ComboPointsAndSereneState {
                id: comboPointsAndSereneState
                horizontalView: true
              } // ComboPointsAndSereneState

              Item {
                Layout.preferredWidth: comboPointsAndSereneState.width < statesBar.width
                  ? statesBar.width - comboPointsAndSereneState.width
                  : 0
              } //Item
            } //RowLayout

          } // RowLayout
        } //Component

        onLoaded: {
          item.playerStatesList = Qt.binding(function() { return playerStates; });
          item.showCombopointsAndIsSerene = Qt.binding(function() { return showCombopointsAndSerene; });
          item.amountOfCombopoints = Qt.binding(function() { return comboPoints; });
          item.isSerene = Qt.binding(function() { return isSerene; });
          Layout.preferredHeight = item.implicitHeight;
        } //onLoaded
      } //Loader
    } // ColumnLayout
  } // BorderImage

  BorderImage {
    id: bottomBorder
    anchors{left: parent.left; top: background.bottom; right: parent.right;}
    anchors.leftMargin: background.height < TibiaStyle.sidebarButtonHeight ? TibiaStyle.sidebarButtonWidth : 0
    anchors.rightMargin: anchors.leftMargin
    border { left: TibiaStyle.statusBarBackgroundBorderWidth; right: TibiaStyle.statusBarBackgroundBorderWidth;}
    horizontalTileMode: BorderImage.Repeat
    source: "/images/statusbar-top-lower-border.png"
    smooth: false
    visible: isTopAnchored ? true : false
  } // BorderImage
} // Item
