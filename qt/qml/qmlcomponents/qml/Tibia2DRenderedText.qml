import QtQuick

QtObject {
  id: rendererHelper
  readonly property string fontMetricsSource: "/fonts/Verdana10px.fnt"

  // These properties are automatically updated when the font metrics are loaded
  property int _fontSize: 0
  property var _fontImageSources: []
  property var _fontCharacterMetrics: {}

  signal fontLoaded()

  function _parseAngelCodeBitmapFontFile(FontDefinition) {
    var CommonRegex = /common lineHeight=(\d+) base=(\d+)/;
    var PageRegex = /page id=(\d+)\s+file="([^"]+)"/g;
    var CharRegex = /char id=(-?\d+)\s+x=(-?\d+)\s+y=(-?\d+)\s+width=(-?\d+)\s+height=(-?\d+)\s+xoffset=(-?\d+)\s+yoffset=(-?\d+)\s+xadvance=(-?\d+)\s+page=(\d+)/g;

    var Common = CommonRegex.exec(FontDefinition);
    rendererHelper._fontSize = parseInt(Common[1]);

    var Page = null;
    while (Page = PageRegex.exec(FontDefinition)) {
      rendererHelper._fontImageSources.push(Page[2]);
    }

    var FontMetrics = {}
    var CharMetric = null;
    while (CharMetric = CharRegex.exec(FontDefinition)) {
      var Charinfo = {}
      Charinfo['x'] = parseInt(CharMetric[2])
      Charinfo['y'] = parseInt(CharMetric[3])
      Charinfo['width'] = parseInt(CharMetric[4])
      Charinfo['height'] = parseInt(CharMetric[5])
      Charinfo['xoffset'] = parseInt(CharMetric[6])
      Charinfo['yoffset'] = parseInt(CharMetric[7])
      Charinfo['xadvance'] = parseInt(CharMetric[8])
      Charinfo['page'] = parseInt(CharMetric[9])
      var CharCode = CharMetric[1];
      FontMetrics[CharCode] = Charinfo;
    }
    rendererHelper._fontCharacterMetrics = FontMetrics;
  }

  function _loadFontMetrics(FontDefinitionUrl) {
    var XHR = new XMLHttpRequest;
    XHR.open("GET", fontMetricsSource);
    XHR.onreadystatechange = function() {
      if (rendererHelper && XHR.readyState == XMLHttpRequest.DONE) {
        rendererHelper._parseAngelCodeBitmapFontFile(XHR.responseText);
        fontLoaded();
      }
    }
    XHR.send();
  }

  function loadImageSourcesInCanvas(Canvas) {
    var AllImagesLoaded = true;
    for (var i = 0; i < _fontImageSources.length; ++i) {
      if (!Canvas.isImageLoaded(_fontImageSources[i]) &&
          !Canvas.isImageLoading(_fontImageSources[i])) {
        Canvas.loadImage(_fontImageSources[i]);
        AllImagesLoaded = false;
      }
    }
    return AllImagesLoaded;
  }

  function fontHeight() {
    // This function exists to make _fontSize read-only from external code
    return _fontSize;
  }

  function measureText(Text) {
    var Width = 0;
    for (var i = 0; i < Text.length && _fontCharacterMetrics != undefined; ++i) {
      var CharCode = String(Text.charCodeAt(i));
      var CharInfo = _fontCharacterMetrics[CharCode];
      if (CharInfo != undefined) {
        var CharWidth = CharInfo["xadvance"];
        Width += CharWidth;
      }
    }
    return Width;
  }

  function drawText(Canvas, Context, Text, x, y) {
    if (!loadImageSourcesInCanvas(Canvas)) {
      return;
    }

    var CursorX = x;
    // Text by default is left-aligned starting from X, so only center/right has to be handled
    if (Context.textAlign == "center") {
      var TextWidth = measureText(Text)
      CursorX -= Math.ceil(TextWidth / 2);
    } else if (Context.textAlign == "right") {
      var TextWidth = measureText(Text)
      CursorX -= TextWidth;
    }

    var CursorY = y - _fontSize; // Translate Y so that the coordinate marks the lower line of text,
                                // similar to Context.strokeText behaviour
    for (var i = 0; i < Text.length && _fontCharacterMetrics != undefined; ++i) {
      var CharCode = String(Text.charCodeAt(i));
      var CharInfo = _fontCharacterMetrics[CharCode];

      if (CharInfo != undefined) {
        var ImageSource = _fontImageSources[CharInfo["page"]];
        Context.drawImage(ImageSource, CharInfo["x"], CharInfo["y"],
                          CharInfo["width"], CharInfo["height"],
                          CursorX + CharInfo["xoffset"], CursorY + CharInfo["yoffset"],
                          CharInfo["width"], CharInfo["height"]);
        CursorX += CharInfo["xadvance"];
      }
    }
  }

  Component.onCompleted: {
    rendererHelper._loadFontMetrics(fontMetricsSource);
  }

  onFontMetricsSourceChanged: {
    rendererHelper._loadFontMetrics(fontMetricsSource);
  }
}
