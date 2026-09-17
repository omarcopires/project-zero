import QtQuick
import QtQuick.Layouts

import qmlcomponents



TibiaSidebarWidget {
  id: spellListSidebarWidget
  caption: qsTrId("spelllist_caption")
  picSource: "/images/skin/classic/icon-spell-list-widget.png"

  highlightFocus: widgetController != null && widgetController.hasFocus

  initialContentHeight: 250
  minContentHeight: TibiaStyle.widgetWithScrollBarMinContentHeight
                  + searchField.height
                  + separator.height
                  + detailView.height //2017-03-20 max 196/177 (Premium/Free Acc)
                  + showMoreButton.height
                  + 2* TibiaStyle.marginRelated


  customButtonContainerData: [
    TibiaIconButton {
      id: showListButton
      sourceUp:   "/images/skin/classic/button-contextmenu-12x12-idle.png"
      sourceDown: "/images/skin/classic/button-contextmenu-12x12-pressed.png"
      tooltipText: qsTrId("spelllist_configure_tooltip")
      onClicked:  widgetController != null ? widgetController.onShowContextMenu() : undefined
    } //TibiaIconButton
  ] //customButtonContainerData

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.RightButton
    onClicked: widgetController != null ? widgetController.onShowContextMenu() : undefined
  } //MouseArea

  ColumnLayout {
    anchors.fill: parent
    spacing: 0

    TibiaTextSearchField {
      id: searchField
      Layout.fillWidth: true

      onSearchTextChanged: {
        if (spellList.model != null) {
          spellList.model.filterText = searchText;
        }
      } //onSearchTextChanged

      onActiveFocusChanged: {
        if (widgetController != null) {
          if (activeFocus) {
            widgetController.takeFocus()
          } else {
            widgetController.releaseFocus()
          }
        }
      } //onActiveFocusChanged

      onEscPressedInSearchTextField: {
        if (widgetController != null) {
          widgetController.releaseFocus()
        }
      } //onEscPressedInSearchTextField
    } //TibiaTextSearchField


    TibiaScrollView {
      Layout.fillWidth: true
      Layout.fillHeight: true

      SpellList {
        id: spellList

        model: widgetController != null ? widgetController.spellListModel : null
        externalSelectedIndex: widgetController != null ? 0 : -1
        patternedBackground: true

        allowDrag: true
        parentWhileDragging: widgetController != null ? widgetController.gameWindowQuickItem : spellList
      } //SpellList
    } //TibiaScrollView

    TibiaHorizontalSeparator {
      id: separator
      Layout.fillWidth: true
    } //TibiaHorizontalSeparator

    GridLayout {
      id: detailView
      Layout.fillWidth: true
      Layout.leftMargin: TibiaStyle.marginNarrow
      columns: 2
      columnSpacing: TibiaStyle.marginRelated
      rowSpacing: -1

      // The text bindings below are updated whenever this property changes. This helps to refresh the list even when the
      // current index of the list doesn't change
      property int spellListBindingUpdateHelper: 0

      property bool detailInformationAvailable: widgetController != null
                                             && spellList.currentItem != null //needed to avoid acces to intermediate state
                                             && spellList.count > 0
                                             && spellList.currentIndex >= 0

      function getCurrentDataRole(roleName) {
        detailView.spellListBindingUpdateHelper; // Mentioning this property here adds it to the binding, causing the function to be reevaluated when the value changes
        if (detailView.detailInformationAvailable) {
          return widgetController.spellListModel.getDataWithRoleName(spellList.currentIndex, roleName);
        }
        return "";
      } //function getCurrentDataRole(roleName)

      Connections {
        target: widgetController != null ? widgetController.spellListModel : null
        function onDataChanged() {
          detailView.spellListBindingUpdateHelper += 1
        }
      }

      TibiaText {
        Layout.fillWidth: true
        Layout.columnSpan: 2
        horizontalAlignment: Text.AlignHCenter
        styleType: "ListValue"
        text: detailView.getCurrentDataRole("name")
      } //TibiaText

      TibiaText {
        Layout.alignment: Qt.AlignRight | Qt.AlignTop
        text: qsTrId("actionbar_tooltip_label_formula") + ":"
      } //TibiaText
      TibiaText {
        Layout.fillWidth: true
        Layout.preferredHeight: 26
        styleType: "ListValue"
        wrapMode: Text.WordWrap
        text: detailView.getCurrentDataRole("formulaRaw")
      } //TibiaText

      TibiaText {
        Layout.alignment: Qt.AlignRight
        text: qsTrId("vocation") + ":"
      } //TibiaText
      TibiaText {
        Layout.fillWidth: true
        styleType: "ListValue"
        text: detailView.getCurrentDataRole("allowedVocations")
      } //TibiaText

      TibiaText {
        Layout.alignment: Qt.AlignRight
        text: qsTrId("spelllist_label_spell_group") + ":"

        Tooltip {
          anchors.fill: parent
          text: qsTrId("spelllist_tooltip_spell_group")
        } //Tooltip
      } //TibiaText
      TibiaText {
        styleType: "ListValue"
        Layout.fillWidth: true
        text: detailView.getCurrentDataRole("groups")
      } //TibiaText

      TibiaText {
        Layout.alignment: Qt.AlignRight
        text: qsTrId("spelllist_label_spell_type") + ":"
      } //TibiaText
      TibiaText {
        Layout.fillWidth: true
        styleType: "ListValue"
        text: detailView.getCurrentDataRole("type")
      } //TibiaText

      TibiaText {
        Layout.alignment: Qt.AlignRight
        text: qsTrId("spelllist_label_damage_type") + ":"
      } //TibiaText
      TibiaText {
        Layout.fillWidth: true
        styleType: "ListValue"
        text: detailView.getCurrentDataRole("damagetype")
      } //TibiaText

      TibiaText {
        Layout.alignment: Qt.AlignRight
        text: qsTrId("cooldown") + ":"

        Tooltip {
          anchors.fill: parent
          text: qsTrId("spelllist_tooltip_spell_cooldown")
        } //Tooltip
      } //TibiaText
      TibiaText {
        Layout.fillWidth: true
        styleType: "ListValue"
        text: detailView.getCurrentDataRole("cooldowns");
      } //TibiaText

      TibiaText {
        Layout.alignment: Qt.AlignRight
        text: qsTrId("spelllist_label_spell_mana_soulpoints") + ":"

        Tooltip {
          anchors.fill: parent
          text: qsTrId("spelllist_tooltip_spell_mana_soulpoints")
        } //Tooltip
      } //TibiaText
      TibiaText {
        Layout.fillWidth: true
        styleType: "ListValue"
        text: detailView.detailInformationAvailable ? detailView.getCurrentDataRole("manaCost") + " / " + detailView.getCurrentDataRole("soulPointsCost") : ""
      } //TibiaText

      TibiaText {
        Layout.alignment: Qt.AlignRight
        text: qsTrId("spelllist_label_spell_min_level") + ":"
      } //TibiaText
      TibiaText {
        Layout.fillWidth: true
        styleType: "ListValue"
        text: detailView.getCurrentDataRole("minimumCasterLevel")
      } //TibiaText

      TibiaText {
        Layout.alignment: Qt.AlignRight
        text: qsTrId("spelllist_label_spell_premium") + ":"
      } //TibiaText
      TibiaText {
        Layout.fillWidth: true
        styleType: "ListValue"
        text: detailView.getCurrentDataRole("premiumOnly")
      } //TibiaText
    } //GridLayout
    TibiaButton {
      id: showMoreButton
      property int selectedSpellID: parseInt(detailView.getCurrentDataRole("enumId")) ?? 0
      text: qsTrId("spelllistwidget_show_more");
      Layout.preferredWidth: TibiaStyle.buttonWidthWide
      Layout.alignment: Qt.AlignHCenter
      Layout.margins: TibiaStyle.marginRelated
      enabled: selectedSpellID > 0
      onClicked: {
        if (spellListSidebarWidget.widgetController) {
          spellListSidebarWidget.widgetController.onShowMoreForSpell(selectedSpellID);
        }
      }
    }
  } //ColumnLayout

  Lenshelp {
    anchors.fill: parent
    triggerRect: mapFromItem(widgetRoot, 0, 0, widgetRoot.width, widgetRoot.height)
    caption: qsTrId("spelllistwidget_lenshelp_caption")
    content: qsTrId("spelllistwidget_lenshelp")
  } //Lenshelp

} // TibiaSidebarWidget
