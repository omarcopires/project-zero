import QtQuick
import QtQuick.Layouts

import qmlcomponents

Item {
    id: root
    signal hoverEnter()
    signal hoverLeave()
    signal mouseButtonPressed()
    signal containsCheck(var point, bool contained)

    property Component delegate: null
    property var calculateDelegatePositionCallback: null
    property alias item: delegateLoader.item
    property point lastHoverPosition: Qt.point(NaN, NaN)
    property bool enabled: true
    property bool mouseContained: false

    Connections {
      id: tooltipHelperConnections
      property bool lastContained: false
      target: null

      function onHoverRefresh() {
        if (target) {
          mouseContained = target.contained(root) && TooltipHelper.inWindow();
          if (!mouseContained) {
            target.unregister();
            root.hoverLeave();
          } else {
            lastHoverPosition = target.hoverPosition(root);
            root.containsCheck(lastHoverPosition, mouseContained);
            root.callCaculatePositionCallbackCaller(lastHoverPosition, mouseContained);
          }
        }
      }

      function onUnregistered() {
        if (mouseContained) {
          root.hoverLeave();
        }
        target = null;
      }

      function onMouseButtonPressed() {
        root.mouseButtonPressed();
      }
    }

    function callCaculatePositionCallbackCaller(point, contained) {
      if (delegateLoader.item && root.calculateDelegatePositionCallback) {
        var calculatedPoint = root.calculateDelegatePositionCallback(point, contained);
        let window = TooltipHelper.findWindowContentItemForQuickItem(delegateLoader);
        let windowPosition = root.mapToItem(window, calculatedPoint);
        if (delegateLoader.x != windowPosition.x || delegateLoader.y != windowPosition.y) {
          delegateLoader.x = windowPosition.x;
          delegateLoader.y = windowPosition.y;
        }
      }
    }

    function showTooltip() {
      let window = TooltipHelper.findWindowContentItemForQuickItem(delegateLoader);
      if (!window) {
        return;
      }
      if (item == null) {
        delegateLoader.sourceComponent = delegate;
        delegateLoader.parent = window;
      }
      callCaculatePositionCallbackCaller(root.lastHoverPosition, true);
    }

    function hideTooltip() {
      if (item != null) {
        delegateLoader.sourceComponent = undefined;
      }
    }

    function recalculatePointToFitDelegateIntoWindow(point) {
      let window = TooltipHelper.findWindowContentItemForQuickItem(delegateLoader);
      if (!window) {
        return point;
      }

      let windowPosition = root.mapToItem(window, point);
      if (delegateLoader.item) {
        let delegateItem = delegateLoader.item;

        var newX = windowPosition.x;
        var newY = windowPosition.y;

        newX = Math.max(0, Math.min(newX, window.width - delegateItem.width));
        newY = Math.max(0, Math.min(newY, window.height - delegateItem.height));

        windowPosition = Qt.point(newX, newY);
      }
      return root.mapFromItem(window, windowPosition);
    }

    onEnabledChanged: {
      if (root.enabled == false) {
        hideTooltip();
      }
    }
    
    Loader {
      id: delegateLoader
    }

    MouseArea {
      id: mouseRoot
      anchors.fill: parent
      hoverEnabled: root.enabled
      acceptedButtons: Qt.NoButton 
      preventStealing: true

      onEntered:() => {
        mouseContained = true;
        root.hoverEnter();
        var tooltipEventWatcher = TooltipHelper.registerTooltip(root);
        tooltipHelperConnections.target = tooltipEventWatcher;
        // manually call hover refresh for getting intial contain state
        tooltipHelperConnections.target.hoverRefresh();
      }
    }
  }
