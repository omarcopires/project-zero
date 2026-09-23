import QtQuick
import QtQuick.Layouts
import qmlcomponents



Item {
  id: panelRoot

  property alias caption: panel.caption
  property alias conversionSourceTypeId: conversionSource.typeid
  property alias conversionSourceIconId: currentCurrencyAmount.iconId
  property string conversionSourceAmount: "0"
  property alias conversionTargetTypeId: conversionTarget.typeid
  property var actionCaption: ""
  property alias tooltipText: convertButton.tooltipText
  property bool showDoubleIcon: false
  property bool readOnly: false
  property bool tooLowBalance: false
  property bool clientSettingSmoothFiltering: false

  property QtObject currentHoverMouseArea

  signal clicked
  signal showPanelHoverText
  signal showButtonHoverText
  signal hideHoverText

  implicitHeight: 255
  implicitWidth: 150

  TibiaPanel2PixelUpFilledWithCaption {
    id: panel
    anchors.fill: parent

    TibiaFrame1PixelDown {
      id: backgroundFrame
      Layout.topMargin: TibiaStyle.marginRelated
      Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
      Layout.preferredWidth: 66
      Layout.preferredHeight: 66

      BorderImage {
        anchors.fill: parent
        anchors.margins: parent.borderWidth
        source: "/images/backdrop-dark-grey.png"
        horizontalTileMode: BorderImage.Repeat
        verticalTileMode: BorderImage.Repeat
        visible: true

        SingleObjectAppearanceInstanceRenderer {
          id: conversionSource
          anchors.centerIn: parent
          width: TibiaStyle.mapWindowPixelPerField * 2
          height: TibiaStyle.mapWindowPixelPerField * 2
          scaleFactor: TibiaStyle.exaltationForgeItemScaleFactor

          animated: true
          typeid: 0
          cumulativeCount: 100
          smoothTextureFiltering: clientSettingSmoothFiltering
        } //SingleObjectAppearanceInstanceRenderer
      } //BorderImage
    } //TibiaFrame1PixelDown

    Item {
      Layout.topMargin: TibiaStyle.marginNarrow
      Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
      Layout.preferredWidth: backgroundFrame.width
      Layout.preferredHeight: currentCurrencyAmount.implicitHeight

      TibiaCurrencyView {
        id: currentCurrencyAmount
        anchors.fill: parent
        rightAligned: false
        balance: conversionSourceAmount
        tooLowBalance: panelRoot.tooLowBalance
      } //TibiaCurrencyView

      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
          panelRoot.currentHoverMouseArea = this;
          showPanelHoverText()
        }
        onExited: {
          if (panelRoot.currentHoverMouseArea === this) {
            hideHoverText()
          }
        }
      } // MouseArea
    } //Item

    Image {
      Layout.topMargin: TibiaStyle.marginUnrelated
      Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
      source: "/images/icon-arrow-downlarge.png"
    } //Image

    Item {
      Layout.topMargin: TibiaStyle.marginUnrelated
      Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
      Layout.preferredWidth: showDoubleIcon ? 128 : 83
      Layout.preferredHeight: 66

      TibiaButton {
        id: convertButton
        anchors.fill: parent
        enabled: !panelRoot.tooLowBalance && !panelRoot.readOnly
        onClicked: panelRoot.clicked()

        SingleObjectAppearanceInstanceRenderer {
          id: conversionTarget
          anchors.centerIn: parent
          width: TibiaStyle.mapWindowPixelPerField * 2
          height: TibiaStyle.mapWindowPixelPerField * 2
          scaleFactor: TibiaStyle.exaltationForgeItemScaleFactor
          anchors.verticalCenterOffset: (showDoubleIcon ? 5 : 0) + (convertButton.pressed || convertButton.checked ? 1 : 0)
          anchors.horizontalCenterOffset: (showDoubleIcon ? -25 : 0) + (convertButton.pressed || convertButton.checked ? 1 : 0)
          anchors.leftMargin: 1 + TibiaStyle.marginRelated + (convertButton.pressed || convertButton.checked ? 1 : 0)
          anchors.rightMargin: 1 + TibiaStyle.marginRelated + (convertButton.pressed || convertButton.checked ? -1 : 0)

          animated: !panelRoot.tooLowBalance && !panelRoot.readOnly
          typeid: 0
          cumulativeCount: 100
          smoothTextureFiltering: clientSettingSmoothFiltering
        } //SingleObjectAppearanceInstanceRenderer

        Loader {
          id: conversionTarget2
          anchors.centerIn: parent
          anchors.verticalCenterOffset: -5 + (convertButton.pressed || convertButton.checked ? 1 : 0)
          anchors.horizontalCenterOffset: 25 + (convertButton.pressed || convertButton.checked ? 1 : 0)
          anchors.leftMargin: 1 + TibiaStyle.marginRelated + (convertButton.pressed || convertButton.checked ? 1 : 0)
          anchors.rightMargin: 1 + TibiaStyle.marginRelated + (convertButton.pressed || convertButton.checked ? -1 : 0)
          active: showDoubleIcon
          sourceComponent: SingleObjectAppearanceInstanceRenderer {
            width: TibiaStyle.mapWindowPixelPerField * 2
            height: TibiaStyle.mapWindowPixelPerField * 2
            scaleFactor: TibiaStyle.exaltationForgeItemScaleFactor

            animated: !panelRoot.tooLowBalance && !panelRoot.readOnly
            typeid: conversionTarget.typeid
            cumulativeCount: 100
            smoothTextureFiltering: clientSettingSmoothFiltering
          } //SingleObjectAppearanceInstanceRenderer
        } //Loader

        TibiaDisabledOverlay {
          anchors.fill: parent
          anchors.margins: TibiaStyle.marginNarrow
          visible: panelRoot.tooLowBalance || panelRoot.readOnly
        }
      } //TibiaButton

      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.RightButton
        onEntered: {
          panelRoot.currentHoverMouseArea = this;
          showButtonHoverText()
        }
        onExited: {
          if (panelRoot.currentHoverMouseArea === this) {
            hideHoverText()
          }
        }
      } // MouseArea
    } //Item

    TibiaText {
      Layout.topMargin: TibiaStyle.marginRelated
      Layout.alignment: Qt.AlignTop | Qt.AlignHCenter

      text: actionCaption
      textFormat: Text.RichText
    } //TibiaText
  } //TibiaPanel2PixelUpFilledWithCaption

  MouseArea {
    anchors.fill: parent
    z: -1
    hoverEnabled: true
    acceptedButtons: Qt.RightButton
    onEntered: {
      panelRoot.currentHoverMouseArea = this;
      showPanelHoverText()
    }
    onExited: {
      if (panelRoot.currentHoverMouseArea === this) {
        hideHoverText()
      }
    }
  } // MouseArea
} //Item
