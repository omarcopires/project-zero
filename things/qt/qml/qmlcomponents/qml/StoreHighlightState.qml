import QtQuick
import qmlcomponents
import qmlenumvalues


TibiaText {
  id: highlightText
  property var highlightState: TOffer.STATE_NONE
  visible: highlightState != TOffer.STATE_NONE
  text: "-"

  states: [
    State {
      name: "NEW"
      when: highlightText.highlightState == TOffer.STATE_NEW
      PropertyChanges { target: highlightText; text: qsTrId("store_offer_state_new"); color: TibiaStyle.storeColorNew }
    },
    State {
      name: "SALE"
      when: highlightText.highlightState == TOffer.STATE_SALE
      PropertyChanges { target: highlightText; text: qsTrId("store_offer_state_sale"); color: TibiaStyle.storeColorSale }
    },
    State {
      name: "TIMED"
      when: highlightText.highlightState == TOffer.STATE_TIMED
      PropertyChanges { target: highlightText; text: qsTrId("store_offer_state_time"); color: TibiaStyle.storeColorTimed  }
    }
  ]
} // TibiaText

