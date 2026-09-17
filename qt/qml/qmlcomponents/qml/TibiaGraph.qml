import QtQuick


Canvas {
  id: graphCanvas
  implicitWidth: 150
  implicitHeight: 100
  antialiasing: false

  property real xMin: 0
  property real xMax: 10
  property real yMin: 0
  property real yMax: 10
  property int  labelCountYAxis: 4
  property int  labelCountXAxis: 5
  property string yLabel: ""
  property string xLabel: ""
  property var values: [] // List of vector2d values, or QObject with x and y properties

  property var backdropImage: "/images/backdrop-dark-grey.png"

  Tibia2DRenderedText {
    id: textRenderer

    onFontLoaded: {
      loadImageSourcesInCanvas(graphCanvas);
      graphCanvas.requestPaint();
    }
  }

  Component.onCompleted: {
    loadImage(backdropImage);
  }

  onImageLoaded: {
    requestPaint();
  }

  onXMinChanged: {
    requestPaint();
  }

  onYMinChanged: {
    requestPaint();
  }

  onXMaxChanged: {
    requestPaint();
  }

  onYMaxChanged: {
    requestPaint();
  }

  onLabelCountXAxisChanged: {
    requestPaint();
  }

  onLabelCountYAxisChanged: {
    requestPaint();
  }

  onXLabelChanged: {
    requestPaint();
  }

  onYLabelChanged: {
    requestPaint();
  }

  onValuesChanged: {
    requestPaint();
  }

  onVisibleChanged: {
    if (visible) {
      requestPaint();
    }
  }

  onPaint: {
    var ctx = getContext("2d");
    ctx.reset();

    // Calculate sizes for the grid
    ctx.textAlign = "center";
    ctx.lineWidth = TibiaStyle.graphGridLineWidth;

    var IntervalBetweenXLabelsCount = labelCountXAxis - 1;
    var IntervalBetweenYLabelsCount = labelCountYAxis - 1;
    var RangeX = xMax - xMin;
    var RangeY = yMax - yMin;

    var MaxLabelWidthX = Math.max(textRenderer.measureText(TibiaStyle.formatNumberWith3DecimalPlacesAndTibiaThousandsUnits(xMax)),
                                  textRenderer.measureText(TibiaStyle.formatNumberWith3DecimalPlacesAndTibiaThousandsUnits(xMin)));
    var MaxLabelHeightY = Math.max(textRenderer.measureText(TibiaStyle.formatNumberWith3DecimalPlacesAndTibiaThousandsUnits(yMax)),
                                   textRenderer.measureText(TibiaStyle.formatNumberWith3DecimalPlacesAndTibiaThousandsUnits(yMin)));
    var MarginBottom = textRenderer.fontHeight() + TibiaStyle.marginNarrow;
    var GridStartX = textRenderer.fontHeight() + TibiaStyle.marginNarrow;
    var GridStartY = Math.ceil(MaxLabelHeightY / 2)
    var AvailableHeightForGrid = Math.ceil(height) - MarginBottom - GridStartY;
    var SpaceBetweenLinesY = Math.floor(AvailableHeightForGrid / IntervalBetweenYLabelsCount);
    var AvailableWidthForGrid = Math.floor(width - GridStartX - MaxLabelWidthX / 2)
    var SpaceBetweenLinesX = Math.floor(AvailableWidthForGrid / IntervalBetweenXLabelsCount);
    var GridEndX = GridStartX + SpaceBetweenLinesX * IntervalBetweenXLabelsCount;
    var GridEndY = Math.floor(MaxLabelHeightY / 2 + SpaceBetweenLinesY * IntervalBetweenYLabelsCount);

    var BackgroundPattern = ctx.createPattern(backdropImage, "repeat");
    ctx.fillStyle = BackgroundPattern;
    ctx.fillRect(GridStartX, GridStartY, GridEndX - GridStartX, GridEndY - GridStartY);

    for (var i = 0; i < labelCountYAxis; ++i) {
      // Draw lines from left to right
      var LineY = Math.floor(GridStartY + SpaceBetweenLinesY * i);
      ctx.beginPath();
      ctx.moveTo(GridStartX, LineY);
      ctx.lineTo(GridEndX, LineY);
      ctx.strokeStyle = TibiaStyle.graphGridColor
      ctx.stroke();

      // Draw labels on the left
      var LabelValue = yMin + Math.abs(RangeY) * (IntervalBetweenYLabelsCount - i)/IntervalBetweenYLabelsCount * (yMin > yMax ? -1 : 1);
      var LabelText = TibiaStyle.formatNumberWith3DecimalPlacesAndTibiaThousandsUnits(LabelValue);
      var LabelX = textRenderer.fontHeight() - TibiaStyle.marginNarrow;
      var LabelY = Math.ceil(LineY);
      ctx.save();
      ctx.translate(LabelX, LabelY);
      ctx.rotate(-Math.PI/2);
      textRenderer.drawText(graphCanvas, ctx, LabelText, 0, 0);
      ctx.restore();
    }

    for (var i = 0; i < labelCountXAxis; ++i) {
      // Draw lines from bottom to top
      var LineX = Math.floor(GridStartX + SpaceBetweenLinesX * i);
      ctx.beginPath();
      ctx.moveTo(LineX, GridStartY);
      ctx.lineTo(LineX, GridEndY);
      ctx.strokeStyle = TibiaStyle.graphGridColor
      ctx.stroke();

      // Draw labels on bottom
      var LabelValue = xMin + Math.abs(RangeX) * i/IntervalBetweenXLabelsCount * (xMin > xMax ? -1 : 1);
      var LabelText = TibiaStyle.formatNumberWith3DecimalPlacesAndTibiaThousandsUnits(LabelValue);
      var LabelX = LineX;
      var LabelY = Math.floor(height);
      textRenderer.drawText(graphCanvas, ctx, LabelText, LabelX, LabelY);
    }

    // Draw y label
    var LabelX = GridStartX + textRenderer.fontHeight() + TibiaStyle.marginNarrow;
    var LabelY = Math.ceil(GridStartY + (GridEndY - GridStartY) / 2);
    ctx.save();
    ctx.translate(LabelX, LabelY);
    ctx.rotate(-Math.PI/2);
    textRenderer.drawText(graphCanvas, ctx, yLabel, 0, 0);
    ctx.restore();

    // Draw x label
    LabelX = Math.floor(GridStartX + (GridEndX - GridStartX) / 2);
    LabelY = GridEndY - TibiaStyle.marginNarrow;
    textRenderer.drawText(graphCanvas, ctx, xLabel, LabelX, LabelY);

    // Draw line from point to point (needs at least two points)
    // The line is drawn with 1px offset from all sides
    if (values.length > 0) {
      ctx.save()
      ctx.translate(GridStartX + 1, GridEndY - 1);
      ctx.beginPath();
    }

    for (var i = 0; i < values.length; ++i) {
      var DistanceToMinX = values[i].x - xMin;
      var PercentageX = DistanceToMinX / RangeX;
      var DistanceToMinY = values[i].y - yMin;
      var PercentageY = DistanceToMinY / RangeY;
      var InnerPadding = 3;
      var CoordinateX = Math.floor((GridEndX - GridStartX) * PercentageX);
      var CoordinateY = Math.floor((GridStartY - GridEndY + InnerPadding) * PercentageY);

      if (i == 0) {
        ctx.moveTo(CoordinateX, CoordinateY);
      }

      ctx.lineTo(CoordinateX, CoordinateY);
    }

    if (values.length > 0) {
      ctx.strokeStyle = TibiaStyle.graphLineColor
      ctx.lineWidth = TibiaStyle.graphLineWidth
      ctx.lineJoin = "round"
      ctx.stroke();
      ctx.restore();
    }
  } // onPaint
} // Canvas
