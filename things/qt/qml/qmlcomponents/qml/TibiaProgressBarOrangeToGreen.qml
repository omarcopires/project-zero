import QtQuick.Layouts



TibiaProgressBar {
  height: TibiaStyle.progressBarSmallHeight
  width: 150
  Layout.preferredHeight: height
  Layout.preferredWidth: width

  frameSource: "/images/1pixel-down-frame.png"
  backgroundSource: "/images/backdrop-dark-grey.png"
  fillSource: fillPercentage >= 1
    ? "/images/progressbar-green-large.png"
    : "/images/progressbar-orange-large.png"

  frameBorder { left: 1; right: 1; top:1; bottom: 1}
  fillOffset { left: 1; right: 1; top:1; bottom: 1}
} //TibiaProgressBar
