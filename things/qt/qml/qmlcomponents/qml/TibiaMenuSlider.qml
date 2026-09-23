import QtQuick
import QtQuick.Layouts




Item {
  id: root
  implicitHeight: withFrame ? TibiaStyle.optionLineFrameHeight : sliderAndTextFrame.height
  implicitWidth: sliderText.width
                 + 5 //+5 min distance slider text
                 + (withFrame ? 2*TibiaStyle.marginRelated : 0) //margins to frame if needed
                 + sliderPreferredWidth
                 + (guiHelp.visible ? guiHelp.width + TibiaStyle.marginRelated : 0)

  property bool withFrame:            false
  property string text:               "Option:"
  property string unitSymbol:         ""
  property alias styleType:           sliderText.styleType
  property alias minimumValue:        slider.minimumValue
  property alias maximumValue:        slider.maximumValue
  property alias stepSize:            slider.stepSize
  property alias value:               slider.value
  property alias shouldBeValue:       slider.shouldBeValue
  property int sliderPreferredWidth:  TibiaStyle.sliderDefaultPreferredWidth
  property bool offAtMinimum:         false
  property alias guiHelpText:         guiHelp.text
  property bool reserverGuiHelpSpace: false
  property bool disabled:             false //allows do disable the slider but still have an aktive GuiHelp

  RowLayout {
    id: sliderAndTextFrame
    anchors.margins: withFrame ? TibiaStyle.marginRelated : 0
    anchors { left: parent.left; right:parent.right; verticalCenter: parent.verticalCenter }
    spacing: 0

    TibiaText{
      id: sliderText
      text: root.text + " " + slider.value + " " + root.unitSymbol
            + (root.offAtMinimum && slider.value == slider.minimumValue ? " " + qsTrId("off_marker") : "")
      enabled: !root.disabled
    } //TibiaText

    Column {
      Layout.fillWidth: true
      TibiaSlider {
        id: slider
        anchors.right: parent.right
        width: sliderPreferredWidth
        enabled: !root.disabled
      } //TibiaSlider
    } //Item

    TibiaGuiHelp {
      id: guiHelp
      Layout.leftMargin: TibiaStyle.marginRelated
      visible: text.length > 0 || reserverGuiHelpSpace
      opacity: text.length > 0 ? 1 : 0
    } //TibiaGuiHelp
  } //RowLayout

  Loader {
    id: frameLoader
    anchors.fill: parent
    z: text.z -1
    active: root.withFrame
    sourceComponent: TibiaFrame1PixelDown { }
  } //Loader
} //Item
