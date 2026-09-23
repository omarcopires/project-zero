import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

import qmlcomponents

TibiaDialog {
  id: root

  caption: qsTrId("weapon_proficiency_reshape_dialog_caption")
  width: 652

  initialFocusItem: root
  KeyNavigation.tab: root
  KeyNavigation.backtab: root

  required property var controller

  onCancelPressedFunction: function() {
    if (controller != null) {
      controller.requestCancel();
    }
  } //onCancelPressedFunction

  ColumnLayout {
    id: mainLayout
    anchors.left: parent.left
    anchors.right: parent.right
    spacing: TibiaStyle.marginUnrelated

    TibiaText {
      text: qsTrId("weapon_proficiency_reshape_dialog_hint")
      Layout.fillWidth: true
      wrapMode: Text.Wrap
    }

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    }

    RowLayout {
      id: cardRowLayout
      spacing: TibiaStyle.marginUnrelated

      Repeater {
        model: root.controller.perkOffersModel
        ColumnLayout {
          WeaponProficiencyPerkCard {
            id: weaponProficiencyCard
            Layout.preferredWidth: 200
            isActive: true
            perkName: modelData.perkName
            perkDescription: modelData.perkDescription
            isShaped: true
            imageSource: modelData.imageSource
            hasAugmentEffect: modelData.hasAugmentEffect
            perkRank: modelData.perkRank
            augmentEffectImageSource: modelData.augmentEffectImageSource
          }
          TibiaButton {
            Layout.preferredWidth: weaponProficiencyCard.width
            Layout.preferredHeight: 34
            text: qsTrId("weapon_proficiency_reshape_replace_button")
            textFont: TibiaStyle.defaultTextFont
            onClicked: {
              controller.replacePerkSelected(index);
            }
          }
        }
      }
    } //RowLayout


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
        id: cancelButton
        text: qsTrId("cancel")
        onClicked: root.onCancelPressedFunction()
      } //TibiaButton
    } // RowLayout
  } // ColumnLayout
} // TibiaDialog
