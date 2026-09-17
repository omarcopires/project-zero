import QtQuick

import qmlcomponents


Image {
  property var teamStatus: TibiaEnums.TeamFinderStatusNotInTeam

  source: {
    if (teamStatus == TibiaEnums.TeamFinderStatusRequest) {
      return "/images/icon-pending.png";
    } else if (teamStatus == TibiaEnums.TeamFinderStatusInvited) {
      return "/images/icon-invite.png";
    } else if (teamStatus == TibiaEnums.TeamFinderStatusAccepted) {
      return "/images/icon-yes.png";
    } else if (teamStatus == TibiaEnums.TeamFinderStatusRejected) {
      return "/images/icon-no.png";
    }
    return "";
  }
  Tooltip {
    anchors.fill: parent
    text: {
      if (teamStatus == TibiaEnums.TeamFinderStatusRequest) {
        return qsTrId("teamfinder_state_pending");
      } else if (teamStatus == TibiaEnums.TeamFinderStatusInvited) {
        return qsTrId("teamfinder_state_invited");
      } else if (teamStatus == TibiaEnums.TeamFinderStatusAccepted) {
        return qsTrId("teamfinder_state_accepted");
      } else if (teamStatus == TibiaEnums.TeamFinderStatusRejected) {
        return qsTrId("teamfinder_state_rejected");
      }
      return "";
    }
  } //Tooltip
} //Image
