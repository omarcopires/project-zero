pragma Singleton
import QtQuick

QtObject {
  readonly property int maxCharacterNameLength: 29
  readonly property int maxTextFieldDefaultLength: 255

  readonly property color white1: "#DFDFDF"
  readonly property color white2: "#F7F7F7"
  readonly property color white3: "#F4F4F4"
  readonly property color white4: "#FFFFFF"
  readonly property color white5: "#C0C0C0" //also used in tibiacolors.h
  readonly property color red1: "#F75F5F"
  readonly property color red2: "#D33C3C" //also used in tibiacolors.h
  readonly property color red3: "#A40F0F"
  readonly property color green1: "#44AD25" //also used in tibiacolors.h
  readonly property color blue1: "#0E84DA"
  readonly property color blue2: "#1872C3" //for text that leads to store
  readonly property color gold1: "#F7AF48"
  readonly property color grey1: "#BFBFBF"
  readonly property color grey2: "#727272" //disabled overlay
  readonly property color grey3: "#707070" //also used in tibiacolors.h
  readonly property color grey4: "#393939"
  readonly property color orange1: "#FF9854"
  readonly property color orange2: "#C28400"
  readonly property color black1: "#242424"
  readonly property color black2: "#000000"
  readonly property color black3: "#3F3F3F" //also used in tibiacolors.h
  readonly property color yellow1: "#F8DB38"
  readonly property color purple1: "#9800C1" // mana shield color
  readonly property color purple2: "#D437FF" // mana shield color for high contrast
  readonly property color purple3: "#9966CC"
  readonly property color teal1: "#00746f"
  readonly property color transparent: "#00000000"

  //text properties
  property variant textColors: { "Default": white3
                                ,"Dialog":  white5
                                ,"Caption": "#909090"
                                ,"Disabled": grey3
                                ,"Dark": black3
                                ,"ContextMenu": white2
                                ,"TabCaptionCurrent": white1
                                ,"TabCaptionIdle": "#7F7F7F"       //grey
                                ,"TabCaptionFlash": white2
                                ,"TabCaptionNewMessage": red1
                                ,"SpecialChannelChatInput": "#9F9FFE" //purple blue
                                ,"VipHighlight": white2
                                ,"VipOnline": "#60F860"    //green
                                ,"VipOffline": "#F86060"   //red
                                ,"VipPending": orange1     //orange flash-client #FFA500
                                ,"VipExerciseWeaponTraining": purple3
                                ,"VipGroup": white2
                                ,"VipGroupBackground": black3
                                ,"Error": "#C04040"  // red
                                ,"IgnorePermanently": red1
                                ,"AllowPermanently": "#5FF75F" //green
                                ,"LenshelpCaption": red1
                                ,"LenshelpContent": white1
                                ,"StoreColorNew": green1
                                ,"StoreColorSale": gold1
                                ,"StoreColorTimed": blue2
                                ,"StoreColorNegativeBalance": red2
                                ,"StoreColorPositiveBalance": green1
                                ,"InventoryOverlay": grey1
                                ,"ModifierPositive": green1
                                ,"ModifierNegative": orange1
                                ,"ModifierZero":     red2
                                ,"CurrencyLowBalance": red2
                                ,"MessageWarning": orange1
                                ,"MessageCritical": red2
                                ,"ActionButtonOverlay": white1
                                ,"ListValue": white3
                                ,"White": white4
                                ,"Positive": green1
                                ,"Negative": red2
                                ,"TrackedQuestHighlight": white2
                                ,"WhiteCaption": white2
                                ,"CalendarDateCurrent": white4
                                ,"CalendarDateInvalid": grey3
                                ,"WidgetCaptionHighilght": white1
                                ,"tableViewHighlight": orange1
                                ,"PartyLeader": yellow1
                                ,"TextFieldTextSelected": white3
                                ,"TextFieldText": white5
                                ,"WarningText": red1
                                ,"RemainingTimeAlmostGone": red2
                                ,"RemainingTimeUsed": yellow1
                                ,"RemainingTimeAlmostNew": grey1
                                ,"TutorialCaption": white1
                                ,"ContainerManualSortMode": orange2
                               }
  property color defaultOutlineColor: "black"

  property font defaultTextFont
    defaultTextFont{family: "Verdana"; pixelSize: 11; bold: true; hintingPreference: Font.PreferDefaultHinting;}

  property font defaultTextFontStrikeout
    defaultTextFontStrikeout{family: defaultTextFont.family; pixelSize: defaultTextFont.pixelSize; bold: defaultTextFont.bold; strikeout: true; hintingPreference: Font.PreferDefaultHinting;}

  property font defaultTightFont
    defaultTightFont{family: defaultTextFont.family; pixelSize: defaultTextFont.pixelSize; bold: defaultTextFont.bold; letterSpacing: -0.8; hintingPreference: Font.PreferDefaultHinting;}

  property font defaultLinkFont
    defaultLinkFont{family: defaultTextFont.family; pixelSize: defaultTextFont.pixelSize; bold: defaultTextFont.bold; underline: true; hintingPreference: Font.PreferDefaultHinting;}

  property font smallFont
    smallFont{family: defaultTextFont.family; pixelSize: 8; bold: defaultTextFont.bold; letterSpacing: 0.1; hintingPreference: Font.PreferDefaultHinting;}

  property font tutorialCaptionFont
    tutorialCaptionFont{family: "Verdana"; pixelSize: 20; bold: false; hintingPreference: Font.PreferDefaultHinting;}

  property font infoBannerCaptionFont
    infoBannerCaptionFont{family: "Verdana"; pixelSize: 17; bold: true; hintingPreference: Font.PreferDefaultHinting;}

  property font buttonFont: smallFont

  readonly property int threeDigitTextSize: 24

  //sometimes needed for calculations. Different OS have different text height
  //value is updated vom gamewindow.qml
  property int defaultTextLineHeight: 13

  //button properties
  readonly property color buttonTextColor: textColors["Dialog"]
  readonly property int buttonWidthDefault: 43
  readonly property int buttonWidthSmall: 34
  readonly property int buttonWidthBroad: 64
  readonly property int buttonWidthWide: 86
  readonly property int buttonWidthWider: 108
  readonly property int buttonWidthWidest: 128
  readonly property int buttonWidthExtraWide: 200
  readonly property int buttonHeightDefault: 20
  readonly property int buttonHeightHigh: 26
  readonly property int buttonWidthStoreSmall: 26
  readonly property int buttonWidthStoreGetPremium: 100
  readonly property int premiumStateButtonWidth: 128
  readonly property int premiumStateButtonHeight: 37
  readonly property int premiumStateButtonHeightFlat:23
  readonly property int buttonHeightAppearance: 36
  readonly property int iconButtonSize: 20

  //tab view
  readonly property int tabWidth: buttonWidthBroad

  // combobox properties
  readonly property int comboBoxHeight: 20
  readonly property color comboBoxSelectionColor: "#55808080"
  readonly property int comboboxOptionsWidth: 150

  //text field properties
  readonly property font textFieldFont: defaultTextFont
  readonly property color textFieldTextColor: textColors["TextFieldText"]
  readonly property color textFieldDisabledTextColor: textColors["Disabled"]
  readonly property color textFieldBackgroundColor: "#363636"
  readonly property color textFieldSelectionTextColor: textColors["TextFieldTextSelected"]
  readonly property color textFieldSelectionColor: "#808080"
  readonly property var textRenderingType: Text.NativeRendering
  readonly property int textFieldHeight: 16

  //the g postfix is needed so the regex is applied more than once
  //https://www.w3schools.com/jsref/jsref_replace.asp
  readonly property var regExpSingleNonASCIIChar: /[^\x00-\xFF]/g

  //Trigonometric constants
  readonly property real gradToRad: Math.PI / 180.0
  readonly property real radToGrad: 180.0 / Math.PI

  //table view properties
  readonly property int   tableViewHeaderHeight: 16
  readonly property int   tableViewRowHeight: 16
  readonly property int   tableViewRowHeight2Lines: 30
  readonly property color tableViewBackgroundColor: "#404040"
  readonly property color tableViewHeaderBackgroundColor: "#363636"
  readonly property color tableViewItemBackgroundColor: "#484848"
  readonly property color tableViewAlternateBackgroundColor: "#414141"
  readonly property color tableViewSelectionColor: "#585858"

  // context menu
  readonly property color contextMenuSelectedBackgroundColor: "#808080"
  readonly property color contextMenuOutlineColor: defaultOutlineColor
  readonly property int entrySpacingVertical: 3
  readonly property int entryPartMargin: 2
  readonly property int minAfterEntrySpace: 40

  // tooltip
  readonly property color tooltipBackgroundColor: "#c0c0c0"
  readonly property color tooltipTextColor: textColors["Dark"]
  readonly property font  tooltipFont: defaultTextFont
  readonly property int tooltipBorderMargin: 4
  readonly property int tooltipRestrictedWidth: 450

  // creature hud
  readonly property font  creatureHUDFont: defaultTextFont

  // player trade
  readonly property font playerTradeSmallFont: buttonFont
  readonly property int playerTradeBorderMargin: marginNarrow

  // currency view
  readonly property int currencyViewHeight: buttonHeightDefault
  readonly property int currencyViewWidthNarrow: 26
  readonly property int currencyViewWidthShort: 2 * currencyViewWidthNarrow
  readonly property int currencyViewWidthMiddle: 3 * currencyViewWidthNarrow
  readonly property int currencyViewWidth: 2 * currencyViewWidthShort
  readonly property int currencyViewWidthLong: 5 * currencyViewWidthNarrow
  readonly property int currencyViewWidthVeryLong: 5 * currencyViewWidthShort

  // scroll bar
  readonly property int scrollBarWidth: 12
  readonly property int scrollBarMinHeight: 12 + 12 + 14 //2*12 Buttons + 14 Handle

  // container
  readonly property int containerSlotSize: 34
  readonly property int containerSlotsMargin: 3 //margin between slots
  readonly property int containerContentTopMargin: 4 //margin to the top of the scroll area
  readonly property int containerContentBottomMargin: 6 //margin to bottom of the scroll area
  readonly property int containerContentLeftMargin: 7 //left margin of the content this means right margins is 4 same ase top margin
  readonly property int numberOfContainerSlotsPerRow: 4

  // slider
  readonly property int sliderDefaultPreferredWidth: 175
  readonly property int sliderModifierShift: 10
  readonly property int sliderModifierControl: 100

  // search features
  readonly property int searchDelay: 250
  readonly property int textAsyncValidationDealy: 500

  // fallback
  readonly property real noShaderBlackoutOpacity: 0.15

  // tables and colums
  readonly property int columnWidthDateTime: 150

  /////////////////////////////////////////////////////////////////////////////
  // CLIENT
  readonly property int clientMinWidth: 1020
  readonly property int clientMinHeight: 650
  readonly property int eMailAdressLength: 49
  readonly property int passwordLength: 29

  // CLIENT
  /////////////////////////////////////////////////////////////////////////////
  // DIALOG
  readonly property int dialogHeaderLineHeight: 17
  readonly property int dialogFrameWidith: 4
  readonly property int dialogContentToFrameMargin: 12
  readonly property int dialogMarginBorder: dialogContentToFrameMargin + dialogFrameWidith
  readonly property int dialogMaxWidth: clientMinWidth - - 2 * marginUnrelated
  readonly property int dialogMaxHeight: clientMinHeight - - 2 * marginUnrelated

  //margins between objects
  readonly property int marginRelated: 5
  readonly property int marginUnrelated: 2 * marginRelated
  readonly property int marginNarrow: 2
  readonly property int marginWide: 3 * marginRelated
  readonly property int margin1PixelFrameToContent: 4
  readonly property int paragraphIndentation: 17
  readonly property int noGuiHelphIndentation: 17
  readonly property int alignGuiHelpWithAndWithoutFrame: marginRelated
  readonly property int labelMargin: marginRelated - 1 //for some reason text often start with 1 pixel distance to its bounding box

  readonly property int optionLineFrameHeight: 22
  // DIALOG
  /////////////////////////////////////////////////////////////////////////////
  //SIDE BAR
  readonly property int sidebarWidth: 176

  //upper/panel pane
  readonly property int sideBarPanelPaneBorderWidth: 2
  readonly property int sideBarPanelVerticalBorderDistance: 3
  readonly property int sideBarPanelVerticalDistance: 4
  readonly property int sideBarPanelHorizontalBorderDistance: 6
  readonly property int sideBarPanelRightSideWith: 42

  //widget
  readonly property int widgetHeaderLineHeight: 15
  readonly property int widgetBorderWidth: 4
  readonly property int widgetMinimizedHeight: widgetHeaderLineHeight + widgetBorderWidth
  readonly property int defaultInitialContentHeight: 57 - widgetMinimizedHeight
  readonly property int widgetWithScrollBarMinContentHeight: scrollBarMinHeight
  readonly property int widgetControllButtonSize: 12

  //SIDE BAR
  /////////////////////////////////////////////////////////////////////////////
  //GAMEWINDOW WINDOW
  readonly property int mapWindowMargins: 4

  readonly property int mapWindowHeightInFields: 11
  readonly property int mapWindowWidthInFields: 15
  readonly property int mapWindowPixelPerField: 32
  readonly property int mapWindowUnscaledHeight: mapWindowHeightInFields * mapWindowPixelPerField
  readonly property int mapWindowUnscaledWidth: mapWindowWidthInFields * mapWindowPixelPerField
  readonly property int mapWindowMinHeight: Math.ceil(mapWindowUnscaledHeight / 2)
  readonly property int mapWindowMinWidth: Math.ceil(mapWindowUnscaledWidth / 2)

  //GAMEWINDOW WINDOW
  /////////////////////////////////////////////////////////////////////////////
  //CHAT
  readonly property int chatInputMaxLength: maxTextFieldDefaultLength
  readonly property int consoletextFrameBorderWidth: 3
  readonly property int chatBackgroundToFrameMargin: 4
  readonly property int chatGuiMargins: 2
  readonly property int chatTextToFrameMargin: 2
  readonly property int tabBarHeight: 16
  readonly property int tabOverlapFakeHeight: 2
  readonly property int chatTabWidth: 96
  readonly property int tabTextSideMargin: 5
  readonly property int tabTextTopMarin: 2
  readonly property color tabCaptionOutlineColor: defaultOutlineColor
  readonly property int tabCaptionFlashTimeMs: 1000
  readonly property color chatInputSpecialChannelColor: textColors["SpecialChannelChatInput"]
  readonly property int chatMinimumHeight: 90

  //CHAT
  /////////////////////////////////////////////////////////////////////////////
  //MINIMAP
  readonly property int numberOfMinimapMarkers: 20
  readonly property int numberOfMinimapMarkersPerSelectRow: 10
  readonly property int minimapViewportHeight: 111
  readonly property int minimapViewportWidth: 108

  //MINIMAP
  /////////////////////////////////////////////////////////////////////////////
  //COOLDOWNBAR
  readonly property int marginCooldownBar: 3
  readonly property real opacityOfCooldownBarIconOverlay: 0.7
  readonly property int cooldownBarHeight: 24

  //COOLDOWNBAR
  /////////////////////////////////////////////////////////////////////////////
  //SELECT OUTFIT DIALOG
  readonly property int numberOfEightBitHSVColors: 133
  readonly property int colorSelectionGridNumberOfColorsPerRow: 19
  readonly property int outfitMountScaleFactor: 2
  //SELECT OUTFIT DIALOG
  /////////////////////////////////////////////////////////////////////////////
  //VIP WIDGET
  readonly property int vipListBottomMargin: 5

  //VIP WIDGET
  /////////////////////////////////////////////////////////////////////////////
  //EDIT VIP DIALOG
  readonly property int numberOfVipIcons: 11
  readonly property int maxDescriptionLength: 128

  //EDIT VIP DIALOG
  /////////////////////////////////////////////////////////////////////////////
  //UNJUSTIFIED POINTS WIDGET
  readonly property int skullBarSpacing: 2

  //UNJUSTIFIED POINTS WIDGET
  /////////////////////////////////////////////////////////////////////////////
  // NEWS (compendium)
  readonly property int newsCategoriesViewWidth: 144
  readonly property int newsCategoryEntryHeight: 36
  readonly property int newsTooltipWidth: tooltipRestrictedWidth
  readonly property int newsMainContentViewHeight: 425
  readonly property int newsContentWidth: 667 //all content created by the CM is optimizied for 667 pixel width
  // NEWS
  /////////////////////////////////////////////////////////////////////////////
  // STORE
  readonly property int storeTooltipWidth: tooltipRestrictedWidth
  readonly property color storeColorNew: textColors["StoreColorNew"]
  readonly property color storeColorSale: textColors["StoreColorSale"]
  readonly property color storeColorTimed: textColors["StoreColorTimed"]
  readonly property color storeColorGiftRefund: storeColorTimed
  readonly property color storeColorNegativeBalance: textColors["StoreColorNegativeBalance"]
  readonly property color storeColorPositiveBalance: textColors["StoreColorPositiveBalance"]
  readonly property int storeCategoriesViewWidth: 185
  readonly property int storeCategoryEntryHeight: 36
  readonly property int storeProductViewWidth: 120
  readonly property int storeProductViewHeight: 134
  readonly property int storeMainContentViewHeight: 339 //20 entries within the history and also more 2 produtc rows and some pixels of an extra categorie
  // STORE
  /////////////////////////////////////////////////////////////////////////////
  // STORE PURCHASE SUCCESS DIALOG
  readonly property int storePurchaseSuccessButtonSize: 108
  readonly property int dragonHeaderMarginToDialog: -2
  // STORE PURCHASE SUCCESS DIALOG
  /////////////////////////////////////////////////////////////////////////////
  // LENSEHELP
  readonly property color lenshelpBackgroundColor: "#80000000"
  readonly property color lenshelpBorderColor: "grey"
  readonly property int lenshelpBorderWidth: 2
  readonly property int lenshelpCornerRadius: marginRelated
  readonly property int lenshelpContentMargin: lenshelpCornerRadius + lenshelpBorderWidth
  readonly property color lenshelpCaptionOutlineColor: defaultOutlineColor
  // LENSHELP
  /////////////////////////////////////////////////////////////////////////////
  // TUTORIAL
  readonly property color tutorialBackgroundColor: "#AA00A000"
  readonly property color tutorialMarkerColor: "#FF00FF00"
  readonly property int tutorialMarkerBorderWidth: 2
  readonly property int tutorialMarkerCornerRadius: marginRelated
  readonly property int tutorialMarkerBorderMargins: 10
  readonly property int tutorialTextHintStandardOffset: 15
  readonly property int tutorialTextHintWithMarkerVisibleOffset: 25
  readonly property int noTutorialMarker: 0
  readonly property int captionFlagTopMargin: 10
  readonly property int startplayingDecorationMargin: 6
  readonly property int startplayingDecorationBottomMargin: 7
  // TUTORIAL
  /////////////////////////////////////////////////////////////////////////////
  // GUI HELP & TOOLTIP
  readonly property int guiHelpDelay: 0
  readonly property int guiHelpTooltipWidth: tooltipRestrictedWidth
  readonly property int tooltipDelay: 500
  // GUI HELP & TOOLTIP
  /////////////////////////////////////////////////////////////////////////////
  // PREY DIALOG and KILL TRACKER WIDGET
  readonly property int preyGridSelectionWidth: 204
  readonly property int preyMonsterViewSize: 134 // 66*2 + TibiaStyle.marginNarrow
  readonly property int preyBonusViewWidth: 66
  readonly property int preyMonsterImageSize: 128
  readonly property int preyMonsterScaleFactor: 2
  readonly property int preySelectionImageSize: 64
  readonly property int preySelectionScaleFactor: 1
  readonly property int preyMiniProgressbarWidth: 65
  readonly property int preyShortCurrencyWidth: 26
  property font preyBonusFont
    preyBonusFont{family: defaultTextFont.family; pixelSize: 18; bold: true}
  readonly property color preyProgressBarColor: orange2
  readonly property color preyHuntingTaskFinishedProgressBarColor: green1
  readonly property color preyHuntingTaskExpiredProgressBarColor: red2
  // PREY DIALOG and KILL TRACKER WIDGET
  /////////////////////////////////////////////////////////////////////////////
  // IMBUING DIALOG
  readonly property int imbuingImbuedItemScaleFactor: 2
  readonly property int imbuingAstralSourcesScaleFactor: 2
  // IMBUING DIALOG
  /////////////////////////////////////////////////////////////////////////////
  // EXALTATION FORGE DIALOG
  readonly property int exaltationForgeItemScaleFactor: 2
  readonly property int exaltedDustId: 37160
  readonly property int exaltedslivertId: 37109
  readonly property int exaltedCoreId: 37110
  readonly property int goldCoinId: 3031
  // EXALTATION FORGE DIALOG
  /////////////////////////////////////////////////////////////////////////////
  // PROGRESS BARS
  readonly property int progressBarLargeHeight: 20
  readonly property int progressBarSmallHeight: 14
  readonly property int progressBarSlimHeight: 5
  // PROGRESS BARS
  /////////////////////////////////////////////////////////////////////////////
  //INSPECT OBJECT DIALOG/PLAYER
  readonly property int inspectObjectScaleFactor: 2
  readonly property int inspectObjectSpriteViewSize: mapWindowPixelPerField * 2
  readonly property int inspectObjectSpriteOuterSize: inspectObjectSpriteViewSize + 2
  //INSPECT OBJECT DIALOG/PLAYER
  /////////////////////////////////////////////////////////////////////////////
  // MARKET
  readonly property int marketCategoryViewWidth: 160
  readonly property int marketCategoryViewHeight: 137
  readonly property int marketAmountSliderWidth: 150
  readonly property int market5DigitsNumberSpace: 45
  readonly property int market7DigitsNumberSpace: 72
  readonly property int marketColumnWidthAmountText: 60
  readonly property int marketColumnWidthPriceText: 85
  readonly property int marketColumnWidthEndsAtTime: 150
  readonly property int marketColumnWidthStatus: 70
  // MARKET
  /////////////////////////////////////////////////////////////////////////////
  // ACTION BAR
  readonly property int actionBarSlotSize: 34
  readonly property int actionBarSlotMargin: marginNarrow
  readonly property int actionBarLockButtonWidth: 12
  readonly property int actionBarLockButtonHeight: 16
  readonly property int actionBarTooltipMaxWidth: tooltipRestrictedWidth
  readonly property int actionBarAssignObjectScaleFactor: 2
  readonly property int actionBarReapeatDealy: 500 //see keyboardshortcuthandler.cpp case tibia::input::EGameAction::ACTION_BUTTON_TRIGGERED:
  readonly property int actionBarReapeatTextDelay: 2500
  readonly property int actionBarPressedTriggerDelay: 500
  readonly property int actionBarServerEquipDelay: 500
  // ACTION BAR
  /////////////////////////////////////////////////////////////////////////////
  // SPELL LIST WIDGET
  readonly property int spellListIconSize: 32
  // SPELL LIST WIDGET
  /////////////////////////////////////////////////////////////////////////////
  // PASSIVE ABILITIES LIST
  readonly property int passiveAbilityListIconSize: 32
  // PASSIVE ABILITIES LIST
  /////////////////////////////////////////////////////////////////////////////
  // BATTLE LISTWIDGET
  readonly property int battleListMonsterSize: 18
  // BATTLE LIST WIDGET
  /////////////////////////////////////////////////////////////////////////////
  // DRAG & DROP
  readonly property int dragThreshold: 4
  readonly property int dragStickTreshold: 25
  readonly property string dragKeyChatChannelTab:  "application/x-chatchanneltab"
  readonly property string dragKeyMoveTibiaObject: "application/x-move-tibia-object"
  readonly property string dragKeySidebarPanel:    "application/x-sidebarpanel"
  readonly property string dragKeyWidgetInternal:  "application/x-sidebarwidget-%1"
  readonly property string dragKeyWidgetSidebar:   "application/x-widget-to-sidebar"
  readonly property string dragKeyActionButton:    "application/x-action-button"
  readonly property string dragKeySpell:           "application/x-spell"
  readonly property string dragSourceActionButton: "actionButton"
  readonly property string dragSourceSpellIcon:    "spellIcon"
  // DRAG & DROP
  /////////////////////////////////////////////////////////////////////////////
  // DISABLE OVERLAY
  readonly property real disabledOverlayOpacity: 0.6
  // DISABLE OVERLAY
  /////////////////////////////////////////////////////////////////////////////
  // REWARD WALL
  readonly property int rewardWallItemSize: 66
  readonly property int pickItemWeightWith: 60
  // REWARD WALL
  /////////////////////////////////////////////////////////////////////////////
  // MONSTER CYCLOPEDIA
  readonly property color slotBackground: "#404040"
  readonly property color sensitivityWeak: "#18ce18"
  readonly property color sensitivityNeutral: "#ffffff"
  readonly property color sensitivityResist: "#e4c00a"
  readonly property color sensitivityImmune: "#ae0f0f"
  readonly property int   cyclopediaObjectCategoryViewHeight: 60
  // MONSTER CYCLOPEDIA
  /////////////////////////////////////////////////////////////////////////////
  // CUSTOMISABLE STATUS BAR
  readonly property int sidebarButtonHeight: 56
  readonly property int sidebarButtonWidth: 7
  readonly property int statusBarBackgroundBorderWidth: 2
  readonly property int healthManaBarLargeHeight: 27
  readonly property int healthManaBarSmallHeight: progressBarSmallHeight
  readonly property int states10Width: 103
  readonly property int states5Width: 53
  readonly property string smallString: "small"
  readonly property string largeString: "large"

  //keep in sync with GetColorForHealthPercent in tibiaalgorithms
  function getThresholdForHealthPercent(HealthPercent) {
    if (HealthPercent < 0.04) {
        return "4";
      } else if (HealthPercent < 0.10) {
        return "10";
      } else if (HealthPercent < 0.30) {
        return "30";
      } else if (HealthPercent < 0.60) {
        return "60";
      } else if (HealthPercent < 0.95) {
        return "95";
      } else {
        return "100";
      }
  } //function getThresholdForHealthPercent
  // CUSTOMISABLE STATUS BAR
  /////////////////////////////////////////////////////////////////////////////
  // TIBIA GRAPH
  readonly property color graphGridColor: "#000000"
  readonly property color graphLineColor: "#CE1F16"
  readonly property int graphGridLineWidth: 1
  readonly property int graphLineWidth: 2

  function formatNumberWithFixedDecimalPlaces(Value, Precision) {
    var Power = Math.pow(10, Precision || 0);
    return String(Math.round(Value * Power) / Power);
  } //function formatNumberWithFixedDecimalPlaces

  function formatNumberWith3DecimalPlacesAndTibiaThousandsUnits(Value) {
    if (Value < 100) {
      return formatNumberWithFixedDecimalPlaces(Value, 1);
    } else if (Value < 1000) {
      return formatNumberWithFixedDecimalPlaces(Value, 0);
    } else if (Value < 1000000) {
      return formatNumberWithFixedDecimalPlaces(Value / 1000.0, 0) + "k";
    } else if (Value < 1000000000) {
      return formatNumberWithFixedDecimalPlaces(Value / 1000000.0, 0) + "kk";
    } else {
      return formatNumberWithFixedDecimalPlaces(Value / 1000000000.0, 0) + "kkk";
    }
  } //function formatNumberWith3DecimalPlacesAndTibiaThousandsUnits
  // TIBIA GRAPH
  /////////////////////////////////////////////////////////////////////////////
  // CALENDAR
  readonly property int calendarDayCaptionHeight: 14
  readonly property int calendarEventEntryHeight: calendarDayCaptionHeight
  readonly property color calendarDayCaptionBackgroundColor: tableViewHeaderBackgroundColor
  readonly property color calenderCurrentDayBackgroundColor: tableViewSelectionColor
  readonly property color calenderVisibleMonthBackgroundColor: tableViewItemBackgroundColor
  readonly property color calenderOtherMonthBackgroundColor: tableViewAlternateBackgroundColor
  readonly property color calenderSelectedDayBackgroundColor: tableViewSelectionColor
  readonly property color calenderNavigationBarBackgroundColor: tableViewItemBackgroundColor
  readonly property color calenderDisabledTextColor: textColors["Disabled"]
  // CALENDAR
  /////////////////////////////////////////////////////////////////////////////
  // DIALOG TAB BAR
  readonly property int dialogTabBarHeight: 36
  readonly property int dialogTabBarDefaultWidth: 150
  readonly property int dialogTabBarWiderWidth: 200
  readonly property int dialogTabBarHugeWidth: 250
  // DIALOG TAB BAR
  /////////////////////////////////////////////////////////////////////////////
  // CYLOPEDIA HOUSES TAB
  readonly property int propertyInformationKeyWidth: 100
  readonly property int houseBidWidth: 100
  readonly property var houseMaxBid: Number(10000000000)
  // CYLOPEDIA HOUSES TAB
  /////////////////////////////////////////////////////////////////////////////
  // TEAM FINDER
  readonly property int teamFinderNumberInputWidth: 50
  readonly property int teamFinderCheckBoxWidth: 75
  // TEAM FINDER
  /////////////////////////////////////////////////////////////////////////////

  /////////////////////////////////////////////////////////////////////////////
// MONSTER GLOW PARAMETERS

readonly property QtObject fiendishMonsterGlow: QtObject {
    readonly property color color: "#EE8413"
    readonly property int radius: 3
    readonly property int samples: 7
    readonly property real spread: 0.4
}

readonly property QtObject leaderMonsterGlow: QtObject {
    readonly property color color: "#FF2020"
    readonly property int radius: 4
    readonly property int samples: 9
    readonly property real spread: 0.5
}

readonly property QtObject leaderMinionMonsterGlow: QtObject {
    readonly property color color: "#C850C0"
    readonly property int radius: 3
    readonly property int samples: 7
    readonly property real spread: 0.4
}

  /////////////////////////////////////////////////////////////////////////////
  // SKILL WHEEL
  readonly property color skillWheelTopLeftBaseColor:     "#3146b21c"
  readonly property color skillWheelTopLeftFillColor:     "#6b94c412"
  readonly property color skillWheelTopRightBaseColor:    "#31ae1434"
  readonly property color skillWheelTopRightFillColor:    "#6bef1a38"
  readonly property color skillWheelBottomLeftBaseColor:  "#31198d40"
  readonly property color skillWheelBottomLeftFillColor:  "#6b18cd8f"
  readonly property color skillWheelBottomRightBaseColor: "#31841d9e"
  readonly property color skillWheelBottomRightFillColor: "#6be618da"
  readonly property color skillWheelHoverColor:           "#67808080"
  readonly property int   skillWheelLineWidth: 2
  readonly property int selectionAreaInformationHeight: 179

  /////////////////////////////////////////////////////////////////////////////
  // ACCOUNT CREATION
  readonly property int textFieldWidth: 180
  readonly property int lableTextWidth: 144

  /////////////////////////////////////////////////////////////////////////////
  // WEAPON PROFICIENCY
  readonly property int proficiencyPerkSize: 48
  readonly property int proficiencyPerkScaleFactor: 2
} //QtObject
