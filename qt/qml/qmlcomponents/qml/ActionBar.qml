import QtQuick
import QtQuick.Layouts
import qmlcomponents



GridLayout {
  id: root

  property QtObject controller: null
  readonly property bool vertical: controller != null ? controller.vertical : false
  readonly property bool atBeginning: root.vertical ? buttonListView.atYBeginning : buttonListView.atXBeginning
  readonly property bool atEnd: root.vertical ? buttonListView.atYEnd : buttonListView.atXEnd

  Layout.fillWidth: !root.vertical
  Layout.fillHeight: root.vertical

  //0 is not used as a real ID
  Layout.row: controller != null && !root.vertical ? controller.actionBarId : 0
  Layout.column: controller != null && root.vertical ? controller.actionBarId : 0

  rows: root.vertical ? -1 : 1
  columns: root.vertical ? 1 : -1

  rowSpacing: TibiaStyle.marginNarrow
  columnSpacing: TibiaStyle.marginNarrow


  GridLayout {
    rows: root.vertical ? 1 : -1
    columns: root.vertical ? -1 : 1
    rowSpacing: 0
    columnSpacing: 0

    Item {
      Layout.preferredWidth: TibiaStyle.actionBarSlotSize * 0.5
      Layout.preferredHeight: TibiaStyle.actionBarSlotSize * 0.5

      TibiaButton {
        id: leftButton
        anchors.fill: parent
        imageSource: root.vertical ? "/images/icon-uparrow.png" : "/images/icon-arrow.png"
        imageSourceDisabled: root.vertical ? "/images/icon-uparrow-disabled.png" :"/images/icon-arrow-disabled.png"
        autoRepeat: true
        onClicked: buttonListView.scrollOneLeft()
        enabled: root.atBeginning == false
        tooltipText: qsTrId("actionbar_button_left_tooltip")
      } //TibiaButton

      Tooltip {
        anchors.fill: parent
        enabled: !leftButton.enabled
        text: qsTrId("actionbar_button_no_scroll")
      } //Tooltip
    } //Item

    Item {
      Layout.preferredWidth: TibiaStyle.actionBarSlotSize * 0.5
      Layout.preferredHeight: TibiaStyle.actionBarSlotSize * 0.5

      TibiaButton {
        id: beginButton
        anchors.fill: parent
        imageSource: root.vertical ? "/images/icon-uparrowskip.png" : "/images/icon-arrowskip.png"
        imageSourceDisabled: root.vertical ? "/images/icon-uparrowskip-disabled.png" : "/images/icon-arrowskip-disabled.png"
        onClicked: buttonListView.scrollLeftEnd()
        enabled: root.atBeginning == false
        tooltipText: qsTrId("actionbar_button_begin_tooltip")
      } //TibiaButton

      Tooltip {
        anchors.fill: parent
        enabled: !beginButton.enabled
        text: qsTrId("actionbar_button_no_scroll")
      } //Tooltip
    } //Item
  } //GridLayout

  Item {
    id: buttonSpace
    Layout.fillWidth: !root.vertical
    Layout.fillHeight: root.vertical
    Layout.preferredHeight: TibiaStyle.actionBarSlotSize
    Layout.preferredWidth: TibiaStyle.actionBarSlotSize

    readonly property int availableSpace: root.vertical ? height : width

    ListView {
      id: buttonListView
      objectName: "buttonListView"
      anchors.top: parent.top
      anchors.left: parent.left

      readonly property int spacePerButton: TibiaStyle.actionBarSlotSize + TibiaStyle.actionBarSlotMargin
      readonly property int numVisibleSlots: Math.min(count, Math.floor((buttonSpace.availableSpace + TibiaStyle.actionBarSlotMargin) / spacePerButton))
      readonly property int usableSpace: numVisibleSlots * spacePerButton - TibiaStyle.actionBarSlotMargin
      width: root.vertical ? TibiaStyle.actionBarSlotSize : usableSpace
      height: root.vertical ? usableSpace : TibiaStyle.actionBarSlotSize
      //1 slot => TibiaStyle.actionBarSlotSize
      //2 slots => 2*(TibiaStyle.actionBarSlotSize) + TibiaStyle.actionBarSlotMargin
      //        => 2*spacePerButton - TibiaStyle.actionBarSlotMargin

      // PERF It is important that this clip property remains set to true.
      // When this is false Qt takes a lot of time to check for hover elements
      // when evaluating mouse move events. This leads to massive frame drops
      // (e.g. 120 FPS -> 10 FPS). I guess this happens because Qt uses the
      // clip space to precull action bar buttons when looking for hoverables
      // when this is true.
      // If this must be changed please test for frame drops when moving the
      // mouse non-stop in the client window.
      clip: true

      spacing: TibiaStyle.actionBarSlotMargin
      model: controller != null ? controller.actionButtonModel : null
      delegate: ActionBarMultiActionButton {
        controller: root.controller
        buttonData: modelData
        direction: root.controller != null ?
            (root.controller.position === TibiaEnums.ActionBarPositionRight ? ActionBarMultiActionExpandable.Direction.Left :
             root.controller.position === TibiaEnums.ActionBarPositionLeft ? ActionBarMultiActionExpandable.Direction.Right :
             root.controller.position === TibiaEnums.ActionBarPositionBottom ? ActionBarMultiActionExpandable.Direction.Up :
             ActionBarMultiActionExpandable.Direction.Down)
          : ActionBarMultiActionExpandable.Direction.Up
      } //delegate: ActionBarMultiActionButton
      orientation: root.vertical ? ListView.Vertical : ListView.Horizontal

      highlightRangeMode: ListView.ApplyRange
      preferredHighlightBegin: 0
      preferredHighlightEnd: TibiaStyle.actionBarSlotSize
      highlightFollowsCurrentItem: true
      highlightMoveDuration: 0

      interactive: false //prevent flick behavior on touch screens
      boundsBehavior: Flickable.StopAtBounds

      onNumVisibleSlotsChanged: {
        if (buttonListView.count - buttonListView.numVisibleSlots < buttonListView.currentIndex) {
          buttonListView.currentIndex = buttonListView.count - buttonListView.numVisibleSlots;
        }

        if (root.controller != null) {
          root.controller.setNumVisibleSlots(buttonListView.numVisibleSlots);
        }
      } //onNumVisibleSlotsChanged

      readonly property int controllerFirstVisibleIndex: controller != null ? controller.firstVisibleButtonId : 0
      onControllerFirstVisibleIndexChanged: controllerFirstVisibleIndexChanged.restart()
      Timer {
        id: controllerFirstVisibleIndexChanged
        interval: 0
        onTriggered: {
          buttonListView.currentIndex = buttonListView.controllerFirstVisibleIndex;
        } //onTriggered
      } //Timer

      function scrollOneLeft() {
        if (root.atBeginning == false) {
          buttonListView.decrementCurrentIndex();
        }
      } //function shiftOneLeft()

      function scrollOneRight() {
        if (root.atEnd == false) {
          buttonListView.incrementCurrentIndex();
        }
      } //function scrollOneRight()

      function scrollLeftEnd() {
        buttonListView.currentIndex = 0;
      } //function scrollLeftEnd()

      function scrollRightEnd() {
        buttonListView.currentIndex = buttonListView.count - buttonListView.numVisibleSlots;
      } //function scrollLeftEnd()

      onCurrentIndexChanged: {
        buttonListView.currentIndex = Math.max(0, Math.min(buttonListView.count - buttonListView.numVisibleSlots, buttonListView.currentIndex));
        if (controller != null) {
          controller.firstVisibleButtonId = buttonListView.currentIndex;
          controller.closeOpenMultiActionButtons();
        }
      } //onCurrentIndexChanged
    } //ListView
  } //Item

   GridLayout {
    rows: root.vertical ? 1 : -1
    columns: root.vertical ? -1 : 1
    rowSpacing: 0
    columnSpacing: 0

    Item {
      Layout.preferredWidth: TibiaStyle.actionBarSlotSize * 0.5
      Layout.preferredHeight: TibiaStyle.actionBarSlotSize * 0.5

      TibiaButton {
        id: rightButton
        anchors.fill: parent
        imageSource: root.vertical ? "/images/icon-downarrow.png" : "/images/icon-arrow.png"
        imageSourceDisabled: root.vertical ? "/images/icon-arrow-disabled.png" : "/images/icon-arrow-disabled.png"
        imageMirrored: !root.vertical
        autoRepeat: true
        enabled: root.atEnd == false
        onClicked: buttonListView.scrollOneRight()
        tooltipText: qsTrId("actionbar_button_right_tooltip")
      } //TibiaButton

      Tooltip {
        anchors.fill: parent
        enabled: !rightButton.enabled
        text: qsTrId("actionbar_button_no_scroll")
      } //Tooltip
    } //Item

    Item {
      Layout.preferredWidth: TibiaStyle.actionBarSlotSize * 0.5
      Layout.preferredHeight: TibiaStyle.actionBarSlotSize * 0.5

      TibiaButton {
        id: endButton
        anchors.fill: parent
        imageSource: root.vertical ? "/images/icon-downarrowskip.png" : "/images/icon-arrowskip.png"
        imageSourceDisabled: root.vertical ? "/images/icon-downarrowskip-disabled.png" : "/images/icon-arrowskip-disabled.png"
        imageMirrored: !root.vertical
        enabled: root.atEnd == false
        onClicked: buttonListView.scrollRightEnd()
        tooltipText: qsTrId("actionbar_button_end_tooltip")
      } //TibiaButton

      Tooltip {
        anchors.fill: parent
        enabled: !endButton.enabled
        text: qsTrId("actionbar_button_no_scroll")
      } //Tooltip
    } //Item
  } //GridLayout
} // GridLayout
