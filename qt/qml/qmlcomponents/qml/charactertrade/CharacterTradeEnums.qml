import QtQuick

QtObject {

  enum DialogState {
    Conditions,
    Configuration,
    Confirmation
  }

  enum ConfigurationState {
    None,
    MinimumBid,
    AuctionEnd,
    Items,
    Highlights
  }

}
