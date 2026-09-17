import QtQuick
import QtQuick.Layouts
import qmlcomponents
import qmlenumvalues



Item {
  property var skillData: null
  property var dialogStyle: StatusBarController.Default
  property var skillText: ""
  implicitHeight: skillRowLayout.height

  RowLayout {
    id: skillRowLayout
    visible: skillData != null ? true : false
    anchors { left: parent.left; right: parent.right; top: parent.top; }

    TibiaText {
      id: optionalText
      Layout.preferredWidth: 38
      Layout.preferredHeight: 13
      horizontalAlignment: Text.AlignRight
      Layout.alignment: Qt.AlignVCenter
      visible: (dialogStyle != StatusBarController.Compact ? true : false)
      elide: Text.ElideRight
      text: skillText
      styleType: {
        if (skillData == null) {
          return "Dialog";
        } else if (skillData.valueStringColor == SkillsWidgetEntryData.MODIFIER_POSITIVE) {
          return "ModifierPositive";
        } else if (skillData.valueStringColor == SkillsWidgetEntryData.MODIFIER_NEGATIVE) {
          return "ModifierNegative";
        } else if (skillData.valueStringColor == SkillsWidgetEntryData.MODIFIER_ZERO) {
          return "ModifierZero";
        } else {
          return "Dialog";
        }
      } //styleType
    } // TibiaText

    Image {
      id: skillImage
      Layout.alignment: Qt.AlignVCenter
      visible: (skillData != null? true : false)
      source: (skillData != null? skillData.iconSource : "")
      Tooltip {
        anchors.fill: parent
        text: (skillData != null? skillData.iconTooltip : "")
      } //Tooltip
      smooth: false
    } // Image

    Item {
      id : barItem
      Layout.fillWidth: true
      Layout.preferredHeight: skillMarker.height*2 - skillBar.height
      SlimProgressbar {
        id: skillBar
        height: TibiaStyle.progressBarSlimHeight
        progressbarPercent: (skillData != null ? skillData.progressBarValue : 0)
        anchors{left: barItem.left; right: barItem.right; verticalCenter: barItem.verticalCenter;}
        visible: (skillData != null? true : false)
        progressbarColor: (skillBar.visible ? skillData.progressBarColor : "transparent")
        progressbarBackgroundColor: "transparent"

        Image {
          id: skillMarker
          anchors{left: parent.left; leftMargin: Math.round(skillBar.width*0.25 - width*0.5); top: skillBar.top;}
          source: "/images/marker-top.png"
          smooth: false
        } // Image

        Image {
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.top: skillBar.top
          source: "/images/marker-top.png"
          smooth: false
        } // Image

        Image {
          anchors{left: parent.left; leftMargin: Math.round(skillBar.width*0.75 - width*0.5); top: skillBar.top;}
          source: "/images/marker-top.png"
          smooth: false
        } // Image

        Tooltip {
          anchors.fill: parent
          text: (skillData != null? skillData.tooltip : "")
        } //Tooltip

      } // SlimProgressbar
    } // Item
  } // RowLayout
} // Item
