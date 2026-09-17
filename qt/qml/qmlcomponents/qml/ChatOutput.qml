import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qmlcomponents


ListView  {
  id: root

  property QtObject chatController: null
  property var chatChannelModel: null

  readonly property int chatWidth: width - leftMargin - rightMargin

  signal requestDeselectChatInput()

  clip: true

  verticalLayoutDirection: ListView.BottomToTop

  cacheBuffer: height + 200
  model: chatChannelModel

  interactive: false //prevent flick behavior on touch screens
  boundsBehavior: Flickable.StopAtBounds

  onChatChannelModelChanged: {
    if(chatChannelModel != null) {
      chatChannelModel.setChatWidth(root.chatWidth);
      chatChannelModel.setChatFont(TibiaStyle.defaultTextFont);
      chatChannelModel.setAutoScrollToEnd(true);
    }
    model = chatChannelModel;
    scrollViewToEnd();
  } //onModleChanged


  onChatWidthChanged: {
    if(chatChannelModel != null) {
      chatChannelModel.setChatWidth(root.chatWidth);
    }
    if(lastAtYEnd) {
      scrollViewToEnd();
    }
    refreshModelTimer.restart();
  } //onChatWidthChanged


  Timer {
    id: refreshModelTimer
    interval: 1
    onTriggered: {
      root.model = null;
      root.model = chatChannelModel;
      scrollViewToEnd();
    } //onTriggered
  } //Timer

  /////////////////////////////////////////////////////////////////////////
  //AUTO SCROLL TO END
  pixelAligned : true
  highlightFollowsCurrentItem: false

  Component.onCompleted: {
    positionViewAtEnd();
  } //Component.onCompleted

  property bool lastAtYEnd: true
  onAtYEndChanged: {
    if(chatChannelModel != null) {
      chatChannelModel.setAutoScrollToEnd(atYEnd);
    }
    lastAtYEnd = atYEnd;
  } //onAtYEndChanged

  function scrollViewToEnd() {
    root.currentIndex = root.count - 1; // last index
    root.positionViewAtBeginning();
    Qt.callLater(root.positionViewAtBeginning)
  } //function scrollToEnd()

  onHeightChanged: {
    if(lastAtYEnd) {
      scrollViewToEnd();
    }
  } //onHeightChanged

  //AUTO SCROLL TO END
  /////////////////////////////////////////////////////////////////////////

  delegate: TibiaTextEdit {
    id: chatEntry
    width: root.chatWidth

    property int selectionStartIndexFromModel: selectionStartIndex
    property int selectionEndIndexFromModel: selectionEndIndex
    property int entryIndex: index
    property var tutorialMarkerRenderInfo: tutorialMarker
    property rect tutorialMakerRect: Qt.rect(0,0,0,0)

    text: chatText
    height: sizeHint.height
    textFormat: TextEdit.RichText
    wrapMode: TextEdit.Wrap

    activeFocusOnPress: false
    enabled: false
    readOnly: true
    selectByMouse: false
    selectByKeyboard: false
    persistentSelection: true

    Component.onCompleted: {
      updateSelectionIfChanged();
    } //Component.onCompleted

    onSelectionStartIndexFromModelChanged: {
      updateSelectionIfChanged();
    } //onSelectionStartIndexFromModelChanged

    onSelectionEndIndexFromModelChanged: {
      updateSelectionIfChanged();
    } //onSelectionEndIndexFromModelChanged

    function updateSelectionIfChanged() {
      if((selectionStart != selectionStartIndex) || (selectionEnd != selectionEndIndex)) {
        select(selectionStartIndex, selectionEndIndex);
      }

    } //function updateSelectionIfChanged()

    function ensureVisible() {
      var cursorRect = mapToItem(root, cursorRectangle.x, cursorRectangle.y, cursorRectangle.width , cursorRectangle.height);
      cursorRect.y = cursorRect.y + root.contentY; //transvare to visible space

      if (cursorRect.y >= root.contentY + root.height - cursorRect.height - textMargin) {
        // moving down
        root.contentY = cursorRect.y - root.height +  cursorRect.height + textMargin
      } else if (cursorRect.y < root.contentY) {
        // moving up
        root.contentY = cursorRect.y - textMargin
      }
    } //function ensureVisible

    onTutorialMarkerRenderInfoChanged: {
      tutorialMarkerLoader.sourceComponent = tutorialMarkerRenderInfo != undefined ? tutorialMarkerComponent : null;
      updateTutorialMakerRect();
    } //onTutorialMarkerRenderInfoChanged

    onTextChanged: updateTutorialMakerRect()
    onWidthChanged: updateTutorialMakerRect()

    function updateTutorialMakerRect() {
      if(tutorialMarkerRenderInfo != undefined && chatEntry.length > 0) {
        var left = chatEntry.width
        var right = 0;
        var top = chatEntry.height;
        var bottom = 0;
        for(var i=0; i < tutorialMarkerRenderInfo.length+1; ++i) {
          var rect = chatEntry.positionToRectangle(tutorialMarkerRenderInfo.startIndex + i);
          left = Math.min(left, rect.left);
          right = Math.max(right, rect.right);
          top = Math.min(top, rect.top);
          bottom = Math.max(bottom, rect.bottom);
        }
        tutorialMakerRect = Qt.rect(left, top, right-left, bottom-top);
      } else {
        tutorialMakerRect = Qt.rect(0,0,0,0)
      }
    } //function updateTutorialMakerRect()

    Component {
      id: tutorialMarkerComponent
      TibiaTutorialMarker {
      } //TibiaTutorialMarker
    } //Component

    Loader {
      id: tutorialMarkerLoader
      x: tutorialMakerRect.x
      y: tutorialMakerRect.y
      width: tutorialMakerRect.width
      height: tutorialMakerRect.height
      onLoaded: {
        item.markerID = Qt.binding(function() { return tutorialMarkerRenderInfo != null ? tutorialMarkerRenderInfo.tutorialMarkerID : 0});
      } //onLoaded
      z: 999
    } //Loader
  } //delegate: TextEdit

  MouseArea{
    id: chatMouseAreaOverlay
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    //disabled if no controller or model avoilable
    //and disabled if there are no chat entrys in the list so any call to find the entry at mouse position would return null
    enabled: (chatController != null) && (chatChannelModel != null) && (root.count  > 0)

    onClicked: (mouse) => {
      var itemAtPosition = getItemAtMousePosition(mouse);
      if (itemAtPosition != null) {
        //handle clicks like context menu
        chatChannelModel.onChannelClicked(itemAtPosition.entryIndex, mouse.button, mouse.modifiers);

        //click link with left mouse button
        if(mouse.button == Qt.LeftButton) {
          var mappedCoordinates = mapToItem(itemAtPosition, mouse.x, mouse.y);
          var link = itemAtPosition.linkAt(mappedCoordinates.x, mappedCoordinates.y);
          if(chatController && link !="") {
            chatController.sendKeyword(link);
          }
        }
      }
    } //onClicked

    onDoubleClicked: (mouse) => {
      if (mouse.button == Qt.LeftButton) {
        selectWord(mouse);
        root.requestDeselectChatInput();
      }
    } //onDoubleClicked

    onPressed: (mouse) => {
      if (mouse.button == Qt.LeftButton) {
        startSelection(mouse);
        root.requestDeselectChatInput();
      }
    } //onPressed

    onPositionChanged: (mouse) => {
      if (mouse.buttons == Qt.LeftButton) {
        selectText(mouse);
        root.requestDeselectChatInput();
      }
    } //onPositionChanged

    onWheel: (wheel) => {
      if (wheel.buttons == Qt.LeftButton) {
        selectText(wheel);
        root.requestDeselectChatInput();
      }
      wheel.accepted = false;
    } //onWheel

    function selectWord(mouse) {
      var itemAtMousePosition = getItemAtMousePosition(mouse);
      if (itemAtMousePosition != null) {
        var indexAtMousePosition = getIndexAtMousePosition(mouse);
        var newCursorPosition = getPositionAtItem(itemAtMousePosition, mouse);

        itemAtMousePosition.cursorPosition = newCursorPosition;
        itemAtMousePosition.selectWord();

        chatChannelModel.selectTextPassage(indexAtMousePosition,itemAtMousePosition.selectionStart, itemAtMousePosition.selectionEnd);
      }
    } //function selectWord(mouse)

    function startSelection(mouse) {
      var itemAtMousePosition = getItemAtMousePosition(mouse);
      if (itemAtMousePosition !=  null) {
        var indexAtMousePosition = getIndexAtMousePosition(mouse);
        var newCursorPosition = getPositionAtItem(itemAtMousePosition, mouse);

        chatChannelModel.startNewSelection(indexAtMousePosition, newCursorPosition);
      }
    } //function startSelection(mouse)

    function selectText(mouse) {
      if(!pressed) {
        return;
      }

      //clamp mouse.y to visible area
      //have a little offset to not select text that is barly already visible
      var mousePos = {x:mouse.x, y:mouse.y};
      mousePos.y = Math.max(mousePos.y, 5);
      mousePos.y = Math.min(mousePos.y, chatMouseAreaOverlay.height-5);

      //get index and actual item at the mouse position
      var itemAtMousePosition = getItemAtMousePosition(mousePos);
      if (itemAtMousePosition != null) {
        var indexAtMousePosition = getIndexAtMousePosition(mousePos);
        var newCursorPosition = getPositionAtItem(itemAtMousePosition, mousePos);

        chatChannelModel.updateSelection(indexAtMousePosition, newCursorPosition);
      }
    } //function selectText(mouse)

    function getItemAtMousePosition(mouse) {
      var mappedCoordinate = mapToItem(root.contentItem, mouse.x, mouse.y)
      var itemAtPosition = root.contentItem.childAt(mappedCoordinate.x, mappedCoordinate.y);
      if (itemAtPosition && itemAtPosition.positionAt) {
        // The item may in theory not be a TextEdit control, which doesn't have a positionAt function.
        // Make sure the function exist, otherwise pretend no item was hit
        return itemAtPosition;
      } else if (root.count > 0) {
        // Fall back to first item in list if no item is found at coordinate
        return root.itemAt(0, 0);
      } else {
        return null;
      }
    } //function getItemAtMousePosition(mouse)

    function getIndexAtMousePosition(mouse) {
      var itemAtPosition = getItemAtMousePosition(mouse);
      if (itemAtPosition != null) {
        return itemAtPosition.entryIndex;
      } else {
        return -1;
      }
    } //function getIndexAtMousePosition(mouse)

    function getPositionAtItem(item, mouse) {
      var mappedCoordinates = mapToItem(item, mouse.x, mouse.y);
      mappedCoordinates.y = Math.max(0, mappedCoordinates.y); //map inside the content area

      return item.positionAt(mappedCoordinates.x, mappedCoordinates.y);
    } //function getPositionAtItem(item, mouse)

  } //MouseArea
} //ListView
