import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import qmlcomponents
import "qrc:/qt/qml/qmlcomponents/qml"

Item {
  id: root

  property var iconData: {}

  onIconDataChanged: processIconData()

  implicitWidth: iconImage.implicitWidth
  implicitHeight: iconImage.implicitHeight

  Image {
    id: iconImage
  }

  function processIconData() {
    let bannerType = iconData ? iconData.infoBannerType : TibiaEnums.InfoBannerTypeAutoAttackSpamming
    let iconSource = "icon-infobanner-hint.png";
    switch(bannerType) {
      case TibiaEnums.InfoBannerTypeAutoAttackSpamming:
      case TibiaEnums.InfoBannerTypeCapacityWarning:
      case TibiaEnums.InfoBannerTypeOutOfAmmunition:
      case TibiaEnums.InfoBannerTypeAdjacentTargetAttacked:
      case TibiaEnums.InfoBannerTypeOutOfSoulpoints:
        iconSource = "icon-infobanner-hint.png";
        break;
      case TibiaEnums.InfoBannerTypeLeaveNewhaven:
        iconSource = "icon-infobanner-offtonewshores.png";
        break;
      case TibiaEnums.InfoBannerTypeLevelUp: 
        const level = root.iconData.extraData && root.iconData.extraData.level ? root.iconData.extraData.level : 0;
        iconSource = "icon-infobanner-levelup.png";
        if (level == 20) {
          iconSource = "icon-infobanner-promotion.png"
        }
        break;
      case TibiaEnums.InfoBannerTypeSkillUp: {
        const skillName = root.iconData.extraData.skill ?? "unknown";
        if (skillName != "unknown") {
          iconSource = `icon-infobanner-skill-${skillName}.png`;
        }
        break;
      }
      case TibiaEnums.InfoBannerTypeBosstiaryProgress: 
      case TibiaEnums.InfoBannerTypeBestiaryProgress:
        iconSource = "icon-infobanner-unlock.png";
        iconContentLoader.extraData = iconData.extraData;
        iconContentLoader.sourceComponent = raceRendererComponent;
        break;
      case TibiaEnums.InfoBannerTypeQuestProgress:
        iconSource = "icon-infobanner-quests.png";
        break;
      case TibiaEnums.InfoBannerTypeAchievement:
        iconSource = "icon-infobanner-achievements.png";
        break;
      case TibiaEnums.InfoBannerTypeTitle:
        iconSource = "icon-infobanner-title.png";
        break;
      case TibiaEnums.InfoBannerTypeOutfitPartUnlocked:
        iconSource = "icon-infobanner-unlock.png";
        iconContentLoader.extraData = iconData.extraData;
        iconContentLoader.sourceComponent = outfitRendererComponent;
        break;
      case TibiaEnums.InfoBannerTypeWeaponProficency:
        iconSource = "icon-infobanner-unlock.png";
        iconContentLoader.extraData = iconData.extraData;
        iconContentLoader.sourceComponent = objectRendererComponent;
        break;
      case TibiaEnums.InfoBannerTypeBountyTaskFinished:
        iconSource = "icon-infobanner-unlock.png";
        iconContentLoader.extraData = iconData.extraData;
        iconContentLoader.sourceComponent = raceRendererComponent;
        break;
      case TibiaEnums.InfoBannerTypeWeeklyTaskAnyCreatureFinished:
        iconSource = "icon-infobanner-weeklytask.png";
        break;
      case TibiaEnums.InfoBannerTypeWeeklyTaskSpecificCreatureFinished:
        iconSource = "icon-infobanner-unlock.png";
        iconContentLoader.extraData = iconData.extraData;
        iconContentLoader.sourceComponent = raceRendererComponent;
        break;
      case TibiaEnums.InfoBannerTypeSpellUnlocked:
        iconSource = "icon-infobanner-unlock.png";
        iconContentLoader.extraData = iconData.extraData;
        iconContentLoader.sourceComponent = spellRendererComponent;
        break;
      case TibiaEnums.InfoBannerTypePromotionUnlocked:
        iconSource = "icon-infobanner-unlock.png";
        iconContentLoader.extraData = iconData.extraData;
        break;
      case TibiaEnums.InfoBannerTypeLeaderMonsterKilled:
        iconSource = "icon-infobanner-unlock.png";
        iconContentLoader.extraData = iconData.extraData;
        iconContentLoader.sourceComponent = raceRendererComponent;
        break;
      case TibiaEnums.InfoBannerTypeSubAreaUnlocked:
        iconSource = "icon-infobanner-pointofinterest.png";
        iconContentLoader.extraData = iconData.extraData;
        iconContentLoader.sourceComponent = spellRendererComponent;
        break;
      case TibiaEnums.InfoBannerTypeAreaUnlocked:
        iconSource = "icon-infobanner-pointofinterest.png";
        iconContentLoader.extraData = iconData.extraData;
        iconContentLoader.sourceComponent = spellRendererComponent;
        break;
    }
    iconImage.source = `qrc:/images/tutorial/${iconSource}`;
  }

  Loader {
    id: iconContentLoader
    x: root.width / 2 - width / 2
    y: root.height / 2 - height / 2
    property var extraData: {
    }
    Component {
      id: objectRendererComponent
      SingleObjectAppearanceInstanceRenderer {
        
        width: 32
        height: 32

        typeid: iconContentLoader.extraData.objectid ?? 0
      } 
    }
    Component {
      id: raceRendererComponent
      RaceAppearanceInstanceRenderer {
        raceID: iconContentLoader.extraData.raceid ?? 0
        width: 64
        height: 64
      }
    }

    Component {
      id: outfitRendererComponent
      OutfitAppearanceInstanceRenderer {
        id: outftitMountRenderer
        outfitId: iconContentLoader.extraData.outfitid ?? 0

        width: 64
        height: 64
        animated: true
        center: true
        
        headColor: ColorHelper.createColorFromEightBitHSV(95)
        torsoColor: ColorHelper.createColorFromEightBitHSV(113)
        legsColor: ColorHelper.createColorFromEightBitHSV(39)
        detailColor: ColorHelper.createColorFromEightBitHSV(15)
        firstAddOn: iconContentLoader.extraData.type == "addon1"
        secondAddOn: iconContentLoader.extraData.type == "addon2"
      } 
    }

    Component {
      id: spellRendererComponent

      Item {
        anchors.centerIn: parent
        width: 32
        height: 32

        Image {
          anchors.centerIn: parent
          source: iconContentLoader.extraData.spellIcon ?? ""
          smooth: false
        }

        Image {
          id: border
          anchors.fill: parent
          source: "/images/tutorial/border-vocationinfo-spells.png"
        }
      }
    }
  }
}
