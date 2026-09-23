import QtQuick
import QtQuick.Layouts
import qmlcomponents



RowLayout {
  spacing: 1
  implicitHeight: TibiaStyle.progressBarLargeHeight
  Layout.preferredHeight: TibiaStyle.progressBarLargeHeight
  Layout.fillHeight: false

  property int currentKills: 0
  property int killsToUnlockDetails1: 1
  property int killsToUnlockDetails2: 2
  property int killsToFullUnlock: 3
  property bool isFullyUnlocked: currentKills >= killsToFullUnlock
  property string colorInProgress: "orange"
  property string colorFull: "green"

  readonly property string barFillSource: isFullyUnlocked
    ? "/images/progressbar-" + colorFull + "-large.png"
    : "/images/progressbar-" + colorInProgress + "-large.png"

  function calculateFillPercentage(Maximum, Current)
  {
    if (!isFullyUnlocked) {
      var MaximumValue = Math.max(Maximum, 1.0);
      var CurrentValue = Math.min(Math.max(Current, 0.0), MaximumValue);
      return CurrentValue / MaximumValue;
    } else {
      return 1.0;
    }
  }

  TibiaProgressBar {
    Layout.fillHeight: true
    Layout.fillWidth: true
    fillPercentage: calculateFillPercentage(killsToUnlockDetails1, currentKills)

    frameSource: "/images/1pixel-down-frame.png"
    backgroundSource: "/images/backdrop-dark-grey.png"
    fillSource: barFillSource

    frameBorder { left: 1; right: 1; top:1; bottom: 1}
    fillOffset { left: 1; right: 1; top:1; bottom: 1}

    Tooltip {
      anchors.fill: parent
      text: qsTrId("monsters_unlock_state")
        .arg(TextHelper.formatNumberWithThousandSeparators(currentKills))
        .arg(TextHelper.formatNumberWithThousandSeparators(killsToUnlockDetails1))
        .arg(isFullyUnlocked ? qsTrId("monsters_fully_unlocked") : "")
    } // Tooltip
  } //TibiaProgressBar

  TibiaProgressBar {
    Layout.fillHeight: true
    Layout.fillWidth: true
    fillPercentage: calculateFillPercentage(killsToUnlockDetails2 - killsToUnlockDetails1,
                                            currentKills - killsToUnlockDetails1)

    frameSource: "/images/1pixel-down-frame.png"
    backgroundSource: "/images/backdrop-dark-grey.png"
    fillSource: barFillSource

    frameBorder { left: 1; right: 1; top:1; bottom: 1}
    fillOffset { left: 1; right: 1; top:1; bottom: 1}

    TibiaText {
      anchors.centerIn: parent
      text: TextHelper.formatNumberWithThousandSeparators(currentKills)
    } //TibiaText

    Tooltip {
      anchors.fill: parent
      text: qsTrId("monsters_unlock_state")
        .arg(TextHelper.formatNumberWithThousandSeparators(currentKills))
        .arg(TextHelper.formatNumberWithThousandSeparators(killsToUnlockDetails2))
        .arg(isFullyUnlocked ? qsTrId("monsters_fully_unlocked") : "")
    } // Tooltip
  } //TibiaProgressBar

  TibiaProgressBar {
    Layout.fillHeight: true
    Layout.fillWidth: true
    fillPercentage: calculateFillPercentage(killsToFullUnlock - killsToUnlockDetails2,
                                            currentKills - killsToUnlockDetails2)

    frameSource: "/images/1pixel-down-frame.png"
    backgroundSource: "/images/backdrop-dark-grey.png"
    fillSource: barFillSource

    frameBorder { left: 1; right: 1; top:1; bottom: 1}
    fillOffset { left: 1; right: 1; top:1; bottom: 1}

    Tooltip {
      anchors.fill: parent
      text: qsTrId("monsters_unlock_state")
        .arg(TextHelper.formatNumberWithThousandSeparators(currentKills))
        .arg(TextHelper.formatNumberWithThousandSeparators(killsToFullUnlock))
        .arg(isFullyUnlocked ? qsTrId("monsters_fully_unlocked") : "")
    } // Tooltip
  } //TibiaProgressBar
} // RowLayout
