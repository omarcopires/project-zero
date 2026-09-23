import QtQuick
import QtQuick.Layouts

import qmlcomponents
import qmlenumvalues


TibiaSidebarWidget {
  id: battleListSidebarWidget
  property point _currentTooltipPosition: Qt.point(0,0)

  initialContentHeight: 75
  //                filterButtons.height + scroll view height
  minContentHeight: (filterButtons.visible ? 48 : 0) + TibiaStyle.widgetWithScrollBarMinContentHeight

  caption: {
    if (widgetController != null) {
      if (widgetController.name.length > 0) {
        return widgetController.name;
      } else if (widgetController.isPartyView) {
        return qsTrId("battlelist_party_caption");
      }
    }
    return qsTrId("battlelist_caption");
  } //caption
  highlightCaption: widgetController != null && widgetController.isPrimary
  picSource: {
    if (widgetController != null) {
      if (widgetController.isPrimary) {
        return "/images/skin/classic/icon-battlelist.png";
      } else if (widgetController.isPartyView) {
        return "/images/skin/classic/icon-battlelist-party-widget.png";
      }
    }
    return "/images/skin/classic/icon-battlelist-secondary-widget.png";
  } //picSource

  signal currentlyHoveredCreatureChanged(int CreatureID)
  signal creatureClicked(int CreatureID, int MouseButton, int KeyboardModifiers)
  signal creatureTargetSelected(int CreatureID)

  property var battleListObjectsModel: widgetController != null ? widgetController.battleListModel : null
  property bool isPartyView: widgetController != null && widgetController.isPartyView

  property real oldListPosition;
  property int  battleListBottomMargin: 5;
  property int  currentlyHoveredCreatureID: 0;

  property var _FILTER_BUTTONS_INFO: {}

  Component.onCompleted: {
    var filterButtonInfo = {};
    function appendFilterButtonInfo(filterType, iconPostfix, tooltipPrefix) {
      filterButtonInfo[filterType] = {
          "iconPostfix": iconPostfix
        , "tooltipPrefix": tooltipPrefix
      }
    }

    appendFilterButtonInfo(BattleListController.HIDE_PLAYERS,              "players",   qsTrId("battlelist_configure_menuentry_players"));
    appendFilterButtonInfo(BattleListController.HIDE_KNIGHTS,              "knight",    qsTrId("battlelist_configure_menuentry_knights"));
    appendFilterButtonInfo(BattleListController.HIDE_PALADINS,             "paladin",   qsTrId("battlelist_configure_menuentry_paladins"));
    appendFilterButtonInfo(BattleListController.HIDE_DRUIDS,               "druid",     qsTrId("battlelist_configure_menuentry_druids"));
    appendFilterButtonInfo(BattleListController.HIDE_SORCERERS,            "sorcerer",  qsTrId("battlelist_configure_menuentry_sorcerers"));
    appendFilterButtonInfo(BattleListController.HIDE_MONKS,                "monk",      qsTrId("battlelist_configure_menuentry_monks"));
    appendFilterButtonInfo(BattleListController.HIDE_NPCS,                 "npc",       qsTrId("battlelist_configure_menuentry_npcs"));
    appendFilterButtonInfo(BattleListController.HIDE_MONSTERS,             "monster",   qsTrId("battlelist_configure_menuentry_monsters"));
    appendFilterButtonInfo(BattleListController.HIDE_NON_SKULLED_PLAYERS,  "skull",     qsTrId("battlelist_configure_menuentry_non_skulled_players"));
    appendFilterButtonInfo(BattleListController.HIDE_PARTY_MEMBERS,        "party",     qsTrId("battlelist_configure_menuentry_party_members"));
    appendFilterButtonInfo(BattleListController.HIDE_PLAYER_SUMMONS,       "summon",    qsTrId("battlelist_configure_menuentry_player_summons"));
    appendFilterButtonInfo(BattleListController.HIDE_MEMBERS_OF_OWN_GUILD, "own-guild", qsTrId("battlelist_configure_menuentry_own_guild"));

    _FILTER_BUTTONS_INFO = filterButtonInfo;
  }

  onBattleListObjectsModelChanged: {
    // remember and restore old list position
    oldListPosition = creaturesList.contentY ;
    creaturesList.model = battleListObjectsModel;
    creaturesList.contentY  = oldListPosition;
  } //onBattleListObjectsModelChanged

  onCurrentlyHoveredCreatureIDChanged: {
    battleListSidebarWidget.currentlyHoveredCreatureChanged(currentlyHoveredCreatureID);
  } //onCurrentlyHoveredCreatureIDChanged

  customButtonContainerData: [
    TibiaButton {
      id: openSecondaryBattleListButton
      Layout.preferredWidth: TibiaStyle.widgetControllButtonSize
      Layout.preferredHeight: TibiaStyle.widgetControllButtonSize
      color: widgetController != null && widgetController.hasPremiumStatus ? "verydarkgrey" : "blue"
      imageSource: "/images/skin/classic/icon-additionalwidget.png"
      tooltipText: qsTrId("battlelist_open_secondary")
                   + (widgetController != null && !widgetController.hasPremiumStatus ? " " + qsTrId("context_premium_feature") : "")
      onClicked: widgetController!=null ? widgetController.requestOpenSecondaryBattleList() : undefined
      visible: widgetController != null && !widgetController.isPartyView
    }, //TibiaButton
    TibiaIconButton {
      id: contextMenuButton
      sourceUp:   "/images/skin/classic/button-contextmenu-12x12-idle.png"
      sourceDown: "/images/skin/classic/button-contextmenu-12x12-pressed.png"
      tooltipText: qsTrId("battlelist_configure_tooltip")
      onClicked: widgetController !=null ? widgetController.onShowConfigurationMenu() : undefined
    }, //TibiaIconButton
    TibiaIconButton {
      id: filtersButton
      checkable: true
      enabled: battleListSidebarWidget.maximized
      sourceUp:   "/images/skin/classic/button-expand-12x12-up.png"
      sourceDown: "/images/skin/classic/button-expand-12x12-down.png"
      tooltipText: qsTrId("battlelist_configure_tooltip")
      useButtonShouldBeChecked: true
      buttonShouldBeChecked: widgetController != null && widgetController.filterButtonsVisible
      onClicked: {
        if (widgetController != null) {
          widgetController.onFilterButtonsVisibleClicked();
        }
      } //onClicked
    } //TibiaIconButton
  ] //customButtonContainerData

  MouseArea {
    id: mouseAreaForConfigurationMenu
    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.RightButton
    onClicked: widgetController!=null ?  widgetController.onShowConfigurationMenu() : undefined;

    ColumnLayout {
      anchors.fill: parent
      spacing: 0

      Component {
        id: filterButtonComponent
        TibiaButton {
          id: filterButton

          checkable: true
          useButtonShouldBeChecked: true
          width: TibiaStyle.iconButtonSize
          height: TibiaStyle.iconButtonSize

          property int filterType: -1
          property string tooltipPrefix: ""

          onFilterTypeChanged: {
            if (filterType in _FILTER_BUTTONS_INFO) {
              var info = _FILTER_BUTTONS_INFO[filterType];
              imageSource = "/images/skin/classic/icon-battlelist-" + info.iconPostfix + ".png"
              tooltipPrefix = info.tooltipPrefix;
              refreshFilterButton();
            }
          } //onFilterTypeChanged

          Connections {
            target: widgetController

            function onOptionsChanged() {
              refreshFilterButton()
            }
          } //Connections

          function refreshFilterButton() {
            filterButton.buttonShouldBeChecked = !widgetController.isFilterActive(filterType);
            tooltipText = qsTrId(checked ? "battlelist_configure_menuentry_prefix_hide"
                                         : "battlelist_configure_menuentry_prefix_show")
                                .arg(tooltipPrefix);
          } //function refreshFilterButton()

          onClicked: {
            widgetController.toggleFilter(filterType);
          } //onClicked
        } //TibiaButton
      } //Component

      ColumnLayout {
        id: filterButtons
        Layout.fillWidth: true
        Layout.topMargin: TibiaStyle.marginNarrow
        spacing: TibiaStyle.marginNarrow
        visible: widgetController != null && widgetController.filterButtonsVisible

        Component {
          id: filterButtonRow
          ListView {
            implicitHeight: contentItem.childrenRect.height
            spacing: TibiaStyle.marginNarrow
            orientation: Qt.Horizontal
            boundsBehavior: Flickable.StopAtBounds
            interactive: false //prevent flick behavior on touch screens
            delegate: Loader {
              sourceComponent: widgetController != null ? filterButtonComponent : undefined
              onItemChanged: {
                if (item != null) {
                  item.filterType = modelData;
                }
              }//onItemChanged
            } //delegate: Loader
          } //ListView
        } //Component

        ColumnLayout {
          Layout.fillWidth: true
          Layout.leftMargin: 8 //center buttons
          spacing: TibiaStyle.marginNarrow
          Loader {
            Layout.preferredHeight: item == null ? 0 : item.implicitHeight
            Layout.fillWidth: true
            sourceComponent: filterButtonRow
            onItemChanged: {
              if (item != null) {
                item.model = [  BattleListController.HIDE_PLAYERS
                              , BattleListController.HIDE_KNIGHTS
                              , BattleListController.HIDE_PALADINS
                              , BattleListController.HIDE_DRUIDS
                              , BattleListController.HIDE_SORCERERS
                              , BattleListController.HIDE_MONKS
                              , BattleListController.HIDE_PLAYER_SUMMONS
                             ];
                item.Layout.fillWidth = true;
              }
            } //onItemChanged
          } //Loader
          Loader {
            Layout.preferredHeight: item == null ? 0 : item.implicitHeight
            Layout.fillWidth: true
            sourceComponent: isPartyView ? undefined : filterButtonRow
            visible: sourceComponent != undefined
            onItemChanged: {
              if (item != null) {
                item.model = [  BattleListController.HIDE_NPCS
                              , BattleListController.HIDE_MONSTERS
                              , BattleListController.HIDE_NON_SKULLED_PLAYERS
                              , BattleListController.HIDE_PARTY_MEMBERS
                              , BattleListController.HIDE_MEMBERS_OF_OWN_GUILD
                             ];
                item.Layout.fillWidth = true;
              }
            } //onItemChanged
          } //Loader
        } //ColumnLayout

        TibiaHorizontalSeparator {
          id: filterButtonsSeparator
          Layout.fillWidth: true
        } //TibiaHorizontalSeparator
      } // ColumnLayout

      TibiaScrollView {
        id: creaturesListScrollView
        Layout.fillHeight: true
        Layout.fillWidth: true
        ListView {
          id: creaturesList

          boundsBehavior: Flickable.StopAtBounds
          interactive: false //prevent flick behavior on touch screens
          rebound: Transition {}

          delegate: BattleListEntry {
            property int creatureID: model.creatureID

            implicitWidth: creaturesList.contentItem.width - TibiaStyle.marginNarrow
            implicitHeight: widgetController ? isPartyView ? 26 : 22 : 22
            isPartyViewActive : isPartyView
            entryID : model.creatureID
            creatureName: model.creatureName

            creatureOutfitId: model.creatureOutfitId
            creatureOutfitIsObject: model.creatureOutfitIsObject
            creatureHeadColor: model.creatureHeadColor
            creatureTorsoColor: model.creatureTorsoColor
            creatureLegsColor: model.creatureLegsColor
            creatureDetailColor: model.creatureDetailColor
            creatureFirstAddOn: model.creatureFirstAddOn
            creatureSecondAddOn: model.creatureSecondAddOn

            frameColorsOuterToInner: model.frameColorsOuterToInner
            isTemporarySelected: model.isTemporarySelected
            healthProgressbarPercent: model.healthProgressbarPercent
            healthProgressbarColor: model.healthProgressbarColor
            manaProgressbarPercent: model.manaProgressbarPercent
            showMana: isPartyView && model.showMana
            statusIcons: model.statusIcons
            tutorialMarkerID: model.tutorialMarkerID
            isInViewport: model.isInViewport
            isInSharedXPDistance: model.isInSharedXPDistance
            isFiendishMonster: model.isFiendishMonster
            isLeaderMonster: model.isLeaderMonster
            isLeaderMinionMonster: model.isLeaderMinionMonster
          } //BattleListEntry

          footer: Item {
            height: battleListBottomMargin
          } //footer: Item

          TibiaTargetSelection {
            anchors.fill: parent
            onTargetSelected: {
              var itemAtPosition = creaturesListMouseArea.getItemAtMousePosition(MouseX, MouseY);
              if (itemAtPosition != null) {
                battleListSidebarWidget.creatureTargetSelected(itemAtPosition.creatureID);
              }
            }
          } //TibiaTargetSelection

          MouseArea {
            id: creaturesListMouseArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.RightButton | Qt.LeftButton
            property bool dualMouseClickEmulationActive: false

            onEntered: {
              hoverElementTimer.start();
              tooltipTimer.start();
            } //onEntered
            onExited: {
              hoverElementTimer.stop();
              tooltipTimer.stop();
              tooltip.hideTooltip();
              currentlyHoveredCreatureID = 0;
            } //onExited
            onPositionChanged: {
              tooltip.hideTooltip();
              tooltipTimer.restart();
            } //onPositionChanged
            onClicked: (mouse) => {
              if (mouse.buttons == 0) {
                var itemAtPosition = getItemAtMousePosition(mouse.x, mouse.y);
                if (itemAtPosition != null && !dualMouseClickEmulationActive) {
                  battleListSidebarWidget.creatureClicked(itemAtPosition.creatureID, mouse.button, mouse.modifiers);
                } else if (itemAtPosition != null && dualMouseClickEmulationActive) {
                  battleListSidebarWidget.creatureClicked(itemAtPosition.creatureID, Qt.MiddleButton, Qt.NoModifier);
                }
                if (mouse.button == Qt.RightButton && itemAtPosition == null) {
                  widgetController!=null ?  widgetController.onShowConfigurationMenu() : undefined;
                }
              }
            } // onClicked
            onPressed: (mouse) => {
              if (mouse.buttons == (Qt.LeftButton | Qt.RightButton)) {
                dualMouseClickEmulationActive = true;
              } else {
                dualMouseClickEmulationActive = false;
              }
            } // onPressed

            function getItemAtMousePosition(x, y) {
              //find the position within the list view
              var xInListView = x + creaturesList.contentX;
              var yInListView = y + creaturesList.contentY;

              return creaturesList.itemAt(xInListView, yInListView);
            } //function getItemAtMousePosition(mouse)

            Timer {
              id: hoverElementTimer
              interval: 50
              running: false
              repeat: true
              onTriggered: {
                var itemAtPosition = creaturesListMouseArea.getItemAtMousePosition(creaturesListMouseArea.mouseX,
                                                                                  creaturesListMouseArea.mouseY);
                if (creaturesListMouseArea.containsMouse && itemAtPosition != null) {
                  if (currentlyHoveredCreatureID != itemAtPosition.creatureID) {
                    currentlyHoveredCreatureID = itemAtPosition.creatureID;
                  }
                } else {
                  if (currentlyHoveredCreatureID != 0) {
                    currentlyHoveredCreatureID = 0;
                  }
                }
              } //onTriggered
            } // Timer
            Timer {
              id: tooltipTimer
              interval: TibiaStyle.tooltipDelay
              running: false
              repeat: true
              onTriggered: {
                let mousePositionInBattlelist = Qt.point(creaturesListMouseArea.mouseX, creaturesListMouseArea.mouseY);
                var itemAtPosition = creaturesListMouseArea.getItemAtMousePosition(mousePositionInBattlelist.x,
                                                                                   mousePositionInBattlelist.y);
                if (creaturesListMouseArea.containsMouse && itemAtPosition != null && itemAtPosition.isElided) {
                    tooltip.text = itemAtPosition.creatureName;
                    battleListSidebarWidget._currentTooltipPosition = mousePositionInBattlelist;
                    tooltip.showTooltip();
                }
              } //onTriggered
            } //timer

          } // MouseArea
        } // ListView
      }  // TibiaScrollView
    } // ColumnLayout
  } // MouseArea

  Tooltip {
    id: tooltip
    calculateDelegatePositionCallback: (point) => {
      let window = TooltipHelper.findWindowContentItemForQuickItem(this)
      let tooltipPosition = battleListSidebarWidget._currentTooltipPosition;
      tooltipPosition = tooltip.mapFromItem(creaturesListMouseArea, battleListSidebarWidget._currentTooltipPosition);
      tooltipPosition.y = tooltipPosition.y - tooltip.item.height;
      tooltipPosition = recalculatePointToFitDelegateIntoWindow(tooltipPosition);
      return tooltipPosition;
    }
  } //Tooltip

  Lenshelp {
    anchors.fill: parent
    triggerRect: mapFromItem(widgetRoot, 0, 0, widgetRoot.width, widgetRoot.height)
    caption: widgetController != null && widgetController.isPartyView ? qsTrId("battlelist_party_caption") : qsTrId("battlelist_caption")
    content: widgetController != null && widgetController.isPartyView ? qsTrId("battlelist_party_lenshelp") : qsTrId("battlelist_lenshelp")
  } //Lenshelp

} // tibia sidebar widget
