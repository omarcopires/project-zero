import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.LegacyControls

import qmlcomponents

TibiaDialog {
  id: root

  caption: qsTrId("weapon_proficiency_shape_options_dialog_caption")
  width: 600

  initialFocusItem: root
  KeyNavigation.tab: root
  KeyNavigation.backtab: root

  required property var controller

  onCancelPressedFunction: function() {
    if (controller != null) {
      controller.requestClose();
    }
  } //onCancelPressedFunction


  ColumnLayout {
    id: mainLayout
    anchors { left: parent.left; right: parent.right; }
    spacing: TibiaStyle.marginUnrelated

    TibiaTextSearchField {
      Layout.fillWidth: true

      onSearchTextChanged: {
        controller.setFilterString(searchText);
      } //onSearchTextChanged
    } //TibiaTextSearchField

    TibiaTableView {
      id: optionsTable
      Layout.fillWidth: true
      Layout.preferredHeight: 450

      model: root.controller.perkOptionsModel

      headerVisible: true
      selectionMode: SelectionMode.NoSelection

      selection.onSelectionChanged: {
        if (selection.count > 0) {
          selection.clear();
        }
      } //selection.onSelectionChanged

      rowHeight: TibiaStyle.defaultTextLineHeight
        + TibiaStyle.marginRelated
        + TibiaStyle.proficiencyPerkSize
        * TibiaStyle.proficiencyPerkScaleFactor
        + TibiaStyle.marginRelated

      TableViewColumn {
        id: nameColumn
        role: "perkName"
        title: qsTrId("weapon_proficiency_shape_options_perk_column")
        width: optionsTable.contentItem.width
          - rank1Column.width
          - rank10Column.width
        delegate: Item {
          ColumnLayout{
            anchors {left: parent.left; top: parent.top; right: parent.right}
            anchors.topMargin: TibiaStyle.marginRelated
            spacing: TibiaStyle.marginRelated

            TibiaText {
              Layout.fillWidth: true
              horizontalAlignment: Text.AlignHCenter
              text: model?.perkName ?? ""
            } //TibiaText

            TibiaProficiencyPerk {
              Layout.alignment: Qt.AlignHCenter

              imageSource: model?.imageSource ?? ""
              hasAugmentEffect: model?.hasAugmentEffect ?? false
              augmentEffectImageSource: model?.augmentEffectImageSource ?? ""
              isShaped: false
              isActive: true
              perkRank: -1
            } //ProficiencyPerk
          } //ColumnLayout
        } //delegate: Item
      } //TableViewColumn

      TableViewColumn {
        id: rank1Column
        role: "perkDescriptionRank0"
        title: qsTrId("weapon_proficiency_shape_options_rank0_column")
        width: 200
        delegate: TibiaFrame1PixelDown {
          Rectangle {
            anchors.fill: parent
            anchors.margins: parent.borderWidth
            color: TibiaStyle.textFieldBackgroundColor
          } //Rectangle

          TibiaText {
            anchors.fill: parent
            anchors.margins: parent.marginsToContent
            wrapMode: Text.Wrap
            text: model?.perkDescriptionRank0 ?? ""
          } //TibiaText
        } //TibiaFrame1PixelDown
      } //TableViewColumn

      TableViewColumn {
        id: rank10Column
        role: "perkDescriptionRank0"
        title: qsTrId("weapon_proficiency_shape_options_rank10_column")
        width: 200
        delegate: TibiaFrame1PixelDown {
          Rectangle {
            anchors.fill: parent
            anchors.margins: parent.borderWidth
            color: TibiaStyle.textFieldBackgroundColor
          } //Rectangle

          TibiaText {
            anchors.fill: parent
            anchors.margins: parent.marginsToContent
            wrapMode: Text.Wrap
            text: model?.perkDescriptionRank10 ?? ""
          } //TibiaText
        } //TibiaFrame1PixelDown
      } //TableViewColumn
    } //TibiaTableView

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } // TibiaHorizontalSeparator

    RowLayout {
      spacing: TibiaStyle.marginUnrelated

      Item {
        // Padding
        Layout.fillWidth: true
        Layout.preferredHeight: 1
      } //Item

      TibiaButton {
        id: closeButton
        text: qsTrId("close")
        onClicked: root.onCancelPressedFunction()
      } //TibiaButton
    } // RowLayout
  } // ColumnLayout
} // TibiaDialog
