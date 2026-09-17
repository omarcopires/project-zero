import QtQuick

import qmlcomponents


Image {
  property var dailyRewardState: TibiaEnums.DailyRewardStateNotAvailable

  source: {
    if (dailyRewardState == TibiaEnums.DailyRewardStateCollected) {
      return "/images/icon-dailyrewarddone.png";
    } else if (dailyRewardState == TibiaEnums.DailyRewardStateNotCollected) {
      return "/images/icon-dailyrewardready.png";
    } else if (dailyRewardState == TibiaEnums.DailyRewardStateNotAvailable) {
      return "/images/icon-dailyrewarddeactivated.png";
    }
    return "";
  }
  Tooltip {
    anchors.fill: parent
    text: {
      if (dailyRewardState == TibiaEnums.DailyRewardStateCollected) {
        return qsTrId("dailyreward_state_collected");
      } else if (dailyRewardState == TibiaEnums.DailyRewardStateNotCollected) {
        return qsTrId("dailyreward_state_not_collected");
      } else if (dailyRewardState == TibiaEnums.DailyRewardStateNotAvailable) {
        return qsTrId("dailyreward_state_not_available");
      }
      return "";
    }
  } //Tooltip
} //Image
