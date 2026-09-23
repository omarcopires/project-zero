import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import qmlcomponents
import "qrc:/qt/qml/qmlcomponents/qml"

Item {
  id: root

  required property var controller
  property var bannersToShow: []
  property var currentlyShownBannerData: null

  readonly property int _DEFAULT_DURATION: 3500

  anchors.fill: parent
  anchors.topMargin: 26
  
  function processNextBanner() {
    if (infoBannerLoader.item != null)
      return;
    
    if (bannersToShow.length > 0) {
      let info = bannersToShow.shift();
      let bannerTypeInfo =  bannerTypeToInfo(info.type, info.data);
      infoBannerLoader.sourceComponent = bannerComponent;
      infoBannerLoader.item.caption = bannerTypeInfo.caption;
      infoBannerLoader.item.text = bannerTypeInfo.text;
      infoBannerLoader.item.iconData = {
        "infoBannerType": info.type,
        "extraData": info.data
      }
      root.currentlyShownBannerData = info;
      infoBannerLoader.item.openBanner();
    }
  }

  Connections {
    target: root.controller
    function onShowInfoBanner(infoBannerType, extraData) {

      let compareFunction = function(banner) {
        return banner.type === infoBannerType &&
               JSON.stringify(banner.data) === JSON.stringify(extraData);
      }

      const sameBannerExistsInQueue = root.bannersToShow.some(function(banner) {
        return compareFunction(banner);
      });
      const aBannerIsCurrentlyShown = root.currentlyShownBannerData !== null;
      const newBannerIsAllowed = root.bannersToShow.length < (5 - (aBannerIsCurrentlyShown ? 1 : 0));
      if (newBannerIsAllowed && ((aBannerIsCurrentlyShown && compareFunction(root.currentlyShownBannerData) == false) || !aBannerIsCurrentlyShown) && !sameBannerExistsInQueue) {
        root.bannersToShow.push( {
          "type": infoBannerType,
          "data": extraData
        });
        processNextBanner();
      }
    }

    function onClearInfoBannerQueue() {
      bannersToShow = [];
    }
  }

  Loader {
    id: infoBannerLoader
    sourceComponent: undefined
    anchors.horizontalCenter: parent.horizontalCenter
  }
  Component {
    id: bannerComponent
    InfoBanner {
      id: infoBanner
      duration: root._DEFAULT_DURATION
      onFinished: {
        root.currentlyShownBannerData = null;
        infoBannerLoader.sourceComponent = undefined;
        processNextBanner();
      }
    }
  }

  function bannerTypeToInfo(bannerType, extraData) {
    function createInfo(caption, text) {
      return {
        "caption": caption,
        "text": text,
        "data": extraData,
      };
    }
    function createSimpleInfo(qtlabelId) {
      return {
        "caption": qsTrId(`info_banner_${qtlabelId}_caption`),
        "text": qsTrId(`info_banner_${qtlabelId}_text`),
        "data": extraData,
      };
    }

    switch(bannerType) {
      case TibiaEnums.InfoBannerTypeAutoAttackSpamming:
        return createSimpleInfo("auto_attack_spamming");
      case TibiaEnums.InfoBannerTypeCapacityWarning:
        return createSimpleInfo("capacity_warning");
      case TibiaEnums.InfoBannerTypeOutOfAmmunition:
        return createSimpleInfo("ammunition_depleted");
      case TibiaEnums.InfoBannerTypeAdjacentTargetAttacked:
        return createSimpleInfo("adjacent_target");
      case TibiaEnums.InfoBannerTypeOutOfSoulpoints:
        return createSimpleInfo("soulpoints_depleted");
      case TibiaEnums.InfoBannerTypeLeaveNewhaven:
        return createSimpleInfo("leave_newhaven");
      case TibiaEnums.InfoBannerTypeWeeklyTaskAnyCreatureFinished:
        return createSimpleInfo("weekly_task_any_creature_finished");
      case TibiaEnums.InfoBannerTypePromotionUnlocked:
        return createSimpleInfo("promotion_unlocked");
     
      case TibiaEnums.InfoBannerTypeLevelUp: {
        const level = extraData.level ?? -1;
        if (level == 20) {
          return createInfo(qsTrId("info_banner_level_up_caption").arg(level), qsTrId("info_banner_promotion_text"));
        } else {
          return createInfo(qsTrId("info_banner_level_up_caption").arg(level), qsTrId("info_banner_level_up_text"));
        }
      }
      case TibiaEnums.InfoBannerTypeSkillUp: {
        const level = extraData.level ?? -1;
        const skillName = extraData.skill ?? "unknown";
        if (skillName != "unknown") {
          return createInfo(qsTrId(`charinfo_skill_${skillName}`), qsTrId("info_banner_skill_up_text").arg(level));
        }
      }
      case TibiaEnums.InfoBannerTypeBestiaryProgress:
      case TibiaEnums.InfoBannerTypeBosstiaryProgress: 
        const prefix = bannerType == TibiaEnums.InfoBannerTypeBestiaryProgress ? "bestiary" : "bosstiary"
        const name = extraData.name ?? "unknown";
        const stage = extraData.stage ?? 1;
        if (stage == 1) {
          return createInfo(qsTrId(`info_banner_${prefix}_revealed_caption`), qsTrId(`info_banner_${prefix}_revealed_text`).arg(name));
        } else {
          return createInfo(qsTrId(`info_banner_${prefix}_stage_unlocked_caption`), qsTrId(`info_banner_${prefix}_stage_unlocked_text`).arg(name));
        }
        break;
      case TibiaEnums.InfoBannerTypeQuestProgress: {
        const name = extraData.name ?? "unknown";
        const progress = extraData.progress ?? "unknown"
        if (progress == "started") {
          return createInfo(qsTrId("info_banner_quest_started_caption"), qsTrId("info_banner_quest_started_text").arg(name));
        } else if (progress == "completed") {
          return createInfo(qsTrId("info_banner_quest_completed_caption"), qsTrId("info_banner_quest_completed_text").arg(name));
        }
        break;
      }
      case TibiaEnums.InfoBannerTypeAchievement: {
        const name = extraData.name ?? "unknown";
        if (name != "unknown") {
          return createInfo(qsTrId("info_banner_achievment_caption"), qsTrId("info_banner_achievment_text").arg(name));
        }
        break;
      }
      case TibiaEnums.InfoBannerTypeTitle: {
        const name = extraData.name ?? "unknown";
        if (name != "unknown") {
          return createInfo(qsTrId("info_banner_title_caption"), qsTrId("info_banner_title_text").arg(name));
        }
        break;
      }
      case TibiaEnums.InfoBannerTypeOutfitPartUnlocked: {
        const outfitid = extraData.outfitid ?? 0;
        const name = extraData.name ?? "unknown"
        const type = extraData.type ?? "unknown"
        if (name != "unknown" && type != "unknown") {
          switch (type) {
            case "outfit":
              return createInfo(qsTrId("info_banner_outfit_unlocked_caption"), qsTrId("info_banner_outfit_unlocked_text").arg(name));
            case "addon1":
              return createInfo(qsTrId("info_banner_addon_unlocked_caption"), qsTrId("info_banner_addon_unlocked_text").arg(name).arg(1));
            case "addon2":
              return createInfo(qsTrId("info_banner_addon_unlocked_caption"), qsTrId("info_banner_addon_unlocked_text").arg(name).arg(2));
            case "mount":
              return createInfo(qsTrId("info_banner_mount_unlocked_caption"), qsTrId("info_banner_mount_unlocked_text").arg(name));
          }
        }
        break;
      }
      case TibiaEnums.InfoBannerTypeWeaponProficency: {
        const name = extraData.name ?? "unknown";
        if (name != "unknown") {
          return createInfo(qsTrId("info_banner_weapon_proficency_caption"), qsTrId("info_banner_weapon_proficency_text").arg(name));
        }
        break;
      }
      case TibiaEnums.InfoBannerTypeBountyTaskFinished: {
        const name = extraData.name ?? "unknown";
        if (name != "unknown") {
          return createInfo(qsTrId("info_banner_bounty_task_finished_caption"), qsTrId("info_banner_bounty_task_finished_text").arg(name));
        }
        break;
      }
      case TibiaEnums.InfoBannerTypeWeeklyTaskSpecificCreatureFinished: {
        const name = extraData.name ?? "unknown";
        if (name != "unknown") {
          return createInfo(qsTrId("info_banner_weekly_task_specific_creature_finished_caption"), qsTrId("info_banner_weekly_task_specific_creature_finished_text").arg(name));
        }
        break;
      }
      case TibiaEnums.InfoBannerTypeSpellUnlocked: {
        const name = extraData.spellName ?? "";
        if (name) {
          return createInfo(qsTrId("info_banner_spell_unlocked_caption"), qsTrId("info_banner_spell_unlocked_text").arg(name));
        }
        break;
      }
      case TibiaEnums.InfoBannerTypeLeaderMonsterKilled: {
        const charmPoints = extraData.charmpoints ?? "";
        return createInfo(qsTrId("info_banner_leader_monster_killed_caption"), qsTrId("info_banner_leader_monster_killed_text").arg(charmPoints));
      }
      case TibiaEnums.InfoBannerTypeSubAreaUnlocked: {
        const name = extraData.subAreaName ?? "";
        if (name) {
          return createInfo(qsTrId("info_banner_subarea_unlocked_caption"), qsTrId("info_banner_subarea_unlocked_text").arg(name));
        }
        break;
      }
      case TibiaEnums.InfoBannerTypeAreaUnlocked: {
        const name = extraData.areaName ?? "";
        if (name) {
          return createInfo(qsTrId("info_banner_area_unlocked_caption"), qsTrId("info_banner_area_unlocked_text").arg(name));
        }
        break;
      }
    }
    return {};
  }
}
