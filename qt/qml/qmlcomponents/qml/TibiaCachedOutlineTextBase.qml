import QtQuick
import qmlcomponents

CachedOutlineText {
  property string styleType: "Dialog"
  property bool active: true

  // uncomment this to disable caching globally (except for items that set it explicitly)
  //cacheMode: CachedOutlineText.NoCaching

  // uncomment this to show a debug overlay (green = show cached texture, red = no texture cache)
  //debugOverlay: true

  font: TibiaStyle.defaultTextFont
  color: TibiaStyle.textColors[(enabled && active) ? styleType : "Disabled"]
  styleColor: TibiaStyle.defaultOutlineColor
  elide: Text.ElideRight
  renderType: TibiaStyle.textRenderingType

  readonly property bool usingSmallFont: font.pixelSize < 10
  antialiasing: usingSmallFont // Small text looks really ugly without antialiasing

  // Explicitly specify line height so that Linux and Windows heights are identical
  // Text.FixedHeight does not properly work with Text.RichText
  readonly property bool prohibitFixedHeight: usingSmallFont || textFormat == Text.RichText
  lineHeight: !prohibitFixedHeight ? 13.0 : 1.0
  lineHeightMode: !prohibitFixedHeight ? Text.FixedHeight : Text.ProportionalHeight
}