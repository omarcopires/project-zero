import QtQuick
import QtQuick.Templates as T
import qmlcomponents

T.Button {
  id: button
  property string tooltipText: ""
  property string tooltipTextChecked: ""
  property alias  tooltipMaxWidth: buttonTooltip.maxWidth
  property alias  textStyle: buttonText.styleType
  property alias  textFont: buttonText.font
  property string color: "grey"
  property string sourceDown: "/images/skin/classic/button-" + color + "-down.png"
  property string sourceUp:  "/images/skin/classic/button-" + color + "-up.png"
  property string imageSourceUp: ""
  property alias  imageSource: button.imageSourceUp
  property string imageSourceDown: ""
  property string imageSourceDisabled: button.imageSource
  property alias  imageMirrored: image.mirror
  property int    imageXOffset: 0
  property int    imageYOffset: 0
  property string imageAnchor: "center" //possible options: left, center, right, lefttop

  property var    textVerticalAlignment: Text.AlignVCenter
  property var    textHorizontalAlignment: Text.AlignHCenter
  property alias  textLeftPadding: buttonText.leftPadding
  property alias  textRightPadding: buttonText.rightPadding
  property alias  textBottomPadding: buttonText.bottomPadding
  property int    textXOffset: 0
  property int    textYOffset: 0
  property int    rightTextXOffset : 0
  property bool   wrapText: false

  property bool hide: false
  opacity: hide ? 0 : 1
  enabled: !hide

  focusPolicy: Qt.NoFocus

  autoRepeatDelay: 350
  autoRepeatInterval: 60

  implicitWidth: TibiaStyle.buttonWidthDefault
  implicitHeight: TibiaStyle.buttonHeightDefault

  readonly property int pressedPadding: 2
  leftPadding: textXOffset + ((pressed || checked) ? pressedPadding : 0)
  topPadding: textYOffset + ((pressed || checked) ? pressedPadding : 0)

  background: Optimized1PixelBorderImage {
    borderimagesource: (button.pressed || button.checked) ? button.sourceDown : button.sourceUp;
  }

  contentItem: TibiaText {
    id: buttonText
    styleType: "Dialog"
    verticalAlignment: button.textVerticalAlignment
    horizontalAlignment: button.textHorizontalAlignment
    font: TibiaStyle.buttonFont
    text: button.text
    wrapMode: wrapText ? Text.WordWrap : Text.NoWrap
    elide: Text.ElideRight
    smooth: false
  } // contentItem

  Image {
    id: image
    anchors.verticalCenter: imageAnchor == "lefttop" ? undefined : parent.verticalCenter
    anchors.verticalCenterOffset: imageAnchor == "lefttop" ? 0 : button.imageYOffset + (button.pressed || button.checked ? 1 : 0)

    anchors.horizontalCenter: imageAnchor == "center" ? parent.horizontalCenter : undefined
    anchors.horizontalCenterOffset: button.imageXOffset + (button.pressed || button.checked ? 1 : 0)
    anchors.left: imageAnchor == "left" ? parent.left : undefined
    anchors.leftMargin: imageAnchor == "lefttop" ? 0 : 1 + TibiaStyle.marginRelated + button.imageXOffset + (button.pressed || button.checked ? 1 : 0)
    anchors.right: imageAnchor == "right" ? parent.right : undefined
    anchors.rightMargin: 1 + TibiaStyle.marginRelated + button.imageXOffset + (button.pressed || button.checked ? -1 : 0)
    source: button.enabled ? (((button.pressed || button.checked) && imageSourceDown != "") ? button.imageSourceDown
        : button.imageSourceUp)
      : button.imageSourceDisabled
    visible: source != ""
    smooth: false
  } //Image

  Tooltip {
    id: buttonTooltip
    enabled: (tooltipText != "") || (tooltipTextChecked != "")
    anchors.fill: parent
    text: {
      (parent.checked && tooltipTextChecked != "") ? tooltipTextChecked : tooltipText
      if (parent.checked && tooltipTextChecked != "") {
        return tooltipTextChecked;
      } else if (tooltipText != "") {
        return tooltipText;
      }

      return "";
    }
  } //Tooltip

  onPressedChanged: {
    if (!button.pressed) {
      SoundHelper.playSound(SoundHelper.BUTTON_RELEASE);
    } else {
      SoundHelper.playSound(SoundHelper.BUTTON_PRESS);
    }
  } //onPressedChanged

  //helps to give a checkable button its correct checked state if used from outside
  property bool useButtonShouldBeChecked: false
  property bool buttonShouldBeChecked: false
  onButtonShouldBeCheckedChanged: {
    if(checkable == true && useButtonShouldBeChecked == true) {
      if(checked != buttonShouldBeChecked) {
        checked = buttonShouldBeChecked;
      }
    }
  } //onButtonShouldBeCheckedChanged

  onCheckedChanged: {
    if (checkable == true && useButtonShouldBeChecked == true) {
      if(checked != buttonShouldBeChecked) {
        checked = buttonShouldBeChecked;
      }
    }
  } //onCheckedChanged

  onCheckableChanged: {
    if (!checkable) {
      checked = false;
    }
  } //onCheckableChanged
} //Button
