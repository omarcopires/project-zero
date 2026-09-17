import QtQuick
import QtQuick.Layouts
import qmlcomponents
import qmlenumvalues


Item {
  property var skillData: null
  property var dialogStyle: StatusBarController.Default
  property var skillText: ""
  implicitWidth: skillColumnLayout.width

  ColumnLayout {

    id: skillColumnLayout
    anchors { left: parent.left; bottom: parent.bottom; top: parent.top; }
    visible: (skillData != null? true : false)
    Layout.fillHeight: true
    spacing: TibiaStyle.marginRelated
    Item {
      id : barItem
      Layout.fillHeight: true
      Layout.preferredWidth: skillMarker.width*2-skillBar.width
      Layout.alignment: Qt.AlignHCenter
      SlimProgressbarRotated {
        id: skillBar
        width: TibiaStyle.progressBarSlimHeight
        progressbarPercent: (skillData != null ? skillData.progressBarValue : 0)
        anchors{bottom: barItem.bottom; top: barItem.top; horizontalCenter: barItem.horizontalCenter;}
        visible: (skillData != null? true : false)
        progressbarColor: (skillBar.visible ? skillData.progressBarColor : "transparent")
        progressbarBackgroundColor: "transparent"

        Image {
          id: skillMarker
          anchors{bottom: parent.bottom; bottomMargin: Math.round(skillBar.height*0.25 - height*0.5); right: parent.right;}
          source: "/images/marker-right.png"
        } // Image

        Image {
          anchors.verticalCenter: parent.verticalCenter
          anchors.right: parent.right
          source: "/images/marker-right.png"
        } // Image

        Image {
          anchors{bottom: parent.bottom; bottomMargin: Math.round(skillBar.height*0.75 - height*0.5); right: parent.right;}
          source: "/images/marker-right.png"
        } // Image

        Tooltip {
          anchors.fill: parent
          text: (skillData != null? skillData.tooltip : "")
        } //Tooltip

      } // SlimProgressbarRotated
    } // Item

    Image {
      id: skillImage
      Layout.alignment: Qt.AlignHCenter
      visible: (skillData != null? true : false)
      source: (skillData != null? skillData.iconSource : "")
      Tooltip {
        anchors.fill: parent
        text: (skillData != null? skillData.iconTooltip : "")
      } //Tooltip
    } // Image

    Item {
      Layout.preferredWidth: 13
      Layout.preferredHeight: 38
      Layout.alignment: Qt.AlignHCenter
      visible: (dialogStyle != StatusBarController.Compact ? true : false)

      TibiaText {
        id: optionalText
        width: 38
        height: 38
        horizontalAlignment: Text.AlignLeft
        anchors{top: parent.top; right: parent.right;}
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
        rotation: 90
      } // TibiaText
    } // Item


  } // ColumnLayout

} // Item
