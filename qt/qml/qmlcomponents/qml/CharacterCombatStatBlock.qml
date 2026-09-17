import QtQuick
import QtQuick.Layouts

import qmlcomponents

ColumnLayout {
  id: statBlock

  enum EType {
    From,
    Against,
    For,
    Nothing
  }

  property var statBlockData
  property bool alwaysShowSources: false
  property int type: CharacterCombatStatBlock.EType.From
  property int sourcesMarginLeft: TibiaStyle.marginUnrelated

  Layout.fillWidth: true
  visible: statBlockData != null && statBlockData.visible

  TextMetrics {
    id: textMeasurer
    font: TibiaStyle.defaultTextFont
    renderType: TextEdit.NativeRendering
    text: "* 555.55% "
  }

  RowLayout {
    TibiaText {
      text: statBlock.statBlockData != null ? statBlock.statBlockData.caption : qsTrId("dummy_unknown")
      tooltipText: statBlock.statBlockData != null ? statBlock.statBlockData.tooltip : qsTrId("dummy_unknown")
      tooltipMaxWidth: TibiaStyle.tooltipRestrictedWidth
      Layout.fillWidth: true
    }

    TibiaText {
      text: statBlock.statBlockData != null ? statBlock.statBlockData.total : qsTrId("dummy_unknown")
      tooltipText: statBlock.statBlockData != null ? statBlock.statBlockData.tooltip : qsTrId("dummy_unknown")
      tooltipMaxWidth: TibiaStyle.tooltipRestrictedWidth
      styleType: statBlock.statBlockData == null || statBlock.statBlockData.styleType === undefined ? "Dialog" : statBlock.statBlockData.styleType
    }

    Image {
      source: statBlock.statBlockData == null || statBlock.statBlockData.iconSource === undefined ? "" : statBlock.statBlockData.iconSource

      Tooltip {
        anchors.fill: parent
        text: statBlock.statBlockData != null ? (statBlock.statBlockData.iconTooltip === undefined || statBlock.statBlockData.iconTooltip == "" ? statBlock.statBlockData.caption : statBlock.statBlockData.iconTooltip) : qsTrId("dummy_unknown")
        maxWidth: TibiaStyle.tooltipRestrictedWidth
      }
    }
  } // RowLayout

  Repeater {
    id: sourceRepeater
    model: statBlock.statBlockData != null ? statBlock.statBlockData.sources : []
    property string descriptionTextTemplate: switch (statBlock.type) {
      case CharacterCombatStatBlock.EType.From: return qsTrId("charinfo_statblock_from")
      case CharacterCombatStatBlock.EType.Against: return qsTrId("charinfo_statblock_against")
      case CharacterCombatStatBlock.EType.For: return qsTrId("charinfo_statblock_for")
      case CharacterCombatStatBlock.EType.Nothing: return "%1"
    }

    RowLayout {
      id: statRow
      visible: statBlock.alwaysShowSources || sourceRepeater.count > 1
      required property string name
      required property string value
      required property string tooltip

      TibiaText {
        text: statRow.value
        horizontalAlignment: Text.AlignRight
        Layout.leftMargin: statBlock.sourcesMarginLeft
        Layout.preferredWidth: textMeasurer.width

        Tooltip {
          anchors.fill: parent
          text: statRow.tooltip
          maxWidth: TibiaStyle.tooltipRestrictedWidth
        } // Tooltip
      }

      TibiaText {
        text: sourceRepeater.descriptionTextTemplate.arg(statRow.name)
        Layout.fillWidth: true

        Tooltip {
          anchors.fill: parent
          text: statRow.tooltip
          enabled: text.length > 0
          maxWidth: TibiaStyle.tooltipRestrictedWidth
        } // Tooltip
      } // TibiaText
    } // RowLayout
  } // Repeater
} // ColumnLayout
