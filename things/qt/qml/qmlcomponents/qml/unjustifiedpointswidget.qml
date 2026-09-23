import QtQuick
import QtQuick.Layouts

import qmlcomponents



TibiaSidebarWidget {
  id: vipSidebarWidget
  caption: qsTrId("unjustified_caption")
  picSource: "/images/skin/classic/icon-unjustified-points-widget.png"

  minContentHeight: 55
  maxContentHeight: 55

  RowLayout {
    anchors {left: parent.left; top: parent.top; right: parent.right}
    anchors.margins: 3
    spacing: 0

    ColumnLayout {
      Layout.fillWidth: true
      spacing: TibiaStyle.skullBarSpacing

      TibiaText {
        Layout.fillWidth: true
        text: qsTrId("open_pvp_situations").arg(widgetController != null ? widgetController.openPvpSituationCount : 0)
        Tooltip {
          anchors.fill: parent
          text: qsTrId("open_pvp_situations_tooltip")
        } //Tooltip
      } //TibiaText

      TibiaUnjustifiedPointsSkull {
        Layout.alignment: Qt.AlignHCenter
        skullImageSource: widgetController != null ? widgetController.currentSkullSource : ""
        Tooltip {
          anchors.fill: parent
          text: parent.skullImageSource == "" ? qsTrId("no_skull_tooltip") : qsTrId("current_skull_tooltip")
        } //Tooltip
      } //TibiaUnjustifiedPointsSkull

      TibiaText {
        property int days: widgetController != null ? widgetController.skullDuration : 0
        opacity: days > 0 ? 1 : 0
        text: qsTrId(days > 1 ? "skull_time_left_plural" : "skull_time_left").arg(days)
        Tooltip {
          anchors.fill: parent
          text: qsTrId("skull_time_left_tooltip")
          enabled: parent.days > 0
        } //Tooltip
      } //TibiaText
    } //ColumnLayout

    ColumnLayout {
      spacing: TibiaStyle.skullBarSpacing

      Tooltip {
        id: dayTooltip
        implicitWidth: dayDataRow.width
        implicitHeight: dayDataRow.height

        property int killsToNextSkullDay: widgetController != null ? widgetController.fullKillsToNextSkullDay : 3
        text: qsTrId(killsToNextSkullDay == 1 ? "unjustified_point_24h_tooltip" : "unjustified_point_24h_tooltip_plural").arg(killsToNextSkullDay)

        RowLayout {
          id: dayDataRow
          spacing: TibiaStyle.skullBarSpacing

          TibiaUnjustifiedPointsProgressBar {
            fillPercentage: widgetController != null ? widgetController.progressDay : 0.0
            killsToNextSkull: dayTooltip.killsToNextSkullDay
          } //TibiaUnjustifiedPointsProgressBar

          TibiaUnjustifiedPointsSkull {
            skullImageSource: widgetController != null ? widgetController.nextSkullSource : "image://creaturestateflags-playerkiller/3"
          } //TibiaUnjustifiedPointsSkull
        } //RowLayout
      } //Tooltip

      Tooltip {
        id: weekTooltip
        implicitWidth: weekDataRow.width
        implicitHeight: weekDataRow.height

        property int killsToNextSkullWeek: widgetController != null ? widgetController.fullKillsToNextSkullWeek : 3
        text: qsTrId(killsToNextSkullWeek == 1 ? "unjustified_point_7days_tooltip" : "unjustified_point_7days_tooltip_plural").arg(killsToNextSkullWeek)

        RowLayout {
          id: weekDataRow
          spacing: TibiaStyle.skullBarSpacing

          TibiaUnjustifiedPointsProgressBar {
            fillPercentage: widgetController != null ? widgetController.progressWeek : 0.0
            killsToNextSkull: weekTooltip.killsToNextSkullWeek
          } //TibiaUnjustifiedPointsProgressBar

          TibiaUnjustifiedPointsSkull {
            skullImageSource: widgetController != null ? widgetController.nextSkullSource : "image://creaturestateflags-playerkiller/3"
          } //TibiaUnjustifiedPointsSkull
        } //RowLayout
      } //Tooltip

      Tooltip {
        id: monthTooltip
        implicitWidth: monthDataRow.width
        implicitHeight: monthDataRow.height

        property int killsToNextSkullMonth: widgetController != null ? widgetController.fullKillsToNextSkullMonth : 3
        text: qsTrId(killsToNextSkullMonth == 1 ? "unjustified_point_30days_tooltip" : "unjustified_point_30days_tooltip_plural").arg(killsToNextSkullMonth)

        RowLayout {
          id: monthDataRow
          spacing: TibiaStyle.skullBarSpacing

          TibiaUnjustifiedPointsProgressBar {
            fillPercentage: widgetController != null ? widgetController.progressMonth : 0.0
            killsToNextSkull: monthTooltip.killsToNextSkullMonth
          } //TibiaUnjustifiedPointsProgressBar

          TibiaUnjustifiedPointsSkull {
            skullImageSource: widgetController != null ? widgetController.nextSkullSource : "image://creaturestateflags-playerkiller/3"
          } //TibiaUnjustifiedPointsSkull
        } //RowLayout
      } //Tooltip
    } //ColumnLayout
  } //RowLayout

  Lenshelp {
    anchors.fill: parent
    triggerRect: mapFromItem(widgetRoot, 0, 0, widgetRoot.width, widgetRoot.height)
    caption: qsTrId("unjustified_lenshelp_caption")
    content: qsTrId("unjustified_lenshelp")
  } //Lenshelp

} // TibiaSidebarWidget
