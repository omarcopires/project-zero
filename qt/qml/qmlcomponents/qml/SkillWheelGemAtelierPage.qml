import QtQuick
import QtQml.Models
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import qmlcomponents

GridLayout {
  id: root
  property var controller
  property bool isPremium: false
  readonly property bool canBeChanged: controller.canBeChanged

  readonly property int leftColumnWidth: 146
  readonly property int firstColumnHeight: 154
  readonly property int maxRevealedGems: controller.maxRevealedGems

  property var selectedGem: gemSelectionModel.model.rowData(gemSelectionModel.currentIndex)

  columnSpacing: TibiaStyle.marginRelated
  rowSpacing: columnSpacing
  columns: 2

  function releaseFocusFromSearchField() {
    root.focus = true
    searchField.focus = false
  } //function releaseFocusFromSearchField

  Connections {
    target: gemSelectionModel.model

    function resetSelection() {
      gemSelectionModel.setCurrentIndex(gemSelectionModel.model.index(0, 0), ItemSelectionModel.ClearAndSelect)
    }
    function rebindSelectedGem() {
      selectedGem = Qt.binding(function() { return gemSelectionModel.model.rowData(gemSelectionModel.currentIndex); })
    }

    function onDataChanged(topLeftModelIndex, bottomRightModelIndex, roles) {
      if (!gemSelectionModel.currentIndex.valid) {
        resetSelection();
      }
      rebindSelectedGem()
    }
    function onRowsInserted(parent, firstIndex, lastIndex) {
      // This happens, for example, when the page changes, so it makes sense to reset the index here
      resetSelection()
      rebindSelectedGem()
    }
    function onRowsRemoved(parent, firstIndex, lastIndex) {
      if (!gemSelectionModel.currentIndex.valid) {
        resetSelection()
        rebindSelectedGem()
      }
    }
    function onPaginationDataChanged() {
      if (!gemSelectionModel.currentIndex.valid) {
        resetSelection()
        rebindSelectedGem()
      }
    }
  }

  ItemSelectionModel {
    id: gemSelectionModel
    // This is the pagination model, and model.sourceModel
    // refers to the original filter model.
    model: root.controller.gemInventory

    property var shouldBeCurrentIndex: root.controller.selectedGemIndex

    onShouldBeCurrentIndexChanged: {
      if (model) {
        setCurrentIndex(shouldBeCurrentIndex, ItemSelectionModel.ClearAndSelect)
      }
    }

    onModelChanged: (model) => {
      if (model && !root.controller.selectedGemIndex.valid) {
        setCurrentIndex(model.index(0, 0), ItemSelectionModel.ClearAndSelect);
      } else if (model && root.controller.selectedGemIndex.valid) {
        setCurrentIndex(shouldBeCurrentIndex, ItemSelectionModel.ClearAndSelect);
      }
    }

    onCurrentIndexChanged: {
      root.controller.selectedGemIndex = currentIndex;
    }
  }

  // Top left panel: Socketed gems
  TibiaFrame2PixelUpFilledWithCaption {
    caption: qsTrId("skill_wheel_atelier_sockets_caption")
    Layout.preferredWidth: root.leftColumnWidth
    Layout.preferredHeight: root.firstColumnHeight

    Image {
      id: socketsImage
      anchors.centerIn: parent
      anchors.verticalCenterOffset: Math.round(parent.captionHeight / 2)
      source: "/images/skillwheel/socket-gematelier.png"

      readonly property int origin: -7
      readonly property int spacing: 15


      SkillWheelGemSocket {
        id: tlSocket
        socket: root.controller.topLeftSocket
        selected: root.selectedGem.gemId == socket.gemId
        x: socketsImage.origin
        y: socketsImage.origin

        onSocketClicked: (gemId) => {
          root.controller.selectGem(gemId);
          releaseFocusFromSearchField();
          gemSelectionModel.model.sourceModel.filterDomainAffinity = TibiaEnums.EGemAffinity.TopLeft;
        }
      }

      SkillWheelGemSocket {
        socket: root.controller.topRightSocket
        selected: root.selectedGem.gemId == socket.gemId
        x: tlSocket.width + socketsImage.spacing
        y: tlSocket.y

        onSocketClicked: (gemId) => {
          root.controller.selectGem(gemId);
          releaseFocusFromSearchField();
          gemSelectionModel.model.sourceModel.filterDomainAffinity = TibiaEnums.EGemAffinity.TopRight;
        }
      }

      SkillWheelGemSocket {
        id: blSocket
        socket: root.controller.bottomLeftSocket
        selected: root.selectedGem.gemId == socket.gemId
        x: tlSocket.x
        y: tlSocket.height + socketsImage.spacing

        onSocketClicked: (gemId) => {
          root.controller.selectGem(gemId);
          releaseFocusFromSearchField();
          gemSelectionModel.model.sourceModel.filterDomainAffinity = TibiaEnums.EGemAffinity.BottomLeft;
        }
      }

      SkillWheelGemSocket {
        id: brSocket
        socket: root.controller.bottomRightSocket
        selected: root.selectedGem.gemId == socket.gemId
        x: tlSocket.width + socketsImage.spacing
        y: tlSocket.height + socketsImage.spacing

        onSocketClicked: (gemId) => {
          root.controller.selectGem(gemId);
          releaseFocusFromSearchField();
          gemSelectionModel.model.sourceModel.filterDomainAffinity = TibiaEnums.EGemAffinity.BottomRight;
        }
      }
    }
  }

  // Top right panel: Gem details
  TibiaFrame2PixelUpFilledWithCaption {
    id: gemSelectionPanel
    caption: qsTrId("skill_wheel_atelier_gemdetails_caption")
    Layout.fillWidth: true
    Layout.preferredHeight: root.firstColumnHeight

    component GemMod: ColumnLayout {
      id: gemModComponent
      property int modId
      property url modImageSource
      property string modEffectString
      property bool modActive
      property int modGrade
      property int modGradePotential
      property bool supremeMod: false

      spacing: 0

      Item {
        Layout.fillWidth: true
        readonly property int supremeModIconHeight: 35
        Layout.preferredHeight: supremeModIconHeight*1.5 + 4 * TibiaStyle.marginNarrow

        Image {
          id: modSaturationTarget
          anchors.centerIn: parent
          source: controller.getModGradeImageSource(gemModComponent.modGrade)
          visible: gemModComponent.modImageSource != ""
          width: implicitWidth
          height: implicitHeight

          Image {
            id: gradeHighlightImage
            source: controller.getModGradeHighlightImageSource(gemModComponent.modGrade)
            visible: false
          }

          Image {
            id: gemModImage
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: supremeMod ? 3 : 0
            anchors.verticalCenterOffset: supremeMod ? -2 : 0
            source: gemModComponent.modImageSource
          }

          Image {
            source: controller.getModGradePotentialSource(gemModComponent.modGradePotential)
            visible: gemModComponent.modGrade < gemModComponent.modGradePotential
          }
        } // Image

        HueSaturation {
          anchors.centerIn: parent
          width: modSaturationTarget.width
          height: modSaturationTarget.height
          saturation: gemModComponent.modActive ? 0.0 : -1.0
          source: modSaturationTarget
          visible: gemModComponent.modImageSource != ""

          Tooltip {
            text: {
              let tooltipParts = []
              if (!gemModComponent.modActive) {
                tooltipParts.push(qsTrId("skill_wheel_atelier_mod_inactive"))
              }
              if (gemModComponent.modGrade < gemModComponent.modGradePotential) {
                tooltipParts.push(qsTrId("skill_wheel_atelier_mod_grade_reduced"))
              }
              if (tooltipParts.length > 0) {
                return tooltipParts.join('\n\n')
              }
              return "";
            }

            anchors.fill: parent
            maxWidth: TibiaStyle.tooltipRestrictedWidth

            onHoverEnter: {
              if (tibiaMouseCursorController) {
                tibiaMouseCursorController.setPointingHand(true);
              }
              gradeHighlightImage.visible = true
            }
            onHoverLeave: {
              if (tibiaMouseCursorController) {
                tibiaMouseCursorController.setPointingHand(false);
              }
              gradeHighlightImage.visible = false
            }
          }

          MouseArea {
            anchors.fill: parent

            onClicked: {
              if (tibiaMouseCursorController) {
                tibiaMouseCursorController.setPointingHand(false);
              }
              controller.selectModInFragmentWorkshop(gemModComponent.modId, gemModComponent.supremeMod);
            }
          }
        } // HueSaturation
      }

      TibiaText {
        Layout.fillWidth: true
        Layout.fillHeight: true
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: gemModComponent.modEffectString
        wrapMode: Text.Wrap
        styleType: gemModComponent.modActive ? "Dialog" : "Disabled"
      } //TibiaText
    } // component GemMod

    Component {
      id: selectedGemComponent
      Item {
        RowLayout {
          anchors { left: parent.left; top: parent.top;
                    right: parent.right; bottom: gemButtonLayout.top;
                    bottomMargin: TibiaStyle.marginRelated }
          spacing: TibiaStyle.marginNarrow

          ColumnLayout {
            Layout.preferredWidth: 160 // not as width as the GemMod views to give more width for texts
            Layout.maximumWidth: Layout.preferredWidth
            Layout.fillHeight: true

            TibiaText {
              text: root.selectedGem.gemName
              Layout.fillWidth: true
              horizontalAlignment: Text.AlignHCenter
            }

            Item {
              Layout.fillWidth: true
              Layout.fillHeight: true

              Image {
                source: root.selectedGem.gemImageSource
                width: implicitWidth * 2
                height: width
                smooth: false
                anchors.centerIn: parent
              }
            }

            RowLayout {
              Layout.fillWidth: true

              TibiaText {
                text: qsTrId("skill_wheel_atelier_domain_affinity")
                Layout.preferredHeight: selectedGemAffinityImage.height
                Layout.fillWidth: true
              }

              Image {
                id: selectedGemAffinityImage
                source: root.selectedGem.domainAffinitySource
                Layout.topMargin: -width/2
              }
            } // RowLayout
          } // ColumnLayout

          RowLayout {
            Layout.fillWidth: true
            spacing: TibiaStyle.marginNarrow
            readonly property int detailPartWidth: (width - 2 * spacing) / 3

            GemMod {
              modId: root.selectedGem.mod1Id
              modImageSource: root.selectedGem.mod1ImageSource
              modEffectString: root.selectedGem.mod1EffectString
              modActive: root.selectedGem.mod1Active
              modGrade: root.selectedGem.mod1Grade
              modGradePotential: root.selectedGem.mod1PotentialGrade
              Layout.preferredWidth: parent.detailPartWidth
              Layout.fillHeight: true
            } //GemMod

            GemMod {
              modId: root.selectedGem.mod2Id
              modImageSource: root.selectedGem.mod2ImageSource
              modEffectString: root.selectedGem.mod2EffectString
              modActive: root.selectedGem.mod2Active
              modGrade: root.selectedGem.mod2Grade
              modGradePotential: root.selectedGem.mod2PotentialGrade
              Layout.preferredWidth: parent.detailPartWidth
              Layout.fillHeight: true
            } //GemMod

            GemMod {
              modId: root.selectedGem.mod3Id
              modImageSource: root.selectedGem.mod3ImageSource
              modEffectString: root.selectedGem.mod3EffectString
              modActive: root.selectedGem.mod3Active
              modGrade: root.selectedGem.mod3Grade
              modGradePotential: root.selectedGem.mod3PotentialGrade
              supremeMod: true
              Layout.preferredWidth: parent.detailPartWidth
              Layout.fillHeight: true
            } //GemMod
          } //RowLayout
        } // RowLayout

        RowLayout {
          id: gemButtonLayout
          anchors { left: parent.left; bottom: parent.bottom; right: parent.right}
          spacing: TibiaStyle.marginUnrelated


          Item {
            Layout.preferredWidth: socketButton.width
            Layout.preferredHeight: socketButton.height
            Layout.alignment: Qt.AlignLeft

            TibiaButton {
              id: socketButton
              text: root.selectedGem.isSocketed ? qsTrId("skill_wheel_atelier_unsocket") : qsTrId("skill_wheel_atelier_socket")
              width: TibiaStyle.buttonWidthWider
              enabled: root.isPremium && root.canBeChanged

              onClicked: {
                root.controller.socketOrUnsocketGem(root.selectedGem.gemId)
              }
            } // TibiaButton

            Tooltip {
              anchors.fill: parent
              text: {
                if (socketButton.enabled) {
                  return ""
                }
                let messages = []
                if (!root.isPremium) {
                  messages.push(qsTrId("skill_wheel_atelier_socket_not_premium"))
                }
                if (!root.canBeChanged) {
                  messages.push(qsTrId("skill_wheel_atelier_socket_not_in_temple"))
                }
                return messages.join("\n")
              }
            } // Tooltip
          } // Item

          Item {
            Layout.fillWidth: true
            Layout.preferredHeight: changeAffinityButton.height
          } // Item

          Item {
            Layout.preferredWidth: changeAffinityButton.width
            Layout.preferredHeight: changeAffinityButton.height
            Layout.alignment: Qt.AlignRight

            TibiaButton {
              id: changeAffinityButton
              text: qsTrId("skill_wheel_atelier_change_affinity")
              width: TibiaStyle.buttonWidthWide
              enabled: !root.selectedGem.isLastOfDomainAffinity && root.isPremium && root.canBeChanged && !root.selectedGem.isSocketed && !changeAffinityCostView.tooLowBalance && root.selectedGem.canBeDismantled && !root.selectedGem.isLocked

              onClicked: {
                root.controller.changeAffinityOfGem(root.selectedGem.gemId)
              }

            } // TibiaButton

            Tooltip {
              width: changeAffinityButton.width
              height: changeAffinityButton.height

              text: {
                if (changeAffinityButton.enabled) {
                  return qsTrId("skill_wheel_atelier_change_affinity_tooltip")
                    .arg(TextHelper.formatNumberWithThousandSeparators(root.controller.changeAffinityCost))
                }
                let messages = []
                if (root.selectedGem.isLastOfDomainAffinity) {
                  messages.push(qsTrId("skill_wheel_atelier_change_affinity_last_gem"))
                } else {
                  if (!root.isPremium) {
                    messages.push(qsTrId("skill_wheel_atelier_change_affinity_not_premium"))
                  }
                  if (!root.canBeChanged) {
                    messages.push(qsTrId("skill_wheel_atelier_change_affinity_not_in_temple"))
                  }
                  if (root.selectedGem.isSocketed) {
                    messages.push(qsTrId("skill_wheel_atelier_change_affinity_gem_socketed"))
                  } else if (!root.selectedGem.canBeDismantled) {
                    messages.push(qsTrId("skill_wheel_atelier_change_affinity_changes_not_applied"))
                  }
                  if (root.selectedGem.isLocked) {
                    messages.push(qsTrId("skill_wheel_atelier_change_affinity_still_locked"))
                  }

                  if (changeAffinityCostView.tooLowBalance) {
                    messages.push(
                      qsTrId("skill_wheel_atelier_change_affinity_insufficient_money")
                      .arg(TextHelper.formatNumberWithThousandSeparators(root.controller.changeAffinityCost)))
                  }
                }

                return messages.join("\n")
              }
            } // Tooltip
          } // Item

          TibiaCurrencyView {
            id: changeAffinityCostView
            Layout.preferredWidth: 50
            Layout.leftMargin: (TibiaStyle.marginNarrow - gemButtonLayout.spacing)
            Layout.alignment: Qt.AlignRight
            iconId: "GoldCoin"
            rightAligned: true
            price: TextHelper.formatNumberWithThousandSeparatorsAndThousandShortcutsAsMultiString(root.controller.changeAffinityCost)
            tooLowBalance: root.controller.changeAffinityCost > storeAndResourceBalanceHelper.totalGoldBalance
          }

          Item {
            Layout.preferredWidth: dismantleButton.width
            Layout.preferredHeight: dismantleButton.height

            Layout.alignment: Qt.AlignRight

            TibiaButton {
              id: dismantleButton
              text: qsTrId("skill_wheel_atelier_dismantle")
              width: TibiaStyle.buttonWidthWide
              enabled: !root.selectedGem.isLastOfDomainAffinity && root.isPremium && root.canBeChanged && !root.selectedGem.isSocketed && root.selectedGem.canBeDismantled && !root.selectedGem.isLocked

              onClicked: {
                root.controller.dismantleGem(root.selectedGem.gemId)
              }
            } // TibiaButton

            Tooltip {
              anchors.fill: parent
              text: {
                if (dismantleButton.enabled) {
                  return ""
                }
                let messages = []
                if (root.selectedGem.isLastOfDomainAffinity) {
                  messages.push(qsTrId("skill_wheel_atelier_dismantle_last_gem"))
                } else {
                  if (!root.isPremium) {
                    messages.push(qsTrId("skill_wheel_atelier_dismantle_not_premium"))
                  }
                  if (!root.canBeChanged) {
                    messages.push(qsTrId("skill_wheel_atelier_dismantle_not_in_temple"))
                  }
                  if (root.selectedGem.isSocketed) {
                    messages.push(qsTrId("skill_wheel_atelier_dismantle_still_socketed"))
                  } else if (!root.selectedGem.canBeDismantled) {
                    messages.push(qsTrId("skill_wheel_atelier_dismantle_changes_not_applied"))
                  }
                  if (root.selectedGem.isLocked) {
                    messages.push(qsTrId("skill_wheel_atelier_dismantle_still_locked"))
                  }
                }
                return messages.join("\n")
              }
            } // Tooltip
          } //Item
        } // RowLayout

      } // Item
    } // Component

    Component {
      id: noSelectedGemComponent

      TibiaText {
        text: qsTrId("skill_wheel_atelier_no_gem_selection")
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
      }
    }
    Loader {
      anchors {
        fill: parent
        topMargin: gemSelectionPanel.topMarginToContent;
        leftMargin: gemSelectionPanel.marginsToContent + TibiaStyle.marginRelated
        rightMargin: gemSelectionPanel.marginsToContent + TibiaStyle.marginRelated
        bottomMargin: gemSelectionPanel.marginsToContent }

      sourceComponent: root.selectedGem && root.selectedGem.gemName !== undefined ? selectedGemComponent : noSelectedGemComponent
    } // Loader
  } // TibiaFrame2PixelUpFilledWithCaption

  // Top left panel: Reveal unidentified gems
  TibiaFrame2PixelUpFilledWithCaption {
    caption: qsTrId("skill_wheel_atelier_relevation_caption")
    Layout.preferredWidth: root.leftColumnWidth
    Layout.fillHeight: true

    component GemRelevation: ColumnLayout {
      id: relevationComponent
      property int appearanceTypeId: 0
      property string gemName
      property int gemCount: 0
      property real revealCost: 0
      property real bankBalance: 0
      property int gemQuality
      property int totalRevealedGems: 0

      Item {
        Layout.fillWidth: true
        Layout.fillHeight: true

        SingleObjectAppearanceInstanceRenderer {
          typeid: relevationComponent.appearanceTypeId
          width: TibiaStyle.mapWindowPixelPerField
          height: width
          anchors.centerIn: parent

          Tooltip {
            anchors.fill: parent
            text: relevationComponent.gemName
          } // ToolTip
        } // SingleObjectAppearanceInstanceRenderer
      } // Item

      TibiaText {
        text: qsTrId("skill_wheel_atelier_reveal_name_count").arg(relevationComponent.gemName).arg(relevationComponent.gemCount)
        Layout.fillWidth: true
        Layout.minimumHeight: TibiaStyle.defaultTextLineHeight * 2
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignBottom
        wrapMode: Text.Wrap
      }

      RowLayout {
        spacing: TibiaStyle.marginNarrow

        Item {
          // Workaround for tooltip + disabled element
          width: revealButton.width
          height: revealButton.height

          TibiaButton {
            id: revealButton
            text: qsTrId("skill_wheel_atelier_reveal")
            width: TibiaStyle.buttonWidthBroad
            enabled: !revealCostView.tooLowBalance && relevationComponent.gemCount > 0 && relevationComponent.totalRevealedGems < root.maxRevealedGems && root.isPremium && root.canBeChanged

            onClicked: {
              root.controller.revealGem(relevationComponent.gemQuality);
            }
          } // TibiaButton

          Tooltip {
            anchors.fill: parent
            text: {
              if (revealButton.enabled) {
                return "";
              }
              let messages = []
              if (revealCostView.tooLowBalance) {
                messages.push(
                  qsTrId("skill_wheel_atelier_reveal_insufficient_money")
                    .arg(TextHelper.formatNumberWithThousandSeparators(relevationComponent.revealCost)))
              }
              if (relevationComponent.gemCount == 0) {
                messages.push(qsTrId("skill_wheel_atelier_reveal_no_unrevealed_gems"))
              }
              if (relevationComponent.totalRevealedGems >= root.maxRevealedGems) {
                messages.push(
                  qsTrId("skill_wheel_atelier_reveal_too_many_gems")
                    .arg(root.maxRevealedGems))
              }
              if (!root.isPremium) {
                messages.push(qsTrId("skill_wheel_atelier_reveal_not_premium"))
              }
              if (!root.canBeChanged) {
                messages.push(qsTrId("skill_wheel_atelier_reveal_not_in_temple"))
              }
              return messages.join("\n")
            }
          } // Tooltip
        } // Item

        TibiaCurrencyView {
          id: revealCostView
          Layout.fillWidth: true
          iconId: "GoldCoin"
          rightAligned: true
          price: TextHelper.formatNumberWithThousandSeparatorsAndThousandShortcutsAsMultiString(relevationComponent.revealCost)
          tooLowBalance: relevationComponent.revealCost > relevationComponent.bankBalance
        }
      }
    } // component GemRelevation

    TibiaGuiHelp {
      anchors { right: parent.right; top: parent.top;
                topMargin: parent.borderWidth + 1;
                rightMargin: parent.borderWidth + TibiaStyle.marginNarrow; }
      text: qsTrId("skill_wheel_atelier_reveal_tooltip")
    }

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: parent.marginsToContent
      anchors.topMargin: parent.topMarginToContent

      GemRelevation {
        Layout.fillWidth: true
        Layout.fillHeight: true

        appearanceTypeId: root.controller.unrevealedLesserGemAppearanceType
        gemName: root.controller.unrevealedLesserGemName
        gemCount: root.controller.unrevealedLesserGems
        revealCost: root.controller.revealLesserGemCost
        bankBalance: storeAndResourceBalanceHelper.totalGoldBalance
        gemQuality: TibiaEnums.EGemQuality.Lesser
        totalRevealedGems: root.controller.gemsInInventory
      }

      GemRelevation {
        Layout.fillWidth: true
        Layout.fillHeight: true

        appearanceTypeId: root.controller.unrevealedRegularGemAppearanceType
        gemName: root.controller.unrevealedRegularGemName
        gemCount: root.controller.unrevealedRegularGems
        revealCost: root.controller.revealRegularGemCost
        bankBalance: storeAndResourceBalanceHelper.totalGoldBalance
        gemQuality: TibiaEnums.EGemQuality.Regular
        totalRevealedGems: root.controller.gemsInInventory
      }

      GemRelevation {
        Layout.fillWidth: true
        Layout.fillHeight: true

        appearanceTypeId: root.controller.unrevealedGreaterGemAppearanceType
        gemName: root.controller.unrevealedGreaterGemName
        gemCount: root.controller.unrevealedGreaterGems
        revealCost: root.controller.revealGreaterGemCost
        bankBalance: storeAndResourceBalanceHelper.totalGoldBalance
        gemQuality: TibiaEnums.EGemQuality.Greater
        totalRevealedGems: root.controller.gemsInInventory
      }
    }
  } // TibiaFrame2PixelUpFilledWithCaption (Gem Relevation)

  // Lower right panel: List of all identified gems
  ColumnLayout {
    Layout.fillWidth: true
    Layout.fillHeight: true
    spacing: TibiaStyle.marginRelated

    RowLayout {
      id: middleControlsLayout
      Layout.fillWidth: true
      Layout.preferredHeight: TibiaStyle.buttonHeightDefault

      spacing: TibiaStyle.marginRelated
      readonly property int filterControlsWidth: 155

      TibiaTextSearchField {
        id: searchField
        Layout.preferredWidth: middleControlsLayout.filterControlsWidth
        shouldBeText: gemSelectionModel.model.sourceModel.filterModName

        onSearchTextChanged: {
          gemSelectionModel.model.sourceModel.filterModName = searchText
        }

        Keys.onPressed: (event) => {
          if (focus && event.key == Qt.Key_Enter || event.key == Qt.Key_Return) {
            searchTextChanged();
            event.accepted = true;
            //avoid forward to OK-Button which closes the dialogue
          }
        } //Keys.onPressed

      } //TibiaTextSearchField

      TibiaComboBox {
        Layout.preferredWidth: middleControlsLayout.filterControlsWidth
        shouldBeCurrentIndex: gemSelectionModel.model.sourceModel.filterDomainAffinity + 1
        textRole: "text"
        valueRole: "value"
        model: ListModel {
          id: filterAffinityModel
          ListElement { text: qsTrId("skill_wheel_atelier_domain_affinity_filter_all");
                        value: -1 }
          ListElement { text: qsTrId("skill_wheel_domain_name_topleft");
                        value: TibiaEnums.EGemAffinity.TopLeft }
          ListElement { text: qsTrId("skill_wheel_domain_name_topright");
                        value: TibiaEnums.EGemAffinity.TopRight }
          ListElement { text: qsTrId("skill_wheel_domain_name_bottomleft");
                        value: TibiaEnums.EGemAffinity.BottomLeft }
          ListElement { text: qsTrId("skill_wheel_domain_name_bottomright");
                        value: TibiaEnums.EGemAffinity.BottomRight }
        }

        onActivated: (index) => {
          gemSelectionModel.model.sourceModel.filterDomainAffinity = filterAffinityModel.get(index).value
        }
      }

      TibiaComboBox {
        Layout.preferredWidth: middleControlsLayout.filterControlsWidth
        shouldBeCurrentIndex: gemSelectionModel.model.sourceModel.filterGemQuality + 1
        textRole: "text"
        valueRole: "value"
        model: ListModel {
          id: filterQualityModel
          ListElement { text: qsTrId("skill_wheel_atelier_gem_quality_filter_all");
                        value: -1 }
          ListElement { text: qsTrId("skill_wheel_atelier_gem_quality_filter_lesser");
                        value: TibiaEnums.EGemQuality.Lesser }
          ListElement { text: qsTrId("skill_wheel_atelier_gem_quality_filter_regular");
                        value: TibiaEnums.EGemQuality.Regular }
          ListElement { text: qsTrId("skill_wheel_atelier_gem_quality_filter_greater");
                        value: TibiaEnums.EGemQuality.Greater }
        }

        onActivated: (index) => {
          gemSelectionModel.model.sourceModel.filterGemQuality = filterQualityModel.get(index).value
        }
      }

      TibiaCheckBox {
        text: qsTrId("skill_wheel_atelier_gem_show_locked_only")
        shouldBeChecked: gemSelectionModel.model.sourceModel.showLockedOnly
        onCheckedChanged: {
          gemSelectionModel.model.sourceModel.showLockedOnly = checked;
        }
      }

      TibiaButton {
        Layout.leftMargin: TibiaStyle.marginWide - parent.spacing
        imageSource: "/images/icon-arrow.png"
        imageSourceDisabled: "/images/icon-arrow-disabled.png"
        Layout.preferredWidth: TibiaStyle.buttonHeightDefault
        enabled: gemSelectionModel.model.hasPreviousPage

        onClicked: {
          gemSelectionModel.model.currentPage -= 1
        }
      } // TibiaButton

      TibiaText {
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        text: qsTrId("skill_wheel_atelier_page_count_total")
          .arg(gemSelectionModel.model.currentPage)
          .arg(gemSelectionModel.model.numberOfPages)
          .arg(gemSelectionModel.model.sourceModel.rowCount())
      } // TibiaText

      TibiaButton {
        imageSource: "/images/icon-arrow.png"
        imageSourceDisabled: "/images/icon-arrow-disabled.png"
        Layout.preferredWidth: TibiaStyle.buttonHeightDefault
        imageMirrored: true
        enabled: gemSelectionModel.model.hasNextPage

        onClicked: {
          gemSelectionModel.model.currentPage += 1
        }
      } // TibiaButton
    } // RowLayout

    TibiaFrame1PixelDown {
      Layout.fillWidth: true
      Layout.fillHeight: true

      GridView {
        id: gemsGrid
        anchors.fill: parent
        anchors.margins: parent.borderWidth

        interactive: false
        boundsBehavior: Flickable.StopAtBounds

        readonly property int rowCount: 3
        readonly property int columnCount: 5
        readonly property int spacing: TibiaStyle.marginRelated
        cellWidth: Math.ceil((width / columnCount) - (spacing / columnCount))
        cellHeight: Math.ceil((height / rowCount) - (spacing / rowCount))

        model: gemSelectionModel.model

        delegate: MouseArea {
          id: gridCell

          required property int index
          required property string gemName
          required property url gemImageSource
          required property url domainAffinitySource
          required property bool isSocketed
          required property url mod1ImageSource
          required property string mod1EffectString
          required property int mod1Grade
          required property int mod1PotentialGrade
          required property url mod2ImageSource
          required property string mod2EffectString
          required property int mod2Grade
          required property int mod2PotentialGrade
          required property url mod3ImageSource
          required property string mod3EffectString
          required property int mod3Grade
          required property int mod3PotentialGrade
          required property int gemId
          required property bool isLocked

          width: gemsGrid.cellWidth
          height: gemsGrid.cellHeight

          onClicked: (mouse) => {
            gemSelectionModel.setCurrentIndex(gemsGrid.model.index(index, 0), ItemSelectionModel.ClearAndSelect)
            gemsGrid.currentIndex = index

            releaseFocusFromSearchField();
          }

          TibiaFrame2PixelUpFilled {
            width: gemsGrid.cellWidth - gemsGrid.spacing
            height: gemsGrid.cellHeight - gemsGrid.spacing
            anchors { bottom: parent.bottom; right: parent.right; }

            Rectangle {
              anchors.fill: parent
              anchors.margins: -3
              color: "transparent"
              border { color: "white"; width: 2 }
              visible: gemSelectionModel.currentIndex == gemsGrid.model.index(gridCell.index, 0)
            }

            Item {
              width: lockButton.width
              height: lockButton.height
              anchors { margins: parent.marginsToContent + TibiaStyle.marginRelated;
                          left: parent.left; top: parent.top }

              TibiaIconButton {
                id: lockButton
                checkable: true
                checked: gridCell.isLocked
                opacity: root.canBeChanged ? 1.0 : 0.6
                enabled: root.canBeChanged
                sourceDown: "/images/icon-locked.png"
                sourceUp: "/images/icon-unlocked.png"
                anchors.fill: parent
                onClicked: {
                  root.controller.toggleGemLock(gridCell.gemId);
                }

              } // TibiaIconButton

              Tooltip {
                anchors.fill: parent
                text: {
                  if (lockButton.enabled) {
                    return qsTrId("skill_wheel_atelier_lock_button_tooltip");
                  } else {
                    let messages = [];
                    if (!root.canBeChanged) {
                      messages.push(qsTrId("skill_wheel_atelier_lock_not_in_temple"));
                    }
                    return messages.join("\n");
                  }
                }

              } // Tooltip

            } // Item

            Image {
              anchors.horizontalCenter: parent.horizontalCenter
              anchors.top: parent.top
              anchors.topMargin: parent.marginsToContent
              source: gridCell.gemImageSource

              Tooltip {
                anchors.fill: parent
                text: gridCell.gemName
              }
            } // Image

            Image {
              anchors { margins: parent.marginsToContent + TibiaStyle.marginNarrow;
                        right: parent.right; top: parent.top }
              source: isSocketed ? gridCell.domainAffinitySource : ""
            } // Image

            RowLayout {
              anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter;
                        margins: parent.marginsToContent }

              spacing: TibiaStyle.marginNarrow

              Image {
                source: controller.getModGradeImageSource(gridCell.mod1Grade)

                Image {
                  source: gridCell.mod1ImageSource
                  anchors.centerIn: parent

                  Tooltip {
                    anchors.fill: parent
                    text: gridCell.mod1EffectString
                  }
                }

                Image {
                  source: controller.getModGradePotentialSource(gridCell.mod1PotentialGrade)
                  visible: gridCell.mod1Grade < gridCell.mod1PotentialGrade
                }
              } // Image

              Image {
                source: controller.getModGradeImageSource(gridCell.mod2Grade)
                visible: gridCell.mod2ImageSource != ""

                Image {
                  source: gridCell.mod2ImageSource
                  anchors.centerIn: parent

                  Tooltip {
                    anchors.fill: parent
                    text: gridCell.mod2EffectString
                  }
                }

                Image {
                  source: controller.getModGradePotentialSource(gridCell.mod2PotentialGrade)
                  visible: gridCell.mod2Grade < gridCell.mod2PotentialGrade
                }
              } // Image

              Image {
                source: controller.getModGradeImageSource(gridCell.mod3Grade)
                visible: gridCell.mod3ImageSource != ""

                Image {
                  source: gridCell.mod3ImageSource
                  anchors.centerIn: parent
                  anchors.horizontalCenterOffset: 3
                  anchors.verticalCenterOffset: -2

                  Tooltip {
                    anchors.fill: parent
                    text: gridCell.mod3EffectString
                  }
                }

                Image {
                  source: controller.getModGradePotentialSource(gridCell.mod3PotentialGrade)
                  visible: gridCell.mod3Grade < gridCell.mod3PotentialGrade
                }
              } // Image
            } /// RowLayout
          } // TibiaFrame2PixelUpFilled
        } // Item
      } // GridView
    } // TibiaFrame1PixelDown
  } // ColumnLayout
} // GridView
