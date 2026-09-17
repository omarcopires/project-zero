import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qmlcomponents


TibiaDialog {
  id: inspectObjectDialog
  caption: qsTrId("inspect_object_caption")
  width: 450 + 2*TibiaStyle.dialogMarginBorder //450 is the with of the text field in inspect player dialog

  required property var controller

  onReturnPressedFunction: closeDialog
  onCancelPressedFunction: closeDialog

  function closeDialog() {
    if (controller != null) {
      controller.okButtonClicked();
    }
  } //function closeDialog

  initialFocusItem: inspectObjectDialog

  Component {
    id: inspectObjectView64x64

    ColumnLayout {
      property var inspectModel: modelData

      Layout.fillWidth: true
      spacing: TibiaStyle.marginRelated

      RowLayout {
        Layout.fillWidth: true
        spacing: TibiaStyle.marginRelated

        ScalableObjectDisplay {
          Layout.preferredWidth: TibiaStyle.inspectObjectSpriteOuterSize
          Layout.preferredHeight: TibiaStyle.inspectObjectSpriteOuterSize
          scaleFactor: TibiaStyle.inspectObjectScaleFactor
          smoothTextureFiltering: controller != null && controller.clientSettingSmoothFiltering
          showBackground: false

          animated: true
          typeid: inspectModel.appearanceID
          cumulativeCount: inspectModel.objectCount
          upgradeTier: inspectModel.objectUpgradeTier
          liquidType: inspectModel.liquidType
          hookDirection: inspectModel.hookDirection
          decoItemObjectID: inspectModel.decoItemObjectID
        } //ScalableObjectDisplay

        TibiaText {
          Layout.fillWidth: true
          Layout.alignment: Qt.AlignBottom | Qt.AlignLeft
          text: qsTrId("inspect_inspecting").arg(inspectModel.objectName)
          wrapMode: Text.Wrap
        } //TibiaText

        Repeater {
          model: inspectModel.imbumentIcons

          BorderImage {
            Layout.preferredWidth: TibiaStyle.inspectObjectSpriteOuterSize
            Layout.preferredHeight: TibiaStyle.inspectObjectSpriteOuterSize
            border { left: 1; right: 1; top: 1; bottom: 1 }
            source: "/images/1pixel-down-frame.png"
            horizontalTileMode: BorderImage.Repeat
            verticalTileMode: BorderImage.Repeat

            Image {
              anchors.centerIn: parent
              source: modelData
            } //Image
          } //BorderImage
        } //Repeater
      } //RowLayout

      TibiaTextArea {
        id: objectInformation
        Layout.fillWidth: true
        Layout.preferredHeight: 150
        text: inspectModel.objectInformation
        readOnly: true
        wrapMode: TextEdit.Wrap
        KeyNavigation.tab: inspectObjectDialog
        textFormat: TextEdit.RichText
      } //TibiaTextArea
    } //ColumnLayout
  } //Component

  ColumnLayout {
    anchors { left: parent.left; right: parent.right }
    spacing: TibiaStyle.marginUnrelated

    TibiaScrollView {
      id: inspectObjectScrollView
      Layout.fillWidth: true
      Layout.preferredHeight: Math.min(460, inspectObjectViews.height)

      verticalScrollBarPolicy: ScrollBar.AsNeeded

      Flickable {
        boundsBehavior: Flickable.StopAtBounds
        interactive: false //prevent flick behavior on touch screens

        contentHeight: inspectObjectViews.height
        contentWidth: inspectObjectViews.width

        ColumnLayout {
          id: inspectObjectViews
          width: inspectObjectScrollView.width - (height > inspectObjectScrollView.height ? (12+TibiaStyle.marginRelated) : 0)
          spacing: TibiaStyle.marginUnrelated

          Repeater {
            model: controller != null ? controller.inspectObjectList : null

            delegate: inspectObjectView64x64
          } //Repeater
        } //ColumnLayout
      } //Flickable
    } //TibiaScrollView

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } //TibiaHorizontalSeparator

    RowLayout {
      Layout.alignment: Qt.AlignRight
      spacing: TibiaStyle.marginRelated

      TibiaIconButton {
        sourceUp: "/images/button-copytoclipboard-up.png"
        sourceDown: "/images/button-copytoclipboard-down.png"
        tooltipText: qsTrId("inspect_copy_information")

        onClicked: {
          if (controller != null) {
            controller.copyToClipboarClicked();
          }
        } //onClicked
      } //TibiaIconButton

      Item {Layout.fillWidth: true}

      TibiaButton {
        text: qsTrId("inspect_open_weapon_proficiency_dialog")
        tooltipText: qsTrId("inspect_open_weapon_proficiency_dialog_tooltip")
        visible: inspectObjectDialog.controller != null && inspectObjectDialog.controller.showProficiencyButton
        Layout.preferredWidth: TibiaStyle.buttonWidthBroad

        onClicked: {
          inspectObjectDialog.controller.openWeaponProficiencyDialogClicked();
        }
      } // TibiaButton

      TibiaButton {
        text: qsTrId("close")

        onClicked: inspectObjectDialog.closeDialog();
      } // TibiaButton
    } // RowLayout
  } // ColumnLayout
} // TibiaDialog
