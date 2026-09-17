import QtQuick
import QtQuick.Layouts

import qmlcomponents


ColumnLayout {
  property var controller: null
  visible: controller != null ? controller.visible : false
  spacing: 0

  RowLayout {
    spacing: TibiaStyle.marginRelated

    Image {
      id: latencyIcon

      states: [
        State {
          name: "LOW_LATENCY"
          when: controller != null && controller.currentLatencyState == "low"
          PropertyChanges { target: latencyIcon; source: "/images/latency/latency-low.png" }
          PropertyChanges { target: latencyTooltip; latencyTextIdentifier: "latency_low"}
        },
        State {
          name: "MEDIUM_LATENCY"
          when: controller != null && controller.currentLatencyState == "medium"
          PropertyChanges { target: latencyIcon; source: "/images/latency/latency-medium.png" }
          PropertyChanges { target: latencyTooltip; latencyTextIdentifier: "latency_medium"}
        },
        State {
          name: "HIGH_LATENCY"
          when: controller != null && controller.currentLatencyState == "high"
          PropertyChanges { target: latencyIcon; source: "/images/latency/latency-high.png" }
          PropertyChanges { target: latencyTooltip; latencyTextIdentifier: "latency_high"}
        },
        State {
          name: "MEASURING_LATENCY"
          when: controller != null && controller.currentLatencyState == "measuring"
          PropertyChanges { target: latencyIcon; source: "/images/latency/latency-high.png" }
          PropertyChanges { target: latencyTooltip; latencyTextIdentifier: "latency_measuring"}
        }
      ] //states

      Image {
        source: controller != null && controller.optimizedConnectionStability ? "/images/latency/optimized-connection-stability.png" : ""
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
      } //Image

      state: "LOW_LATENCY"

      Tooltip {
        id: latencyTooltip
        anchors.fill: parent

        property string latencyText: "-"
        property string latencyTextIdentifier: "latency_high"
        text: qsTrId("latency_text").arg(qsTrId(latencyTextIdentifier)).arg(controller != null ? controller.currentLatency : "0")
      } //Tooltip
    } //Image

    TibiaCachedOutlineText {
      id: latencyDisplay
      text: latencyTooltip.text
      styleType: "Default"
      cacheMode: CachedOutlineText.NoCaching
    } //TibiaCachedOutlineText
  } //RowLayout

  RowLayout {
    spacing: TibiaStyle.marginRelated

    Item {
      Layout.preferredWidth: latencyIcon.width
      Layout.preferredHeight: latencyIcon.height
    } //Item

    TibiaCachedOutlineText {
      id: fpsDisplay
      text: qsTrId("fps_text").arg(controller != null ? controller.currentFrameRate : 0)
      styleType: "Default"
      cacheMode: CachedOutlineText.NoCaching
    } //TibiaCachedOutlineText
  } //RowLayout
} //ColumnLayout
