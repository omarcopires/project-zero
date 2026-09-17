import QtQuick
import QtQuick.Layouts
import qmlcomponents



ListView {
  id: spellList

  signal spellSelected(int spellEnumId)
  property int selectedSpellID: 0

  property int externalSelectedIndex: -1
  property bool patternedBackground: false

  property bool allowDrag: false
  property var parentWhileDragging: spellList
  property bool showOnlyKnownSpells: false //needed to adjust scroll position if count or selected index did not change but model was updated
  property bool smallIcons: false
  property bool showSpellgroup: false


  boundsBehavior: Flickable.StopAtBounds
  interactive: false //prevent flick behavior on touch screens

  onCountChanged: {
    currentIndex = externalSelectedIndex; //select spell if filter options change
    if (count > 0 && currentItem == null) {
      currentIndex = 0;
    }
  } //onCountChanged

  onModelChanged: {
    currentIndex = externalSelectedIndex;
  } //onModelChanged

  onExternalSelectedIndexChanged: {
    currentIndex = externalSelectedIndex;
  } //onExternalSelectedIndexChanged

  onCurrentIndexChanged: {
    Qt.callLater(spellSelectedAndMakeVisible);
  } //onCurrentIndexChangd

  onCurrentItemChanged: {
    // for some reason currentItem changes if the filter changes but currentIndex does not
    Qt.callLater(spellSelectedAndMakeVisible);
  }

  onShowOnlyKnownSpellsChanged: {
    Qt.callLater(spellSelectedAndMakeVisible);
  } //onShowOnlyKnownSpellsChanged

  function spellSelectedAndMakeVisible() {
    spellList.makeCurrentSpellVisible(); //need to scroll manually as it only works automatically if the view has the item loaded ...
    spellList.onSpellSelected();
  }

  function makeCurrentSpellVisible() {
    positionViewAtIndex(currentIndex, ListView.Contain);
  } //function makeCurrentSpellVisible()

  function onSpellSelected() {
    if (currentItem && model != null) {
      spellList.selectedSpellID = currentItem.spellEnumId;
    } else {
      spellList.selectedSpellID = 0;
    }
    spellList.spellSelected(spellList.selectedSpellID);
  } //function onSpellSelected(listIndex)

  //does only work before you start scrolling
  //topMargin: Math.floor(TibiaStyle.marginNarrow * 0.5)
  //bottomMargin: Math.floor(TibiaStyle.marginNarrow * 0.5)
  //breaks the scroll bar handle length as soon as the content is smaller than ScrollView
  //header: Item { height: Math.floor(TibiaStyle.marginNarrow * 0.5) }
  //footer: Item { height: Math.floor(TibiaStyle.marginNarrow * 0.5) }
  //solution: use height and margins within the delegate

  highlightMoveDuration: 0
  highlight: Rectangle {
    color: patternedBackground ? TibiaStyle.comboBoxSelectionColor
                               : TibiaStyle.tableViewSelectionColor
  } //Rectangle

  delegate: MouseArea {
    width: spellList.width
    height: spellInfoLayout.height
          + TibiaStyle.marginNarrow
          + (index == 0 || (index > 0 && index == spellList.count -1) ? Math.floor(TibiaStyle.marginNarrow * 0.5) : 0)

    property int spellEnumId: enumId;
    property string spellIconUrl: smallIcons ? model.iconUrlSmall : model.iconUrl

    onClicked: {
      spellList.currentIndex = index;
      spellList.forceActiveFocus();
      spellList.onSpellSelected();
    } //onClicked

    RowLayout {
      id: spellInfoLayout
      anchors {left: parent.left; right:parent.right; top: parent.top}
      anchors.margins: TibiaStyle.marginNarrow
      anchors.topMargin: index == 0 ? TibiaStyle.marginNarrow
                                    : Math.floor(TibiaStyle.marginNarrow * 0.5)
      spacing: TibiaStyle.marginNarrow

      Image {
        source: spellIconUrl

        TibiaDisabledOverlay {
          anchors.fill: parent
          visible: !castPossible
        } //TibiaDisabledOverlay
        smooth: false
      } // Image

      ColumnLayout {
        spacing: 0
        Layout.fillWidth: true

        TibiaText {
          Layout.fillWidth: true
          text: qsTrId(name)
          color: index == spellList.currentIndex ? TibiaStyle.textFieldSelectionTextColor
                                                 : TibiaStyle.textFieldTextColor
        } // TibiaText
        Loader {
          sourceComponent: smallIcons ? undefined : formulaComponent
          Component {
            id: formulaComponent
            TibiaText {
              Layout.fillWidth: true
              text: formulaRaw
              color: index == spellList.currentIndex ? TibiaStyle.textFieldSelectionTextColor
                                                    : TibiaStyle.textFieldTextColor
            } // TibiaText
          }
        }
      } //ColumnLayout
      Loader {
        Component {
          id: spellGroupColumnComponent
          RowLayout {
            Image {
              source: groupPrimaryIconUrl
            }
            TibiaText {
              Layout.preferredWidth: 80
              text: `${qsTrId('level')}: ${minimumCasterLevel}`
            }
          }

        }
        sourceComponent: showSpellgroup ? spellGroupColumnComponent : undefined
      }
    } //RowLayout

    drag.target: spellList.allowDrag ? spellDrag : undefined
    drag.threshold: TibiaStyle.dragThreshold
    drag.onActiveChanged: {
      spellList.currentIndex = index;
      spellList.onSpellSelected();
      spellList.dragActive = drag.active;
    } //drag.onActiveChanged

    onPressed: (mouse) => {
      var mousePos = mapToItem(spellList, mouse.x, mouse.y);
      spellDrag.x = mousePos.x - TibiaStyle.spellListIconSize * 0.5;
      spellDrag.y = mousePos.y - TibiaStyle.spellListIconSize * 0.5;
    } //onPressed

    onReleased: {
      if (drag.target != undefined && drag.active) {
        drag.target.Drag.drop();
      }
    } //onReleased
  } // delegate: MouseArea

  Keys.onUpPressed: {
    spellList.currentIndex = Math.max(0, spellList.currentIndex-1);
    spellList.onSpellSelected();
  } //Keys.onUpPressed

  Keys.onDownPressed: {
    spellList.currentIndex = Math.min(spellList.count-1, spellList.currentIndex+1);
    spellList.onSpellSelected();
  } //Keys.onDownPressed

  Keys.onLeftPressed: {}
  Keys.onRightPressed: {}

  property bool dragActive: false
  property int mousePosX: 0
  property int mousePosY: 0

  Image {
    id: spellDrag
    objectName: TibiaStyle.dragSourceSpellIcon
    property int enumId: currentItem != null ? currentItem.spellEnumId : 0
    source: currentItem != null ? currentItem.spellIconUrl : ""
    visible: Drag.active
    smooth: false

    Drag.keys: [ TibiaStyle.dragKeySpell ]
    Drag.active: spellList.dragActive
    Drag.source: this

    Drag.hotSpot.x: Math.ceil(width * 0.5)
    Drag.hotSpot.y: Math.ceil(height * 0.5)

    state: Drag.active ? "DRAGGING" : ""
    transitions: [
      Transition {
        to: "DRAGGING"
          PropertyAction { target: spellDrag; property: "parent"; value: spellList.parentWhileDragging }
      }, //Transition
      Transition {
        from: "DRAGGING"
        SequentialAnimation {
          PropertyAction { target: spellDrag; property: "parent"; value: spellList }
          ParallelAnimation {
            PropertyAction { target: spellDrag; property: "x"; value: 0 }
            PropertyAction { target: spellDrag; property: "y"; value: 0 }
          } //ParallelAnimation
        } //SequentialAnimation
      } //Transition
    ] //transitions

  } // Image
} //ListView

