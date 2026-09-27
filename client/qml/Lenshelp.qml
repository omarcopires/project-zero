import QtQuick

/*
 * Compatibility placeholder for the unavailable native Lenshelp controller.
 * It preserves the QML property contract but does not show the lenshelp panel.
 */
Item {
  property rect triggerRect: Qt.rect(x, y, width, height)
  property string caption: ""
  property string content: ""

  visible: false
  enabled: false
}
