import QtQuick
import QtQuick.Layouts

import qmlcomponents

TooltipBase {
    id: tooltipBase

    signal beforeShowTooltip()

    property string text: ""
    property bool useRichText: false
    property int maxWidth: 0
    property int delayInMs: 500
    property int hideDelayInMs: 0
    property bool autoShow: true
    property bool autoHide: true
    property bool hideOnPositionChange: true

    property var _lastContainedPoint: Qt.point(-1, -1)

    delegate: simpleTextTooltipDelegate

    calculateDelegatePositionCallback: (point) => {
      if (item && point) {
        var newPoint = Qt.point(point.x, point.y);
        newPoint.y = newPoint.y - tooltipBase.item.height;
        newPoint = recalculatePointToFitDelegateIntoWindow(newPoint);
        point = newPoint;
      }
      return point;
    }

    onHoverEnter: () => {
      if (enabled) {
        if (delayInMs == 0) {
          showTooltipInternal();
        } else if (showTooltipTimer.running == false) {
          showTooltipTimer.start();
        } 
      }
      hideTooltipTimer.stop();
    }
    onHoverLeave: startHideTooltip()
    onMouseButtonPressed: startHideTooltip()

    function startHideTooltip() {
      if (hideDelayInMs == 0) {
        hideTooltipInternal();
      } else if (hideTooltipTimer.running == false) {
        hideTooltipTimer.start();
      }
      showTooltipTimer.stop();
    }

    onContainsCheck: (point, contained) => {
      if (_lastContainedPoint != point) {
        tooltipBase._lastContainedPoint = point;
        if (item) { // tooltip visible
          let shouldHideTooltip = false;
          if (contained) {
            if (hideOnPositionChange) {
              // only hide if it would not be shown again immediatelly
              shouldHideTooltip = tooltipBase.delayInMs > 0;
            }
          } else {
            shouldHideTooltip = true;
          }
          if (shouldHideTooltip && autoHide) { 
            hideTooltip();
          }
        } else if (enabled && contained) {
          showTooltipTimer.restart();
        }
      }
    }

    function showTooltipInternal() {
      tooltipBase.beforeShowTooltip();
      if (enabled && autoShow &&
          ((tooltipBase.delegate != simpleTextTooltipDelegate) ||
            (tooltipBase.delegate == simpleTextTooltipDelegate && tooltipBase.text.length > 0))) {
        showTooltip();
      }
    }

    function hideTooltipInternal() {
      if (autoHide) {
        hideTooltip();
      }
    }

    Timer {
      id: showTooltipTimer
      interval: tooltipBase.delayInMs
      running: false
      repeat: false
      onTriggered: showTooltipInternal()
    }


    Timer {
      id: hideTooltipTimer
      interval: tooltipBase.hideDelayInMs
      running: false
      repeat: false
      onTriggered: hideTooltipInternal()
    }

    Component {
      id: simpleTextTooltipDelegate
      Rectangle {
        id: root

        property alias text: tooltipText.text
        property int tooltipMaxWidth: 0
        property bool useRichText: false

        property string _text: tooltipBase.text
        property int _tooltipMaxWidth: tooltipBase.maxWidth
        property bool _useRichText: tooltipBase.useRichText

        on_TextChanged: recalculateContent()
        on_TooltipMaxWidthChanged: recalculateContent()
        on_UseRichTextChanged: recalculateContent()
        Component.onCompleted: recalculateContent()

        function recalculateContent() {
          if (tooltipBase) {
            let window = TooltipHelper.findWindowContentItemForQuickItem(tooltipBase);
            if (window) {
              var maxWidth = parent.width
              if (window) {
                maxWidth = window.width
              }
              tooltipText.width = (root._tooltipMaxWidth > 0 ? Math.min(maxWidth, root._tooltipMaxWidth) : maxWidth) - 2*TibiaStyle.tooltipBorderMargin
              tooltipText.textFormat = root._useRichText ? Text.RichText : Text.AutoText
              tooltipText.text = root._text
            }
          }
        }

        border.width: 1
        border.color: "black"

        color: TibiaStyle.tooltipBackgroundColor
        width: textColumn.width + 2*TibiaStyle.tooltipBorderMargin
        height: textColumn.height + 2*TibiaStyle.tooltipBorderMargin

        Column {
          id: textColumn
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.verticalCenter: parent.verticalCenter
          //Math.min() needed as RichText masses with the contentWith and width masses with the implicitWidth
          width: Math.min(tooltipText.implicitWidth, tooltipText.contentWidth)
          TibiaTextBase {
            id: tooltipText
            font: TibiaStyle.tooltipFont
            color: TibiaStyle.tooltipTextColor
            wrapMode: Text.Wrap
            elide: Text.ElideNone
            textFormat: root.useRichText ? Text.RichText : Text.AutoText
          } //TibiaText
        } //Column
      } //Rectangle (delegate)
    }

}
