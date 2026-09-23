import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qmlcomponents
import QtQuick.LegacyControls


ColumnLayout {
  id: root
  property var controller: null
  property var initialFocusItem: searchTextField

  property bool needsTabNavigation: filterFocusScope.focus

  readonly property bool hasPremium: controller != null && controller.hasPremium

  spacing: TibiaStyle.marginUnrelated

  TibiaFrame2PixelUpFilledWithCaption {
    Layout.fillWidth: true
    Layout.preferredHeight: filtlerLayout.height + topMarginToContent + marginsToContent

    caption: qsTrId("teamfinder_filter_teams")

    FocusScope {
     id: filterFocusScope

      anchors { left: parent.left; top: parent.top; right: parent.right }
      anchors.margins: parent.marginsToContent
      anchors.topMargin: parent.topMarginToContent

      RowLayout {
        id: filtlerLayout
        anchors { left: parent.left; top: parent.top; right: parent.right }

        spacing: TibiaStyle.marginUnrelated

        GridLayout {
          id: leftFilters
          columns: 2
          rowSpacing: TibiaStyle.marginRelated
          columnSpacing: TibiaStyle.marginRelated

          TibiaText {
            Layout.preferredWidth: 90 //Wanted so the layout does jump when changing tabs to assemble team
            horizontalAlignment: Text.AlignRight

            text: qsTrId("level") + ":"
          } //TibiaText

          TibiaTextField {
            id: levelTextField
            Layout.preferredWidth: TibiaStyle.teamFinderNumberInputWidth
            KeyNavigation.backtab: searchTextField

            validator: RegularExpressionValidator { regularExpression: /[0-9]{0,4}/; }
            shouldBeText: controller != null ? controller.teamsList.filterLevel : ""
            onTextChanged: {
              if (controller != null) {
                 controller.teamsList.filterLevel = text;
              }
            } //onTextChanged
          } //TibiaTextField

          TibiaText {
            text: qsTrId("teamfinder_vocations") + ":"
            Layout.alignment: Qt.AlignTop | Qt.AlignRight
          } //TibiaText

          GridLayout {
            columns: 2
            rowSpacing: TibiaStyle.marginNarrow
            columnSpacing: TibiaStyle.marginRelated

            TibiaCheckBox {
              id: druidWantedCheckBox
              Layout.preferredWidth: TibiaStyle.teamFinderCheckBoxWidth
              text: qsTrId("druid")
              shouldBeChecked: controller != null && controller.teamsList.druidWanted
              onCheckedChanged: {
                if (controller != null) {
                  controller.teamsList.druidWanted = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckbox

            TibiaCheckBox {
              id: knightWantedCheckBox
              Layout.preferredWidth: TibiaStyle.teamFinderCheckBoxWidth
              text: qsTrId("knight")
              shouldBeChecked: controller != null && controller.teamsList.knightWanted
              onCheckedChanged: {
                if (controller != null) {
                  controller.teamsList.knightWanted = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckbox

            TibiaCheckBox {
              id: paladinWantedCheckBox
              Layout.preferredWidth: TibiaStyle.teamFinderCheckBoxWidth
              text: qsTrId("paladin")
              shouldBeChecked: controller != null && controller.teamsList.paladinWanted
              onCheckedChanged: {
                if (controller != null) {
                  controller.teamsList.paladinWanted = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckbox

            TibiaCheckBox {
              id: sorcererWantedCheckBox
              Layout.preferredWidth: TibiaStyle.teamFinderCheckBoxWidth
              text: qsTrId("sorcerer")
              shouldBeChecked: controller != null && controller.teamsList.sorcererWanted
              onCheckedChanged: {
                if (controller != null) {
                  controller.teamsList.sorcererWanted = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckbox

            TibiaCheckBox {
              id: monkWantedCheckBox
              Layout.preferredWidth: TibiaStyle.teamFinderCheckBoxWidth
              text: qsTrId("monk")
              shouldBeChecked: controller != null && controller.teamsList.monkWanted
              onCheckedChanged: {
                if (controller != null) {
                  controller.teamsList.monkWanted = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckbox
          } //GridLayout

          Item {
            Layout.columnSpan: 2
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: TibiaStyle.marginUnrelated - 2 * parent.rowSpacing
          } //Item

          TibiaText {
            text: qsTrId("teamfinder_activity_type") + ":"
            Layout.alignment: Qt.AlignTop | Qt.AlignRight
          } //TibiaText

          GridLayout {
            columns: 2
            rowSpacing: TibiaStyle.marginNarrow
            columnSpacing: TibiaStyle.marginRelated

            TibiaCheckBox {
              Layout.preferredWidth: root.TibiaStyle.teamFinderCheckBoxWidth
              text: qsTrId("teamfinder_activty_boss")
              shouldBeChecked: controller != null && controller.teamsList.showBosses
              onCheckedChanged: {
                if (controller != null) {
                  controller.teamsList.showBosses = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckbox

            TibiaCheckBox {
              Layout.preferredWidth: root.TibiaStyle.teamFinderCheckBoxWidth
              text: qsTrId("teamfinder_activty_hunt")
              shouldBeChecked: controller != null && controller.teamsList.showHunts
              onCheckedChanged: {
                if (controller != null) {
                  controller.teamsList.showHunts = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckbox

            TibiaCheckBox {
              Layout.preferredWidth: root.TibiaStyle.teamFinderCheckBoxWidth
              text: qsTrId("teamfinder_activty_quest")
              shouldBeChecked: controller != null && controller.teamsList.showQuests
              onCheckedChanged: {
                if (controller != null) {
                  controller.teamsList.showQuests = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckbox

            TibiaCheckBox {
              Layout.preferredWidth: root.TibiaStyle.teamFinderCheckBoxWidth
              text: qsTrId("teamfinder_activty_other")
              shouldBeChecked: controller != null && controller.teamsList.showOther
              onCheckedChanged: {
                if (controller != null) {
                  controller.teamsList.showOther = checked;
                }
              } //onCheckedChanged
            } //TibiaCheckbox
          } //GridLayout
        } //GridLayout

        GridLayout {
          id: rightFilters
          columns: 2
          rowSpacing: TibiaStyle.marginNarrow
          columnSpacing: TibiaStyle.marginRelated

          TibiaText {
            text: qsTrId("teamfinder_team_size") + ":"
            Layout.alignment: Qt.AlignRight
          } //TibiaText

          RowLayout {
            spacing: TibiaStyle.marginNarrow

            TibiaTextField {
              id: minLevelTextField
              Layout.preferredWidth: TibiaStyle.teamFinderNumberInputWidth
              validator: RegularExpressionValidator { regularExpression: /[0-9]{0,3}/; }
              shouldBeText: controller != null ? controller.teamsList.minTeamSize : ""
              onTextChanged: {
                if (controller != null) {
                   controller.teamsList.minTeamSize = text;
                }
              } //onTextChanged
            } //TibiaTextField

            TibiaText {
              text: "-"
            } //TibiaText

            TibiaTextField {
              id: maxLevelTextField
              Layout.preferredWidth: TibiaStyle.teamFinderNumberInputWidth
              validator: RegularExpressionValidator { regularExpression: /[0-9]{0,3}/; }
              shouldBeText: controller != null ? controller.teamsList.maxTeamSize : ""
              onTextChanged: {
                if (controller != null) {
                   controller.teamsList.maxTeamSize = text;
                }
              } //onTextChanged
            } //TibiaTextField
          } //RowLayout

          TibiaText {
            text: qsTrId("teamfinder_start_time") + ":"
            Layout.alignment: Qt.AlignTop | Qt.AlignRight
          } //TibiaText

          ColumnLayout {
            spacing: TibiaStyle.marginNarrow

            ButtonGroup {
              id: timeType

              checkedButton: controller != null
                    && controller.teamsList.startTimeManager.startImmediately ? timeNowRadioButton
                                                                              : timeSelectionRadioButton

              onCheckedButtonChanged: {
                if (controller != null) {
                  if (checkedButton == timeSelectionRadioButton) {
                    controller.teamsList.startTimeManager.startImmediately = false;
                  } else {
                    controller.teamsList.startTimeManager.startImmediately = true;
                  }
                }
              } //onCurrentChanged
            } //ButtonGroup

            TibiaRadioButton {
              id: timeNowRadioButton
              ButtonGroup.group: timeType

              text: qsTrId("teamfinder_start_time_immediately")
            } //TibiaRadioButton

            RowLayout {
              spacing: TibiaStyle.marginRelated

              TibiaRadioButton {
                id: timeSelectionRadioButton
                Layout.alignment: Qt.AlignTop
                Layout.topMargin: 3
                ButtonGroup.group: timeType
              } //TibiaRadioButton

              Item {
                Layout.preferredWidth: selectTimeLayout.width
                Layout.preferredHeight: selectTimeLayout.height

                MouseArea {
                  anchors.fill: parent
                  enabled: !timeSelectionRadioButton.checked
                  onClicked: {
                    timeSelectionRadioButton.checked = true;
                  } //onClicked
                } //MouseArea

                ColumnLayout {
                  id: selectTimeLayout
                  spacing: TibiaStyle.marginNarrow
                  enabled: timeSelectionRadioButton.checked

                  RowLayout {
                    spacing: TibiaStyle.marginRelated
                    Layout.preferredHeight: timePicker.height

                    TibiaTimePicker {
                      id: timePicker

                      onHourChanged: delayedSetTime.restart()
                      onMinuteChanged: delayedSetTime.restart()

                      Timer {
                        id: delayedSetTime
                        interval: TibiaStyle.searchDelay
                        onTriggered: {
                          if (controller != null) {
                            controller.teamsList.startTimeManager.setTime(timePicker.hour,
                                                                  timePicker .minute)
                          }
                        } //onTriggered
                      } //Timer

                      shouldBeHour: controller != null ? controller.teamsList.startTimeManager.hour : 0
                      shouldBeMinute: controller != null ? controller.teamsList.startTimeManager.minute : 0
                    } //TibiaTimePicker

                    TibiaText {
                      Layout.preferredWidth: 110
                      text: controller != null ?  controller.teamsList.startTimeManager.localDateString
                                                 : qsTrId("teamfinder_not_time_selected")
                    } //TibiaText

                    TibiaGuiHelp {
                      text: controller != null ?  controller.teamsList.startTimeManager.serverTimeString
                                                 : qsTrId("teamfinder_not_time_selected")
                    } //TibiaGuiHelp
                  } //RowLayout

                  RowLayout {
                    spacing: TibiaStyle.marginNarrow

                    TibiaText {
                      Layout.leftMargin: -1
                      text:qsTrId("teamfinder_start_time_offest_prefix")
                    } //TibiaText

                    TibiaComboBox {
                      id: jitterTimePicker
                      Layout.preferredWidth: 70

                      currentIndex: 0
                      textRole: "text"
                      valueRole: "minutes"
                      model: ListModel {
                        id: jitterTimeModel
                        ListElement { text: qsTrId("0min");  minutes: 0 }
                        ListElement { text: qsTrId("15min"); minutes: 15 }
                        ListElement { text: qsTrId("30min"); minutes: 30 }
                        ListElement { text: qsTrId("1h");    minutes: 60 }
                        ListElement { text: qsTrId("2h");    minutes: 120 }
                        ListElement { text: qsTrId("3h");    minutes: 180 }
                        ListElement { text: qsTrId("6h");    minutes: 360 }
                        ListElement { text: qsTrId("12h");   minutes: 720 }
                      } //model: ListModel

                      onCurrentIndexChanged: {
                        if (controller != null) {
                          controller.teamsList.jitterTime = jitterTimeModel.get(currentIndex).minutes;
                        }
                      } //onCurrentIndexChanged

                      property int shouldBeMinutes: controller != null ? controller.teamsList.jitterTime : 0
                      onShouldBeMinutesChanged: {
                        for (var i = 0; i < jitterTimeModel.count; i++) {
                          if (jitterTimeModel.get(i).minutes == shouldBeMinutes) {
                            shouldBeCurrentIndex = i;
                            break;
                          }
                        }
                      } //onShouldBeMinutesChanged
                    } //TibiaComboBox

                    TibiaText {
                      text: qsTrId("teamfinder_start_time_offest_sufix")
                    } //TibiaText
                  } //RowLayout
                } //ColumnLayout
              } //Item
            } //RowLayout
          } //ColumnLayout

          Item {
            Layout.columnSpan: 2
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: TibiaStyle.marginUnrelated - 2 * parent.rowSpacing
          } //Item

          TibiaText {
            text: qsTrId("search") + ":"
          } //TibiaText

          TibiaTextSearchField {
            id: searchTextField
            Layout.fillWidth: true
            KeyNavigation.tab: levelTextField

            shouldBeText: controller != null ? controller.teamsList.nameFilter : ""

            onSearchTextChanged: {
              if (controller != null) {
                controller.teamsList.nameFilter = searchText;
              }
            } //onSearchTextChanged
          } //TibiaTextSearchField
        } //GridLayout
      } //RowLayout
    } //RowLayout
  } //TibiaFrame2PixelUpFilledWithCaption

  TibiaTableView {
    id: currentTeamsTableView
    Layout.fillWidth: true
    Layout.fillHeight: true

    KeyNavigation.tab: currentTeamsTableView
    KeyNavigation.backtab: currentTeamsTableView

    headerVisible: true

    model: controller != null ? controller.teamsList : null

    TableViewColumn {
      id: columnActivity
      title: qsTrId("teamfinder_activity")
      role: "name"
      resizable: false
      movable: false
      width: currentTeamsTableView.contentItem.width - columnLevelRange.width
                                                     - columnSize.width
                                                     - columnVocations.width
                                                     - columnStartTime.width
                                                     - columnLeader.width
                                                     - columnStatus.width
      delegate: RowLayout {
        id: displayNameLayout
        anchors.fill: parent
        spacing: TibiaStyle.marginRelated

        TibiaText {
          Layout.leftMargin: TibiaStyle.marginNarrow
          Layout.alignment: Qt.AlignTop
          styleType: "WhiteCaption"
          text: model ? model.typeName : qsTrId("dummy_unknown")
        } // TibiaText

        TibiaText {
          Layout.fillWidth: true
          Layout.alignment: Qt.AlignTop
          styleType: styleData.selected ? "TextFieldTextSelected" : "TextFieldText"
          text: model ? model.name : qsTrId("dummy_unknown")
        } // TibiaText

        TibiaGuiHelp {
          text: model ? model.alias : ""
          visible: text.length > 0
        } //TibiaGuiHelp

        TibiaVerticalSeparator {
          Layout.fillHeight: true
        } // TibiaVerticalSeparator
      } //delegate: RowLayout
    } //TableViewColumn

    TableViewColumn {
      id: columnLevelRange
      title: qsTrId("level")
      role: "levelRange"
      resizable: false
      movable: false
      width: 80
      delegate : RowLayout {
        spacing: TibiaStyle.marginNarrow

        TibiaText {
          Layout.leftMargin: TibiaStyle.marginNarrow
          Layout.fillWidth: true
          Layout.alignment: Qt.AlignCenter | Qt.AlignTop
          styleType: styleData.selected ? "TextFieldTextSelected" : "TextFieldText"
          text: model ? model.levelRange : ""
          horizontalAlignment: Text.AlignHCenter
        } //TibiaText

        TibiaVerticalSeparator {
          Layout.fillHeight: true
        } // TibiaVerticalSeparator
      } //delegate : RowLayout
    } //TableViewColumn

    TableViewColumn {
      id: columnSize
      title: qsTrId("teamfinder_size")
      role: "teamSizeString"
      resizable: false
      movable: false
      width: 65
      delegate : RowLayout {
        spacing: TibiaStyle.marginNarrow

        TibiaText {
          Layout.leftMargin: TibiaStyle.marginNarrow
          Layout.fillWidth: true
          Layout.alignment: Qt.AlignCenter | Qt.AlignTop
          styleType: styleData.selected ? "TextFieldTextSelected" : "TextFieldText"
          text: model ? model.teamSizeString : ""
          horizontalAlignment: Text.AlignHCenter
        } //TibiaText

        TibiaVerticalSeparator {
          Layout.fillHeight: true
        } // TibiaVerticalSeparator
      } //delegate : RowLayout
    } //TableViewColumn

    TableViewColumn {
      id: columnVocations
      title: qsTrId("teamfinder_vocations")
      role: "vocationString"
      resizable: false
      movable: false
      width: 100
    } //TableViewColumn

    TableViewColumn {
      id: columnStartTime
      title: qsTrId("teamfinder_start_time")
      role: "startTimeString"
      resizable: false
      movable: false
      width: 90
      delegate : RowLayout {
        spacing: TibiaStyle.marginNarrow

        TibiaText {
          Layout.leftMargin: TibiaStyle.marginNarrow
          Layout.fillWidth: true
          Layout.alignment: Qt.AlignCenter | Qt.AlignTop
          styleType: styleData.selected ? "TextFieldTextSelected" : "TextFieldText"
          text: model ? model.startTimeString : ""
          horizontalAlignment: Text.AlignRight

          Tooltip {
            anchors.fill: parent
            text: model ? model.startTimeDetailString : ""
          } //Tooltip
        } //TibiaText

        TibiaVerticalSeparator {
          Layout.fillHeight: true
        } // TibiaVerticalSeparator
      } //delegate : RowLayout
    } //TableViewColumn

    TableViewColumn {
      id: columnLeader
      title: qsTrId("teamfinder_leader")
      role: "leaderName"
      resizable: false
      movable: false
      width: 100

      delegate : Item {
        RowLayout {
          anchors { left: parent.left; right: separator.left }
          anchors.margins: TibiaStyle.marginNarrow
          spacing: TibiaStyle.marginNarrow

          TibiaText {
            Layout.maximumWidth: parent.width
                              - (leaderIcon.visible? (leaderIcon.width + parent.spacing) : 0)
            styleType: styleData.selected ? "TextFieldTextSelected" : "TextFieldText"
            text: model ? model.leaderName : ""
          } //TibiaText

          Image {
            id: leaderIcon
            visible: model && model.isLeader
            source: "/images/icon-leader.png"

            Tooltip {
              anchors.fill: parent
              text: qsTrId("teamfinder_leader")
            } //Tooltip
          } // Image

          Item {
            Layout.leftMargin: -parent.spacing
            Layout.fillWidth: true
          } //Item
        } //RowLaoyut

        TibiaVerticalSeparator {
          id: separator
          anchors {right: parent.right; top: parent.top; bottom: parent.bottom }
        } // TibiaVerticalSeparator
      } //delegate: Item
    } //TableViewColumn

    TableViewColumn {
      id: columnStatus
      title: qsTrId("status")
      role: "status"
      resizable: false
      movable: false
      width: 60
      delegate: Item {
       anchors.fill: parent

        TibiaTeamFinderStatus {
          anchors.centerIn: parent
          teamStatus: model ? model.status : TibiaEnums.TeamFinderStatusNotInTeam
        } //TibiaTeamFinderStatus

        TibiaButton {
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          height: parent.height
          width: height
          imageSourceUp: "/images/icon-edit.png"
          visible: styleData.selected
                 && model && !model.isLeader
                 && model.status != TibiaEnums.TeamFinderStatusRejected

          onClicked: {
            if (controller != null && model) {
              controller.onJoinLeaveTeamClicked(model.teamId, model.status);
            }
          } //onClicked
        } // TibiaButton
      } //delegate: Item
    } //TableViewColumn

    RowLayout {
      anchors.centerIn: parent
      visible: controller != null ? controller.teamsList.numberOfTeams == 0 : false

      Image {
        visible: !root.hasPremium
        source: "/images/premium/icon-nopremium.png"
      } //Image

      TibiaText {
        text: root.hasPremium ? qsTrId("teamfinder_no_teams")
                              : qsTrId("teamfinder_no_teams_no_premium")
      } //TibiaText
    } //RowLayout
  } //TibiaTableView

  TibiaFrame2PixelUpFilled {
    Layout.fillWidth: true
    Layout.preferredHeight: premiumStateLayout.height + 2 * (TibiaStyle.marginRelated + borderWidth)

    visible: !root.hasPremium

    RowLayout {
      id: premiumStateLayout
      anchors { left: parent.left; top: parent.top; right: parent.right }
      anchors.margins: TibiaStyle.marginRelated + parent.borderWidth
      spacing: TibiaStyle.marginRelated

      TibiaText {
        Layout.fillWidth: true
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter

        text: qsTrId("teamfinder_premium_required")
      } //TibiaText

      TibiaPremiumStateButton {
        hasPremium: root.hasPremium

        onClicked: controller ? controller.getPremiumClicked() : undefined
      } //TibiaPremiumStateButton
    } //RowLayout
  } //TibiaFrame2PixelUpFilled
} // ColumnLayout
