import QtQuick
import QtQuick.Layouts

import qmlcomponents
import QtQuick.LegacyControls

RowLayout {
  id: root
  spacing: TibiaStyle.marginUnrelated

  implicitHeight: skillWheel.implicitHeight
  implicitWidth: 928

  property var controller
  property var activeTab: 0 //0=Selection, 1=Manage Presets

  property bool isPremium: false

  readonly property bool fullSummary: controller != null && controller.showFullSummary
  readonly property int widthForBars: width - skillWheel.width - 2 * spacing

  ColumnLayout {
    id: leftBarLayout
    Layout.fillHeight: true
    Layout.fillWidth: true
    Layout.maximumWidth: Math.floor(root.widthForBars * 0.5)
    spacing: TibiaStyle.marginRelated

    TibiaFrame2PixelUpFilledWithCaption {
      Layout.fillWidth: true
      Layout.fillHeight: true
      caption: qsTrId("skill_wheel_dialog_caption_selection")

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: parent.marginsToContent
        anchors.topMargin: parent.topMarginToContent
        spacing: TibiaStyle.marginRelated

        ColumnLayout {
          Layout.fillWidth: true
          Layout.fillHeight: true
          spacing: TibiaStyle.marginRelated

          SkillWheelLargePerkInformation {
            id: selectedLargePerkLayout
            visible: skillWheel.selectedLargePerkQuarter != null

            hoverMode: false
            informationSet: controller != null ? controller.selectedLargePerkInformation : null
          } //SkillWheelLargePerkInformation

          SkillWheelTileInformation {
            id: selectedTileLayout
            Layout.fillWidth: true
            visible: skillWheel.selectedSkillId != null

            informationSet: controller != null ? controller.selectedTileInformation : null
            hoverMode: false
            isLocalPlayer: controller != null && controller.isLocalPlayer
            isPremium: root.isPremium
            canBeDecreased: controller != null && controller.canBeDecreased
            canBeIncreased: controller != null && controller.canBeIncreased
            spentSkillPoints: controller != null ? controller.spentSkillPoints : 0
            totalSkillPoints: controller != null ? controller.totalSkillPoints : 0

            onClearSkillClicked: {
              if (controller != null && skillWheel.selectedSkillId != null) {
                controller.clearSkill(skillWheel.selectedSkillId);
              }
            } //onClearSkillClicked

            onRemoveFromSkillClicked: (keyboardModifiers) => {
              if (controller != null && skillWheel.selectedSkillId != null) {
                controller.removeFromSkill(skillWheel.selectedSkillId, keyboardModifiers);
              }
            } //onRemoveFromSkillClicked

            onAddToSkillClicked: (keyboardModifiers) => {
              if (controller != null && skillWheel.selectedSkillId != null) {
                controller.addToSkill(skillWheel.selectedSkillId, keyboardModifiers);
              }
            } //onAddToSkillClicked

            onFillSkillClicked: {
              if (controller != null && skillWheel.selectedSkillId != null) {
                controller.fillSkill(skillWheel.selectedSkillId);
              }
            } //onFillSkillClicked
          } //SkillWheelTileInformation

          SkillWheelVesselInformation {
            id: selectedVesselLayout
            visible: skillWheel.selectedVesselQuarter != null

            hoverMode: false
            isLocalPlayer: controller != null && controller.isLocalPlayer
            informationSet: controller != null ? controller.selectedVesselInformation : null

            onChangeGemClicked: {
              if (controller != null && skillWheel.selectedVesselQuarter != null) {
                controller.changedGem(skillWheel.selectedVesselQuarter);
              }
            } //onChangeGemClicked
          } //SkillWheelVesselInformation
        } //ColumnLayout

        TibiaHorizontalSeparator {
          Layout.fillWidth: true
        } //TibiaHorizontalSeparator

        TibiaText {
          id: promotionPointsText
          Layout.fillWidth: true
          Layout.alignment: Qt.AlignHCenter
          horizontalAlignment: Text.AlignHCenter
          readonly property int spentSkillPoints: controller != null ? controller.spentSkillPoints : 0
          readonly property int totalSkillPoints: controller != null ? controller.totalSkillPoints : 0
          readonly property string bonusPointItemNames: controller != null ? controller.bonusPointItemNames : ""
          text: qsTrId("skill_wheel_skill_promotion_points_captions")
            + "<br>"
            + qsTrId("count_slash_total")
            .arg(TextHelper.formatNumberWithThousandSeparators(totalSkillPoints - spentSkillPoints))
            .arg(TextHelper.formatNumberWithThousandSeparators(totalSkillPoints))
          tooltipUseRichText: true
          tooltipText: qsTrId("skill_wheel_skill_promotion_points_header_tooltip")
            .arg(TextHelper.formatNumberWithThousandSeparators(controller != null ? controller.regularSkillPoints : 0))
            .arg(TextHelper.formatNumberWithThousandSeparators(controller != null ? controller.modGradesSkillPoints : 0))
            .arg(TextHelper.formatNumberWithThousandSeparators(controller != null ? controller.totalModGradesSkillPoints : 0))
            .arg(TextHelper.formatNumberWithThousandSeparators(controller != null ? controller.specialSkillPoints : 0))
              + (controller != null && controller.hasShrinesOfInsightBonusPoints || bonusPointItemNames.length
                 ? ":"
                 : ".")
              + (controller != null && controller.hasShrinesOfInsightBonusPoints
                  ? qsTrId("skill_wheel_skill_promotion_points_bonus_shrines_of_insight_tooltip")
                  : "")
              + (bonusPointItemNames.length > 0
                 ? qsTrId("skill_wheel_skill_promotion_points_bonus_items_tooltip").arg(bonusPointItemNames)
                 : "")
              + (controller != null && controller.huntingTaskSkillPoints > 0
                 ? qsTrId("skill_wheel_skill_promotion_points_hunting_task_shop_tooltip").arg(controller.huntingTaskSkillPoints)
                 : "")
        } //TibiaText
      } //ColumnLayout
    } //TibiaFrame2PixelUpFilledWithCaption

    TibiaFrame2PixelUpFilled {
      Layout.fillWidth: true
      Layout.preferredHeight: 267 //exact hight needed to show 10 presets without scrolling

      TibiaDialogTabBar {
        id: tabBar
        anchors { left: parent.left; top: parent.top; right: parent.right }
        anchors.margins: parent.borderWidth

        activeTabId: root.activeTab
        tabShortcutsActive: false

        compactStyle: true
        fillWithCurrentTab: true

        onRequestedTabIdChanged:{
          if (controller != null && activeTabId != requestedTabId) {
            root.activeTab = requestedTabId;
          }
        } //onRequestedTabIdChanged

        readonly property bool canManagePresets: controller != null
          && controller.isLocalPlayer
          && controller.canBeDecreased

        tabModel: [
          {
            "tabId": 0,
            "caption": qsTrId("skill_wheel_dialog_caption_information"),
            "tooltip": qsTrId("skill_wheel_dialog_caption_information"),
            "icon": "/images/skillwheel/icon-skillwheel-selection.png"
          }
          , {
            "tabId": 1,
            "caption": qsTrId("manage_presets_caption"),
            "tooltip": qsTrId("manage_presets_caption"),
            "icon": "/images/skillwheel/icon-skillwheel-presets.png",
            "disabled": !canManagePresets,
            "disabledTooltip": qsTrId("skill_wheel_dialog_no_manage_presets_tooltip")
          }
        ] //tabModel
      } //TibiaDialogTabBar

      Loader {
        id: tabContentLoader
        anchors { left: parent.left; top: tabBar.bottom; right: parent.right; bottom: parent.bottom}
        anchors.margins: parent.borderWidth
        anchors.topMargin: 0

        sourceComponent: switch (root.activeTab) {
          case 0: informationComponent; break;
          case 1: managePresetsComponent; break;
          default: undefined; break;
        } //sourceComponent

        Component {
          id: informationComponent

          Item {
            ColumnLayout {
              anchors.fill: parent
              anchors.margins: TibiaStyle.marginRelated
              spacing: 0

              SkillWheelLargePerkInformation {
                id: hoveredLargePerkLayout
                visible: skillWheel.hoveredLargePerkQuarter != null

                hoverMode: true
                informationSet: controller != null ? controller.hoveredLargePerkInformation : null
              } //SkillWheelLargePerkInformation

              SkillWheelTileInformation {
                id: hoveredTileLayout
                Layout.fillWidth: true
                visible: skillWheel.hoveredSkillId != null

                informationSet: controller != null ? controller.hoveredTileInformation : null
                hoverMode: true
                isLocalPlayer: controller != null && controller.isLocalPlayer
                isPremium: root.isPremium
                canBeDecreased: controller != null && controller.canBeDecreased
                canBeIncreased: controller != null && controller.canBeIncreased
                spentSkillPoints: controller != null ? controller.spentSkillPoints : 0
                totalSkillPoints: controller != null ? controller.totalSkillPoints : 0
              } //SkillWheelTileInformation

              SkillWheelVesselInformation {
                id: hoveredVesselLayout
                visible: skillWheel.hoveredVesselQuarter != null

                hoverMode: true
                isLocalPlayer: controller != null && controller.isLocalPlayer
                informationSet: controller != null ? controller.hoveredVesselInformation : null
              } //SkillWheelVesselInformation

              TibiaText {
                id: specialInfoText
                Layout.fillWidth: true
                Layout.fillHeight: true
                wrapMode: Text.Wrap
                styleType: "MessageWarning"

                visible: !hoveredLargePerkLayout.visible
                      && !hoveredTileLayout.visible
                      && !hoveredVesselLayout.visible

                text: {
                  let retValue = "";
                  if (controller != null) {
                    if (!controller.isLocalPlayer) {
                      retValue = qsTrId("skill_wheel_dialog_inspecting_info").arg(controller.playerName);
                      styleType = "MessageWarning";
                    } else if (controller.isLocalPlayer && !root.isPremium) {
                      retValue = qsTrId("skill_wheel_dialog_no_premim_info");
                      styleType = "MessageWarning";
                    } else {
                      retValue = qsTrId("skill_wheel_dialog_right_click_fillorreset_hint")
                        + "\n\n" + qsTrId("skill_wheel_dialog_right_click_fillorreset_stepsize_hint")
                      styleType = "Dialog";
                    }
                  }
                  return retValue;
                } //text
              } //TibiaText
            } //ColumnLayout
          } //Item
        } //Component

        Component {
          id: managePresetsComponent

          ColumnLayout {
            spacing: TibiaStyle.marginNarrow

            GridLayout {
              Layout.alignment: Qt.AlignHCenter
              Layout.topMargin: TibiaStyle.marginRelated
              Layout.leftMargin: TibiaStyle.marginRelated
              Layout.rightMargin: TibiaStyle.marginRelated
              columns: 3
              columnSpacing: TibiaStyle.marginNarrow
              rowSpacing: TibiaStyle.marginNarrow

              Item {
                Layout.fillWidth: true
                Layout.preferredHeight: newPresetButton.height
                implicitWidth: newPresetButton.implicitWidth

                TibiaButton {
                  id: newPresetButton
                  anchors.left: parent.left
                  anchors.right: parent.right
                  text: qsTrId("new");
                  enabled: controller != null && controller.morePresetsPossible
                  onClicked: controller != null ? controller.requestNewPresetClicked() : undefined
                } //TibiaButton

                Tooltip {
                  anchors.fill: parent
                  maxWidth: TibiaStyle.guiHelpTooltipWidth

                  enabled: !newPresetButton.enabled
                  text: qsTrId("skill_wheel_dialog_max_presets_tooltip")
                } //Tooltip
              } //Item

              TibiaButton {
                Layout.fillWidth: true
                text: qsTrId("rename")
                enabled: controller != null && !controller.isPresetDirty
                onClicked: controller != null ? controller.requestRenamePresetClicked() : undefined
              } //TibiaButton

              Item {
                Layout.fillWidth: true
                Layout.preferredHeight: deletePresetButton.height

                TibiaButton {
                  id: deletePresetButton
                  anchors.left: parent.left
                  anchors.right: parent.right
                  text: qsTrId("delete")
                  enabled: controller != null && controller.deletePresetsPossible
                  onClicked: controller != null ? controller.requestDeletePresetClicked() : undefined
                } //TibiaButton

                Tooltip {
                  anchors.fill: parent
                  maxWidth: TibiaStyle.guiHelpTooltipWidth

                  enabled: !deletePresetButton.enabled
                  text: qsTrId("skill_wheel_dialog_last_prest_no_delete_tooltip")
                } //Tooltip
              } //Item

              Item {
                Layout.fillWidth: true
                Layout.preferredHeight: applyPresetButton.height

                TibiaButton {
                  id: applyPresetButton
                  anchors.left: parent.left
                  anchors.right: parent.right
                  text: qsTrId("apply")
                  tooltipText: qsTrId("skill_wheel_dialog_save_preset_tooltip")
                  enabled: controller != null && controller.isPresetDirty
                  onClicked: onApplyPressedFunction()
                } //TibiaButton

                Tooltip {
                  anchors.fill: parent
                  maxWidth: TibiaStyle.guiHelpTooltipWidth

                  enabled: !applyPresetButton.enabled
                  text: qsTrId("skill_wheel_dialog_no_changes")
                } //Tooltip
              } //Item

              Item {
                Layout.fillWidth: true
                Layout.preferredHeight: importPresetButton.height

                TibiaButton {
                  id: importPresetButton
                  anchors.left: parent.left
                  anchors.right: parent.right
                  text: qsTrId("import")
                  enabled: controller != null && controller.morePresetsPossible
                  onClicked: controller != null ? controller.requestImportPresetClicked() : undefined
                } //TibiaButton

                Tooltip {
                  anchors.fill: parent
                  maxWidth: TibiaStyle.guiHelpTooltipWidth

                  enabled: !importPresetButton.enabled
                  text: qsTrId("skill_wheel_dialog_max_presets_tooltip")
                } //Tooltip
              } //Item

              TibiaButton {
                Layout.fillWidth: true
                text: qsTrId("export")
                onClicked: controller != null ? controller.requestExportPresetClicked() : undefined
              } //TibiaButton
            } //GridLayout

            TibiaTableView {
              id: presetTable
              Layout.fillWidth: true
              Layout.fillHeight: true

              headerVisible: true
              alternatingRowColors: true
              verticalScrollBarPolicy: Qt.ScrollBarAsNeeded
              selectionMode: SelectionMode.NoSelection

              model: controller != null ? controller.presetsInfoModel : null

              onClicked: (row) => {
                if (   presetTable.model
                    && rowCount > row
                    && controller != null) {
                  let idx = presetTable.model.index(row, 0);
                  let presetName = presetTable.model.data(idx, presetTable.model.nameEnumValue);
                  controller.selectPresetByName(presetName, false);
                }
              } //onClicked

              readonly property var _shouldBeSelectedPresetName: controller != null ? controller.currentPresetName : ""
              on_ShouldBeSelectedPresetNameChanged: selectRowForPresetName()
              onRowCountChanged: selectRowForPresetName()

              function selectRowForPresetName() {
                let newCurrentIndex = -1;

                if (presetTable.model != null) {
                  for (var i=0; i < presetTable.rowCount; i++) {
                    let idx = presetTable.model.index(i, 0);
                    let presetName = presetTable.model.data(idx, presetTable.model.nameEnumValue);

                    if (presetName == _shouldBeSelectedPresetName) {
                      newCurrentIndex = i;
                      break;
                    }
                  }
                }

                presetTable.selection.clear();
                if (newCurrentIndex != -1) {
                  presetTable.selection.select(newCurrentIndex);
                }
              } //function selectRowForPresetName

              TableViewColumn {
                id: nameColumn
                role: "name"
                title: qsTrId("name")
                width: presetTable.contentItem.width
                  - pointsColumn.width
                movable: false
                resizable: false
              } //TableViewColumn

              TableViewColumn {
                id: pointsColumn
                role: "availablePoints"
                title: qsTrId("skill_wheel_skill_promotion_available_captions")
                width: 48
                movable: false
                resizable: false
                horizontalAlignment: Text.AlignRight
              } //TableViewColumn
            } //TibiaTableView
          } //ColumnLayout
        } //Component
      } //Loader
    } //TibiaFrame2PixelUpFilledWithCaption
  } //ColumnLayout

  SkillWheel {
    id: skillWheel

    useBlending: controller != null ? controller.rendererSupportsGraphicEffects : false
    vocation: controller != null ? controller.vocation : TibiaEnums.Knight
    skillParameters: controller != null ? controller.skillParameters : []
    cornerParameters: controller != null ? controller.cornerParameters : []

    onSkillRightClicked: (skillId, keyboardModifiers) => {
      if (controller != null) {
        controller.onGridTileRightClicked(skillId, keyboardModifiers);
      }
    } //onSkillRightClicked

    onSelectedSkillIdChanged: {
      if (controller != null) {
        if (selectedSkillId != null) {
          controller.onGridTileSelected(selectedSkillId);
        } else {
          controller.onGridTileSelected(-1);
        }
      }
    } //onSelectedSkillIdChanged

    onHoveredSkillIdChanged: {
      if (controller != null) {
        if (hoveredSkillId != null) {
          controller.onGridTileHovered(hoveredSkillId);
        } else {
          controller.onGridTileHovered(-1);
        }
      }
    } //onSelectedSkillIdChanged

    onSelectedLargePerkQuarterChanged: {
      if (controller != null) {
        if (selectedLargePerkQuarter != null) {
          controller.onLargePerkSelected(selectedLargePerkQuarter);
        } else {
          controller.onLargePerkSelected(-1);
        }
      }
    } //onSelectedSkillIdChanged

    onHoveredLargePerkQuarterChanged: {
      if (controller != null) {
        if (hoveredLargePerkQuarter != null) {
          controller.onLargePerkHovered(hoveredLargePerkQuarter);
        } else {
          controller.onLargePerkHovered(-1);
        }
      }
    } //onSelectedSkillIdChanged

    onSelectedVesselQuarterChanged: {
      if (controller != null) {
        if (selectedVesselQuarter != null) {
          controller.onVesselSelected(selectedVesselQuarter);
        } else {
          controller.onVesselSelected(-1);
        }
      }
    } //onSelectedSkillIdChanged

    onHoveredVesselQuarterChanged: {
      if (controller != null) {
        if (hoveredVesselQuarter != null) {
          controller.onVesselHovered(hoveredVesselQuarter);
        } else {
          controller.onVesselHovered(-1);
        }
      }
    } //onSelectedSkillIdChanged
  } //SkillWheel

  ColumnLayout {
    id: rightBarLayout
    Layout.fillHeight: true
    Layout.fillWidth: true
    spacing: 0

    Component {
      id: summaryComponent

      RowLayout {
        anchors { left: parent != null ? parent.left : undefined; right: parent != null ? parent.right : undefined}
        spacing: 0

        RowLayout {
          spacing: TibiaStyle.marginRelated
          visible: !model.isSeparator

          Image {
            source: model.imageSource
          }

          TibiaText {
            Layout.fillWidth: true
            text: model.lable
          } // TibiaText

          TibiaText {
            horizontalAlignment: Text.AlignRight
            text: model.effekt
          } // TibiaText

          TibiaGuiHelp {
            enabled: text.length > 0
            opacity: enabled ? 1 : 0
            useRichText: true

            text: model.additionalInfo
          } //TibiaGuiHelp
        } //RowLoayout

        TibiaHorizontalSeparator {
          Layout.fillWidth: true
          Layout.topMargin: TibiaStyle.marginNarrow
          Layout.bottomMargin: TibiaStyle.marginNarrow
          visible: model.isSeparator
        } // TibiaHorizontalSeparator
      } // RowLayout
    } //Component

    TibiaFrame2PixelUpFilledWithCaption {
      Layout.fillWidth: true
      Layout.fillHeight: true
      caption: qsTrId("skill_wheel_summary")
      visible: root.fullSummary

      TibiaGuiHelp {
          enabled: text.length > 0
          opacity: enabled ? 1 : 0
          anchors { right: summaryButton.left; top: parent.top}
          anchors.topMargin: TibiaStyle.marginNarrow + 1
          anchors.rightMargin: TibiaStyle.marginNarrow

          text: qsTrId("skill_wheel_cooldown_limit_info")
        } //TibiaGuiHelp

      TibiaButton {
        id: summaryButton
        anchors { top:parent.top; right: parent.right }
        anchors.margins: parent.borderWidth
        height: parent.captionHeight - parent.borderWidth -1
        width: height
        tooltipText: qsTrId("skill_wheel_show_split_summary_info")

        checkable: true
        useButtonShouldBeChecked: true
        buttonShouldBeChecked: root.fullSummary
        imageSourceUp: "/images/icon-summary.png"

        onClicked: {
          if (controller != null) {
            controller.setShowFullSummary(false);
          }
        } //onClicked
      } //TibiaButton


      TibiaScrollView {
        id: summaryScrollView
        anchors.fill: parent
        anchors.topMargin: parent.captionHeight
        anchors.bottomMargin: parent.borderWidth
        anchors.leftMargin: parent.marginsToContent
        anchors.rightMargin: parent.borderWidth

        ListView {
          id: scrolledSummaryListView
          model: controller != null ? controller.fullSummaryModel : null

          leftMargin: TibiaStyle.marginNarrow
          topMargin: TibiaStyle.marginNarrow
          rightMargin: TibiaStyle.marginNarrow
          bottomMargin: TibiaStyle.marginNarrow

          boundsBehavior: Flickable.StopAtBounds
          interactive: false //prevent flick behavior on touch screens

          spacing: TibiaStyle.marginNarrow

          header: Item {
            height: TibiaStyle.marginRelated
          } //header: Item

          footer: Item {
            height: TibiaStyle.marginRelated
          } //footer: Item

          delegate: summaryComponent
        } //ListView
      } //TibiaScrollView
    } //TibiaFrame2PixelUpFilledWithCaption

    ColumnLayout {
      id: splitSummary
      Layout.fillHeight: true
      Layout.fillWidth: true
      spacing: TibiaStyle.marginRelated
      visible: !root.fullSummary

      TibiaFrame2PixelUpFilledWithCaption {
        Layout.fillWidth: true
        Layout.preferredHeight: smallBonusesLayout.height + topMarginToContent + marginsToContent
        caption: qsTrId("skill_wheel_dialog_small_perk") + "s"

        TibiaButton {
          anchors { top:parent.top; right: parent.right }
          anchors.margins: parent.borderWidth
          height: parent.captionHeight - parent.borderWidth -1
          width: height
          tooltipText: qsTrId("skill_wheel_show_full_summary_info")

          checkable: true
          useButtonShouldBeChecked: true
          buttonShouldBeChecked: root.fullSummary
          imageSourceUp: "/images/icon-summary.png"

          onClicked: {
            if (controller != null) {
              controller.setShowFullSummary(true);
            }
          } //onClicked
        } //TibiaButton

        ColumnLayout {
          id: smallBonusesLayout
          anchors { left: parent.left; top: parent.top; right: parent.right }
          anchors.margins: parent.marginsToContent
          anchors.topMargin: parent.topMarginToContent
          spacing: TibiaStyle.marginRelated

          ListView {
            id: smallPerksList
            model: controller != null ? controller.smallPerkSummaryModel : null

            Layout.fillWidth: true
            readonly property int smallPerkEntries: 4
            Layout.preferredHeight: smallPerkEntries * TibiaStyle.defaultTextLineHeight + (smallPerkEntries-1) * spacing
            boundsBehavior: Flickable.StopAtBounds
            interactive: false //prevent flick behavior on touch screens

            spacing: TibiaStyle.marginNarrow

            delegate: RowLayout {
              width: smallPerksList.width
              spacing: TibiaStyle.marginRelated

              TibiaText {
                Layout.maximumWidth: 100
                text: model.lable
              } // TibiaText

              TibiaText {
                text: model.effekt
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
              } // TibiaText

              TibiaGuiHelp {
                enabled: text.length > 0
                opacity: enabled ? 1 : 0

                text: model.additionalInfo
              } //TibiaGuiHelp
            } // delegate: RowLayout
          } //ListView
        } //ColumnLayout
      } //TibiaFrame2PixelUpFilledWithCaption

      TibiaFrame2PixelUpFilledWithCaption {
        Layout.fillWidth: true
        Layout.fillHeight: true
        caption: qsTrId("skill_wheel_dialog_medium_perk") + "s"

        TibiaGuiHelp {
          enabled: text.length > 0
          opacity: enabled ? 1 : 0
          anchors { right: parent.right; top: parent.top}
          anchors.topMargin: TibiaStyle.marginNarrow + 1
          anchors.rightMargin: parent.borderWidth + TibiaStyle.marginNarrow

          text: qsTrId("skill_wheel_cooldown_limit_info")
        } //TibiaGuiHelp

        TibiaScrollView {
          id: mediumPerkScrollView
          anchors.fill: parent
          anchors.topMargin: parent.captionHeight
          anchors.bottomMargin: parent.borderWidth
          anchors.leftMargin: parent.marginsToContent
          anchors.rightMargin: parent.borderWidth

          visible: scrolledMediumPerkListView.contentHeight > scrolledMediumPerkListView.height

          ListView {
            id: scrolledMediumPerkListView
            model: controller != null ? controller.mediumPerkSummaryModel : null

            leftMargin: TibiaStyle.marginNarrow
            topMargin: TibiaStyle.marginNarrow
            rightMargin: TibiaStyle.marginNarrow
            bottomMargin: TibiaStyle.marginNarrow

            boundsBehavior: Flickable.StopAtBounds
            interactive: false //prevent flick behavior on touch screens

            spacing: TibiaStyle.marginNarrow

            header: Item {
              height: TibiaStyle.marginRelated
            } //header: Item

            footer: Item {
              height: TibiaStyle.marginRelated
            } //footer: Item

            delegate: summaryComponent
          } //ListView
        } //TibiaScrollView

        ColumnLayout {
          id: mediumBonusesLayout
          anchors.fill: parent
          anchors.margins: parent.marginsToContent
          anchors.topMargin: parent.topMarginToContent

          spacing: TibiaStyle.marginRelated

          visible: !mediumPerkScrollView.visible

          ListView {
            model: controller != null ? controller.mediumPerkSummaryModel : null

            Layout.fillHeight: true
            Layout.fillWidth: true

            boundsBehavior: Flickable.StopAtBounds
            interactive: false //prevent flick behavior on touch screens

            spacing: TibiaStyle.marginNarrow

            delegate: summaryComponent
          } //ListView
        } //ColumnLayout
      } //TibiaFrame2PixelUpFilledWithCaption

      TibiaFrame2PixelUpFilledWithCaption {
        Layout.fillWidth: true
        Layout.fillHeight: true
        caption: qsTrId("skill_wheel_vessel") + "s"

        TibiaGuiHelp {
          enabled: text.length > 0
          opacity: enabled ? 1 : 0
          anchors { right: parent.right; top: parent.top}
          anchors.topMargin: TibiaStyle.marginNarrow + 1
          anchors.rightMargin: parent.borderWidth + TibiaStyle.marginNarrow

          text: qsTrId("skill_wheel_cooldown_limit_info")
        } //TibiaGuiHelp

        TibiaScrollView {
          id: vesselsScrollView
          anchors.fill: parent
          anchors.topMargin: parent.captionHeight
          anchors.bottomMargin: parent.borderWidth
          anchors.leftMargin: parent.marginsToContent
          anchors.rightMargin: parent.borderWidth

          visible: scrolledVesselListView.contentHeight > scrolledVesselListView.height

          ListView {
            id: scrolledVesselListView
            model: controller != null ? controller.vesselsSummaryModel : null

            leftMargin: TibiaStyle.marginNarrow
            topMargin: TibiaStyle.marginNarrow
            rightMargin: TibiaStyle.marginNarrow
            bottomMargin: TibiaStyle.marginNarrow

            boundsBehavior: Flickable.StopAtBounds
            interactive: false //prevent flick behavior on touch screens

            spacing: TibiaStyle.marginNarrow

            header: Item {
              height: TibiaStyle.marginRelated
            } //header: Item

            footer: Item {
              height: TibiaStyle.marginRelated
            } //footer: Item

            delegate: summaryComponent
          } //ListView
        } //TibiaScrollView

        ColumnLayout {
          id: vesselBonusesLayout
          anchors.fill: parent
          anchors.margins: parent.marginsToContent
          anchors.topMargin: parent.topMarginToContent

          spacing: TibiaStyle.marginRelated

          visible: !vesselsScrollView.visible

          ListView {
            model: controller != null ? controller.vesselsSummaryModel : null

            Layout.fillHeight: true
            Layout.fillWidth: true

            boundsBehavior: Flickable.StopAtBounds
            interactive: false //prevent flick behavior on touch screens

            spacing: TibiaStyle.marginNarrow

            delegate: summaryComponent
          } //ListView
        } //ColumnLayout
      } //TibiaFrame2PixelUpFilledWithCaption

      TibiaFrame2PixelUpFilledWithCaption {
        Layout.fillWidth: true
        Layout.preferredHeight: largeBonusesLayout.height + topMarginToContent + marginsToContent
        caption: qsTrId("skill_wheel_dialog_large_perk") + "s"

        ColumnLayout {
          id: largeBonusesLayout
          anchors { left: parent.left; top: parent.top; right: parent.right }
          anchors.margins: parent.marginsToContent
          anchors.topMargin: parent.topMarginToContent
          spacing: TibiaStyle.marginRelated

          ListView {
            id: largePerkList
            model: controller != null ? controller.largePerkSummaryModel : null

            Layout.fillWidth: true
            readonly property int largePerkEntries: 5
            Layout.preferredHeight: largePerkEntries * TibiaStyle.defaultTextLineHeight + (largePerkEntries-1) * spacing
            boundsBehavior: Flickable.StopAtBounds
            interactive: false //prevent flick behavior on touch screens

            spacing: TibiaStyle.marginNarrow

            delegate: RowLayout {
              width: largePerkList.width
              spacing: TibiaStyle.marginRelated

              TibiaText {
                Layout.fillWidth: true
                text: model.lable
              } // TibiaText

              TibiaText {
                text: model.effekt
                horizontalAlignment: Text.AlignRight
              } // TibiaText

              TibiaGuiHelp {
                useRichText: true
                text: model.additionalInfo
              } //TibiaGuiHelp
            } // delegate: RowLayout
          } //ListView
        } //ColumnLayout
      } //TibiaFrame2PixelUpFilledWithCaption
    } //ColumnLayout
  } //ColumnLayout
} //RowLayout
