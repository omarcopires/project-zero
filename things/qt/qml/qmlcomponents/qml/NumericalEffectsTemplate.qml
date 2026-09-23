import QtQuick
import qmlcomponents



Item {
  id: root
  property var controller: null
  property var outerParent: null
  property int maxLeftPositionOfLastElement: 48
  property int maxVerticalOffset: 20
  property int gapBetweenElements: 2

  property var _effectItems: []
  property int _itemCount: controller != null ? controller.itemCount : 0

  onControllerChanged: {
    if (controller != null) {
      controller.itemsChanged.connect(refreshModel);
    }
  }

  Component {
    id: effectTextComponent
    TibiaCachedOutlineTextBase {
    }
  }

  function confineInOuterParent(parent, itemBoundingRect) {
    if (outerParent != null) {
      var itemRect = outerParent.mapFromItem(parent, itemBoundingRect.x, itemBoundingRect.y, itemBoundingRect.width, itemBoundingRect.height);

      var correctedPoint = Qt.point(Math.min(outerParent.width - itemRect.width, Math.max(0, itemRect.x)),
                                  Math.min(outerParent.height - itemRect.height, Math.max(0, itemRect.y)));
      var newPosition = outerParent.mapToItem(parent, correctedPoint.x, correctedPoint.y);
      return newPosition;
    } else {
      return Qt.point(itemBoundingRect.x, itemBoundingRect.y);
    }
  }

  function refreshModel() {
    var completeWidth = 0;
    var lastItemBoundingRect = null;

    var usedItems = 0;
    for (var i = 0; i < root._itemCount; i++) {
      if (completeWidth < maxLeftPositionOfLastElement) {
        usedItems++;
        var newItem = null;
        if (i < _effectItems.length) {
          newItem = _effectItems[i];
        } else {
          newItem = effectTextComponent.createObject(root);
          _effectItems.push(newItem);
        }
        newItem.text = controller.getTextForIndex(i);
        newItem.color = controller.getColorForIndex(i);
        completeWidth += newItem.width + root.gapBetweenElements;
        // position new item
        // it should be centered around the root if its the first item
        // if its not the first item it should be rightmost to the left item with a small gap
        // if its outside of the parent viewport it should be moved to the border of the viewport
        var newItemBoundingRect = Qt.rect(newItem.x, newItem.y, newItem.width, newItem.height); 
        newItemBoundingRect.y = -1 * parseInt(controller.getEffectPercentForIndex(i) * maxVerticalOffset + 0.5);
        if (lastItemBoundingRect == null) {
          newItemBoundingRect.x = -1 * newItemBoundingRect.width / 2;
        } else {
          newItemBoundingRect.x = lastItemBoundingRect.x + lastItemBoundingRect.width + root.gapBetweenElements;
        }
        lastItemBoundingRect = newItemBoundingRect;
        var confinedPosition = confineInOuterParent(newItem.parent, newItemBoundingRect);
        newItem.x = confinedPosition.x;
        newItem.y = confinedPosition.y;
      }
    }
    var before = _effectItems.length;
    if (usedItems < _effectItems.length) {
      // remove any unused items
      var itemsToRemove = _effectItems.splice(usedItems, _effectItems.length);
      var itemsToRemoveLenght = itemsToRemove.length;
      for(var i = 0; i < itemsToRemove.length; i++) {
        itemsToRemove[i].destroy()
      }
    }
  }
}
