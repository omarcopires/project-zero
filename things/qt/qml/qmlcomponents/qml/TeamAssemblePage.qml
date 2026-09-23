import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qmlcomponents
import QtQuick.LegacyControls


ColumnLayout {
  id: root
  property var controller: null
  property var initialFocusItem: root.assemblyStarted ? teamTableView : searchTextField

  property bool needsTabNavigation: teamOptionsFocusScope.focus

  readonly property bool hasPremium: controller != null && controller.hasPremium
  readonly property bool assemblyStarted : controller != null && controller.assemblyStarted
  property QtObject teamSettings: controller != null ? controller.teamSettings : null

  onInitialFocusItemChanged: {
    initialFocusItem.forceActiveFocus();
  } //onAssemblyStartedChanged

  readonly property int externalMembers: teamSettings == null
                                      || teamSettings.teamSize == 0 ? 0
                                                                    : teamSettings.teamSize - teamSettings.freeSlots - controller.teamMembers.countAccepted

  function forwordTeamSettingsToController() {
    if (teamSettings != null) {
      teamSettings.minLevel = minLevelTextField.text;
      teamSettings.maxLevel = maxLevelTextField.text;
      teamSettings.druidNeeded = druidNeededCheckBox.checked;
      teamSettings.knightNeeded = knightNeededCheckBox.checked;
      teamSettings.paladinNeeded = paladinNeededCheckBox.checked;
      teamSettings.sorcererNeeded = sorcererNeededCheckBox.checked;
      teamSettings.monkNeeded = monkNeededCheckBox.checked;
      teamSettings.teamSize = teamSizeTextField.text;
      teamSettings.freeSlots = freeSlotsTextField.text;
      teamSettings.includeParty = includePartyCheckBox.checked;
    }
  } //forwordTeamSettingsToController

  RowLayout {
    Layout.fillWidth: true
    spacing: TibiaStyle.marginRelated

    ColumnLayout {
      Layout.fillWidth: true
      Layout.fillHeight: true
      spacing: TibiaStyle.marginRelated

      TibiaFrame2PixelUpFilledWithCaption {
        Layout.fillWidth: true
        Layout.fillHeight: true

        caption: qsTrId("teamfinder_team_settings")

        FocusScope {
          id: teamOptionsFocusScope
          anchors.fill: parent
          anchors.margins: parent.marginsToContent
          anchors.topMargin: parent.topMarginToContent

          GridLayout {
            id: optionsLayout
            anchors.fill: parent

            columns: 2
            rowSpacing: TibiaStyle.marginRelated
            columnSpacing: TibiaStyle.marginRelated

            TibiaText {
              Layout.preferredWidth: 90 //needed so the layout does not move when assemblyStarted == true
              horizontalAlignment: Text.AlignRight

              text: qsTrId("teamfinder_level_range") + ":"
            } //TibiaText

            RowLayout {
              spacing: TibiaStyle.marginNarrow

              TibiaTextField {
                id: minLevelTextField
                Layout.preferredWidth: TibiaStyle.teamFinderNumberInputWidth
                validator: RegularExpressionValidator { regularExpression: /[0-9]{0,4}/; }
                shouldBeText: teamSettings != null ? teamSettings.minLevel : ""

                KeyNavigation.backtab: root.assemblyStarted ? unlistTeamButton : startTeamButton
              } //TibiaTextField

              TibiaText {
                text: "-"
              } //TibiaText

              TibiaTextField {
                id: maxLevelTextField
                Layout.preferredWidth: TibiaStyle.teamFinderNumberInputWidth
                validator: RegularExpressionValidator { regularExpression: /[0-9]{0,4}/; }
                shouldBeText: teamSettings != null ? teamSettings.maxLevel : ""
              } //TibiaTextField

              TibiaButton {
                Layout.leftMargin: TibiaStyle.marginRelated - parent.spacing
                Layout.preferredWidth: minLevelTextField.height
                Layout.preferredHeight: minLevelTextField.height
                imageSource: "image://creaturestateflags-party/5"
                tooltipText: qsTrId("teamfidner_set_shared_xp_level_range")

                onClicked: {
                  if (controller != null) {
                    var leaderLevel = controller.getLeaderlevel();
                    var maxLevel = Math.floor(leaderLevel * 6 / 5)
                    var minLevel = Math.floor(maxLevel * 2 / 3)
                    minLevelTextField.text = minLevel
                    maxLevelTextField.text = maxLevel
                  }
                } //onClicked
              } //TibiaButton
            } //RowLayout

            TibiaText {
              Layout.alignment: Qt.AlignTop | Qt.AlignRight
              text: qsTrId("teamfinder_vocations") + ":"
            } //TibiaText

            GridLayout {
              columns: 2
              rowSpacing: TibiaStyle.marginNarrow
              columnSpacing: TibiaStyle.marginRelated

              TibiaCheckBox {
                id: druidNeededCheckBox
                Layout.preferredWidth: TibiaStyle.teamFinderCheckBoxWidth
                text: qsTrId("druid")
                shouldBeChecked: teamSettings != null && teamSettings.druidNeeded
              } //TibiaCheckbox

              TibiaCheckBox {
                id: knightNeededCheckBox
                Layout.preferredWidth: TibiaStyle.teamFinderCheckBoxWidth
                text: qsTrId("knight")
                shouldBeChecked: teamSettings != null && teamSettings.knightNeeded
              } //TibiaCheckbox

              TibiaCheckBox {
                id: paladinNeededCheckBox
                Layout.preferredWidth: TibiaStyle.teamFinderCheckBoxWidth
                text: qsTrId("paladin")
                shouldBeChecked: teamSettings != null && teamSettings.paladinNeeded
              } //TibiaCheckbox

              TibiaCheckBox {
                id: sorcererNeededCheckBox
                Layout.preferredWidth: TibiaStyle.teamFinderCheckBoxWidth
                text: qsTrId("sorcerer")
                shouldBeChecked: teamSettings != null && teamSettings.sorcererNeeded
              } //TibiaCheckbox
              TibiaCheckBox {
                id: monkNeededCheckBox
                Layout.preferredWidth: TibiaStyle.teamFinderCheckBoxWidth
                text: qsTrId("monk")
                shouldBeChecked: teamSettings != null && teamSettings.monkNeeded
              } //TibiaCheckbox
            } //GridLayout

            Item {
              Layout.columnSpan: 2
              Layout.fillWidth: true
              Layout.minimumHeight: TibiaStyle.marginUnrelated - 2 * parent.rowSpacing
            } //Item

            TibiaText {
              Layout.alignment: Qt.AlignRight
              text: qsTrId("teamfinder_team_size") + ":"
            } //TibiaText

            TibiaTextField {
              id: teamSizeTextField
              Layout.preferredWidth: TibiaStyle.teamFinderNumberInputWidth
              validator: RegularExpressionValidator { regularExpression: /[0-9]{0,3}/; }
              shouldBeText: teamSettings != null ? teamSettings.teamSize : ""
            } //TibiaTextField

            TibiaText {
              Layout.alignment: Qt.AlignRight
              text: qsTrId("teamfinder_free_slots") + ":"
            } //TibiaText

            TibiaTextField {
              id: freeSlotsTextField
              Layout.preferredWidth: TibiaStyle.teamFinderNumberInputWidth
              validator: RegularExpressionValidator { regularExpression: /[0-9]{0,3}/; }
              shouldBeText: teamSettings != null ? teamSettings.freeSlots : ""
            } //TibiaTextField

            TibiaHorizontalSeparator {
              Layout.columnSpan: 2
              Layout.fillWidth: true
            } //TibiaHorizontalSeparator

            TibiaText {
              text: qsTrId("teamfinder_start_time") + ":"
              Layout.alignment: Qt.AlignTop | Qt.AlignRight
            } //TibiaText

            ColumnLayout {
              spacing: TibiaStyle.marginNarrow

              ButtonGroup {
                id: timeType

                checkedButton: teamSettings != null
                            && teamSettings.startTimeManager.startImmediately ? timeNowRadioButton
                                                                              : timeSelectionRadioButton

                onCheckedButtonChanged: {
                  if (teamSettings != null) {
                    if (checkedButton == timeSelectionRadioButton) {
                      teamSettings.startTimeManager.startImmediately = false;
                    } else {
                      teamSettings.startTimeManager.startImmediately = true;
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

                  RowLayout {
                    id: selectTimeLayout
                    spacing: TibiaStyle.marginRelated
                    enabled: timeSelectionRadioButton.checked
                    anchors { left: parent.left; right: parent.right }

                    TibiaTimePicker {
                      id: timePicker
                      onHourChanged: delayedSetTime.restart()
                      onMinuteChanged: delayedSetTime.restart()

                      Timer {
                        id: delayedSetTime
                        interval: TibiaStyle.searchDelay
                        onTriggered: {
                          if (teamSettings != null) {
                            teamSettings.startTimeManager.setTime(timePicker.hour,
                                                                  timePicker.minute)
                          }
                        } //onTriggered
                      } //Timer

                      shouldBeHour: teamSettings != null ? teamSettings.startTimeManager.hour : -1
                      shouldBeMinute: teamSettings != null ? teamSettings.startTimeManager.minute : -1
                    } //TibiaTimePicker

                    TibiaText {
                      Layout.preferredWidth: 100
                      text: teamSettings != null ? teamSettings.startTimeManager.localDateString
                                                 : qsTrId("teamfinder_not_time_selected")
                    } //TibiaText

                    TibiaGuiHelp {
                      text: teamSettings != null ? teamSettings.startTimeManager.serverTimeString
                                                 : qsTrId("teamfinder_not_time_selected")
                    } //TibiaGuiHelp
                  } //RowLayout
                } //Item
              } //RowLayout
            } // ColumnLayout

            TibiaText {
              Layout.alignment: Qt.AlignTop | Qt.AlignRight
              visible: !root.assemblyStarted
              text: qsTrId("teamfinder_activity_type") + ":"
            } //TibiaText

            GridLayout {
              columns: 2
              rowSpacing: TibiaStyle.marginNarrow
              columnSpacing: TibiaStyle.marginRelated
              visible: !root.assemblyStarted

              TibiaCheckBox {
                Layout.preferredWidth: root.TibiaStyle.teamFinderCheckBoxWidth
                text: qsTrId("teamfinder_activty_boss")
                shouldBeChecked: controller != null && controller.activityList.showBosses
                onCheckedChanged: {
                  if (controller != null) {
                    controller.activityList.showBosses = checked;
                  }
                } //onCheckedChanged
              } //TibiaCheckbox

              TibiaCheckBox {
                Layout.preferredWidth: root.TibiaStyle.teamFinderCheckBoxWidth
                text: qsTrId("teamfinder_activty_hunt")
                shouldBeChecked: controller != null && controller.activityList.showHunts
                onCheckedChanged: {
                  if (controller != null) {
                    controller.activityList.showHunts = checked;
                  }
                } //onCheckedChanged
              } //TibiaCheckbox

              TibiaCheckBox {
                Layout.preferredWidth: root.TibiaStyle.teamFinderCheckBoxWidth
                text: qsTrId("teamfinder_activty_quest")
                shouldBeChecked: controller != null && controller.activityList.showQuests
                onCheckedChanged: {
                  if (controller != null) {
                    controller.activityList.showQuests = checked;
                  }
                } //onCheckedChanged
              } //TibiaCheckbox

              TibiaCheckBox {
                Layout.preferredWidth: root.TibiaStyle.teamFinderCheckBoxWidth
                text: qsTrId("teamfinder_activty_other")
                shouldBeChecked: controller != null && controller.activityList.showOther
                onCheckedChanged: {
                  if (controller != null) {
                    controller.activityList.showOther = checked;
                  }
                } //onCheckedChanged
              } //TibiaCheckbox
            } //GridLayout

            TibiaText {
              Layout.alignment: Qt.AlignRight
              visible: !root.assemblyStarted
              text: qsTrId("search") + ":"
            } //TibiaText

            TibiaTextSearchField {
              id: searchTextField
              Layout.fillWidth: true
              visible: !root.assemblyStarted
              shouldBeText: controller != null ? controller.activityList.nameFilter : ""

              onSearchTextChanged: {
                if (controller != null) {
                  controller.activityList.nameFilter = searchText;
                }
              } //onSearchTextChanged
            } //TibiaTextSearchField

            TibiaText {
              Layout.alignment: Qt.AlignRight | Qt.AlignTop
              visible: root.assemblyStarted
              text: qsTrId("teamfinder_activity") + ":"
            } //TibiaText

            TibiaText {
              Layout.fillWidth: true
              visible: root.assemblyStarted
              wrapMode: Text.Wrap
              text: controller != null ? controller.activityName : ""
            } //TibiaText

            TibiaTableView {
              id: activitiesTableView
              Layout.columnSpan: 2
              Layout.fillWidth: true
              Layout.fillHeight: true

              visible: !root.assemblyStarted
              model: controller != null ? controller.activityList : null

              property bool __preventInitialSelection: false
              onModelChanged: {
                __preventInitialSelection = true;
              } //onModelChanged

              selection.onSelectionChanged: {
                if (__preventInitialSelection && selection.count > 0) {
                  currentRow = -1;
                  selection.clear();
                  __preventInitialSelection = false;
                }
              } //selection.onSelectionChanged

              onRowCountChanged: {
                currentRow = -1;
                selection.clear();
              } //onRowCountchanged

              TableViewColumn {
                role: "name"
                width: activitiesTableView.contentItem.width - aliasColumn.width

                delegate: RowLayout {
                  id: displayNameLayout
                  anchors.fill: parent
                  spacing: TibiaStyle.marginRelated

                  TibiaText {
                    Layout.leftMargin: TibiaStyle.marginNarrow
                    styleType: "WhiteCaption"
                    text: model ? model.typeName : qsTrId("dummy_unknown")
                  } // TibiaText

                  TibiaText {
                    Layout.fillWidth: true
                    styleType: styleData.selected ? "TextFieldTextSelected" : "TextFieldText"
                    text: model ? model.name : qsTrId("dummy_unknown")
                  } // TibiaText
                } //delegate: RowLayout
              } //TableViewColumn

              TableViewColumn {
                id: aliasColumn
                role: "alias"
                width: 12 + TibiaStyle.marginNarrow

                delegate: RowLayout {
                  anchors.fill: parent
                  TibiaGuiHelp {
                    text: styleData.value
                    visible: text.length > 0
                  } //TibiaGuiHelp
                } //delegate: RowLayout
              } //TableViewColumn
            } //TibiaTableView

            TibiaCheckBox {
              id: includePartyCheckBox
              Layout.columnSpan: 2
              Layout.fillWidth: true

              visible: !root.assemblyStarted
              text: qsTrId("teamfinder_include_party")
              enabled: controller != null && controller.isInParty
              shouldBeChecked: teamSettings != null && teamSettings.includeParty && enabled
            } //TibiaCheckBox

            RowLayout {
              Layout.columnSpan: 2
              spacing: TibiaStyle.marginRelated

              visible: root.hasPremium && !root.assemblyStarted

              Item {
                Layout.fillWidth: true
              } //Item

              TibiaButton {
                id: startTeamButton
                Layout.preferredWidth: TibiaStyle.buttonWidthWidest
                KeyNavigation.tab: minLevelTextField

                enabled: activitiesTableView.currentRow != -1

                text: qsTrId("teamfinder_start_team")

                onClicked: {
                  root.forwordTeamSettingsToController();
                  if (controller != null) {
                    controller.onStartAssembleTeamClicked(activitiesTableView.currentRow);
                  }
                } //onClicked
              } //TibiaButton
            } //RowLayout

            RowLayout {
              Layout.columnSpan: 2
              spacing: TibiaStyle.marginRelated

              visible: root.hasPremium && root.assemblyStarted

              Item {
                Layout.fillWidth: true
              } //Item

              TibiaButton {
                Layout.preferredWidth: TibiaStyle.buttonWidthWidest

                text: qsTrId("teamfinder_upate_team_settings")

                onClicked: {
                  root.forwordTeamSettingsToController();
                  if (controller != null) {
                    controller.onUpdateTeamSettingsClicked();
                  }
                } //onClicked
              } //TibiaButton
            } //RowLayout

            RowLayout {
              Layout.columnSpan: 2
              spacing: TibiaStyle.marginRelated

              visible: root.assemblyStarted

              Item {
                Layout.fillWidth: true
              } //Item

              TibiaButton {
                id: unlistTeamButton
                Layout.preferredWidth: TibiaStyle.buttonWidthWidest
                KeyNavigation.tab: minLevelTextField

                text: qsTrId("teamfinder_unlist_team")

                onClicked: {
                  if (controller != null) {
                    controller.onUnlistTeamClicked();
                  }
                } //onClicked
              } //TibiaButton
            } //RowLayout

            RowLayout {
              id: premiumStateLayout
              Layout.columnSpan: 2
              spacing: TibiaStyle.marginRelated

              visible: !root.hasPremium

              TibiaText {
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter

                text:  qsTrId("teamfinder_premium_required")
              } //TibiaText

              TibiaPremiumStateButton {
                hasPremium: root.hasPremium

                onClicked: controller ? controller.getPremiumClicked() : undefined
              } //TibiaPremiumStateButton
            } //RowLayout

            Item {
              Layout.columnSpan: 2
              Layout.fillWidth: true
              Layout.fillHeight: true
              visible: root.assemblyStarted
            } //Item
          } //GridLayout
        } //FocusScope
      } //TibiaFrame2PixelUpFilledWithCaption

      TibiaFrame2PixelUpFilledWithCaption {
        Layout.fillWidth: true
         Layout.preferredHeight: assembleteamInfoText.height + topMarginToContent + marginsToContent
        visible: root.assemblyStarted
        caption: qsTrId("info")

        TibiaText {
          id: assembleteamInfoText
          anchors { left: parent.left; top: parent.top; right: parent.right }
          anchors.margins: parent.marginsToContent
          anchors.topMargin: parent.topMarginToContent
          wrapMode: Text.Wrap
          text: qsTrId("teamfinder_assembleteam_info")
        } //TibiaText
      } //TibiaFrame2PixelUpFilledWithCaption
    } //ColumnLayout

    TibiaFrame2PixelUpFilledWithCaption {
      Layout.fillWidth: true
      Layout.fillHeight: true

      caption: qsTrId("teamfinder_team")

      GridLayout {
        id: activityLayout
        anchors.fill: parent
        anchors.margins: parent.marginsToContent
        anchors.topMargin: parent.topMarginToContent

        columns: 2
        rowSpacing: TibiaStyle.marginRelated
        columnSpacing: TibiaStyle.marginRelated

        TibiaText {
          Layout.alignment: Qt.AlignRight | Qt.AlignTop
          text: qsTrId("teamfinder_composition") + ":"
        } //TibiaText

        GridLayout {
          columns: 4
          rowSpacing: TibiaStyle.marginRelated
          columnSpacing: TibiaStyle.marginRelated

          TibiaText {
            Layout.preferredWidth: TibiaStyle.threeDigitTextSize
            horizontalAlignment: Text.AlignRight
            text: controller != null ? controller.teamMembers.countDruid : "0"
          } //TibiaText

          TibiaText {
            text: "x " + qsTrId("druid")
          } //TibiaText

          TibiaText {
            Layout.preferredWidth: TibiaStyle.threeDigitTextSize
            horizontalAlignment: Text.AlignRight
            text: controller != null ? controller.teamMembers.countKnight : "0"
          } //TibiaText

          TibiaText {
            text: "x " + qsTrId("knight")
          } //TibiaText

          TibiaText {
            Layout.preferredWidth: TibiaStyle.threeDigitTextSize
            horizontalAlignment: Text.AlignRight
            text: controller != null ? controller.teamMembers.countPaladin : "0"
          } //TibiaText

          TibiaText {
            text: "x " + qsTrId("paladin")
          } //TibiaText

          TibiaText {
            Layout.preferredWidth: TibiaStyle.threeDigitTextSize
            horizontalAlignment: Text.AlignRight
            text: controller != null ? controller.teamMembers.countSorcerer : "0"
          } //TibiaText

          TibiaText {
            text: "x " + qsTrId("sorcerer")
          } //TibiaText

          TibiaText {
            Layout.preferredWidth: TibiaStyle.threeDigitTextSize
            horizontalAlignment: Text.AlignRight
            text: controller != null ? controller.teamMembers.countMonk : "0"
          } //TibiaText

          TibiaText {
            text: "x " + qsTrId("monk")
          } //TibiaText

          TibiaText {
            Layout.alignment: Qt.AlignRight
            visible: root.externalMembers > 0
            text: root.externalMembers
          } //TibiaText

          TibiaText {
            visible: root.externalMembers > 0
            text: "x " + qsTrId("any")
          } //TibiaText
        } //GridLayout

        TibiaText {
          Layout.alignment: Qt.AlignRight
          text: qsTrId("teamfinder_status") + ":"
        } //TibiaText

        RowLayout {
          spacing: TibiaStyle.marginUnrelated

          RowLayout {
            spacing: TibiaStyle.marginNarrow

            TibiaText {
              Layout.preferredWidth: TibiaStyle.threeDigitTextSize
              horizontalAlignment: Text.AlignRight
              text: controller != null ? controller.teamMembers.countAccepted : "0"
            } //TibiaText

            TibiaText {
              visible: root.externalMembers > 0
              text: "+"
            } //TibiaText

            TibiaText {
              visible: root.externalMembers > 0
              text: root.externalMembers
            } //TibiaText

            TibiaText {
              visible: teamSettings != null && teamSettings.teamSize > 0
              text: "/"
            } //TibiaText

            TibiaText {
              visible: teamSettings != null && teamSettings.teamSize > 0
              text: teamSettings != null ? teamSettings.teamSize : "0"
            } //TibiaText

            TibiaTeamFinderStatus {
              teamStatus: TibiaEnums.TeamFinderStatusAccepted
            } //TibiaTeamFinderStatus
          } //RowLayout

          RowLayout {
            spacing: TibiaStyle.marginNarrow

            TibiaText {
              horizontalAlignment: Text.AlignRight
              text: controller != null ? controller.teamMembers.countInvited : "0"
            } //TibiaText

            TibiaTeamFinderStatus {
              teamStatus: TibiaEnums.TeamFinderStatusInvited
            } //TibiaTeamFinderStatus
          } //RowLayout

          RowLayout {
            spacing: TibiaStyle.marginNarrow

            TibiaText {
              horizontalAlignment: Text.AlignRight
              text: controller != null ? controller.teamMembers.countPending : "0"
            } //TibiaText

            TibiaTeamFinderStatus {
              teamStatus: TibiaEnums.TeamFinderStatusRequest
            } //TibiaTeamFinderStatus
          } //RowLayout

          RowLayout {
            spacing: TibiaStyle.marginNarrow

            TibiaText {
              horizontalAlignment: Text.AlignRight
              text: controller != null ? controller.teamMembers.countRejected : "0"
            } //TibiaText

            TibiaTeamFinderStatus {
              teamStatus: TibiaEnums.TeamFinderStatusRejected
            } //TibiaTeamFinderStatus
          } //RowLayout
        } //RowLayout

        TibiaTableView {
          id: teamTableView
          Layout.fillWidth: true
          Layout.fillHeight: true
          Layout.columnSpan: 2

          KeyNavigation.tab: teamTableView
          KeyNavigation.backtab: teamTableView

          model: controller != null ? controller.teamMembers : null

          headerVisible: true

          TableViewColumn {
            id: columnName
            title: qsTrId("name")
            role: "name"
            resizable: false
            movable: false
            width: teamTableView.contentItem.width - columnLevel.width
                                                   - columnVocation.width
                                                   - columnStatus.width
            delegate : Item {
              RowLayout {
                anchors { left: parent.left; right: separator.left }
                anchors.margins: TibiaStyle.marginNarrow
                spacing: TibiaStyle.marginNarrow

                TibiaText {
                  Layout.maximumWidth: parent.width
                                    - (leaderIcon.visible? (leaderIcon.width + parent.spacing) : 0)
                  styleType: styleData.selected ? "TextFieldTextSelected" : "TextFieldText"

                  text: model ? model.name : ""
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
            id: columnLevel
            title: qsTrId("level")
            role: "level"
            resizable: false
            movable: false
            width: 50
            delegate : RowLayout {
              spacing: TibiaStyle.marginNarrow

              TibiaText {
                Layout.leftMargin: TibiaStyle.marginNarrow
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter | Qt.AlignTop
                styleType: styleData.selected ? "TextFieldTextSelected" : "TextFieldText"
                text: model ? model.level : ""
                horizontalAlignment: Text.AlignRight
              } //TibiaText

              TibiaVerticalSeparator {
                Layout.fillHeight: true
              } // TibiaVerticalSeparator
            } //delegate : RowLayout
          } //TableViewColumn

          TableViewColumn {
            id: columnVocation
            title: qsTrId("vocation")
            role: "vocationString"
            resizable: false
            movable: false
            width: 80
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
                visible: styleData.selected && model && !model.isLeader

                onClicked: {
                  if (controller != null && model) {
                    controller.onEditMemberStatusClicked(model.characterId, model.status);
                  }
                } //onClicked
              } // TibiaButton
            } //delegate: Item
          } //TableViewColumn

          TibiaText {
            anchors.centerIn: parent
            visible: teamTableView.rowCount == 0
            horizontalAlignment: Text.AlignHCenter
            text: qsTrId("teamfinder_no_team");
          } //TibiaText
        } //TibiaTableView
      } //GridLayout
    } //TibiaFrame2PixelUpFilledWithCaption
  } //RowLayout
} //ColumnLayout
