import QtQuick
import qmlcomponents




Item {
  property string displayText : ""
  property bool ownCharacter: false
  anchors.fill: parent
  TibiaText {
    anchors.fill: parent
    anchors.leftMargin: TibiaStyle.marginNarrow
    anchors.rightMargin: TibiaStyle.marginRelated
    elide: styleData.elideMode
    horizontalAlignment: styleData.textAlignment
    textFormat: text.indexOf("\x9C") != -1 ? Text.PlainText
                                               : Text.StyledText
    text: displayText
    color: ownCharacter ? TibiaStyle.textColors['VipOnline'] : TibiaStyle.textColors['Dialog']
  }//TibiaText

  TibiaVerticalSeparator {
    anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
  } // TibiaVerticalSeparator
}//Item
