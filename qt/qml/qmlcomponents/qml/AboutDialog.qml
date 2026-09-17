import QtQuick
import QtQuick.Layouts



TibiaDialog {
  id: aboutDialog
  caption: qsTrId("aboutdialog_caption")
  width: 250

  property var controller: null;
  property string operatingSystemName: controller != null ? controller.operatingSystemName : ""
  property string copyrightPeriod: controller != null ? controller.copyrightPeriod : ""
  property string tibiaVersion: controller != null ? controller.tibiaVersion : ""

  onReturnPressedFunction: function() {
    if (controller != null) {
      controller.requestClose();
    }
  }

  onCancelPressedFunction: onReturnPressedFunction

  initialFocusItem: aboutDialog
  KeyNavigation.tab: aboutDialog

  ColumnLayout {
    anchors { left: parent.left; right: parent.right; top: parent.top }
    spacing: TibiaStyle.marginUnrelated

    TibiaFrame1PixelDown {
      Layout.fillWidth: true
      Layout.preferredHeight: infoLayout.height

      ColumnLayout {
        id: infoLayout
        anchors { left: parent.left; right: parent.right; top: parent.top;
                  leftMargin: TibiaStyle.marginUnrelated; rightMargin: TibiaStyle.marginUnrelated }
        spacing: TibiaStyle.marginRelated

        TibiaText {
          text: controller != null ? controller.clientType : qsTrId("dummy_unknown")
          Layout.alignment: Qt.AlignHCenter
          Layout.topMargin: TibiaStyle.marginUnrelated
        } //TibiaText

        TibiaText {
          text: qsTrId("aboutdialog_clientversion").arg(tibiaVersion)
          Layout.alignment: Qt.AlignHCenter
        } //TibiaText

        TibiaText {
          text: qsTrId("aboutdialog_copyright").arg(copyrightPeriod)
          Layout.alignment: Qt.AlignHCenter
        } //TibiaText

        TibiaText {
          text: "CipSoft GmbH" // This text doesn't need to be translated
          Layout.alignment: Qt.AlignHCenter
        } //TibiaText

        TibiaText {
          text: qsTrId("aboutdialog_allrightsreserved")
          Layout.alignment: Qt.AlignHCenter
        } //TibiaText

        TibiaHorizontalSeparator {
          Layout.fillWidth: true
          Layout.bottomMargin: TibiaStyle.marginRelated
          Layout.topMargin: TibiaStyle.marginRelated
        } //TibiaHorizontalSeparator

        TibiaText {
          text: qsTrId("aboutdialog_qt_attribution")
          Layout.fillWidth: true
          horizontalAlignment: Text.AlignHCenter
        } // TibiaText

        TibiaText {
          text: qsTrId("aboutdialog_qt_license")
          Layout.fillWidth: true
          horizontalAlignment: Text.AlignHCenter
          wrapMode: Text.Wrap
        } // TibiaText

        TibiaText {
          text: qsTrId("aboutdialog_qt_source")
          Layout.fillWidth: true
          horizontalAlignment: Text.AlignHCenter
          wrapMode: Text.Wrap
        } // TibiaText

        TibiaHorizontalSeparator {
          Layout.fillWidth: true
          Layout.bottomMargin: TibiaStyle.marginRelated
          Layout.topMargin: TibiaStyle.marginRelated
        } //TibiaHorizontalSeparator

        GridLayout {
          Layout.alignment: Qt.AlignHCenter
          Layout.bottomMargin: TibiaStyle.marginUnrelated
          columns: 2

          TibiaText {
            text: qsTrId("aboutdialog_website")
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
          } //TibiaText

          TibiaButton {
            text: "www.tibia.com" // This text doesn't need to be translated
            Layout.preferredWidth: TibiaStyle.buttonWidthWide

            onClicked: {
              if (controller != null) {
                controller.requestOpenWebsite();
              }
            } //onClicked
          } //TibiaButton

          TibiaText {
            text: qsTrId("aboutdialog_licenses")
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
          } //TibiaText

          TibiaButton {
            text: qsTrId("show")
            Layout.preferredWidth: TibiaStyle.buttonWidthWide

            onClicked: {
              if (controller != null) {
                controller.requestShowLicensesDialog();
              }
            } // onClicked
          } //TibiaButton
        } // GridLayout
      } // ColumnLayout
    } // TibiaFrame1PixelDown

    TibiaHorizontalSeparator {
      Layout.fillWidth: true
    } //TibiaHorizontalSeparator

    TibiaButton {
      Layout.alignment: Qt.AlignRight
      text: qsTrId("ok")

      onClicked: onReturnPressedFunction();
    } //TibiaButton
  } // ColumnLayout
} // TibiaDialog
