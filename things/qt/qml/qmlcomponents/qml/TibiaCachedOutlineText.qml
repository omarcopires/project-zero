import QtQuick
import qmlcomponents


TibiaCachedOutlineTextBase {
  id: root
  property int tooltipMaxWidth: 0
  property string tooltipText: ""
  property bool tooltipUseRichText: false

  Loader {
    Component {
      id: loaderComponent
      Tooltip {
        text: root.tooltipText.length == 0 ? root.text : root.tooltipText
        maxWidth: root.tooltipMaxWidth
        useRichText: root.tooltipUseRichText
      } //Tooltip
    } //Component
    anchors.fill: parent
    property bool needTooltip: (root.tooltipText.length > 0 ||
                                (root.truncated && root.text.length > 0))
                               && root.visible
    sourceComponent: needTooltip ? loaderComponent : null
  } //Loader
} //Text
