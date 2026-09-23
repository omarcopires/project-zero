import QtQuick
import QtQml



TibiaCachedOutlineText {
  property int highlightMode: 0 
  //see: gamewindow\chatchanneltabcontroller.h 
  //enum class EChatChannelTabHighlight : uint
  //{ NONE = 0, CURRENT = 1, FLASH_NEW_ENTRY = 2, NEW_ENTRY = 3, };
  
  styleColor: TibiaStyle.tabCaptionOutlineColor 
  horizontalAlignment: Text.AlignHCenter
  clip: false

  styleType: {
      if(!enabled) {
        return "Disabled";
      } else if(highlightMode == 1) {
        return "TabCaptionCurrent";
      } else if (highlightMode == 2) {
        return "TabCaptionFlash";
      } else if(highlightMode == 3) {
        return "TabCaptionNewMessage";
      } else {
        return "TabCaptionIdle";
      }
  } //styleType
} //TibiaCachedOutlineText
