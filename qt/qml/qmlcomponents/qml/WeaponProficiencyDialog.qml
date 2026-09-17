import QtQuick
import QtQuick.Layouts

import qmlcomponents
import qmlenumvalues
import QtQuick.LegacyControls

TibiaDialog {
  id: root
  caption: qsTrId("weapon_proficiency_dialog_caption")

  width: 1000

  initialFocusItem: searchField
  KeyNavigation.tab: searchField
  KeyNavigation.backtab: searchField

  required property var controller
  readonly property bool currentProficiencyChanged: controller.currentProficiencyChanged
  readonly property bool hasProficiencyMastery: controller.currentProficiencyXP >= controller.masteryProficiencyXP

  onReturnPressedFunction: function() {
    if (controller != null) {
      controller.onOkClicked();
    }
  } //onReturnPressedFunction

  function onApplyPressedFunction() {
    if (controller != null) {
      controller.onApplyClicked();
    }
  } //onApplyPressedFunction

  onCancelPressedFunction: function() {
    if (controller != null) {
      controller.requestClose();
    }
  } //onCancelPressedFunction

  function weaponObjectSelected(typeID) {
    if (controller != null) {
      controller.weaponObjectSelected(typeID);
    }
  } //weaponObjectSelected

  function filterChanged (
    levelFilter: bool,
    vocationFilter: bool,
    oneHandFilter: bool,
    twoHandFilter: bool) : void {
    if (controller != null) {
      controller.setFilter(
        levelFilter,
        vocationFilter,
        oneHandFilter,
        twoHandFilter
      );
    }
  } //function filterChanged

  RowLayout {
    id: mainLayout
    anchors { left: parent.left; right: parent.right; }
    spacing: TibiaStyle.marginUnrelated

    ColumnLayout {
      id: leftSideLayout
      spacing: TibiaStyle.marginUnrelated

      readonly property int sidebarwidth: itemSelectionGrid.width

      Layout.preferredWidth: sidebarwidth
      Layout.maximumWidth: sidebarwidth

     TibiaFrame2PixelUpFilledWithCaption {
        Layout.fillWidth: true
        caption: controller.currentTypeName

        Layout.preferredHeight: itemInfoLayout.height + topMarginToContent + marginsToContent

        TibiaGuiHelp {
          id: itemInfoGuiHelp
          enabled: controller.currentTypeId != 0
          opacity: enabled ? 1 : 0
          anchors { right: itemInfoLayout.right; top: itemInfoLayout.top}
          anchors.topMargin: TibiaStyle.marginNarrow + 1
          anchors.rightMargin: parent.borderWidth + TibiaStyle.marginNarrow

          text: controller.currentInspectText
        } //TibiaGuiHelp

        ColumnLayout {
          id: itemInfoLayout
          anchors { left: parent.left; top: parent.top; right: parent.right }
          anchors.margins: parent.marginsToContent
          anchors.topMargin: parent.topMarginToContent
          spacing: TibiaStyle.marginRelated

          Image {
            source: controller.currentDecorationSource

            Image {
              source: controller.currentDecorationLevelSource
            }

            SingleObjectAppearanceInstanceRenderer {
              width: TibiaStyle.mapWindowPixelPerField
              height: TibiaStyle.mapWindowPixelPerField
              x: 76
              y: 23

              animated: true
              typeid: controller.currentTypeId
            } //SingleObjectAppearanceInstanceRenderer
          } //Image

          TibiaText {
            Layout.alignment: Qt.AlignHCenter
            text: qsTrId("count_slash_total")
              .arg(TextHelper.formatNumberWithThousandSeparators(controller.currentProficiencyXP))
              .arg(TextHelper.formatNumberWithThousandSeparators(controller.nextLevelProficiencyXP))
          } //TibiaText

          TibiaText {
            Layout.alignment: Qt.AlignHCenter
            readonly property int remainingXP: controller.nextLevelProficiencyXP
              - controller.currentProficiencyXP
            text: root.hasProficiencyMastery
              ? qsTrId("weapon_proficiency_mastery_reached")
              : qsTrId("exp_to_levelup_tooltip")
                .arg(TextHelper.formatNumberWithThousandSeparators(remainingXP))
          } //TibiaText
        } //ColumnLayout
      } //TibiaFrame2PixelUpFilledWithCaption

      RowLayout {
        id: shapingLayout

        Layout.fillWidth: true
        Layout.minimumHeight: Layout.maximumHeight
        Layout.maximumHeight: TibiaStyle.buttonHeightHigh
        spacing: TibiaStyle.marginRelated

        Item {
          Layout.fillWidth: true
          Layout.fillHeight: true

          TibiaButton {
            anchors.fill: parent

            enabled: root.controller.selectedPerkActionPossible

            textFont: TibiaStyle.defaultTextFont
            textYOffset: -7
            text: {
              let text = "<img src='%1' align='middle'> %2";
              let disabledPosfix = "";

              if (!enabled) {
                disabledPosfix = "_disabled";
              }
              if (root.controller.selectedPerkCanBeShaped) {
                text = text
                  .arg("/images/proficiency/icon_forge" + disabledPosfix + ".png")
                  .arg(qsTrId("weapon_proficiency_shape"))
              } else {
                //text = "<img src='/images/proficiency/icon_manipulation.png' align='middle'> " + qsTrId("");
                text = text
                  .arg("/images/proficiency/icon_manipulation" + disabledPosfix + ".png")
                  .arg(qsTrId("weapon_proficiency_modify"))
              }

              return text
            } //text

            onClicked: root.controller.onModifyShapeClicked()
          } //TibiaButton

          Tooltip {
            anchors.fill: parent
            enabled: !root.controller.selectedPerkActionPossible
            text: controller.selectedPerkTooltip
          } //Tooltip
        } //Item

        TibiaCurrencyView {
          id: currentCurrencyAmount
          visible: !root.controller.selectedPerkCanBeShaped
          Layout.preferredWidth: TibiaStyle.currencyViewWidthShort
          Layout.fillHeight: true
          rightAligned: false
          balance: root.controller.modifiyDustCost
          iconId: "Dust"
          tooLowBalance: !root.controller.hasEnoughDustToModify
        } //TibiaCurrencyView

        TibiaGuiHelp {
          text: controller.selectedPerkGuiHelp
        } //TibiaGuiHelp
      } //RowLayout

      ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: TibiaStyle.marginRelated

        RowLayout {
          id: filterButtonLayout
          Layout.fillWidth: true
          spacing: TibiaStyle.marginRelated

          TibiaButton {
            id: levelFilterButton
            Layout.fillWidth: true
            text: qsTrId("level")
            tooltipText:qsTrId("market_level_filter_tooltip")
            checkable: true
            useButtonShouldBeChecked: true
            buttonShouldBeChecked: root.controller.weaponObjectsModel.filterByLevel

            onClicked: {
              root.filterChanged(
                !checked,
                vocationFilterButton.checked,
                oneHandFilterButton.checked,
                twoHandFilterButton.checked);
            } //onClicked
          } // TibiaButton

          TibiaButton {
            id: vocationFilterButton
            Layout.fillWidth: true
            text: qsTrId("market_vocation_filter_button")
            tooltipText: qsTrId("market_vocation_filter_tooltip")
            checkable: true
            useButtonShouldBeChecked: true
            buttonShouldBeChecked: root.controller.weaponObjectsModel.filterByVocation

            onClicked: {
              root.filterChanged(
                levelFilterButton.checked,
                !checked,
                oneHandFilterButton.checked,
                twoHandFilterButton.checked);
            } //onClicked
          } // TibiaButton

          TibiaButton {
            id: oneHandFilterButton
            Layout.fillWidth: true
            text: qsTrId("market_onehand_filter_button")
            tooltipText: qsTrId("market_onehand_filter_tooltip")
            checkable: true
            useButtonShouldBeChecked: true
            buttonShouldBeChecked: root.controller.weaponObjectsModel.onlyOneHandWeapons

            onClicked: {
              let filter1h = !checked;
              root.filterChanged(
                levelFilterButton.checked,
                vocationFilterButton.checked,
                filter1h,
                twoHandFilterButton.checked && !(twoHandFilterButton.checked && filter1h)
              );
            } //onClicked
          } // TibiaButton

          TibiaButton {
            id: twoHandFilterButton
            Layout.fillWidth: true
            text: qsTrId("market_twohand_filter_button")
            tooltipText: qsTrId("market_twohand_filter_tooltip")
            checkable: true
            useButtonShouldBeChecked: true
            buttonShouldBeChecked: root.controller.weaponObjectsModel.onlyTwoHandWeapons

            onClicked: {
              let filter2h = !checked;
              root.filterChanged(
                levelFilterButton.checked,
                vocationFilterButton.checked,
                oneHandFilterButton.checked && !(oneHandFilterButton.checked && filter2h),
                filter2h);
            } //onClicked
          } // TibiaButton
        } // RowLayout

        TibiaComboBox {
          id: weaponTypesCB
          Layout.fillWidth: true

          model: controller.weaponTypes
          textRole: "text"
          valueRole: "anyWeaponIdentifier"
          shouldBeCurrentIndex: controller.weaponTypesIndex
          onActivated: (index) => {
            controller.setWeaponTypeFilter(model[index].anyWeaponIdentifier)
          } //onActivated
        } //TibiaComboBox

        TibiaTextSearchField {
          id: searchField
          Layout.fillWidth: true
          maximumLength: TibiaStyle.maxCharacterNameLength

          KeyNavigation.tab: searchField
          KeyNavigation.backtab: searchField

          onSearchTextChanged: {
            controller.setNameFilter(searchText);
          } //onSearchTextChanged

          Keys.onEnterPressed: (event) => {
            event.accepted = true
          }
          Keys.onReturnPressed: (event) => {
            event.accepted = true
          }
        } //TibiaTextSearchField

        TibiaItemSelectionGrid {
          id: itemSelectionGrid
          Layout.fillHeight: true
          horizontalItemCount: 5
          typeNameAsTooltip: true
          showProficiencyLevel: true

          model: root.controller.weaponObjectsModel
          selectedTypeID: controller.currentTypeId

          //avoid FPS drops when scrolling large lists
          //Magic number 650 roughly matches the current number of weapons, but using count is a binding loop some reason
          //cacheBufferRows: Math.ceil(650 / horizontalItemCount)

          // this leads to lag when opening the dialog. so we reduce the number of cached rows
          cacheBufferRows: 2

          Component.onCompleted: {
            clicked.connect(root.weaponObjectSelected);
          } //Component.onCompleted
        } //TibiaItemSelectionGrid
      } //ColumnLayout
    } //ColumnLayout

    ColumnLayout {
      Layout.fillWidth: true
      Layout.preferredHeight: 490
      spacing: TibiaStyle.marginUnrelated

      ColumnLayout {
        id: treeProgressLayout
        Layout.alignment: Qt.AlignHCenter
        spacing: TibiaStyle.marginRelated

        TibiaProgressBarSegmented {
          id: levelProgress
          Layout.fillWidth: true

          barHeight: TibiaStyle.progressBarLargeHeight

          backgroundSource: "/images/progressbar-grey-18px.png"
          fillSourceInProgress: "/images/progressbar-teal-18px.png"
          fillSourceFull: fillSourceInProgress

          model: controller.proficiencyModel
          maxSegmentCount: controller.maxProficiencyLevels
          totalProgress: controller.currentProficiencyXP
          thresholdRole: "neededXP"

          segmentTooltipFunction: function(segmentInfo) {
            return qsTrId("count_slash_total")
              .arg(TextHelper.formatNumberWithThousandSeparators(segmentInfo.totalProgress))
              .arg(TextHelper.formatNumberWithThousandSeparators(segmentInfo.max))
          } //segmentTooltipFunction

          segmentDecorationDelegate: Item {
            id: decorationRoot
            property QtObject segmentInfo: null
            Image {
              anchors.centerIn: parent
              source: decorationRoot.segmentInfo.unlocked
                ? (root.hasProficiencyMastery ? "/images/icon-star-active.png" : "/images/icon-star-silver.png")
                : "/images/icon-star-dark.png"
            } //Image
          } //segmentDecorationDelegate
        } //TibiaProgressBarSegmented

        TibiaProgressBar {
          Layout.fillWidth: true
          Layout.preferredHeight: TibiaStyle.progressBarSmallHeight
          fillPercentage:  controller.currentProficiencyXP / controller.masteryProficiencyXP

          frameSource: "/images/1pixel-down-frame.png"
          backgroundSource: "/images/progressbar-grey-12px.png"
          fillSource: "/images/progressbar-lightgreen-12px.png"

          frameBorder { left: 1; right: 1; top:1; bottom: 1}
          fillOffset { left: 1; right: 1; top:1; bottom: 1}

          Tooltip {
            anchors.fill: parent
            text: qsTrId("count_slash_total")
              .arg(TextHelper.formatNumberWithThousandSeparators(controller.currentProficiencyXP))
              .arg(TextHelper.formatNumberWithThousandSeparators(controller.masteryProficiencyXP))
          } // Tooltip
        } //TibiaProgressBar

      } //ColumnLayout

      Item {
        Layout.fillHeight: true
        Layout.fillWidth: true

        RowLayout {
          id: levelClumnsLayout
          anchors.fill:parent
          spacing: levelProgress.spacing

          component LevelLayout: ColumnLayout {
            id: componentRoot

            property double fillPercentage: 0.0
            property alias descriptionText: descriptionText.text
            property int levelIndex: 0
            property var perks
            property bool perkSelected: false
            property bool hasServerSelectedPerk: false
            property bool isFillerSlot: false
            readonly property bool canEditPerksForLevel: fillPercentage == 1.0 &&
                                                         (!hasServerSelectedPerk || controller.canEditPerks)

            spacing: TibiaStyle.marginUnrelated

            TibiaFrame1PixelDown {
              id: perkSelection
              Layout.fillHeight: true
              Layout.fillWidth: true

              BorderImage {
                anchors.fill: parent
                anchors.margins: parent.borderWidth

                source: "/images/background-dark.png"
                horizontalTileMode: BorderImage.Repeat
                verticalTileMode: BorderImage.Repeat

                Rectangle {
                  anchors {left: parent.left; top: parent.top; bottom: parent.bottom }
                  width: parent.width * componentRoot.fillPercentage
                  color: TibiaStyle.teal1
                  opacity: 0.5
                } //Rectangle
              } //BorderImage

              ListView {
                id: perkList
                anchors.fill: parent
                anchors.margins: parent.borderWidth
                model: componentRoot.perks

                interactive: false //prevent flick behavior on touch screens
                pixelAligned : true
                boundsBehavior: Flickable.StopAtBounds

                delegate: Item {
                  id: perkItem
                  required property string perkName
                  required property string perkDescription
                  required property int perkIndex
                  required property url imageSource
                  required property bool hasAugmentEffect
                  required property url augmentEffectImageSource
                  required property bool isPicked
                  required property bool isShaped
                  required property int perkRank

                  width: perkList.width
                  height: perkList.height / perkList.count

                  TibiaProficiencyPerk {
                    id: perkComponent
                    anchors.centerIn: parent

                    perkName: perkItem.perkName
                    perkDescription: perkItem.perkDescription
                    imageSource: perkItem.imageSource
                    hasAugmentEffect: perkItem.hasAugmentEffect
                    augmentEffectImageSource: perkItem.augmentEffectImageSource
                    isShaped: perkItem.isShaped
                    perkRank: perkItem.perkRank
                    hasHighlight: perkItem.isPicked
                    isActive: perkItem.isPicked
                    isSelected: componentRoot.levelIndex === root.controller.selectedLevelIndex
                      && perkItem.perkIndex === root.controller.selectedPerkIndex
                    showLockIcon: componentRoot.fillPercentage == 1.0 && !componentRoot.canEditPerksForLevel
                    isInteractive: true

                    onPerkPressed: {
                      root.controller.selectPerk(componentRoot.levelIndex, perkItem.perkIndex);
                      if (componentRoot.canEditPerksForLevel && !perkItem.isPicked) {
                        root.controller.pickPerk(componentRoot.levelIndex, perkItem.perkIndex);
                      }
                    } //onPerkPressed
                  } //ProficiencyPerk
                } // Item
              } //ColumnLayout

            } //TibiaFrame1PixelDown

            TibiaFrame1PixelDown {
              id: descriptionArea
              Layout.preferredHeight: 77
              Layout.fillWidth: true

              Rectangle {
                anchors.fill: parent
                anchors.margins: parent.borderWidth
                color: TibiaStyle.textFieldBackgroundColor
              } //Rectangle

              TibiaText {
                id: descriptionText
                anchors.fill: parent
                anchors.margins: parent.marginsToContent
                wrapMode: Text.Wrap
              } //TibiaText

              Image {
                anchors.centerIn: parent
                source: !componentRoot.isFillerSlot && !componentRoot.perkSelected
                        ? "/images/icon-lock-grey.png" : ""
              } //Image
            } //TibiaFrame1PixelDown
          } //component LevelBackdrop

          Repeater {
            id: levelRepeater
            model: controller.proficiencyModel

            delegate: LevelLayout {
              id: levelDelegate

              required property var model
              required property int index

              Layout.fillHeight: true
              Layout.preferredWidth: levelProgress.segmentWidth
                //last element gets extra space
                + (!levelProgress.hasFillerElement && index == (levelProgress.segmentCount-1) ? levelProgress.remainingWidth : 0)
              Layout.maximumWidth: Layout.preferredWidth

              spacing: TibiaStyle.marginUnrelated
              fillPercentage: levelProgress.fillPercentageForSegment(index)
              descriptionText: model.selectedPerkDescription
              perks: model.perks
              levelIndex: index
              perkSelected: model.isPerkSelected
              hasServerSelectedPerk: model.hasServerSelectedPerk
              isFillerSlot: false
            } //delegate: LevelLayout
          } //Repeater

          LevelLayout {
            id: fillerLevel
            Layout.fillHeight: true
            Layout.fillWidth: true

            fillPercentage: 0.0
            visible: levelProgress.hasFillerElement
            isFillerSlot: true
          } //LevelLayout
        } //RowLayout

        Rectangle {
          anchors {left: levelClumnsLayout.left; top: levelClumnsLayout.top; right: levelClumnsLayout.right }
          anchors.margins: 1
          height: TibiaStyle.defaultTextLineHeight + 2 * TibiaStyle.marginNarrow
          color: TibiaStyle.orange1

          visible: controller.currentIsUseRestricted

          TibiaText {
            anchors.centerIn: parent
            styleType: "Default"
            style: Text.Outline
            text: qsTrId("weapon_proficiency_use_restricted")
          } //TibiaText
        } //Rectangle
      } //Item
    } //ColumnLayout
  } //RowLayout

  ColumnLayout {
    id: buttonLayout
    spacing: TibiaStyle.marginUnrelated
    anchors { left: parent.left; right: parent.right; top: mainLayout.bottom; topMargin: TibiaStyle.marginRelated }

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } // TibiaHorizontalSeparator

    RowLayout {
      id: buttonBar
      Layout.fillWidth: true
      spacing: TibiaStyle.marginRelated

      TibiaCurrentBalanceView {
        Layout.preferredWidth: TibiaStyle.currencyViewWidth
        balanceType: "Dust"
      } //TibiaCurrentBalanceView

      Item {
        // Padding
        Layout.fillWidth: true
        Layout.preferredHeight: 1
      } //Item

      Item {
        Layout.preferredWidth: okButton.width
        Layout.preferredHeight: okButton.height

        TibiaButton {
          id: okButton
          text: qsTrId("ok")
          enabled: root.currentProficiencyChanged
          tooltipText: qsTrId("weapon_proficiency_apply_perk_changes_tooltip")

          onClicked: root.onReturnPressedFunction()
        } //TibiaButton

        Tooltip {
          anchors.fill: parent
          maxWidth: TibiaStyle.guiHelpTooltipWidth

          enabled: !okButton.enabled
          text: qsTrId("weapon_proficiency_no_perk_changes_tooltip")
        } //Tooltip
      } //Item

      Item {
        Layout.preferredWidth: applyButton.width
        Layout.preferredHeight: applyButton.height

        TibiaButton {
          id: applyButton
          text: qsTrId("apply")
          enabled: root.currentProficiencyChanged
          tooltipText: qsTrId("weapon_proficiency_apply_perk_changes_tooltip")

          onClicked: onApplyPressedFunction()
        } //TibiaButton

        Tooltip {
          anchors.fill: parent
          maxWidth: TibiaStyle.guiHelpTooltipWidth

          enabled: !applyButton.enabled
          text: qsTrId("weapon_proficiency_no_perk_changes_tooltip")
        } //Tooltip
      } //Item

      Item {
        Layout.preferredWidth: resetButton.width
        Layout.preferredHeight: resetButton.height

        TibiaButton {
          id: resetButton
          text: qsTrId("reset")
          enabled: controller.canEditPerks && controller.hasPickedPerks
          tooltipText: qsTrId("weapon_proficiency_reset_tooltip")

          onClicked: controller.resetPerks()
        } // TibiaButton

        Tooltip {
          anchors.fill: parent
          maxWidth: TibiaStyle.guiHelpTooltipWidth

          enabled: !resetButton.enabled
          text: {
            if (!controller.canEditPerks) {
              return qsTrId("weapon_proficiency_adjust_not_possibile_tooltip")
            }
            return qsTrId("weapon_proficiency_reset_no_perks_tooltip")
          }
        } //Tooltip
      } // Item

      TibiaButton {
        id: closeButton
        text: root.currentProficiencyChanged ? qsTrId("cancel") : qsTrId("close")
        onClicked: root.onCancelPressedFunction()
      } //TibiaButton
    } // RowLayout
  } // ColumnLayout
} // TibiaDialog
