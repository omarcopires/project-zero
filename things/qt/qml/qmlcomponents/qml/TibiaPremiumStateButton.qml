import QtQuick

TibiaButton {
  id: root
  property bool hasPremium: false

  implicitWidth: TibiaStyle.premiumStateButtonWidth
  implicitHeight: flat ? TibiaStyle.premiumStateButtonHeightFlat
                       : TibiaStyle.premiumStateButtonHeight

  checkable: root.hasPremium
  checked: root.hasPremium
  enabled: !root.hasPremium
  color: root.hasPremium ? "grey" : "blue"
  imageSource: root.hasPremium ? "/images/dailyreward/icon-have-premium.png" : "/images/dailyreward/icon-get-premium.png"
  imageSourceDisabled: imageSource

  tooltipText: qsTrId("get_premium")
} //TibiaButton
