import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import qmlcomponents



TibiaDialog {
  id: root
  caption: {
    // fusion result caption
    if (root.isFusion) {
      return root.isConvergence ? qsTrId("exaltation_result_convergence_fusion_caption") : qsTrId("exaltation_result_fusion_caption")
    }
    // transfer result caption
    return root.isConvergence ? qsTrId("exaltation_result_convergence_transfer_caption") : qsTrId("exaltation_result_transfer_caption")
  }
  width: 400
  headerDelegate: DialogHeaderDragon {}

  property var controller: null

  property bool smoothTextureFiltering: controller != null && controller.smoothTextureFiltering
  property bool isFusion: controller != null && controller.isFusion
  property bool isConvergence: controller != null && controller.isConvergence
  property bool wasSuccessful: controller != null && controller.wasSuccessful
  property int resultObjectUpgradeTier: controller != null ? controller.resultObjectUpgradeTier : 0
  property int fusionBonus: controller != null && controller.fusionBonus
  property bool bonusStage: false

  readonly property bool softwareRenderBackup: GlobalConstants.isSoftwareRenderer
  readonly property int coverBonusMargin: 10

  readonly property int blinkNormalMs: 200
  readonly property int blinkFastDivisor: 2
  readonly property int arrowFactor: 1
  readonly property int blinkFastMs: blinkNormalMs / blinkFastDivisor
  readonly property int arrowTimeMs: blinkNormalMs * arrowFactor * 2

  onVisibleChanged: resetPropertiesAndStartAnimation()
  onIsFusionChanged: resetPropertiesAndStartAnimation()
  onWasSuccessfulChanged: resetPropertiesAndStartAnimation()

  initialFocusItem: root
  KeyNavigation.tab: root
  KeyNavigation.backtab: root

  onReturnPressedFunction: function() {
  }

  onCancelPressedFunction: function() {
  }

 function onButtonClicked() {
   if (controller != null && dialogButton.enabled) {
     if (   root.bonusStage
         || !root.isFusion
         || root.fusionBonus == TibiaEnums.FusionBonusEffectNone) {
       controller.requestClose();
     } else {
       showBonusStage();
     }
   }
 } //function onButtonClicked

  function showBonusStage() {
    bonusStage = true;
    dialogButton.text = qsTrId("close")
  } // function showBonusStage()

  property bool showLeftAtTheEnd: false
  property bool showRightAtTheEnd: false
  property color rightCoverColor: TibiaStyle.black2
  property color rightFadeColor: TibiaStyle.white4
  property int startTargetUpgradeTier: resultObjectUpgradeTier
  property string buttonTextAtTheEnd: qsTrId("close")

  function resetPropertiesAndStartAnimation() {
    animation.stop()

    leftObject.visible = true;
    rightObject.visible = true;
    leftObject.opacity = 1.0;
    rightObject.opacity = 1.0;
    leftObjectColorOverlay.opacity = 1.0;
    rightObjectColorOverlay.opacity = 1.0;
    resultText.opacity = 0.0;
    arrow1.source = "/images/icon-arrow-rightlarge.png"
    arrow2.source = "/images/icon-arrow-rightlarge.png"
    arrow3.source = "/images/icon-arrow-rightlarge.png"
    root.bonusStage = false;
    dialogButton.text = "";

    if (root.visible) {
      if (root.isFusion && root.wasSuccessful) {
        showLeftAtTheEnd = false;
        showRightAtTheEnd = true;
        rightCoverColor = TibiaStyle.black2;
        rightFadeColor = TibiaStyle.white4;
        startTargetUpgradeTier = resultObjectUpgradeTier;
      } else if (root.isFusion && !root.wasSuccessful) {
        showLeftAtTheEnd = true;
        showRightAtTheEnd = false;
        rightCoverColor = TibiaStyle.black2;
        rightFadeColor = TibiaStyle.red3;
        startTargetUpgradeTier = resultObjectUpgradeTier;
      } else if (!root.isFusion) {
        showLeftAtTheEnd = false;
        showRightAtTheEnd = true;
        rightCoverColor = TibiaStyle.transparent;
        rightFadeColor = TibiaStyle.white4;
        startTargetUpgradeTier = 0;
      }

      if (root.fusionBonus == TibiaEnums.FusionBonusEffectNone) {
        buttonTextAtTheEnd = qsTrId("close");
      } else  {
        buttonTextAtTheEnd = qsTrId("next");
      }

      animation.restart();
    }
  } //function resetPropertiesAndStartAnimation

  SequentialAnimation {
    id: animation
    running: false
    loops: 1
    alwaysRunToEnd: false

    //1000 Item left normal; right black
    PropertyAction { target: leftObjectColorOverlay;  property: "color"; value: TibiaStyle.transparent }
    PropertyAction { target: rightObjectColorOverlay; property: "color"; value: root.rightCoverColor }
    PropertyAction { target: rightObject; property: "upgradeTier"; value: root.startTargetUpgradeTier }
    PauseAnimation { duration: 1000 }

    //200 Item left white
    PropertyAction { target: leftObjectColorOverlay;  property: "color"; value: TibiaStyle.white4 }

    ParallelAnimation {
      SequentialAnimation {
        //200|200 blinking left item
        SequentialAnimation {
          loops: (4*root.arrowTimeMs) / (2*root.blinkNormalMs)
          PauseAnimation { duration: root.blinkNormalMs }
          PropertyAction { target: leftObjectColorOverlay; property: "color"; value: TibiaStyle.transparent }
          PauseAnimation { duration: root.blinkNormalMs }
          PropertyAction { target: leftObjectColorOverlay; property: "color"; value: TibiaStyle.white4 }
        } //SequentialAnimation

        //100|100 blinkinf left item
        SequentialAnimation {
          loops: (2*root.arrowTimeMs) / (2*root.blinkFastMs)
          PauseAnimation { duration: root.blinkFastMs }
          PropertyAction { target: leftObjectColorOverlay; property: "color"; value: TibiaStyle.transparent }
          PauseAnimation { duration: root.blinkFastMs }
          PropertyAction { target: leftObjectColorOverlay; property: "color"; value: TibiaStyle.white4 }
        } //SequentialAnimation
      }//SequentialAnimation

      //400 fill and empty arrows
      SequentialAnimation {
        PauseAnimation { duration: root.arrowTimeMs }
        PropertyAction { target: arrow1;  property: "source"; value: "/images/icon-arrow-rightlarge-filled.png" }
        PauseAnimation { duration: root.arrowTimeMs }
        PropertyAction { target: arrow2;  property: "source"; value: "/images/icon-arrow-rightlarge-filled.png" }
        PauseAnimation { duration: root.arrowTimeMs }
        PropertyAction { target: arrow3;  property: "source"; value: "/images/icon-arrow-rightlarge-filled.png" }
        PauseAnimation { duration: root.arrowTimeMs }
        PropertyAction { target: arrow1;  property: "source"; value: "/images/icon-arrow-rightlarge.png" }
        PauseAnimation { duration: root.arrowTimeMs }
        PropertyAction { target: arrow2;  property: "source"; value: "/images/icon-arrow-rightlarge.png" }
        PauseAnimation { duration: root.arrowTimeMs }
        PropertyAction { target: arrow3;  property: "source"; value: "/images/icon-arrow-rightlarge.png" }
      } //SequentialAnimation
    } //ParallelAnimation

    //100 both white
    PropertyAction { target: rightObjectColorOverlay; property: "color"; value: root.rightFadeColor }
    PropertyAction { target: rightObject; property: "upgradeTier"; value: root.resultObjectUpgradeTier }
    PropertyAction { target: leftObject;  property: "visible"; value: root.showLeftAtTheEnd || root.softwareRenderBackup }
    PropertyAction { target: rightObject; property: "visible"; value: root.showRightAtTheEnd || root.softwareRenderBackup }

    PauseAnimation { duration: 100 }

    //1000 left white to nothing; right white to item
    ParallelAnimation {
      PropertyAnimation { target: leftObjectColorOverlay;  property: "opacity"; from: 1.0; to: 0.0; easing.type: Easing.InQuad; duration: 1000 }
      PropertyAnimation { target: rightObjectColorOverlay; property: "opacity"; from: 1.0; to: 0.0; easing.type: Easing.InQuad; duration: 1000 }
      PropertyAnimation { target: leftObject;  property: "opacity";
                          from: !root.softwareRenderBackup ? 1.0 : (root.showLeftAtTheEnd ? 0.0 : 1.0);
                          to:   !root.softwareRenderBackup ? 1.0 : (root.showLeftAtTheEnd ? 1.0 : 0.0);
                          easing.type: Easing.Linear; duration: 1000 }
      PropertyAnimation { target: rightObject;  property: "opacity";
                          from: !root.softwareRenderBackup ? 1.0 : (root.showRightAtTheEnd ? 0.0 : 1.0);
                          to:   !root.softwareRenderBackup ? 1.0 : (root.showRightAtTheEnd ? 1.0 : 0.0);
                          easing.type: Easing.Linear; duration: 1000 }
    } //ParallelAnimation

    PropertyAction { target: leftObject;  property: "visible"; value: root.showLeftAtTheEnd }
    PropertyAction { target: rightObject; property: "visible"; value: root.showRightAtTheEnd }

    //50 show result text
    PropertyAnimation { target: resultText;  property: "opacity"; to: 1.0; duration: 50 }
    PropertyAction { target: dialogButton; property: "text"; value: root.buttonTextAtTheEnd }
  } //SequentialAnimation

  ColumnLayout {
    anchors { left: parent.left; right: parent.right }
    spacing: TibiaStyle.marginUnrelated

    RowLayout {
      visible: !root.bonusStage
      spacing: 0

      Layout.topMargin: root.softwareRenderBackup ? root.coverBonusMargin : 0
      Layout.leftMargin: Layout.topMargin
      Layout.rightMargin: Layout.topMargin

      Item {
        Layout.preferredWidth: leftObject.width
        Layout.preferredHeight: leftObject.height

        ScalableObjectDisplay {
          id: leftObject
          showBackground: false
          scaleFactor: TibiaStyle.exaltationForgeItemScaleFactor
          animated: true
          smoothTextureFiltering: root.smoothTextureFiltering

          typeid: controller != null ? controller.inputObjectTypeId : 0
          upgradeTier: controller != null ? controller.inputObjectUpgradeTier : 0
        } //ScalableObjectDisplay

        ColorOverlay {
          id: leftObjectColorOverlay
          width: leftObject.width
          height: leftObject.height
          anchors.centerIn: leftObject

          visible: !root.softwareRenderBackup

          source: leftObject
          color: TibiaStyle.transparent
        } //ColorOverlay

        Rectangle {
          id: leftCover
          anchors.centerIn: leftObject
          width: leftObject.width + 2 * root.coverBonusMargin
          height: width
          radius: 3 * root.coverBonusMargin

          visible: root.softwareRenderBackup
          color: leftObjectColorOverlay.color
          opacity: leftObjectColorOverlay.opacity
        } //Rectangle
      } //Item

      Item {
        Layout.fillWidth: true
      } //Item

      RowLayout {
        spacing: TibiaStyle.marginRelated
        Layout.alignment: Qt.AlignVCenter

        Image {
          id: arrow1
          source: "/images/icon-arrow-rightlarge.png"
        } //Image

        Image {
          id: arrow2
          source: "/images/icon-arrow-rightlarge.png"
        } //Image

        Image {
          id: arrow3
          source: "/images/icon-arrow-rightlarge.png"
        } //Image
      } //RowLayout

      Item {
        Layout.fillWidth: true
      } //Item

      Item {
        Layout.preferredWidth: rightObject.width
        Layout.preferredHeight: rightObject.height

        ScalableObjectDisplay {
          id: rightObject
          showBackground: false
          scaleFactor: TibiaStyle.exaltationForgeItemScaleFactor
          animated: true
          smoothTextureFiltering: root.smoothTextureFiltering

          typeid: controller != null ? controller.resultObjectTypeId : 0
          upgradeTier: root.resultObjectUpgradeTier
        } //ScalableObjectDisplay

        ColorOverlay {
          id: rightObjectColorOverlay
          width: rightObject.width
          height: rightObject.height
          anchors.centerIn: rightObject

          visible: !root.softwareRenderBackup

          source: rightObject
          color: TibiaStyle.transparent
        } //ColorOverlay

        Rectangle {
          id: rightCover
          anchors.centerIn: rightObject
          width: rightObject.width + 2 * root.coverBonusMargin
          height: width
          radius: 3 * root.coverBonusMargin

          visible: root.softwareRenderBackup
          color: rightObjectColorOverlay.color
          opacity: rightObjectColorOverlay.opacity
        } //Rectangle
      } //Item
    } //RowLayout

    TibiaText {
      id: resultText
      Layout.fillWidth: true
      Layout.preferredHeight: 40
      horizontalAlignment: Text.AlignHCenter
      textFormat: Text.RichText
      wrapMode: Text.Wrap

      visible: !root.bonusStage
      text: {
        var resultText = "";
        if (root.isFusion) {
          if (root.wasSuccessful) {
            resultText = qsTrId("exaltation_result_fusion_result_success").arg(TibiaStyle.green1);
          } else {
            resultText = qsTrId("exaltation_result_fusion_result_fail").arg(TibiaStyle.red2);
          }
        } else {
          resultText = qsTrId("exaltation_result_transfer_result").arg(TibiaStyle.green1);
        }
        return resultText;
      }
      opacity: 0
    } //TibiaText

    ScalableObjectDisplay {
      id: bonusObject
      Layout.alignment: Qt.AlignHCenter

      showBackground: false
      scaleFactor: TibiaStyle.exaltationForgeItemScaleFactor
      animated: true
      smoothTextureFiltering: root.smoothTextureFiltering
      cumulativeCount: 100

      visible: root.bonusStage
      typeid: {
        var typeId = 0;

        if (   root.fusionBonus == TibiaEnums.FusionBonusEffectNoDustCost
            || root.fusionBonus == TibiaEnums.FusionBonusEffectBackfillDust) {
          typeId = TibiaStyle.exaltedDustId;
        } else if (root.fusionBonus == TibiaEnums.FusionBonusEffectNoCoreCost) {
          typeId = TibiaStyle.exaltedCoreId;
        } else if (root.fusionBonus == TibiaEnums.FusionBonusEffectNoGoldCost) {
          typeId = TibiaStyle.goldCoinId;
        } else if (   root.fusionBonus == TibiaEnums.FusionBonusEffectDowngradeResourceObject
                   || root.fusionBonus == TibiaEnums.FusionBonusEffectKeepResourceObject
                   || root.fusionBonus == TibiaEnums.FusionBonusEffectUpgradeResourceObject
                   || root.fusionBonus == TibiaEnums.FusionBonusEffectDoubleUpgrade
                   || root.fusionBonus == TibiaEnums.FusionBonusEffectTierLossPreventionTriggered) {
          typeId = controller != null ? controller.bonusObjectTypeId : 0;
        }

        return typeId;
      }
      upgradeTier: {
        var tier = 0;

        if (   root.fusionBonus == TibiaEnums.FusionBonusEffectDowngradeResourceObject
            || root.fusionBonus == TibiaEnums.FusionBonusEffectKeepResourceObject
            || root.fusionBonus == TibiaEnums.FusionBonusEffectUpgradeResourceObject
            || root.fusionBonus == TibiaEnums.FusionBonusEffectDoubleUpgrade
            || root.fusionBonus == TibiaEnums.FusionBonusEffectTierLossPreventionTriggered) {
          tier = controller != null ? controller.bonusObjectUpgradeTier : 0;
        }

        return tier;
      }
    } //ScalableObjectDisplay

    TibiaText {
      id: bonusText
      Layout.fillWidth: true
      Layout.preferredHeight: resultText.Layout.preferredHeight
      horizontalAlignment: Text.AlignHCenter
      textFormat: Text.RichText
      wrapMode: Text.Wrap

      visible: root.bonusStage
      text: {
        var resultText = "";
        if (controller != null) {
          if (root.fusionBonus == TibiaEnums.FusionBonusEffectNoDustCost) {
            resultText = qsTrId("exaltation_result_bonus_no_dust_cost").arg(controller.dustCost);
          } else if (root.fusionBonus == TibiaEnums.FusionBonusEffectNoCoreCost) {
            if (controller.coreCount == 1) {
              resultText = qsTrId("exaltation_result_bonus_no_core_cost_singular")
            } else {
              resultText = qsTrId("exaltation_result_bonus_no_core_cost_plural").arg(controller.coreCount)
            }
          } else if (root.fusionBonus == TibiaEnums.FusionBonusEffectNoGoldCost) {
            resultText = qsTrId("exaltation_result_bonus_no_gold_cost").arg(TextHelper.formatNumberWithThousandSeparators(controller.goldCost));
          } else if (root.fusionBonus == TibiaEnums.FusionBonusEffectDowngradeResourceObject) {
            resultText = qsTrId("exaltation_result_bonus_downgrade_resource_object");
          } else if (root.fusionBonus == TibiaEnums.FusionBonusEffectKeepResourceObject) {
            resultText = qsTrId("exaltation_result_bonus_keep_resource_object");
          } else if (root.fusionBonus == TibiaEnums.FusionBonusEffectUpgradeResourceObject) {
            resultText = qsTrId("exaltation_result_bonus_upgrade_resource_object");
          } else if (root.fusionBonus == TibiaEnums.FusionBonusEffectDoubleUpgrade) {
            resultText = qsTrId("exaltation_result_bonus_upgrade_double_upgrade");
          } else if (root.fusionBonus == TibiaEnums.FusionBonusEffectTierLossPreventionTriggered) {
            if (controller.bonusObjectUpgradeTier == 0) {
              resultText = qsTrId("exaltation_result_bonus_tier_loss_prevention_triggered_tier0");
            } else {
              resultText = qsTrId("exaltation_result_bonus_tier_loss_prevention_triggered");
            }
          } else if (root.fusionBonus == TibiaEnums.FusionBonusEffectBackfillDust) {
            resultText = qsTrId("exaltation_result_bonus_backfill_dust");
          }
        }
        return resultText;
      }
    } //TibiaText

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } // TibiaHorizontalSeparator

    RowLayout {
      id: buttonBar
      Layout.fillWidth: true
      spacing: TibiaStyle.marginRelated

      Item {
        // Padding
        Layout.fillWidth: true
        height: 1
      } //Item

      TibiaButton {
        id: dialogButton
        enabled: text.length != 0
        text: ""
        onClicked: onButtonClicked()

        TibiaDisabledOverlay {
          anchors.fill: parent
          anchors.margins: 1
          visible: !parent.enabled
        } //TibiaDisabledOverlay
      } //TibiaButton
    } // RowLayout
  } // ColumnLayout
} // TibiaDialog
