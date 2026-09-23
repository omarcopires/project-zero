import QtQuick
import qmlcomponents
import qmlenumvalues


Image {
  property var highlightState: TOffer.STATE_NONE
  source: {
    if (highlightState == TOffer.STATE_NEW) {
      return "/images/store-flag-new.png"
    } else if (highlightState == TOffer.STATE_SALE) {
      return "/images/store-flag-sale.png"
    } else if (highlightState == TOffer.STATE_TIMED) {
      return "/images/store-flag-expires.png"
    }
    return "";
  }
  visible: source != ""
} // Image
