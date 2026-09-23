import QtQuick
import QtQuick.Layouts
import qmlcomponents



ColumnLayout {
  id: conversionTabRoot
  spacing: TibiaStyle.marginRelated

  property var controller: null
  property bool smoothTextureFiltering: false

  property var currentHoverOwner: null

  Connections {
    target: conversionTabRoot.controller

    function onIncreaseDustLimitValueChanged() {
      if (conversionTabRoot.currentHoverOwner === increaseDustLimit) {
        increaseDustLimit.showButtonHoverText();
      }
    }
  }

  RowLayout {
    spacing: TibiaStyle.marginRelated

    ExaltationForgeConversionPanel {
      id: convertDust
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignTop

      function missingResources() {
        return storeAndResourceBalanceHelper.exaltedDustBalance < conversionSourceAmount
      }

      function buttonHoverText() {
        if (!missingResources()) {
          return qsTrId("exaltation_forge_conversion_convert_dust_button_hover")
            .arg(controller != null ? controller.convertDustToSliversCost : 0)
            .arg(controller != null ? controller.convertDustToSliversResult : 0);
        } else {
          return qsTrId("exaltation_forge_conversion_convert_dust_button_missing_resources_hover");
        }
      }

      function actionText() {
        return qsTrId("exaltation_forge_conversion_convert_dust_action")
        .arg(controller != null ? controller.convertDustToSliversResult : 0);
      }

      function hoverText() {
        return qsTrId("exaltation_forge_conversion_convert_dust_panel_hover");
      }

      caption: qsTrId("exaltation_forge_conversion_convert_dust")
      conversionSourceTypeId: TibiaStyle.exaltedDustId
      conversionSourceIconId: "Dust"
      conversionTargetTypeId: TibiaStyle.exaltedslivertId
      actionCaption: actionText()
      tooltipText: qsTrId("exaltation_forge_conversion_convert_dust")
      conversionSourceAmount: controller != null ? controller.convertDustToSliversCost : 0
      tooLowBalance: missingResources()
      clientSettingSmoothFiltering: conversionTabRoot.smoothTextureFiltering

      onClicked: if (controller != null) controller.convertDust()
      onShowPanelHoverText: displayHoverText.text = hoverText()
      onShowButtonHoverText: {
        conversionTabRoot.currentHoverOwner = convertDust;
        displayHoverText.text = buttonHoverText();
      }

      onHideHoverText: {
        if (conversionTabRoot.currentHoverOwner === convertDust) {
          conversionTabRoot.currentHoverOwner = null;
        }
        displayHoverText.text = "";
      }
    } //ExaltationForgeConversionPanel

    ExaltationForgeConversionPanel {
      id: convertSlivers
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignTop

      function missingResources() {
        return storeAndResourceBalanceHelper.exaltedSliversCount < conversionSourceAmount
      }

      function buttonHoverText() {
        if (!missingResources()) {
          return qsTrId("exaltation_forge_conversion_convert_slivers_button_hover")
            .arg(controller != null ? controller.convertSliversToCoresCost : 0);
        } else {
          return qsTrId("exaltation_forge_conversion_convert_slivers_button_missing_resources_hover");
        }
      }

      function actionText() {
        return qsTrId("exaltation_forge_conversion_convert_slivers_action")
        .arg(controller != null ? controller.convertSliversToCoresResult : 0);
      }

      function hoverText() {
        return qsTrId("exaltation_forge_conversion_convert_slivers_panel_hover");
      }

      caption: qsTrId("exaltation_forge_conversion_convert_slivers")
      conversionSourceTypeId: TibiaStyle.exaltedslivertId
      conversionSourceIconId: "Slivers"
      conversionTargetTypeId: TibiaStyle.exaltedCoreId
      actionCaption: actionText()
      tooltipText: qsTrId("exaltation_forge_conversion_convert_slivers")
      conversionSourceAmount: controller != null ? controller.convertSliversToCoresCost : 0
      tooLowBalance: missingResources()
      clientSettingSmoothFiltering: conversionTabRoot.smoothTextureFiltering

      onClicked: if (controller != null) controller.convertSlivers()
      onShowPanelHoverText: displayHoverText.text = hoverText()

      onShowButtonHoverText: {
        conversionTabRoot.currentHoverOwner = convertSlivers;
        displayHoverText.text = buttonHoverText();
      }

      onHideHoverText: {
        if (conversionTabRoot.currentHoverOwner === convertSlivers) {
          conversionTabRoot.currentHoverOwner = null;
        }
        displayHoverText.text = "";
      }
    } //ExaltationForgeConversionPanel

    ExaltationForgeConversionPanel {
      id: increaseDustLimit
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignTop

      readonly property int increaseDustLimitCost: controller != null ? controller.increaseDustLimitCost : 0

      function missingResources() {
        return storeAndResourceBalanceHelper.exaltedDustBalance < increaseDustLimit.increaseDustLimitCost
      }

      function buttonHoverText() {
        if (maxDustLimitReached()) {
          return qsTrId("exaltation_forge_conversion_increase_dust_limit_maximum_action");
        } else if (!missingResources()) {
          var currentDustLimit = controller != null ? controller.currentDustLimit : 0
          var increaseDustLimitResult = controller != null ? controller.increaseDustLimitResult : 0
          return qsTrId("exaltation_forge_conversion_increase_dust_limit_button_hover")
            .arg(increaseDustLimit.increaseDustLimitCost)
            .arg(currentDustLimit)
            .arg(increaseDustLimitResult);
        } else {
          return qsTrId("exaltation_forge_conversion_increase_dust_limit_button_missing_resources_hover");
        }
      }

      function maxDustLimitReached() {
        return controller != null ? controller.maxDustLimitReached : false;
      }

      function actionText() {
        if (maxDustLimitReached()) {
          return qsTrId("exaltation_forge_conversion_increase_dust_limit_maximum_action")
        } else {
          return qsTrId("exaltation_forge_conversion_increase_dust_limit_action")
            .arg(controller != null ? controller.currentDustLimit : 0)
            .arg(controller != null ? controller.increaseDustLimitResult : 0)
        }
      }

      function hoverText() {
        return qsTrId("exaltation_forge_conversion_increase_dust_limit_panel_hover")
                  .arg(controller != null ? controller.currentDustLimit : 0);
      }

      caption: qsTrId("exaltation_forge_conversion_increase_dust_limit")
      conversionSourceTypeId: TibiaStyle.exaltedDustId
      conversionSourceIconId: "Dust"
      conversionTargetTypeId: TibiaStyle.exaltedDustId
      actionCaption: actionText()
      tooltipText: qsTrId("exaltation_forge_conversion_increase_dust_limit")
      conversionSourceAmount: maxDustLimitReached() ? "-" : increaseDustLimit.increaseDustLimitCost
      readOnly: maxDustLimitReached()
      tooLowBalance: missingResources() && !maxDustLimitReached()
      clientSettingSmoothFiltering: conversionTabRoot.smoothTextureFiltering
      showDoubleIcon: true

      onClicked: if (controller != null) controller.increaseDustLimit()
      onShowPanelHoverText: displayHoverText.text = hoverText()
      onShowButtonHoverText: {
        conversionTabRoot.currentHoverOwner = increaseDustLimit;
        displayHoverText.text = buttonHoverText();
      }

      onHideHoverText: {
        if (conversionTabRoot.currentHoverOwner === increaseDustLimit) {
          conversionTabRoot.currentHoverOwner = null;
        }
        displayHoverText.text = "";
      }
    } //ExaltationForgeConversionPanel
  } //RowLayout

  TibiaFrame2PixelUpFilled {
    Layout.fillWidth: true
    Layout.fillHeight: true

    TibiaText {
      id: displayHoverText
      anchors { left: parent.left; top: parent.top; right: parent.right }
      anchors.margins: TibiaStyle.marginRelated + parent.borderWidth
      wrapMode: Text.Wrap
      textFormat: Text.RichText
      text: ""
    } //TibiaText
  } //TibiaFrame2PixelUpFilled
} //ColumnLayout
