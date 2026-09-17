import QtQuick

import qmlcomponents


Canvas {
  // for the mathematics behind an isosceles right triangle see here:
  // https://rechneronline.de/pi/gr-dreieck.phprec
  // a = c / sqrt(2.0)    (a = short side = radius, c = long side = height)
  // height of triangle: h = sqrt(2.0) * a / 2

  property real borderWidth: 10.0
  property color borderColor: Qt.rgba(0.0, 0.0, 0.0, 1.0)
  property color borderColor2: Qt.rgba(255.0, 0.0, 0.0, 1.0)
  property color backgroundColor: Qt.rgba(0.0, 0.0, 0.0, 0.25)
  property color sereneColor: Qt.rgba(0.83, 0.22, 1.0, 0.65)
  property real innerMargin: 1.0
  property var arcWidth: 40.0
  property bool rightArc: false
  property var progressBarsFillRates: [0.0]
  property var progressBarsColors: [Qt.rgba(1.0,0.0,0.0,1.0)]
  property var progressBarsToDivide: []
  property var progressBarDivisionFillRates: []
  property bool showSerene: false
  property bool isSerene: false

  readonly property var _SQRT_OF_2: Math.sqrt(2.0)
  readonly property real _HALF_BORDER_WIDTH: borderWidth / 2.0
  readonly property real _HALF_ARC_WIDTH: arcWidth / 2.0
  readonly property real _OUTER_RADIUS: this.height / _SQRT_OF_2 - 2 * _HALF_BORDER_WIDTH - (innerMargin * 2) / _SQRT_OF_2
  readonly property real _OUTER_TRIANGLE_HEIGHT: _OUTER_RADIUS - _SQRT_OF_2 * _OUTER_RADIUS / 2
  readonly property real _INNER_TRIANGLE_HEIGHT: (progressBarsFillRates.length * arcWidth) / _SQRT_OF_2
  readonly property real _TOTAL_ARCS_WIDTH: arcWidth * progressBarsFillRates.length

  implicitWidth: {
    let calculatedWidth = _HALF_BORDER_WIDTH + _OUTER_TRIANGLE_HEIGHT + _INNER_TRIANGLE_HEIGHT +
                          _HALF_BORDER_WIDTH + _HALF_BORDER_WIDTH / _SQRT_OF_2 + 2 * innerMargin;
    return calculatedWidth;
  }

  function drawHud(rightArc, context2D) {
      var directionSign = rightArc ? -1.0 : 1.0
      var antiClockwise = rightArc ? true : false

      var centreX = _HALF_BORDER_WIDTH + _OUTER_RADIUS + innerMargin
      if (rightArc) {
        centreX = width - centreX - 1
      }
      var centreY = height / 2



      const NUMBER_OF_PROGRESS_BARS = progressBarsFillRates.length;

      context2D.reset();
      // a canvas works with half pixels. this is a trick to compensate this
      // see: https://stackoverflow.com/questions/13879322/drawing-a-1px-thick-line-in-canvas-creates-a-2px-thick-line
      //context2D.translate(0.5, 0.5)

      for (var i = 0; i < NUMBER_OF_PROGRESS_BARS; i++) {
        let currentRadius = _OUTER_RADIUS - i * arcWidth;
        let radiusOfFillStroke = currentRadius - _HALF_ARC_WIDTH;

        // the degree of the filling must be less than -45 degree to 45 degree since half the border width
        // will be on the inside of the progress bar
        // so we calculate a rad value to substract

        //0.25 rad == 45 degree
        const radBorder = ((_HALF_BORDER_WIDTH / 2) / currentRadius) / 2;

        const startRad = -0.25 + radBorder + (!rightArc ? 1 : 0);
        const endRad = 0.25 - radBorder + (!rightArc ? 1 : 0);
        const maxFillLevelRad = 0.5 - 2 * radBorder;

        let fillRate = progressBarsFillRates[i]
        let fillColor = Qt.rgba(0,0,0,1)
        if (i < progressBarsColors.length) {
          fillColor = progressBarsColors[i]
        }

        const startAngle = directionSign * startRad * Math.PI;
        const endAngle = directionSign * endRad * Math.PI;
        const endAngleFill = directionSign * (startRad + maxFillLevelRad * fillRate) * Math.PI;

        //draw filled area or progress bar
        context2D.beginPath();
        context2D.arc(centreX, centreY, radiusOfFillStroke, startAngle, endAngleFill, antiClockwise);
        context2D.lineWidth = arcWidth;
        context2D.strokeStyle = fillColor;
        context2D.stroke();

        //draw empty area of progress bar
        context2D.beginPath();
        context2D.arc(centreX, centreY, radiusOfFillStroke, endAngleFill, endAngle, antiClockwise);
        context2D.lineWidth = arcWidth;
        context2D.strokeStyle = backgroundColor;
        context2D.stroke();
      }

      // draw borders
      // these will always be from -45 degree to 45 degree
      const BORDER_START_ANGLE = (0.75 + (rightArc ? 1 : 0)) * Math.PI ;
      const BORDER_END_ANGLE = (1.25 - (rightArc ? 1 : 0)) * Math.PI;

      // draw inner lines
      for (var i = 1; i < NUMBER_OF_PROGRESS_BARS; i++) {
        let currentRadius = _OUTER_RADIUS - i * arcWidth;
        // draw each outer radius
        context2D.beginPath();
        context2D.lineWidth = borderWidth;
        context2D.strokeStyle = borderColor;
        context2D.arc(centreX, centreY, currentRadius, BORDER_START_ANGLE, BORDER_END_ANGLE, false);
        context2D.stroke();
      }

      // draw seperation lines in specific progress bars
      for (var i = 0; i < progressBarsToDivide.length; i++) {
        let divideNumber = progressBarsToDivide[i];

        let currentRadius = _OUTER_RADIUS - (divideNumber-1) * arcWidth;
        let innerRadius = _OUTER_RADIUS - (divideNumber) * arcWidth;
        const radBorder = ((_HALF_BORDER_WIDTH / 2) / currentRadius) / 2;
        const startRad = -0.25 + radBorder + (!rightArc ? 1 : 0);
        const endRad = 0.25 - radBorder + (!rightArc ? 1 : 0);
        const maxFillLevelRad = 0.5 - 2 * radBorder;
        const startAngle = directionSign * startRad * Math.PI;
        const endAngle = directionSign * endRad * Math.PI;

        for (var j = 0; j < progressBarDivisionFillRates.length; j++) {

          let myfillRate = progressBarDivisionFillRates[j];

          const endAngleFill = directionSign * (startRad + maxFillLevelRad * myfillRate) * Math.PI;

          context2D.beginPath();

          if(!rightArc) {
            context2D.arc(centreX, centreY, currentRadius, startAngle, endAngleFill, false);
            context2D.arc(centreX, centreY, innerRadius, endAngleFill, startAngle, true);
          } else {
            context2D.arc(centreX, centreY, currentRadius, startAngle, endAngleFill, true);
            context2D.arc(centreX, centreY, innerRadius, endAngleFill, startAngle, false);
          }

          context2D.lineWidth = borderWidth;
          context2D.strokeStyle = borderColor;
          context2D.closePath();
          context2D.stroke();
        }
      }

      // draw serene circle
      if (showSerene) {

        let currentRadius = _OUTER_RADIUS - _TOTAL_ARCS_WIDTH;
        let innerRadius = currentRadius - 1; // for fictional inner arc

        const radBorder = ((_HALF_BORDER_WIDTH / 2) / currentRadius) / 2;
        const startRad = -0.25 + radBorder + (!rightArc ? 1 : 0);
        const maxFillLevelRad = 0.5 - 2 * radBorder;

        let lesserRate = 0.41;
        let higherRate = 0.59;

        let innerLesserRate = 0.44;
        let innerHigherRate = 0.56;

        const startAngleCurve = directionSign * (startRad + maxFillLevelRad * lesserRate) * Math.PI;
        const endAngleCurve = directionSign * (startRad + maxFillLevelRad * higherRate) * Math.PI;

        const innerstartAngleCurve = directionSign * (startRad + maxFillLevelRad * innerLesserRate) * Math.PI;
        const innerendAngleCurve = directionSign * (startRad + maxFillLevelRad * innerHigherRate) * Math.PI;

        // lower intersection with the left arc
        const x_lower = centreX + currentRadius * Math.cos(startAngleCurve);
        const y_lower = centreY + currentRadius * Math.sin(startAngleCurve);

        // upper intersection with the left arc
        const x_upper = centreX + currentRadius * Math.cos(endAngleCurve);
        const y_upper = centreY + currentRadius * Math.sin(endAngleCurve);

        // lower intersection with fictional further arc for the bezier curves
        const x_inner_lower = centreX + innerRadius * Math.cos(innerstartAngleCurve);
        const y_inner_lower = centreY + innerRadius * Math.sin(innerstartAngleCurve);

        // upper intersection with fictional further arc for the bezier curves
        const x_inner_upper = centreX + innerRadius * Math.cos(innerendAngleCurve);
        const y_inner_upper = centreY + innerRadius * Math.sin(innerendAngleCurve);

        // Center of the serene circle
        let centersign = rightArc ? (-1) : 1;
        const m_1 = (x_inner_upper + centersign * ((y_inner_lower - y_inner_upper) / 2 - 1));
        const m_2 = ((y_inner_upper + y_inner_lower) / 2);

        // Radius for the outer circle
        const radius_innercircle = (y_inner_lower - y_inner_upper) / 2; //Math.sqrt(( x_inner_upper - m_1 )* ( x_inner_upper - m_1 ) + ( y_inner_upper - m_2 )* ( y_inner_upper - m_2 ) );

        let counterclock = rightArc ? true : false;

        context2D.beginPath();
        context2D.arc(centreX, centreY, currentRadius, startAngleCurve, endAngleCurve, counterclock);
        context2D.moveTo(x_upper, y_upper);
        context2D.bezierCurveTo(x_inner_upper, y_inner_upper + 3, m_1, m_2 - radius_innercircle, m_1, m_2 - radius_innercircle);
        context2D.arc(m_1, m_2, radius_innercircle, 3 * Math.PI / 2, Math.PI / 2, counterclock);
        context2D.bezierCurveTo(x_inner_lower, y_inner_lower - 3, x_lower, y_lower, x_lower, y_lower);
        context2D.fillStyle = backgroundColor;
        context2D.fill();

        context2D.beginPath();
        if (isSerene) {
          context2D.fillStyle = sereneColor;
        } else {
          context2D.fillStyle = backgroundColor;
        }
        context2D.arc(m_1, m_2, radius_innercircle-3, 0, 2 * Math.PI);
        context2D.fill();
        context2D.stroke();
      } 
      
      


      //draw border around all progress bars
      const INNER_RADIUS = _OUTER_RADIUS - progressBarsFillRates.length * arcWidth;
      context2D.beginPath();
      context2D.lineWidth = borderWidth;
      context2D.strokeStyle = borderColor;
      context2D.arc(centreX, centreY, _OUTER_RADIUS, BORDER_START_ANGLE, BORDER_END_ANGLE, false);
      context2D.arc(centreX, centreY, INNER_RADIUS, BORDER_END_ANGLE, BORDER_START_ANGLE, true);
      context2D.closePath();
      context2D.stroke();

    } //function drawHud

    onPaint: {
      var ctx = getContext("2d");
      drawHud(rightArc,ctx);
    } //onPaint

}
