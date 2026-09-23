import QtQuick
import QtQuick.Layouts
import qmlcomponents



ListView {
  id: passiveAbilityList

  signal passiveAbilitySelected(int passiveAbilityEnumId)

  property int externalSelectedIndex: -1
  property bool patternedBackground: false

  property bool allowDrag: false
  //property var parentWhileDragging: passiveAbilityList

  boundsBehavior: Flickable.StopAtBounds
  interactive: false //prevent flick behavior on touch screens

  onCountChanged: {
    currentIndex = externalSelectedIndex; //select passive ability if filter options change
  } //onCountChanged

  onModelChanged: {
    currentIndex = externalSelectedIndex;
  } //onModelChanged

  onExternalSelectedIndexChanged: {
    currentIndex = externalSelectedIndex;
  } //onExternalSelectedIndexChanged

  onCurrentIndexChanged: {
    makeCurrentPassiveAbilityVisible(); //need to scroll manually as it only works automatically if the view has the item loaded ...
  } //onCurrentIndexChangd

  function makeCurrentPassiveAbilityVisible() {
    positionViewAtIndex(currentIndex, ListView.Contain);
  } //function makeCurrentPassiveAbilityVisible()

  function selectPassiveAbility() {
    if (currentItem && model != null) {
      passiveAbilityList.passiveAbilitySelected(currentItem.passiveAbilityEnumId);
    }
  } //function selectPassiveAbility(listIndex)

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
    anchors { left: parent != null ? parent.left : undefined; right: parent !=null ? parent.right : undefined }
    height: passiveAbilityInfoLayout.height
          + TibiaStyle.marginNarrow
          + (index == 0 || (index > 0 && index == passiveAbilityList.count -1) ? Math.floor(TibiaStyle.marginNarrow * 0.5) : 0)

    property int passiveAbilityEnumId: enumId;
    property string passiveAbilityIconUrl: iconUrl
    property bool passiveAbilityUsableByCurrentVocation: usableByCurrentVocation

    onClicked: {
      passiveAbilityList.currentIndex = index;
      passiveAbilityList.forceActiveFocus();
      passiveAbilityList.selectPassiveAbility();
    } //onClicked

    RowLayout {
      id: passiveAbilityInfoLayout
      anchors {left: parent.left; right:parent.right; top: parent.top}
      anchors.margins: TibiaStyle.marginNarrow
      anchors.topMargin: index == 0 ? TibiaStyle.marginNarrow
                                    : Math.floor(TibiaStyle.marginNarrow * 0.5)
      spacing: TibiaStyle.marginNarrow

      Image {
        source: iconUrl
        smooth: false

        TibiaDisabledOverlay {
          anchors.fill: parent
          visible: !usableByCurrentVocation
        } //TibiaDisabledOverlay
      } // Image

      ColumnLayout {
        spacing: 0
        Layout.fillWidth: true

        TibiaText {
          Layout.fillWidth: true
          text: name
          color: index == passiveAbilityList.currentIndex ? TibiaStyle.textFieldSelectionTextColor
                                                 : TibiaStyle.textFieldTextColor
        } // TibiaText
        /*
        TibiaText {
          Layout.fillWidth: true
          text: "" //"formulaRaw >>FIXME"
          color: index == passiveAbilityList.currentIndex ? TibiaStyle.textFieldSelectionTextColor
                                                 : TibiaStyle.textFieldTextColor
        } // TibiaText
        */
      } //ColumnLayout
    } //RowLayout

    /*
    drag.target: passiveAbilityList.allowDrag ? passiveAbilityDrag : undefined
    drag.threshold: TibiaStyle.dragThreshold
    drag.onActiveChanged: {
      passiveAbilityList.currentIndex = index;
      passiveAbilityList.selectPassiveAbility();
      passiveAbilityList.dragActive = drag.active;
    } //drag.onActiveChanged
    */

    onPressed: (mouse) => {
      var mousePos = mapToItem(passiveAbilityList, mouse.x, mouse.y);
      /*
      passiveAbilityDrag.x = mousePos.x - TibiaStyle.passiveAbilityListIconSize * 0.5;
      passiveAbilityDrag.y = mousePos.y - TibiaStyle.passiveAbilityListIconSize * 0.5;
      */
    } //onPressed

    onReleased: {
      if (drag.target != undefined && drag.active) {
        drag.target.Drag.drop();
      }
    } //onReleased
  } // delegate: MouseArea

  Keys.onUpPressed: {
    passiveAbilityList.currentIndex = Math.max(0, passiveAbilityList.currentIndex - 1);
    passiveAbilityList.selectPassiveAbility();
  } //Keys.onUpPressed

  Keys.onDownPressed: {
    passiveAbilityList.currentIndex = Math.min(passiveAbilityList.count - 1, passiveAbilityList.currentIndex + 1);
    passiveAbilityList.selectPassiveAbility();
  } //Keys.onDownPressed

  /*
  property bool dragActive: false
  property int mousePosX: 0
  property int mousePosY: 0

  Image {
    id: passiveAbilityDrag
    objectName: "xyz" // TibiaStyle.dragSourcePassiveAbilityIcon
    property int enumId: currentItem != null ? currentItem.passiveAbilityEnumId : 0
    source: currentItem != null ? currentItem.passiveAbilityIconUrl : ""
    visible: Drag.active
    smooth: false

    Drag.keys: [ TibiaStyle.dragKeyPassiveAbility ]
    Drag.active: passiveAbilityList.dragActive
    Drag.source: this

    Drag.hotSpot.x: Math.ceil(width * 0.5)
    Drag.hotSpot.y: Math.ceil(height * 0.5)

    state: Drag.active ? "DRAGGING" : ""
    transitions: [
      Transition {
        to: "DRAGGING"
          PropertyAction { target: passiveAbilityDrag; property: "parent"; value: passiveAbilityList.parentWhileDragging }
      }, //Transition
      Transition {
        from: "DRAGGING"
        SequentialAnimation {
          PropertyAction { target: passiveAbilityDrag; property: "parent"; value: passiveAbilityList }
          ParallelAnimation {
            PropertyAction { target: passiveAbilityDrag; property: "x"; value: 0 }
            PropertyAction { target: passiveAbilityDrag; property: "y"; value: 0 }
          } //ParallelAnimation
        } //SequentialAnimation
      } //Transition
    ] //transitions

  } // Image
  */

} //ListView

