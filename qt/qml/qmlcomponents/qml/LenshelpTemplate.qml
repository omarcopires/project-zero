import QtQuick
import QtQuick.Layouts




TibiaRadiusedSemiTranspartentRectangle {
  id: root
  z: 9999
  property QtObject controller: null

  visible: controller != null && controller.lenshelpVisible

  width: 440
  height: contentLayout.height + 2 * TibiaStyle.lenshelpContentMargin

  ColumnLayout {
    id: contentLayout
    anchors {left: parent.left; top: parent.top; right: parent.right}
    anchors.margins: TibiaStyle.lenshelpContentMargin

    spacing: TibiaStyle.marginRelated

    TibiaText {
      Layout.fillWidth: true
      style: Text.Outline
      styleColor: TibiaStyle.lenshelpCaptionOutlineColor
      styleType: "LenshelpCaption"

      text: controller != null ? controller.caption : "Caption"
    } //TibiaText

    TibiaText {
      Layout.fillWidth: true
      style: Text.Outline
      styleColor: TibiaStyle.lenshelpCaptionOutlineColor
      wrapMode: Text.Wrap
      textFormat: Text.RichText //Text.StyledText this fixes the align middle for images
      styleType: "LenshelpContent"

      text: controller != null ? controller.content : "Content"

      lineHeight: 1.1
    } //TibiaText

  } //ColumnLayout

} //TibiaRadiusedSemiTranspartentRectangle
