import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts



ScrollBar {
  id: root
  readonly property bool cornerVisible: vertical && horizontal && verticalScrollbar.visible && horizontalScrollbar.visible
  readonly property int minimumHandleLength: 14 // 6+6 for handle-top/bottom +2 (14 found in legacy code)
  readonly property int mimimumLenght: minimumHandleLength + (2 * TibiaStyle.scrollBarWidth) + (cornerVisible ? TibiaStyle.scrollBarWidth : 0)

  minimumSize: mimimumLenght / (horizontal ? control.availableWidth : control.availableHeight)
  stepSize: control.contentItem
    ? (20 / (horizontal ? control.contentItem.contentWidth : control.contentItem.contentHeight)) //20pixel target scroll steps
    : 0.1

  visible: {
    // QML StyledScrollBar: Binding loop detected for property "implicitWidth"
    // no propert solution found
    switch (policy) {
      case ScrollBar.AsNeeded: return size < 1.0;
      case ScrollBar.AlwaysOff: return false;
      case ScrollBar.AlwaysOn: return true;
    }
  } //visible

  x: horizontal
    ? control.leftPadding
    : (control.mirrored ? 0 : control.width - width)
  y: horizontal
    ? control.height - height
    : control.topPadding

  width: horizontal
   ? control.availableWidth + control.needRightPadding
   : TibiaStyle.scrollBarWidth
  height: horizontal
   ? TibiaStyle.scrollBarWidth
   : control.availableHeight + control.needBottomPadding

  leftPadding: horizontal ? TibiaStyle.scrollBarWidth : 0
  topPadding: horizontal ? 0 : TibiaStyle.scrollBarWidth
  rightPadding: horizontal
    ? TibiaStyle.scrollBarWidth + (cornerVisible ? TibiaStyle.scrollBarWidth : 0)
    : 0
  bottomPadding: horizontal
    ? 0
    : TibiaStyle.scrollBarWidth + (cornerVisible ? TibiaStyle.scrollBarWidth : 0)

  contentItem: Item {
    BorderImage {
      //contentItem width/height is sub pixel exact, this sometime leads to the handle shrinking and expanding
      width: control.contentItem.atXEnd ? Math.round(parent.width) : Math.floor(parent.width)
      height: control.contentItem.atYEnd ? Math.round(parent.height) : Math.floor(parent.height)

      source: horizontal
        ? "/images/skin/classic/scrollbar-handle-horizontal.png"
        : "/images/skin/classic/scrollbar-handle-vertical.png"
      readonly property int endCapSize: 6

      border.left: horizontal ? endCapSize : 0
      border.right: horizontal ? endCapSize : 0
      border.top: horizontal ? 0 : endCapSize
      border.bottom: horizontal ? 0 : endCapSize
      smooth: false
    } //BorderImage
  } // Item

  __decreaseVisual.indicator: TibiaButton {
    width: TibiaStyle.scrollBarWidth
    height: TibiaStyle.scrollBarWidth
    sourceDown: horizontal
      ? "/images/skin/classic/scrollbar-buttonleft-down.png"
      : "/images/skin/classic/scrollbar-buttonup-down.png"
    sourceUp: horizontal
      ? "/images/skin/classic/scrollbar-buttonleft-up.png"
      : "/images/skin/classic/scrollbar-buttonup-up.png"
    autoRepeat: true
    onClicked: decrease()
  } //TibiaButton

  __increaseVisual.indicator: TibiaButton {
    width: TibiaStyle.scrollBarWidth
    height: TibiaStyle.scrollBarWidth
    x: horizontal ? root.width - width : 0
    y: !horizontal ? root.height - height : 0
    sourceDown: horizontal
      ? "/images/skin/classic/scrollbar-buttonright-down.png"
      : "/images/skin/classic/scrollbar-buttondown-down.png"
    sourceUp: horizontal
      ? "/images/skin/classic/scrollbar-buttonright-up.png"
      : "/images/skin/classic/scrollbar-buttondown-up.png"
    autoRepeat: true
    onClicked: increase()
  } //TibiaButton

  background: GridLayout {
    columnSpacing: 0
    rowSpacing: 0

    columns: horizontal ? -1 : 1
    rows: horizontal ? 1 : -1

    TibiaTiledImage {
      id: slideArea
      Layout.fillHeight: true
      Layout.fillWidth: true
      source: horizontal
        ? "/images/skin/classic/scrollbar-texture-horizontal.png"
        : "/images/skin/classic/scrollbar-texture-vertical.png"
    } //TibiaTiledImage

    Optimized1PixelBorderImage {
      id: cornerFiller
      Layout.preferredWidth: TibiaStyle.scrollBarWidth
      Layout.preferredHeight: TibiaStyle.scrollBarWidth
      visible: cornerVisible

      borderimagesource: "/images/skin/classic/button-grey-up.png"
    } //Optimized1PixelBorderImage
  } //background: GridLayout
}
