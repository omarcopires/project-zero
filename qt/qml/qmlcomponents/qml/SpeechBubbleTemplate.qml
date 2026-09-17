import QtQuick
import QtQuick.Layouts

TibiaText {
  id: root
  property var controller: null
  text: controller != null ? controller.text : "";
  color: controller != null ? controller.textColor : "#ffffff";
  styleColor: controller != null ? controller.styleColor : "#000000";
  style: Text.Outline
  textFormat: controller != null && controller.isHtmlText ? Text.RichText : Text.PlainText
  property bool showBoundingRect: controller != null ? controller.showBoundingRect : false;
  visible: controller != null ? controller.isVisible : false;
  property var textPosition: controller != null ? controller.position : Qt.point(0,0);
  property int maximumWidth: controller != null ? controller.maximumWidth : ((TibiaStyle.mapWindowHeightInFields -2) * TibiaStyle.mapWindowPixelPerField)

  width: Math.min(implicitWidth, maximumWidth)

  wrapMode: Text.Wrap
  elide: Text.ElideNone
  horizontalAlignment: Text.AlignHCenter

  onTextPositionChanged: {
    if (x != textPosition.x) {
      x = textPosition.x;
    }
    if (y != textPosition.y) {
      y = textPosition.y;
    }
  } //onTextPositionChanged

  function setContentSizeInController() {
    if (controller != null) {
      controller.calculatedSize = Qt.size(width, height);
    }
  } //unction setContentSizeInController

  onWidthChanged: {
    setContentSizeInController();
  } //onWidthChanged

  onHeightChanged: {
    setContentSizeInController();
  } //onHeightChanged

  Component {
    id: debugBoundingRectComponent
    Rectangle {
      anchors.fill: parent;
      border.width: 1
      color: "transparent"
    }
  }

  // for debug purposes to see the bounding rect
  // load only on demand to save processing time
  Loader {
    id: debugBoundingRect
    sourceComponent: showBoundingRect ? debugBoundingRectComponent : null
    anchors.fill: parent
    onLoaded: {
      item.border.color = Qt.binding(function() { return talkbox.color })
    }
  } //Loader
} //RowLayout
