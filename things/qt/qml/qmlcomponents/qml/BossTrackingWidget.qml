import QtQuick
import QtQuick.Layouts

import qmlcomponents



TibiaSidebarWidget {
  caption: qsTrId("bosstracker_caption")
  picSource: "/images/skin/classic/icon-bosstracker-widget.png"

  minContentHeight: 45

  highlightFocus: widgetController != null && widgetController.hasFocus

  onWidgetControllerChanged: {
    if (widgetController != null) {
      widgetController.requestWidgetControlToTakeFocus.connect(setFocusToSearchField);
    }
  } //onWidgetControllerChanged

  customButtonContainerData: [
    TibiaIconButton {
      id: showConfigButton
      sourceUp:   "/images/skin/classic/button-contextmenu-12x12-idle.png"
      sourceDown: "/images/skin/classic/button-contextmenu-12x12-pressed.png"
      tooltipText: widgetController != null ? qsTrId("bosstracker_options_tooltip") : qsTrId("dummy_unknown")
      onClicked:  widgetController != null ? widgetController.requestWidgetConfigurationMenu() : undefined
    } //TibiaIconButton
  ] //customButtonContainerData

  function setFocusToSearchField() {
    searchField.forceActiveFocus()
  }

  TibiaScrollView {
    id: scrollView
    anchors { left: parent.left; leftMargin: TibiaStyle.marginNarrow;
              right: parent.right;
              top: parent.top; bottom: parent.bottom }

    Flickable {
      contentHeight: bossTrackerList.count > 0 ? searchField.height + TibiaStyle.marginNarrow + bossTrackerList.height : noBossesText.height

      interactive: false //prevent flick behavior on touch screens
      boundsBehavior: Flickable.StopAtBounds
      pixelAligned: true

      TibiaTextSearchField {
        id: searchField
        visible: widgetController != null && widgetController.hasUnlockedAnyBosses
        anchors { left: parent.left; leftMargin: TibiaStyle.marginNarrow;
                  right: parent.right; rightMargin: TibiaStyle.marginRelated;
                  top: parent.top; topMargin: TibiaStyle.marginNarrow; }

        KeyNavigation.tab: searchField
        KeyNavigation.backtab: searchField

        maximumLength: TibiaStyle.maxCharacterNameLength

        onSearchTextChanged: {
          if (widgetController != null) {
            widgetController.requestFilterByBossName(searchText);
          }
        }

        onActiveFocusChanged: {
          if (activeFocus && widgetController != null) {
            widgetController.takeFocus()
          }
        }

        onEscPressedInSearchTextField: {
          if (widgetController != null) {
            widgetController.releaseFocus()
          }
        }
      }

      TibiaText {
        id: noBossesText
        text: qsTrId("bosstracker_no_unlocked_bosses")
        visible: widgetController != null && !widgetController.hasUnlockedAnyBosses

        wrapMode: Text.Wrap
        anchors { left: parent.left; leftMargin: TibiaStyle.marginNarrow;
                  right: parent.right; rightMargin: TibiaStyle.marginRelated;
                  top: parent.top; topMargin: TibiaStyle.marginNarrow; }
      }

      ListView {
        id: bossTrackerList
        model: widgetController != null ? widgetController.bosses : null
        anchors { left: parent.left; leftMargin: TibiaStyle.marginNarrow;
                  right: parent.right; rightMargin: TibiaStyle.marginNarrow;
                  top: searchField.bottom; topMargin: TibiaStyle.marginNarrow; }
        height: contentItem.height

        interactive: false //prevent flick behavior on touch screens
        boundsBehavior: Flickable.StopAtBounds

        delegate: Item {
          width: bossTrackerList.width
          height: trackingEntryLayout.height

          RowLayout {
            id: trackingEntryLayout
            anchors { left: parent.left; right: parent.right }

            OutfitAppearanceInstanceRenderer {
              Layout.preferredWidth: 32
              Layout.preferredHeight: 32

              outfitId: model.outfit != null ? model.outfit.outfitID : 0
              headColor: model.outfit != null ? model.outfit.colors.headColor : "black"
              legsColor: model.outfit != null ? model.outfit.colors.legsColor : "black"
              torsoColor: model.outfit != null ? model.outfit.colors.torsoColor : "black"
              detailColor: model.outfit != null ? model.outfit.colors.detailColor : "black"
              firstAddOn: model.outfit != null ? model.outfit.firstAddOn : false
              secondAddOn: model.outfit != null ? model.outfit.secondAddOn : false
              outfitIsObject: model.outfit != null ? model.outfit.isObjectOutfit : false
              shrinkToFit: true
            }

            ColumnLayout {
              spacing: TibiaStyle.marginNarrow

              TibiaText {
                text: model.name
                styleType: "Default"
                Layout.fillWidth: true
              }

              TibiaText {
                text: model.hasCooldown ? model.cooldownEndString : qsTrId("bosstracker_no_cooldown")
                styleType: model.hasCooldown ? "ModifierNegative" : "Dialog"
                Layout.fillWidth: true
              }
            } // ColumnLayout
          } // RowLayout

          MouseArea {
            anchors.fill: parent

            onClicked: {
              if (widgetController != null) {
                widgetController.requestOpenBosstiary(model.bossRaceId)
              }
            }
          } // MouseArea
        } // delegate: Item
      } // ListView
    } // Flickable
  } // TibiaScrollView

  Lenshelp {
    anchors.fill: parent
    triggerRect: mapFromItem(widgetRoot, 0, 0, widgetRoot.width, widgetRoot.height)
    caption: qsTrId("bosstracker_lenshelp_caption")
    content: qsTrId("bosstracker_lenshelp")
  } //Lenshelp
} // TibiaSidebarWidget
