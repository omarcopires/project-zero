import QtQml
import QtQuick
import QtQuick.Layouts

import qmlcomponents
import qmlenumvalues


Loader {
  id: skillsContent
  property var skillModelData: null
  property var beforeTooltipFunction: function() {}
  property var openStoreXpBoostFunction: function() {}

  visible: skillModelData != null && skillModelData.entryVisible

  sourceComponent: {
    if (skillModelData != null && skillModelData.entryVisible) {
      if (skillModelData.separatorType == SkillsWidgetEntryData.NONE) {
        return textComponent;
      } else if (skillModelData.separatorType == SkillsWidgetEntryData.CAPTION) {
        return captionComponent;
      } else if (skillModelData.separatorType == SkillsWidgetEntryData.SEPARATOR) {
        return separatorComponent;
      } else if (skillModelData.separatorType == SkillsWidgetEntryData.XP_BOOST_BUTTON) {
        return xpButtonSeparatorComponent;
      }
    }

    return null;
  }

  onLoaded: {
    item.modelData = Qt.binding(function() { return skillsContent.skillModelData; });
  }

  Component {
    id: progressBarComponent
    RowLayout {
      id: skillRowLayout
      property var modelData: null
      spacing: TibiaStyle.marginRelated

      Image {
        id: skillImage
        clip: true
        source: (modelData != null ? modelData.iconSource : "")
        visible: (skillImage.source == "" ? false : true)
      } // Image

      SlimProgressbar {
        Layout.preferredHeight: TibiaStyle.progressBarSlimHeight
        Layout.fillWidth: true

        progressbarColor: modelData != null ? modelData.progressBarColor : "white"
        progressbarPercent: modelData != null ? modelData.progressBarValue : 0
        progressbarBackgroundColor: "transparent"
      } //SlimProgressbar
    } // RowLayout
  } // Component

  Component {
    id: textComponent

    Item {
      property var modelData: null

      Layout.fillWidth: true
      Layout.preferredHeight: implicitHeight
      implicitHeight: skillsRowContent.height

      ColumnLayout {
        id: skillsRowContent
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 0

        Item {
          Layout.fillWidth: true
          implicitHeight: lineLabel.height

          TibiaText {
            id: lineLabel
            text: modelData != null ? modelData.caption : "" // can be a multi-string for eliding
            anchors { left: parent.left; right: valueString.left }
            styleType: "Dialog"

            Component.onCompleted: {
              blinkAnimation.blink = Qt.binding(function() { return modelData != null ? modelData.changeHighlight : false; });
            }

            ColorAnimation on color {
              id: blinkAnimation
              to: TibiaStyle.textColors["Dialog"]
              from: TibiaStyle.white2
              duration: 1500
              loops: 5
              running: false

              property bool blink: false
              onBlinkChanged: {
                if (blink) {
                  restart();
                }
              }
            } // ColorAnimation
          } //TibiaText

          TibiaText {
            id: valueString
            text: modelData != null ? modelData.valueString : ""
            anchors.right: parent.right
            styleType: {
              if (modelData == null) {
                return "Dialog";
              } else if (modelData.valueStringColor == SkillsWidgetEntryData.MODIFIER_POSITIVE) {
                return "ModifierPositive";
              } else if (modelData.valueStringColor == SkillsWidgetEntryData.MODIFIER_NEGATIVE) {
                return "ModifierNegative";
              } else if (modelData.valueStringColor == SkillsWidgetEntryData.MODIFIER_ZERO) {
                return "ModifierZero";
              } else {
                return "Dialog";
              }
            } //styleType
          } //TibiaText
        } // Item

        Loader {
          Layout.fillWidth: true
          Layout.bottomMargin: 2
          sourceComponent: modelData != null && modelData.progressBarVisible ? progressBarComponent : null
          visible: sourceComponent != null

          onLoaded: {
            item.modelData = Qt.binding(function() { return modelData; });
          }
        } // Loader
      } // ColumnLayout

      Tooltip {
        text: modelData != null ? modelData.tooltip : ""
        anchors.fill: skillsRowContent
        onBeforeShowTooltip: skillsContent.beforeTooltipFunction()
        maxWidth: TibiaStyle.tooltipRestrictedWidth
      } //Tooltip
    } // Item
  } // Component

  Component {
    id: captionComponent

    TibiaText {
      id: caption
      property var modelData: null
      text: modelData != null ? modelData.caption : "" // can be a multi-string for eliding
      width: skillsContent.width
      styleType: "Dialog"

      Tooltip {
        text: modelData != null ? modelData.tooltip : ""
        anchors.fill: parent
        onBeforeShowTooltip: skillsContent.beforeTooltipFunction()
      } //Tooltip
    } //TibiaText
  } // Component

  Component {
    id: separatorComponent

    Item {
      property var modelData: null
      implicitHeight: 10
      implicitWidth: skillsContent.width

      TibiaHorizontalSeparator {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
      } //TibiaHorizontalSeparator
    } //Item
  } //Component

  Component {
    id: xpButtonSeparatorComponent

    Item {
      id: xpButtonSeparator
      property var modelData: null
      implicitHeight: storeXpBoostButton.visible ? 16 : 10
      implicitWidth: skillsContent.width

      TibiaHorizontalSeparator {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
      }

      TibiaIconButton {
        id: storeXpBoostButton
        visible: modelData != null ? modelData.showButton : false
        anchors.centerIn: parent
        sourceUp: "/images/button-store-storexp-up.png"
        sourceDown: "/images/button-store-storexp-down.png"
        tooltipText: qsTrId("store_xp_boost_tooltip")

        onClicked: skillsContent.openStoreXpBoostFunction()
      } // TibiaIconButton
    } // Item
  } // Component

}
