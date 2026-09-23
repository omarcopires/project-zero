import QtQuick

Item {
  id: root
  property bool horizontal: false

  Component {
    id: verticalHandle
    BorderImage {
      source: "/images/skin/classic/scrollbar-handle-vertical.png"
      border.top: 6
      border.bottom: 6
      smooth: false
    }
  }  // Component

  Component {
    id: horizontalHandle
    BorderImage {
      source: "/images/skin/classic/scrollbar-handle-horizontal.png"
      border.left: 6
      border.right: 6
      smooth: false
    }
  }  // Component

  Loader {
    sourceComponent: root.horizontal ? horizontalHandle : verticalHandle
    height: root.horizontal ? 12 : parent.height
    width: root.horizontal ? parent.width : 12
  } //Loader
} //Item
