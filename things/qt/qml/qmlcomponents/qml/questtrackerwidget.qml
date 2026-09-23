import QtQuick
import QtQuick.Layouts

import qmlcomponents



TibiaSidebarWidget {
  id: questTrackerSidebarWidget

  property variant questTrackerListModel : widgetController != null ? widgetController.questTrackerList : null

  customButtonContainerData: [
    TibiaButton {
      id: addEntryButton
      Layout.preferredWidth: TibiaStyle.widgetControllButtonSize
      Layout.preferredHeight: TibiaStyle.widgetControllButtonSize
      imageSource: "/images/skin/classic/icon-additionalwidget.png"
      color: "verydarkgrey"
      tooltipText: qsTrId("quest_tracker_track_new")
      onClicked:  widgetController != null ? widgetController.requestOpenQuestLogDialog() : undefined
    }, //TibiaButton
    TibiaIconButton {
      id: showListButton
      sourceUp:   "/images/skin/classic/button-contextmenu-12x12-idle.png"
      sourceDown: "/images/skin/classic/button-contextmenu-12x12-pressed.png"
      tooltipText: qsTrId("quest_tracker_options_tooltip")
      onClicked:  widgetController != null ? widgetController.requestConfigurationContextMenu() : undefined
    } //TibiaIconButton
  ] //customButtonContainerData

  onQuestTrackerListModelChanged: {
    var oldScrollPosition = questTrackerList.contentY;
    questTrackerList.model = questTrackerListModel;
    questTrackerList.contentY = oldScrollPosition;
  }

  caption: qsTrId("quest_tracker_caption")
  picSource: "/images/skin/classic/icon-questtracker-widget.png"

  initialContentHeight: 75
  minContentHeight: TibiaStyle.widgetWithScrollBarMinContentHeight

  TibiaScrollView {
    anchors.fill: parent

    Flickable {
      contentHeight: questTrackerList.contentHeight + TibiaStyle.marginNarrow * 2
      ListView {
        id: questTrackerList
        model: widgetController.questTrackerList;

        anchors { left: parent.left; leftMargin: TibiaStyle.marginNarrow; right: parent.right; rightMargin: TibiaStyle.marginNarrow;
                  top: parent.top; topMargin: TibiaStyle.marginNarrow; }
        height: contentItem.height

        boundsBehavior: Flickable.StopAtBounds
        interactive: false //prevent flick behavior on touch screens
        rebound: Transition {}

        delegate: MouseArea {
          id: mouseArea
          width: questTrackerList.width
          height: questTrackerRowEntry.height
          hoverEnabled: true

          acceptedButtons: Qt.RightButton | Qt.LeftButton
          onClicked: (mouse) => {
            if (mouse.button == Qt.RightButton) {
              widgetController.onShowContextMenuForQuestFlag(model.questFlagID);
            }
          } //onClicked

          onDoubleClicked: widgetController.onShowQuestInQuestLog(model.questFlagID);

          ColumnLayout {
            id: questTrackerRowEntry
            anchors {left: parent.left; right:parent.right}
            spacing: 0

            Component.onCompleted: {
              const HIGHLIGHT_TIME_MILLISECONDS = 5000;
              const Now = Date.now();
              if (Now - model.lastUpdateTimestamp < HIGHLIGHT_TIME_MILLISECONDS) {
                questLinePartNameText.styleType = "WhiteCaption";
                descriptionText.styleType = "WhiteCaption";
                highlightTimer.interval = model.lastUpdateTimestamp + HIGHLIGHT_TIME_MILLISECONDS - Now;
                highlightTimer.start();
              }
            }
            Timer {
              id: highlightTimer
              onTriggered: {
                questLinePartNameText.styleType = "Dialog";
                descriptionText.styleType = "Dialog";
              }
            }

            Item {
              Layout.preferredHeight: 10
              Layout.preferredWidth: questTrackerList.width
              visible: index != 0

              TibiaHorizontalSeparator {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
              } //TibiaHorizontalSeparator
            } //Item

            ColumnLayout {
              id: questLineAndPartName
              spacing: 0

              RowLayout {
                spacing: TibiaStyle.marginNarrow

                TibiaText {
                  id: questLineNameText
                  text: model.questLineName
                  styleType: "WhiteCaption"

                  Layout.fillWidth: true
                } //TibiaText

                TibiaButton {
                  id: pinButton
                  Layout.maximumWidth: 12
                  Layout.maximumHeight: Layout.maximumWidth

                  visible: true
                  opacity: mouseArea.containsMouse || model.isPinned ? 1 : 0
                  imageSource: "/images/icon-pin.png"

                  checkable: true
                  useButtonShouldBeChecked: true
                  buttonShouldBeChecked: model.isPinned

                  onClicked: {
                    widgetController.onPinnedChanged(model.questFlagID, !checked);
                  } //onClicked
                } //TibiaButton
              } //RowLayout

              RowLayout {
                spacing: TibiaStyle.marginNarrow

                Image {
                  visible: model.questLinePartCompleted
                  source:  "/images/icon-yes.png"
                  smooth: false

                  Tooltip {
                    anchors.fill: parent
                    text: qsTrId("quest_log_completed")
                  } //Tooltip
                } //Image

                TibiaText {
                  id: questLinePartNameText
                  text: model.questLinePart
                  Layout.fillWidth: true
                  styleType: "Dialog"
                } //TibiaText
              } //RowLayout
            } //ColumnLayout

            TibiaText {
              id: descriptionText
              Layout.topMargin: TibiaStyle.marginRelated
              text: model.description
              styleType: "Dialog"

              Layout.fillWidth: true
              wrapMode: Text.WordWrap

            } //TibiaText

          } //ColumnLayout

          Tooltip {
            anchors.fill: parent
            text: model.tooltip
          } //Tooltip
        } //delegate: MouseArea
      } //ListView

    } // Flickable

  } //TibiaScrollView

  Lenshelp {
    anchors.fill: parent
    triggerRect: mapFromItem(widgetRoot, 0, 0, widgetRoot.width, widgetRoot.height)
    caption: qsTrId("quest_tracker_widget_lenshelp_caption")
    content: qsTrId("quest_tracker_widget_lenshelp")
  } //Lenshelp

} // TibiaSidebarWidget
